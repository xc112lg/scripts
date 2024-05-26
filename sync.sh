#!/bin/bash

rm -rf ~/.android-certs/

ls ~/.android-certs/



subject='/C=PH/ST=Philippines/L=Manila/O=Rex H/OU=Rex H/CN=Rex H/emailAddress=dtiven13@gmail.com'
mkdir ~/.android-certs

for x in releasekey platform shared media networkstack testkey cyngn-priv-app bluetooth sdk_sandbox verifiedboot; do 
    yes "" | ./development/tools/make_key ~/.android-certs/$x "$subject"
done

cd ~/.android-certs/
ls





