#!/bin/bash

# merge-cleanup.sh — Switch to base branch, pull, fetch --prune, and delete feature branch.
# Usage: merge-cleanup.sh <base-branch> <branch-to-delete>
# Example: merge-cleanup.sh development feat/my-feature

set -euo pipefail

PROTECTED_BRANCHES="main master development develop staging release"
FORCE=false
DRY_RUN=false

usage() {
    echo "Usage: $0 [-f] [-n] <base-branch> <branch-to-delete>"
    echo
    echo "  -f  Force delete (skip confirmation)"
    echo "  -n  Dry run (show what would happen)"
    echo "  -h  Show this help"
    exit 1
}

confirm() {
    local msg="$1"
    if $FORCE; then return 0; fi
    read -rp "$msg [y/N] " answer
    case "$answer" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) echo "Aborted."; exit 1 ;;
    esac
}

is_protected() {
    local branch="$1"
    for p in $PROTECTED_BRANCHES; do
        if [[ "$branch" == "$p" || "$branch" == "origin/$p" ]]; then
            return 0
        fi
    done
    return 1
}

while getopts "fnh" opt; do
    case "$opt" in
        f) FORCE=true ;;
        n) DRY_RUN=true ;;
        h) usage ;;
        *) usage ;;
    esac
done
shift $((OPTIND - 1))

[[ $# -lt 2 ]] && usage

BASE_BRANCH="$1"
DELETE_BRANCH="$2"

if [[ "$BASE_BRANCH" == "$DELETE_BRANCH" ]]; then
    echo "Error: base branch and delete branch are the same."
    exit 1
fi

if is_protected "$DELETE_BRANCH"; then
    echo "Error: '$DELETE_BRANCH' is a protected branch. Will not delete."
    exit 1
fi

echo "Base branch:    $BASE_BRANCH"
echo "Delete branch:  $DELETE_BRANCH"
echo

if $DRY_RUN; then
    echo "[dry-run] Would checkout $BASE_BRANCH"
    echo "[dry-run] Would git pull origin $BASE_BRANCH"
    echo "[dry-run] Would git fetch --prune"
    echo "[dry-run] Would delete local branch $DELETE_BRANCH"
    echo "[dry-run] Would delete remote branch origin/$DELETE_BRANCH"
    exit 0
fi

confirm "Switch to '$BASE_BRANCH' and pull latest?"

echo "→ Checking out $BASE_BRANCH..."
git checkout "$BASE_BRANCH"

echo "→ Pulling latest from origin/$BASE_BRANCH..."
git pull origin "$BASE_BRANCH"

echo "→ Fetching and pruning remote tracking branches..."
git fetch --prune

echo "→ Deleting local branch '$DELETE_BRANCH'..."
git branch -d "$DELETE_BRANCH" 2>/dev/null || echo "  (local branch not found or already deleted)"

confirm "Delete remote branch 'origin/$DELETE_BRANCH'?"
echo "→ Deleting remote branch..."
git push origin --delete "$DELETE_BRANCH" 2>/dev/null || echo "  (remote branch not found or already deleted)"

echo "Done. Branch '$DELETE_BRANCH' cleaned up."
