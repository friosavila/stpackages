{smcl}
{* *! version 1.1 30Aug24}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "cre##syntax"}{...}
{viewerjumpto "Description" "cre##description"}{...}
{viewerjumpto "Options" "cre##options"}{...}
{viewerjumpto "Remarks" "cre##remarks"}{...}
{viewerjumpto "Examples" "cre##examples"}{...}
{title:Title}

{phang}
{bf:cre} {hline 2} Prefix program for estimating Correlated Random Effect models


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:cre}, [options]: [{help command}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt abs(varlist)}}specifies the "fixed effects" variables used to create independent variable "means"{p_end}
{synopt:{opt drop}}Drops all created variables after the estimation command is executed. Default is to keep them in the data{p_end}
{synopt:{opt compact}}creates a single "mean" variable aggregating all fixed effects means (default is to create a separate variable per fixed effect){p_end}
{synopt:{opt dropsingletons}}drop singletons when estimating the independent variable means (default is to keep singletons){p_end}
{synopt:{opth prefix(name)}}specifies a string to be used as prefix for newly created variables (default is "m", resulting in "m#_varname" or "m_varname"){p_end}
{synopt:{opth hdfe(options)}}Specifies other options that would be used directly in reghdfe. This could help to increase the processing speed. {p_end}

{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:cre} is a prefix command that facilitates the implementation of correlated random effect models given a set of "fixed effects".

{pstd}Consider a simple panel model:

{pstd}  y_it = a_i + b * x_it + e_it

{pstd}The standard approach is to absorb (partial out) fixed effects and estimate model coefficients on the residual data:

{pstd}  y_it - E[y_it|i] =  b * (x_it - E[x_it|i]) + e_it

{pstd}The CRE model instead aims to estimate the following:

{pstd}  y_it = b0 + b * x_it + b_m * (E[x_it|i] - E[x_it]) + e_it

{pstd}For linear models, this approach provides numerically identical results for the point estimates of "b".
The advantage, however, comes from using this strategy for nonlinear models. 

{pstd}Note that this command only creates new variables and adds them to the model specification. It does not account for standard error or degrees of freedom corrections. 
 
{marker remarks}{...}
{title:Remarks}

{pstd}It uses Sergio Correia's {help reghdfe} command and one utility from {help ftools}

{pstd}All errors are the author's own.

{marker examples}{...}
{title:Examples}

{phang}{stata "sysuse auto"}{p_end}
{phang}{stata "replace headroom = round(headroom)"}{p_end}
{phang}{stata "replace price = price / 1000"}{p_end}

{phang}{stata "regress mpg price foreign i.headroom"}{p_end}
{phang}{stata "reghdfe mpg price foreign, abs(headroom)"}{p_end}
{phang}{stata "cre, abs(headroom): regress mpg price foreign"}{p_end}
{phang}{stata "cre, abs(foreign headroom): regress mpg price"}{p_end}
{phang}{stata "cre, compact abs(foreign headroom): regress mpg price"}{p_end}

{pstd}For nonlinear models:{p_end}
{phang}{stata "qreg mpg price foreign i.headroom, nolog q(10)"}{p_end}
{phang}{stata "cre, abs(headroom): qreg mpg price foreign, nolog q(10)"}{p_end}

{phang}{stata "logit foreign mpg price i.headroom"}{p_end}
{phang}{stata "cre, abs(headroom): logit foreign mpg price"}{p_end}


{marker Author}{...}
{title: Author}

{pstd}
Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org


{marker Alsosee}{...}
{title:Also see}

{phang}
Help: {help reghdfe}
