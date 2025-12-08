
# Prerequisites:
  - A Debian Bookworm system (or newer) - derivatives like Devuan and Ubuntu should work, too, as long as they are at least based on Debian Bookworm
  - A microSD card or USB flash memory stick, or a Compute Module with onboard eMMC flash, at least 32 GB in size
  - Approximately 15 GB free space in /tmp
  - The rpi-imager tool (which can be downloaded from `https://downloads.raspberrypi.com/imager/imager_latest_amd64.AppImage`)
# Required steps:
  - ONLY when using a Compute Module with onboard eMMC flash, please follow the additional directions from: https://www.jeffgeerling.com/blog/2020/how-flash-raspberry-pi-os-compute-module-4-emmc-usbboot>
    - Put the switch/jumper on your CM baseboard in the proper position to flash the eMMC
    - Connect the CM to the CM baseboard, if you have not already done so
    - Connect the CM baseboard to your computer
    - Run `rpiboot` (if it's throwing errors and the connection seems unstable/your image writing process ends prematurely, try `rpiboot -d mass-storage-gadget64`)
  - ONLY when NOT using a Compute Module with onboard eMMC flash: connect your media (microSD card/USB flash stick) to your computer
  - Make sure you are either using "pristine" media straight out of the original packaging, or wipe the entire media with zeroes - else `base_install.sh` might detect traces of previous partitions/file systems on it and abort.
  - Start rpi-imager:
    - `chmod +x imager_latest_amd64.AppImage`
    - `sudo imager_latest_amd64.AppImage`
  - Select your language, click 
  - At "CHOOSE DEVICE", select your Raspberry Pi Model (Pi 4 or Pi 5, or the corresponding entry for a Compute Module 4 or 5)
  - At "CHOOSE OS", select the proper Raspberry Pi OS version - do NOT use the default image, rather, pick: "Raspberry Pi OS (other)" -> "Raspberry Pi OS Lite (64-bit)"
  - At "CHOOSE STORAGE", select the destination media: rpi-imager should be smart enough to show only removable media (i.e. your microSD card or USB flash stick)
  - Click "NEXT"
  - Click "EDIT SETTINGS"
    - Select the "General" tab
      - Note that depending on the size of your screen and the rpi-imager window, you may have to scroll down to reach all the items you need to check/set.
      - Make sure "Set hostname" is checked and enter a suitable, unique hostname (e.g. grnp-donny-duck, grnp-daisy-duck) - the .local gets added automatically
      - Make sure "Set username and password" is checked and choose a username that will be common across all the devices you intend to manage. For now, choose a random password with at least 16 characters and make sure to store it in a safe place. (The configuration as per these instructions will block remote logins using this password, but still, please don't choose something generic and easy to guess like "raspberry".)
      - Make sure "Configure wireless LAN" is NOT checked.
      - Make sure "Set locale settings" is checked and the Time zone and Keyboard layout correspond to your region's usual settings.
      - DO NOT CLICK THE "SAVE" BUTTON JUST YET!
    - Select the "Services" tab
      - Make sure "Enable SSH" is checked
      - Select "Allow public-key authentication only"
        - If you do not already have a public/private SSH key pair:
          - If the button "RUN SSH-KEYGEN" is greyed out for you, open a new console and run the "ssh-keygen" command there. You can accept all default settings; and when prompted for a passphrase, enter a passphrase that is at least 16 characters long. Feel free to use a complete sentence. Make sure you store this passphrase/sentence somewhere safe.
          - If the button "RUN SSH-KEYGEN" works for you, feel free to use it and follow the instructions on screen.
        - If/Once you have a public/private SSH key pair, press the "ADD SSH KEY" button and paste the text string of your public key (usually stored in a text file matching ~/.ssh/id_*.pub) here.
      - AGAIN, DO NOT CLICK THE "SAVE" BUTTON JUST YET!
    - Select the "Options" tab
      - Feel free to check "Play sound when finished"
      - Make sure "Eject media when finished" is checked.
      - Make sure "Enable telemetry" is NOT checked.
      - Now, click the "SAVE" button
    - Click "YES" to confirm you want to apply these settings
  - Confirm that you wish to completely erase and overwrite the selected destination media
  - At this point, you may be prompted for your sudo/root/administrator password
  - Once rpi-imager has completed writing and verifying the image, exit rpi-imager
  - Remove the removable media and re-insert it after a good 10-15 seconds (if you are using a CM with flash, this means you need to re-run `rpiboot`)
  - Review the default settings in `base_install.conf`, if you need to make any changes, save them as `base_install_custom.conf` so they won't get overwritten by a `git pull`
  - Run `sudo ./base_install.sh 2>&1 | tee base_install.log`
  - When `base_install.sh` has finished its work, remove the media and boot your Pi from it (note that it will reboot several times until the installation is complete)

# Result
  - The above steps, combined with the `base_install.sh` script in this directory, will set you up with three boot environments you can choose from.
  - These environments are called ENV1, ENV2, and ENV3:
    - ENV1 uses the first partition as /boot/firmware and the fifth partition as /
    - ENV2 uses the second partition as /boot/firmware and the sixth partition as /
    - ENV3 uses the third partition as /boot/firmware and the seventh partition as /
    - All three environments share the eight partition as /data, so you can transfer data between them by saving it to /data and rebooting to a different environment
  - You can switch between the three environments by running `sudo reboot n`, where n is a number between 1 and 3.
  - The default partition is set in the file `autoboot.txt` located on the first partition.
  - The idea behind this approach is that you leave ENV1 as a minimal installation, from which you can service/repair the other two.
  - In ENV2 and ENV3, you can install all the applications your users need:
    - Whenever you need to apply updates, do so in the environment that is currently not active, check if there were any errors, and if not, reboot into the other environment.
    - Once in the other environment, you can either set it to be the default until the next update, or apply the updates again to the now inactive environment.
  - You will need to apply updates to ENV1 as well, but hopefully, due to the minimal installation there, updates should occur way less frequently than in the other two environments.

# Customization
Please see the README.md files in the folders `templates` and `custom` for details on how to add your own packages and scripts.
