Refer to [this](https://supabase.com/docs/guides/functions/quickstart) Supabase documentation to get started for local development!

## Supabase

This folder is responsible for storing the backend of our Flutter-based application. A high-level overview of the code contained in this folder is:
1. `leetcode`: A Supabase edge function to talk with the Leetcode GraphQL API (https://leetcode.com/graphql) and maintain a table of the required information for rendering quizzes!

| id | slug | questions | data |
| --- | --- | --- | --- 
| int | text | jsonb or null | jsonb or null |

2. `questions`: A Supabase edge function to utilize the table above and generate questions based on an LLM API of our choice (which will vary depending on speed, cost, limits, and other factors). These questions will be generated and updated into the `leetcode` table.

| id | leetcodeId | question | answers | answer |
| --- | --- | --- | --- | --- |
| int | int | text | jsonb | int |

## System Design
1. `leetcode` edge function is ran periodically (CRON) to ensure the data is synced with Leetcode's website
2. `questions` edge function is ran when the application attempts to fetch an entry from the `leetcode` table where the `questions` column is `null`
3. This implementation makes our database build itself as users uncover new questions for the first time!