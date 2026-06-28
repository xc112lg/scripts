#!/bin/bash
# ============================================================================
# ENHANCED RBE CONFIGURATION FOR BUILDBUDDY + REPROXY DAEMON MANAGEMENT
# Includes: startup verification, health checks, diagnostics, graceful shutdown
# ============================================================================

set -e  # Exit on error

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
# BUILDBUDDY CONFIGURATION
# ============================================

export RBE_service="remote.buildbuddy.io:443"
export RBE_remote_headers="x-buildbuddy-api-key,NF5nEUUyU7LIy2QkkIIe"
export RBE_use_rpc_credentials=true
export RBE_service_no_auth=true  # Disable auth for testing with placeholder key

# ============================================
# RECLIENT BINARY DISCOVERY
# ============================================

# Try multiple common AOSP paths
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

# Add reclient binaries to PATH (must come BEFORE repoxy startup)
export PATH="${RBE_BIN_DIR}:${PATH}"

# ============================================
# PLATFORM & EXECUTION CONFIG
# ============================================

export RBE_PLATFORM="container-image=docker://gcr.io/cloud-marketplace/google/rbe-ubuntu18-04@sha256:6346552230ab057cf5bc8da39b56f8742ca2c63f10f60710fc39c8901b0b72f4,OSFamily=Linux"

export USE_RBE=1
export NINJA_REMOTE_NUM_JOBS=400

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

print_status() {
    echo -e "${BLUE}[RBE]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# ============================================
# PRE-STARTUP CHECKS
# ============================================

check_binaries() {
    print_status "Checking reclient binaries..."
    
    if [ ! -x "${RBE_BIN_DIR}/reproxy" ]; then
        print_error "reproxy not found at ${RBE_BIN_DIR}/reproxy"
        print_warning "Searched paths:"
        find . -name reproxy -type f 2>/dev/null | head -5 || echo "  (none found)"
        return 1
    fi
    
    # Check for rewrapper (Crave/Lineage 21-22) or reclient (generic AOSP)
    local wrapper_bin=""
    if [ -x "${RBE_BIN_DIR}/rewrapper" ]; then
        wrapper_bin="rewrapper"
    elif [ -x "${RBE_BIN_DIR}/reclient" ]; then
        wrapper_bin="reclient"
    else
        print_error "wrapper not found (neither rewrapper nor reclient at ${RBE_BIN_DIR})"
        return 1
    fi
    
    print_success "reproxy: $(${RBE_BIN_DIR}/reproxy --version 2>/dev/null || echo 'version unknown')"
    print_success "$wrapper_bin: $(${RBE_BIN_DIR}/${wrapper_bin} --version 2>/dev/null || echo 'version unknown')"
    return 0
}

check_api_key() {
    print_status "Validating BuildBuddy API key..."
    
    # Extract API key from header (format: "key,value")
    local api_key="${RBE_remote_headers##*,}"
    
    if [ -z "$api_key" ]; then
        print_error "API key is empty!"
        print_warning "Add your BuildBuddy API key to line 36 in rbe.sh"
        return 1
    fi
    
    if [ "$api_key" = "NF5nEUUyU7LIy2QkkIIe" ]; then
        print_warning "Using PLACEHOLDER API key"
        print_warning "Update line 36 with your actual BuildBuddy API key:"
        print_warning "  export RBE_remote_headers=\"x-buildbuddy-api-key,YOUR_KEY_HERE\""
        return 1
    fi
    
    print_success "API key configured (${#api_key} chars)"
    return 0
}

check_file_limits() {
    print_status "Checking file descriptor limits..."
    
    local current_limit=$(ulimit -n)
    local required=10000
    
    if [ "$current_limit" -lt "$required" ]; then
        print_warning "Current limit: $current_limit (need $required)"
        print_status "Run: ulimit -n $required"
        ulimit -n $required 2>/dev/null || print_warning "Failed to raise ulimit (may need sudo)"
    else
        print_success "File limits OK: $current_limit"
    fi
}

# ============================================
# REPROXY DAEMON MANAGEMENT
# ============================================

reproxy_running() {
    [ -S "${RBE_SOCKET}" ] && [ ! -z "$(pgrep -f 'reproxy.*server_address' 2>/dev/null)" ]
}

start_reproxy() {
    print_status "Starting reproxy daemon..."
    
    # Kill any existing reproxy instances
    if reproxy_running; then
        print_warning "reproxy already running, restarting..."
        pkill -f 'reproxy.*server_address' 2>/dev/null || true
        sleep 1
    fi
    
    # Remove stale socket
    rm -f "${RBE_SOCKET}"
    
    # Extract API key from header for environment variable
    local api_key="${RBE_remote_headers##*,}"
    
    # Start reproxy in background with minimal valid flags
    # Note: reproxy handles most config via environment variables, not command-line flags
    # Only pass what's absolutely necessary: server_address, service, log_dir, service_no_auth
    RBE_API_KEY="${api_key}" \
    "${RBE_BIN_DIR}/reproxy" \
        -server_address="unix://${RBE_SOCKET}" \
        -service="${RBE_service}" \
        -service_no_auth="${RBE_service_no_auth}" \
        -log_dir="${RBE_LOG_DIR}" \
        >> "${RBE_REPROXY_LOG}" 2>&1 &
    
    local reproxy_pid=$!
    print_status "reproxy PID: $reproxy_pid"
    
    # Wait for socket to appear
    print_status "Waiting for reproxy socket..."
    local wait_count=0
    while [ ! -S "${RBE_SOCKET}" ] && [ $wait_count -lt 10 ]; do
        sleep 0.5
        ((wait_count++))
    done
    
    if [ ! -S "${RBE_SOCKET}" ]; then
        print_error "reproxy socket not created after 5 seconds"
        print_error "reproxy PID $reproxy_pid may have crashed"
        print_status "Last 20 lines of reproxy.log:"
        tail -20 "${RBE_REPROXY_LOG}" 2>/dev/null || echo "(log not available)"
        return 1
    fi
    
    print_success "reproxy socket created: ${RBE_SOCKET}"
    
    # Verify reproxy is still running
    sleep 1
    if ! reproxy_running; then
        print_error "reproxy exited unexpectedly"
        print_status "Last 20 lines of reproxy.log:"
        tail -20 "${RBE_REPROXY_LOG}" 2>/dev/null || echo "(log not available)"
        return 1
    fi
    
    print_success "reproxy daemon online"
    return 0
}

stop_reproxy() {
    print_status "Stopping reproxy daemon..."
    
    if reproxy_running; then
        pkill -f 'reproxy.*server_address' 2>/dev/null || true
        sleep 1
        print_success "reproxy stopped"
    else
        print_warning "reproxy not running"
    fi
    
    rm -f "${RBE_SOCKET}"
}

# ============================================
# DIAGNOSTICS
# ============================================

print_diagnostics() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  RBE CONFIGURATION & STATUS${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    
    print_status "BuildBuddy Setup:"
    echo "  Instance: buildbuddy.io"
    echo "  Dashboard: https://buildbuddy.io"
    echo "  RBE Backend: ${RBE_service}"
    echo ""
    
    print_status "Local Configuration:"
    echo "  RBE Directory: ${RBE_DIR}"
    echo "  Reclient Binary: ${RBE_BIN_DIR}"
    echo "  reproxy Socket: ${RBE_SOCKET}"
    echo "  Parallel Jobs: ${NINJA_REMOTE_NUM_JOBS}"
    echo ""
    
    print_status "Daemon Status:"
    if reproxy_running; then
        local reproxy_pid=$(pgrep -f 'reproxy.*server_address' | head -1)
        echo "  reproxy: ${GREEN}RUNNING${NC} (PID: $reproxy_pid)"
        echo "  Socket: ${GREEN}EXISTS${NC}"
    else
        echo "  reproxy: ${RED}NOT RUNNING${NC}"
        echo "  Socket: ${RED}NOT FOUND${NC}"
    fi
    echo ""
    
    print_status "File Limits:"
    echo "  Open Files: $(ulimit -n)"
    echo ""
    
    print_status "Logs:"
    echo "  reproxy log: ${RBE_REPROXY_LOG}"
    echo "  reclient log: ${RBE_RECLIENT_LOG}"
    echo ""
    
    print_status "Cache:"
    local cache_size=$(du -sh "${RBE_CACHE_DIR}" 2>/dev/null | cut -f1)
    echo "  Location: ${RBE_CACHE_DIR}"
    echo "  Size: ${cache_size:-0B}"
    echo ""
}

# ============================================
# TROUBLESHOOTING
# ============================================

show_troubleshooting() {
    echo ""
    echo -e "${YELLOW}Troubleshooting Tips:${NC}"
    echo ""
    echo "1. Check reproxy logs:"
    echo "   tail -f ${RBE_REPROXY_LOG}"
    echo ""
    echo "2. Verify socket connectivity:"
    echo "   nc -zU ${RBE_SOCKET} && echo 'Socket OK' || echo 'Socket DOWN'"
    echo ""
    echo "3. Monitor build with RBE:"
    echo "   time m -j$(nproc) 2>&1 | tee build.log"
    echo ""
    echo "4. Check BuildBuddy invocations:"
    echo "   https://buildbuddy.io/invocation/"
    echo ""
    echo "5. Stop reproxy manually:"
    echo "   pkill -f 'reproxy.*server_address'"
    echo ""
}

# ============================================
# MAIN INITIALIZATION
# ============================================

main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  Enhanced RBE Configuration for BuildBuddy${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Pre-startup checks
    if ! check_binaries; then
        print_error "Reclient binaries not found. Cannot continue."
        return 1
    fi
    echo ""
    
    check_file_limits
    echo ""
    
    # Check API key but don't fail (warn only)
    check_api_key || print_warning "Continuing with current configuration..."
    echo ""
    
    # Start reproxy
    if ! start_reproxy; then
        print_error "Failed to start reproxy. See logs above."
        return 1
    fi
    echo ""
    
    # Show status
    print_diagnostics
    show_troubleshooting
    
    print_success "RBE is ready!"
    echo ""
}

# ============================================
# EXPORT CLEANUP FUNCTION
# ============================================

# Trap EXIT to gracefully stop reproxy when shell exits
trap 'print_status "Shutting down RBE..."; stop_reproxy' EXIT

# ============================================
# RUN INITIALIZATION
# ============================================

main "$@"
