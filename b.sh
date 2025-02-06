
sudo apt-get update
sudo apt-get install -y ccache
export USE_CCACHE=1
rm -rf .repo/local_manifests 
repo init --depth=1 --no-repo-verify -u https://github.com/crdroidandroid/android.git -b 14.0 -g default,-mips,-darwin,-notdefault
git clone https://github.com/aosp-realm/android_build_manifest.git -b apollo-cr14 .repo/local_manifests
/opt/crave/resync.sh
source build/envsetup.sh
#brunch apollo

rm -rf scripts
git clone https://github.com/xc112lg/scripts.git -b cd10
chmod u+x scripts/sync.sh
bash scripts/sync.sh




