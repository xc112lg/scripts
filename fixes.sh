cd system/sepolicy
git fetch https://github.com/LineageOS/android_system_sepolicy.git refs/changes/91/375191/3/
git cherry-pick cbda51f2df0fb7c7d7154ea218c9eaf7ce99083b^..8a8da2b5e8a86d2f7fa06ac9f69f97a23e36fd74
cd ../../