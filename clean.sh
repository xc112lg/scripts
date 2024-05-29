# Define the target date
target_date="2024-03-12"

# Set the path to frameworks/base
path="frameworks/base"

# Navigate to the frameworks/base directory
cd "$path" || { echo "Directory $path not found"; exit 1; }

# Find the commit hash before the target date
commit_hash=$(git rev-list -1 --before="$target_date" HEAD)

if [ -z "$commit_hash" ]; then
    echo "No commits found before $target_date in $path"
else
    # Get the commit date
    commit_date=$(git show -s --format=%ci "$commit_hash")

    # Check if the commit date is after the target date
    if [[ "$commit_date" > "$target_date" ]]; then
        # Reset the branch to the commit
        git reset --hard "$commit_hash"
        echo "Reverted to commit $commit_hash on $commit_date in $path"
    else
        echo "No need to revert in $path, latest commit before target date is on $commit_date"
    fi
fi
