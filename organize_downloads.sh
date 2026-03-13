#!/usr/bin/env bash
# Moves files in ~/Downloads to their respective folders based on their type 

downloads_folder="$HOME/Downloads"

# Create folders if they don't exist
image_folder="$downloads_folder/Images"
audio_folder="$downloads_folder/Audio"
video_folder="$downloads_folder/Videos"
doc_folder="$downloads_folder/Documents"
other_folder="$downloads_folder/Others"

mkdir -p "$image_folder" "$audio_folder" "$video_folder" "$doc_folder" "$other_folder"

echo "Organizing files in $downloads_folder ..."

# Move files to their folders
find "$downloads_folder" -maxdepth 1 -type f -exec bash -c '
    file="$1"
    base=$(basename "$file")
    case "$file" in
        *.png|*.jpg|*.jpeg|*.tif|*.tiff|*.bpm|*.gif|*.eps|*.raw)
            echo "Moving image: $base ¿ $2/Images/"
            mv "$file" "$2/Images/"
            ;;
        *.mp3|*.m4a|*.flac|*.aac|*.ogg|*.wav)
            echo "Moving audio: $base ¿ $2/Audio/"
            mv "$file" "$2/Audio/"
            ;;
        *.mp4|*.avi|*.mkv|*.flv)
            echo "Moving video: $base ¿ $2/Videos/"
            mv "$file" "$2/Videos/"
            ;;
        *.pdf|*.doc|*.docx|*.epub|*.mobi|*.cbz|*.cbr|*.xls|*.xlsx|*.csv|*.tsv)
            echo "Moving document: $base ¿ $2/Documents/"
            mv "$file" "$2/Documents/"
            ;;
        *)
            echo "Moving other file: $base ¿ $2/Others/"
            mv "$file" "$2/Others/"
            ;;
    esac
' _ {} "$downloads_folder" \;

echo "Done organizing files."
