## Cam fix for LG G6 and delete some line cause im stupid.
cd frameworks/base/
git reset --hard
cd ../../

# Mixer: adjust input volume levelsa
cd device/lge/g6-common
git reset --hard
cd ../../../

cd kernel/lge/msm8996
# Fix LTO
git reset --hard
cd ../../../

#some fixes will be push to source fter testingg
cd device/lge/msm8996-common
git reset --hard
cd ../../../

cd packages/apps/Updater
git reset --hard
cd ../../../

cd vendor/lineage/
git reset --hard @{u}
cd ../../




