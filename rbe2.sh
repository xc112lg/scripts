#!/bin/bash
# ============================================================================
# ENHANCED RBE CONFIGURATION FOR BUILDBUDDY + REPROXY DAEMON MANAGEMENT
# Includes: startup verification, health checks, diagnostics, graceful shutdown
# ============================================================================

# Color output for clarity
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================
# CONFIGURATION PATHS & DIRECTORIES
# ============================================
export RBE_DIR="${RBE_DIR:-rbe1}"
export RBE_LOG_DIR="${RBE_DIR}/logs"
export RBE_CACHE_DIR="${RBE_DIR}/cache"
export RBE_SOCKET="${RBE_DIR}/reproxy.sock"
export RBE_REPROXY_LOG="${RBE_LOG_DIR}/reproxy.log"
export RBE_RECLIENT_LOG="${RBE_LOG_DIR}/reclient.log"

# Ensure directories exist
mkdir -p "${RBE_LOG_DIR}" "${RBE_CACHE_DIR}"

# ============================================
# BUILDBUDDY CONFIGURATION (Active API Key)
# ============================================
export RBE_remote_cache="grpcs://remote.buildbuddy.io"
export RBE_remote_cache_header="x-buildbuddy-api-key,NF5nEUUyU7LIy2QkkIIe"
export RBE_service="remote.buildbuddy.io:443"
export RBE_remote_headers="x-buildbuddy-api-key,NF5nEUUyU7LIy2QkkIIe"
export RBE_use_rpc_credentials=true

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
export NINJA_REMOTE_NUM_JOBS=500

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
# EXECUTION STRATEGIES (with fallback safety)
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

export RBE_JAVA_POOL=default
export RBE_METALAVA_POOL=default
export RBE_LINT_POOL=default
export RBE_exec_timeout=20m
export RBE_reclient_timeout=120m

export RBE_cache_dir="${RBE_CACHE_DIR}"
export RBE_enable_local_cache=1
export RBE_batch_downloads=true

# ============================================
# UTILITIES
# ============================================
print_status() { echo -e "${BLUE}[RBE]${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }

reproxy_running() {
    [ -S "${RBE_SOCKET}" ] && [ ! -z "$(pgrep -f "reproxy.*server_address=unix://${RBE_SOCKET}" 2>/dev/null)" ]
}

check_binaries() {
    print_status "Checking reclient binaries..."
    if [ ! -x "${RBE_BIN_DIR}/reproxy" ]; then
        print_error "reproxy not found at ${RBE_BIN_DIR}/reproxy"
        return 1
    fi
    return 0
}

check_file_limits() {
    print_status "Checking file descriptor limits..."
    local current_limit=$(ulimit -n)
    local required=10000
    if [ "$current_limit" -lt "$required" ]; then
        print_warning "Current limit: $current_limit (need $required)"
        ulimit -n $required 2>/dev/null || print_warning "Failed to raise ulimit (may need sudo)"
    else
        print_success "File limits OK: $current_limit"
    fi
}

# ============================================
# REPROXY DAEMON STARTUP
# ============================================
start_reproxy() {
    print_status "Starting reproxy daemon..."
    
    # Pre-startup cleanup to prevent socket lockups
    if reproxy_running; then
        print_warning "reproxy already running for this socket context."
        return 0
    fi
    rm -f "${RBE_SOCKET}"
    
    # Fire up reproxy using inherited environment configurations
    "${RBE_BIN_DIR}/reproxy" \
        -server_address="unix://${RBE_SOCKET}" \
        -log_dir="${RBE_LOG_DIR}" \
        >> "${RBE_REPROXY_LOG}" 2>&1 &
    
    local reproxy_pid=$!
    
    # Wait loop for unix socket registration
    local wait_count=0
    while [ ! -S "${RBE_SOCKET}" ] && [ $wait_count -lt 10 ]; do
        sleep 0.5
        ((wait_count++))
    done
    
    # Verification block with automatic tail dumping on crash
    if [ ! -S "${RBE_SOCKET}" ] || ! reproxy_running; then
        print_error "reproxy failed to start properly."
        echo -e "${RED}==================== REPROXY CRASH LOG ====================${NC}"
        if [ -f "${RBE_REPROXY_LOG}" ]; then
            tail -n 50 "${RBE_REPROXY_LOG}"
        else
            echo "Log file not found at ${RBE_REPROXY_LOG}"
        fi
        echo -e "${RED}===========================================================${NC}"
        return 1
    fi
    
    print_success "reproxy daemon online (PID: $reproxy_pid)"
    return 0
}

# Tear down function called manually when done with the entire build environment
stop_rbe() {
    print_status "Stopping reproxy daemon..."
    local pid=$(pgrep -f "reproxy.*server_address=unix://${RBE_SOCKET}")
    if [ ! -z "$pid" ]; then
        kill "$pid" && print_success "reproxy stopped."
    else
        print_warning "No reproxy daemon running for this socket context."
    fi
    rm -f "${RBE_SOCKET}"
}

# ============================================
# MAIN INITIALIZATION LOGIC
# ============================================
main_rbe() {
    echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  Enhanced RBE Configuration for BuildBuddy     ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    if ! check_binaries; then return 1; fi
    check_file_limits
    
    if start_reproxy; then
        echo ""
        print_success "RBE environment sourced and ready for AOSP!"
        print_status "To clean up after your build finishes, run: stop_rbe"
        echo ""
    else
        echo ""
        print_error "RBE initialization failed. Resolve the log errors shown above before building."
        echo ""
        return 1
    fi
}

main_rbec