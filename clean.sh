# Check if the directory exists

    # Extract and echo the paths
    # paths=$(xmlstarlet sel -t -m "//project/@path" -v .repo/local_manifests/*.xml)
    # echo "Paths to be deleted:"
    # echo "$paths"

    # # Remove each file
    # for path in $paths; do
    #     rm -rf "$path"
    #     #sudo find "$path" -delete
    #     echo "Deleted: $path"
    # done



    # Extract and echo the paths
xml_dir=".repo/manifests"
paths=$(xmlstarlet sel -t -v "//project/@path" "$xml_dir"/*.xml | sed 's/$/\//')


echo "Extracted paths:"
echo "$paths"

# Remove each file
for path in $paths; do
    #!/bin/bash
cd "$path"
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

    #rm -rf "$path"
            num_slashes=$(tr -cd '/' <<< "$dir" | wc -c)
        # Return to the previous directory accordingly
        for (( i=0; i<num_slashes; i++ )); do
            cd ..
        done

        ls
done


