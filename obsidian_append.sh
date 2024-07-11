#!/usr/bin/env bash
# Append to a file in Obsidian Inbox folder
# Format it as markdown task

path="$HOME/Documents/Obsidian/Main_vault/00 Inbox/Stuff.md"
date_time=$(date +"%Y-%m-%d %H:%M:%S")
read -p "Task: " task
printf -- "- [ ] %s %s\n" "$date_time" "$task" >> "$path"
