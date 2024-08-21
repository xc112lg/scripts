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

# Start a background process to monitor CPU usage for the last 10 minutes of the 1-hour period
(
  echo "Waiting for 50 minutes before starting CPU monitoring..."
  sleep 3000  # Wait for 50 minutes

  echo "Starting CPU monitoring for the last 10 minutes..."
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
    kill $$  # Exit the entire script if the CPU usage stayed below 60%
  fi
) &

monitor_pid=$!

# Run main command in the background
echo "Running main command..."
repo init -u https://github.com/accupara/los21-exp.git -b lineage-21.0 --git-lfs
#repo init -u https://github.com/LineageOS/android.git -b lineage-21.0 --git-lfs


source scripts/cleanmanifest.sh
rm -rf .repo/local_manifests


echo "building $DEVICE for $USERNAME"

git clone --depth=1 $MANIFEST -b $BRANCH .repo/local_manifests

cd build/make
git reset --hard
cd -


/opt/crave/resync.sh

sed -i '0,/echo "including \$f"; \. "\$T\/\$f"/ s|echo "including \$f"; \. "\$T\/\$f"|echo "vendorsetup.sh is not allowed, skipping changes"|' build/make/envsetup.sh

. build/envsetup.sh
breakfast $DEVICE $BUILD_TYPE
m bacon

main_command_pid=$!

# Wait for the monitoring process to finish
wait $monitor_pid

# If the monitoring process finishes and exits the script, kill the main command if it's still running
if ps -p $main_command_pid > /dev/null; then
  echo "Killing main command..."
  kill $main_command_pid
fi

# Wait for the main command to finish
wait $main_command_pid

# Main script logic (if any) continues here
echo "Continuing main script..."
