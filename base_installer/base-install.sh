#!/bin/bash -e

# clone rootfs into a file, so we can safely repartition the media
sudo dd if=/dev/disk/by-label/rootfs of=/tmp/rootfs bs=4096k \
        status=progress
# block first sectors with a fake partition
echo ",,c"  | sudo sfdisk -N 2 $(realpath \
     /dev/disk/by-label/bootfs | tr -d "[0-9]")
# create another fale partition as placeholder for ENV2/ENV3
echo ",1G,c"  | sudo sfdisk -N 3 $(realpath \
     /dev/disk/by-label/bootfs | tr -d "[0-9]")
# create extended partition
echo ",,Ex"  | sudo sfdisk -N 4 $(realpath \
     /dev/disk/by-label/bootfs | tr -d "[0-9]")
# delete fake partitions
sudo sfdisk --delete $(realpath \
     /dev/disk/by-label/bootfs | tr -d "[0-9]") 3
sudo sfdisk --delete $(realpath \
     /dev/disk/by-label/bootfs | tr -d "[0-9]") 2
# create actual permanent partitions
echo ",512M,c"  | sudo sfdisk -N 2 $(realpath \
     /dev/disk/by-label/bootfs | tr -d "[0-9]")
echo ",512M,c"  | sudo sfdisk -N 3 $(realpath \
     /dev/disk/by-label/bootfs | tr -d "[0-9]")
echo ",8G"  | sudo sfdisk -N 5 $(realpath \
     /dev/disk/by-label/bootfs | tr -d "[0-9]")
echo ",8G"  | sudo sfdisk -N 6 $(realpath \
     /dev/disk/by-label/bootfs | tr -d "[0-9]")
echo ",8G"  | sudo sfdisk -N 7 $(realpath \
     /dev/disk/by-label/bootfs | tr -d "[0-9]")
echo ","  | sudo sfdisk -N 8 $(realpath \
     /dev/disk/by-label/bootfs | tr -d "[0-9]")

# write rootfs contents into proper partition
sudo dd if=/tmp/rootfs of=$(realpath \
     /dev/disk/by-label/bootfs | tr -d \
     "[0-9]")5 bs=4096k status=progress
# delete temporary rootfs copy
sudo rm /tm/rootfs
# make sure everything is written to disk/media
sudo sync
# re-read partition table
sudo partprobe
# force fsck (required for resize)
sudo fsck -f -y /dev/disk/by-label/rootfs
# resize rootfs to partition size
sudo resize2fs /dev/disk/by-label/rootfs
# mount rootfs and bootfs the way they would be in ENV1
sudo mount /dev/disk/by-label/rootfs /media
sudo mount /dev/disk/by-label/bootfs /media/boot/firmware
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
sudo dd if=$(realpath /dev/disk/by-label/bootfs | tr -d "[0-9]")5 \
        of=$(realpath /dev/disk/by-label/bootfs | tr -d "[0-9]")6 \
        bs=4096k status=progress
# to make sure we can tell our clones apart, we set a new LABEL and UUID
sudo tune2fs -L rootfs2 -U $(uuid) $(realpath \
     /dev/disk/by-label/bootfs | tr -d "[0-9]")6

# re-read partition table
sudo partprobe

# mount the ENV2 rootfs and update /etc/fstab
sudo mount /dev/disk/by-label/rootfs2 /media
sudo sed -e 's/-01 /-02 /g' -e 's/-05 /-06 /g' -i \
     /media/etc/fstab

# we're done making changes to ENV2's rootfs, so let's unmount
# everything
sudo umount -R /media

# now we are cloning ENV1 rootfs to ENV3 rootfs
sudo dd if=$(realpath /dev/disk/by-label/bootfs | tr -d "[0-9]")5 \
        of=$(realpath /dev/disk/by-label/bootfs | tr -d "[0-9]")7 \
        bs=4096k status=progress
# to make sure we can tell our clones apart, we set a new LABEL and UUID
sudo tune2fs -L rootfs3 -U $(uuid) $(realpath \
     /dev/disk/by-label/bootfs | tr -d "[0-9]")7

# re-read partition table
sudo partprobe

# mount the ENV3 rootfs and update /etc/fstab
sudo mount /dev/disk/by-label/rootfs3 /media
sudo sed -e 's/-01 /-03 /g'-e 's/-05 /-07 /g' -i \
     /media/etc/fstab

# we're done making changes to ENV3's rootfs, so let's unmount
# everything
sudo umount -R /media

# now let's create the file system on the data partition
sudo mkfs.ext4 -L data $(realpath /dev/disk/by-label/bootfs | tr -d \
     "[0-9]")8

# re-read partition table
sudo partprobe

# next step is cloning ENV1 bootfs to ENV2 bootfs
sudo dd if=$(realpath /dev/disk/by-label/rootfs | tr -d "[0-9]")1 \
        of=$(realpath /dev/disk/by-label/rootfs | tr -d "[0-9]")2 \
        bs=4096k status=progress
# to make sure we can tell our clones apart, we set a new LABEL
sudo fatlabel $(realpath /dev/disk/by-label/rootfs | tr -d "[0-9]")2 \
     bootfs2

# re-read partition table
sudo partprobe

# mount the ENV2 rootfs and update cmdline.txt
sudo mount /dev/disk/by-label/bootfs2 /media
sudo sed -e 's/-05 /-06 /g' -i /media/cmdline.txt

# we're done making changes to ENV2's bootfs, so let's unmount
# everything
sudo umount -R /media

# finally, let's clone ENV1 bootfs to ENV3 bootfs
sudo dd if=$(realpath /dev/disk/by-label/rootfs | tr -d "[0-9]")1 \
        of=$(realpath /dev/disk/by-label/rootfs | tr -d "[0-9]")3 \
        bs=4096k status=progress
# to make sure we can tell our clones apart, we set a new LABEL
sudo fatlabel $(realpath /dev/disk/by-label/rootfs | tr -d "[0-9]")2 \
     bootfs3

# re-read partition table
sudo partprobe

# mount the ENV3 rootfs and update cmdline.txt
sudo mount /dev/disk/by-label/bootfs3 /media
sudo sed -e 's/-05 /-07 /g' -i /media/cmdline.txt

# we're done making changes to ENV3's bootfs, so let's unmount
# everything
sudo umount -R /media
