#!/bin/bash -e

echo "Downloading the 'sl' package into ENV2, so it can be installed later - even without internet access."
chroot $MOUNTPOINT apt-get install -d -y sl
