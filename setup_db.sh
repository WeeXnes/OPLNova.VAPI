#!/bin/bash

set -e  # Exit on error

URL=""
ZIP_FILE="OPLM_ART_2024_09.zip"
TARGET_DIR="db"

echo "Downloading archive..."
curl -L "$URL" -o "$ZIP_FILE"

echo "Creating target directory..."
mkdir -p "$TARGET_DIR"

echo "Extracting archive into $TARGET_DIR..."
unzip -q "$ZIP_FILE" -d "$TARGET_DIR"

echo "Cleaning up..."
rm "$ZIP_FILE"

echo "Done! Files are in ./$TARGET_DIR"