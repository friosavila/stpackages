{smcl}
{* *! version 1.0  March 2022}{...}

{title:Title}

{phang}
{bf:joy_plot} {hline 2} Module create joy/violin plots across different groups. 
{p2colreset}{...}

{title:Syntax}

{p 8 16 2}
{cmd:joy_plot} varlist [if] [in] [aweight], [over(varname) by(varname)] [joy_plot_options color_options legend_options twoway_options]

{synoptset 19 tabbed}{...}
{marker opt}{synopthdr:options}
{synoptline}
{synopt  : {cmd: varlist}} You need to specify a list of variable that will be used to create plots (kdensity, or line). 

{synopt : {cmd: over(varname)}} Indicates a variable that defines the groups to be used for the joy_plot. If you omit this, you probably would prefer using {help kdensity} directly. See descriptions for details. 

{synopt : {cmd: by(varname)}} Indicates a variable that defines what groups to be plotted by. This creates multiple density plots for each level defined by over(). This variable can only take 2 values if using for violin plot. See descriptions for details. 

{marker opt}{synopthdr:joy_plot options}
{synoptline}

{phang} This options are used to modify some aspects specific to the looks of the joy_plot

{synopt : {cmd:radj(#)}}When used, the range used for the plots will be extended beyong the max or min values of the {cmd: varname}. Defeult is 0.

{synopt : {cmd:range(#1 #2)}}When used, it sets the range for the plot to be between #1 and #2. The default uses the sample min and max.

{synopt : {cmd:dadj(#)}}When used the height of the densities will be adjusted. This allows for plots to overlap each other. Default is 1 (no overlapping).

{synopt : {cmd:bwadj(#)}}Should be between 0 and 1. It is used to determine the bandwidth for each subplot. When bwadj=1 each plot uses the bandwidth determined by kdensity, which may vary by subgroup. When bwadj=0, all plots use a bandwidth equal to the simple average across all subgroups. Any number between 0 and 1 will use a weighted average between both options. For example, bwadj(0.5) will use a bandwith equal to the simple average between the subgroup kdensity specific bandwidth, and the overal mean bandwidth. 

{synopt : {cmd:bwadj2(#)}}Any positive number. It is use to change the bandwith across all plots. One can, for example, modify all
bandwidths to be half (bwadj2=0.5) of the one originally estimated. Default is 1.

{synopt : {cmd:bwadj3(#)}}Any positive number. It is used to define the bandwidth for all plots exogenously. For example bwadj3(0.5) sets the bandwidth to 0.5
across all plots. This is the fastest option.

{synopt : {cmd:kernel(kfun)}}This can be used to select a particular type of kernel function for the plots. Default is Gaussian.

{synopt : {cmd:nobs(#)}}This is used to define how many points to be used for the plot. Larger number creates a smoother figure, 
but uses more memory. Default is 200.	

{marker opt2}{synopthdr:Other options}
{synoptline}

{phang} These options can be used to modify the look of the legend, or text describing the groups.

{synopt : {cmd:strict}} Unless specified, the value labels, or values of {cmd:over(variable)} will be used to label groups. Using "strict" 
will not show any text, if a value label is undefined. See {help macro##remarks2}, and section on "label".

{synopt : {cmd:notext}}When used, no text will be added on the vertical axis.

{synopt : {cmd:textopt(opts)}}When producing joy_plots, one can use this option to change some aspects of the group indentifiers. See {help added_text_options} or details. 

{synopt : {cmd:right}}When used, it will put the text identifying groups on the right of the plot. The default is to add this text on the left.

{synopt : {cmd:offset(#)}}When used, It request to offset (move) the text # points to the right (+) or left (-).

{synopt : {cmd:gap0}}When used, all joy_plots will be drawn starting at 0. This will be similar to producing various {help kdensity} plots, but using areas. Cannot be combined with {cmd:violin}.

{synopt : {cmd:alegend}}When used, It will add a legend with all values defined in {cmd:over(varname)} or {cmd:by(varname)} to the graph. The default is not to show any legends. When over() and by() are specified, legends will be created based on the labels of variable in by(). This option can be combined with {help legend_options}.

{synopt : {cmd:iqr[(numlist)]}}When specified, it will add lines to the graph indicating specified percentiles (numlist). 
If numlist is not provided, it produces the 25th, 50th and 75th percentile.

{synopt : {cmd:iqrlwidth(numlist)}}Used to change the width of the lines marking the specified percentiles. Default is 0.3.

{synopt : {cmd:iqrlcolor(color)}}Used to change the color, or color properties of lines marking the specified percentiles. It may overwrite other color options.

{synopt : {cmd:violin}}When specified, it produces a violin type plot, rather than the kernel density plots. If by() is used, it produces half violin plots.

{marker opt}{synopthdr:color options}
{synoptline}

{synopt : {cmd: color(colorlist)}}Can be used to specify colors for each group defined by {cmd:over(varname)}, using 
a list of colors. If you add fewer colors than groups in {cmd:over(varname)}, subsequent groups will use last specified color. 
For example if you type color(red blue), but over(var) has 3 groups, the last group will also be assigned the "blue" color.

{synopt : {cmd: colorpalette(*)}}An alternative approach to specify colors. This uses the command {help colorpalette} 
to define colors and use them for the scatter plot. 

{phang}If neither option is used, colors are assigned based on the current {help scheme}, which uses up to 15 different 
colors. 

{phang}Note: If one uses over() option only, each group will be ploted with different colors. However, if by() option is used
colors will be assigned based on by() not over().

{marker opt}{synopthdr:Other color options}
{synoptline}

{phang}One can use other {help rarea} specific options including  fcolor,  fintensity, lcolor, 
lwidth, lpattern, lalign, lstyle. Be aware that the same option will be applied to each sub rarea defined by {cmd:over(varname)}.

{marker opt}{synopthdr:twoway options}
{synoptline}

{phang}It is also possible to use any of the {help twoway} options, including {k}labels, {k}titles, name, notes, etc. 


{marker description}{...}
{title:Description}

{p}This module aims to provide an easy way to create joy_plots and violin plots, over different groups. These are basically kernel density plots for a single variable
across multiple groups (either over() or by())
{p_end}

{p}For example, say that one is interested in visualizing the wage distribution for men and women. What you would normally do would be
{p_end}

{phang2} twoway kdensity wage if sex==1 || kdensity wage age if sex==2, legend(order(1 "Men" 2 "Women"))

{p}Instead you could create a similar graph using the following syntax:{p_end}

{phang2} joy_plot wage , over(sex) 

{p}And if you would prefer a violin plot, you could use the following{p_end}
{phang2} joy_plot wage , over(sex)  violin

{p}This program should also facilitate using different colors to each sub group. For example, one can simply 
provide the list of colors using {cmd:color(colorlist)}. You coud also use the option
{help colorpalette}() to select colors for each group defined by {cmd:over(varname)}.{p_end}

{p}This can also be used to produce bi-dimensional plots using the options "over()" and "by()". over() will create plots at different levels,
whereas by() will produce various plots within each level. For example, one could plot
wage distribution across education levels, for men and women. 

{p}See examples for details

{marker examples}{...}
{title:Examples}

{pstd}Lets start by loading some data:{p_end}

{phang2}
{bf:. {stata "use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta"}}

{pstd}
Say that you want to see the relationship between wages and experience, but differentiating 
by marital status:{p_end}
{phang2}
{bf:{stata "gen mstatus=single+2*married+3*divorced"}}{p_end}
{phang2}
{bf:{stata "joy_plot lnwage , over(mstatus)"}}

{pstd}
But now you want to add a label to differentiate all groups, and show this as a legend:{p_end}

{phang2}{bf:{stata "label define mstatus 1 Single 2 Married 3 Divorced"}}{p_end}
{phang2}{bf:{stata "label values mstatus mstatus"}} {p_end}
{phang2}{bf:{stata "joy_plot lnwage, over(mstatus) alegend notext"}}

{pstd}
But what if you want to try using colors other than the default. You have three options {p_end}

{pstd}Provide a list of colors manually{p_end}
{phang2}{bf:{stata "joy_plot lnwage  , over(mstatus) alegend color(navy gold)"}}{p_end}

{pstd}Or use colorpalette:{p_end}
{phang2}{bf:{stata "joy_plot lnwage  , over(mstatus) alegend colorpalette(blues) notext"}}{p_end}

{pstd}You could also use rarea options, and two way options{p_end}
{phang2}{bf:{stata `"joy_plot lnwage  , over(mstatus) color(gs10) iqr right title("Wages distribution") subtitle("by Marital Status") "'}}
{p_end}

{pstd}You could also request producing a graph that ignores the lower tail of the distribution. {p_end}
{phang2}{bf:{stata `"joy_plot lnwage  , over(mstatus) iqr range(2 5) title("Wages distribution") subtitle("by Marital Status") "'}}
{p_end}

{pstd}Now say that you want to compare wage distribution of men and women, over marital status. {p_end}
{phang2}{bf:{stata `"joy_plot lnwage  , over(mstatus) by(female) title("Wages distribution") subtitle("by Marital Status") "'}}

{pstd}Or produce a violin plot from here as well:{p_end}
{phang2}{bf:{stata `"joy_plot lnwage  , over(mstatus) by(female) title("Wages distribution") subtitle("by Marital Status and Gender") violin"'}}

{pstd}Finally, you can plot over gender, by marital Status. Although violin is no longer an option {p_end}
{phang2}{bf:{stata `"joy_plot lnwage  , by(mstatus) over(female) title("Wages distribution") subtitle("by Marital Status and Gender") "'}}


{marker Aknowledgement}{...}
{title:Aknowledgement}

{pstd}
This command came up to existance because I do this kind of graphs often just to visualize multiple groups at the same time. 
Since I was in a programming mood, I decided to write up a command for this. 
{p_end}

{pstd}
Also, colorpalette is a very powerful command by Ben Jann. Without it, playing with colors would be far more difficult!

{pstd}
Finally, many thanks to Eric Melse, who suggested many new features for this command.

{pstd}
One last point. If you are interested on this or other of my visualization tools, check {browse "https://github.com/friosavila/stataviz"}, where I will try to 
keep updated versions of these commands.

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
Help:  {helpb colorpalette}, {helpb scatter}, {helpb kdensity}, {helpb ridgeline_plot}, {helpb waffle_plot}

