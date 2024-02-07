#!/bin/bash

cd ~/android/builds/banana/miatoll/ && rm *.*
cd ~/android/cr/out/target/product/miatoll/ && mv *.zip *.md5sum ~/android/builds/cr/miatoll/
cd ~/android/builds/cr/miatoll/ && rm banana_miatoll-ota*.zip *.md5sum

sftp itubuild@frs.sourceforge.net:/home/pfs/project/itu/build/miatoll/