




# rm -rf .repo/local_manifests/
# rm -rf device/lge
# rm -rf vendor/lge/msm8996-common kernel/lge/msm8996
# rm -rf vendor/evolution-priv/keys
# #rm -rf out/target/product/*/obj/KERNEL_OBJ

# #repo init -u https://github.com/crdroidandroid/android.git -b 16.0 --depth=1 --git-lfs
# #repo init -u https://github.com/Evolution-X/manifest -b bka --git-lfs --depth=1
# repo init -u https://github.com/crdroidandroid/android.git -b 15.0 --git-lfs --depth=1
# git clone https://github.com/xc112lg/local_manifests --depth 1 -b lg .repo/local_manifests
# repo sync -c -j64 --force-sync --no-clone-bundle --no-tags
#/opt/crave/resync.sh
source <(curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/lunaris/rbe8.sh)


# source build/envsetup.sh
# lunch lineage_h872-bp1a-userdebug
# m libicui18n 2>&1 | tee /tmp/rbe_test.log

# # 3. Check the result
# if grep -q "Unauthenticated" /tmp/rbe_test.log; then
#   echo "❌ Still failing to authenticate with RBE"
# else
#   echo "✅ No auth errors — RBE is authenticating correctly"
# fi
# grep "RBE Stats" /tmp/rbe_test.log

# 1. Create a trivial test file
mkdir -p /tmp/rbe_test && cd /tmp/rbe_test
echo 'int main() { return 0; }' > test.c

# 2. First run — should write to cache (cache MISS, uploads bytes)
prebuilts/remoteexecution-client/buildbuddyfix/rewrapper \
  --canonicalize_working_dir \
  --labels=type=compile,lang=cpp,compiler=clang \
  --exec_strategy=remote \
  --platform=container-image=docker://gcr.io/androidbuild-re-dockerimage/android-build-remoteexec-image@sha256:1eb7f64b9e17102b970bd7a1af7daaebdb01c3fb777715899ef462d6c6d01a45,Pool=default \
  -- \
  prebuilts/clang/host/linux-x86/clang-r536225/bin/clang++ -c test.c -o test.o

echo "--- First run done, checking output ---"
ls -la test.o

# 3. Delete output, run again — should be a cache HIT (fast, downloads instead of recompiling)
rm -f test.o
time prebuilts/remoteexecution-client/buildbuddyfix/rewrapper \
  --canonicalize_working_dir \
  --labels=type=compile,lang=cpp,compiler=clang \
  --exec_strategy=remote \
  --platform=container-image=docker://gcr.io/androidbuild-re-dockerimage/android-build-remoteexec-image@sha256:1eb7f64b9e17102b970bd7a1af7daaebdb01c3fb777715899ef462d6c6d01a45,Pool=default \
  -- \
  prebuilts/clang/host/linux-x86/clang-r536225/bin/clang++ -c test.c -o test.o

ls -la test.o

