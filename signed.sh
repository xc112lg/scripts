#!/bin/bash
cd hardware/lge
git fetch https://github.com/LineageOS/android_hardware_lge refs/changes/41/390841/7 && git checkout FETCH_HEAD
git fetch https://github.com/LineageOS/android_hardware_lge refs/changes/42/390842/11 && git checkout FETCH_HEAD
git fetch https://github.com/LineageOS/android_hardware_lge refs/changes/45/390845/13 && git checkout FETCH_HEAD
git fetch https://github.com/LineageOS/android_hardware_lge refs/changes/46/390846/15 && git checkout FETCH_HEAD
git fetch https://github.com/LineageOS/android_hardware_lge refs/changes/47/390847/17 && git checkout FETCH_HEAD
git fetch https://github.com/LineageOS/android_hardware_lge refs/changes/48/390848/18 && git checkout FETCH_HEAD
git fetch https://github.com/LineageOS/android_hardware_lge refs/changes/70/391370/3 && git checkout FETCH_HEAD

cd ../..





