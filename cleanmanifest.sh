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