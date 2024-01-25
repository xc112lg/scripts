#!/bin/bash

rm -rf h870/* h872/* us997/* 
rm Releases/*.zip
crave pull out/target/product/*/*.zip
crave pull out/target/product/*/recovery.img
mv h870/recovery.img h870/recoveryh870.img
mv h872/recovery.img h872/recoveryh872.img
mv us997/recovery.img us997/recoveryus997.img
mv h870/* h872/* us997/* ./Releases/ 
cd Releases 
./multi_upload.sh