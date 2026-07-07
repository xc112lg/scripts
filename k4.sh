#!/bin/bash

# ---- AnyKernel3 config (edit as needed for your device fork/branch) ----
ANYKERNEL_REPO="https://github.com/osm0sis/AnyKernel3"
ANYKERNEL_BRANCH="master"
KERNEL_ZIP_NAME="sashimi_kernel_blossom_$(date +%Y%m%d_%H%M).zip"

# Packages the compiled kernel + dtb.img from newkernel/ into a flashable
# AnyKernel3 zip. Run this from the same directory as this script, after
# sashimi_kernel_xiaomi_blossom/newkernel/{kernel,dtb.img} exist.
package_anykernel3() {
    local KERNEL_DIR="sashimi_kernel_xiaomi_blossom/newkernel"

    if [ ! -f "$KERNEL_DIR/kernel" ] || [ ! -f "$KERNEL_DIR/dtb.img" ]; then
        echo "✗ Missing kernel or dtb.img in $KERNEL_DIR — build step may have failed"
        return 1
    fi

    rm -rf AnyKernel3
    git clone "$ANYKERNEL_REPO" -b "$ANYKERNEL_BRANCH" --depth 1 AnyKernel3 || {
        echo "✗ Failed to clone AnyKernel3"
        return 1
    }

    cp "$KERNEL_DIR/kernel" AnyKernel3/Image
    cp "$KERNEL_DIR/dtb.img" AnyKernel3/dtb

    (
        cd AnyKernel3 || exit 1
        rm -rf .git
        zip -r9 "../$KERNEL_ZIP_NAME" . -x ".git*"
        cd -
    )

    if [ -f "$KERNEL_ZIP_NAME" ]; then
        echo "✓ Built flashable zip: $KERNEL_ZIP_NAME"
    else
        echo "✗ Zip creation failed"
        return 1
    fi
}

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
rm -rf nn
git clone https://github.com/zyexro/sashimi_kernel_xiaomi_blossom -b sashimi --depth 1
cd sashimi_kernel_xiaomi_blossom 
curl -L https://github.com/xc112lg/sashimi_kernel_xiaomi_blossom/commit/f8717ce1b4ec2c1195deccbe2365369379be538f.patch | git am
curl -L https://github.com/xc112lg/sashimi_kernel_xiaomi_blossom/commit/ed4cf13defccb54cbb67567a578ed55207bb692d.patch | git am

curl -L https://github.com/xc112lg/sashimi_kernel_xiaomi_blossom/commit/a571172d38b2f706f3b21a8a0e3543c42d4bd2a6.patch | git am
wget -O buildneutron1.sh https://raw.githubusercontent.com/xc112lg/extremeNiigo/refs/heads/yoka_rb1/buildneutron1.sh
chmod +x buildneutron1.sh
. buildneutron1.sh
cd ..

package_anykernel3

git clone  https://$GH_TOKEN@github.com/xc112lg/nn
mv sashimi_kernel_xiaomi_blossom/newkernel/dtb.img nn
mv sashimi_kernel_xiaomi_blossom/newkernel/kernel nn
mv *.zip nn
cd nn
git add .
git commit -m "newkernel"
git push
