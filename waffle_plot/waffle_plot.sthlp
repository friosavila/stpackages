{smcl}
{* *! version 1.2  19 April 2022 }{...}
{title:Title}

{phang}
{bf:waffle_plot} {hline 2} Module to produce Waffle plots


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:waffle_plot} [{varlist} / {help numlist} ] {ifin} [{help aweights}] [{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt varlist/numlist}}You can provide either a numlist or varlist to be used and produce the waffle plots. When using varlist, the means (or means by()) will be used to produce the plots. When providing a varlist, the values of the varlist cannot be individually larger than 100. unless {cmd:total} is used. {p_end}

{synopt:{opt total([varname])}}This is used to crate shares of the provided variables. If used without a varname, the shares will be constructed as total of the sum of all variables. Otherwise, one can use a variable with the denominator to create the shares. {p_end}

{synopt:}Default behavior is to produce the shares first per observation, then obtain group averages. See {cmd:group} for alternative option.{p_end}

{synopt:{opt individual}}This can be used in combination with {cmd: total}. When this option is used, the command first estimates shares for each observation, and then average them by group. The default is to first obtain average of variables, and then obtain the shares.
{p_end}

{synopt:{cmd: by(varname,...)}}Repeats the procedure for subgroups. Most {help by_option} are allowed. If there are many observations within each group in by(), the mean value will be obtained using "weigths" if provided.  {p_end}

{synopt:{opt nobs(#)}}Used to define the dimension of the waffle plot. Default is 10. This superseeds xnobs() and ynobs(), and necessarily produces a squared waffle. {p_end}

{synopt:{opt xnobs(#)}}Used to define the X dimension of the waffle plot. Can be used to produce rectangular waffles. Default is nobs(#){p_end}

{synopt:{opt ynobs(#)}}Used to define the Y dimension of the waffle plot. Can be used to produce rectangular waffles. Default is nobs(#){p_end}

{synopt:{opt sctopt(options)}}Used to provide options for scatter. For example, markersize, markersymbol, etc. see {help scatter##marker_options} and consider only the marker options. The same option will be applied to each subgroup scatter.{p_end}

{synopt:{}}If the options relate to the marker properties, they can be provided without using sctopt(){p_end}

{synopt:{opth color(colorlist)}}Provides the a list of colors associated to each variable or number. {p_end}

{synopt:{opth pstyle(stylelist)}}Provides the a list of styles associated to each variable or number. {p_end}

{synopt:{opth color0(color)}}Provides a color for the left out group. For example, if one provides the values 10 20 30, the last group will consider the left 40. The color of this group can be defined with this option {p_end}

{synopt:{opth amargin(#)}}Can be used to increase the margins in the plot region. May be usedul to avoid overlapping titles.{p_end}

{synopt:{opth rseed(#)}}Can be used to scramble the asigment order.{p_end}

{synopt:{opth flip}}Forces the plot to be "flipped". Similar to horizontal option {p_end}

{synopt:{opth legend(..)}}Can be used to create a legend. Default is legend(off){p_end}

{p}The program also allows for other {help twoway_options}. Including name, legend, titles, region, etc.
Not of options have been tested.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:waffle_plot} can be used to produce waffle plots. This command has two options for this purpose.{p_end}

{pstd}The first option works as an immediate command, where you provide values that define groups. Each group is stacked on top of each other until 100% is reached.{p_end}

{pstd}The second option works similar to {help graph bar}. Rather than providing values, one provides variables with the information of interest. If there are multiple values, the mean of the variables are used for the plot.{p_end}

{pstd}The second option can be combined with by(), option, similar to other twoway graphs. First, the mean by group will be estimated, and then those means are used to produce waffle plots by group.{p_end}

{pstd}The values or variables must be between 0-100 or 0-1. If all values are between 0-1, they will be rescaled to 100.{p_end}

{pstd}Current version sets the size of markers at "10" for a 10x10 plot. And adapts based on nobs and by() levels.{p_end}

{marker examples}{...}
{title:Examples}

{pstd}
Waffle_plot as an immediate command:{p_end}

{phang}
{bf:{stata "waffle_plot 45  "}}{p_end}

{phang}
{bf:{stata "waffle_plot 12 45,  msymbol(square)  "}}{p_end}

{phang}
{bf:{stata "waffle_plot 12 45 7,   msymbol(square)  color0(gs10) color(blue red)"}}{p_end}

{phang}
{bf:{stata "waffle_plot 12 45 7,  msymbol(square) mlcolor(black) color0(gs10) color(blue red)"}}{p_end}

{phang}
{bf:{stata `"waffle_plot 12 45 7,  msymbol(square) mlcolor(black) color0(gs10) color(blue red)  legend(order(1 "Rep" 2 "dem" 3 "green" 4 "unde"))"' }}{p_end}

{phang}
{bf:{stata `"waffle_plot 12 45 7, msymbol(square) mlcolor(black) color0(gs10) color(blue red)  legend(order(1 "Rep" 2 "dem" 3 "green" 4 "unde")) flip"' }}{p_end}

{phang}
{bf:{stata `"waffle_plot 12 45 7,  msymbol(square) mlcolor(black) color0(gs10) color(blue red)  legend(order(1 "Rep" 2 "dem" 3 "green" 4 "Undecided")) xnobs(12) ynobs(8) "' }}{p_end}

{phang}
{bf:{stata `"waffle_plot .12 .45 .07,  msymbol(square) mlcolor(black) color0(gs10) color(blue red)  legend(order(1 "Rep" 2 "dem" 3 "green" 4 "Undecided")) xnobs(12) ynobs(8) "' }}{p_end}

{pstd}
Waffle_plot as a regular command. Lets start loading pop2000 data {p_end}

{phang}
{bf:{stata "sysuse pop2000, clear" }}{p_end}

{pstd}
And say we want to estimate the population share by race. Lets start by calculating the shares for the whole country, first:{p_end}
{phang}
{bf:{stata "collapse (sum) white black indian asian island" }}{p_end}
{phang}{bf:{stata "gen total=white +black +indian +asian +island" }}{p_end}
{phang}{bf:{stata "gen share_white =white/total" }}{p_end}
{phang}{bf:{stata "gen share_black =black/total" }}{p_end}
{phang}{bf:{stata "gen share_other =(indian+asian+island)/total" }}{p_end}

{pstd}
Simplest waffle_plot, plus additional examples with options{p_end}
{phang}{bf:{stata "waffle_plot share_*" }}{p_end}
{phang}{bf:{stata `"waffle_plot share_*, legend(order(1 "White" 2 "Black" 3 "Other"))"' }}{p_end}
{phang}{bf:{stata `"waffle_plot share_*, legend(order(1 "White" 2 "Black" 3 "Other")) msize(7) mlcolor(black)  title("Population Composition")"' }}{p_end}

{pstd}
One could have achieved the same graph using option "total"{p_end}
{phang}{bf:{stata "sysuse pop2000, clear" }}{p_end}
{phang}{bf:{stata "gen other=indian +asian +island" }}{p_end}
{phang}{bf:{stata "replace total=white+black+indian +asian +island" }}{p_end}
{phang}{bf:{stata `"waffle_plot white black other, legend(order(1 "White" 2 "Black" 3 "Other")) msize(7) mlcolor(black) total title("Population Composition")"' }}{p_end}

{pstd}
Or using option total(varname). Notice that "other" is now the "left" category. {p_end}
{phang}{bf:{stata `"waffle_plot white black  , legend(order(1 "White" 2 "Black" 3 "Other")) msize(7) mlcolor(black) total(total) title("Population Composition")"' }}{p_end}

{pstd}
Now, What if my interest is not to get the population race structure, but the average structure across all groups in the data (by age). In this case I would use "individual" {p_end}
{phang}{bf:{stata `"waffle_plot white black  , legend(order(1 "White" 2 "Black" 3 "Other")) msize(7) mlcolor(black)  total(total) title("Population Composition") individual"' }}{p_end}

{pstd}
Finally, what if I'm trying to do this by group (here age group). I have to use "title" as part of {cmd:by(,options)}. I ll also use the compact version of the plots, with 7 columns and modify legends to be drawn with 3 columns. {p_end}

{phang}
{bf:{stata `"waffle_plot white black  , legend(order(1 "White" 2 "Black" 3 "Other") cols(3)) msize(3) msymbol(square) mlcolor(black)  total(total)  individual by(agegrp, compact cols(7)) title("Population Composition")"' }}{p_end}

{phang}
{bf:{stata `"waffle_plot white black, legend(order(1 "White" 2 "Black" 3 "Other") cols(3)) xnobs(20) ynobs(5) sct(msize(3)  msymbol(square) mlcolor(black) ) total(total)  individual by(agegrp, compact cols(3)) title("Population Composition")"' }}{p_end}

{phang}
{bf:{stata `"waffle_plot white black, legend( cols(3)) xnobs(20) ynobs(5) sct(msize(3)  msymbol(square) mlcolor(black) ) total(total)  individual by(agegrp, compact rows(2)) title("Population Composition") flip"' }}{p_end}

{pstd}
Waffle_plot as a regular command. Using random examples from Stata datasets:{p_end}

{phang}{bf:{stata `"sysuse cancer, clear"' }}{p_end}
{phang}{bf:{stata `"waffle_plot died, color0(gs15) legend(order(1 "Died")) by(drug, cols(3)) sctopt(msize(6))"' }}{p_end}

{phang}{bf:{stata `"sysuse voter, clear"' }}{p_end}

{phang}{bf:{stata `"xi, noomit:waffle_plot i.cand [w=pop], color(*0.7 *0.7 *.5) sctopt(msize(4) mlcolor(black*.50))  by(inc) title("1992 President Elections") subtitle("by Family Income") legend(order(1 "Clinton" 2 "Bush" 3 "Perot") cols(3))"'}}{p_end}

{marker Aknowledgement}{...}
{title:Aknowledgement}
 
{pstd}
This command was inspired by the blog by Asjad Naveed for producing these type of plots, and my interest in bringing some advanced visualization tools to Stata, in a way that is easy to use for most people.
{p_end}

{pstd}Also, thank you to Jared Colston, who pushed me to finish this little project.
{p_end}

{pstd}
All errors are my own.
{p_end}

{marker Author}{...}
{title:Author}

{pstd}Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Blithewood-Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org
