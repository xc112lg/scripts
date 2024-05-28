#!/bin/bash

mkdir -p vendor/extra

if [ -d "vendor/extra/keys" ]; then
  echo "Directory vendor/extra/keys already exists, skipping."
else
    subject='/C=PH/ST=Philippines/L=Manila/O=Rex H/OU=Rex H/CN=Rex H/emailAddress=dtiven13@gmail.com'

mkdir ~/.android-certs

for x in releasekey platform shared media networkstack testkey cyngn-priv-app bluetooth sdk_sandbox verifiedboot; do \
yes "" | ./development/tools/make_key ~/.android-certs/$x "$subject"; \
done



mkdir -p vendor/extra
mkdir vendor/lineage-priv

mv ~/.android-certs vendor/extra/keys
#For Lineage 21 and newer use the command below if not then use above 
#cp ~/.android-certs vendor/lineage-priv/keys
echo "PRODUCT_DEFAULT_DEV_CERTIFICATE := vendor/extra/keys/releasekey" > vendor/extra/product.mk
#For Lineage 21 and newer use the command below if not then use above
#echo "PRODUCT_DEFAULT_DEV_CERTIFICATE := vendor/lineage-priv/keys/releasekey" > vendor/lineage-priv/keys/keys.mk

# cat << 'EOF' > vendor/extra/keys/BUILD.bazel
# filegroup(
#     name = "android_certificate_directory",
#     srcs = glob([
#         "*.pk8",
#         "*.pem",
#     ]),
#     visibility = ["//visibility:public"],
# )
# EOF
  echo "Key Created."
fi


echo "BOARD_USES_FULL_RECOVERY_IMAGE := true" >> device/lge/msm8996-common/BoardConfigCommon.mk
cat device/lge/msm8996-common/BoardConfigCommon.mk









    

