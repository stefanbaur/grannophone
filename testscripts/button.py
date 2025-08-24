# -*- coding: utf-8 -*-
from RPi import GPIO
from datetime import datetime
import os, time
 
 
GPIOPin = 4
 
def button_callback(gpio_number):
    #print("Button pressed!")
    datetime_string = datetime.now().strftime("%Y-%m-%d %H-%M-%S %s")
    print("Button pressed at %s!" % datetime_string)
    #filename = "/home/pi/button_pushed_at_%s.txt" % datetime_string
    #os.system("touch %s" % filename)
 
GPIO.setmode(GPIO.BCM)
GPIO.setup(GPIOPin, GPIO.IN, pull_up_down = GPIO.PUD_DOWN)
#GPIO.add_event_detect(GPIOPin, GPIO.RISING, callback=button_callback,bouncetime=500)
GPIO.add_event_detect(GPIOPin, GPIO.FALLING, callback=button_callback,bouncetime=500)
 
try:
    while True:
        time.sleep(0.01)
except:
    GPIO.cleanup()
