#!/bin/bash

rm -rf h870/* h872/* us997/* 
rm Releases/*.zip
crave pull cd9/out/target/product/*/*.zip
mv h870/* h872/* us997/* ./Releases/ 
cd Releases 
./multi_upload.sh