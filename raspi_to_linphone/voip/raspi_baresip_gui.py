import queue
import tkinter as tk
from .raspi_baresip import RaspiBaresip
from time import sleep
from dotenv import load_dotenv, find_dotenv
import os
from baresipy.utils.log import LOG
import sys
from PyQt5.QtWidgets import QApplication, QLabel, QMainWindow
from PyQt5.QtCore import QObject, pyqtSignal, QTimer, Qt

# --- GUI window that reacts to call events ---
class CallWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Incoming Call")
        self.label = QLabel("Idle", parent=self)
        self.label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.setCentralWidget(self.label)
        self.resize(400, 200)
        self.hide()  # Start hidden
        self.call_queue = queue.Queue() # Queue to share information between threads.

        # Load .env variables and instantiate our BareSip instance.
        load_dotenv("raspi_to_linphone/config/.env", override=True)
        user = os.getenv("SIP_USER")
        pwd = os.getenv("SIP_PASSWORD")
        gateway = os.getenv("SIP_SERVER")
        allowed_callers = os.getenv("ALLOWED_CALLERS")
        baresip = RaspiBaresip(user=user, pwd=pwd, gateway=gateway, allowed_callers=allowed_callers, event_queue=self.call_queue)


    def check_queue(self):
        """
        This method checks the buffer both threads use for an incoming call.
        :return:
        """
        while True:
            if self.call_queue.empty():
                sleep(5)
            else:
                caller_name = self.call_queue.get()
                self.show_incoming(caller_name)


    def show_incoming(self, caller: str):
        """
        Adjust call window when a call is incoming.
        :param caller:
        :return:
        """
        self.setWindowTitle(f"Call from {caller}")
        self.show()

    def show_established(self, caller: str):
        self.label.setText(f"Call with {caller} established")

    def show_ended(self, reason: str):
        self.label.setText(f"Call ended ({reason})")
        QTimer.singleShot(1500, self.hide)  # auto-hide after 1.5s
