#!/usr/bin/env bash
# Simple way to send notifications to phone - uses https://ntfy.sh/

topic=$ntfy_topic

if [[ $# -eq 0 ]]; then
    read -p "Message: " msg
else
    msg=$1
fi

curl -d "$msg" ntfy.sh/$topic
