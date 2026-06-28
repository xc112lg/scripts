#!/bin/bash

set -x  # Show each command

RBE_DIR="rbe1"
RBE_SOCKET="${RBE_DIR}/reproxy.sock"
RBE_BIN="prebuilts/remoteexecution-client/live/reproxy"

# Clean up
pkill -f reproxy 2>/dev/null || true
rm -f "${RBE_SOCKET}"
mkdir -p "${RBE_DIR}/logs"

echo "=== Testing reproxy startup ==="
echo ""

# Try 1: Absolute minimum
echo "Test 1: Minimal arguments"
"${RBE_BIN}" \
  -server_address="unix://${RBE_SOCKET}" \
  -service="remote.buildbuddy.io:443" \
  >> "${RBE_DIR}/logs/reproxy-test1.log" 2>&1 &

sleep 3
if [ -S "${RBE_SOCKET}" ]; then
  echo "✓ Socket created!"
  pkill -f reproxy
  rm -f "${RBE_SOCKET}"
else
  echo "✗ Socket not created"
  echo "Log:"
  cat "${RBE_DIR}/logs/reproxy-test1.log"
fi

echo ""
echo "Test 2: With log_dir"
"${RBE_BIN}" \
  -server_address="unix://${RBE_SOCKET}" \
  -service="remote.buildbuddy.io:443" \
  -log_dir="${RBE_DIR}/logs" \
  >> "${RBE_DIR}/logs/reproxy-test2.log" 2>&1 &

sleep 3
if [ -S "${RBE_SOCKET}" ]; then
  echo "✓ Socket created!"
  pkill -f reproxy
  rm -f "${RBE_SOCKET}"
else
  echo "✗ Socket not created"
  echo "Log:"
  cat "${RBE_DIR}/logs/reproxy-test2.log"
fi
