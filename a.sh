cd scripts
echo "$(xmlstarlet sel -t -m "//project" -v "@path" -n roomservice.xml)"
echo "$(xmlstarlet sel -t -m "//project" -v "@path" -n X01BD.xml)"
echo "$(xmlstarlet sel -t -m "//project" -v "@path" -n x.xml)"
echo "$(xmlstarlet sel -t -m "//project" -v "@path" -n lge_sdm845.xml)"
echo "$(xmlstarlet sel -t -m "//project" -v "@path" -n eureka_deps.xml)"

