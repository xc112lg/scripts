#!/bin/bash

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

# Function to extract paths from XML files and append a forward slash
extract_paths_from_xml() {
    local xml_dir=$1

    echo "Scanning XML files in $xml_dir..."

    # Extract paths from XML files and append a forward slash
    paths=$(xmlstarlet sel -t -v "//project/@path" "$xml_dir"/*.xml | sed 's/$/\//')
    echo "Paths extracted from XML files:"
    echo "$paths"
}

# Define the date before which to revert (March 12, 2024)
revert_date="2024-03-12"

# Example usage: extract paths from XML files in .repo/manifests directory
extract_paths_from_xml ".repo/manifests"

# Populate the directories array with the extracted paths
directories=()
for path in $paths; do
    directories+=("\"$path\"")
done

# Get the commit hash before the revert date for each directory
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
