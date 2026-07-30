# Make sure nothing stale is running
pkill -f "reproxy -server_address" 2>/dev/null
sleep 1

cd /tmp/src/android
source <(curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/lunaris/rbe8.sh)  # confirm this path is where you saved rbe8.sh with the auth fix applied

export RBE_server_address="unix:///tmp/reproxy.sock"

# Start reproxy explicitly with the connection + auth flags
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
echo "--- reproxy.log ---"
cat /tmp/reproxy.log

# Now test compile via rewrapper against that running reproxy
echo 'int main() { return 0; }' > rbe_test.c

prebuilts/remoteexecution-client/buildbuddyfix/rewrapper \
  -server_address="$RBE_server_address" \
  --canonicalize_working_dir \
  --labels=type=compile,lang=cpp,compiler=clang \
  --exec_strategy=remote \
  --platform=container-image=docker://gcr.io/androidbuild-re-dockerimage/android-build-remoteexec-image@sha256:1eb7f64b9e17102b970bd7a1af7daaebdb01c3fb777715899ef462d6c6d01a45,Pool=default \
  -- \
  prebuilts/clang/host/linux-x86/clang-r536225/bin/clang++ -c rbe_test.c -o rbe_test.o

ls -la rbe_test.o
