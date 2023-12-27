#!/bin/bash

# build/make
repopick -p 374112 -P build/make

# build/soong
repopick -p 374016

# bionic
repopick -p 368174

# frameworks/av
repopick -p 375037

# frameworks/base
repopick -p -f 376441
repopick 371338-371340 371336 # nvidia stuff

# frameworks/native
#Could not apply 94dd1b1bda... inputflinger: allow disabling input devices via idc
repopick -p 375021

# frameworks/opt/telephony
repopick -p 374711

# hardware/interfaces
repopick -p 375018

# packages/apps/Car/Settings
repopick -p 368408

# packages/apps/Settings
repopick -p 376991

# packages/apps/SettingsIntelligence
repopick -p 372631

# packages/apps/Trebuchet
repopick -p 368923

# packages/apps/TvSettings
repopick -p 368593

# packages/modules/adb
repopick -p 368672

# packages/modules/Bluetooth
repopick -p 368681

# packages/modules/common
repopick -p 368682

# packages/modules/Connectivity
repopick -p 375029

# packages/modules/Wifi
repopick -p 368685

# packages/services/Telecomm
repopick -p 372630

# packages/services/Telephony
repopick -p 368707

# system/core
repopick -p 375030

# system/logging
repopick -p 368739

# system/netd
repopick -p 369205

# system/security
repopick -p 368744

# system/sepolicy
repopick -p 375640

# system/update_engine
repopick -p 368759

# system/vold
repopick -p 368773

# vendor/lineage
repopick 376553 # kernel modules check

### Custom

# packages/apps/ExactCalculator
repopick -p 375863

# packages/apps/SetupWizard
repopick -p 371961
