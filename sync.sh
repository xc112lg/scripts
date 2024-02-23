#!/bin/bash


repo forall -c 'git reset --hard ; git clean -fdx'
rm -rf .repo/local_manifests
rm -rf device/lge/

cp scripts/roomservice.xml .repo/local_manifests
repo sync -c -j16 --force-sync --no-clone-bundle --no-tags

source scripts/fixes.sh



