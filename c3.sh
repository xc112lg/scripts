cat >> ~/.bashrc << 'EOF'
 
# Smart patch function - uses --force only when patch prompts for yes/no
patch() {
  # Try patch normally first
  local output
  output=$(command patch "$@" 2>&1)
  local exit_code=$?
  
  # If patch asks for input (contains "Apply hunk?" or similar), retry with --force
  if echo "$output" | grep -qE "(Apply hunk|apply this hunk|\[y/n\]|Apply patch|Hunk|\?)" && [ $exit_code -ne 0 ]; then
    echo "$output"
    echo "Patch needs confirmation, retrying with --force..."
    command patch --force "$@"
  else
    echo "$output"
    return $exit_code
  fi
}
 
# Custom repo function - use --depth=1 for init
repo() {
  if [ "$1" = "init" ]; then
    shift
    command repo init --depth=1 "$@"
  else
    command repo "$@"
  fi
}
EOF
 
source ~/.bashrc

# Verify functions are set
echo "Functions configured:"
declare -f patch | head -3
declare -f repo | head -5
type patch
rm -rf .repo/local_manifests/  && # Clone local_manifests repository
repo init -u https://github.com/Lunaris-AOSP/android -b 16.2 --git-lfs --depth=1
 git clone https://github.com/ardiandideyashidiq/local_manifest-P13001L --depth 1 -b lineage-23.2 .repo/local_manifests && 
repo sync -c -j32 --force-sync --no-clone-bundle --no-tags
# Sync the repositories
 
if [ -f /usr/bin/resync ]
 
 then
 
  /usr/bin/resync # For compatibility with Omansh's Docker image 
 
else
 
  /opt/crave/resync.sh
 
fi && 
 
# Set up build environment
 
export BUILD_USERNAME=ardiandideyashidiq 
 
 export BUILD_HOSTNAME=crave 
 
 source build/envsetup.sh && 
 
echo Repository: ardiandideyashidiq/crave_aosp_builder
 
 echo Run ID: 26355419836
 
 
 
# Build the ROM
 
breakfast P13001L user && make installclean && mka bacon
