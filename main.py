import sys
import os
import shutil
from PyQt6.QtWidgets import QApplication, QFileDialog
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtCore import QObject, pyqtSlot, pyqtSignal, pyqtProperty

class Backend(QObject):
    processingChanged = pyqtSignal()
    toastMessageChanged = pyqtSignal()

    def __init__(self, engine):
        super().__init__()
        self.engine = engine
        self._processing = False
        self._toastMessage = ""

    # Properties for QML binding
    @pyqtProperty(bool, notify=processingChanged)
    def processing(self):
        return self._processing

    @processing.setter
    def processing(self, value):
        if self._processing != value:
            self._processing = value
            self.processingChanged.emit()

    @pyqtProperty(str, notify=toastMessageChanged)
    def toastMessage(self):
        return self._toastMessage

    @toastMessage.setter
    def toastMessage(self, value):
        if self._toastMessage != value:
            self._toastMessage = value
            self.toastMessageChanged.emit()

    # Directory picker
    @pyqtSlot()
    def browseDirectory(self):
        try:
            folder = QFileDialog.getExistingDirectory(None, "Select Directory")
            if folder:
                root = self.engine.rootObjects()
                if root:
                    directoryField = root[0].findChild(QObject, "directoryInput")
                    if directoryField:
                        directoryField.setProperty("text", folder)
                    else:
                        self.toastMessage = "Error: could not find 'directoryInput'"
                else:
                    self.toastMessage = "Error: no root objects loaded"
        except Exception as e:
            self.toastMessage = f"Error opening folder dialog: {e}"

    # Separate files
    @pyqtSlot(str, str)
    def separateFiles(self, directoryPath, fileNames):
        try:
            self.processing = True
            files = [f.strip() for f in fileNames.splitlines() if f.strip()]
            found_dir = os.path.join(directoryPath, "found")
            other_dir = os.path.join(directoryPath, "other")

            os.makedirs(found_dir, exist_ok=True)
            os.makedirs(other_dir, exist_ok=True)

            for f in os.listdir(directoryPath):
                full_path = os.path.join(directoryPath, f)
                if os.path.isfile(full_path):
                    if f in files:
                        shutil.move(full_path, os.path.join(found_dir, f))
                    else:
                        shutil.move(full_path, os.path.join(other_dir, f))

            self.toastMessage = "Files separated successfully!"

        except Exception as e:
            self.toastMessage = f"Error: {e}"

        finally:
            self.processing = False


if __name__ == "__main__":
    try:
        app = QApplication(sys.argv)
        engine = QQmlApplicationEngine()
        backend = Backend(engine)
        engine.rootContext().setContextProperty("backend", backend)

        engine.load(os.path.join(os.path.dirname(__file__), "ui/main.qml"))
        if not engine.rootObjects():
            print("Failed to load QML")
            sys.exit(1)

        sys.exit(app.exec())
    except Exception as e:
        print(f"Unhandled exception: {e}")
        sys.exit(1)
