#!/bin/bash
rm -rf vendor/lineage-priv/keys

git clone https://$GH_TOKEN@github.com/xc112lg/key vendor/lineage-priv/keys

grep -qxF 'include vendor/lineage-priv/keys/keys.mk' device/xiaomi/sm8150-common/msmnile.mk || echo 'include vendor/lineage-priv/keys/keys.mk' >> device/xiaomi/sm8150-common/msmnile.mk





