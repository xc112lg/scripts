#!/bin/bash



rm -rf .repo/local_manifests
rm -rf frameworks/base/
mkdir -p .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests

mkdir -p rbe  # Ensure the target directory exists

ZIP_URL=$(wget -qO- "https://chrome-infra-packages.appspot.com/p/infra/rbe/client/linux-amd64/+/latest" | grep -Eo 'https://[^"]+\.zip' | head -n 1)

# Check if a URL was found
if [[ -n "$ZIP_URL" ]]; then
    echo "Downloading from: $ZIP_URL"
    wget -O rbe_client.zip "$ZIP_URL"
    echo "Download completed: rbe_client.zip"
else
    echo "Error: Could not find the download link."
    exit 1
fi

unzip -o rbe_client.zip -d rbe  # Extract and overwrite if needed



export USE_RBE=1                                      
export RBE_DIR="rbe"                      # Path to the extracted reclient directory (relative or absolute)
export NINJA_REMOTE_NUM_JOBS=300                        # Number of parallel remote jobs (adjust based on your RAM, buildbuddy has 80 CPU cores in the free tier)

# --- BuildBuddy Connection Settings ---
export RBE_service="remote.buildbuddy.io:443"        # BuildBuddy instance address (without grpcs://, add the port 443)
export RBE_remote_headers="x-buildbuddy-api-key=NF5nEUUyU7LIy2QkkIIe"    # Your BuildBuddy API key
export RBE_use_rpc_credentials=false                   
export RBE_service_no_auth=true                       

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




repo init -u https://github.com/crdroidandroid/android.git -b 15.0 --git-lfs --depth 1
/opt/crave/resync.sh 

source scripts/changes.sh
source scripts/signed.sh

source build/envsetup.sh
make installclean

breakfast vayu
brunch vayu


