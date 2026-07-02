#!/bin/bash
# ============================================================================
# AOSP RBE CONFIGURATION FOR CUSTOM BUILDBUDDY + REPROXY
# Minimal configuration - reproxy will timeout on dependency scanner gracefully
# ============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================
# PATHS & DIRECTORIES
# ============================================

export RBE_DIR="/tmp/src/android/rbe1"
export RBE_LOG_DIR="${RBE_DIR}/logs"
export RBE_CACHE_DIR="${RBE_DIR}/cache"
export RBE_SOCKET="/tmp/reproxy_aosp.sock"
export RBE_REPROXY_LOG="${RBE_LOG_DIR}/reproxy.log"
export RBE_RECLIENT_LOG="${RBE_LOG_DIR}/reclient.log"

mkdir -p "${RBE_LOG_DIR}" "${RBE_CACHE_DIR}"

# ============================================
# BUILDBUDDY CONFIGURATION
# ============================================

export RBE_remote_cache="grpcs://xc112lg.buildbuddy.io"
export RBE_service="xc112lg.buildbuddy.io:443"
export RBE_remote_cache_header="x-buildbuddy-api-key=D2SvmJdB1v8oM6KaNg6J"
export RBE_remote_headers="x-buildbuddy-api-key=D2SvmJdB1v8oM6KaNg6J"

export RBE_use_rpc_credentials=true
export RBE_service_no_auth=false

# ============================================
# RECLIENT BINARY DISCOVERY
# ============================================

find_reclient_bin() {
    local search_paths=(
        "prebuilts/remoteexecution-client/live"
        "prebuilts/remoteexecution-client"
        "out/soong/remoteexecution-client"
        "${PWD}/prebuilts/remoteexecution-client/live"
    )
    
    for path in "${search_paths[@]}"; do
        if [ -x "${path}/reproxy" ] 2>/dev/null; then
            echo "${path}"
            return 0
        fi
    done
    return 1
}

export RBE_BIN_DIR=$(find_reclient_bin || echo "prebuilts/remoteexecution-client/live")
export PATH="${RBE_BIN_DIR}:${PATH}"

# ============================================
# PLATFORM & EXECUTION CONFIG
# ============================================

export RBE_PLATFORM="container-image=docker://gcr.io/cloud-marketplace/google/rbe-ubuntu22-04,OSFamily=Linux,docker_network=off"
export USE_RBE=1
export NINJA_REMOTE_NUM_JOBS=160

# ============================================
# RBE SOCKET & LOGGING
# ============================================

export RBE_server_address="unix://${RBE_SOCKET}"
export RBE_log_dir="${RBE_LOG_DIR}"
export RBE_LOG=INFO
export RBE_VERBOSE=0

# ============================================
# NETWORK OPTIMIZATION
# ============================================

export RBE_use_unified_downloads=true
export RBE_use_unified_uploads=true
export RBE_compression=gzip
export RBE_compression_level=6
export RBE_max_open_files=10000

# ============================================
# EXECUTION STRATEGIES
# ============================================

export RBE_R8_EXEC_STRATEGY=remote_local_fallback
export RBE_D8_EXEC_STRATEGY=remote_local_fallback
export RBE_JAVAC_EXEC_STRATEGY=remote_local_fallback
export RBE_JAR_EXEC_STRATEGY=remote_local_fallback
export RBE_ZIP_EXEC_STRATEGY=remote_local_fallback
export RBE_TURBINE_EXEC_STRATEGY=remote_local_fallback
export RBE_SIGNAPK_EXEC_STRATEGY=remote_local_fallback
export RBE_CXX_EXEC_STRATEGY=remote_local_fallback
export RBE_CXX_LINKS_EXEC_STRATEGY=remote_local_fallback
export RBE_ABI_LINKER_EXEC_STRATEGY=remote_local_fallback
export RBE_CLANG_TIDY_EXEC_STRATEGY=remote_local_fallback
export RBE_METALAVA_EXEC_STRATEGY=remote_local_fallback
export RBE_LINT_EXEC_STRATEGY=remote_local_fallback

# ============================================
# TOOL ENABLEMENT
# ============================================

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
export RBE_CLANG_TIDY=1
export RBE_METALAVA=1
export RBE_LINT=1

# ============================================
# RESOURCE POOLS & TIMEOUTS
# ============================================

export RBE_JAVA_POOL=default
export RBE_METALAVA_POOL=default
export RBE_LINT_POOL=default
export RBE_exec_timeout=20m
export RBE_reclient_timeout=120m

# ============================================
# CACHING
# ============================================

export RBE_cache_dir="${RBE_CACHE_DIR}"
export RBE_enable_local_cache=1
export RBE_batch_downloads=true

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
    
    # reproxy configuration  
    # Custom BuildBuddy instances don't have dependency scanner service
    # Setting depsscanner_address to empty string avoids scanner timeout
    "${RBE_BIN_DIR}/reproxy" \
        -server_address="unix://${RBE_SOCKET}" \
        -service="${RBE_service}" \
        -service_no_auth="${RBE_service_no_auth}" \
        -log_dir="${RBE_LOG_DIR}" \
        -depsscanner_address="" \
        >> "${RBE_REPROXY_LOG}" 2>&1 &
    
    local reproxy_pid=$!
    print_status "reproxy PID: $reproxy_pid"
    
    # Wait for socket - reproxy will timeout on dependency scanner (~30 seconds)
    print_status "Waiting for reproxy socket (may take up to 35 seconds)..."
    local wait_count=0
    local max_wait=70  # 35 seconds (70 * 0.5s)
    
    while [ ! -S "${RBE_SOCKET}" ] && [ $wait_count -lt $max_wait ]; do
        if [ $((wait_count % 20)) -eq 0 ] && [ $wait_count -gt 0 ]; then
            print_status "Still waiting... ($((wait_count / 2)) seconds elapsed)"
        fi
        sleep 0.5
        ((wait_count++))
    done
    
    if [ ! -S "${RBE_SOCKET}" ]; then
        print_error "reproxy socket not created after 35 seconds"
        print_error "reproxy may have crashed. Check logs:"
        print_status "Last 50 lines of reproxy.log:"
        tail -50 "${RBE_REPROXY_LOG}" 2>/dev/null | tail -50
        return 1
    fi
    
    local elapsed=$((wait_count / 2))
    print_success "reproxy socket created after ${elapsed}s: ${RBE_SOCKET}"
    
    sleep 1
    if ! reproxy_running; then
        print_error "reproxy exited unexpectedly"
        print_status "Last 50 lines of reproxy.log:"
        tail -50 "${RBE_REPROXY_LOG}" 2>/dev/null | tail -50
        return 1
    fi
    
    print_success "reproxy online"
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


cat rbe1/logs/reproxy.log

