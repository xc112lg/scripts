echo "🔧 Applying FMR core fix..."

patch -p1 << 'EOF'
--- a/packages/apps/RevampedFMRadio/jni/fmr/fmr_core.cpp
+++ b/packages/apps/RevampedFMRadio/jni/fmr/fmr_core.cpp
@@ -70,8 +70,6 @@ int FMR_get_cfgs(int idx)

 int FMR_chk_cfg_data(int idx __unused)
 {
-    int ret = 0;
-
     //TODO Need check? how to check?
     return 0;
 }
EOF

# Apply it in your build script before compiling
patch -p1 < fix-fmr-core.patch
