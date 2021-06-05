#!/bin/bash

if [ -z "${BEFORE_EIGHTH}" ] || [ "$(date +'%d')" -lt "8" ]; then
  /usr/bin/Rscript ./store_directions.R "$1" "$2" "$3" 2>&1 | grep -v "Loading required package: methods"
fi
