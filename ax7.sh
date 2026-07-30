#!/bin/bash
#git clone https://github.com/xc112lg/rbe1 >/dev/null 2>&1

# rm -rf .repo/local_manifests 
# git clone https://github.com/LG-G6/scripts.git -b lineage-21 
# mkdir .repo/local_manifests 
# cp scripts/roomservice.xml .repo/local_manifests/ 
#repo sync -c -j32 --force-sync --no-clone-bundle --no-tags
#/opt/crave/resync.sh

export CLANG_TARGET_ARM32="--target=arm-linux-android"
source build/envsetup.sh
#make clean
git clone https://github.com/Rares6567/new_rbe_fix tutorial
bash tutorial/scripts/build_patched_reclient.sh .

PATCH_FILE="tutorial/patches/android-rbe-buildbuddyfix-defaults.patch"
if patch -p1 --dry-run --forward < "$PATCH_FILE" >/dev/null 2>&1; then
    echo "[PATCH] Not yet applied, applying now..."
    patch -p1 < "$PATCH_FILE"
else
    echo "[PATCH] Already applied (or conflicts), skipping."
fi

export RBE_service="xc112lg1.buildbuddy.io:443"        # BuildBuddy instance address (without grpcs://, add the port 443)
export RBE_remote_headers="x-buildbuddy-api-key=7iMbWyZKZx0eFB9MLKUd"    # Your BuildBuddy API key
export RBE_use_rpc_credentials=false
export RBE_service_no_auth=true

# --- Enable RBE and General Settings ---
export USE_RBE=1
export RBE_DIR="prebuilts/remoteexecution-client/buildbuddyfix"                     # Set this to the output folder produced by the fix script
export NINJA_REMOTE_NUM_JOBS=256                        # Number of parallel remote jobs (adjust based on your RAM, AOSP default is 500)

# --- Unified Downloads/Uploads (Recommended) ---
export RBE_use_unified_downloads=true
export RBE_use_unified_uploads=true

# --- Execution Strategies (remote_local_fallback is generally best) ---
export RBE_R8_EXEC_STRATEGY=remote_local_fallback
export RBE_D8_EXEC_STRATEGY=remote_local_fallback
export RBE_JAVAC_EXEC_STRATEGY=remote_local_fallback
export RBE_JAR_EXEC_STRATEGY=remote_local_fallback
export RBE_ZIP_EXEC_STRATEGY=remote_local_fallback
export RBE_TURBINE_EXEC_STRATEGY=remote_local_fallback
export RBE_SIGNAPK_EXEC_STRATEGY=remote_local_fallback
export RBE_CXX_EXEC_STRATEGY=remote_local_fallback    # Important see below.
export RBE_CXX_LINKS_EXEC_STRATEGY=remote_local_fallback
export RBE_ABI_LINKER_EXEC_STRATEGY=remote_local_fallback
export RBE_ABI_DUMPER_EXEC_STRATEGY=    # Will make build slower, by a lot. Keeping this for documentation
export RBE_CLANG_TIDY_EXEC_STRATEGY=remote_local_fallback
export RBE_METALAVA_EXEC_STRATEGY=remote_local_fallback
export RBE_LINT_EXEC_STRATEGY=remote_local_fallback

# --- Enable RBE for Specific Tools ---
export RBE_R8=1
export RBE_D8=1
export RBE_JAVAC=1
export RBE_JAR=1
export RBE_ZIP=1
export RBE_TURBINE=1
export RBE_SIGNAPK=1
export RBE_CXX_LINKS=1
export RBE_CXX=1
export RBE_ABI_LINKER=1
export RBE_ABI_DUMPER=    # Will make build slower, by a lot. Keeping this for documentation
export RBE_CLANG_TIDY=1
export RBE_METALAVA=1
export RBE_LINT=1

# --- Resource Pools ---
export RBE_JAVA_POOL=default
export RBE_METALAVA_POOL=default
export RBE_LINT_POOL=default

# --- Timeouts ---
export RBE_reclient_timeout=60m
export RBE_exec_timeout=10m

# =====================================================================
# --- RBE Connection Test ---
# Starts reproxy directly (not via bootstrap), waits for its unix socket,
# fires one test action through rewrapper, then tears it down.
# Run with:  bash ax.sh test  (or: source ax.sh test)
# =====================================================================
RBE_TEST_SOCKET="/tmp/reproxy_ax_test.sock"
RBE_TEST_LOG_DIR="/tmp/rbe_ax_test_logs"
RBE_TEST_LOG="${RBE_TEST_LOG_DIR}/reproxy.log"

test_reproxy_running() {
    [ -S "${RBE_TEST_SOCKET}" ] && [ -n "$(pgrep -f "reproxy.*${RBE_TEST_SOCKET}" 2>/dev/null)" ]
}

test_check_binaries() {
    echo "[RBE TEST] Checking reclient binaries in ${RBE_DIR}..."
    if [[ ! -x "${RBE_DIR}/reproxy" ]]; then
        echo "[RBE TEST] ERROR: reproxy not found/executable at ${RBE_DIR}/reproxy"
        ls -la "${RBE_DIR}" 2>/dev/null
        return 1
    fi
    if [[ ! -x "${RBE_DIR}/rewrapper" ]]; then
        echo "[RBE TEST] ERROR: rewrapper not found/executable at ${RBE_DIR}/rewrapper"
        return 1
    fi
    echo "[RBE TEST] reproxy:   $(${RBE_DIR}/reproxy --version 2>/dev/null || echo 'version unknown')"
    echo "[RBE TEST] rewrapper: $(${RBE_DIR}/rewrapper --version 2>/dev/null || echo 'version unknown')"
    return 0
}

test_check_api_key() {
    echo "[RBE TEST] Validating API key..."
    local api_key="${RBE_remote_headers##*=}"
    if [[ -z "$api_key" ]]; then
        echo "[RBE TEST] ERROR: API key is empty (RBE_remote_headers unset?)"
        return 1
    fi
    if [[ "$api_key" == "YOUR_API_KEY_HERE" ]]; then
        echo "[RBE TEST] ERROR: placeholder API key, replace with a real key"
        return 1
    fi
    echo "[RBE TEST] API key configured (${#api_key} chars)"
    return 0
}

test_check_file_limits() {
    local current_limit
    current_limit=$(ulimit -n)
    if [[ "$current_limit" -lt 10000 ]]; then
        echo "[RBE TEST] WARNING: file descriptor limit is $current_limit (recommended 10000+)"
        ulimit -n 10000 2>/dev/null || echo "[RBE TEST] WARNING: failed to raise ulimit"
    else
        echo "[RBE TEST] File descriptor limit OK: $current_limit"
    fi
}

test_start_reproxy() {
    echo "[RBE TEST] Starting reproxy..."

    if test_reproxy_running; then
        echo "[RBE TEST] reproxy already running from a previous test, restarting..."
        pkill -f "reproxy.*${RBE_TEST_SOCKET}" 2>/dev/null || true
        sleep 1
    fi

    mkdir -p "${RBE_TEST_LOG_DIR}"
    rm -f "${RBE_TEST_SOCKET}"

    local args=(
        -server_address="unix://${RBE_TEST_SOCKET}"
        -service="${RBE_service}"
        -log_dir="${RBE_TEST_LOG_DIR}"
        -use_rpc_credentials="${RBE_use_rpc_credentials:-false}"
        -service_no_auth="${RBE_service_no_auth:-true}"
        -alsologtostderr
        -v=2
    )
    [[ -n "${RBE_remote_headers}" ]] && args+=(-remote_headers="${RBE_remote_headers}")

    echo "[DEBUG] reproxy args: ${args[@]}"

    "${RBE_DIR}/reproxy" "${args[@]}" >> "${RBE_TEST_LOG}" 2>&1 &
    local reproxy_pid=$!

    echo "[RBE TEST] Waiting for reproxy socket (pid ${reproxy_pid})..."
    for _ in $(seq 1 30); do
        [[ -S "${RBE_TEST_SOCKET}" ]] && break
        if ! kill -0 "${reproxy_pid}" 2>/dev/null; then
            echo "[RBE TEST] ERROR: reproxy exited during startup"
            tail -100 "${RBE_TEST_LOG}"
            return 1
        fi
        sleep 0.5
    done

    if [[ ! -S "${RBE_TEST_SOCKET}" ]]; then
        echo "[RBE TEST] ERROR: socket never appeared at ${RBE_TEST_SOCKET}"
        tail -100 "${RBE_TEST_LOG}"
        return 1
    fi

    echo "[RBE TEST] Socket up. Giving reproxy a moment to finish connecting..."
    sleep 5

    if ! kill -0 "${reproxy_pid}" 2>/dev/null; then
        echo "[RBE TEST] ERROR: reproxy exited right after socket creation"
        tail -100 "${RBE_TEST_LOG}"
        return 1
    fi

    echo "[RBE TEST] reproxy running (pid ${reproxy_pid})."
    return 0
}

test_stop_reproxy() {
    if test_reproxy_running; then
        echo "[RBE TEST] Stopping reproxy..."
        pkill -f "reproxy.*${RBE_TEST_SOCKET}" 2>/dev/null || true
        sleep 1
    fi
    rm -f "${RBE_TEST_SOCKET}"
}

test_rbe_connection() {
    test_check_binaries || return 1
    test_check_api_key || return 1
    test_check_file_limits

    trap 'test_stop_reproxy' RETURN

    test_start_reproxy || return 1

    echo "[RBE TEST] Dispatching a single test action through rewrapper..."
    "${RBE_DIR}/rewrapper" -server_address="unix://${RBE_TEST_SOCKET}" -exec_root="$(pwd)" -- echo "rbe connection test"
    local wrap_status=$?
    if [[ $wrap_status -eq 0 ]]; then
        echo "[RBE TEST] Test action dispatched successfully."
        echo "[RBE TEST] Check https://xc112lg.buildbuddy.io/invocation/ to confirm it landed remotely."
    else
        echo "[RBE TEST] WARNING: rewrapper test action failed (exit $wrap_status)."
    fi

    echo "[RBE TEST] --- last 30 lines of reproxy log ---"
    tail -30 "${RBE_TEST_LOG}" 2>/dev/null
    echo "[RBE TEST] --- grep for errors/auth issues ---"
    grep -iE "error|fail|unauth|denied" "${RBE_TEST_LOG}" 2>/dev/null | tail -20

    return $wrap_status
}

if [[ "$1" == "test" ]]; then
    test_rbe_connection
    exit $?
fi
