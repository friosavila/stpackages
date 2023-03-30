{smcl}
{* *! version 1.0  March 2022}{...}

{title:Title}

{phang}
{bf:color_style} {hline 2} Module to change colors in your scheme file. 
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:color_style} [palette], [graph list] [n(#) {help colorpalette} options]

{synoptset 12 tabbed}{...}
{marker opt}{synopthdr:options}
{synoptline}

{p2coldent : {opt palette}} Specifies a particular palette to be applied to the Scheme file. One can use
any of the palettes or color options following {help colorpalette} syntax, or the palettes provided along with this command. 
See {cmd: list}.

{synopt : {cmd: graph}} When requested, the command will display the palette of colors one will apply.

{synopt : {cmd: random}} Selects a random palette from the ones available with the package.

{synopt : {cmd: list}} Provides a list of Palettes that accompany this file. These are in addition to the ones in {help colorpalette}. 

{synopt : {cmd: list(letter)}} Provides a list of Palettes that start with "letter".


{synopt :{cmd: n(#)}} Defines the number of colors to be used for the palette. n(#) should be between 1 to 15. If you select a number larger than 15, those colors will not be used in the scheme file. If n(#)<15, unused pstyle's will be recycled. 

{synopt :{cmd: ipolate(#)}} Same as with n(#). However, using n(#) does not work under Stata versions earlier than 14.2.

{synopt : } The default is to use the number of colors in the palette. For exaple {cmd: Greek} has 5 default colors. Using and n(#) higher or lower than this will interpolate colors. See the options in {help colorpalette}.

{synopt :{cmd:showcase}} This will show you how the palette will look for up to 15 colors.

Extra:

{p 8 16 2}
{cmd:font_style} {it: font}

This has 1 job. Change the fontface for your graphs.  

{p 8 16 2}
{cmd:graphquery} {it: options}

This has 1 job. Returns the scheme properties associated to a particular option.

For example "graphquery color p1" should provide the color assigned to color p1 (navy for s2color).

{marker description}{...}
{title:Description}

{p}This module aims to provide an easy way to change the palette colors in your scheme and graphs. 
{p_end}

{p}This command works as a wrapper on top of Ben Jann's {help colorpalette} and {help grstyle}. Whereas the palette's 
were put together by Blake Robert Mills, Karthik Ram and Jake Lawlor.
{p_end}

{p}Because this command works as a wrapper for colorpalette, you can easily use your own palettes, or the ones in colorspace to make your graphs shine.

{marker examples}{...}
{title:Examples}

{pstd}Lets start by loading some data:{p_end}

{phang2}
{bf:. {stata "use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta"}}{p_end}
{phang2}
{bf:. {stata "set scheme white"}}{p_end}

Say that you are considering using one of the color palettes that comes with this command. 
However, you do not know what is available, so you start by simply typing:{p_end}

{phang2}
{bf:. {stata "color_style , list"}}

{pstd}
Now, assume you want decide for the enigmatic Egypt, but are unsure about the colors,
then you can type:{p_end}

{phang2}
{bf:. {stata "color_style egypt, graph"}}

{pstd}
What you will see is that this palette uses 4 colors. So only the first 4 Styles would be modified.
You could extend this palette to 15 colors: {p_end}

{phang2}
{bf:. {stata "color_style egypt, graph n(15)"}}

{pstd}
You may or may not like this set of colors interpolated. Alternatively, you can choose to recycle the colors, 
using option {cmd:class()}. This is a colorpalette option: {p_end}

{phang2}
{bf:. {stata "color_style egypt, graph n(15) class(q)"}}

{pstd}
So, lets settle with the option above, and now make a simple scatter plot {p_end}

{phang2}
{bf:. {stata "xtile q4=exper, n(4)"}}{p_end}
{phang2}
{bf:. {stata "separate lnwage,by(q4)"}}{p_end}
{phang2}
{bf:. {stata "scatter lnwage? exper"}}

{pstd}
But of course, we can change this with any other palette:{p_end}

{phang2}
{bf:. {stata "color_style peru1"}}{p_end}
{phang2}
{bf:. {stata "scatter lnwage? exper"}}{p_end}
{phang2}
{bf:. {stata "color_style peru2"}}{p_end}
{phang2}
{bf:. {stata "scatter lnwage? exper"}}{p_end}
{phang2}
{bf:. {stata "color_style johnson"}}{p_end}
{phang2}
{bf:. {stata "scatter lnwage? exper"}}{p_end}
{phang2}
{bf:. {stata "graph bar lnwage?, stack"}}{p_end}
{phang2}
{bf:. {stata "color_style viridis, n(5)"}}{p_end}
{phang2}
{bf:. {stata "scatter lnwage? exper"}}{p_end}
{phang2}
{bf:. {stata "graph bar lnwage?, stack"}}


{pstd}
Finally, if you are interested looking at how many of the palettes look with , scatterplots, violinplots,
 or stream plots, you can look here: {browse "https://github.com/friosavila/playingwithstata/blob/gh-pages/articles/palette.md"}

{marker Aknowledgement}{...}
{title:Aknowledgement}

{pstd}
This command could not have been possible without the work by Ben Jann, who make it possible to easily manipulate colors in Stata using colorpalette, as well as his work with grstyle, which make it quite easy to manipulate schemes.
{p_end}

{pstd}
Furthermore, thank you to Blake Robert Mills, Karthik Ram and Jake Lawlor, who put together very amazing palettes.
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
Help:  {helpb colorpalette}, {helpb grstyle}

