#!/bin/bash

repo init -u https://github.com/LineageOS/android.git -b lineage-21.0 --git-lfs
#!/bin/bash
# Copyright (c) 2016-2024 Crave.io Inc. All rights reserved

main() {
    # Run repo sync command and capture the output
    find .repo -name '*.lock' -delete
    repo sync -c -j100 --force-sync --no-clone-bundle --no-tags --prune 2>&1 | tee /tmp/output.txt

    if ! grep -qe "Failing repos:\|uncommitted changes are present" /tmp/output.txt ; then
         echo "All repositories synchronized successfully."
         exit 0
    else
        rm -f deleted_repositories.txt
    fi

    # Check if there are any failing repositories
    if grep -q "Failing repos:" /tmp/output.txt ; then
        echo "Deleting failing repositories..."
        # Extract failing repositories from the error message and echo the deletion path
        while IFS= read -r line; do
            # Extract repository name and path from the error message
            repo_info=$(echo "$line" | awk -F': ' '{print $NF}')
            repo_path=$(dirname "$repo_info")
            repo_name=$(basename "$repo_info")
            # Save the deletion path to a text file
            echo "Deleted repository: $repo_info" | tee -a deleted_repositories.txt
            # Delete the repository
            rm -rf "$repo_path/$repo_name"
        done <<< "$(cat /tmp/output.txt | awk '/Failing repos:/ {flag=1; next} /Try/ {flag=0} flag')"
    fi

    # Check if there are any failing repositories due to uncommitted changes
    if grep -q "uncommitted changes are present" /tmp/output.txt ; then
        echo "Deleting repositories with uncommitted changes..."

        # Extract failing repositories from the error message and echo the deletion path
        while IFS= read -r line; do
            # Extract repository name and path from the error message
            repo_info=$(echo "$line" | awk -F': ' '{print $2}')
            repo_path=$(dirname "$repo_info")
            repo_name=$(basename "$repo_info")
            # Save the deletion path to a text file
            echo "Deleted repository: $repo_info" | tee -a deleted_repositories.txt
            # Delete the repository
            rm -rf "$repo_path/$repo_name"
        done <<< "$(cat /tmp/output.txt | grep 'uncommitted changes are present')"
    fi

    # Re-sync all repositories after deletion
    echo "Re-syncing all repositories..."
    find .repo -name '*.lock' -delete
    repo sync -c -j100 --force-sync --no-clone-bundle --no-tags --prune
}

main $*

# Function to find the last commit in February and revert the repository
revert_repo_to_february() {
  local repo_path=$1
  cd "$repo_path" || { echo "Error: Could not change directory to $repo_path"; return 1; }

  echo "Searching for commits in February 2024 in $repo_path..."

  # Find the last commit made in February
  commit_hash=$(git rev-list -1 --before="2024-03-01 00:00" --after="2024-01-31 23:59" HEAD)

  # Check if a valid commit hash was found
  if [ -z "$commit_hash" ]; then
    echo "No commits found in February 2024 in $repo_path"
  else
    # Reset the repository to that commit
    git reset --hard "$commit_hash" || { echo "Error: Failed to reset repository $repo_path"; return 1; }
    echo "Reverted $repo_path to the last commit in February 2024: $commit_hash"
  fi

  # Go back to the previous directory
  cd - > /dev/null || { echo "Error: Failed to change directory back to previous directory"; return 1; }
}

# Export the function to use it recursively
export -f revert_repo_to_february

# Start reverting repositories within frameworks/base
revert_repo_to_february "frameworks/base"
