#!/bin/bash -e

if [ $(uname -m) == "aarch64" ] ; then
	echo "It looks like you're trying to run this script"
	echo "on a Raspberry Pi. This is a bad idea, as"
	echo "your booted environment will already use the"
	echo "partition labels that this script is expecting."
	echo "Therefore, we need to abort here."
	exit 1
elif ! [ -x /usr/bin/qemu-aarch64-static ]; then
	echo "This is not 'aarch64' hardware, yet we need to"
	echo "chroot into an 'aarch64' environment later on."
	echo "Therefore, we will now install qemu-user-static."
	sudo apt update
	sudo apt -y install qemu-user-static
fi

if ! [ -x /usr/bin/sudo ]; then
	echo "Command 'sudo' not found."
	echo "You should install the sudo package to fix this."
	echo "Also, once installed, make sure you run this script"
	echo "with a user account that has sudo rights."
	echo "Suggested commands (as root):"
	echo "apt update && apt -y install sudo"
	echo "Terminating now, so you can fix this."
	exit 1
fi

if ! [ -x /sbin/partprobe ]; then
	echo "Command 'partprobe' not found."
	echo "Installing parted package to fix this."
	sudo apt update
	sudo apt -y install parted
fi

if ! [ -x /sbin/fatlabel ]; then
	echo "Command 'fatlabel' not found."
	echo "Installing dosfstools package to fix this."
	sudo apt update
	sudo apt -y install dosfstools
fi

if ! ( [ -x /bin/uuid ] || [ -x /usr/bin/uuid ] ) ; then
	echo "Command 'uuid' not found."
	echo "Installing uuid package to fix this."
	sudo apt update
	sudo apt -y install uuid
fi

while ! (test -L /dev/disk/by-label/bootfs && \
	 test -L /dev/disk/by-label/rootfs); do
	echo "No partitions labelled bootfs and rootfs found."
	echo "Try removing and reinserting the media."
	echo "Sleeping 30 seconds and trying again ..."
	sleep 30
done

# set BASEDEV and PARTITIONxyz variables depending on removable storage type
BASEDEV=$(realpath /dev/disk/by-label/bootfs | sed -e 's/[0-9]$//')
if echo -n "$BASEDEV" | grep -q "mmc" ; then
	BASEDEV=$(echo -n "$BASEDEV" | sed -e 's/p$//')
	PARTONE="${BASEDEV}p1"
	PARTTWO="${BASEDEV}p2"
	PARTTHREE="${BASEDEV}p3"
	PARTFIVE="${BASEDEV}p5"
	PARTSIX="${BASEDEV}p6"
	PARTSEVEN="${BASEDEV}p7"
	PARTEIGHT="${BASEDEV}p8"
else
	PARTONE="${BASEDEV}1"
	PARTTWO="${BASEDEV}2"
	PARTTHREE="${BASEDEV}3"
	PARTFIVE="${BASEDEV}5"
	PARTSIX="${BASEDEV}6"
	PARTSEVEN="${BASEDEV}7"
	PARTEIGHT="${BASEDEV}8"
fi

# test for buggy sfdisk version (can't calculate partition sizes properly, either)
echo ",,Ex"  | sudo sfdisk -n -N 4 $BASEDEV || (echo "Your sfdisk version is too old. Terminating for safety reasons." ; exit 1)

# make a copy of the partition table for debug purposes
sudo sfdisk --dump $BASEDEV >/tmp/sfdisk.$(basename $BASEDEV)

# clone rootfs into a file, so we can safely repartition the media
# but do not clone again if file already exists
if ! [ -f /tmp/rootfs ] ; then
	sudo dd if=${PARTTWO} of=/tmp/rootfs bs=4096k status=progress
fi
# free partition number 2
sudo sfdisk --delete $BASEDEV 2
# re-read partition table
while ! sudo partprobe $BASEDEV; do sleep 1; done
# block first sectors with a fake partition
echo ",,c"  | sudo sfdisk -N 2 $BASEDEV
# re-read partition table
while ! sudo partprobe $BASEDEV; do sleep 1; done
# create another fake partition as placeholder for ENV2/ENV3
echo ",1G,c"  | sudo sfdisk -N 3 $BASEDEV
# re-read partition table
while ! sudo partprobe $BASEDEV; do sleep 1; done
# create extended partition
echo ",,Ex"  | sudo sfdisk -N 4 $BASEDEV
# re-read partition table
while ! sudo partprobe $BASEDEV; do sleep 1; done
# delete fake partition 3
sudo sfdisk --delete $BASEDEV 3
# re-read partition table
while ! sudo partprobe $BASEDEV; do sleep 1; done
# delete fake partition 2
sudo sfdisk --delete $BASEDEV 2
# re-read partition table
while ! sudo partprobe $BASEDEV; do sleep 1; done
# create actual permanent partitions
echo ",512M,c"  | sudo sfdisk -N 2 $BASEDEV
# re-read partition table
while ! sudo partprobe $BASEDEV; do sleep 1; done
echo ",512M,c"  | sudo sfdisk -N 3 $BASEDEV
# re-read partition table
while ! sudo partprobe $BASEDEV; do sleep 1; done
echo ",8G"  | sudo sfdisk -N 5 $BASEDEV
# re-read partition table
while ! sudo partprobe $BASEDEV; do sleep 1; done
echo ",8G"  | sudo sfdisk -N 6 $BASEDEV
# re-read partition table
while ! sudo partprobe $BASEDEV; do sleep 1; done
echo ",8G"  | sudo sfdisk -N 7 $BASEDEV
# re-read partition table
while ! sudo partprobe $BASEDEV; do sleep 1; done
echo ","  | sudo sfdisk -N 8 $BASEDEV
# re-read partition table
while ! sudo partprobe $BASEDEV; do sleep 1; done

# write rootfs contents into proper partition
if test -b $PARTFIVE ; then
	sudo dd if=/tmp/rootfs of=$PARTFIVE bs=4096k status=progress
else
	echo "Partition 5 ($PARTFIVE) not accessible. Terminating."
	exit 1
fi
# delete temporary rootfs and partition table copy
sudo rm -f /tmp/rootfs /tmp/sfdisk.$(basename $BASEDEV)

# make sure everything is written to disk/media
sudo sync
# force fsck (required for resize)
sudo fsck -f -y $PARTFIVE
# resize rootfs to partition size
sudo resize2fs $PARTFIVE
# mount rootfs and bootfs the way they would be in ENV1
sudo mount $PARTFIVE /media
sudo mount $PARTONE /media/boot/firmware
# mount pseudo-filesystems 
sudo mount -R /dev/ /media/dev
sudo mount -R /sys/ /media/sys
sudo mount -t proc proc /media/proc

# update fstab and cmdline.txt with new partition numbers
sudo sed -e 's/-02 /-05 /g' -i \
     /media/etc/fstab /media/boot/firmware/cmdline.txt
# add an fstab entry for the data partition
grep "PARTUUID" /media/etc/fstab | grep " / " | sed -e \
     's/-05/-08/' -e 's# / # /data#' -e 's/defaults/defaults,sync/' \
     | sudo tee -a /media/etc/fstab >/dev/null
# data partition also needs a mount point
sudo mkdir /media/data
# add cmdline.txt parameters for USB ethernet gadget
sudo sed -e \
     's/$/ modules-load=dwc2,g_ether \
     g_ether.host_addr=00:11:22:33:44:55/' -i \
     /media/boot/firmware/cmdline.txt
# create a etc/profile.d directory if it doesn't already exist
sudo mkdir -p /media/etc/profile.d
# add scripts to detect booted ENV (ENV1/2/3) and active
# overlay filesystem - add corresponding tags to shell prompt
echo "if grep -q '^overlayroot /' /proc/mounts ; then" | \
     sudo tee /media/etc/profile.d/zz10-overlay-prompt.sh >/dev/null
echo '  PS1="OFS-${PS1}"' | sudo tee -a \
     /media/etc/profile.d/zz10-overlay-prompt.sh >/dev/null
echo 'fi' | sudo tee -a /media/etc/profile.d/zz10-overlay-prompt.sh \
     >/dev/null
sudo chmod 644 /media/etc/profile.d/zz10-overlay-prompt.sh
echo 'ENV=$(awk '"'"'$2=="/boot/firmware" {print $1}'"'"' \
     /proc/mounts | tr -cs '"'"'[:digit:]'"'"' '"'"'\n'"'"' \
     | tail -n 1)' | sudo tee \
     /media/etc/profile.d/zz20-bootedenv-prompt.sh >/dev/null
echo 'PS1="ENV${ENV}-${PS1}"' | sudo tee -a \
      /media/etc/profile.d/zz20-bootedenv-prompt.sh >/dev/null
echo '[ $UID -eq 0 ] && sed -e "s/^ENV[0-9]-//" -e \
     "s/^Debian/ENV${ENV}-Debian/" -i /etc/issue' | sudo tee -a \
      /media/etc/profile.d/zz20-bootedenv-prompt.sh >/dev/null
sudo chmod 644 /media/etc/profile.d/zz20-bootedenv-prompt.sh

# make sure that when logging in as regular user, the tags 
# get applied to the default shell prompt as well
for bashrc in /media/home/*/.bashrc ; do
    echo 'echo $PS1 | \
    grep -q "^ENV" && for setprompt in /etc/profile.d/zz* ; do \
    source "${setprompt}"; done' | sudo tee -a $bashrc >/dev/null
done

# make sure booted environment (ENV1/2/3) is shown at the login console
sudo tee /media/etc/cron.d/showsysenv <<SHOWSYSENV
@reboot root bash -c "export SYSENV=\$(awk '\$2=="/boot/firmware" {print \$1}' /proc/mounts | tr -cs '[:digit:]' '\n' | tail -n 1) ; test -n \"\\\$SYSENV\" && /usr/bin/sed -e 's/^ENV[0-9]-//' -e 's/^Debian/ENV'\\\${SYSENV}'-Debian/' -i /etc/issue"
SHOWSYSENV


# add config.txt parameters for USB ethernet gadget and SPI touchscreen
tail -n 1 /media/boot/firmware/config.txt | grep -q '^\[all\]$' || \
echo "[all]" | sudo tee -a /media/boot/firmware/config.txt >/dev/null
echo "# for USB Ethernet Gadget" | \
     sudo tee -a /media/boot/firmware/config.txt >/dev/null
echo "dtoverlay=dwc2" | sudo tee -a \
     /media/boot/firmware/config.txt >/dev/null
echo "# for SPI TouchScreen" | sudo tee -a \
     /media/boot/firmware/config.txt >/dev/null
echo "dtparam=spi=on" | sudo tee -a \
     /media/boot/firmware/config.txt >/dev/null
echo "dtoverlay=piscreen,speed=16000000,rotate=270" | sudo \
     tee -a /media/boot/firmware/config.txt >/dev/null

# add boot partition chooser config file
echo "[all]" | sudo tee -a /media/boot/firmware/autoboot.txt >/dev/null
echo "boot_partition=1" | sudo tee -a \
     /media/boot/firmware/autoboot.txt >/dev/null

# set and generate locale so the following update steps won't complain
sudo sed -e 's/^# de_DE.UTF-8/de_DE.UTF-8/' \
         -e 's/^# C.UTF-8/C.UTF-8/' \
         -e 's/^en_GB/# en_GB/' \
         -i /media/etc/locale.gen
sudo sed -e 's/=en_GB/=de_DE/' -i /media/etc/locale.conf
sudo chroot /media locale-gen

# update package list, install etckeeper so we get a log of our
# upcoming changes
sudo chroot /media apt update
sudo chroot /media apt install -y etckeeper

# purge the cloud-init package and clean up afterwards
sudo chroot /media apt purge -y cloud-init
sudo chroot /media apt autopurge -y

# install the minimum required packages
sudo chroot /media apt install -y ifupdown screen git vim dnsmasq

# check for a custom install script; execute it if present,
# and remove the executable bit afterwards (so it runs only once)
test -x /media/custom-install.sh && \
        sudo chroot /media custom-install.sh && \
        sudo chmod -x /media/custom-install.sh

# add loopback network configuration
echo "auto lo" | sudo tee -a /media/etc/network/interfaces >/dev/null
echo "iface lo inet loopback" | sudo tee -a \
     /media/etc/network/interfaces >/dev/null

# add DHCP network configuration for eth0
echo "" | sudo tee -a /media/etc/network/interfaces >/dev/null
echo "allow-hotplug eth0" | sudo tee -a /media/etc/network/interfaces \
      >/dev/null
echo "iface eth0 inet dhcp" | sudo tee -a \
      /media/etc/network/interfaces >/dev/null

# add static network configuration for usb0
echo "allow-hotplug usb0" | sudo tee \
     /media/etc/network/interfaces.d/usb0 >/dev/null
echo "iface usb0 inet static" | sudo tee -a \
     /media/etc/network/interfaces.d/usb0 >/dev/null
echo "        address 192.168.134.1" | sudo tee -a \
     /media/etc/network/interfaces.d/usb0 >/dev/null
echo "        netmask 255.255.255.0" | sudo tee -a \
     /media/etc/network/interfaces.d/usb0 >/dev/null

# configure dnsmasq on usb0 so a host device connecting via usb0
# can receive an IP address via DHCP (by disabling dhcp options 3
# and 6, we avoid messing with the host's routing and DNS settings)
echo "# Bind to usb0 only" | sudo tee \
     /media/etc/dnsmasq.q/usb0 >/dev/null
echo "interface=usb0" | sudo tee -a /media/etc/dnsmasq.q/usb0 >/dev/null
echo "bind-interfaces" | sudo tee -a \
     /media/etc/dnsmasq.q/usb0 >/dev/null
echo "# Set range and lease time" | sudo tee -a \
     /media/etc/dnsmasq.q/usb0 >/dev/null
echo "dhcp-range=192.168.134.20,192.168.134.10,1h" | sudo tee -a \
     /media/etc/dnsmasq.q/usb0 >/dev/null
echo "# Send no default route" | sudo tee -a \
     /media/etc/dnsmasq.q/usb0 >/dev/null
echo "dhcp-option=3" | sudo tee -a /media/etc/dnsmasq.q/usb0 >/dev/null
echo "# Send no DNS server info" | sudo tee -a \
      /media/etc/dnsmasq.q/usb0 >/dev/null
echo "dhcp-option=6" | sudo tee -a /media/etc/dnsmasq.q/usb0 >/dev/null

# we're done making changes to ENV1, so let's unmount everything
sudo umount -R /media

# we start by cloning ENV1 rootfs to ENV2 rootfs
sudo dd if=$PARTFIVE of=$PARTSIX bs=4096k status=progress
# to make sure we can tell our clones apart, we set a new LABEL and UUID
sudo tune2fs -L rootfs2 -U $(uuid) $PARTSIX

# re-read partition table
while ! sudo partprobe $BASEDEV; do sleep 1; done

# mount the ENV2 rootfs and update /etc/fstab
sudo mount $PARTSIX /media
sudo sed -e 's/-01 /-02 /g' -e 's/-05 /-06 /g' -i \
     /media/etc/fstab

# we're done making changes to ENV2's rootfs, so let's unmount
# everything
sudo umount -R /media

# now we are cloning ENV1 rootfs to ENV3 rootfs
sudo dd if=$PARTFIVE of=$PARTSEVEN bs=4096k status=progress
# to make sure we can tell our clones apart, we set a new LABEL and UUID
sudo tune2fs -L rootfs3 -U $(uuid) $PARTSEVEN

# re-read partition table
while ! sudo partprobe $BASEDEV; do sleep 1; done

# mount the ENV3 rootfs and update /etc/fstab
sudo mount $PARTSEVEN /media
sudo sed -e 's/-01 /-03 /g'-e 's/-05 /-07 /g' -i \
     /media/etc/fstab

# we're done making changes to ENV3's rootfs, so let's unmount
# everything
sudo umount -R /media

# now let's create the file system on the data partition
sudo mkfs.ext4 -L data $PARTEIGHT

# re-read partition table
while ! sudo partprobe $BASEDEV; do sleep 1; done

# next step is cloning ENV1 bootfs to ENV2 bootfs
sudo dd if=$PARTONE of=$PARTTWO bs=4096k status=progress
# to make sure we can tell our clones apart, we set a new LABEL
sudo fatlabel $PARTTWO bootfs2

# re-read partition table
while ! sudo partprobe $BASEDEV; do sleep 1; done

# mount the ENV2 rootfs and update cmdline.txt
sudo mount $PARTTWO /media
sudo sed -e 's/-05 /-06 /g' -i /media/cmdline.txt

# we're done making changes to ENV2's bootfs, so let's unmount
# everything
sudo umount -R /media

# finally, let's clone ENV1 bootfs to ENV3 bootfs
sudo dd if=$PARTONE of=$PARTTHREE bs=4096k status=progress
# to make sure we can tell our clones apart, we set a new LABEL
sudo fatlabel $PARTTWO bootfs3

# re-read partition table
while ! sudo partprobe $BASEDEV; do sleep 1; done

# mount the ENV3 rootfs and update cmdline.txt
sudo mount $PARTTHREE /media
sudo sed -e 's/-05 /-07 /g' -i /media/cmdline.txt

# we're done making changes to ENV3's bootfs, so let's unmount
# everything
sudo umount -R /media
