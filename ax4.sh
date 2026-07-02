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

export RBE_service="xc112lg.buildbuddy.io:443"        # BuildBuddy instance address (without grpcs://, add the port 443)
export RBE_remote_headers="x-buildbuddy-api-key=D2SvmJdB1v8oM6KaNg6J"    # Your BuildBuddy API key
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
# Verifies reproxy can actually reach the BuildBuddy service before
# kicking off a full build. Run with:  bash ax.sh test
# =====================================================================
test_rbe_connection() {
    local reproxy_dir="${RBE_DIR}"

    if [[ ! -d "${reproxy_dir}" ]]; then
        echo "[RBE TEST] ERROR: RBE_DIR not found at ${reproxy_dir}"
        echo "[RBE TEST] Did build_patched_reclient.sh run successfully?"
        return 1
    fi

    if [[ ! -x "${reproxy_dir}/bootstrap" ]]; then
        echo "[RBE TEST] ERROR: bootstrap binary not found/executable in ${reproxy_dir}"
        ls -la "${reproxy_dir}" 2>/dev/null
        return 1
    fi

    echo "[RBE TEST] 1/4 Checking basic network reachability to ${RBE_service}..."
    local host="${RBE_service%%:*}"
    if ! curl -s -o /dev/null -w "%{http_code}" --max-time 10 "https://${host}" >/dev/null 2>&1; then
        echo "[RBE TEST] WARNING: could not reach https://${host} — check network/DNS before continuing."
    else
        echo "[RBE TEST] Host ${host} is reachable."
    fi

    pushd "${reproxy_dir}" >/dev/null || return 1

    local LOCAL_SOCK="unix:///tmp/reproxy_test_$$.sock"

    echo "[RBE TEST] 2/4 Starting reproxy via bootstrap (local socket: ${LOCAL_SOCK})..."
    ./bootstrap --re_proxy=./reproxy --server_address="${LOCAL_SOCK}"
    local boot_status=$?
    if [[ $boot_status -ne 0 ]]; then
        echo "[RBE TEST] ERROR: bootstrap failed to start reproxy (exit $boot_status)."
        echo "[RBE TEST] Check for auth/network errors above (Unauthenticated, connection refused, TLS failure)."
        popd >/dev/null
        return 1
    fi
    echo "[RBE TEST] reproxy started."

    echo "[RBE TEST] 3/4 Dispatching a single test action through rewrapper..."
    if [[ -x ./rewrapper ]]; then
        ./rewrapper --server_address="${LOCAL_SOCK}" --labels=type=test --exec_root="$(pwd)" -- echo "rbe connection test"
        local wrap_status=$?
        if [[ $wrap_status -eq 0 ]]; then
            echo "[RBE TEST] Test action dispatched successfully."
            echo "[RBE TEST] Check the BuildBuddy dashboard 'Invocations' tab to confirm it landed remotely."
        else
            echo "[RBE TEST] WARNING: rewrapper test action failed (exit $wrap_status)."
        fi
    else
        echo "[RBE TEST] WARNING: rewrapper binary not found, skipping action dispatch test."
    fi

    echo "[RBE TEST] 4/4 Shutting down reproxy and checking logs..."
    ./bootstrap --shutdown --server_address="${LOCAL_SOCK}"

    local log_file
    log_file=$(ls -t reproxy_*.INFO 2>/dev/null | head -1)
    if [[ -n "$log_file" ]]; then
        echo "[RBE TEST] Latest log: $log_file"
        grep -iE "error|fail|unauth|connect" "$log_file" | tail -20
    else
        echo "[RBE TEST] No reproxy_*.INFO log found to inspect."
    fi

    popd >/dev/null
    echo "[RBE TEST] Done. If no errors were printed above and the dashboard showed an invocation, RBE is connected."
}

if [[ "$1" == "test" ]]; then
    test_rbe_connection
    exit $?
fi