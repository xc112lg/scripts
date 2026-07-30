cd /tmp/src/android

# Source it directly so the RBE_* vars stick around in this shell
source <(curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/lunaris/rbe8.sh)
# (or if you have it saved locally: source rbe8.sh)

# Confirm the critical var is actually set now
echo "RBE_service=$RBE_service"

# Now retry the single-file test
echo 'int main() { return 0; }' > rbe_test.c

prebuilts/remoteexecution-client/buildbuddyfix/rewrapper \
  --canonicalize_working_dir \
  --labels=type=compile,lang=cpp,compiler=clang \
  --exec_strategy=remote \
  --platform=container-image=docker://gcr.io/androidbuild-re-dockerimage/android-build-remoteexec-image@sha256:1eb7f64b9e17102b970bd7a1af7daaebdb01c3fb777715899ef462d6c6d01a45,Pool=default \
  -- \
  prebuilts/clang/host/linux-x86/clang-r536225/bin/clang++ -c rbe_test.c -o rbe_test.o

echo "--- First run done ---"
ls -la rbe_test.o

rm -f rbe_test.o
time prebuilts/remoteexecution-client/buildbuddyfix/rewrapper \
  --canonicalize_working_dir \
  --labels=type=compile,lang=cpp,compiler=clang \
  --exec_strategy=remote \
  --platform=container-image=docker://gcr.io/androidbuild-re-dockerimage/android-build-remoteexec-image@sha256:1eb7f64b9e17102b970bd7a1af7daaebdb01c3fb777715899ef462d6c6d01a45,Pool=default \
  -- \
  prebuilts/clang/host/linux-x86/clang-r536225/bin/clang++ -c rbe_test.c -o rbe_test.o

ls -la rbe_test.o
rm -f rbe_test.c rbe_test.o
