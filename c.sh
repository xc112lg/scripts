sed -i '/^int FMR_get_cfgs/,/^}/ { s/int ret = 0;//; s/^    ret = CUST_get_cfg/    int ret = CUST_get_cfg/; }; /^int FMR_init()/,/^}/ { /int ret;/d; /ret = 0;/d; }; /^int FMR_scan/,/^}/ { /fm_s32 ret;/d; /ret = FMR_scan_Channels.*$/d; s/return FMR_scan_Channels.*$/    return FMR_scan_Channels(idx, scan_tbl, max_cnt, band_channel_no, Start_Freq, seek_space, NF_Space);/; }' packages/apps/RevampedFMRadio/jni/fmr/fmr_core.cpp


cat packages/apps/RevampedFMRadio/jni/fmr/fmr_core.cpp 2>&1 | tee build1.log && curl -F "file=@build1.log" https://temp.sh/upload
