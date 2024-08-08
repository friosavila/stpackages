import sys
from PyQt6.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, 
                             QPushButton, QTableWidget, QTableWidgetItem, QLineEdit, 
                             QComboBox, QCheckBox, QFileDialog, QMessageBox)
from PyQt6.QtGui import QIcon
from PyQt6.QtCore import Qt
import os

class SoundConverterGUI(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Sound Converter")
        self.setGeometry(100, 100, 800, 600)

        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        layout = QVBoxLayout(central_widget)

        # Top buttons
        top_buttons_layout = QHBoxLayout()
        self.add_file_btn = QPushButton("Add File(s)")
        self.remove_btn = QPushButton("Remove")
        self.play_btn = QPushButton("Play")
        self.options_btn = QPushButton("Options")
        self.upgrade_btn = QPushButton("Upgrade")
        self.share_btn = QPushButton("Share")
        self.suite_btn = QPushButton("Suite")
        self.help_btn = QPushButton("?")

        top_buttons_layout.addWidget(self.add_file_btn)
        top_buttons_layout.addWidget(self.remove_btn)
        top_buttons_layout.addWidget(self.play_btn)
        top_buttons_layout.addStretch()
        top_buttons_layout.addWidget(self.options_btn)
        top_buttons_layout.addWidget(self.upgrade_btn)
        top_buttons_layout.addWidget(self.share_btn)
        top_buttons_layout.addWidget(self.suite_btn)
        top_buttons_layout.addWidget(self.help_btn)

        layout.addLayout(top_buttons_layout)

        # File list table
        self.file_table = QTableWidget(0, 4)
        self.file_table.setHorizontalHeaderLabels(["File Name", "Format", "Size (MB)", "Containing Folder"])
        layout.addWidget(self.file_table)

        # Output folder selection
        output_layout = QHBoxLayout()
        output_layout.addWidget(QLineEdit("C:\\Users\\YourUsername\\Music"))
        self.browse_btn = QPushButton("Browse")
        self.open_output_btn = QPushButton("Open Output Folder")
        output_layout.addWidget(self.browse_btn)
        output_layout.addWidget(self.open_output_btn)
        layout.addLayout(output_layout)

        # Output format selection
        format_layout = QHBoxLayout()
        self.format_combo = QComboBox()
        self.format_combo.addItems(["mp3", "wav", "ogg", "flac"])
        format_layout.addWidget(QLineEdit("Output Format:"))
        format_layout.addWidget(self.format_combo)
        self.format_options_btn = QPushButton("Options...")
        format_layout.addWidget(self.format_options_btn)
        self.same_as_source_cb = QCheckBox("Same as source")
        format_layout.addWidget(self.same_as_source_cb)
        self.copy_folder_structure_cb = QCheckBox("Copy folder structure of source files")
        format_layout.addWidget(self.copy_folder_structure_cb)
        self.convert_btn = QPushButton("Convert")
        format_layout.addWidget(self.convert_btn)
        layout.addLayout(format_layout)

        # Connect buttons to functions
        self.add_file_btn.clicked.connect(self.add_files)
        self.remove_btn.clicked.connect(self.remove_files)
        self.play_btn.clicked.connect(self.play_file)
        self.browse_btn.clicked.connect(self.browse_output_folder)
        self.open_output_btn.clicked.connect(self.open_output_folder)
        self.convert_btn.clicked.connect(self.convert_files)

    def add_files(self):
        files, _ = QFileDialog.getOpenFileNames(self, "Select Audio Files", "", "Audio Files (*.mp3 *.wav *.ogg *.flac)")
        for file in files:
            file_name = os.path.basename(file)
            file_format = os.path.splitext(file_name)[1][1:]
            file_size = round(os.path.getsize(file) / (1024 * 1024), 3)
            containing_folder = os.path.dirname(file)
            
            row_position = self.file_table.rowCount()
            self.file_table.insertRow(row_position)
            self.file_table.setItem(row_position, 0, QTableWidgetItem(file_name))
            self.file_table.setItem(row_position, 1, QTableWidgetItem(file_format))
            self.file_table.setItem(row_position, 2, QTableWidgetItem(str(file_size)))
            self.file_table.setItem(row_position, 3, QTableWidgetItem(containing_folder))

    def remove_files(self):
        selected_rows = set(index.row() for index in self.file_table.selectedIndexes())
        for row in sorted(selected_rows, reverse=True):
            self.file_table.removeRow(row)

    def play_file(self):
        selected_items = self.file_table.selectedItems()
        if selected_items:
            file_name = selected_items[0].text()
            QMessageBox.information(self, "Play File", f"Playing {file_name}")
        else:
            QMessageBox.warning(self, "No File Selected", "Please select a file to play.")

    def browse_output_folder(self):
        folder = QFileDialog.getExistingDirectory(self, "Select Output Folder")
        if folder:
            self.output_folder_edit.setText(folder)

    def open_output_folder(self):
        folder = self.output_folder_edit.text()
        if os.path.exists(folder):
            os.startfile(folder)
        else:
            QMessageBox.warning(self, "Folder Not Found", "The specified output folder does not exist.")

    def convert_files(self):
        output_format = self.format_combo.currentText()
        same_as_source = self.same_as_source_cb.isChecked()
        copy_folder_structure = self.copy_folder_structure_cb.isChecked()
        
        files_to_convert = []
        for row in range(self.file_table.rowCount()):
            file_name = self.file_table.item(row, 0).text()
            file_format = self.file_table.item(row, 1).text()
            files_to_convert.append((file_name, file_format))
        
        conversion_summary = f"Converting {len(files_to_convert)} files to {output_format}\n"
        conversion_summary += f"Same as source: {same_as_source}\n"
        conversion_summary += f"Copy folder structure: {copy_folder_structure}\n"
        conversion_summary += "Files:\n" + "\n".join([f"{name} ({fmt})" for name, fmt in files_to_convert])
        
        QMessageBox.information(self, "Conversion Started", conversion_summary)

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = SoundConverterGUI()
    window.show()
    sys.exit(app.exec())