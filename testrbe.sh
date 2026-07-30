cd /tmp/src/android
source <(curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/lunaris/rbe8.sh)

# 1. Pick a socket path and start reproxy as a background daemon
export RBE_server_address="unix:///tmp/reproxy.sock"
prebuilts/remoteexecution-client/buildbuddyfix/reproxy \
  -server_address="$RBE_server_address" \
  > /tmp/reproxy.log 2>&1 &
REPROXY_PID=$!
sleep 2   # give it a moment to come up

# 2. Confirm it's alive
ps -p $REPROXY_PID
tail -20 /tmp/reproxy.log

# 3. Now run rewrapper, pointing it at that same local socket
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

# 4. Second run to test cache
rm -f rbe_test.o
time prebuilts/remoteexecution-client/buildbuddyfix/rewrapper \
  -server_address="$RBE_server_address" \
  --canonicalize_working_dir \
  --labels=type=compile,lang=cpp,compiler=clang \
  --exec_strategy=remote \
  --platform=container-image=docker://gcr.io/androidbuild-re-dockerimage/android-build-remoteexec-image@sha256:1eb7f64b9e17102b970bd7a1af7daaebdb01c3fb777715899ef462d6c6d01a45,Pool=default \
  -- \
  prebuilts/clang/host/linux-x86/clang-r536225/bin/clang++ -c rbe_test.c -o rbe_test.o

ls -la rbe_test.o

# 5. Cleanup
kill $REPROXY_PID
rm -f rbe_test.c rbe_test.o
