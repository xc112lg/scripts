#!/bin/bash

# Define the directories to revert
directories=("frameworks/base/" "device/lge/h872/" "device/lge/h870/" "device/lge/us997/" "device/lge/g6-common/" "kernel/lge/msm8996/" "device/lge/msm8996-common/" "packages/apps/Updater/" "vendor/lineage/" "vendor/lge/msm8996-common/")

# Function to find the commit hash before a specified date
find_commit_before_date() {
    local repo_path=$1
    local date=$2

    cd "$repo_path" || return 1

    # Find the commit hash before the specified date
    commit_hash=$(git rev-list -1 --before="$date" HEAD)

    # Return the commit hash
    echo "$commit_hash"
}

# Function to revert a directory to a specific commit
revert_directory_to_commit() {
    local dir=$1
    local commit_hash=$2
    
    # Check if the directory exists
    if [ -d "$dir" ]; then
        # Change to the directory
        cd "$dir" || return 1
        
        # Perform the git reset to the specified commit
        git reset --hard "$commit_hash" || return 1
    fi
}

# Define the date before which to revert (March 12, 2024)
revert_date="2024-03-12"

# Get the commit hash before the revert date
for dir in "${directories[@]}"; do
    commit_hash=$(find_commit_before_date "$dir" "$revert_date")

    # Check if a valid commit hash was found
    if [ -n "$commit_hash" ]; then
        echo "Reverting $dir to state before $revert_date..."
        revert_directory_to_commit "$dir" "$commit_hash"
        echo "Revert completed."
    else
        echo "Error: No commits found before $revert_date in $dir."
    fi
done
