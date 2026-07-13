#!/usr/bin/env bash
# Create simple struture for a website. Copies everything to current folder.
# html - basic template, js - empty
# css - reset https://meyerweb.com/eric/tools/css/reset/ and normalize https://unpkg.com/normalize.css@8.0.1/normalize.css

usage() {
    echo "Usage: website_project.sh"
    echo
    echo "Create a basic website scaffold in the current directory."
    echo "Includes: index.html, main.js, CSS reset, and normalize.css."
    exit 0
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && usage

cp -r ~/scripts/data/web-template/. .