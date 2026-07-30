pkill -f reproxy 2>/dev/null
sleep 1
rm -f /tmp/reproxy.sock

cd /tmp/src/android
source <(curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/lunaris/rbe8.sh)

export RBE_server_address="unix:///tmp/reproxy.sock"

prebuilts/remoteexecution-client/buildbuddyfix/reproxy \
  -server_address="$RBE_server_address" \
  -service="$RBE_service" \
  -cas_service="$RBE_service" \
  -remote_headers="$RBE_remote_headers" \
  -use_rpc_credentials=false \
  -service_no_auth=false \
  -service_no_security=false \
  > /tmp/reproxy.log 2>&1 &

sleep 3
echo "===== REPROXY LOG ====="
cat /tmp/reproxy.log
echo "========================"
