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

# Function to recursively find .repo directories and revert repositories
find_and_revert_repositories() {
  local start_dir=$1
  local repo_dirs=$(find "$start_dir" -type d -name ".repo")
  for repo_dir in $repo_dirs; do
    local repo_parent=$(dirname "$repo_dir")
    echo "Reverting repositories in $repo_parent"
    cd "$repo_parent" || { echo "Error: Could not change directory to $repo_parent"; return 1; }
    repo forall -c 'bash -c "revert_repo_to_february \"$(pwd)\""' || { echo "Error: 'repo forall' command failed"; return 1; }
  done
}

# Start searching from the current directory
find_and_revert_repositories "$(pwd)"
