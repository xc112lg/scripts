paths=$(xmlstarlet sel -t -v "//project/@path" .repo/manifests/*.xml)
echo "Paths to be deleted:"
echo "$paths" | sed 's/$/\/"/' | sed 's/^/"/; s/ /" "/g'
