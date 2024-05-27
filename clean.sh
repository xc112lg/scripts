xml_dir=".repo/manifests"
paths=$(xmlstarlet sel -t -v "//project/@path" "$xml_dir"/*.xml | sed 's/$/\//')

echo "Extracted paths:"
echo "$paths"

# Remove each file
for path in $paths; do
    cd "$path"
    # Count the number of slashes in the path
    num_slashes=$(tr -dc '/' <<< "$path" | awk '{ print length; }')

    # Define the target date
    target_date="2024-03-12"

    # Find the commit hash or tag before the target date
    commit_hash=$(git rev-list -1 --before="$target_date" HEAD)

    if [ -z "$commit_hash" ]; then
        echo "No commits found before $target_date"
        exit 1
    fi

    # Reset the branch to the commit
    git reset --hard "$commit_hash"

    echo "Reverted to commit before $target_date"

    # Move back to the original directory
    for ((i=0; i<num_slashes; i++)); do
        cd ..
    done

done
