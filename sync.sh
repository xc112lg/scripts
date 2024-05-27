#!/bin/bash

# repo init -u https://github.com/xc112lg/android.git -b 14.0 --git-lfs
# /opt/crave/resync.sh

#!/bin/bash

# Define the manifests directory relative to the current directory
MANIFESTS_DIR=".repo/manifests"

# Function to extract contents from XML files
extract_contents() {
  local manifests_dir=$1

  echo "Scanning XML files in $manifests_dir..."

  # Find all XML files in the manifests directory
  find "$manifests_dir" -name "*.xml" | while read -r xml_file; do
    echo "Contents of $xml_file:"
    # Output the contents of the XML file
    cat "$xml_file"
    echo "--------------------------------------"
  done
}

# Extract contents from XML files in the manifests directory
extract_contents "$MANIFESTS_DIR"


