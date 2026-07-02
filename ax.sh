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
patch -p1 < tutorial/patches/android-rbe-buildbuddyfix-defaults.patch

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

#source <(curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/lunaris/rbe2.sh)
#cat rbe1/logs/reproxy.log
#export WITH_GMS=false
#rm -rf hardware/interfaces/biometrics/fingerprint/2.1/default

# ============================================
# HELPER FUNCTIONS
# ============================================

print_status() { echo -e "${BLUE}[RBE]${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }

# ============================================
# CHECKS
# ============================================

check_binaries() {
    print_status "Checking reclient binaries..."
    if [ ! -x "${RBE_BIN_DIR}/reproxy" ]; then
        print_error "reproxy not found at ${RBE_BIN_DIR}/reproxy"
        return 1
    fi
    
    local wrapper_bin=""
    if [ -x "${RBE_BIN_DIR}/rewrapper" ]; then
        wrapper_bin="rewrapper"
    elif [ -x "${RBE_BIN_DIR}/reclient" ]; then
        wrapper_bin="reclient"
    else
        print_error "wrapper not found"
        return 1
    fi
    
    print_success "reproxy: $(${RBE_BIN_DIR}/reproxy --version 2>/dev/null || echo 'version unknown')"
    print_success "$wrapper_bin: $(${RBE_BIN_DIR}/${wrapper_bin} --version 2>/dev/null || echo 'version unknown')"
    return 0
}

check_api_key() {
    print_status "Validating API key..."
    local api_key="${RBE_remote_headers##*=}"
    
    if [ -z "$api_key" ]; then
        print_error "API key is empty"
        return 1
    fi
    
    if [ "$api_key" = "YOUR_API_KEY_HERE" ]; then
        print_error "Placeholder API key - replace with real key"
        return 1
    fi
    
    print_success "API key configured (${#api_key} chars)"
    return 0
}

check_file_limits() {
    print_status "Checking file descriptor limits..."
    local current_limit=$(ulimit -n)
    
    if [ "$current_limit" -lt 10000 ]; then
        print_warning "Current: $current_limit (need 10000)"
        ulimit -n 10000 2>/dev/null || print_warning "Failed to raise ulimit"
    else
        print_success "File limits OK: $current_limit"
    fi
}

# ============================================
# REPROXY DAEMON
# ============================================

reproxy_running() {
    [ -S "${RBE_SOCKET}" ] && [ ! -z "$(pgrep -f 'reproxy.*server_address' 2>/dev/null)" ]
}

start_reproxy() {
    print_status "Starting reproxy..."

    if reproxy_running; then
        print_warning "reproxy already running, restarting..."
        pkill -f 'reproxy.*server_address' 2>/dev/null || true
        sleep 1
    fi

    rm -f "${RBE_SOCKET}"

    local args=(
        -server_address="unix://${RBE_SOCKET}"
        -service="${RBE_service}"
        -log_dir="${RBE_LOG_DIR}"
        -use_rpc_credentials=true
        -service_no_auth=true
    )

    if [ -x "${RBE_BIN_DIR}/scandeps_server" ]; then
        print_status "Using external dependency scanner"
        args+=(-depsscanner_address="execrel://")
    else
        print_warning "Using internal dependency scanner"
        args+=(-depsscanner_address="")
    fi

    "${RBE_BIN_DIR}/reproxy" "${args[@]}" >> "${RBE_REPROXY_LOG}" 2>&1 &
    local reproxy_pid=$!

    print_status "Waiting for reproxy socket..."

    for _ in $(seq 1 70); do
        [ -S "${RBE_SOCKET}" ] && break
        if ! kill -0 "${reproxy_pid}" 2>/dev/null; then
            print_error "reproxy exited during startup"
            tail -100 "${RBE_REPROXY_LOG}"
            return 1
        fi
        sleep 0.5
    done

    if [ ! -S "${RBE_SOCKET}" ]; then
        print_error "Socket not created"
        tail -100 "${RBE_REPROXY_LOG}"
        return 1
    fi

    sleep 35

    if ! kill -0 "${reproxy_pid}" 2>/dev/null; then
        print_error "reproxy exited unexpectedly"
        tail -100 "${RBE_REPROXY_LOG}"
        return 1
    fi

    print_success "reproxy fully initialized"
    return 0
}

stop_reproxy() {
    print_status "Stopping reproxy..."
    if reproxy_running; then
        pkill -f 'reproxy.*server_address' 2>/dev/null || true
        sleep 1
        print_success "reproxy stopped"
    fi
    rm -f "${RBE_SOCKET}"
}

# ============================================
# DIAGNOSTICS
# ============================================

print_diagnostics() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  AOSP RBE CONFIGURATION${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${BLUE}[RBE]${NC} BuildBuddy:"
    echo "  Instance: xc112lg.buildbuddy.io"
    echo "  Dashboard: https://xc112lg.buildbuddy.io/invocation/"
    echo ""
    
    echo -e "${BLUE}[RBE]${NC} Configuration:"
    echo "  Remote cache: ${RBE_remote_cache}"
    echo "  Socket: ${RBE_SOCKET}"
    echo "  Parallel jobs: ${NINJA_REMOTE_NUM_JOBS}"
    echo "  Local cache: ${RBE_CACHE_DIR}"
    echo ""
    
    echo -e "${BLUE}[RBE]${NC} Daemon:"
    if reproxy_running; then
        echo "  reproxy: ${GREEN}RUNNING${NC}"
        echo "  Socket: ${GREEN}OK${NC}"
    else
        echo "  reproxy: ${RED}STOPPED${NC}"
        echo "  Socket: ${RED}MISSING${NC}"
    fi
    echo ""
}

show_tips() {
    echo ""
    echo -e "${YELLOW}Tips:${NC}"
    echo "1. Monitor cache during build:"
    echo "   tail -f ${RBE_REPROXY_LOG}"
    echo ""
    echo "2. Check BuildBuddy dashboard:"
    echo "   https://xc112lg.buildbuddy.io/invocation/"
    echo ""
    echo "3. Expected output after build:"
    echo "   RBE Stats: down X MB, up Y MB, 0-5 local fallbacks"
    echo ""
}

# ============================================
# MAIN
# ============================================

main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  AOSP RBE Setup for Custom BuildBuddy${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if ! check_binaries; then
        print_error "Reclient binaries not found"
        return 1
    fi
    echo ""
    
    check_file_limits
    echo ""
    
    if ! check_api_key; then
        print_error "API key invalid"
        return 1
    fi
    echo ""
    
    if ! start_reproxy; then
        print_error "Failed to start reproxy"
        return 1
    fi
    echo ""
    
    print_diagnostics
    show_tips
    
    print_success "RBE ready - start your AOSP build now!"
    echo ""
}

trap 'stop_reproxy' EXIT
main "$@"


    
breakfast h872
brunch h872
