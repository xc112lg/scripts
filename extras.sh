#!/bin/bash

# Scan all folders under external/chromium-webview/prebuilt/*
echo "Scanning folders in external/chromium-webview/prebuilt/*"
folders=$(find external/chromium-webview/prebuilt/* -type d)

# Install Git LFS
echo "Installing Git LFS"
git lfs install

# Loop through each folder
for folder in $folders; do
  echo "Processing folder: $folder"
  
  # Check if the folder is a Git repository
  if [ -d "$folder/.git" ]; then
    echo "$folder is a Git repository"
    
    # Navigate to the Git repository
    cd "$folder"
    
    # Get the Git directory
    GIT_DIR=$(git rev-parse --git-dir)
    echo "Git directory is: $GIT_DIR"
    
    # Add the folder to the list of safe directories
    echo "Adding $folder to the list of safe directories"
    git config --global --add safe.directory "$folder"
    
    # Pull Git LFS objects
    echo "Pulling Git LFS objects"
    git lfs pull
    
    # Navigate back to the initial directory
    cd - > /dev/null
  else
    echo "$folder is not a Git repository"
  fi
done
