# Grannophone: Raspberry Pi + BareSIP
This project uses BareSIP as a SIP User Agent to answer calls on a Raspberry Pi.
BareSIP is included as Python wrapper baresipy.

## Main idea
This version still uses a GUI (based on the PyQt5 Library) to accept and end calls. The GUI controls the class RaspiBaresip (our child class of BareSIP) in order to manage phone calls.
In the future, the GUI (hopefully) will become obsolete and phone call management will directly take place between the Raspberry Pi and our RaspiBaresip class. 
Since the GUI is our main thread, and we also have our BareSip-thread, we need a way to pass information from our BareSip-thread to our GUI thread. To accomplish this, we use a Producer-Consumer pattern that is based on a shared queue. 
The producer (our BareSip instance) generates data (e.g. incoming call event, ending call event) and adds it to out queue. The consumer (our GUI) polls the queue and reacts according to the events added to the queue by the producer.


## Setup
1. First, you (and the person you want to call) will need to create a SIP Account such as https://www.linphone.org/
2. Install dependencies and and configure your account in ~/.baresip/accounts
```
sudo apt update
sudo apt install python3-pip
sudo apt install baresip
sudo apt install ffmpeg
sudo apt install python3-pyqt5
sudo apt install libcamera-v4l2 libcamera-tools
```

If ~/.baresip/accounts doesn't exist, run baresip once via command line using the command ```baresip```.

3. Create .env and fill in your account details as well as allowed callers.
```
mv .env.example .env
```

```
SIP_USER=myusername
SIP_PASSWORD=mypaSSWORD
SIP_SERVER=sip.linphone.org
# separate by comma
ALLOWED_CALLERS=sip:bob@sip.linphone.org,sip:alice@sip.linphone.org
```

4. Create virtual environment and install Python dependencies
```
python -m venv --system-site-packages new-venv
source new-venv/bin/activate
pip3 install -r requirements.txt
```

5. Run python script (within the active virtual environment)
```
libcamerify python3 main.py 
```

6. TODOs
- wrap all the steps above in a script
- use full desktop app?: https://forums.raspberrypi.com/viewtopic.php?t=325477

