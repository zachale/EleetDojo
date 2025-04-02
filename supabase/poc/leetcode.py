import requests
import json


GRAPHQL_URL = "https://leetcode.com/graphql"
HEADERS = {
    "Content-Type": "application/json",
    "Accept": "application/json"
}

def get_all_questions():
    # Small set of questions, so no pagination is in place
    query = """
    query getAllQuestions {
        problemsetQuestionListV2(limit: 50000, skip: 0) {
            questions {
                questionFrontendId
                titleSlug
                content
                topicTags {
                    name
                }
            }
        }
    }
    """
    json = {
        "query": query,
        "variables": {}
    }

    response = requests.post(GRAPHQL_URL, json=json, headers=HEADERS)
    if response.ok:
        return response.json()
    else:
        raise Exception(f"query \"getAllQuestions\" responded with {response.status_code}: {response.text}")




# Leetcode GraphQL API query to get question data by slug
# - Leetcode does not provide a query by ID directly, but we will
#   store a mapping from slug to ID to take care of this
def search_question_by_slug(question_slug):
    query = """
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
    """
    variables = {"titleSlug": question_slug}
    json = {
        "query": query,
        "variables": variables
    }

    response = requests.post(GRAPHQL_URL, json=json, headers=HEADERS)
    if response.ok:
        return response.json()
    else:
        raise Exception(f"query \"getQuestion\" responded with {response.status_code}: {response.text}")

# Example usage
if __name__ == "__main__":
    # We can also use an array which is way more efficient here
    # NOTE: The mapping is 1-indexed
    questions = get_all_questions()
    question_map = {}
    id_count = 0
    for question in questions["data"]["problemsetQuestionListV2"]["questions"]:
        id_count += 1
        _id = int(question["questionFrontendId"])
        if _id != id_count:
            break # Stop at the end of consecutive IDs
        question_map[_id] = question["titleSlug"]

    # Save the mapping to a JSON file
    with open("questions.json", "w") as f:
        json.dump(question_map, f, indent=4)

    # 1 -> Two Sum
    # question_id = question_map[1]
    # result = search_question_by_slug("two-sum")
    # with open("leetcode.json", "w") as f:
    #     json.dump(result, f, indent=4)