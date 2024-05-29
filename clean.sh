xml_dir=".repo/manifests"
paths=$(xmlstarlet sel -t -v "//project/@path" "$xml_dir"/*.xml | sed 's/$/\//')

# Define the target date
target_date="2024-03-12"

# Iterate through each path
for path in $paths; do
    cd "$path" || exit

    # Count the number of slashes in the path
    num_slashes=$(tr -dc '/' <<< "$path" | awk '{ print length; }')

    # Get the date of the latest commit
    latest_commit_date=$(git log -1 --format=%ci | cut -d' ' -f1)

    # Compare the latest commit date with the target date
    if [[ "$latest_commit_date" <= "$target_date" ]]; then
        echo "Latest commit in $path is on or before $target_date. Skipping reset."
    else
        # Find the commit hash or tag before the target date
        commit_hash=$(git rev-list -1 --before="$target_date" HEAD)

        if [ -z "$commit_hash" ]; then
            echo "No commits found before $target_date in $path."
            exit 1
        fi

        # Reset the branch to the commit
        git reset --hard "$commit_hash"
        echo "Reverted to commit before $target_date in $path."
    fi

    # Move back to the original directory
    for ((i=0; i<num_slashes; i++)); do
        cd ..
    done

done
