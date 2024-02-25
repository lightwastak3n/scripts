#!/usr/bin/env bash
#
# Sets up a python project based on options provided. Can be used with flags or with read input.
# Pyright is used to fix nvim pyright import error
# gitignore creates .gitignore based on githubs and appends pyright fix if needed
# venv creates venv and activates it

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
                echo "Too many args: $1"
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
