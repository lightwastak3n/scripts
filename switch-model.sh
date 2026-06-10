#!/usr/bin/env bash
# switch-model.sh — fzf dropdown to change the model for opencode agents
# Usage: bash switch-model.sh [agent-name]

AGENTS_DIR="$HOME/.config/opencode/agents"

MODELS=(
    "zai-coding-plan/glm-5.1"
    "opencode-go/glm-5.1"
    "opencode-go/kimi-k2.6"
    "opencode-go/deepseek-v4-pro"
    "opencode-go/deepseek-v4-flash"
    "opencode-go/mimo-v2.5"
    "opencode-go/mimo-v2.5-pro"
)

get_current_model() {
    sed -n 's/^model: //p' "$1"
}

set_model() {
    sed -i "s|^model: .*|model: ${2}|" "$1"
}

# ── Step 1: Select agent ─────────────────────────────────────────────────────

agent_entries=()
agent_files=()

for f in "$AGENTS_DIR"/*.md; do
    [ -f "$f" ] || continue
    name=$(basename "$f" .md)
    cur=$(get_current_model "$f")
    agent_entries+=("${name}  (${cur})")
    agent_files+=("$f")
done

if [ ${#agent_files[@]} -eq 0 ]; then
    echo "No agents found in $AGENTS_DIR"
    exit 1
fi

if [ -n "$1" ]; then
    for i in "${!agent_files[@]}"; do
        if [ "$(basename "${agent_files[$i]}" .md)" = "$1" ]; then
            selected_file="${agent_files[$i]}"
            selected_name="$1"
            break
        fi
    done
    if [ -z "$selected_file" ]; then
        echo "Agent '$1' not found."
        exit 1
    fi
else
    selected_entry=$(printf '%s\n' "${agent_entries[@]}" | fzf \
        --prompt="Agent > " \
        --height=~40% \
        --border=rounded \
        --header="Select an agent to change its model" \
        --preview-window=hidden)

    [ -z "$selected_entry" ] && exit 0

    selected_name=$(echo "$selected_entry" | sed 's/  (.*)//')
    for i in "${!agent_entries[@]}"; do
        if [ "${agent_entries[$i]}" = "$selected_entry" ]; then
            selected_file="${agent_files[$i]}"
            break
        fi
    done
fi

# ── Step 2: Select model ─────────────────────────────────────────────────────

current_model=$(get_current_model "$selected_file")

model_entries=()
for m in "${MODELS[@]}"; do
    if [ "$m" = "$current_model" ]; then
        model_entries+=("▸ ${m}  (current)")
    else
        model_entries+=("  ${m}")
    fi
done

chosen=$(printf '%s\n' "${model_entries[@]}" | fzf \
    --prompt="Model > " \
    --height=~50% \
    --border=rounded \
    --header="Change model for: ${selected_name}" \
    --preview-window=hidden)

[ -z "$chosen" ] && exit 0

new_model=$(echo "$chosen" | sed -E 's/^[▸ ]+//; s/  \(current\)//')

if [ "$new_model" = "$current_model" ]; then
    echo "Already using ${new_model} — no change."
    exit 0
fi

set_model "$selected_file" "$new_model"
echo "${selected_name} → ${new_model}"
