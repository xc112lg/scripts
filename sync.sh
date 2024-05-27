#!/bin/bash

# Function to find the last commit in February and revert the repository
revert_repo_to_february() {
  local repo_path=$1
  cd "$repo_path" || { echo "Error: Could not change directory to $repo_path"; return 1; }

  # Find the last commit made in February
  commit_hash=$(git rev-list -1 --before="2023-03-01 00:00" --after="2023-02-01 00:00" HEAD)

  # Check if a valid commit hash was found
  if [ -z "$commit_hash" ]; then
    echo "No commits found in February in $repo_path"
  else
    # Reset the repository to that commit
    git reset --hard "$commit_hash" || { echo "Error: Failed to reset repository $repo_path"; return 1; }
    echo "Reverted $repo_path to the last commit in February: $commit_hash"
  fi

  # Go back to the previous directory
  cd - > /dev/null || { echo "Error: Failed to change directory back to previous directory"; return 1; }
}

# Export the function to use it recursively
export -f revert_repo_to_february

# Function to revert repositories within frameworks/base directory
revert_frameworks_base_repositories() {
  local base_dir=$1
  cd "$base_dir" || { echo "Error: Could not change directory to $base_dir"; return 1; }

  # Find all .git directories within frameworks/base and its subdirectories
  local repo_dirs=$(find . -type d -name ".git" -printf "%h\n")

  # Iterate over each repository directory
  for repo_dir in $repo_dirs; do
    local parent_dir=$(dirname "$repo_dir")
    local repo_path=$(realpath "$parent_dir")  # Get the full path
    echo "Reverting repository in $repo_path"
    revert_repo_to_february "$repo_path" || return 1
  done
}

# Start reverting repositories within frameworks/base
revert_frameworks_base_repositories "path/to/frameworks/base"
