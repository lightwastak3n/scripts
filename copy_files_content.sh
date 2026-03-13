#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <folder-path>"
    exit 1
fi

FOLDER="$1"

if [ ! -d "$FOLDER" ]; then
    echo "Error: '$FOLDER' is not a directory."
    exit 1
fi

OUTPUT=""

while IFS= read -r -d '' file; do
    # Skip binary files to avoid null-byte warnings
    if grep -Iq . "$file"; then
	OUTPUT+="file path: $file"$'\n'
        OUTPUT+="$(cat "$file")"$'\n\n'
    else
        OUTPUT+="$file"$'\n[binary file skipped]'\n\n
    fi
done < <(find "$FOLDER" -type f -print0)

# Directly pipe to Windows clipboard
echo -e "$OUTPUT" | clip.exe

echo "Copied contents of all files to clipboard!"
