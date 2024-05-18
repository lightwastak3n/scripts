#!/usr/bin/env bash
# Create icons of multiple sizes from a given image
# Delete the ones you don't need or just comment it out here

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 input image path"
    exit 1
fi

input_img=$1
sizes=("256x256" "128x128" "64x64" "48x48" "32x32" "16x16")
for size in "${sizes[@]}"
do
    img_name=$(basename "$input_img" | cut -d. -f1)
    size_name=$(echo $size | cut -dx -f1)
    output_img="${img_name}${size_name}.png"
    convert "$input_img" -resize "$size" "$output_img"
    echo "Done: $size"
done
echo "Created all images."
