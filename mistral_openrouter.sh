#!/usr/bin/env bash
# openrouter mistral chat
# As of the time of making this script 1:32 AM it's free to use

api_key=$openrouter_api
instructions="You are a helpful assistant. Think about your prompt and respond correctly."
prompt="$instructions $1"

response=$(curl -s https://openrouter.ai/api/v1/chat/completions \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $api_key" \
-H "HTTP-Referer: http://localhost:5000/" \
-H "X-Title: terminal-helper" \
-d "{
\"model\": \"mistralai/mistral-7b-instruct\",
\"messages\": [
	{\"role\": \"user\", \"content\": \"$prompt\"}
]
}")

reply=$(echo "$response" | jq -r '.choices[0].message.content')
echo "$reply" | xclip -selection clipboard
