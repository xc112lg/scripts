#!/bin/bash





# # Download the latest version of repo
# curl -o repo https://storage.googleapis.com/git-repo-downloads/repo

# # Make the repo script executable
# chmod a+x repo

# # Move the repo script to the appropriate location
# sudo mv repo /usr/local/bin/repo

# # Verify the update
# repo --version


#repo init -u https://github.com/LineageOS/android.git -b lineage-21.0 --git-lfs




rm -rf .repo/local_manifests device/lge/msm8996-common
mkdir -p .repo/local_manifests
cp scripts/roomservice.xml .repo/local_manifests
#rm -rf ~/.android-certs


#/opt/crave/resync.sh
# main() {
#     # Run repo sync command and capture the output
#     repo sync -c -j20 --force-sync --no-clone-bundle --no-tags 2>&1 | tee /tmp/output.txt

#     # Check if there are any failing repositories
#     if grep -q "Failing repos:" /tmp/output.txt ; then
#         echo "Deleting failing repositories..."
#         # Extract failing repositories from the error message and echo the deletion path
#         while IFS= read -r line; do
#             # Extract repository name and path from the error message
#             repo_info=$(echo "$line" | awk -F': ' '{print $NF}')
#             repo_path=$(dirname "$repo_info")
#             repo_name=$(basename "$repo_info")
#             # Echo the deletion path
#             echo "Deleted repository: $repo_info"
#             # Save the deletion path to a text file
#             echo "Deleted repository: $repo_info" > deleted_repositories.txt
#             # Delete the repository
#             rm -rf "$repo_path/$repo_name"
#         done <<< "$(cat /tmp/output.txt | awk '/Failing repos:/ {flag=1; next} /Try/ {flag=0} flag')"

#         # Re-sync all repositories after deletion
#         echo "Re-syncing all repositories..."
#         repo sync -c -j20 --force-sync --no-clone-bundle --no-tags
#     else
#         echo "All repositories synchronized successfully."
#     fi
# }

# main $*


sed -i '0,/echo "including \$f"; \. "\$T\/\$f"/ s|echo "including \$f"; \. "\$T\/\$f"|echo "vendorsetup.sh is not allowed, skipping changes"|' build/envsetup.sh
cd build/make
ls
git reset --hard
cd -
ls





# source build/envsetup.sh
# #repopick -p 396073
# lunch lineage_h872-ap2a-eng
# m installclean
# m bacon


# # breakfast h872
# # brunch h872 eng
