#!/bin/bash

if [ -f gh_token.txt ]; then
    export GH_TOKEN=$(cat gh_token.txt)
    git clone https://$GH_TOKEN@github.com/xc112lg/key vendor/lineage-priv/keys
else
    echo "gh_token.txt not found. Skipping repository clone."
fi



