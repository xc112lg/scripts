#!/bin/bash
which repo

sudo curl -o /usr/bin/repo https://storage.googleapis.com/git-repo-downloads/repo
sudo chmod +x /usr/bin/repo


## Remove existing build artifactsa
if [ "$DELZIP" == "delzip" ]; then
    rm -rf out/target/product/*/*.zip
fi

#git clean -fdX
#rm -rf frameworks/base/
rm -rf .repo/local_manifests
#rm -rf device/lge/
#rm -rf kernel/lge/msm8996
mkdir -p .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests

/opt/crave/resync.sh





# source scripts/fixes.sh
# source scripts/signed.sh
export USE_CCACHE=1
source build/envsetup.sh
brunch h872




