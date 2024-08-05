#!/bin/bash

USERNAME="${1}"
MANIFEST="${2}"  
BRANCH="${3}" 
DEVICE="${4}"
BUILD_TYPE="${5}"

# Ensure mpstat is installed
if ! command -v mpstat &> /dev/null; then
  echo "mpstat could not be found, installing sysstat..."
  sudo apt update && sudo apt install -y sysstat
fi

# Function to check CPU usage
check_cpu_usage() {
  local usage=$(mpstat 1 1 | awk '/Average/ { print 100 - $NF }')
  echo $usage
}

# Variable to track if CPU usage stays below 60%
cpu_below_threshold=true

# Start a background process to monitor CPU usage for 1 hour
(
  for i in {1..60}; do
    sleep 60
    cpu_usage=$(check_cpu_usage)
    echo "Minute $i: CPU usage is $cpu_usage%"

    if (( $(echo "$cpu_usage > 60" | bc -l) )); then
      echo "CPU usage exceeded 60%: $cpu_usage%"
      cpu_below_threshold=false
      break
    fi
  done

  if $cpu_below_threshold; then
    echo "CPU usage stayed below 60% for 1 hour. Exiting."
    exit 0
  fi
) &

monitor_pid=$!

# Main command
echo "Running main command..."





repo init -u https://github.com/RisingTechOSS/android -b fourteen --git-lfs




#git clean -fdX
#rm -rf frameworks/base/
rm -rf .repo/local_manifests  mkdir vendor/lineage-priv
rm -rf device/infinix/X6833B
rm -rf vendor/infinix/X6833B
#rm -rf device/lge/
#rm -rf kernel/lge/msm8996
mkdir -p .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests
git clone https://github.com/muhammadrafiasyddiq/android_kernel_infinix_X6833B kernel/infinix/X6833B

wget https://pixeldrain.com/u/e2wpLqPZ && mkdir device/infinix/ && mkdir device/infinix/X6833B && unzip e2wpLqPZ -d device/infinix/X6833B/

git clone  https://gitlab.com/muhammadrafiasyddiq/vendor vendor/infinix/X6833B/

rm -rf hardware/mediatek

git clone https://gitlab.com/muhammadrafiasyddiq/mediatek hardware/mediatek

git clone https://github.com/LineageOS/android_device_mediatek_sepolicy_vndr device/mediatek/sepolicy_vndr

git clone https://gitlab.com/muhammadrafiasyddiq/hardware hardware/device/infinix/X6833B/power/


 #!/bin/bash
# Copyright (c) 2016-2024 Crave.io Inc. All rights reserved

repo --version
cd .repo/repo
git pull -r
cd -
repo --version


main() {
    # Run repo sync command and capture the output
    find .repo -name '*.lock' -delete
    repo sync -c -j64 --force-sync --no-clone-bundle --no-tags --prune 2>&1 | tee /tmp/output.txt

 if ! grep -qe "Failing repos:\|uncommitted changes are present" /tmp/output.txt ; then
         echo "All repositories synchronized successfully."
         exit 0
    else
        rm -f deleted_repositories.txt
    fi

    # Check if there are any failing repositories
    if grep -q "Failing repos:" /tmp/output.txt ; then
        echo "Deleting failing repositories..."
        # Extract failing repositories from the error message and echo the deletion path
        while IFS= read -r line; do
            # Extract repository name and path from the error message
            repo_info=$(echo "$line" | awk -F': ' '{print $NF}')
            repo_path=$(dirname "$repo_info")
            repo_name=$(basename "$repo_info")
            # Save the deletion path to a text file
            echo "Deleted repository: $repo_info" | tee -a deleted_repositories.txt
            # Delete the repository
            rm -rf "$repo_path/$repo_name"
            rm -rf ".repo/project/$repo_path/$repo_name"/*.git
        done <<< "$(cat /tmp/output.txt | awk '/Failing repos:/ {flag=1; next} /Try/ {flag=0} flag')"
    fi

    # Check if there are any failing repositories due to uncommitted changes
    if grep -q "uncommitted changes are present" /tmp/output.txt ; then
        echo "Deleting repositories with uncommitted changes..."

        # Extract failing repositories from the error message and echo the deletion path
        while IFS= read -r line; do
            # Extract repository name and path from the error message
            repo_info=$(echo "$line" | awk -F': ' '{print $2}')
            repo_path=$(dirname "$repo_info")
            repo_name=$(basename "$repo_info")
            # Save the deletion path to a text file
            echo "Deleted repository: $repo_info" | tee -a deleted_repositories.txt
            # Delete the repository
            rm -rf "$repo_path/$repo_name"
            rm -rf ".repo/project/$repo_path/$repo_name"/*.git
        done <<< "$(cat /tmp/output.txt | grep 'uncommitted changes are present')"
    fi

    # Re-sync all repositories after deletion
    echo "Re-syncing all repositories..."
    find .repo -name '*.lock' -delete
    repo sync -c -j64 --force-sync --no-clone-bundle --no-tags --prune
}

main $*


source build/envsetup.sh



riseup X6833B userdebug
gk -s
rise b








# Check CPU usage for the last 10 minutes
(
  for i in {1..10}; do
    sleep 60
    cpu_usage=$(check_cpu_usage)
    echo "Last 10 minutes - minute $i: CPU usage is $cpu_usage%"

    if (( $(echo "$cpu_usage > 60" | bc -l) )); then
      echo "CPU usage exceeded 60%: $cpu_usage%"
      cpu_below_threshold=false
      break
    fi
  done

  if $cpu_below_threshold; then
    echo "CPU usage stayed below 60% for the last 10 minutes. Exiting."
    exit 0
  fi
) &

last_10_min_monitor_pid=$!

# Wait for the monitor processes to finish
wait $monitor_pid
wait $last_10_min_monitor_pid

# Main script logic (if any) continues here
echo "Continuing main script..."
