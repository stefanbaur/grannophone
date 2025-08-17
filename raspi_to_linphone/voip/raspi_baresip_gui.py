import queue
from .raspi_baresip import RaspiBaresip
from dotenv import load_dotenv
import os
from PyQt5.QtWidgets import QLabel,QVBoxLayout, QMainWindow, QPushButton, QWidget
from PyQt5.QtCore import QTimer, Qt, QSize, QRect
from PyQt5.QtGui import QPixmap, QIcon


class CallWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Neuer Anruf")
        self.setStyleSheet("background-color: #f0fff0;")
        width, height = 800, 480

        # Force fullscreen-like behavior
        self.setGeometry(QRect(0, 0, width, height))
        self.setWindowFlags(Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint)
        self.hide()  # Start hidden
        self.call_queue = queue.Queue()  # Queue to share information between threads.

        # Load .env variables and instantiate our BareSip instance.
        base_dir = os.path.dirname(os.path.abspath(__file__))
        env_path = os.path.abspath(os.path.join(base_dir, '../config/.env'))
        load_dotenv(env_path, override=True)
        user = os.getenv("SIP_USER")
        pwd = os.getenv("SIP_PASSWORD")
        gateway = os.getenv("SIP_SERVER")
        allowed_callers = os.getenv("ALLOWED_CALLERS")
        self.baresip = RaspiBaresip(user=user, pwd=pwd, gateway=gateway, allowed_callers=allowed_callers,
                               event_queue=self.call_queue)
        # Start polling.
        self.poll_timer = QTimer(self)
        self.poll_timer.setInterval(1000)
        self.poll_timer.timeout.connect(self._check_queue)
        self.poll_timer.start()

    def _check_queue(self):
        """
        This method checks the buffer both threads use for call actions.
        """
        try:
            while True:

                # Check if any event was put into the buffer by baresip.
                buffer = self.call_queue.get(timeout=1)
                if buffer["event"] == "incoming_call":
                    self.show_incoming(buffer["caller"])
                elif buffer["event"] == "end_call":
                    self.show_ended()
        except queue.Empty:
            pass


    def show_incoming(self, caller: str):
        """
        Adjust call window when a call is incoming and provide accept-call-button.
        :param caller: The name of the caller.
        """
        label = QLabel(f"Anruf von {caller}")
        label.setAlignment(Qt.AlignHCenter | Qt.AlignTop)
        label.setStyleSheet("font-size: 40px; font-weight: bold; margin-top: 30px;")

        # Check if any picture of the caller exists in the images folder.
        base_dir = os.path.dirname(os.path.abspath(__file__))
        image_path = os.path.abspath(os.path.join(base_dir, f'../images/{caller}.jpg'))
        image_label = QLabel()
        if os.path.exists(image_path):
            pixmap = QPixmap(image_path)
            scaled_pixmap = pixmap.scaled(400, 240, Qt.KeepAspectRatio, Qt.SmoothTransformation)
            image_label.setPixmap(scaled_pixmap)
            image_label.setAlignment(Qt.AlignCenter)

        # Accept call button + icons.
        icon_path = os.path.abspath(os.path.join(base_dir, '../icons/telephone-fill.svg'))
        icon = QIcon(icon_path)
        button = QPushButton("  Anruf annehmen")
        button.setIcon(icon)
        button.setIconSize(QSize(35, 35))
        button.setFixedSize(QSize(600, 150))
        button.setStyleSheet("font-size:40px; background-color: green; margin-top: 30px; margin-bottom: 30px;")
        button.clicked.connect(self.baresip.accept_call)

        # Stack components vertically.
        layout = QVBoxLayout()
        layout.addWidget(label)
        layout.addWidget(image_label)
        layout.addWidget(button, alignment=Qt.AlignHCenter)

        # Add layout to widget.
        widget = QWidget()
        widget.setLayout(layout)
        self.setCentralWidget(widget)
        self.show()

    def show_established(self, caller: str):
        self.label.setText(f"Anruf mit {caller}")

    def show_ended(self):
        self.hide()
