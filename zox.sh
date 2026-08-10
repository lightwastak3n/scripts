#!/usr/bin/env bash
# zox: cd replacement with fuzzy search + auto-save
# Usage:
#   zox          - save current dir + fzf picker
#   zox foo      - search store for "foo", or cd "foo" if not found
#   zox --list   - list saved directories
#   zox --remove [query] - remove a saved directory
#   zox --prune  - remove saved directories that no longer exist
#   zox --help  - show this help
#
# Store: ~/.local/share/zox/store.txt
# Format: count|timestamp|path

STORE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zox"
STORE_FILE="$STORE_DIR/store.txt"

mkdir -p "$STORE_DIR"
touch "$STORE_FILE"

usage() {
    cat <<'EOF'
Usage: zox [OPTION] [QUERY]

Jump to frequently used directories with fzf, or save the current directory.

Options:
  -h, --help             Show this help
  --list                 List saved directories, newest first
  --prune                Remove saved directories that no longer exist
  --remove [QUERY]       Remove a saved directory; choose one with fzf when
                         QUERY matches multiple directories or is omitted

Examples:
  zox                    Pick a saved directory
  zox projects           Search saved directories for "projects"
  zox --remove projects Remove a saved directory matching "projects"
EOF
}

require_fzf() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "zox: fzf is required for this operation." >&2
        return 1
    fi
}

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

# Newer visits are more useful than old visits; visit count breaks ties.
ranked_paths() {
    sort -t'|' -k2,2nr -k1,1nr "$STORE_FILE" | cut -d'|' -f3-
}

remove_path() {
    local path="$1" tmp_file
    tmp_file=$(mktemp)
    while IFS= read -r line; do
        [[ "$(echo "$line" | cut -d'|' -f3-)" == "$path" ]] || echo "$line" >> "$tmp_file"
    done < "$STORE_FILE"
    mv "$tmp_file" "$STORE_FILE"
    echo "zox: removed $path"
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

if [[ "${1:-}" == "--list" ]]; then
    if [[ ! -s "$STORE_FILE" ]]; then
        echo "zox: store is empty."
        exit 0
    fi
    printf '%-8s %-12s %s\n' "VISITS" "LAST_USED" "PATH"
    sort -t'|' -k2,2nr -k1,1nr "$STORE_FILE" | while IFS='|' read -r count timestamp path; do
        printf '%-8s %-12s %s\n' "$count" "$timestamp" "$path"
    done
    exit 0
fi

if [[ "${1:-}" == "--prune" ]]; then
    if [[ ! -s "$STORE_FILE" ]]; then
        echo "zox: store is empty."
        exit 0
    fi

    tmp_file=$(mktemp)
    removed=0
    while IFS= read -r line; do
        path=$(printf '%s\n' "$line" | cut -d'|' -f3-)
        if [[ -d "$path" ]]; then
            printf '%s\n' "$line" >> "$tmp_file"
        else
            removed=$((removed + 1))
            printf 'zox: removing stale entry: %s\n' "$path"
        fi
    done < "$STORE_FILE"
    mv "$tmp_file" "$STORE_FILE"
    printf 'zox: pruned %d stale %s.\n' "$removed" "$([[ "$removed" -eq 1 ]] && printf 'directory' || printf 'directories')"
    exit 0
fi

if [[ "${1:-}" == "--remove" ]]; then
    shift
    query="$*"
    if [[ ! -s "$STORE_FILE" ]]; then
        echo "zox: store is empty." >&2
        exit 1
    fi

    if [[ -n "$query" ]]; then
        matches=$(grep -iF -- "$query" "$STORE_FILE" | sort -t'|' -k2,2nr -k1,1nr | cut -d'|' -f3-)
    else
        matches=$(ranked_paths)
    fi

    if [[ -z "$matches" ]]; then
        echo "zox: no saved directory matches '$query'." >&2
        exit 1
    fi

    count=$(printf '%s\n' "$matches" | wc -l)
    if [[ "$count" -eq 1 ]]; then
        selected="$matches"
    else
        require_fzf || exit 1
        selected=$(printf '%s\n' "$matches" | fzf --prompt="remove> " --query="$query" --height=40% --reverse)
    fi
    [[ -n "$selected" ]] && remove_path "$selected"
    exit 0
fi

# No args: save current dir + show fzf picker
if [[ -z "${1:-}" ]]; then
    require_fzf || exit 1
    save "$PWD"
    if [[ ! -s "$STORE_FILE" ]]; then
        echo "zox: store is empty." >&2
        return 1 2>/dev/null || exit 1
    fi
    selected=$(ranked_paths | fzf --prompt="zox> " --height=40% --reverse)
    if [[ -n "$selected" && -d "$selected" ]]; then
        save "$selected"
        echo "$selected"
    fi
    exit 0
fi

query="$*"

# 1. A valid path takes precedence over store matches.
target="$query"
if [[ -d "$target" ]]; then
    save "$target"
    echo "$target"
    exit 0
fi

# 2. Search store for matches
if [[ -s "$STORE_FILE" ]]; then
    matches=$(grep -iF -- "$query" "$STORE_FILE" | sort -t'|' -k2,2nr -k1,1nr | cut -d'|' -f3-)

    if [[ -n "$matches" ]]; then
        count=$(echo "$matches" | wc -l)
        if [[ "$count" -eq 1 ]]; then
            save "$matches"
            echo "$matches"
            exit 0
        fi
        require_fzf || exit 1
        selected=$(printf '%s\n' "$matches" | fzf --prompt="zox> " --query="$query" --height=40% --reverse)
        if [[ -n "$selected" && -d "$selected" ]]; then
            save "$selected"
            echo "$selected"
        fi
        exit 0
    fi
fi

echo "zox: nothing found for '$query' (not in store and not a valid path)." >&2
return 1 2>/dev/null || exit 1
