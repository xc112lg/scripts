#!/bin/bash

repo init -u https://github.com/LineageOS/android.git -b lineage-21.0 --git-lfs
/opt/crave/resync.sh

# Function to find the commits in February and echo their hashes
echo_commits_in_february() {
  local repo_path=$1
  cd "$repo_path" || { echo "Error: Could not change directory to $repo_path"; return 1; }

  echo "Commits in February 2024 in $repo_path:"
  
  # Find commits made in February
  git log --pretty=format:"%H %ad %s" --date=iso --after="2024-01-31" --before="2024-03-01" --reverse

  # Go back to the previous directory
  cd - > /dev/null || { echo "Error: Failed to change directory back to previous directory"; return 1; }
}

# Export the function to use it recursively
export -f echo_commits_in_february

# Start echoing commits within frameworks/base
echo_commits_in_february "frameworks/base"
