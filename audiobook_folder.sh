#!/usr/bin/env bash
# Just some audiobook projects that I used to make

usage() {
    echo "Usage: audiobook_folder.sh"
    echo
    echo "Create folder structure for an audiobook project:"
    echo "  Audio edited/"
    echo "  Audio original/"
    echo "  images/"
    echo "  texts/ (description.txt, edit_timings.txt, book.txt)"
    echo "  videos/"
    exit 0
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && usage

mkdir "Audio edited" "Audio original" "images"
mkdir "texts" "videos"
touch "texts/description.txt" "texts/edit_timings.txt"
touch "texts/book.txt"
