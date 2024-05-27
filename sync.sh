#!/bin/bash

# repo init -u https://github.com/xc112lg/android.git -b 14.0 --git-lfs
# /opt/crave/resync.sh
#!/bin/bash

# Function to extract paths from XML files
extract_paths_from_xml() {
  local xml_dir=$1

  echo "Scanning XML files in $xml_dir..."

  # Extract paths from XML files
  paths=$(xmlstarlet sel -t -v "//project/@path" "$xml_dir"/*.xml | sed 's/$/\//')
  echo "Paths extracted from XML files:"
  echo "$paths"
}

# Example usage: extract paths from XML files in .repo/manifests directory
extract_paths_from_xml ".repo/manifests"
