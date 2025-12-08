#!/bin/bash -e

# THIS SCRIPT WILL BE EXECUTED INSIDE THE CHANGEROOT, NO NEED TO CALL chroot HERE
echo "Downloading the 'sl' package into ENV3, so it can be installed later - even without internet access."
$MOUNTPOINT apt-get install -d -y sl
