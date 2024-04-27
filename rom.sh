#!/bin/bash

# Modify ROM prefix
modify_rom_prefix() {
  echo "Performing renaming for ${device}..."
  cd device/lge/${device}
  find . -not -path "*/.*" -name "*.mk" -type f -exec sed -i "s/aosp/${rom}/g" {} +
  mv aosp_${device}.mk ${rom}_${device}.mk
  echo "Successfully renamed prefix to ${rom}"

  cd ./../../../
}

# Clone KernelSU submodule
init_ksu() {
  cd kernel/lge/sdm845
  git submodule init
  git submodule update
  cd ./../../../
}

device_choice=4
device_arr=("judyln" "judyp" "judypn")
rom=lineage

if [ "${device_choice}" == 4 ]; then
  for ((i = 0; i < ${#device_arr[@]}; i++)); do
    device="${device_arr[$i]}"
    modify_rom_prefix
  done
else
  modify_rom_prefix
fi
init_ksu

cd build/make
git fetch github --unshallow
git fetch https://github.com/EAZYBLACK/cr_build.git 14.0
git cherry-pick 785f90c649dee54e2aeb769447cd5b913f8e9e2c
git cherry-pick d5ec62691b7821ccb19ebdd9c836916ffa869727
git cherry-pick 6e6d2ee61a60a76429b320a88fb7b5c8266fb3ac
cd ../..
echo SAR BACK

echo "Done!"
