  #!/bin/bash
# --- Optimized RBE Configuration for AOSP Builds ---
# Recommendations based on your current setup and performance best practices
rm -rf rbe1


rm -rf .repo/local_manifests/
rm -rf device/xiaomi
rm -rf kernel/xiaomi/blossom
rm -rf 
rm -rf TMP_PATCHES
#rm -rf frameworks/base
sudo apt update >/dev/null 2>&1
sudo apt install patchelf -y >/dev/null 2>&1
rm -rf .repo/local_manifests
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs --depth=1
git clone https://github.com/xc112lg/local_manifests.git -b lunaris .repo/local_manifests
repo sync -c -j32 --force-sync --no-clone-bundle --no-tags
/opt/crave/resync.sh
source <(curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/lunaris/rbe8.sh)  
. build/envsetup.sh
#export WITH_GMS=true
export WITH_GMS=false
# export WITH_GMS_COMMS_SUITE := false
# export WITH_PIXEL_LAUNCHER := false
# export TARGET_USE_GPHOTOS := false
# export TARGET_USE_WALLPAPERS := false
repo sync -c -j32 --force-sync --no-clone-bundle --no-tags build/make build/soong

# 1. Add the datetime import right after the contextlib import
sed -i '/^import contextlib$/a import datetime' build/soong/scripts/gen_build_prop.py

# 2. Replace the two subprocess-based date calls with pure-Python datetime
sed -i \
  -e 's|  config\["Date"\] = subprocess\.check_output(\["date", "-d", f"@{raw_date}"\], text=True)\.strip()|  dt = datetime.datetime.fromtimestamp(int(raw_date), tz=datetime.timezone.utc)\n  config["Date"] = dt.strftime("%a %b %e %H:%M:%S UTC %Y")|' \
  -e 's|  config\["DateUtc"\] = subprocess\.check_output(\["date", "-d", f"@{raw_date}", "+%s"\], text=True)\.strip()|  config["DateUtc"] = str(int(raw_date))|' \
  build/soong/scripts/gen_build_prop.py

export TARGET_USES_PICO_GAPPS=true
export TARGET_INCLUDE_VIA=true
export TARGET_INCLUDE_REVAMPED=true
sed -i '$a -include vendor/evolution-priv/keys/keys.mk' device/xiaomi/blossom/lineage_blossom.mk
#sed -i '\|vendor/extras/prebuilt/product/fonts,\$(TARGET_COPY_OUT_PRODUCT)/fonts|d' vendor/extras/evolution.mk
#sed -i '/<item>com.android.nfc<\/item>/d' frameworks/base/core/res/res/values/policy_exempt_apps.xml
#cat frameworks/base/core/res/res/values/policy_exempt_apps.xml

export RBE_LOG=DEBUG
export RBE_VERBOSE=1

lunch lineage_blossom-bp4a-user
m installclean
#m clean #once
m bacon -j64

curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/blossom/upevo.sh | bash >/dev/null 2>&1
