#!/usr/bin/env bash
# Results shown in split-window in tmux
# Uncomment the other line if not using tmux
# Totally not stolen from Primeagen

usage() {
    echo "Usage: cht.sh"
    echo
    echo "Fuzzy search cheat sheets from cht.sh."
    echo "1. Pick a language or utility from the list"
    echo "2. Enter your query"
    echo "Opens in a tmux split window."
    exit 0
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && usage

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
