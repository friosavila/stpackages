{smcl}
{* *! version 1.0  April 2022}{...}

{title:Title}

{phang}
{bf:ridgeline_plot} {hline 2} Module create ridgeline/stack/stream plots across different groups. 
{p2colreset}{...}

{title:Syntax}

{p 8 16 2}
{cmd:ridgeline_plot} yvar xvar [if] [in] [iweight], [over(varname)] [ridgeline_plot_options color_options legend_options twoway_options]

{synoptset 19 tabbed}{...}
{marker opt}{synopthdr:options}
{synoptline}
{synopt  : {cmd: yvar xvar}} You need to specify a two variables. xvar is usually a time variable, and yvar is the variable you want to plot. Similar to {help line}.

{synopt : }When there is more than one observation per {cmd:xvar} and {cmd:over()}, the command will first estimate the mean within xvar, before preparing the plot. 

{synopt : {cmd:sum}} When there is more than one observation per {cmd:xvar} and {cmd:over()}, one can request obtaining the weighted sum by xvar, instead of mean.

{synopt : {cmd: over(varname)}} Indicates a variable that defines the groups to be used for the joy_plot. If you omit this, you probably would prefer using {help line} directly. See Descriptions for details. 

{marker opt}{synopthdr:ridgeline_plot options}
{synoptline}

{phang} This options are used to modify some aspects specific to the looks of the ridgeline_plot

{synopt : {cmd:radj(#)}}When used, the Range used for the plots will be extended beyong the max or min values of the {cmd: varname}. Defeult 0.

{synopt : {cmd:range(#1 #2)}}When used, It sets the range for the plot to be between #1 and #2. The default uses the sample min and max.

{synopt : {cmd:dadj(#)}}When used, the hight of the lines to be adjusted. This allows for plots to overlap each other. Default is 1.

{synopt : {cmd:bwadj(#)}}Should be between 0 and 1. It is used to determine the bandwidth for each subplot. When bwadj=0, all plots use the simple Bandwidth average. When bwadj=1, all plots will use the bandwidth determined by {help lpoly}. One can choose something inbetween.

{synopt : {cmd:bwadj2(#)}}Any possitive number. It is use to change the Bandwith across all plots. One can, for example, modify all
bandwidths to be half (bwdj2=0.5) of the one originally estimated. Default is 0.2.

{synopt : {cmd:bwadj3(#)}}Exogenously provides a bandwidth for all lines.

{synopt : {cmd:kernel(kfun)}}This can be used to select a particular type of kernel function for the plots. Default is triangular.

{synopt : {cmd:degree(#)}}Determines the degree of the local regression for smoothing. Default is 0.

{synopt : {cmd:nobs(#)}}This is used to define how many points to be used for the plot. Larger number creates a smoother figure, but uses more memory. Default is 200.	

{synopt : {cmd:normalize}}This is used to normalize the height of the lines for all groups to be equal to 1. The default is for lines height to be relative to the populations height. See Example for details.

{marker opt}{synopthdr:ridgeline_plot options:Stack and Stream}

{synopt : {cmd:stack}}Request to produce a stack line plot.

{synopt : {cmd:stack100}}Request to produce a stack line plot, normalized to 100 (Shares).

{synopt : {cmd:stream([#])}}Request to produce a stream like plot. Default is to produce a graph centered at 0. When a number # is provided, then the height of that group becomes the pivot point for stacking. can be combined with stack & stack100.

{synopt : {cmd:half}}If {cmd:stream ()} is used, half request the "middle" of the #th group to be the pivot point for stacking.


{marker opt2}{synopthdr:Other options}
{synoptline}

{phang} These options can be used to modify the look of the legend, or text describing the groups.

{synopt : {cmd:strict}}Unless specified, the value labels, or values of {cmd:over(variable)} will be used to label groups. using "strict" 
will not no text, if a value label is undefined.

{synopt : {cmd:notext}}WHen used, no text will be added on the vertical axis.

{synopt : {cmd:textopt(opts)}}When producing joy_plots, one can use this option to change some aspects of the group indentifiers. See {help added_text_options} or details. 

{synopt : {cmd:right}}When used, it will put the text identifying groups on the right of the plot. The default is to add this text on the left.

{synopt : {cmd:offset(#)}}When used, It request to offset (move) the text # points to the right (+) or left (-).

{synopt : {cmd:gap0}}When used, all joy_plots will be drawn starting at 0. This will be similar to producing various {help kdensity} plots, but using areas. Cannot be combined with {cmd:violin}

{synopt : {cmd:alegend}}When used, It will add a legend with all values defined in {cmd:over(varname)} to the graph. The default is not to show any legends. Can be combined with {help legend_options}

{marker opt}{synopthdr:color options}
{synoptline}

{synopt : {cmd: color(colorlist)}}Can be used to specify colors for each group defined by {cmd:over(varname)}, using 
a list of colors. If you add only fewer colors than groups in {cmd:over(varname)}, subsequent groups will use last specified color. 
For example if you type color(red blue), but over(var) has 3 groups, the last group will also be assigned the "blue" color.

{synopt : {cmd: colorpalette(*)}}An alternative approach to specify colors. This uses the command {help colorpalette} 
to define colors and use them for the scatter plot. 

{phang}If neither option is used, colors are assigned based on the current {help scheme}, which uses up to 15 different 
colors.

{marker opt}{synopthdr:Other color options}
{synoptline}

{phang}One can use other {help rarea} specific options including  fcolor,  fintensity, lcolor, 
lwidth, lpattern, lalign, lstyle. Be aware that the same option will be applied to each sub rarea defined by {cmd:over(varname)}.

{marker opt}{synopthdr:twoway options}
{synoptline}

{phang}It is also possible to use any of the {help twoway} options, including {k}labels, {k}titles, name, notes, etc. 


{marker description}{...}
{title:Description}

{p}This module aims to provide an easy way to create ridgeline plots, as well as stream plots and stackline plots. using smoothed versions of the data via {help lpoly()}. Using smooth lines helps dealing with large datasets.
{p_end}

{p}This program should also facilitate using different colors to each sub group. For example, one can simply 
provide the list of colors using {cmd:color(colorlist)}. You coud also use the option
{help colorpalette}() to select colors for each group defined by {cmd:over(varname)}.{p_end}

{p}See examples for details

{marker examples}{...}
{title:Examples}

{pstd}For this example, lets start by loading the ancillary data covid_small. This contains data for South america and Oceania only{p_end}
{phang2}{bf:{stata `"use covid_small.dta"'}}
{p_end}

{pstd}Now, say you want to do a basic ridgeline_plot, looking at new dealths across time by country in South America{p_end}
{phang2}{bf:{stata `"ridgeline_plot new_deaths date , over(country)"'}}

{pstd}This may give you graph with alot of data for brazil, but almost no information for other countries (relatively small) {p_end}
{pstd}So what I can do is place the label somwhere else, as well as Normalize figures. {p_end}
{phang2}{bf:{stata `"ridgeline_plot new_deaths date , over(country) normalize textopt(size(small) placement(e))"'}}

{pstd}That should look better. But could also change from text to legend, and adjust overlap{p_end}
{phang2}{bf:{stata `"ridgeline_plot new_deaths date , over(country) normalize notext alegend dadj(3)"'}}

{pstd}What if what you are interested is in stackbars{p_end}
{phang2}{bf:{stata `"ridgeline_plot new_deaths date , over(country)   notext alegend stack"'}}

{pstd}or if what you are interested is in stackbars at 100{p_end}
{phang2}{bf:{stata `"ridgeline_plot new_deaths date , over(country)   notext alegend stack100"'}}
{p_end}

{pstd}Streamlines are also easy to build{p_end}
{phang2}{bf:{stata `"ridgeline_plot new_deaths date , over(country)   notext alegend stream"'}}

{pstd}Or if you want to shift the stream up a bit{p_end}
{phang2}{bf:{stata `"ridgeline_plot new_deaths date , over(country)   notext alegend stream(3)"'}}
{p_end}

{marker Aknowledgement}{...}
{title:Aknowledgement}

{pstd}
This command came up to existance because I do this kind of graphs often enough to visualize multiple groups at the same time. Also, Asjad started a small "revolution" of color and dataviz in Stata that I wanted to contribute.
{p_end}

{marker Author}{...}
{title:Author}

{pstd}Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Blithewood-Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org

{title:Also see}

{p 7 14 2}
Help:  {helpb colorpalette}, {helpb scatter}, {helpb line}

