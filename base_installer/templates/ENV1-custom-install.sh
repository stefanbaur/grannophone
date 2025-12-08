#!/bin/bash -e

# THIS SCRIPT WILL BE EXECUTED INSIDE THE CHANGEROOT, NO NEED TO CALL chroot HERE
# run this right before umounting, so there's no apt clean call destroying our work
# download the packages required for overlayroot, so you don't need internet access to activate it
echo "Downloading required packages for overlayroot, so it can be installed later - even without internet access."
apt-get install -d -y cryptsetup cryptsetup-bin overlayroot
