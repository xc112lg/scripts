main() {

# Check if the directory exists
if [ -d .repo/local_manifests ]; then

# Extract and echo the paths
paths=$(xmlstarlet sel -t -m "//project[starts-with(@path, 'device') or starts-with(@path, 'prebuilt')]" -v "@path" -n .repo/local_manifests/*.xml)

echo "Paths to be deleted:"
echo "$paths"

# Remove each file
for path in $paths; do
    rm -rf "$path"
    echo "Deleted: $path"
done
else
    echo "Skipping command. .repo/local_manifests directory does not exist."
fi


    # Run repo sync command and capture the output
    repo sync -c -j64 --force-sync --no-clone-bundle --no-tags 2>&1 | tee /tmp/output.txt

    # Check if there are any failing repositories
    if grep -q -e "Failing repos:" -e "error:" /tmp/output.txt ; then
        echo "Deleting failing repositories..."
        # Extract failing repositories from the error message and echo the deletion path
        while IFS= read -r line; do
            # Extract repository name and path from the error message
            repo_info=$(echo "$line" | awk -F': ' '{print $NF}')
            repo_path=$(dirname "$repo_info")
            repo_name=$(basename "$repo_info")
            # Echo the deletion path
            echo "Deleted repository: $repo_info"
            # Save the deletion path to a text file
            echo "Deleted repository: $repo_info" > deleted_repositories.txt
            # Delete the repository
            rm -rf "$repo_path/$repo_name"
        done <<< "$(cat /tmp/output.txt | awk '/Failing repos:/ {flag=1; next} /Try/ {flag=0} flag')"
        # Re-sync all repositories after deletion
        echo "Re-syncing all repositories..."
        repo sync -c -j64 --force-sync --no-clone-bundle --no-tags
    else
        echo "All repositories synchronized successfully."
    fi
}

main $*
