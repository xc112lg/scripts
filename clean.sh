xml_dir=".repo/manifests"
paths=$(xmlstarlet sel -t -v "//project/@path" "$xml_dir"/*.xml)

# Define the target date
target_date="2024-03-12"

reverted_directories=()

for path in $paths; do
    # Append a slash to the end of the path
    path="${path}/"

    # Navigate to the directory
    cd "$path" || { echo "Directory $path not found"; continue; }

    # Find the latest commit hash
    latest_commit_hash=$(git rev-parse HEAD)

    # Find the commit hash before the target date
    commit_hash=$(git rev-list -n 1 --before="$target_date" HEAD)

    if [ -z "$commit_hash" ]; then
        echo "No commits found before $target_date in $path"
    else
        # Check if the latest commit is after the target date
        if [[ "$(git log -n 1 --format=%ci $latest_commit_hash)" > "$target_date" ]]; then
            # Reset the branch to the commit before the target date
            git reset --hard "$commit_hash"
            echo "Reverted to commit $commit_hash before $target_date in $path"
            reverted_directories+=("$path")
        else
            echo "No need to revert in $path, latest commit is before $target_date"
        fi
    fi

    # Move back to the original directory
    cd -
done

# List reverted directories
if [ ${#reverted_directories[@]} -eq 0 ]; then
    echo "No directories were reverted."
else
    echo "Reverted directories:"
    for dir in "${reverted_directories[@]}"; do
        echo "- $dir"
    done
fi
