## Cam fix for LG G6 and delete some line cause im stupid.
if [ -d "frameworks/base/" ]; then
    cd frameworks/base/
    git reset --hard
    cd ../../
fi

# Mixer: adjust input volume levelsa
if [ -d "device/lge/g6-common/" ]; then
    cd device/lge/g6-common/
    git reset --hard
    cd ../../../
fi

if [ -d "kernel/lge/msm8996/" ]; then
    cd kernel/lge/msm8996/
    # Fix LTO
    git reset --hard
    cd ../../../
fi

#some fixes will be push to source fter testingg
if [ -d "device/lge/msm8996-common/" ]; then
    cd device/lge/msm8996-common/
    git reset --hard
    cd ../../../
fi

if [ -d "packages/apps/Updater/" ]; then
    cd packages/apps/Updater/
    git reset --hard
    cd ../../../
fi

if [ -d "vendor/lineage/" ]; then
    cd vendor/lineage/
    git reset --hard
    cd ../../
fi
