#!/bin/bash

rm -rf ~/.android-certs/
mkdir ~/.android-certs
ls ~/.android-certs/



subject='/C=DE/ST=Germany/L=Berlin/O=Max Mustermann/OU=Max Mustermann/CN=Max Mustermann/emailAddress=max@mustermann.de'
mkdir ~/.android-certs

for x in releasekey platform shared media networkstack testkey cyngn-priv-app bluetooth sdk_sandbox verifiedboot; do 
    yes "" | ./development/tools/make_key ~/.android-certs/$x "$subject"
done

cd ~/.android-certs/
ls





