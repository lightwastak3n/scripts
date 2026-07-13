#!/usr/bin/env bash
# Uploads given file to the https://free.keep.sh/ and shows link and qr code of the link
# Example: curl --upload-file path/to/file.txt https://free.keep.sh
# Or curl -F "file=@test.txt" https://file.io

usage() {
    echo "Usage: upload_file.sh <file>"
    echo
    echo "Upload a file to file.io and display a QR code for the link."
    exit 0
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && usage

if [[ $# -eq 1 ]]; then
    #link=$(curl --upload-file $1 https://free.keep.sh) # dead?
    link=$(curl -F "file=@$1" https://file.io | jq .link | tr -d '"')
    curl "https://qrcode.show/$link"
	echo "$link"
else
    echo "Please provide path to the file"
fi
