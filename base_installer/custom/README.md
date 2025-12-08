# Custom Script Directory

The files 

  - *-run-custom-install-script-env1
  - *-run-custom-install-script-env2
  - *-run-custom-install-script-env3
  - *-patch-data-partition

in the `/base_install_scripts.d` folder expect scripts named

  - ENV1-custom-install.sh, 
  - ENV2-custom-install.sh,
  - ENV1-custom-install.sh, and 
  - autostart.sh, 

respectively.

If the folder this README.md is in (currently named `custom`) is empty, the scripts will pull a corresponding template file from the folder `templates`.

**Note: that ENV1-custom-install.sh will be run first, and ENV2 and ENV2 are clones of ENV1, with the cloning process starting *after* ENV1-custom-install.sh is run, so whatever you put in the custom script for ENV1 will also end up in ENV2 and ENV3.**
