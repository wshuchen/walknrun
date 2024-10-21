#!/bin/bash

## getPangene.sh
# Download pangene package and put all binaries in pangene/ directory.
# Assume that the current directory is walknrun/test/.

## Download.
echo
echo "Downloaing pangene-1.1 package."
echo
curl -L https://github.com/lh3/pangene/releases/download/v1.1/pangene-1.1-bin.tar.bz2|tar jxf -

## Collect the binaries.
mkdir pangene
mv pangene-1.1-bin/bin_x64-linux/* pangene
mv pangene-1.1-bin/scripts/pangene.js pangene
mv pangene ../bin/
rm -rf pangene-1.1-bin

## Check the files.
echo
echo "See pangene binaries in ../bin/pangene directory."
echo
ls ../bin/pangene
echo

## Export path for simple execution.
bin_path=$(echo ${PWD} | sed 's/\/test//')/bin
export PATH=${bin_path}:$PATH
if [[ -d ${bin_path}/pangene ]]; then
    export PATH=${bin_path}/pangene:$PATH
fi
