if [ -d .repo/local_manifests ]; then

    # Extract and echo the paths
    echo "$(xmlstarlet sel -t -m "//project" -v "@path" -n .repo/local_manifests/*.xml)"

    paths=$(xmlstarlet sel -t -m "//project" -v "@path" -n .repo/local_manifests/*.xml)

    echo "Paths to be deleted:"
    echo "$paths"

    # Remove each file except for paths starting with "kernel", "vendor", or "hardware"
  #  for path in $paths; do
    #    if [[ ! "$path" =~ ^(vendor|hardware) ]]; then
            rm -rf "$path"
            echo "Deleted: $path"
        else
            echo "Skipping deletion for path: $path"
        fi
    done
else
    echo "Skipping command. .repo/local_manifests directory does not exist."
fi
