#!/usr/bin/env bash
# Append to a file in Obsidian Inbox folder
# Format it as markdown task

path="$HOME/Documents/Obsidian/Main_vault/00 Inbox/Stuff.md"
read -p "Task: " task
printf "\n- [ ] %s" "$task" >> "$path"
