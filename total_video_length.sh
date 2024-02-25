#!/usr/bin/env bash
# Total length of all the videos in the current folder
# Useful to know if you want to stich them together for example 

total_duration=0
for file in *.mp4
do 
    duration=$(ffprobe -i "$file" -show_entries format=duration -v quiet -of csv="p=0")
    total_duration=$(echo "$total_duration + $duration" | bc)
done
echo "Total Duration: $total_duration seconds"