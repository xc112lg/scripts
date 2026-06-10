# type patch
# rm -rf .repo/local_manifests/
# #rm -rf device/xiaomi
# #rm -rf TMP_PATCHES
# sudo apt update
# sudo apt install patchelf -y
# sudo apt install ccache -y
# mkdir tmp
# export CCACHE_DIR=tmp
# export USE_CCACHE=1
# rm -rf .repo/local_manifests
# repo init -u https://github.com/Lunaris-AOSP/android -b 16.2 --depth=1 --git-lfs
# git clone https://github.com/xc112lg/local_manifests.git -b lunaris .repo/local_manifests
# repo sync -c -j32 --force-sync --no-clone-bundle --no-tags
# /opt/crave/resync.sh
# . build/envsetup.sh
# export WITH_GMS=false
# # Add memory-saving flags
# export USE_NINJA=false  # Use Make instead of Ninja (more memory efficient)
# export ENABLE_CPUSTATS=false
# lunch lineage_blossom-bp4a-eng
# m installclean
# make sepolicy -j1



sudo apt update
sudo apt install patchelf -y
sudo apt install ccache -y
mkdir tmp
export CCACHE_DIR=tmp
export USE_CCACHE=1
. build/envsetup.sh
export WITH_GMS=false
 Force the system to use only 2 parallel compilation threads 

# Trigger the build specifically targeting sepolicy instead of the whole Android image

lunch lineage_blossom-bp4a-eng
m installclean
make sepolicy -j1



# Aggressively cap the Java Heap for both the Soong builder and Metalava compiler


# Trigger the build specifically targeting sepolicy instead of the whole Android image
m selinux_policy -j2


