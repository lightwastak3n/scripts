#!/bin/bash

# Switch to a base branch, pull, prune, and delete a feature branch.
# Omit either branch argument to choose it interactively.

set -euo pipefail

PROTECTED_BRANCHES="main master development develop staging release"
FORCE=false
DRY_RUN=false

usage() {
    echo "Usage: gmc [-f] [-n] [<base-branch> [<branch-to-delete>]]"
    echo
    echo "Omitted branches are selected from local and known origin branches."
    echo "Uses fzf when available in a terminal, otherwise a numbered menu."
    echo "  -f  Skip confirmation prompts (does not force unmerged deletion)"
    echo "  -n  Dry run (show what would happen)"
    echo "  -h  Show this help"
}

die() {
    echo "Error: $*" >&2
    exit 1
}

confirm() {
    local answer
    if $FORCE; then return 0; fi
    read -rp "$1 [y/N] " answer || { echo "Aborted." >&2; exit 1; }
    case "$answer" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) echo "Aborted." >&2; exit 1 ;;
    esac
}

is_protected() {
    local p
    for p in $PROTECTED_BRANCHES; do
        if [[ "$1" == "$p" || "$1" == "origin/$p" ]]; then
            return 0
        fi
    done
    return 1
}

has_local() {
    git show-ref --verify --quiet "refs/heads/$1"
}

has_remote() {
    git show-ref --verify --quiet "refs/remotes/origin/$1"
}

choose_branch() {
    local prompt="$1" selected reply i
    shift
    local choices=("$@")
    ((${#choices[@]})) || die "No eligible branches for: $prompt"

    if [[ -t 0 && -t 2 ]] && command -v fzf >/dev/null 2>&1; then
        selected=$(printf '%s\n' "${choices[@]}" | fzf \
            --no-multi --height=40% --layout=reverse --border \
            --prompt="$prompt > " --header="Enter to select, Esc to cancel") || {
            echo "Aborted." >&2
            return 1
        }
        # Native Windows fzf can write CRLF even when called from Git Bash.
        selected="${selected%$'\r'}"
        # Only accept a branch from the supplied list, even with custom fzf options.
        for reply in "${choices[@]}"; do
            if [[ "$selected" == "$reply" ]]; then
                printf '%s\n' "$selected"
                return 0
            fi
        done
        die "No branch selected."
    fi

    echo "$prompt:" >&2
    for ((i=0; i<${#choices[@]}; i++)); do
        printf '  %d) %s\n' "$((i + 1))" "${choices[i]}" >&2
    done
    while true; do
        read -rp "Choose a number, or q to cancel: " reply || {
            echo "Aborted." >&2
            return 1
        }
        [[ "$reply" != q && "$reply" != Q ]] || { echo "Aborted." >&2; return 1; }
        for ((i=0; i<${#choices[@]}; i++)); do
            if [[ "$reply" == "$((i + 1))" ]]; then
                printf '%s\n' "${choices[i]}"
                return 0
            fi
        done
        echo "Invalid selection. Enter one of the listed numbers." >&2
    done
}

while getopts "fnh" opt; do
    case "$opt" in
        f) FORCE=true ;;
        n) DRY_RUN=true ;;
        h) usage; exit 0 ;;
        *) usage >&2; exit 1 ;;
    esac
done
shift $((OPTIND - 1))
[[ $# -le 2 ]] || { usage >&2; exit 1; }

git rev-parse --git-dir >/dev/null 2>&1 || die "Run gmc inside a Git repository."
git remote get-url origin >/dev/null 2>&1 || die "This repository has no origin remote."

# Read existing refs without fetching, so selection and dry runs change nothing.
refs=$(git for-each-ref --format='%(refname) %(symref)' refs/heads/ refs/remotes/origin/)
mapfile -t branches < <(
    while read -r ref symref; do
        [[ -n "$ref" && -z "$symref" ]] || continue
        case "$ref" in
            refs/heads/*) printf '%s\n' "${ref#refs/heads/}" ;;
            refs/remotes/origin/*) printf '%s\n' "${ref#refs/remotes/origin/}" ;;
        esac
    done <<< "$refs" | LC_ALL=C sort -u
)

BASE_BRANCH="${1:-}"
if [[ -z "$BASE_BRANCH" ]]; then
    BASE_BRANCH=$(choose_branch "Select base branch to switch to and pull" "${branches[@]}")
fi
git check-ref-format --branch "$BASE_BRANCH" >/dev/null 2>&1 || die "Invalid base branch: $BASE_BRANCH"
if ! has_local "$BASE_BRANCH" && ! has_remote "$BASE_BRANCH"; then
    die "Unknown base branch '$BASE_BRANCH'. Run git fetch origin to refresh the branch list."
fi

DELETE_BRANCH="${2:-}"
if [[ -z "$DELETE_BRANCH" ]]; then
    candidates=()
    for branch in "${branches[@]}"; do
        if [[ "$branch" != "$BASE_BRANCH" ]] && ! is_protected "$branch"; then
            candidates+=("$branch")
        fi
    done
    DELETE_BRANCH=$(choose_branch "Select feature branch to delete locally and on origin" "${candidates[@]}")
fi
git check-ref-format --branch "$DELETE_BRANCH" >/dev/null 2>&1 || die "Invalid delete branch: $DELETE_BRANCH"
[[ "$BASE_BRANCH" != "$DELETE_BRANCH" ]] || die "Base branch and delete branch are the same."
if is_protected "$DELETE_BRANCH"; then
    die "'$DELETE_BRANCH' is a protected branch. Will not delete."
fi
if ! has_local "$DELETE_BRANCH" && ! has_remote "$DELETE_BRANCH"; then
    die "Unknown delete branch '$DELETE_BRANCH'. Run git fetch origin to refresh the branch list."
fi

echo "Base branch:    $BASE_BRANCH"
echo "Delete branch:  $DELETE_BRANCH"
echo

if $DRY_RUN; then
    echo "[dry-run] Would checkout $BASE_BRANCH"
    echo "[dry-run] Would git pull --ff-only origin $BASE_BRANCH"
    echo "[dry-run] Would git fetch origin --prune"
    echo "[dry-run] Would delete local branch $DELETE_BRANCH if present, using git branch -d"
    echo "[dry-run] Would delete remote branch origin/$DELETE_BRANCH if present"
    exit 0
fi

confirm "Switch to '$BASE_BRANCH' and pull latest?"

echo "Checking out $BASE_BRANCH..."
if has_local "$BASE_BRANCH"; then
    git checkout "$BASE_BRANCH"
else
    git checkout -b "$BASE_BRANCH" --track "origin/$BASE_BRANCH"
fi

echo "Pulling latest from origin/$BASE_BRANCH..."
git pull --ff-only origin "$BASE_BRANCH"

echo "Fetching and pruning origin branches..."
git fetch origin --prune

if has_local "$DELETE_BRANCH"; then
    echo "Deleting local branch '$DELETE_BRANCH'..."
    git branch -d -- "$DELETE_BRANCH" || die "Local deletion failed. Remote branch was not deleted."
else
    echo "Local branch '$DELETE_BRANCH' is already absent."
fi

if has_remote "$DELETE_BRANCH"; then
    confirm "Delete remote branch 'origin/$DELETE_BRANCH'?"
    echo "Deleting remote branch..."
    git push origin --delete "$DELETE_BRANCH" || die "Remote deletion failed."
else
    echo "Remote branch 'origin/$DELETE_BRANCH' is already absent."
fi

echo "Done. Branch '$DELETE_BRANCH' cleaned up."
