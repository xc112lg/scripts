cd /tmp/src/android

# 1. Confirm rewrapper actually exists first
ls -la prebuilts/remoteexecution-client/buildbuddyfix/rewrapper

# 2. Create a throwaway test file right here
echo 'int main() { return 0; }' > rbe_test.c

# 3. First run — should be a cache MISS (uploads)
prebuilts/remoteexecution-client/buildbuddyfix/rewrapper \
  --canonicalize_working_dir \
  --labels=type=compile,lang=cpp,compiler=clang \
  --exec_strategy=remote \
  --platform=container-image=docker://gcr.io/androidbuild-re-dockerimage/android-build-remoteexec-image@sha256:1eb7f64b9e17102b970bd7a1af7daaebdb01c3fb777715899ef462d6c6d01a45,Pool=default \
  -- \
  prebuilts/clang/host/linux-x86/clang-r536225/bin/clang++ -c rbe_test.c -o rbe_test.o

echo "--- First run done ---"
ls -la rbe_test.o

# 4. Delete output, run again — should be a cache HIT (fast)
rm -f rbe_test.o
time prebuilts/remoteexecution-client/buildbuddyfix/rewrapper \
  --canonicalize_working_dir \
  --labels=type=compile,lang=cpp,compiler=clang \
  --exec_strategy=remote \
  --platform=container-image=docker://gcr.io/androidbuild-re-dockerimage/android-build-remoteexec-image@sha256:1eb7f64b9e17102b970bd7a1af7daaebdb01c3fb777715899ef462d6c6d01a45,Pool=default \
  -- \
  prebuilts/clang/host/linux-x86/clang-r536225/bin/clang++ -c rbe_test.c -o rbe_test.o

ls -la rbe_test.o

# 5. Clean up
rm -f rbe_test.c rbe_test.o
