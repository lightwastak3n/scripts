#!/usr/bin/env bash
# Check the weather for a given location
# This is bad. There are probably multiple ways to break this

usage() {
    echo "Usage: weather.sh [city]"
    echo
    echo "Show weather for a city from wttr.in."
    echo "If no city is provided, you'll be prompted for one."
    exit 0
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && usage

if [[ $# -ge 1 ]]; then
    city="$*"
else
    read -p "City: " city
fi
curl "https://wttr.in/${city// /-}"