# Define the target date
target_date="2024-03-12"

# Set the path to frameworks/base
path="frameworks/base"

# Navigate to the frameworks/base directory
cd "$path" || { echo "Directory $path not found"; exit 1; }

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
    else
        echo "No need to revert in $path, latest commit is before $target_date"
    fi
fi
