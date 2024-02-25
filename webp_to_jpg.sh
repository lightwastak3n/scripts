#!/usr/bin/env bash
# Convert all .webp images in a folder to .jpg images

for f in *.webp; do convert "$f" "${f%.webp}.jpg"; rm "$f"; done