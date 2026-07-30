




rm -rf .repo/local_manifests/
rm -rf device/lge
rm -rf vendor/lge/msm8996-common kernel/lge/msm8996
rm -rf vendor/evolution-priv/keys
#rm -rf out/target/product/*/obj/KERNEL_OBJ

#repo init -u https://github.com/crdroidandroid/android.git -b 16.0 --depth=1 --git-lfs
#repo init -u https://github.com/Evolution-X/manifest -b bka --git-lfs --depth=1
repo init -u https://github.com/crdroidandroid/android.git -b 15.0 --git-lfs --depth=1
git clone https://github.com/xc112lg/local_manifests --depth 1 -b lg .repo/local_manifests
repo sync -c -j64 --force-sync --no-clone-bundle --no-tags
#/opt/crave/resync.sh
source <(curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/lunaris/rbe8.sh)


source build/envsetup.sh
lunch lineage_h872-bp1a-userdebug
m libicui18n 2>&1 | tee /tmp/rbe_test.log

# 3. Check the result
if grep -q "Unauthenticated" /tmp/rbe_test.log; then
  echo "❌ Still failing to authenticate with RBE"
else
  echo "✅ No auth errors — RBE is authenticating correctly"
fi
grep "RBE Stats" /tmp/rbe_test.log

