#!/bin/bash

cd .repo/local_manifests
hals=("hardware/qcom-caf/sdm845/audio" "hardware/qcom-caf/sdm845/display" "hardware/qcom-caf/sdm845/media")

device_choice=4
device=("judyln" "judypn" "judyp")
newline="  <project path=\"device/lge/$device\" name=\"android_device_lge_$device\" remote=\"jlst\" />"
echo -e "\nEditing XML files..."

readarray -t file_lines < <(cat lge_sdm845.xml)
echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" | tee lge_sdm845.xml &> /dev/null
for ((i = 1; i < ${#file_lines[@]}-2; i++)); do
  echo "${file_lines[$i]}" | tee -a lge_sdm845.xml &> /dev/null
done

if [ "$device_choice" == 4 ]; then
  for codename in "${device[@]}"; do
    echo -e "  <project path=\"device/lge/$codename\" name=\"android_device_lge_$codename\" remote=\"jlst\" />" | tee -a lge_sdm845.xml &> /dev/null
  done
else
  echo -e "$newline" | tee -a lge_sdm845.xml &> /dev/null
fi

echo "</manifest>" | tee -a lge_sdm845.xml  &> /dev/null
echo "Finished!"

echo -e "--------------------------------------"

echo "Try to remove SDM845 CAF HALs from default manifests..."
cd ../manifests

for hal in ${hals[@]}; do
  IFS='/' read -r -a name <<< "$(echo $hal)"
  IFS=' ' read -r -a line <<< "$(grep -nir $hal)"
  IFS=':' read -r -a loc_info <<< $line
  sed -i "${loc_info[1]}s/.*/  <!-- SDM845 yeet ${name[-1]} -->/" ${loc_info[0]}
done

cd ../..

echo "Done!"
echo "Note: If you are not sure of the changes, double check the files."


