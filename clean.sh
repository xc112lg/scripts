paths=$(xmlstarlet sel -t -v "//project/@path" .repo/manifests/*.xml)
echo "Paths to be deleted:"
echo "$paths" | sed 's/$/\/"/' | tr -d '\n' | sed 's/^/"/; s/ /" "/g; s/$/"/'
