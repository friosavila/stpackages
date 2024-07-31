import tkinter as tk
from tkinter import filedialog, ttk
from PIL import Image
import os
from tqdm import tqdm

class ImageConverterApp:
    def __init__(self, master):
        self.master = master
        master.title("Advanced Image Converter")
        master.geometry("500x400")
        master.resizable(False, False)
        
        self.style = ttk.Style()
        self.style.theme_use('clam')
        
        self.create_widgets()
        
        self.files = []
        self.output_format = ".png"

    def create_widgets(self):
        main_frame = ttk.Frame(self.master, padding="20 20 20 20")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        self.label = ttk.Label(main_frame, text="Select images to convert:")
        self.label.grid(row=0, column=0, columnspan=2, pady=(0, 10), sticky=tk.W)
        
        self.select_button = ttk.Button(main_frame, text="Select Files", command=self.select_files)
        self.select_button.grid(row=1, column=0, sticky=tk.W)
        
        self.status_label = ttk.Label(main_frame, text="No files selected")
        self.status_label.grid(row=1, column=1, padx=(10, 0), sticky=tk.W)
        
        format_frame = ttk.LabelFrame(main_frame, text="Output Options", padding="10 10 10 10")
        format_frame.grid(row=2, column=0, columnspan=2, pady=(20, 0), sticky=(tk.W, tk.E))
        
        ttk.Label(format_frame, text="Format:").grid(row=0, column=0, sticky=tk.W)
        
        self.format_var = tk.StringVar(value=".png")
        formats = [".png", ".jpg", ".bmp", ".gif"]
        self.format_combo = ttk.Combobox(format_frame, textvariable=self.format_var, values=formats, state="readonly", width=5)
        self.format_combo.grid(row=0, column=1, padx=(10, 0), sticky=tk.W)
        self.format_combo.bind("<<ComboboxSelected>>", self.update_output_format)
        
        # PNG options
        self.png_frame = ttk.Frame(format_frame)
        self.png_frame.grid(row=1, column=0, columnspan=2, pady=(10, 0), sticky=(tk.W, tk.E))
        ttk.Label(self.png_frame, text="Compression:").grid(row=0, column=0, sticky=tk.W)
        self.png_compression = tk.IntVar(value=6)
        ttk.Spinbox(self.png_frame, from_=0, to=9, textvariable=self.png_compression, width=5).grid(row=0, column=1, padx=(10, 0), sticky=tk.W)
        
        # JPEG options
        self.jpg_frame = ttk.Frame(format_frame)
        self.jpg_frame.grid(row=1, column=0, columnspan=2, pady=(10, 0), sticky=(tk.W, tk.E))
        ttk.Label(self.jpg_frame, text="Quality:").grid(row=0, column=0, sticky=tk.W)
        self.jpg_quality = tk.IntVar(value=85)
        ttk.Spinbox(self.jpg_frame, from_=1, to=95, textvariable=self.jpg_quality, width=5).grid(row=0, column=1, padx=(10, 0), sticky=tk.W)
        
        # GIF options
        self.gif_frame = ttk.Frame(format_frame)
        self.gif_frame.grid(row=1, column=0, columnspan=2, pady=(10, 0), sticky=(tk.W, tk.E))
        self.gif_optimize = tk.BooleanVar(value=True)
        ttk.Checkbutton(self.gif_frame, text="Optimize", variable=self.gif_optimize).grid(row=0, column=0, sticky=tk.W)
        
        self.convert_button = ttk.Button(main_frame, text="Convert", command=self.convert_images)
        self.convert_button.grid(row=3, column=0, columnspan=2, pady=(20, 0))
        
        self.progress = ttk.Progressbar(main_frame, orient="horizontal", length=460, mode="determinate")
        self.progress.grid(row=4, column=0, columnspan=2, pady=(20, 0))
        
        self.result_label = ttk.Label(main_frame, text="")
        self.result_label.grid(row=5, column=0, columnspan=2, pady=(10, 0))
        
        self.update_output_format()

    def select_files(self):
        self.files = filedialog.askopenfilenames(filetypes=[("Image files", "*.jpg *.jpeg *.png *.bmp *.gif")])
        self.status_label.config(text=f"{len(self.files)} files selected")

    def update_output_format(self, event=None):
        self.output_format = self.format_var.get()
        self.png_frame.grid_remove()
        self.jpg_frame.grid_remove()
        self.gif_frame.grid_remove()
        
        if self.output_format == '.png':
            self.png_frame.grid()
        elif self.output_format in ['.jpg', '.jpeg']:
            self.jpg_frame.grid()
        elif self.output_format == '.gif':
            self.gif_frame.grid()

    def convert_images(self):
        if not self.files:
            self.result_label.config(text="No files selected!")
            return
        
        output_dir = filedialog.askdirectory(title="Select Output Directory")
        if not output_dir:
            return
        
        self.progress["value"] = 0
        self.progress["maximum"] = len(self.files)
        
        converted_count = 0
        for i, file in enumerate(tqdm(self.files)):
            try:
                img = Image.open(file)
                
                # Convert RGBA to RGB if saving as JPEG
                if img.mode == 'RGBA' and self.output_format.lower() in ['.jpg', '.jpeg']:
                    img = img.convert('RGB')
                
                base_name = os.path.splitext(os.path.basename(file))[0]
                output_path = os.path.join(output_dir, f"{base_name}{self.output_format}")
                
                save_args = {}
                if self.output_format == '.png':
                    save_args['compress_level'] = self.png_compression.get()
                elif self.output_format in ['.jpg', '.jpeg']:
                    save_args['quality'] = self.jpg_quality.get()
                elif self.output_format == '.gif':
                    save_args['optimize'] = self.gif_optimize.get()
                
                img.save(output_path, **save_args)
                converted_count += 1
            except Exception as e:
                print(f"Error converting {file}: {str(e)}")
            finally:
                self.progress["value"] = i + 1
                self.master.update_idletasks()
        
        self.result_label.config(text=f"Conversion complete! {converted_count}/{len(self.files)} images converted.")

root = tk.Tk()
app = ImageConverterApp(root)
root.mainloop()