#!/usr/bin/env bash
# Simple way to send notifications to phone - uses https://ntfy.sh/

usage() {
    echo "Usage: ntfy.sh [message]"
    echo
    echo "Send a notification to your phone via ntfy.sh."
    echo "If no message is provided, you'll be prompted for one."
    exit 0
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && usage

topic=$ntfy_topic

if [[ $# -eq 0 ]]; then
    read -p "Message: " msg
else
    msg=$1
fi

curl -d "$msg" ntfy.sh/$topic
