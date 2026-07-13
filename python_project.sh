#!/usr/bin/env bash
#
# Sets up a python project based on options provided. Can be used with flags or with read input.
# Pyright is used to fix nvim pyright import error
# gitignore creates .gitignore based on githubs and appends pyright fix if needed
# venv creates venv and activates it

usage() {
    echo "Usage: python_project.sh [options]"
    echo
    echo "Set up a Python project with optional scaffolding."
    echo "Run without flags for interactive prompts."
    echo
    echo "Options:"
    echo "  -p, --pyright     Create pyrightconfig.json"
    echo "  -v, --venv        Create .venv virtual environment"
    echo "  -g, --gitignore   Create .gitignore from GitHub template"
    exit 0
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && usage

pyright=false
venv=false
gitignore=false

# Check if its called directly without args 
if [ "$#" -eq 0 ]; then
    read -p "Create pyrightconfig.json? (y/n): " ans
    [[ "$ans" =~ [yY] ]] && pyright=true

    read -p "Create venv? (y/n): " ans
    [[ "$ans" =~ [yY] ]] && venv=true

    read -p "Create .gitignore? (y/n): " ans
    [[ "$ans" =~ [yY] ]] && gitignore=true
else
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -p|--pyright)
                pyright=true
                ;;
            -v|--venv)
                venv=true
                ;;
            -g|--gitignore)
                gitignore=true
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
        shift
    done
fi

# Do stuff
if [ "$pyright" = true ]; then
    echo "Creating pyrightconfig.json"
    echo '{"executionEnvironments": [{"root": "src"}]}' > pyrightconfig.json
fi

if [ "$venv" = true ]; then
    echo "Creating venv"
    python -m venv .venv
fi

if [ "$gitignore" = true ]; then
    echo "Creating gitignore"
    curl https://raw.githubusercontent.com/github/gitignore/main/Python.gitignore > .gitignore
    if [ "$pyright" = true ]; then
        echo "pyrightconfig.json" >> .gitignore
    fi
fi

notify-send "Finished creating python project."
