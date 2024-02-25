#!/usr/bin/env bash
# Use fzf to search through scripts and then run them

selected=$(find ~/scripts -maxdepth 1 -type f | fzf)
"$selected"
