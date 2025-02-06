
sudo apt-get update
sudo apt-get install -y ccache
export USE_CCACHE=1
which repo

sudo curl -o /usr/bin/repo https://storage.googleapis.com/git-repo-downloads/repo
sudo chmod +x /usr/bin/repo


rm -rf .repo/local_manifests/ 
repo init -u https://github.com/crdroidandroid/android.git -b 14.0 --git-lfs 
git clone https://github.com/iamrh1819/local_manifests --depth 1 -b A14-NF .repo/local_manifests && # Sync the repositories if [ -f /usr/bin
/opt/crave/resync.sh 
source build/envsetup.sh 
brunch a30s user
#brunch apollo

rm -rf scripts
git clone https://github.com/xc112lg/scripts.git -b cd10
chmod u+x scripts/sync.sh
bash scripts/sync.sh




