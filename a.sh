

echo "$(xmlstarlet sel -t -m "//project[starts-with(@path, 'device')]" -v "@path" -n .repo/local_manifests/*.xml)"


# Extract and echo the paths
paths=$(xmlstarlet sel -t -m "//project[starts-with(@path, 'device')]" -v "@path" -n .repo/local_manifests/*.xml)
echo "Paths to be deleted:"
echo "$paths"

# Remove each file
for path in $paths; do
    rm -rf "$path"
    echo "Deleted: $path"
done



