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
rm -rf sync && git clone https://gitlab.com/muhammadrafiasyddiq/sync && chmod +x sync/sync.sh && ./sync/sync.sh

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
