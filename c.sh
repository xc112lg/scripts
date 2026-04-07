sed -i '/^int FMR_get_cfgs/,/^}/ {
    s/int ret = 0;//
    s/^    ret = CUST_get_cfg/    int ret = CUST_get_cfg/
}' packages/apps/RevampedFMRadio/jni/fmr/fmr_core.cpp
sed -i '75d' packages/apps/RevampedFMRadio/jni/fmr/fmr_core.cpp

