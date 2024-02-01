#!/bin/bash
TARGET_FACE_UNLOCK := false

source scripts/sync.sh
rm -rf out/target/product/*
brunch miatoll

