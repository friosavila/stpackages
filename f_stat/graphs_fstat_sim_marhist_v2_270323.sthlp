{smcl}
{* 24February2023}{...}
{title:sim_marhist: Marginal Histogram}
{right:{browse "https://github.com/":Marginal Histogram v1.0 (GitHub)}}

{p 4 4 2}
{marker syntax}{...}
{title:Marginal Histogram}: A Stata Package for generating Marginal Histograms.

{p 8 15 2}
{cmd:sim_marhist} yvar xvar {ifin} [{it:{help weight:weight}}] {cmd:[}{cmd:,} 
												{it: options}{cmd:]}

{p 4 4 2}

{synoptset 35}{...}
{p2col:{it: Options}}Description{p_end}
{p2line}
{synopt :{it:{opt scatter:}(scatter options)}} Allows user to pass {help scatter} options to modify the general look of the scatterplot.

{synopt :{it:{opt hhistogram:}(histogram options)}} Allows user to pass {help histogram} options to modify the general look of the horizontal histogram.

{synopt :{it:{opt vhistogram:}(histogram options)}} Allows user to pass {help histogram} options to modify the general look of the vertical histogram.

{synopt :{it:{opt histogram:}(histogram options)}} Allows user to pass {help histogram} options to modify the general look of 
both horizonal and vertical histograms. It cannot be combined with hhistogram or vhistogram.

{synopt :{it:{opt fit}(cmd [if/in] [weight], options)}} Allows user to add a fitted line option to the scatterplot. For example, one could add a lowess plot, or lpoly plot, to further improve the information of the plot.

{synopt :{it: graph_combine options}} In addition to the options above, one can provide most {help graph combine} options, to modify the overall look of the plot, size, or save the graph in memory or disk.
{p2line}

{hline}

{title:Marginal Histogram}: A Stata package for visualizing a Marginal Histogram.

{p 4 4 2}
The Marginal Histogram is a command version of the following guide in Medium (The Stata Gallery): {browse "https://medium.com/the-stata-gallery/top-25-stata-visualizations-with-full-code-668b5df114b6":Top 25 Stata Visualizations - With Full Code}.
This command is a {it:beta} version and is subject to improve over time. Please regularly check the {browse "https://github.com/":GitHub} page for version changes and updates.

{p 4 4 2}

{title:Dependencies}

While the program is self contained, the following examples require additional packages.

{stata ssc install palettes, replace}
{stata ssc install colrspace, replace}
{stata ssc install color_style, replace}
{stata ssc install frause, replace}
{stata ssc install grstyle, replace}

Even if you have these installed, it is highly recommended to update the dependencies:
{stata ado update, update}

{title:Examples}

Setup: Auto Dataset

{stata sysuse auto, clear}

Simple scatter plot

{stata sim_marhist price mpg}

Using alternative scheme

{stata sim_marhist price mpg, scheme(white_tableau)}

Adding a title

{stata sim_marhist price mpg, scheme(white_tableau) title("Prices vs MPG")}

Using alternative Dataset

{stata frause oaxaca,clear}

Creating Scatter plot with Lowess
{stata set scheme white_tableau}
{stata sim_marhist lnwage age, title("Prices vs MPG") scatter(color(%30) msize(large)) fit(lowess, lwidth(1) color(*1.1))}

{stata sim_marhist lnwage age, title("Prices vs MPG") scatter(color(%10) msize(large)) fit(lpolyci)}

{stata color_style monet}
{stata sim_marhist lnwage age, title("Prices vs MPG") scatter(color(%10) msize(large)) fit(lpolyci)}
See {browse "https://github.com/":GitHub} for more examples.

{hline}

{title:Version history}

- {bf:1.0} : First version.


{title:Package details}

Version      : {bf:Marginal Histogram} v1.0
This release : 24 Feb 2023
First release: 24 Feb 2023
Repository   : {browse "https://github.com/":GitHub}
Keywords     : Stata, graph, visualization, marginal histogram, scatter
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/fahad-mirza":Fahad Mirza}
E-mail       : fahadmirza04@outlook.com
GitHub       : {browse "https://github.com/fahad-mirza":Git Repository}
Website      : {browse "https://medium.com/@fahad-mirza":Medium Blog}
Twitter      : {browse "https://twitter.com/theFstat":@theFstat}

Author       : {browse "https://github.com/friosavila":Fernando Rios-Avila}
E-mail       : f.rios.a@gmail.com
GitHub       : {browse "https://github.com/friosavila":Git Repository}
Website      : {browse "https://friosavila.github.io/playingwithstata/index.html":Playing With Stata}
Twitter      : {browse "https://twitter.com/friosavila":@friosavila}


{title:Acknowledgements}



{title:Feedback}

Please submit bugs, errors, feature requests on {browse "https://github.com/":GitHub} by opening a new issue.

{title:References}

{p 4 8 2}Jann, B. (2018). {browse "https://www.stata-journal.com/article.html?article=gr0075":Color palettes for Stata graphics}. The Stata Journal 18(4): 765-785.

{psee}
    {helpb histogram}, {helpb scatter}, {helpb schemepack}
