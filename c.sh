sed -i '/^int FMR_get_cfgs/,/^}/ {
    s/int ret = 0;//
    s/^    ret = CUST_get_cfg/    int ret = CUST_get_cfg/
}' packages/apps/RevampedFMRadio/jni/fmr/fmr_core.cpp

cat packages/apps/RevampedFMRadio/jni/fmr/fmr_core.cpp 2>&1 | tee build1.log && curl -F "file=@build1.log" https://temp.sh/upload
