#!/bin/bash

# repo init -u https://github.com/xc112lg/android.git -b 14.0 --git-lfs
# /opt/crave/resync.sh

#!/bin/bash

# Define the manifest directory
MANIFEST_DIR=".repo/manifests"

# Function to extract project paths from XML files
extract_paths() {
  local manifest_dir=$1
  local paths=()

  echo "Scanning XML files in $manifest_dir..."

  # Find all XML files in the manifest directory
  find "$manifest_dir" -name "*.xml" | while read -r xml_file; do
    echo "Processing $xml_file..."
    # Extract paths from the XML file using grep
    local extracted_paths=$(grep -oP 'path="\K[^"]+' "$xml_file")

    # Add the extracted paths to the array
    for path in $extracted_paths; do
      paths+=("$path")
    done
  done

  echo "Found paths: ${paths[*]}"
  echo "${paths[@]}"
}

# Function to scan directories based on extracted paths
scan_directories() {
  local manifest_dir=$1
  local paths=("$@")

  echo "Scanning directories based on extracted paths..."

  for path in "${paths[@]}"; do
    local full_path="$manifest_dir/$path"
    echo "Scanning directory: $full_path"
    # Here you can perform any action you want with the directory path
    # For now, let's just echo the path
    echo "Directory contents:"
    ls -l "$full_path"
    echo "--------------------------------------"
  done
}

# Extract paths from XML files in the manifest directory
project_paths=$(extract_paths "$MANIFEST_DIR")

# Convert the space-separated paths string to an array
IFS=$'\n' read -r -d '' -a paths_array <<< "
