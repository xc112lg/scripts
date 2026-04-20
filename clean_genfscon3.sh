#!/bin/bash

echo "[*] Cleaning vendor genfscon (MTK-safe mode)..."
# remove ALL debugfs
sed -i '/genfscon debugfs/d' vendor -R

# remove ALL /proc/sys (CRITICAL)
sed -i '/genfscon proc "\/sys/d' vendor -R

# remove kernel tunables
sed -i '/genfscon proc "\/kernel/d' vendor -R
sed -i '/genfscon proc "\/vm/d' vendor -R

# Process all files containing genfscon
FILES=$(grep -rl "genfscon" vendor/ 2>/dev/null)

for f in $FILES; do
    echo "[*] Processing $f"
    

    # Keep ONLY MTK-specific / non-conflicting rules
    sed -i '
    /genfscon/ {
        # KEEP MTK-specific paths
        /mtk_/b keep
        /apusys/b keep
        /cpu_loading/b keep
        /cmdq/b keep
        /ged/b keep
        /gpufreq/b keep
        /mali/b keep
        /ion/b keep
        /vpu/b keep
        /mdp/b keep
        /m4u/b keep
        /ccci/b keep
        /wmt/b keep
        /bt_dbg/b keep
        /thermal/b keep
        /fpsgo/b keep
        /perfmgr/b keep

        # KEEP vendor-specific driver paths
        /driver\//b keep

        # OTHERWISE DELETE (conflicting with AOSP)
        d

        :keep
    }
    ' "$f"
done




echo "[✓] Done cleaning genfscon"
echo "[!] Backup saved at: vendor_backup_genfscon"
