#!/usr/bin/env bash
# Convert different formats to .jpg

find . -type f \( -name "*.webp" -o -name "*.jpeg" -o -name "*.png" \) -execdir sh -c 'convert "$0" "${0%.*}.jpg" && rm "$0"' {} \;