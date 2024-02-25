#!/usr/bin/env bash
# Results shown in split-window in tmux
# Uncomment the other line if not using tmux
# Totally not stolen from Primeagen

languages=$(echo "python javascript golang" | tr " " "\n")
core_utils=$(echo "find xargs sed awk grep" | tr " " "\n")
selected=$(echo -e "$languages\n$core_utils" | fzf)
read -p "Enter Query: " query
if echo "$languages" | grep -qs $selected; then
	tmux split-window -h bash -c "curl cht.sh/$selected/$(echo "$query" | tr ' ' '+') | less -R"
	# curl cht.sh/$selected/$(echo "$query" | tr ' ' '+') | less -R
else
	tmux split-window -h bash -c "curl cht.sh/$selected~$query | less -R"
	# curl cht.sh/$selected~$query | less -R
fi
