from _curses import window

from baresipy import BareSIP
from time import sleep
from dotenv import load_dotenv
import os
from voip.raspi_baresip import RaspiBaresip
from voip.raspi_baresip_gui import CallWindow
import threading
import queue
import tkinter as tk
from PyQt5.QtWidgets import QApplication, QWidget
import sys

def main():
    load_dotenv()
    user = os.getenv("SIP_USER")
    pwd = os.getenv("SIP_PASSWORD")
    gateway = os.getenv("SIP_SERVER")
    allowed_callers = os.getenv("ALLOWED_CALLERS")

    # Main thread: GUI
    app = QApplication(sys.argv)
    window = CallWindow()
    window.check_queue()
    app.exec()





# Start our main thread: tkinter event loop.
#def runtk():
   # event_queue = queue.Queue()

   # baresip = RaspiBaresip(user=user, pwd=pwd, gateway=gateway, allowed_callers=allowed_callers, event_queue=event_queue)
    #main_app = MainApp(baresip)
   # main_app.mainloop()


if __name__ == "__main__":
    main()




#try:
    #while True:
        #if b.call_status == "INCOMING":
            #print(f"blaaaaaaaaaaaaa call from {b.current_call}")
            #b.accept_call()
        #sleep(0.5)
#except KeyboardInterrupt:
    #b.quit()










