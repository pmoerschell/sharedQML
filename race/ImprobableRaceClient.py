# This Python file uses the following encoding: utf-8
import sys
import os
import socket
import threading
import time
import censusname       # `sudo pip install censusname`

from PySide2.QtGui import QGuiApplication
from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtCore import QObject, Signal

HOST = '127.0.0.1'  # The server's hostname or IP address
PORT = 2468         # The default port used by the server


class Receiver(QObject):

    msg_number = 0
    raceData = Signal(str, float, int, int, arguments=['name', 'elapsed', 'id', 'gate'])

    def handle_race_data(self):
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM, 0)

        except socket.error as e:
            print("Failed to create socket: " + str(e))
            sys.exit(-1)

        # keep trying every 5 seconds to connect to server until server is running
        while True:
            try:
                s.connect((HOST, PORT))
                print("Socket connected to server " + HOST + " port: " + str(PORT))
                s.sendall(b'start')
                break

            except socket.error as e:
                print("Failed to connect to server: " + str(e) + " - make sure it's running.")
                time.sleep(5)

        while True:
            self.msg_number += 1
            s.sendall(bytes(str(self.msg_number), 'utf-8'))     # you need to send at least 1 byte to get next message
            data = s.recv(1024)
            if (data == b'None'):
                print('......No more data is coming.  Exiting.')
                exit(0)
            data = data.decode('utf-8').translate({ord(i): None for i in ' ()'}).split(',')
            self.raceData.emit(censusname.generate(), float(data[0]), int(data[1]), int(data[2]))

def run():
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    myReceiver = Receiver()
    engine.rootContext().setContextProperty("Receiver", myReceiver)
    engine.load(os.path.join(os.path.dirname(__file__), "ImprobableRaceClient.qml"))

    listeningThread = threading.Thread(target=myReceiver.handle_race_data, daemon=True)
    listeningThread.start()
    if not engine.rootObjects():
        sys.exit(-1)

    return app.exec_()

if __name__ == "__main__":
    sys.exit(run())
