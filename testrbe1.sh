pkill -f reproxy 2>/dev/null
sleep 1
rm -f /tmp/reproxy.sock /tmp/depscan.sock

cd /tmp/src/android
source /tmp/rbe8.sh

# Test 1: Basic reachability + auth via curl against BuildBuddy's gRPC-gateway/API
curl -s -o /dev/null -w "HTTP status: %{http_code}\n" \
  -H "x-buildbuddy-api-key: D2SvmJdB1v8oM6KaNg6J" \
  https://xc112lg.buildbuddy.io/

# Test 2: Check if grpcurl is available for a more direct RPC-level test
which grpcurl || echo "grpcurl not installed"
