{smcl}
{* *! version 1.2.2  15may2018}{...}
{vieweralsosee "" "--"}{...}
{title:fra_tools}

This helpfile provides a quick list of random programs, all in fra_tools that I have found useful.

{title:Commands}

{hline}

{phang}
{bf:drop2} {hline 2} Alternative to {help drop}.

{p 8 17 2}
{cmdab:drop2}
{varlist}

{cmd:Description}

{pstd}
{cmd:drop2} is an alternative to {help drop}, with two added features. First, it only drops variables if the provided name matches exactly the a variable in the dataset. 
This may prevent unintentially dropping required variables. Second, it will drop all variables in a given variable list, even if some are not available in the dataset. 

{cmd:Examples}

Setup

{phang} {stata  sysuse auto}
 
This should drop nothing, because there is no variable named "pr"

{phang} {stata  drop2 pr }

This should drop price and mpg, but notify you that prices and mph were not found

{phang} {stata  drop2 price prices mph mpg}

{hline}

{phang}
{bf:encode2} {hline 2} Alternative to {help encode}.

{p 8 17 2}
{cmdab:encode2}
{varlist}, prefix(name)

{cmd:Description}

{pstd}
{cmd:encode2} is an alternative to {help encode}, with two added features. It allows you to encode more than 1 variable at a time, using the same rules across all. The new variables are named using -prefix- and the original variable name.

{cmd:Examples}

Setup: create 3 variables based on the care maker. 

{phang} {stata  sysuse auto, clear}{p_end}
{phang} {stata  split make}{p_end}
{phang} {stata  replace make2=make1[runiformint(1,74)]}{p_end}
{phang} {stata  replace make3=make1[runiformint(1,74)]}{p_end}
 
Encode make1 make2 and make3 using the prefix "cd_"

{phang} {stata  encode2 make1 make2 make3, prefix(cd_)}

Now all new variables cd_make1, cd_make2 and cd_make3 should be coded the same way

{phang} {stata  tab cd_make1 if cd_make1 ==1 }{p_end}
{phang} {stata  tab cd_make2 if cd_make2 ==1 }{p_end}
{phang} {stata  tab cd_make3 if cd_make3 ==1 }{p_end}

{hline}

{phang}
{bf:addr} {hline 2} Utility to add information to r()

{p 8 17 2}
{cmdab:addr [scalar/local/matrix] } name = {help exp} [, new]

{cmd:options}
{p 8 17 2}
{cmd: new}  It replaces all the elements in r() with the new element, otherwise, it simply adds  information to r().

{cmd:Description}

{pstd}
{cmd:addr} is a utility that can be used to add information to r() from a previously executed command. It may be useful for adding further information to ouputs. Without modifying the original ado file.

{cmd:Examples}

Setup

{phang} {stata  sysuse auto}
 
Summary Statistics

{phang} {stata  summarize price mpg }

Add a comment

{phang} {stata addr local comment "This are summary statistics for mpg and price"}

Review

{phang} {stata  return list }

{hline}

{phang}
{bf:adde} {hline 2} Utility to add information to e()

{p 8 17 2}
{cmdab:adde [scalar/local/matrix] } name = {help exp}
{cmdab:adde [post/repost] } name , options

{cmd:Description}

{pstd}
{cmd:adde} is a utility that can be used to add information to e() from a previously executed command. It may be useful for adding further information to ouputs, without modifying the original ado file. This also takes the advantage of being able to save e() results into an ster file.

{cmd:Examples}

Setup

{phang} {stata  sysuse auto}
 
Regression

{phang} {stata  reg price mpg }

Add r(table) as part of the e() information.

{phang} {stata matrix table = r(table)}{p_end}
{phang} {stata adde matrix table = table}{p_end}
{phang} {stata adde loca comment "Example that adds table to e()"}

Review to make sure its there

{phang} {stata  ereturn list }

{hline}

{phang}
{bf:editsource} {hline 2} Utility to open a file in the Stata editor

{cmd:Description}

{pstd}
{cmd:editsource} is a clone of viewsource. However, instead of 
viewing the file, you can now edit it.  
You may find it useful for copy pasting your own programs.

{hline}

{phang}
{bf:emargins} {hline 2} Utility to store margins output without using post

{p 8 17 2}
{cmdab:emargins} options , {it:margin_options} [estore(name) esave(name)]

{cmd:Description}

{pstd}
{cmd:emargis} is a clone of {help margins}. It should help for storing margins results
into memory or disk, without loosing your previously estimated models  

{hline}

{phang}
{bf:fg_commands} {hline 2} Commands that would allow using transformations before 
running calculations or makeing graphs

{cmd:Description}

These commands aim to provide more flexiblity when doing exploratory analysis. They allow 
you to use transformations of variables directly on some commands. 

These commands are:

fghistogram, fgkdensity, fgmean, fgreg, fgscatter, fgsum


{marker author}{...}
{title:Author}

{pstd}
Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org
