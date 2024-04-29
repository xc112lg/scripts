cd scripts
echo "$(xmlstarlet sel -t -m "//project" -v "@path" -n roomservice.xml)"
