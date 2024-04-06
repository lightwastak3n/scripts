#!/usr/bin/env bash
# Extract subs from all .mkv files in the current folder

echo Which sub channel to extract?
read sub_no
for f in ./*.mkv; do ffmpeg -i "$f" -map 0:s:$sub_no "$f.srt"; done
for f in ./*.srt; do mv -- "$f" "${f%.mkv.srt}.srt"; done
