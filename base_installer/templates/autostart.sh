#!/bin/bash

# test if cloud-init is still running #runonce
echo "Checking/waiting for cloud-init to finish - $(date)" >>/data/reboot.log #runonce
cloud-init status --wait #runonce
echo "cloud-init complete - $(date)" >>/data/reboot.log #runonce

# switch to console #8 and show that we're not yet ready if the banner is not set yet
while ! test -s /etc/ssh/banner; do chvt 8; clear >/dev/tty8 ; echo "banner not set yet $(date)" >/dev/tty8 ; sleep 10; done
chvt 1

# log our ENV and date
echo "$(cat /etc/ssh/banner) - bootup complete - $(date)">>/data/reboot.log

# is this the second reboot (first one does not log our ENV)? then remove cloud-init and set reboot cycle to ENV2 #runonce
if [ $(grep $(cat /etc/ssh/banner) /data/reboot.log | wc -l) -eq 1 ] ; then #runonce
	# remove cloud-init #runonce
	apt purge cloud-init -y 2>&1 | tee /data/cloudinit-purge.log  #runonce
	# do not use apt autopurge -y or apt clean here, or you might wipe the overlayfs packages we already downloaded during the chroot phase #runonce
	# enable overlay file system #runonce
	raspi-config nonint enable_overlayfs #runonce
	# make sure /data is not affected by overlayfs #runonce
	sed -e "s#overlayroot=tmpfs #overlayroot=tmpfs:recurse=0 #" -i /boot/firmware/cmdline.txt #runonce
	if grep -q "^ENV1" /etc/ssh/banner; then #runonce
		apt clean && apt autopurge -y #runonce
		sed -e "s#^boot_partition=1#boot_partition=2#" -i /boot/firmware/autoboot.txt #runonce
		echo "Date is now: $(date)" | tee -a /data/reboot.log >/dev/tty8 #runonce
		if /sbin/shutdown -r 1 1 2>&1 | tee -a /data/reboot.log >/dev/tty8; then #runonce
			touch /data/ENV1-stage-complete #runonce
		else #runonce
			touch /data/ENV1-could-not-reboot #runonce
		fi #runonce
	elif grep -q "^ENV2" /etc/ssh/banner; then #runonce
		# as we already downloaded the required packages during the chroot phase, we can install sl without needing internet access #runonce
		apt install -y sl #runonce
		apt clean && apt autopurge -y #runonce
		mount /dev/disk/by-label/bootfs /mnt #runonce
		sed -e "s#^boot_partition=2#boot_partition=3#" -i /mnt/autoboot.txt #runonce
		umount /dev/disk/by-label/bootfs #runonce
		echo "Date is now: $(date)" | tee -a /data/reboot.log >/dev/tty8 #runonce
		if /sbin/shutdown -r 1 ; then #runonce
			touch /data/ENV2-stage-complete #runonce
		else #runonce
			touch /data/ENV2-could-not-reboot #runonce
		fi #runonce
	elif grep -q "^ENV3" /etc/ssh/banner; then #runonce
		# as we already downloaded the required packages during the chroot phase, we can install sl without needing internet access #runonce
		apt install -y sl #runonce
		apt clean && apt autopurge -y #runonce
		mount /dev/disk/by-label/bootfs /mnt #runonce
		sed -e "s#^boot_partition=3#boot_partition=2#" -i /mnt/autoboot.txt #runonce
		touch /mnt/config_complete.txt #runonce
		umount /dev/disk/by-label/bootfs #runonce
		touch /data/ENV3-stage-complete #runonce
		echo "Date is now: $(date)" | tee -a /data/reboot.log >/dev/tty8 #runonce
		# this line removes all lines ending with #runonce from this autostart.sh file
		if sed -e "/#runonce$/d" -i /data/autostart.sh && /sbin/shutdown -r 1 1 2>&1 | tee -a /data/reboot.log >/dev/tty8; then #runonce
			touch /data/ENV3-runonce-removed #runonce
		else #runonce
			touch /data/ENV3-could-not-remove-runonce #runonce
		fi #runonce
	fi #runonce
fi #runonce

