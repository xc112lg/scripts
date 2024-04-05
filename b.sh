#!/bin/bash

 type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh -y

mkdir workspace && cd workspace
  git clone --depth=1 https://github.com/Jiovanni-dump/xiaomi_ishtar_dump -b missi_phone_global-user-13-TKQ1.221114.001-V14.0.1.0.TMAMIXM-release-keys ./firmware-dump
 cd /workspace
  git clone --depth=1 https://github.com/jacksproject/device_xiaomi_ishtar -b 13.0 ./android/device/ishtar/xiaomi_ultra_13

 cd /workspace
  git clone --depth=1 https://github.com/LineageOS/android_tools_extract-utils -b lineage-20.0 ./android/tools/extract-utils
  echo "Done cloning extract-utils."
  git clone --depth=1  https://github.com/LineageOS/android_prebuilts_extract-tools -b lineage-20.0 ./android/prebuilts/extract-tools
  echo "Done cloning extract-tools."

cd /workspace
  chmod a+x android/device/ishtar/xiaomi_ultra_13/setup-makefiles.sh
  cd android/device/ishtar/xiaomi_ultra_13/
  bash extract-files.sh ${GITHUB_WORKSPACE}/workspace/firmware-dump/
  echo "Done extracting and making files."
  echo "Pushing as repository now."