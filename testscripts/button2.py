import RPi.GPIO as GPIO
import threading

class ButtonHandler(threading.Thread):
    def __init__(self, pin, func, edge='both', bouncetime=200):
        super().__init__(daemon=True)

        self.edge = edge
        self.func = func
        self.pin = pin
        self.bouncetime = float(bouncetime)/1000

        self.lastpinval = GPIO.input(self.pin)
        self.lock = threading.Lock()

    def __call__(self, *args):
        if not self.lock.acquire(blocking=False):
            return

        t = threading.Timer(self.bouncetime, self.read, args=args)
        t.start()

    def read(self, *args):
        pinval = GPIO.input(self.pin)

        if (
                ((pinval == 0 and self.lastpinval == 1) and
                 (self.edge in ['falling', 'both'])) or
                ((pinval == 1 and self.lastpinval == 0) and
                 (self.edge in ['rising', 'both']))
        ):
            self.func(*args)

        self.lastpinval = pinval
        self.lock.release()

def real_cb(gpio_number):
    datetime_string = datetime.now().strftime("%Y-%m-%d %H-%M-%S %s")
    print("Button pressed at %s!" % datetime_string)

GPIO.setmode(GPIO.BCM)
GPIO.setup(4, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
cb = ButtonHandler(4, real_cb, edge='rising', bouncetime=100)
cb.start()
GPIO.add_event_detect(4, GPIO.RISING, callback=cb)

try:
    while True:
        time.sleep(0.01)
except:
    GPIO.cleanup()
