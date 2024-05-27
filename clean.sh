#!/bin/bash

xml_dir=".repo/manifests"
paths=$(xmlstarlet sel -t -v "//project/@path" "$xml_dir"/*.xml | sed 's/$/\//')


echo "Extracted paths:"
echo "$paths"


# Check if the paths variable is provided
if [ -z "$paths" ]; then
    echo "Error: No paths provided"
    exit 1
fi

# Iterate over each path
for repo_path in $paths; do
    # Check if the directory exists
    if [ ! -d "$repo_path" ]; then
        echo "Error: Directory '$repo_path' not found"
        continue
    fi

    # Define the target date
    target_date="2024-03-12"

    # Find the commit hash or tag before the target date
    commit_hash=$(git -C "$repo_path" rev-list -1 --before="$target_date" HEAD)

    if [ -z "$commit_hash" ]; then
        echo "No commits found before $target_date in '$repo_path'"
        continue
    fi

    # Reset the branch to the commit
    git -C "$repo_path" reset --hard "$commit_hash"

    echo "Reverted '$repo_path' to commit before $target_date"
done
