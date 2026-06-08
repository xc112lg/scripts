sed -i '/alias patch='\''patch --force'\''/d;/alias repo-init='\''repo init --depth=1'\''/d' ~/.bashrc
 
# Define aliases directly in current shell
alias patch='patch --force'
alias repo-init='repo init --depth=1'
 
# Also add to bashrc for future sessions
cat >> ~/.bashrc << 'EOF'
 
# Custom aliases
alias patch='patch --force'
alias repo-init='repo init --depth=1'
EOF
 
# Test if aliases work
echo "Testing aliases:"
type patch
type repo-init
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
