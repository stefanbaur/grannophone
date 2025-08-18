from voip.raspi_baresip_gui import CallWindow
from PyQt5.QtWidgets import QApplication
import sys

def main():
    """
     Starts our main thread: the call-GUI.
    """
    app = QApplication(sys.argv)
    window = CallWindow()
    app.exec()

if __name__ == "__main__":
    main()










