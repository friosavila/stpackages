{smcl}
{* *! version 1.0  March 2022}{...}

{title:Title}

{phang}
{bf:color_style} {hline 2} Module to change colors in your scheme file


{title:Syntax}

{p 8 16 2}
{cmd:color_style} [{it:palette}] [, {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt g:raph}}display the palette of colors to be applied{p_end}
{synopt:{opt rand:om}}select a random palette from those available with the package{p_end}
{synopt:{opt list}}provide a list of palettes that accompany this file{p_end}
{synopt:{opt list(letter)}}provide a list of palettes that start with "letter"{p_end}
{synopt:{opt n(#)}}define the number of colors to be used for the palette (1-15){p_end}
{synopt:{opt i:polate(#)}}same as {opt n()}, but works with Stata versions earlier than 14.2{p_end}
{synopt:{opt show:case}}show how the palette will look for up to 15 colors{p_end}
{synopt:{help colorpalette##options:{it:colorpalette_options}}}any options from {helpb colorpalette}{p_end}
{synoptline}

{p 4 6 2}
{cmd:font_style} {it:font}

{p 4 6 2}
{cmd:graphquery} [{it:options}]


{title:Description}

{pstd}
{cmd:color_style} provides an easy way to change the palette colors in your scheme and graphs. 
It works as a wrapper for {helpb colorpalette} and {helpb grstyle}. The palettes were put together 
by Blake Robert Mills, Karthik Ram, and Jake Lawlor.

{pstd}
Because this command works as a wrapper for {cmd:colorpalette}, you can easily use your own palettes 
or the ones in {cmd:colorspace} to enhance your graphs.

{pstd}
{cmd:font_style} changes the font face for your graphs.

{pstd}
{cmd:graphquery} returns the scheme properties associated with a particular option.


{title:Options}

{phang}
{opt palette} specifies a particular palette to be applied to the scheme file. You can use
any of the palettes or color options following {help colorpalette} syntax, or the palettes provided 
with this command. See {cmd:list} option.

{phang}
{opt graph} displays the palette of colors to be applied.

{phang}
{opt random} selects a random palette from those available with the package.

{phang}
{opt list} provides a list of palettes that accompany this file. These are in addition to those in {help colorpalette}.

{phang}
{opt list(letter)} provides a list of palettes that start with "letter".

{phang}
{opt n(#)} defines the number of colors to be used for the palette. {it:#} should be between 1 and 15. 
If you select a number larger than 15, those colors will not be used in the scheme file. If {it:#} < 15, 
unused pstyles will be recycled.

{phang}
{opt ipolate(#)} same as {opt n(#)}. However, {opt n(#)} does not work under Stata versions earlier than 14.2.

{phang}
{opt showcase} shows how the palette will look for up to 15 colors.

{pstd}
The default is to use the number of colors in the palette. For example, {cmd:Greek} has 5 default colors. 
Using an {opt n(#)} higher or lower than this will interpolate colors. See the options in {help colorpalette}.


{title:Examples}

{pstd}Load some data:{p_end}
{phang2}{cmd:. use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta}{p_end}
{phang2}{cmd:. set scheme white}{p_end}

{pstd}List available palettes:{p_end}
{phang2}{cmd:. color_style, list}{p_end}

{pstd}Display the Egypt palette:{p_end}
{phang2}{cmd:. color_style egypt, graph}{p_end}

{pstd}Extend the Egypt palette to 15 colors:{p_end}
{phang2}{cmd:. color_style egypt, graph n(15)}{p_end}

{pstd}Recycle colors using the {cmd:class()} option:{p_end}
{phang2}{cmd:. color_style egypt, graph n(15) class(q)}{p_end}

{pstd}Create a scatter plot with the selected palette:{p_end}
{phang2}{cmd:. xtile q4 = exper, n(4)}{p_end}
{phang2}{cmd:. separate lnwage, by(q4)}{p_end}
{phang2}{cmd:. scatter lnwage? exper}{p_end}

{pstd}Try different palettes:{p_end}
{phang2}{cmd:. color_style peru1}{p_end}
{phang2}{cmd:. scatter lnwage? exper}{p_end}
{phang2}{cmd:. color_style peru2}{p_end}
{phang2}{cmd:. scatter lnwage? exper}{p_end}
{phang2}{cmd:. color_style johnson}{p_end}
{phang2}{cmd:. scatter lnwage? exper}{p_end}
{phang2}{cmd:. graph bar lnwage?, stack}{p_end}
{phang2}{cmd:. color_style viridis, n(5)}{p_end}
{phang2}{cmd:. scatter lnwage? exper}{p_end}
{phang2}{cmd:. graph bar lnwage?, stack}{p_end}


{title:Acknowledgements}

{pstd}
This command would not have been possible without the work of Ben Jann, who made it possible to easily 
manipulate colors in Stata using {cmd:colorpalette}, as well as his work with {cmd:grstyle}, which makes 
it quite easy to manipulate schemes.

{pstd}
Furthermore, thanks to Blake Robert Mills, Karthik Ram, and Jake Lawlor, who put together amazing palettes.


{title:Author}

{pstd}Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Blithewood-Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org


{title:Also see}

{p 4 14 2}
Help:  {helpb colorpalette}, {helpb grstyle}

{p 7 14 2}
Online:  {browse "https://github.com/friosavila/playingwithstata/blob/gh-pages/articles/palette.md":Palette examples}