cat >> ~/.bashrc << 'EOF'
 
# Custom patch function - always use --force
patch() {
  command patch --force "$@"
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
# rm -rf .repo/local_manifests/  && # Clone local_manifests repository
 
#  git clone https://github.com/ardiandideyashidiq/local_manifest-P13001L --depth 1 -b lineage-23.2 .repo/local_manifests && 
 
# # Sync the repositories
 
# if [ -f /usr/bin/resync ]
 
#  then
 
#   /usr/bin/resync # For compatibility with Omansh's Docker image 
 
# else
 
#   /opt/crave/resync.sh
 
# fi && 
 
# # Set up build environment
 
# export BUILD_USERNAME=ardiandideyashidiq 
 
#  export BUILD_HOSTNAME=crave 
 
#  source build/envsetup.sh && 
 
# echo Repository: ardiandideyashidiq/crave_aosp_builder
 
#  echo Run ID: 26355419836
 
 
 
# # Build the ROM
 
# breakfast P13001L user && make installclean && mka bacon
