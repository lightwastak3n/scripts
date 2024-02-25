#!/usr/bin/env bash
# Add a task to a todoist list. 
# List ids can be found in the web app 
#
# Section ids are from the API
# curl -s -H "Authorization: Bearer $KEY" \
# https://api.todoist.com/rest/v2/sections?project_id=2212737897
# Basically just used to add groceries since terminal is always open and I usually forget what to add in 5 secs


KEY=$todoist_api

INBOX=378525202
KUPOVINA=2212737897

NXT=26008550
DM=48404723

function add_to_section() {
    local project_id=$1
    local task_add=$2
    local section_id=$3
    curl "https://api.todoist.com/rest/v2/tasks" \
        -X POST \
        --data "{\"content\": \"$task_add\", \"project_id\": \"$project_id\", \"section_id\": \"$section_id\"}" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $KEY"
}

function add_to_project() {
    local project_id=$1
    local task_add=$2
    curl "https://api.todoist.com/rest/v2/tasks" \
        -X POST \
        --data "{\"content\": \"$task_add\", \"project_id\": \"$project_id\"}" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $KEY"
}

read -p "Task: " task
read -p "Project: " pr

if [[ $pr = "inbox" ]]; then
	project="$INBOX"
	section="$NXT"
    echo "Adding $task to project $project and section $section"
    add_to_section $project $task $section
elif [[ $pr = "dm" ]]; then
	project="$KUPOVINA"
	section="$DM"
    echo "Adding $task to project $project and section $section"
    add_to_section $project $task $section
else
	project="$KUPOVINA"
    echo "Adding $task to project $project"
    add_to_project $project $task
fi



