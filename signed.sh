#!/bin/bash

if [ -d ~/.android-certs/ ]; then
echo "key already exist"

else
    subject='/C=PH/ST=Philippines/L=Manila/O=Rex H/OU=Rex H/CN=Rex H/emailAddress=rexc1835@gmail.com'
mkdir ~/.android-certs

for x in releasekey platform shared media networkstack testkey cyngn-priv-app bluetooth sdk_sandbox verifiedboot; do 
    yes "" | ./development/tools/make_key ~/.android-certs/$x "$subject"
done

mkdir vendor/extra
mkdir vendor/lineage-priv/keys

mv ~/.android-certs vendor/extra/keys
#For Lineage 21 and newer use the command below if not then use above 
#mv ~/.android-certs vendor/lineage-priv/keys
echo "PRODUCT_DEFAULT_DEV_CERTIFICATE := vendor/extra/keys/releasekey" > vendor/extra/product.mk
#For Lineage 21 and newer use the command below if not then use above
#echo "PRODUCT_DEFAULT_DEV_CERTIFICATE := vendor/lineage-priv/keys/releasekey" > vendor/lineage-priv/keys/keys.mk

fi

printf 'filegroup(\n    name = "android_certificate_directory",\n    srcs = glob([\n        "*.pk8",\n        "*.pem",\n    ]),\n    visibility = ["//visibility:public"],\n)\n' > BUILD.bazel

