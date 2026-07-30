#!/usr/bin/env bash

source <(curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/lunaris/rbe7.sh)


prebuilts/remoteexecution-client/buildbuddyfix/reproxy -server_address=unix:///tmp/reproxy.sock -service=xc112lg.buildbuddy.io:443 -cas_service=xc112lg.buildbuddy.io:443 -remote_headers="x-buildbuddy-api-key=D2SvmJdB1v8oM6KaNg6J"
