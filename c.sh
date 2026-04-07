sed -i '
# Fix FMR_get_cfgs - remove unused ret declaration
/^int FMR_get_cfgs/,/^}/ {
    s/int ret = 0;//
    s/^    ret = CUST_get_cfg/    int ret = CUST_get_cfg/
}

# Fix FMR_init - remove unused ret variable
/^int FMR_init()/,/^}/ {
    s/int ret;//
    /ret = 0;/d
}

# Fix FMR_scan - remove double call and unused ret
/^int FMR_scan/,/^}/ {
    /fm_s32 ret/d
    s/ret = FMR_scan_Channels.*$/return FMR_scan_Channels(idx, scan_tbl, max_cnt, band_channel_no, Start_Freq, seek_space, NF_Space);/
}
' packages/apps/RevampedFMRadio/jni/fmr/fmr_core.cpp


cat packages/apps/RevampedFMRadio/jni/fmr/fmr_core.cpp 2>&1 | tee build1.log && curl -F "file=@build1.log" https://temp.sh/upload
