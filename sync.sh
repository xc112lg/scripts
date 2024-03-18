#!/bin/bash
# Set default values for device and command
DEVICE="${1:-all}"  # If no value is provided, default to "all"
COMMAND="${2:-build}"  # If no value is provided, default to "build"
DELZIP="${3}"
echo $PWD
echo $PWD
repo init -u https://github.com/crdroidandroid/android.git -b 14.0 --git-lfs

# Define the log file path
log_file="deleted_repos.log"

# Sync repositories and capture the output
output=$(repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags 2>&1)

# Check if there are any failing repositories
if echo "$output" | grep -q "error:"; then
    echo "Deleting failing repositories..."
    # Extract failing repositories from the error message and log the deletion
    while IFS= read -r line; do
        repo_name=$(echo "$line" | awk '{print $NF}')
        echo "Deleted repository: $repo_name" >> "$log_file"
        rm -rf "$repo_name"
    done <<< "$(echo "$output" | grep "error:")"
    
    # Re-sync all repositories after deletion
    echo "Re-syncing all repositories..."
    repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
else
    echo "All repositories synchronized successfully."
fi




repo init -u https://github.com/DerpFest-AOSP/manifest.git -b 13
while true; do
    errors=$(repo sync -j64 --fail-fast --force-sync --no-clone-bundle --no-tags 2>&1 | awk '/^error: Exited sync due to errors/,/^error: Cannot fetch .* in/ {print $0}' | tee /dev/tty)
    if [ -z "$errors" ]; then
        echo "No errors found. Exiting loop."
        break
    fi
    echo "$errors" | awk '/^error: Exited sync due to errors/,/^error: Cannot fetch .* in/ {print "rm -rf " $NF}' | bash
done

