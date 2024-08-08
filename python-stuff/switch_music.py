import tkinter as tk
from tkinter import filedialog, ttk
import subprocess
import os
from tqdm import tqdm

class AudioConverterApp:
    def __init__(self, master):
        self.master = master
        master.title("Advanced Audio Converter")
        master.geometry("600x500")
        master.resizable(False, False)
        
        self.style = ttk.Style()
        self.style.theme_use('clam')
        
        self.files = []
        self.output_format = "mp3"
        self.format_options = {
            "mp3": {"bitrate": "192k", "quality": "0"},
            "aac": {"bitrate": "192k"},
            "opus": {"bitrate": "128k"},
            "wav": {"bits_per_sample": "16"},
            "flac": {"compression_level": "5"},
            "m4a": {"bitrate": "192k"},
            "m4b": {"bitrate": "192k"}
        }
        
        self.create_widgets()

    def create_widgets(self):
        main_frame = ttk.Frame(self.master, padding="20 20 20 20")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        self.label = ttk.Label(main_frame, text="Select audio files to convert:")
        self.label.grid(row=0, column=0, columnspan=2, pady=(0, 10), sticky=tk.W)
        
        self.select_button = ttk.Button(main_frame, text="Select Files", command=self.select_files)
        self.select_button.grid(row=1, column=0, sticky=tk.W)
        
        self.status_label = ttk.Label(main_frame, text="No files selected")
        self.status_label.grid(row=1, column=1, padx=(10, 0), sticky=tk.W)
        
        format_frame = ttk.LabelFrame(main_frame, text="Output Options", padding="10 10 10 10")
        format_frame.grid(row=2, column=0, columnspan=2, pady=(20, 0), sticky=(tk.W, tk.E))
        
        ttk.Label(format_frame, text="Format:").grid(row=0, column=0, sticky=tk.W)
        
        self.format_var = tk.StringVar(value="mp3")
        formats = ["mp3", "aac", "opus", "wav", "flac", "m4a", "m4b"]
        self.format_combo = ttk.Combobox(format_frame, textvariable=self.format_var, values=formats, state="readonly", width=5)
        self.format_combo.grid(row=0, column=1, padx=(10, 0), sticky=tk.W)
        self.format_combo.bind("<<ComboboxSelected>>", self.update_output_format)
        
        self.options_frame = ttk.Frame(format_frame)
        self.options_frame.grid(row=1, column=0, columnspan=2, pady=(10, 0), sticky=(tk.W, tk.E))
        
        self.convert_button = ttk.Button(main_frame, text="Convert", command=self.convert_audio)
        self.convert_button.grid(row=3, column=0, columnspan=2, pady=(20, 0))
        
        self.progress = ttk.Progressbar(main_frame, orient="horizontal", length=560, mode="determinate")
        self.progress.grid(row=4, column=0, columnspan=2, pady=(20, 0))
        
        self.result_label = ttk.Label(main_frame, text="")
        self.result_label.grid(row=5, column=0, columnspan=2, pady=(10, 0))
        
        self.update_output_format()

    def select_files(self):
        self.files = filedialog.askopenfilenames(filetypes=[("Audio files", "*.mp3 *.aac *.opus *.wav *.flac *.m4a *.m4b")])
        self.status_label.config(text=f"{len(self.files)} files selected")

    def update_output_format(self, event=None):
        self.output_format = self.format_var.get()
        for widget in self.options_frame.winfo_children():
            widget.destroy()
        
        row = 0
        for option, value in self.format_options[self.output_format].items():
            ttk.Label(self.options_frame, text=f"{option.replace('_', ' ').title()}:").grid(row=row, column=0, sticky=tk.W)
            entry = ttk.Entry(self.options_frame, width=10)
            entry.insert(0, value)
            entry.grid(row=row, column=1, padx=(10, 0), sticky=tk.W)
            setattr(self, f"{self.output_format}_{option}", entry)
            row += 1

    def convert_audio(self):
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
                base_name = os.path.splitext(os.path.basename(file))[0]
                output_path = os.path.join(output_dir, f"{base_name}.{self.output_format}")
                
                ffmpeg_cmd = ["ffmpeg", "-i", file]
                
                for option, entry in self.format_options[self.output_format].items():
                    value = getattr(self, f"{self.output_format}_{option}").get()
                    if self.output_format == "mp3":
                        if option == "bitrate":
                            ffmpeg_cmd.extend(["-b:a", value])
                        elif option == "quality":
                            ffmpeg_cmd.extend(["-q:a", value])
                    elif self.output_format in ["aac", "m4a", "m4b"]:
                        if option == "bitrate":
                            ffmpeg_cmd.extend(["-b:a", value])
                    elif self.output_format == "opus":
                        if option == "bitrate":
                            ffmpeg_cmd.extend(["-b:a", value])
                    elif self.output_format == "wav":
                        if option == "bits_per_sample":
                            ffmpeg_cmd.extend(["-acodec", f"pcm_s{value}le"])
                    elif self.output_format == "flac":
                        if option == "compression_level":
                            ffmpeg_cmd.extend(["-compression_level", value])
                
                ffmpeg_cmd.append(output_path)
                
                subprocess.run(ffmpeg_cmd, check=True, stderr=subprocess.DEVNULL)
                converted_count += 1
            except Exception as e:
                print(f"Error converting {file}: {str(e)}")
            finally:
                self.progress["value"] = i + 1
                self.master.update_idletasks()
        
        self.result_label.config(text=f"Conversion complete! {converted_count}/{len(self.files)} audio files converted.")

root = tk.Tk()
app = AudioConverterApp(root)
root.mainloop()