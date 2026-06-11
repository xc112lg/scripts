
rm -rf .repo/local_manifests/
rm -rf device/xiaomi
rm -rf TMP_PATCHES
sudo apt update
sudo apt install patchelf -y
rm -rf .repo/local_manifests
repo init -u https://github.com/Lunaris-AOSP/android -b 16.2 --depth=1 --git-lfs
git clone https://github.com/xc112lg/local_manifests.git -b lunaris .repo/local_manifests
repo sync -c -j32 --force-sync --no-clone-bundle --no-tags
/opt/crave/resync.sh
. build/envsetup.sh
export WITH_GMS=false
lunch lineage_blossom-bp4a-eng
m installclean
m bacon

curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/lunaris/tar.sh  | bash
