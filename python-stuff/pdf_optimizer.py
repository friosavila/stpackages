import os
import io
from pypdf import PdfReader, PdfWriter
from PIL import Image
import tkinter as tk
from tkinter import filedialog, ttk, messagebox
import threading

def optimize_pdf(input_path, output_path, compress_images=True, remove_metadata=True, flatten_forms=True):
    reader = PdfReader(input_path)
    writer = PdfWriter()

    # Handle metadata
    if remove_metadata:
        writer.add_metadata({"/Producer": ""})
    else:
        writer.add_metadata(reader.metadata)

    for page in reader.pages:
        if flatten_forms:
            # Flatten form fields by merging them into the page content
            page.merge_page(page)

        writer.add_page(page)

        # Compress images if specified
        if compress_images:
            for image in page.images:
                with Image.open(io.BytesIO(image.data)) as img:
                    if img.mode == 'RGBA':
                        continue
                    
                    if img.mode != 'RGB':
                        img = img.convert('RGB')
                    
                    compressed_img = io.BytesIO()
                    img.save(compressed_img, format='JPEG', quality=85, optimize=True)
                    
                    image.data = compressed_img.getvalue()

    # Save the optimized PDF
    with open(output_path, 'wb') as f:
        writer.write(f)

class Application(tk.Frame):
    def __init__(self, master=None):
        super().__init__(master)
        self.master = master
        self.pack()
        self.create_widgets()

    def create_widgets(self):
        self.select_files_button = tk.Button(self)
        self.select_files_button["text"] = "Select PDF Files"
        self.select_files_button["command"] = self.select_files
        self.select_files_button.pack(side="top")

        self.compress_images_var = tk.BooleanVar(value=True)
        self.compress_images_check = tk.Checkbutton(self, text="Compress Images", variable=self.compress_images_var)
        self.compress_images_check.pack()

        self.remove_metadata_var = tk.BooleanVar(value=True)
        self.remove_metadata_check = tk.Checkbutton(self, text="Remove Metadata", variable=self.remove_metadata_var)
        self.remove_metadata_check.pack()

        self.flatten_forms_var = tk.BooleanVar(value=True)
        self.flatten_forms_check = tk.Checkbutton(self, text="Flatten Forms", variable=self.flatten_forms_var)
        self.flatten_forms_check.pack()

        self.optimize_button = tk.Button(self)
        self.optimize_button["text"] = "Optimize PDFs"
        self.optimize_button["command"] = self.start_optimization
        self.optimize_button.pack(side="top")

        self.progress = ttk.Progressbar(self, orient="horizontal", length=200, mode="determinate")
        self.progress.pack()

        self.quit = tk.Button(self, text="QUIT", fg="red", command=self.master.destroy)
        self.quit.pack(side="bottom")

    def select_files(self):
        self.filenames = filedialog.askopenfilenames(filetypes=[("PDF Files", "*.pdf")])

    def start_optimization(self):
        if not hasattr(self, 'filenames') or not self.filenames:
            messagebox.showerror("Error", "No files selected!")
            return
        
        self.progress["value"] = 0
        self.progress["maximum"] = len(self.filenames)
        
        threading.Thread(target=self.optimize_files).start()

    def optimize_files(self):
        for filename in self.filenames:
            output_filename = os.path.splitext(filename)[0] + "_optimized.pdf"
            try:
                optimize_pdf(filename, output_filename, 
                             compress_images=self.compress_images_var.get(),
                             remove_metadata=self.remove_metadata_var.get(),
                             flatten_forms=self.flatten_forms_var.get())
            except Exception as e:
                messagebox.showerror("Error", f"Failed to optimize {filename}: {str(e)}")
            self.progress["value"] += 1
            self.update_idletasks()
        
        messagebox.showinfo("Success", "All files have been optimized!")

root = tk.Tk()
app = Application(master=root)
app.mainloop()