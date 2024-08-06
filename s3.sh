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

# Variable to track if CPU usage stays below 10%
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

    if (( $(echo "$cpu_usage > 10" | bc -l) )); then
      echo "CPU usage exceeded 10%: $cpu_usage%"
      cpu_below_threshold=false
      break
    fi
  done

  if $cpu_below_threshold; then
    echo "CPU usage stayed below 10% for the last 10 minutes. Exiting."
    kill $$  # Exit the entire script if the CPU usage stayed below 10%
  fi
) &

monitor_pid=$!

# Run main command in the background
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



/opt/crave/resync.sh
source build/envsetup.sh
riseup X6833B userdebug
gk -s
rise b



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
