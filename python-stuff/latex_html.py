import re

def latex_to_html_table(latex_table):
    # Remove any leading/trailing whitespace and split into lines
    lines = latex_table.strip().split('\n')
    
    # Initialize variables
    html_table = []
    in_table = False
    table_specs = {}
    current_row = []
    
    for line in lines:
        line = line.strip()
        
        # Check for table environment
        if line.startswith(r'\begin{table}') or line.startswith(r'\begin{tabular}'):
            in_table = True
            html_table.append('<table>')
            continue
        elif line.startswith(r'\end{table}') or line.startswith(r'\end{tabular}'):
            in_table = False
            if current_row:
                html_table.append('  <tr>' + ''.join(current_row) + '</tr>')
            html_table.append('</table>')
            break
        
        if not in_table:
            continue
        
        # Handle table specifications
        if line.startswith('{') and '}' in line:
            specs = line[1:line.index('}')]
            table_specs = parse_table_specs(specs)
            continue
        
        # Handle \hline
        if line == r'\hline':
            if current_row:
                html_table.append('  <tr>' + ''.join(current_row) + '</tr>')
                current_row = []
            html_table.append('  <tr><td colspan="100%" style="border-bottom: 1px solid black;"></td></tr>')
            continue
        
        # Process table row
        cells = re.split(r'(?<!\\)&', line)
        for i, cell in enumerate(cells):
            cell = cell.strip()
            if cell == r'\hline':
                continue
            
            # Check for multicolumn
            multicolumn_match = re.match(r'\\multicolumn{(\d+)}{([^}]*)}{(.*)}', cell)
            if multicolumn_match:
                colspan, align, content = multicolumn_match.groups()
                style = f'colspan="{colspan}" style="text-align: {get_alignment(align)};"'
                cell_content = process_cell_content(content)
            else:
                style = f'style="text-align: {get_alignment(table_specs.get(i, "l"))};"'
                cell_content = process_cell_content(cell)
            
            current_row.append(f'<td {style}>{cell_content}</td>')
        
        # End of row
        if line.endswith(r'\\'):
            html_table.append('  <tr>' + ''.join(current_row) + '</tr>')
            current_row = []
    
    return '\n'.join(html_table)

def parse_table_specs(specs):
    spec_map = {'l': 'left', 'c': 'center', 'r': 'right'}
    return {i: spec_map.get(spec, 'left') for i, spec in enumerate(specs) if spec in spec_map}

def get_alignment(spec):
    spec_map = {'l': 'left', 'c': 'center', 'r': 'right'}
    return spec_map.get(spec.strip(), 'left')

def process_cell_content(content):
    # Handle basic LaTeX formatting
    content = re.sub(r'\\textbf{([^}]*)}', r'<strong>\1</strong>', content)
    content = re.sub(r'\\textit{([^}]*)}', r'<em>\1</em>', content)
    content = re.sub(r'\\underline{([^}]*)}', r'<u>\1</u>', content)
    content = content.replace(r'\%', '%')
    
    # Handle math mode
    content = re.sub(r'\$([^$]+)\$', r'<span class="math">\1</span>', content)
    
    return content

# Example usage
latex_table = r"""
\begin{tabular}{l*{4}{c}}
\hline\hline
            &  Disabled & Husband & Wife & Other \\
\hline
Non-Time Poor      &         - &         - &         - &         - \\
                   &       [8.1]&   [22.9]   &  [22.9]    &        [46.1] \\     
Single Person Elig &        12.1&        - &       - &        99.7 \\
                   &       [5.9]&        - &       - &        [94.1] \\
HH Type I          &         - &       100.0&       100.0&       100.0\\
                   &  [0.02]    &   [47.2] & [47.2] & [5.6] \\
HH Type II         &        37.3&        42.4&        58.7&        43.0\\
                   &     [0.02] &  [45.9] & [45.9] & [8.2] \\
HH Type III        &         5.9&        41.3&        58.2&        24.2\\
                   &  [1.0]      & [35.4] & [35.4] & [28.3] \\
\hline\hline
\end{tabular}
"""

html_output = latex_to_html_table(latex_table)
print(html_output)