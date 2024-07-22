import os
from pathlib import Path

def find_dta_files(root_path, output_file):
    root = Path(root_path).resolve()  # Get the absolute path
    
    with open(output_file, 'w') as f:
        for path in root.rglob('*.dta'):
            relative_path = path.relative_to(root)
            f.write(f"{relative_path}\n")

# Usage
root_directory = "."  # Current directory
output_file = "dta_files_list.txt"  # Name of the output file

find_dta_files(root_directory, output_file)
print(f"List of .dta files has been written to {output_file}")