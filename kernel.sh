#!/bin/bash
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | xargs)
    echo "✓ Loaded .env from current directory"
elif [ -f ../.env ]; then
    export $(cat ../.env | grep -v '#' | xargs)
    echo "✓ Loaded .env from parent directory"
else
    echo "⚠ .env file not found"
fi
rm -rf sashimi_kernel_xiaomi_blossom
rm -rf android_device_xiaomi_blossom-kernel
git clone https://github.com/zyexro/sashimi_kernel_xiaomi_blossom -b sashimi --depth 1
cd sashimi_kernel_xiaomi_blossom 
sed -i.backup '/^extern unsigned int gCapturePriLayerEnable;/i\
/* Forward declaration and struct definition for dprec_logger_event */\
struct dprec_logger {\
\	unsigned long long period_frame;\
\	unsigned long long period_total;\
\	unsigned long long period_max_frame;\
\	unsigned long long period_min_frame;\
\	unsigned long long ts_start;\
\	unsigned long long ts_trigger;\
\	unsigned long long count;\
};\
\
struct dprec_logger_event {\
\	int8_t name[24];\
\	unsigned int mmp;\
\	uint32_t level;\
\	struct dprec_logger logger;\
};\
' drivers/misc/mediatek/video/mt6765/dispsys/display_recorder.h

grep -n "struct dprec_logger_event" \
  drivers/misc/mediatek/video/mt6765/dispsys/display_recorder.h


curl -L https://github.com/xc112lg/sashimi_kernel_xiaomi_blossom/commit/a571172d38b2f706f3b21a8a0e3543c42d4bd2a6.patch | git am
wget -O buildneutron1.sh https://raw.githubusercontent.com/xc112lg/extremeNiigo/refs/heads/yoka_rb1/buildneutron1.sh
chmod +x buildneutron1.sh
. buildneutron1.sh
cd ..
git clone  https://$GH_TOKEN@github.com/xc112lg/android_device_xiaomi_blossom-kernel -b main
mv sashimi_kernel_xiaomi_blossom/newkernel/dtb.img android_device_xiaomi_blossom-kernel
mv sashimi_kernel_xiaomi_blossom/newkernel/kernel android_device_xiaomi_blossom-kernel
cd android_device_xiaomi_blossom-kernel
git add .
git commit -m "newkernel"
git push
