#!/bin/bash



#repo init -u https://github.com/LineageOS/android.git -b lineage-21.0 --git-lfs




rm -rf .repo/local_manifests device/lge/msm8996-common
mkdir -p .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests



/opt/crave/resync.sh

cd build/make
ls
git reset --hard
cd -
ls



sed -i '0,/echo "including \$f"; \. "\$T\/\$f"/ s|echo "including \$f"; \. "\$T\/\$f"|echo "vendorsetup.sh is not allowed, skipping changes"; exit 1|' build/envsetup.sh




source build/envsetup.sh

# lunch lineage_h872-ap2a-eng
# m installclean
# m bacon


breakfast h872
brunch h872 eng
