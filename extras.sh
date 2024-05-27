
#!/bin/bash

# Scan all folders under external/chromium-webview/prebuilt/*
echo "Scanning folders in external/chromium-webview/prebuilt/*"
find external/chromium-webview/prebuilt/* -type d

# Install Git LFS
echo "Installing Git LFS"
git lfs install

# Find the Git directory
echo "Finding the Git directory"
GIT_DIR=$(git rev-parse --git-dir)
echo "Git directory is: $GIT_DIR"

# Get the first subfolder name under external/chromium-webview/prebuilt/
TARGET_FOLDER=$(find external/chromium-webview/prebuilt/* -type d | head -n 1)
echo "Target folder is: $TARGET_FOLDER"

# Add the target folder to the list of safe directories
echo "Adding $TARGET_FOLDER to the list of safe directories"
git config --global --add safe.directory "$TARGET_FOLDER"

# Pull Git LFS objects
echo "Pulling Git LFS objects"
git lfs pull
