#!/bin/bash

# repo init -u https://github.com/xc112lg/android.git -b 14.0 --git-lfs
# /opt/crave/resync.sh

#!/bin/bash

# Define the manifest directory relative to the current directory
MANIFEST_DIR="$(pwd).repo/manifest"

# Function to extract project paths from XML files
extract_paths() {
  local manifest_dir=$1
  local paths=()

  echo "Scanning XML files in $manifest_dir..."

  # Find all XML files in the manifest directory
  find "$manifest_dir" -name "*.xml" | while read -r xml_file; do
    echo "Processing $xml_file..."
    # Extract paths from the XML file using xmllint
    local extracted_paths=$(xmllint --xpath '//project/@path' "$xml_file" 2>/dev/null | sed 's/path="\([^"]*\)"/\1\n/g')

    # Add the extracted paths to the array
    for path in $extracted_paths; do
      paths+=("$path")
    done
  done

  echo "Found paths: ${paths[*]}"
  echo "${paths[@]}"
}

# Function to list all .git directories in the given paths
list_git_directories() {
  local paths=("$@")

  echo "Listing .git directories in the specified paths..."

  for path in "${paths[@]}"; do
    local full_path="$(pwd)/$path"
    if [ -d "$full_path/.git" ]; then
      echo "Found .git directory at $full_path"
    else
      echo "No .git directory found at $full_path"
    fi
  done
}

# Extract paths from XML files in the manifest directory
project_paths=$(extract_paths "$MANIFEST_DIR")

# Convert the space-separated paths string to an array
IFS=' ' read -r -a paths_array <<< "$project_paths"

# List all .git directories in the extracted paths
list_git_directories "${paths_array[@]}"


