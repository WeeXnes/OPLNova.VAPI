#!/bin/bash

set -e

URL=""
ZIP_FILE="OPLM_ART_2024_09.zip"
TARGET_DIR="db"

echo "Downloading archive..."
curl -L "$URL" -o "$ZIP_FILE"

echo "Creating target directory..."
mkdir -p "$TARGET_DIR"

echo "Extracting archive into $TARGET_DIR..."
unzip -q "$ZIP_FILE" -d "$TARGET_DIR"

PS2_DIR="$TARGET_DIR/PS2"

if [ -d "$PS2_DIR" ]; then
    for game_dir in "$PS2_DIR"/*; do
        if [ -d "$game_dir" ]; then
            echo "Processing $game_dir"

            find "$game_dir" -type f -exec mv -t "$PS2_DIR" {} +

            rm -rf "$game_dir"
        fi
    done
else
    echo "PS2 directory not found, skipping flatten step."
fi

echo "Cleaning up..."
rm "$ZIP_FILE"

echo "Done! Files are in ./$TARGET_DIR"