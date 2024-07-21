#!/bin/bash
wget -O commands.txt https://raw.githubusercontent.com/xc112lg/scripts/cd10-qpr3/commands.txt
# Read the file line by line
while IFS= read -r line || [ -n "$line" ]; do
    # Skip empty lines and lines that start with "====="
    if [[ -n "$line" && "$line" != "====="* ]]; then
        echo "Scanned Line: $line"

        # Split line into fields based on comma
        IFS=',' read -r -a fields <<< "$line"

        # Ensure we have exactly three fields
        if [[ ${#fields[@]} -eq 5 ]]; then
            username="${fields[0]}"
            manifest="${fields[1]}"
            branch="${fields[2]}"
 	    device="${fields[3]}"
	    buildtype="${fields[4]}"	



            # Optionally, execute a command with the extracted data
            crave run --no-patch -- "sudo find scripts -delete;git clone https://github.com/xc112lg/scripts.git -b cd10-qpr3;chmod u+x scripts/sync2.sh;bash scripts/sync2.sh $username $manifest $branch $device $buildtype"
        else
            echo "Error: Failed to extract necessary fields from command block."
        fi
    fi
done < commands.txt
