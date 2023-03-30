{smcl}
{* *! version 1  April 7 2022}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Title}

{phang}
{bf:sankey_plot} {hline 2} Module to produce Sankey Plots


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:sankey_plot}
x0 y0 x1 y1
{ifin}
[{cmd:,} {it:sankey_options} {it: twoway_options}]

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main: Sankey coordinates options}

{synopt:{cmd:x0 y0 x1 y1}}Required. This provides the coordinates and groups to 
be plotted. (x0,y0) identifies the origin, and (x1,y1) the destination.
This values identify the nodes. {p_end}
{synopt:}x0 and x1 must be numerical. They identify the horizonal levels of the connections. However y0 and y1 can be numerical or strings, but not both. If they are strings, those values will be used as labels. They identity nodes within levels.  {p_end}

{synopt:{cmd:width0(varname)}}Provides a variable with the weight or width at the origin (x0,y0). Default is 0.01{p_end}

{synopt:{cmd:width1(varname)}}Provides a variable with the weight or width at the destinatin (x1,y1). 
Default is the value in width0{p_end}


{synoptline}
{syntab:Main: Sankey Look options}

{synopt:{cmd:sharp(#)}} Uses # to define change the look of the conecting segments or links. 
Default is 7. Must be larger than 0. A value of 1 produces a line. {p_end}
 
{synopt:{cmd:adjust}}Adjust Ys coordinates to avoid overlapping within nodes. 
However, the figure will remain "around" the original value of Y{p_end}

{synopt:{cmd:extra}}Adjust Y coordinates based on width0 and/or width1. With this option
there will be no overlapping across nodes. Can be combined with {cmd:adjust}   {p_end}

{synopt:{cmd:gap(#)}}To be used in combination with {cmd:extra}. Request 
to add a "gap" across nodes from the same level when using {cmd:extra}    {p_end}

{synopt:{cmd:noline}}Request connecting segments or links to be drawn without the border line{p_end}

{synopt:{cmd:nobar}}Requests the Bars that connects segments/links not to be drawn. {p_end}


{synoptline}
{syntab:Main: Sankey bar & label options options}

{synopt:{cmd:bwidth(#)}}If the connecting Bar is kept, this can be used to modify 
the width of that bar. Default 0.025.  {p_end}

{synopt:{cmd:bheight(#)}}When used, this modifies the height of all 
connecting bars. Default is to use the hight of the connecting links{p_end}

{synopt:{cmd:bcolor(colorstyle)}}When used, one can modify the color of the bar.
Default is to use the color of the following segment. This option superseeds other color options, but can be combined with pstyle {p_end}

{synopt:{cmd:label0(varname)}}Provides a variable with the labels for the 
origin coordinates. Must be String. Default None. Not needed if y0 and y1 are strings. {p_end}

{synopt:{cmd:label1(varname)}}Provides a variable with the label for the 
destination coordinates. Must be String. Default label0 if any. Not needed if y0 and y1 are strings {p_end}

{synopt:{cmd:labangle(#)}}When {cmd:label0} are provided, 
one can use this option to modify the angle of labels. Default 0{p_end}

{synopt:{cmd:labpos(#)}}When {cmd:label0} are provided, 
one can use this option to modify the possition of labels. 
Default is to possition the label to the right of the first level, 
and left of the last one.{p_end}

{synopt:{cmd:labsize(#)}}When {cmd:label0} are provided, 
one can use this option to modify the size of the text for labels. 
{p_end}

{synopt:{cmd:labcolor(colorstyle)}}When {cmd:label0} are provided, or y0 y1 were strings, one can use this option to modify the color of the text for labels. 
{p_end}

{synoptline}
{syntab:Main: Sankey color/style options}

{pstd}This command provides various options to add colors to all links and conecting bars.
The default is to use the current Scheme colors, which allows up to 15 different groups.{p_end}

{synopt:{cmd:pstyle(varname)}}One can provide a variable that preassigns styles to a particular segment. One can choose from p1-p15. This can be combined with bcolor and fillcolor options.{p_end}

{synopt:{cmd:color(varname)}}One can provide a variable that preassigns colors to a particular link. This {cmd:cannot} be combined with bcolor and fillcolor options. If those options are used, they will superseed {cmd:color} {p_end}

{synopt:{cmd:fillcolor(color)}}One can use this option to define a single color for all connecting links. Using this option superseeds color and colorpalette options {p_end}

{synopt:{cmd:colorpalette(options)}}
This option allows you to use color palettes using Ben Jann's {help colorpalette}. Most options are allowed. However, the option {cmd:opacity()} will only affect the connecting links, not the connecting bars.
{p_end}


{synoptline}
{syntab:Main: Experimental}

{synopt:{cmd:wide}}This is an experimental option. You can use it, for example, when each variable in your data
corresponds to a different horizontal level. See "dogs and happiness" example. {p_end}

{synopt:{cmd:width(varname)}}If wide option is used, the weight of each flow should be defined with this option {p_end}

{synopt:{cmd:tight}}If wide option is used, this option "compresses" categories to avoid multiple flows from and to same
nodes{p_end}

{pstd}Most other Sankey options are allowed. However, not all have been tested.{p_end}


{synoptline}
{syntab:Main: twoway graph options}

{pstd}Most {help twoway_options} are allowed, including name, title, subtitle, xlabel, etc. However, not all have been tested.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:sankey_plot} is a module that aims to facilitate the creation of sankey plots in Stata. This command, however, does not make any data processing, and assumes the data is ready to be used. {p_end}

{pstd}
At its core, a Sankey plot is nothing less than pairs of connected coordinates: from (x0,y0) -> (x1,y1). These points are connected with flows that have widths proportional to {cmd:width0} and {cmd:width1}.
{p_end}

{pstd}
x0 and x1 identify the vertical levels of a plot. These variables must be numeric.
{p_end}

{pstd}
y0 and y1 identify different groups within levels. These variables can be numeric of string but not both. When string variables are used, those values are used as labels for the different groups within levels.
{p_end}

{pstd}
There are two main options to adjust coordinates:
{p_end}

{pstd}
{cmd:adjust}, which adjusts coordinates so that there is no overlapping of flows within groups. 
{p_end}

{pstd}
{cmd:extra}, which adjusts coordinates based on {cmd: width0} and {cmd: width1}, so that there is no overlapping across groups.
{p_end}

{pstd}The command also allows you to use the command {help colorpalette} to choose from different color palettes. Only available if correctly installed.

{marker examples}{...}
{title:Examples}

{pstd}Immigration flows: The following contains data on immigration flows across continents.
It has data on 2 levels. Source and destination. {p_end}

{phang}{cmd:use immigration, clear}{p_end}

{pstd}Simplest Sankey plot. Only connects observations across groups. Weights are default. {p_end}
{phang}{cmd:sankey_plot x0 from x1 to}{p_end}

{pstd}Uses ticker widths. But flows overlap {p_end}
{phang}{cmd:gen w0 = 0.1 }{p_end}
{phang}{cmd:sankey_plot x0 from x1 to, width0(w0) }{p_end}

{pstd}Uses ticker widths. But flows do not overlap {p_end}
{phang}{cmd:sankey_plot x0 from x1 to, width0(w0) adjust}{p_end}

{pstd}Uses imigration flows as widths. This figure will be unreadable because all flows will overlap, even if using adjust{p_end}
{phang}{cmd:sankey_plot x0 from x1 to, width0(value) }{p_end}
{phang}{cmd:sankey_plot x0 from x1 to, width0(value) adjust}{p_end}

{pstd}This is a better figure, because it adjusts coordinates to widths {p_end}
{phang}{cmd:sankey_plot x0 from x1 to, width0(value) extra}{p_end}

{pstd}Even better, because it also adjust overlapping{p_end}
{phang}{cmd:sankey_plot x0 from x1 to, width0(value) extra adjust}{p_end}

{pstd}Now say you want to modify colors. You can change the colors of the flows using fillcolor.
you could change all to grey (gs12) or modify transparency, or both.{p_end}

{phang}{cmd:sankey_plot x0 from x1 to, width0(value) extra adjust fillcolor(gs12)}{p_end}
{phang}{cmd:sankey_plot x0 from x1 to, width0(value) extra adjust fillcolor(%50)}{p_end}

{pstd}You could also increase the gap across nodes{p_end}
{phang}{cmd:sankey_plot x0 from x1 to, width0(value) extra adjust fillcolor(%50) gap(0.1)}{p_end}

{pstd}If you do not like the default colors of your scheme, you could use colorpalette. Notice that Im using opacity
and noline, to get cleaner flows{p_end}
{phang}{cmd:sankey_plot x0 from x1 to, width0(value) extra adjust colorpalette(viridis, opacity(40)) gap(0.1) noline}{p_end}

{pstd}But what about the xlabels. The default is to use the values for x0 and x1. However, they can be changed{p_end}
{phang}{cmd:sankey_plot x0 from x1 to, width0(value) extra adjust colorpalette(viridis, opacity(40)) gap(0.1) noline xlabel(1 "Source" 2 "Destination", nogrid)}{p_end}

{pstd}And of course, you can titles, name the graph, add notes{p_end}
{phang}{cmd:sankey_plot x0 from x1 to, width0(value) extra adjust colorpalette(HSV intense, opacity(40)) gap(0.1) noline xlabel(1 "Source" 2 "Destination", nogrid) title("Migration flows") note("Note:Abel, Guy J (2017) Estimates of Global Bilateral Migration Flows by Gender between 1960 and 2015")}{p_end}

{pstd}JobMarket: The following contains data on Job market flows across many weeks. It has data on multiple levels. {p_end}
{pstd}In contrast with the previous plot, I will use labels explicilty{p_end}
{phang}{cmd:use jobmarket, clear}{p_end}

{pstd}Lets Start with the simplest plot{p_end}
{phang}{cmd:sankey_plot week0 y0 week1 y1}{p_end}

{pstd}Since I would like to keep the same shape as above, but using the provided widths, I will readjust the Y0 and Y1 coordinates{p_end}
{phang}{cmd:gen y00=y0*10}{p_end}
{phang}{cmd:gen y11=y1*10}{p_end}
 {phang}{cmd:sankey_plot week0 y00 week1 y11, width0(candiates) adjust}{p_end}
 
{pstd}Next I'll modify the colors, add labels and change the xlabels{p_end}
{phang}{cmd:sankey_plot week0 y00 week1 y11, width0(candidates) adjust xlabel(0 " " 1 "Week 1" 2 "Week 2" 3 "Week 3" 4 "Week 4" 5 "Week 5" 6 "Week 6", nogrid) fillcolor(gs12%50) label0(label0) label1(label1) xsize(10) ysize(6)}{p_end}

{pstd}Same as above but using "extra" to adjust possition of nodes{p_end}
{phang}{cmd:sankey_plot week0 y00 week1 y11, width0(candidates) adjust extra xlabel(0 " " 1 "Week 1" 2 "Week 2" 3 "Week 3" 4 "Week 4" 5 "Week 5" 6 "Week 6", nogrid) fillcolor(gs12%50) label0(label0) label1(label1) xsize(10) ysize(6)}{p_end}

{pstd}Pets, Marriage and Happiness: The following contains with a different structure. Rather than having pair of coordinates, we use 
variables which identify the flows across nodes. This requires a slighly different syntax. {p_end}

{phang}{cmd:use dogs_and_happiness, clear}{p_end}
{phang}{cmd:list}{p_end}

{pstd}First the simplest Sankey requires to indicate you are going to use "wide" data{p_end}
{pstd}It is required to provide the width variable as well.{p_end}
{phang}{cmd:sankey_plot married pet happy , wide width(freq)}{p_end}

{pstd}As before, lets change colors, add space within nodes, and drop the xlabels {p_end}
{phang}{cmd:sankey_plot married pet happy , wide width(freq) fillcolor(%50) xlabel("",nogrid) gap(0.1)}{p_end}

{pstd}You will notice 2 groups in Married with pets who are happy. That can be fixed using "tight" {p_end}
{phang}{cmd:sankey_plot married pet happy , wide width(freq) fillcolor(%50) xlabel("",nogrid) gap(0.1) tight title("The Secret to Happyness") subtitle("Have Pets: Nora and Bruce!") note("Nora and Bruce belong to my wife and I")}{p_end}


{marker Aknowledgement}{...}
{title:Aknowledgement}

{pstd}
This command came to life as part of a small programming challenge by Asjad, who created a step-by-step post of how to make Sankey Plots. 
However, the structure of how this program works is different from his approach.
{p_end}

{pstd}
Questions comments and suggestions welcome.
{p_end}

{marker Author}{...}
{title:Author}

{pstd}Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Blithewood-Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org

