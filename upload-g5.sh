#!/bin/bash

cd ~/android/builds/lineage/rs988/ && rm *.*
cd ~/android/los18/out/target/product/rs988/ && mv *.zip *.md5sum ~/android/builds/lineage/rs988/
cd ~/android/builds/lineage/rs988/ && rm lineage_rs988-ota*.zip *.md5sum
