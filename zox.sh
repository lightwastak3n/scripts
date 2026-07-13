#!/usr/bin/env bash
# zox: cd replacement with fuzzy search + auto-save
# Usage:
#   zox          - save current dir + fzf picker
#   zox foo      - search store for "foo", or cd "foo" if not found
#
# Store: ~/.local/share/zox/store.txt
# Format: count|timestamp|path

STORE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zox"
STORE_FILE="$STORE_DIR/store.txt"

mkdir -p "$STORE_DIR"
touch "$STORE_FILE"

save() {
    local path now tmp_file found=0
    path="$(cd "$1" 2>/dev/null && pwd)" || return 1
    [[ "$path" == "$STORE_DIR" ]] && return 0
    now=$(date +%s)
    tmp_file=$(mktemp)

    while IFS= read -r line; do
        local existing
        existing=$(echo "$line" | cut -d'|' -f3-)
        if [[ "$existing" == "$path" ]]; then
            local count
            count=$(echo "$line" | cut -d'|' -f1)
            echo "$((count+1))|${now}|${path}" >> "$tmp_file"
            found=1
        else
            echo "$line" >> "$tmp_file"
        fi
    done < "$STORE_FILE"

    [[ "$found" -eq 0 ]] && echo "1|${now}|${path}" >> "$tmp_file"
    mv "$tmp_file" "$STORE_FILE"
}

# No args: save current dir + show fzf picker
if [[ -z "${1:-}" ]]; then
    save "$PWD"
    if [[ ! -s "$STORE_FILE" ]]; then
        echo "zox: store is empty." >&2
        return 1 2>/dev/null || exit 1
    fi
    selected=$(sort -t'|' -k1 -rn "$STORE_FILE" | cut -d'|' -f3- | fzf --prompt="zox> " --height=40% --reverse)
    if [[ -n "$selected" && -d "$selected" ]]; then
        save "$selected"
        echo "$selected"
    fi
    exit 0
fi

query="$*"

# 1. Search store for matches
if [[ -s "$STORE_FILE" ]]; then
    matches=$(grep -i "$query" "$STORE_FILE" | sort -t'|' -k1 -rn | cut -d'|' -f3-)

    if [[ -n "$matches" ]]; then
        count=$(echo "$matches" | wc -l)
        if [[ "$count" -eq 1 ]]; then
            save "$matches"
            echo "$matches"
            exit 0
        fi
        selected=$(echo "$matches" | fzf --prompt="zox> " --query="$query" --height=40% --reverse)
        if [[ -n "$selected" && -d "$selected" ]]; then
            save "$selected"
            echo "$selected"
        fi
        exit 0
    fi
fi

# 2. No store match — try cd directly (absolute, ~, or relative)
target="$query"
if [[ -d "$target" ]]; then
    save "$target"
    echo "$target"
    exit 0
fi

echo "zox: nothing found for '$query' (not in store and not a valid path)." >&2
return 1 2>/dev/null || exit 1
