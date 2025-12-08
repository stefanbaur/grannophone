#!/bin/bash -e

# do not continue unless run as root
if [ $UID -ne 0 ]; then
	echo "Please run this program as root or using sudo."
	exit 1
fi

# check if our config file exists
if ! test -s ./base_install.conf ; then
	echo "Config file ./base_install.conf not found!"
	exit 1
fi

# check for media presence
while ! (test -L /dev/disk/by-label/bootfs && \
	 test -L /dev/disk/by-label/rootfs); do
	echo "No partitions labelled bootfs and rootfs found."
	echo "Try removing and reinserting the media."
	echo "Sleeping 30 seconds and trying again ..."
	sleep 30
done

# source our config variables
source ./base_install.conf

# override settings with custom file if present
if [ -s ./base_install_custom.conf ]; then
	echo "Custom base install file found, overriding default settings."
	source ./base_install_custom.conf
fi
# TODO check that all required variables are set

#set dynamic variables
export MOUNTPOINT=$(mktemp -d)
export TEMPIMAGEDIR=$(mktemp -d -p $TEMPIMAGEDIRROOT)

# set BASEDEV and PARTITIONxyz variables depending on removable storage type
export BASEDEV=$(realpath /dev/disk/by-label/bootfs | sed -e 's/[0-9]$//')
if echo -n "$BASEDEV" | grep -q "mmc" ; then
	export BASEDEV=$(echo -n "$BASEDEV" | sed -e 's/p$//')
	export PARTONE="${BASEDEV}p1"
	export PARTTWO="${BASEDEV}p2"
	export PARTTHREE="${BASEDEV}p3"
	export PARTFIVE="${BASEDEV}p5"
	export PARTSIX="${BASEDEV}p6"
	export PARTSEVEN="${BASEDEV}p7"
	export PARTEIGHT="${BASEDEV}p8"
else
	export PARTONE="${BASEDEV}1"
	export PARTTWO="${BASEDEV}2"
	export PARTTHREE="${BASEDEV}3"
	export PARTFIVE="${BASEDEV}5"
	export PARTSIX="${BASEDEV}6"
	export PARTSEVEN="${BASEDEV}7"
	export PARTEIGHT="${BASEDEV}8"
fi

# now run our configuration steps

echo "Now executing all our base install/config scripts ..."
if test -d ./base_install_scripts.d ; then
        run-parts --exit-on-error ./base_install_scripts.d
else
	echo "Directory ./base_install_scripts.d not found!"
	exit 1
fi

####################

# TODO
# - Make ENV1,2,3 do a "reboot dance" straight after base install, ending up in ENV2 - work in progress -> investigate autostart.sh
# - try mkfs and rsync -avPAHXx --numeric-ids origin destination/ instead of dd - is it faster?
# - note: rsync now supports -HS --inplace and possibly --no-whole-file as well
# - command line to enable overlayfs: sudo raspi-config nonint enable_overlayfs
# - update-rc.d alsa-utils disable
# - update-rc.d dnsmasq disable
# - watchdog is messed up?
#   - try combining systemd and userland watchdog settings
#   - what's the output of wdctl?
#   - what happens when using a minimal Linux image (straight out of the imager), only with the watchdog-userland package?
# manual mount commands for an attempted switch to sysvinit:
# mount /dev/sda7 /mnt/
# mount /dev/sda3 /mnt/boot/firmware/
# mount --bind /dev /mnt/dev
# mount -t devpts none /mnt/dev/pts
# mount -t proc none /mnt/proc
# mount --bind /sys /mnt/sys
# chroot /mnt/
# apt install --allow-remove-essential sysvinit-core initscripts orphan-sysvinit-scripts rsyslog watchdog ntpsec-ntpdate uuid netcat-openbsd fake-hwclock systemd-sysv- systemd- apparmor- bluez-
# apt purge systemd-timesyncd systemd-zram-generator network-manager cloud-init
# apt autopurge -y
