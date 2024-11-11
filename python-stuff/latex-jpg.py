import matplotlib.pyplot as plt
from matplotlib.backends.backend_agg import FigureCanvasAgg as FigureCanvas
from matplotlib.figure import Figure

# Define the LaTeX table as a string
latex_table = r"""
\begin{tabular}{|c|c|c|}
\hline
Column 1 & Column 2 & Column 3 \\
\hline
Data 1 & Data 2 & Data 3 \\
Data 4 & Data 5 & Data 6 \\
\hline
\end{tabular}
"""

# Create a figure and a canvas
fig = Figure()
canvas = FigureCanvas(fig)
ax = fig.add_subplot(111)

# Hide the axes
ax.axis('off')

# Render the LaTeX table
ax.text(0.5, 0.5, latex_table, horizontalalignment='center', verticalalignment='center', fontsize=12, usetex=True)

# Save the figure as an image
canvas.print_figure('latex_table.png', bbox_inches='tight')

print("LaTeX table rendered and saved as 'latex_table.png'")