echo "$(xmlstarlet sel -t -m "//project" -v "@path" -n .repo/local_manifests/*.xml)"

echo "$(xmlstarlet sel -t -m "//project[starts-with(@path, 'device')]" -v "@path" -n .repo/local_manifests/*.xml)"


