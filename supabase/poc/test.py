import os
import requests
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Get the API key from the environment variables
ANON_KEY = os.getenv("SUPABASE_ANON_KEY")

# Define the URL and headers
url = "https://pfgcidvllsujvfryaiwz.supabase.co/functions/v1/leetcode"
headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {ANON_KEY}"
}

# Make the POST request
response = requests.post(url, headers=headers)

# Print the response
if response.status_code == 200:
    print("Success:", response.json())
else:
    print("Error:", response.status_code, response.text)