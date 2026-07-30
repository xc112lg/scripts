cd /tmp/src/android
source <(curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/lunaris/rbe8.sh)
# Kill the old one first
pkill -f "reproxy -server_address" 2>/dev/null
sleep 1

export RBE_server_address="unix:///tmp/reproxy.sock"

prebuilts/remoteexecution-client/buildbuddyfix/reproxy \
  -server_address="$RBE_server_address" \
  -service="$RBE_service" \
  -remote_headers="$RBE_remote_headers" \
  -use_rpc_credentials=false \
  -service_no_auth=false \
  > /tmp/reproxy.log 2>&1 &
REPROXY_PID=$!
sleep 2
ps -p $REPROXY_PID
cat /tmp/reproxy.log
