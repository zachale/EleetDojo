from openai import OpenAI
import json
import os
from dotenv import load_dotenv
load_dotenv()


with open("leetcode.json", "r") as f:
    data = json.load(f)
if data["data"]["question"] is None:
    raise Exception("Question has no data")

question = data["data"]["question"]
prompt = f"""
Given the following information about a LeetCode question:
- Title: {question["title"]}
- Description: {question["content"]}
- Difficulty: {question["difficulty"]}
- Example Testcases: {question["exampleTestcases"]}
- Topic Tags: {", ".join(tag["name"] for tag in question["topicTags"])}
- Hints: {question["hints"]}

Build five questions each with four answers that would help someone understand the problem better.

Format the questions as a JSON array of objects with the following structure:
```json
[
    {{
        id: int
        question: string
        answers: [{{
            id: int
            label: string
        }}]
    answer: int
    }}
]
```

Return the JSON array and only the JSON array.
"""

OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY")
client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key=OPENROUTER_API_KEY,
)

completion = client.chat.completions.create(
    model="deepseek/deepseek-chat-v3-0324:free",
    messages=[
        {
            "role": "user",
            "content": prompt
        }
    ]
)
answer = completion.choices[0].message.content
with open("ai.json", "w") as f:
    answer = answer.split("```json\n")[-1].split("```")[0]
    json_answer = json.loads(answer)
    json.dump(json_answer, f, indent=4)