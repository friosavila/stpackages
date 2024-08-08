import tkinter as tk
from tkinter import filedialog, messagebox, ttk
import os
import re

def is_binary(file_path, sample_size=1024):
    try:
        with open(file_path, 'rb') as file:
            return b'\0' in file.read(sample_size)
    except IOError:
        return False

def explore_and_write(root_path, output_file, status_var, selected_items):
    with open(output_file, 'w', encoding='utf-8') as out_file:
        for item_path in selected_items:
            full_path = os.path.join(root_path, item_path)
            if os.path.isfile(full_path):
                process_file(full_path, root_path, out_file, status_var)
            elif os.path.isdir(full_path):
                for root, _, files in os.walk(full_path):
                    for file in files:
                        file_path = os.path.join(root, file)
                        process_file(file_path, root_path, out_file, status_var)
    return output_file

def process_file(file_path, root_path, out_file, status_var):
    relative_path = os.path.relpath(file_path, root_path)
    status_var.set(f"Processing: {relative_path}")
    out_file.write(f"file:{relative_path}\n\n")
    
    if is_binary(file_path):
        out_file.write("```\nbinary file. No text inside\n```\n\n")
    else:
        out_file.write("```\n")
        try:
            with open(file_path, 'r', encoding='utf-8') as in_file:
                out_file.write(in_file.read())
        except UnicodeDecodeError:
            out_file.write("Error: Unable to decode file content.\n")
        out_file.write("```\n\n")

def reconstruct_files(input_file, output_dir, status_var):
    with open(input_file, 'r', encoding='utf-8') as file:
        content = file.read()

    file_sections = re.split(r'file:', content)[1:]

    for section in file_sections:
        lines = section.strip().split('\n')
        file_path = lines[0].strip()
        file_content = '\n'.join(lines[1:])

        status_var.set(f"Reconstructing: {file_path}")

        file_content = re.sub(r'```[\s\S]*?```', lambda m: m.group(0).strip('`').strip(), file_content)

        if "binary file. No text inside" in file_content:
            continue

        full_path = os.path.join(output_dir, file_path)
        os.makedirs(os.path.dirname(full_path), exist_ok=True)

        with open(full_path, 'w', encoding='utf-8') as out_file:
            out_file.write(file_content.strip())

class CheckboxTreeview(ttk.Treeview):
    def __init__(self, master=None, **kw):
        ttk.Treeview.__init__(self, master, **kw)
        self.bind('<Button-1>', self.toggle_check)

    def toggle_check(self, event):
        item = self.identify_row(event.y)
        if item:
            tags = list(self.item(item, 'tags'))
            checked = 'checked' in tags
            self.change_state(item, not checked)

    def change_state(self, item, checked):
        tags = list(self.item(item, 'tags'))
        tags = [tag for tag in tags if tag not in ('checked', 'unchecked')]
        tags.append('checked' if checked else 'unchecked')
        self.item(item, tags=tags)
        text = self.item(item, 'text')
        self.item(item, text=('☑ ' if checked else '☐ ') + text.lstrip('☑☐ '))

class FolderSelector(tk.Toplevel):
    def __init__(self, parent, root_path):
        super().__init__(parent)
        self.title("Select Folders and Files")
        self.geometry("500x600")
        self.root_path = root_path
        self.selected_items = []

        self.tree = CheckboxTreeview(self, columns=("fullpath",), displaycolumns=(), selectmode="none")
        self.tree.heading('#0', text='Folder/File', anchor='w')
        self.tree.column('#0', width=400)
        self.tree.pack(expand=True, fill='both')

        ysb = ttk.Scrollbar(self, orient='vertical', command=self.tree.yview)
        xsb = ttk.Scrollbar(self, orient='horizontal', command=self.tree.xview)
        self.tree.configure(yscroll=ysb.set, xscroll=xsb.set)
        ysb.pack(side='right', fill='y')
        xsb.pack(side='bottom', fill='x')

        self.populate_tree()

        btn_frame = ttk.Frame(self)
        btn_frame.pack(fill='x', pady=10)
        ttk.Button(btn_frame, text="OK", command=self.on_ok).pack(side='right', padx=5)
        ttk.Button(btn_frame, text="Cancel", command=self.destroy).pack(side='right')

    def populate_tree(self):
        self.tree.delete(*self.tree.get_children())
        self.insert_node('', self.root_path, os.path.basename(self.root_path))

    def insert_node(self, parent, path, text):
        node = self.tree.insert(parent, 'end', text='☐ ' + text, tags=('unchecked',), open=False, values=(path,))
        if os.path.isdir(path):
            try:
                for item in os.listdir(path):
                    full_path = os.path.join(path, item)
                    self.insert_node(node, full_path, item)
            except PermissionError:
                pass  # Skip folders we don't have permission to access

    def on_ok(self):
        self.selected_items = []
        self.get_checked_items('')
        self.destroy()

    def get_checked_items(self, parent):
        for item in self.tree.get_children(parent):
            if 'checked' in self.tree.item(item, 'tags'):
                item_path = self.tree.item(item, 'values')[0]
                relative_path = os.path.relpath(item_path, self.root_path)
                self.selected_items.append(relative_path)
            else:
                self.get_checked_items(item)

class FileExplorerReconstructorGUI:
    def __init__(self, master):
        self.master = master
        master.title("File Explorer and Reconstructor")
        master.geometry("600x400")

        style = ttk.Style()
        style.theme_use('clam')

        self.create_widgets()

    def create_widgets(self):
        main_frame = ttk.Frame(self.master, padding="10")
        main_frame.pack(fill=tk.BOTH, expand=True)

        # Explore and Write section
        explore_frame = ttk.LabelFrame(main_frame, text="Explore and Write", padding="10")
        explore_frame.pack(fill=tk.X, pady=5)

        self.explore_path_var = tk.StringVar()
        ttk.Entry(explore_frame, textvariable=self.explore_path_var).pack(side=tk.LEFT, expand=True, fill=tk.X)
        ttk.Button(explore_frame, text="Browse", command=self.browse_explore).pack(side=tk.LEFT, padx=5)
        ttk.Button(explore_frame, text="Select Items", command=self.select_items).pack(side=tk.LEFT, padx=5)
        ttk.Button(explore_frame, text="Explore and Write", command=self.explore_and_write).pack(side=tk.LEFT)

        # Reconstruct section
        reconstruct_frame = ttk.LabelFrame(main_frame, text="Reconstruct Files", padding="10")
        reconstruct_frame.pack(fill=tk.X, pady=5)

        self.reconstruct_path_var = tk.StringVar()
        ttk.Entry(reconstruct_frame, textvariable=self.reconstruct_path_var).pack(side=tk.LEFT, expand=True, fill=tk.X)
        ttk.Button(reconstruct_frame, text="Browse", command=self.browse_reconstruct).pack(side=tk.LEFT, padx=5)
        ttk.Button(reconstruct_frame, text="Reconstruct Files", command=self.reconstruct_files).pack(side=tk.LEFT)

        # Status bar
        self.status_var = tk.StringVar()
        self.status_var.set("Ready")
        status_bar = ttk.Label(main_frame, textvariable=self.status_var, relief=tk.SUNKEN, anchor=tk.W)
        status_bar.pack(side=tk.BOTTOM, fill=tk.X)

        self.selected_items = []

    def browse_explore(self):
        path = filedialog.askdirectory(title="Select Directory to Explore")
        if path:
            self.explore_path_var.set(path)
            self.selected_items = []  # Reset selected items when new root is chosen

    def select_items(self):
        if not self.explore_path_var.get():
            messagebox.showerror("Error", "Please select a root directory first")
            return
        
        selector = FolderSelector(self.master, self.explore_path_var.get())
        self.master.wait_window(selector)
        self.selected_items = selector.selected_items
        if self.selected_items:
            self.status_var.set(f"Selected {len(self.selected_items)} item(s)")
        else:
            self.status_var.set("No items selected")

    def browse_reconstruct(self):
        path = filedialog.askopenfilename(filetypes=[("Text files", "*.txt")])
        if path:
            self.reconstruct_path_var.set(path)

    def explore_and_write(self):
        root_path = self.explore_path_var.get()
        if not root_path:
            messagebox.showerror("Error", "Please select a directory to explore")
            return
        
        if not self.selected_items:
            messagebox.showerror("Error", "Please select items to explore")
            return

        output_file = filedialog.asksaveasfilename(defaultextension=".txt", filetypes=[("Text files", "*.txt")])
        if not output_file:
            return

        try:
            result_file = explore_and_write(root_path, output_file, self.status_var, self.selected_items)
            self.status_var.set("Ready")
            messagebox.showinfo("Success", f"File exploration completed. Output saved to {result_file}")
        except Exception as e:
            self.status_var.set("Error occurred")
            messagebox.showerror("Error", f"An error occurred: {str(e)}")

    def reconstruct_files(self):
        input_file = self.reconstruct_path_var.get()
        if not input_file:
            messagebox.showerror("Error", "Please select an input file")
            return

        output_dir = filedialog.askdirectory(title="Select Directory to Reconstruct Files")
        if not output_dir:
            return

        try:
            reconstruct_files(input_file, output_dir, self.status_var)
            self.status_var.set("Ready")
            messagebox.showinfo("Success", f"Files reconstructed in {output_dir}")
        except Exception as e:
            self.status_var.set("Error occurred")
            messagebox.showerror("Error", f"An error occurred: {str(e)}")

if __name__ == "__main__":
    root = tk.Tk()
    gui = FileExplorerReconstructorGUI(root)
    root.mainloop()