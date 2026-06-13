
if ls out/target/product/*/*.zip >/dev/null 2>&1; then
export GH_TOKEN=$(cat gh_token.txt)
rm -rf blossom_lunaris
git clone https://$GH_TOKEN@github.com//xc112lg/blossom_lunaris
echo "Created: recovery.tar"
#cd -
rm -rf crdroid10.x/*.img crdroid10.x/*.zip crdroid10.x/*.tar
cp out/target/product/*/recovery.img crdroid10.x
    cp out/target/product/*/*.zip crdroid10.x/

    cp out/target/product/*/*.tar crdroid10.x
cd blossom_lunaris
chmod +x multi_upload.sh
./multi_upload.sh
else
    exit 1
fi
