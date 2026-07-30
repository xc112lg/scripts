pkill -f reproxy 2>/dev/null
sleep 1
rm -f /tmp/reproxy.sock

cd /tmp/src/android
source /tmp/rbe8.sh

prebuilts/remoteexecution-client/buildbuddyfix/reproxy \
  -server_address="unix:///tmp/reproxy.sock" \
  -service="$RBE_service" \
  -cas_service="$RBE_service" \
  -remote_headers="$RBE_remote_headers" \
  -use_rpc_credentials=false \
  -use_application_default_credentials=false \
  -use_gce_credentials=false \
  -use_external_auth_token=false \
  -service_no_auth=false \
  -service_no_security=false \
  > /tmp/reproxy.log 2>&1 &

sleep 3
echo "===== REPROXY LOG ====="
cat /tmp/reproxy.log
echo "========================"
