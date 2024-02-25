# Used to get sections so that I can hard code them in the other script
KEY=$todoist_api

curl -s -H "Authorization: Bearer $KEY" \
    https://api.todoist.com/rest/v2/sections?project_id=2212737897
