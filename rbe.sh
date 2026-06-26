#!/bin/bash
# ============================================================================
# RBE CONFIGURATION FOR YOUR BUILDBUDDY INSTANCE (AOSP RECLIENT COMPATIBLE)
# Based on your .bazelrc showing: app.buildbuddy.io and remote.buildbuddy.io
# ============================================================================

echo "=== Your BuildBuddy Configuration ==="
echo ""
echo "Instance: buildbuddy.io (self-hosted)"
echo "Dashboard: https://buildbuddy.io"
echo "RBE Backend: grpcs://remote.buildbuddy.io"
echo ""

# ============================================
# BUILDBUDDY CONFIGURATION (YOUR SETUP)
# ============================================

# Your RBE service endpoint (gRPC with TLS)
export RBE_service="remote.buildbuddy.io:443"

# FIX: Reclient requires a comma ',' separating the key and value for headers
export RBE_remote_headers="x-buildbuddy-api-key,NF5nEUUyU7LIy2QkkIIe"

# TLS enabled
export RBE_use_rpc_credentials=true

# Require authentication
export RBE_service_no_auth=false

# ============================================
# AOSP / BUILDBUDDY PLATFORM & BINARY MAPPINGS
# ============================================

# Informs BuildBuddy workers which environment container to pull for remote tasks
export RBE_PLATFORM="container-image=docker://gcr.io/cloud-marketplace/google/rbe-ubuntu18-04@sha256:6346552230ab057cf5bc8da39b56f8742ca2c63f10f60710fc39c8901b0b72f4,OSFamily=Linux"

# Tells the AOSP build system where your reclient binaries are stored
export RBE_BIN_DIR="prebuilts/remoteexecution-client/live"

# ============================================
# RBE CORE SETTINGS (64GB RAM OPTIMIZED)
# ============================================
export USE_RBE=1
export RBE_DIR="rbe1"

# Correct for 64GB RAM
export NINJA_REMOTE_NUM_JOBS=400

# Create isolation directories for local tracking state
mkdir -p "${RBE_DIR}/logs"
mkdir -p "${RBE_DIR}/cache"

# Creates explicit runtime socket tracking paths for the reproxy background daemon
export RBE_server_address="unix://${RBE_DIR}/reproxy.sock"
export RBE_log_dir="${RBE_DIR}/logs"

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
# RESOURCE POOLS
# ============================================
export RBE_JAVA_POOL=default
export RBE_METALAVA_POOL=default
export RBE_LINT_POOL=default

# ============================================
# TIMEOUTS (Optimized for 64GB RAM)
# ============================================
export RBE_exec_timeout=20m
export RBE_reclient_timeout=120m

# ============================================
# CACHING
# ============================================
export RBE_cache_dir="${RBE_DIR}/cache"
export RBE_enable_local_cache=1
export RBE_batch_downloads=true

# ============================================
# LOGGING
# ============================================
export RBE_LOG=INFO
export RBE_VERBOSE=0

# ============================================
# VERIFICATION
# ============================================
echo "✓ Configuration for buildbuddy.io"
echo "  RBE Service: ${RBE_service}"
echo "  Dashboard: https://buildbuddy.io"
echo "  Parallel Jobs: ${NINJA_REMOTE_NUM_JOBS}"
echo ""
echo "⚠️  NEXT STEPS:"
echo "  1. Verify the paths match your workspace tree:"
echo "     ls ${RBE_BIN_DIR}/reproxy"
echo ""
echo "  2. Elevate your local file limits to match configuration:"
echo "     ulimit -n 10000"
echo ""
echo "  3. Source this configuration inside your terminal profile:"
echo "     source $(basename "$BASH_SOURCE")"
echo ""
echo "  4. Execute compilation wrapper:"
echo "     time m"
echo ""
echo "  5. Track your stream:"
echo "     https://buildbuddy.io/invocation/"

echo "✓ RBE optimized configuration loaded"
