# Custom Script Directory

The files 

  - *-run-custom-install-script-env1
  - *-run-custom-install-script-env2
  - *-run-custom-install-script-env3
  - *-patch-data-partition

in the `/base_install_scripts.d` folder expect scripts named

  - ENV1-custom-install.sh, 
  - ENV2-custom-install.sh,
  - ENV3-custom-install.sh, and 
  - autostart.sh, 

respectively.

If the folder `custom` is empty, the scripts will pull a corresponding template from the folder this README.md is in (currently named `templates`).

**Notes:**
  - **ENV1-custom-install.sh will be run first, and ENV2 and ENV3 are clones of ENV1, with the cloning process starting *after* ENV1-custom-install.sh is run, so whatever you put in the custom script for ENV1 will also end up in ENV2 and ENV3.**
  - **There is a `.gitignore` file in the parent directory that excludes files named ENV?-custom-install.sh and autostart.sh in the `custom` directory, so you can safely put your own versions there, a `git pull` command  will not overwrite them. Files in this directory (`templates`), however, will be overwritten.**
