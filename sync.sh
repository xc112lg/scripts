#!/bin/bash

repo init -u https://github.com/xc112lg/android.git -b 14.0 --git-lfs
/opt/crave/resync.sh




ROOT_DIR="frameworks/base"

# Function to find the latest commit before March 12, 2024, and revert the repository to that commit
revert_repo_to_before_march_12() {
  local repo_path=$1
  cd "$repo_path" || { echo "Error: Could not change directory to $repo_path"; return 1; }

  echo "Searching for the latest commit before March 12, 2024, in $repo_path..."

  # Find the latest commit made before March 12, 2024
  commit_hash=$(git rev-list -1 --before="2024-03-12 00:00" HEAD)

  # Check if a valid commit hash was found
  if [ -z "$commit_hash" ]; then
    echo "No commits found before March 12, 2024, in $repo_path"
  else
    # Reset the repository to that commit
    git reset --hard "$commit_hash" || { echo "Error: Failed to reset repository $repo_path"; return 1; }
    echo "Reverted $repo_path to the latest commit before March 12, 2024: $commit_hash"
  fi

  # Go back to the previous directory
  cd - > /dev/null || { echo "Error: Failed to change directory back to previous directory"; return 1; }
}

# Export the function to use it recursively
export -f revert_repo_to_before_march_12

# Function to find all git repositories and list them
list_all_repos() {
  local base_dir=$1
  cd "$base_dir" || { echo "Error: Could not change directory to $base_dir"; return 1; }

  # Find all .git directories (excluding .repo folder) and list them, limiting to the fifth subdirectory
  find . -maxdepth 6 -type d -name ".git" -not -path "*/.repo/*" | while read -r git_dir; do
    local repo_path=$(dirname "$git_dir")
    echo "Found repository at $repo_path"
  done

  # Go back to the previous directory
  cd - > /dev/null || { echo "Error: Failed to change directory back to previous directory"; return 1; }
}

# Function to revert all git repositories sequentially
revert_all_repos() {
  local base_dir=$1
  cd "$base_dir" || { echo "Error: Could not change directory to $base_dir"; return 1; }

  # Find all .git directories (excluding .repo folder) and revert them sequentially, limiting to the fifth subdirectory
  find . -maxdepth 6 -type d -name ".git" -not -path "*/.repo/*" | while read -r git_dir; do
    local repo_path=$(dirname "$git_dir")
    echo "Reverting repository at $repo_path"
    revert_repo_to_before_march_12 "$repo_path"
  done

  # Go back to the previous directory
  cd - > /dev/null || { echo "Error: Failed to change directory back to previous directory"; return 1; }
}

# List all repositories with .git directories
echo "Listing all repositories with .git directories (excluding .repo folder):"
list_all_repos "$ROOT_DIR"

# Revert all repositories sequentially
echo "Reverting all repositories:"
revert_all_repos "$ROOT_DIR"



