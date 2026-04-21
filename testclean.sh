

sed -i '/\/fpsgo/d' $(grep -rl fpsgo device/ vendor/)
sed -i '/\/mtkfb/d' $(grep -rl mtkfb device/ vendor/)
sed -i '/\/ion\//d' $(grep -rl 'genfscon debugfs "/ion' device/ vendor/)
sed -i '/dynamic_debug/d' $(grep -rl dynamic_debug device/ vendor/)
sed -i '/kmemleak/d' $(grep -rl kmemleak device/ vendor/)
rm -rf out/soong/.intermediates/system/sepolicy
export NINJA_ARGS="-j2 -l2"
source build/envsetup.sh
lunch lineage_blossom-bp4a-eng
make sepolicy -j2
