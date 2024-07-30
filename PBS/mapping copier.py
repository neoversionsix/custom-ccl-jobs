import sys
import pandas as pd
from PyQt5.QtWidgets import QApplication, QMainWindow, QLabel, QVBoxLayout, QWidget
from PyQt5.QtCore import Qt, QMimeData, pyqtSignal
from PyQt5.QtGui import QDragEnterEvent, QDropEvent

class DragDropSquare(QLabel):
    dataFrameLoaded = pyqtSignal(object)  # Signal to emit when DataFrame is loaded

    def __init__(self, title):
        super().__init__()
        self.setAlignment(Qt.AlignCenter)
        self.setText(f"{title}\n\nDrag and drop xlsx file here")
        self.setStyleSheet("""
            QLabel {
                border: 2px dashed #aaa;
                border-radius: 5px;
                padding: 10px;
                background: #f0f0f0;
            }
        """)
        self.setAcceptDrops(True)
        self.df = None

    def dragEnterEvent(self, event: QDragEnterEvent):
        if event.mimeData().hasUrls():
            event.accept()
        else:
            event.ignore()

    def dropEvent(self, event: QDropEvent):
        files = [u.toLocalFile() for u in event.mimeData().urls()]
        if files:
            file_path = files[0]
            if file_path.endswith('.xlsx'):
                try:
                    self.df = pd.read_excel(file_path)
                    self.dataFrameLoaded.emit(self.df)  # Emit signal with loaded DataFrame
                    file_name = file_path.split('/')[-1]
                    self.setText(f"{self.text().split()[0]}\n\n{file_name}")
                    self.setStyleSheet("""
                        QLabel {
                            border: 2px solid #5c5;
                            border-radius: 5px;
                            padding: 10px;
                            background: #efe;
                        }
                    """)
                except Exception as e:
                    self.setText(f"{self.text().split()[0]}\n\nError: {str(e)}")
                    self.setStyleSheet("""
                        QLabel {
                            border: 2px solid #c55;
                            border-radius: 5px;
                            padding: 10px;
                            background: #fee;
                        }
                    """)
            else:
                self.setText(f"{self.text().split()[0]}\n\nError: Not an xlsx file")
                self.setStyleSheet("""
                    QLabel {
                        border: 2px solid #c55;
                        border-radius: 5px;
                        padding: 10px;
                        background: #fee;
                    }
                """)

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Excel File Loader")
        self.setGeometry(100, 100, 600, 400)

        layout = QVBoxLayout()
        
        self.cert_mappings = DragDropSquare("CERT MAPPINGS")
        self.prod_mappings = DragDropSquare("PROD MAPPINGS")
        self.cert_catalog = DragDropSquare("CERT CATALOG")

        layout.addWidget(self.cert_mappings)
        layout.addWidget(self.prod_mappings)
        layout.addWidget(self.cert_catalog)

        container = QWidget()
        container.setLayout(layout)
        self.setCentralWidget(container)

        # Initialize DataFrame attributes
        self.cert_mappings_df = None
        self.prod_mappings_df = None
        self.cert_catalog_df = None

        # Connect signals to update DataFrames
        self.cert_mappings.dataFrameLoaded.connect(self.update_cert_mappings_df)
        self.prod_mappings.dataFrameLoaded.connect(self.update_prod_mappings_df)
        self.cert_catalog.dataFrameLoaded.connect(self.update_cert_catalog_df)

    def update_cert_mappings_df(self, df):
        self.cert_mappings_df = df

    def update_prod_mappings_df(self, df):
        self.prod_mappings_df = df

    def update_cert_catalog_df(self, df):
        self.cert_catalog_df = df

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()

    # After loading the files, you can access the DataFrames like this:
    # cert_mappings_df = window.cert_mappings_df
    # prod_mappings_df = window.prod_mappings_df
    # cert_catalog_df = window.cert_catalog_df

    sys.exit(app.exec_())