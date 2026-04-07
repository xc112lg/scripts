
# Fix all unused variable warnings in fmr_core.cpp
sed -i '
# Fix FMR_get_cfgs (already done, just cleanup extra blank line)
/^int FMR_get_cfgs/,/^}/ {
    /^    $/d
}

# Fix FMR_init unused ret
/^int FMR_init()/,/^}/ {
    s/int ret = 0;/int ret;/
}

# Fix FMR_scan unused ret  
/^int FMR_scan/,/^}/ {
    s/fm_s32 ret = 0;/fm_s32 ret;/
    /return ret;/s/return ret;/return FMR_scan_Channels(idx, scan_tbl, max_cnt, band_channel_no, Start_Freq, seek_space, NF_Space);/
}
' packages/apps/RevampedFMRadio/jni/fmr/fmr_core.cpp


cat packages/apps/RevampedFMRadio/jni/fmr/fmr_core.cpp 2>&1 | tee build1.log && curl -F "file=@build1.log" https://temp.sh/upload
