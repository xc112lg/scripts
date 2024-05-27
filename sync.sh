#!/bin/bash

repo init -u https://github.com/xc112lg/android.git -b 14.0 --git-lfs
/opt/crave/resync.sh
# cd frameworks/base
# git log --pretty=format:"%H %ad %s" --date=iso --after="2024-01-31" --before="2024-03-01"
# cd ../..

#!/bin/bash

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

# Start reverting repositories within frameworks/base
revert_repo_to_before_march_12 "frameworks/base"





