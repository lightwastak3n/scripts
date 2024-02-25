#!/usr/bin/env bash
# Rename files in current dir to random strings
# Used for testing

generate_random_name() {
  tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 10
}

for file in *; do
  if [ -f "$file" ]; then
    extension="${file##*.}"
    new_name=$(generate_random_name)."${extension}"
    mv "$file" "$new_name"
    echo "Renamed '$file' to '$new_name'"
  fi
done

echo "All files renamed."

