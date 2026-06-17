
if ls out/target/product/*/*.zip >/dev/null 2>&1; then
export GH_TOKEN=$(cat gh_token.txt)
rm -rf blossom_lunaris
git clone https://$GH_TOKEN@github.com//xc112lg/blossom_lunaris

#cd -
#rm -rf blossom_lunaris/*.img blossom_lunaris/*.zip blossom_lunaris/*.tar
#cp out/target/product/*/recovery.img blossom_lunaris
#cp out/target/product/*/*.zip blossom_lunaris/
echo "test" > blossom_lunaris/dummy.txt

# Create the zip
zip -q blossom_lunaris/test.zip blossom_lunaris/dummy.txt

# Check size
ls -lh blossom_lunaris/test.zip
cp out/target/product/*/*.tar blossom_lunaris
cd blossom_lunaris
chmod +x multi_upload1.sh
./multi_upload1.sh
else
    exit 1
fi
