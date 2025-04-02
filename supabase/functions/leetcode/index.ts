import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const GRAPHQL_URL = "https://leetcode.com/graphql"

interface Question {
  questionFrontendId: string
  titleSlug: string
}

interface LeetCodeResponse {
  data: {
    problemsetQuestionListV2: {
      questions: Question[]
    }
  }
}

async function getAllQuestions(): Promise<LeetCodeResponse> {
  const query = `
    query getAllQuestions {
        problemsetQuestionListV2(limit: 50000, skip: 0) {
            questions {
                questionFrontendId
                titleSlug
            }
        }
    }
  `

  const response = await fetch(GRAPHQL_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
    body: JSON.stringify({ query, variables: {} })
  })

  if (!response.ok) {
    throw new Error(`Query failed with status ${response.status}`)
  }

  return response.json()
}

async function initSupabaseClient(req: Request) {
  const supabaseUrl = Deno.env.get('SUPABASE_URL')
  const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY')

  if (!supabaseUrl || !supabaseAnonKey) {
    throw new Error("Supabase environment variables are missing.")
  }

  return createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: req.headers.get('Authorization')! } }
  })
}

async function processQuestions(questions: Question[]) {
  return questions.map((question, index) => {
    const id = parseInt(question.questionFrontendId)
    if (id !== index + 1) {
      return null
    }
    return {
      id,
      slug: question.titleSlug,
      questions: null,
      data: null
    }
  }).filter(Boolean)
}

Deno.serve(async (req) => {
  try {
    const supabaseClient = await initSupabaseClient(req)
    const questions = await getAllQuestions()
    const bulkData = await processQuestions(questions.data.problemsetQuestionListV2.questions)

    if (bulkData.length > 0) {
      const { error } = await supabaseClient
        .from('leetcode')
        .upsert(bulkData, { onConflict: 'id', ignoreDuplicates: true })

      if (error) {
        throw error
      }
    }

    return new Response(
      JSON.stringify({ message: 'Questions synchronized' }),
      { headers: { 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { 'Content-Type': 'application/json' }, status: 500 }
    )
  }
})
