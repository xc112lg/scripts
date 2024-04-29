

echo "$(xmlstarlet sel -t -m "//project[starts-with(@path, 'device')]" -v "@path" -n .repo/local_manifests/*.xml)"


# Check if the directory exists
if [ -d .repo/local_manifests ]; then
    # Extract and echo the paths
    paths=$(xmlstarlet sel -t -m "//project/@path" -v .repo/local_manifest/*.xml)
    echo "Paths to be deleted:"
    echo "$paths"

    # Remove each file except those containing "kernel" or "vendor"
    for path in $paths; do
        if [[ ! "$path" =~ "kernel" && ! "$path" =~ "vendor" ]]; then
            rm -rf "$path"
            echo "Deleted: $path"
        fi
    done
else
    echo "Skipping command. .repo/local_manifests directory does not exist."
fi



