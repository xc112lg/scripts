#!/bin/bash

# Change directory to frameworks/base
cd frameworks/base

# Get the latest commit hash
latest_commit_hash=$(git rev-parse HEAD)

# Check if the repository is in a detached HEAD state
if [ -z "$(git symbolic-ref HEAD 2>/dev/null)" ]; then
    echo "Repository is in a detached HEAD state. Creating a temporary branch..."
    
    # Create a temporary branch at the current commit
    git checkout -b temp_branch $latest_commit_hash
    
    # Point HEAD to the temporary branch
    git symbolic-ref HEAD refs/heads/temp_branch
fi

# Get the latest commit date
latest_commit_date=$(git log -1 --format="%ad" --date=iso)

# Convert commit date to timestamp
latest_commit_timestamp=$(date -d "$latest_commit_date" +%s)

# Timestamp for March 12, 2024
march_12_2024_timestamp=$(date -d "March 12, 2024" +%s)

# Check if the latest commit is after March 12, 2024
if [ "$latest_commit_timestamp" -gt "$march_12_2024_timestamp" ]; then
    echo "Latest commit is after March 12, 2024. Reverting..."
    
    # Get the commit hash before March 12, 2024
    target_commit_hash=$(git rev-list -1 --before="$march_12_2024_timestamp" HEAD)
    
    # Revert to the commit before March 12, 2024
    git checkout $target_commit_hash

    echo "Reverted successfully."
else
    echo "Latest commit is not after March 12, 2024. No action required."
fi

# Delete the temporary branch
git checkout master  # or the main branch you're working on
git branch -D temp_branch
