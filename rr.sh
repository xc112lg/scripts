#!/usr/bin/env bash

source <(curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/lunaris/rbe7.sh)
echo "========== RBE Environment =========="

vars=(
USE_RBE
RBE_service
RBE_remote_headers
RBE_service_no_auth
RBE_use_rpc_credentials
RBE_CXX_EXEC_STRATEGY
RBE_JAVAC_EXEC_STRATEGY
RBE_R8_EXEC_STRATEGY
)

for v in "${vars[@]}"; do
    printf "%-30s = %s\n" "$v" "${!v:-<unset>}"
done

echo
echo "========== API Header =========="

if [[ -z "${RBE_remote_headers:-}" ]]; then
    echo "ERROR: RBE_remote_headers is empty"
    exit 1
fi

echo "Header found."

echo
echo "========== DNS =========="

HOST="${RBE_service%%:*}"

getent hosts "$HOST" || {
    echo "Cannot resolve $HOST"
    exit 1
}

echo
echo "========== TCP =========="

PORT="${RBE_service##*:}"

timeout 5 bash -c "</dev/tcp/$HOST/$PORT" \
    && echo "TCP OK" \
    || {
        echo "Cannot connect to $HOST:$PORT"
        exit 1
    }

echo
echo "========== rewrapper =========="

RWRAPPER=prebuilts/remoteexecution-client/buildbuddyfix/rewrapper

if [[ ! -x "$RWRAPPER" ]]; then
    echo "rewrapper not found"
    exit 1
fi

echo "Found $RWRAPPER"

echo
echo "========== Version =========="

"$RWRAPPER" --version || true

echo
echo "========== Starting reproxy =========="

pkill reproxy 2>/dev/null || true

prebuilts/remoteexecution-client/buildbuddyfix/bootstrap \
    > /tmp/reproxy-test.log 2>&1 &

sleep 5

if ! pgrep -x reproxy >/dev/null; then
    echo "FAILED: reproxy did not start"
    cat /tmp/reproxy-test.log
    exit 1
fi

echo "reproxy started."

echo
echo "========== Health =========="

if command -v curl >/dev/null; then
    curl -fs http://127.0.0.1:8080/statusz || true
fi

echo
echo "========== Authentication =========="

grep -Ei "Unauth|auth|error|api" /tmp/reproxy-test.log || \
echo "No authentication errors detected."

echo
echo "========== SUCCESS =========="



prebuilts/remoteexecution-client/buildbuddyfix/reproxy -server_address=unix:///tmp/reproxy.sock -service=xc112lg.buildbuddy.io:443 -cas_service=xc112lg.buildbuddy.io:443 -remote_headers="x-buildbuddy-api-key=D2SvmJdB1v8oM6KaNg6J"
