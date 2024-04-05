#!/bin/bash

sudo apt-get update
sudo apt-get install python python3-pip wget git 
pip3 install payload_dumper
mkdir rom
cd rom
wget -O archive.zip https://bn.d.miui.com/V14.0.5.0.TMAMIXM/miui_ISHTARGlobal_V14.0.5.0.TMAMIXM_6f43e09971_13.0.zip
unzip -j archive.zip  -d .
payload_dumper payload.bin --out .
ls -lah *
rm archive.zip
wget https://github.com/kelexine/rom-dumper/releases/download/v1.o/compress.sh
chmod 777 compress.sh
bash compress.sh