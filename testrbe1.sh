

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

