# List of directories to check
directories=("frameworks/base/" "device/lge/h872/" "device/lge/h870/" "device/lge/us997/" "device/lge/g6-common/" "kernel/lge/msm8996/" "device/lge/msm8996-common/" "packages/apps/Updater/" "vendor/lineage/" "vendor/lge/msm8996-common/")

# Get the current directory
current_dir=$(pwd)

# Loop through each directory
for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        # Change to the directory
        cd "$dir"
        # Perform the git reset
        git reset --hard
        # Count the number of slashes in the directory path
        num_slashes=$(tr -cd '/' <<< "$dir" | wc -c)
        # Return to the previous directory accordingly
        for (( i=0; i<num_slashes; i++ )); do
            cd ..
        done
    fi
done
