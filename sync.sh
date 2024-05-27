#!/bin/bash

# Function to find the latest commit before a specified date
find_latest_commit_before_date() {
  local repo_path=$1
  local date=$2

  cd "$repo_path" || { echo "Error: Could not change directory to $repo_path"; return 1; }

  # Find the latest commit before the specified date
  commit_hash=$(git rev-list -1 --before="$date" HEAD)

  # Check if a valid commit hash was found
  if [ -z "$commit_hash" ]; then
    echo "No commits found before $date in $repo_path"
  else
    echo "Latest commit before $date in $repo_path: $commit_hash"
  fi

  # Go back to the previous directory
  cd - > /dev/null || { echo "Error: Failed to change directory back to previous directory"; return 1; }

  # Return the commit hash
  echo "$commit_hash"
}

# Function to revert the repository to a specific commit
revert_repo_to_commit() {
  local repo_path=$1
  local commit_hash=$2

  cd "$repo_path" || { echo "Error: Could not change directory to $repo_path"; return 1; }

  # Reset the repository to the specified commit
  git reset --hard "$commit_hash" || { echo "Error: Failed to reset repository $repo_path"; return 1; }
  echo "Reverted $repo_path to commit: $commit_hash"

  # Go back to the previous directory
  cd - > /dev/null || { echo "Error: Failed to change directory back to previous directory"; return 1; }
}

# Function to extract paths from XML files
extract_paths_from_xml() {
  local xml_dir=$1

  echo "Scanning XML files in $xml_dir..."

  # Extract paths from XML files
  paths=$(xmlstarlet sel -t -v "//project/@path" "$xml_dir"/*.xml | sed 's/$/\//')
  echo "Paths extracted from XML files:"
  echo "$paths"
}

# Export the functions to use them recursively
export -f find_latest_commit_before_date
export -f revert_repo_to_commit
export -f extract_paths_from_xml

# Example usage: find the latest commit before March 12, 2024, revert repositories, and then revert back
repo_path="$(pwd)"
date="2024-03-12"

commit_hash=$(find_latest_commit_before_date "$repo_path" "$date")
if [ -n "$commit_hash" ]; then
  extract_paths_from_xml ".repo/manifests"

  # Save current directory
  current_dir="$(pwd)"

  # Revert repositories at each path
  for path in $paths; do
    if [ -d "$path" ]; then
      echo "Reverting repository at path: $path"
      cd "$path" || { echo "Error: Could not change directory to $path"; continue; }
      pwd
      revert_repo_to_commit "$path" "$commit_hash"
      # Calculate the number of levels to go back
      num_levels=$(tr -dc '/' <<< "$path" | wc -c)
      # Revert back
      for ((i=1; i<=num_levels; i++)); do
        cd ..
      done
    else
      echo "Warning: Directory $path does not exist."
    fi
  done

  # Revert back to the original directory
  cd "$current_dir" || { echo "Error: Could not change directory back to $current_dir"; exit 1; }
fi
