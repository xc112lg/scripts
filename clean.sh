#!/bin/bash

# Change directory to frameworks/base
cd frameworks/base
git log -1
# Get the latest commit date
latest_commit_date=$(git log -1 --format="%ad" --date=iso)

# Convert commit date to timestamp
latest_commit_timestamp=$(date -d "$latest_commit_date" +%s)

# Timestamp for March 12, 2024
march_12_2024_timestamp=$(date -d "March 12, 2024" +%s)

# Check if the latest commit is after March 12, 2024
if [ "$latest_commit_timestamp" -gt "$march_12_2024_timestamp" ]; then
    echo "Latest commit is after March 12, 2024. Reverting..."
    
    # Revert to the commit before March 12, 2024
    git checkout $(git rev-list -1 --before="$march_12_2024_timestamp" HEAD)

    echo "Reverted successfully."
else
    echo "Latest commit is not after March 12, 2024. No action required."
fi
