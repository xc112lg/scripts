#!/bin/bash



MANIFEST="${1}"  
BRANCH="${2}" 
DEVICE="${3}"

echo "$MANIFEST -b $BRANCH" 
echo "$BRANCH"
echo "$DEVICE"





#!/bin/bash

# Read the file and split by "====="
commands=$(awk 'BEGIN {RS="====="} {print $0}' commands.txt)

# Loop through each command block
while IFS= read -r command_block; do
    if [[ -n "$command_block" ]]; then
        # Extract local_manifest, branch, and device from the command block
        local_manifest=$(echo "$command_block" | grep -o 'local_manifest:[^ ]*' | cut -d':' -f2)
        branch=$(echo "$command_block" | grep -o 'branch:[^ ]*' | cut -d':' -f2)
        device=$(echo "$command_block" | grep -o 'device:[^ ]*' | cut -d':' -f2)



        # Echo the data for verification
        echo "Local Manifest: $local_manifest"
        echo "Branch: $branch"
        echo "Device: $device"
        # Execute the command
        #crave run --no-patch -- "sudo find scripts -delete;git clone https://github.com/xc112lg/scripts.git -b cd10-qpr3;chmod u+x scripts/sync2.sh;bash scripts/sync2.sh $local_manifest $branch $device"
    fi
done <<< "$commands"
