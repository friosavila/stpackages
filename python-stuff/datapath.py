import os
from pathlib import Path
import sys

def create_directory_tree(root_path, output_file, indent="", is_last=True):
    root = Path(root_path)
    
    output_file.write(f"{indent}{'└── ' if is_last else '├── '}{root.name}/\n")
    
    indent += "    " if is_last else "│   "
    
    entries = list(root.iterdir())
    entries.sort(key=lambda x: (not x.is_dir(), x.name.lower()))
    
    file_extensions = set()
    
    for i, entry in enumerate(entries):
        if entry.is_dir():
            create_directory_tree(entry, output_file, indent, i == len(entries) - 1)
        else:
            file_extensions.add(entry.suffix.lower() if entry.suffix else "(no extension)")
    
    for i, ext in enumerate(sorted(file_extensions)):
        is_last_ext = i == len(file_extensions) - 1
        output_file.write(f"{indent}{'└── ' if is_last_ext else '├── '}*{ext}\n")

def main():
    if len(sys.argv) > 1:
        root_directory = sys.argv[1]
    else:
        root_directory = "."
    
    output_filename = "directory_tree.txt"
    
    with open(output_filename, 'w', encoding='utf-8') as output_file:
        create_directory_tree(root_directory, output_file)
    
    print(f"Directory tree has been saved to {output_filename}")
    input("Press Enter to exit...")

if __name__ == "__main__":
    main()