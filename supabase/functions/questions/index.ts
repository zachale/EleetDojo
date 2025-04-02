import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface Answer {
  id: number;
  label: string;
}

interface GeneratedQuestion {
  id: number;
  question: string;
  answers: Answer[];
  answer: number;
}

interface LeetCodeQuestion {
  title: string;
  content: string;
  difficulty: string;
  exampleTestcases: string;
  topicTags: { name: string }[];
  hints: string[];
}

async function generatePrompt(question: LeetCodeQuestion): Promise<string> {
  return `
  Given the following information about a LeetCode question:
  - Title: ${question.title}
  - Description: ${question.content}
  - Difficulty: ${question.difficulty}
  - Example Testcases: ${question.exampleTestcases}
  - Topic Tags: ${question.topicTags.map(tag => tag.name).join(", ")}
  - Hints: ${question.hints}

  Build five questions each with four answers that would help someone understand the problem better.

  Format the questions as a JSON array of objects with the following structure:
  [{
      id: int
      question: string
      answers: [{
          id: int
          label: string
      }]
      answer: int
  }]

  Return the JSON array and only the JSON array.`;
}

async function generateQuestions(question: LeetCodeQuestion): Promise<GeneratedQuestion[]> {
  const openrouterKey = Deno.env.get('OPENROUTER_API_KEY')
  if (!openrouterKey) throw new Error('OpenRouter API key not found')

  const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${openrouterKey}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      model: 'deepseek/deepseek-chat-v3-0324:free',
      messages: [{ role: 'user', content: await generatePrompt(question) }]
    })
  })

  if (!response.ok) throw new Error(`API request failed: ${response.statusText}`)
  
  const result = await response.json()
  const content = result.choices[0].message.content
  const jsonContent = content.split('```json\n').pop()?.split('```')[0] || content
  try {
    return JSON.parse(jsonContent.trim())
  } catch (e) {
    throw new Error(`Failed to parse AI response: ${jsonContent}`)
  }
}

const GRAPHQL_URL = "https://leetcode.com/graphql"

async function fetchQuestionData(questionSlug: string): Promise<LeetCodeQuestion> {
  const query = `
    query getQuestion($titleSlug: String!) {
        question(titleSlug: $titleSlug) {
            questionId
            questionFrontendId
            title
            titleSlug
            content
            difficulty
            similarQuestions
            exampleTestcases
            topicTags {
                name
                slug
            }
            stats
            hints
            solution {
                id
            }
            status
        }
    }
  `
  const response = await fetch(GRAPHQL_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
    body: JSON.stringify({
      query,
      variables: { titleSlug: questionSlug }
    })
  })

  if (!response.ok) {
    throw new Error(`LeetCode API request failed: ${response.statusText}`)
  }

  const result = await response.json()
  return result.data.question
}

Deno.serve(async (req) => {
  try {
    // Parse request body for questionId
    const { questionId } = await req.json()
    if (!questionId) throw new Error('Question ID is required')

    // Supabase credentials
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY')
  
    if (!supabaseUrl || !supabaseAnonKey) {
      throw new Error("Supabase environment variables are missing.")
    }

    const supabaseClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: req.headers.get('Authorization')! } }
    })

    // Get specific question by ID
    const { data: leetcodeData, error: fetchError } = await supabaseClient
      .from('leetcode')
      .select('*')
      .eq('id', questionId)
      .single()

    if (fetchError) throw fetchError
    let data = leetcodeData
    if (data?.questions) {
      // If questions exist, fetch them from the questions table
      const { data: existingQuestions, error: questionsError } = await supabaseClient
        .from('questions')
        .select('*')
        .in('id', data.questions)

      if (questionsError) throw questionsError
      if (existingQuestions.length > 0) {
        return new Response(
          JSON.stringify({ questions: existingQuestions }),
          { headers: { 'Content-Type': 'application/json' } }
        )
      }
    }
    
    // Generate fresh data
    const freshData = await fetchQuestionData(leetcodeData.slug)
    leetcodeData.data = freshData

    // Generate questions
    const questions = await generateQuestions(leetcodeData.data)
    
    // Insert questions into questions table with leetcode_id and collect their IDs
    let questions_data = questions.map(q => {
      const { id, ...rest } = q;
      return { ...rest, leetcode_id: questionId };
    })
    const { data: insertedQuestions, error: questionsError } = await supabaseClient
      .from('questions')
      .insert(questions_data)
      .select('id')

    if (questionsError) throw questionsError

    // Extract question IDs into an array
    const questionIds = insertedQuestions.map(q => q.id)

    // Update the leetcode entry with generated questions and data
    const { error: updateError } = await supabaseClient
      .from('leetcode')
      .update({ 
        questions: questionIds,
        data: leetcodeData.data 
      })
      .eq('id', questionId)
      .select()
      
    if (updateError) throw updateError

    return new Response(
      JSON.stringify({ questions }),
      { headers: { 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { 'Content-Type': 'application/json' }, status: 500 }
    )
  }
})
