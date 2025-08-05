# Grannophone: Raspberry Pi + BareSIP
This project uses BareSIP as a SIP User Agent to answer calls on a Raspberry Pi.
BareSIP is included as Python wrapper baresipy.

## Main idea
This version still uses a GUI (based on the PyQt5 Library) to accept and end calls. The GUI controls the class RaspiBaresip (our child class of BareSIP) in order to manage phone calls.
In the future, the GUI (hopefully) will become obsolete and phone call management will directly take place between the Raspberry Pi and our RaspiBaresip class. 

## Setup
1. First, you (and the person you want to call) will need to create a SIP Account such as https://www.linphone.org/
2. Install dependencies and configure your account in ~/.baresip/accounts

