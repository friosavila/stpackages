{smcl}
{* *! version 1 7july22}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Title}

{phang}
{bf:cre} {hline 2} Prefix program used for the estimation of Correlated Random Effect models


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:cre}, [options]: [{help command}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt abs(varlist)}}Provides the list of "fixed effects" that will be used to to create independent variable "means" {p_end}
{synopt:{opt keep}}request to "keep" the created variables after the estimation command is excecuted{p_end}
{synopt:{opt compact }}Request to create a single "mean" variable that aggregates all fixed effects means. The default is to create a separate variable per fixed effect{p_end}
{synopt:{opt keepsingletons}}Request "keeping" singletons, when estimating the indep. variable means. Default option is to drop singletons{p_end}
{synopt:{opth prefix(name)}}provides a string to be used as prefix for the newly created variables. THe default is using "m", so that the new variable will be named "m#_varname" or "m_varname" {p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:cre} is a prefix command that allows the user to easily implement correlated random effect models given a set of "fixed effects".

{pstd}For example, consider a simple panel model:

{pstd}  y_it = a_i + b * x_it + e_it

{pstd}The standard approach is to absorb (partial out) fixed effects, and estimate model coefficients on the the residual data:

{pstd}  y_it -E[y_it|i] =  b * (x_it-E[x_it|i]) + e_it

{pstd}The CRE model, instead aims to estimate the following model:

{pstd}  y_it = b0 + b * x_it + b_m * (E[x_it|i]-E[x_it]) + e_it

{pstd}For the linear model, this approach provides numerically identical results for the point estimates of "b".
The advantage, however, comes from using this strategy for nonlinear models. 

{pstd}Keep in mind that this command simply creates the new variables and adds them to the model specification. It does not account for standard error or degrees of freedom corrections. 

{marker remarks}{...}
{title:Remarks}

{pstd}
This program was created simply as a tool to facilitate the comparison of CRE in quantile regression setups. 

{pstd}It uses Sergio Correira {help reghdfe}

{pstd}All errors are my own.

{marker examples}{...}
{title:Examples}

{phang}{stata "sysuse auto"}{p_end}
{phang}{stata "replace headroom=round(headroom)"}{p_end}
{phang}{stata "replace price=price/1000"}{p_end}

{phang}{stata "regress mpg price foreign i.headroom"}{p_end}
{phang}{stata "reghdfe mpg price foreign, abs(headroom)"}{p_end}
{phang}{stata "cre, abs(headroom): regress mpg price foreign" }{p_end}
{phang}{stata "cre, abs(foreign headroom): regress mpg price" }{p_end}
{phang}{stata "cre, compact abs(foreign headroom): regress mpg price" }{p_end}

{phang}{stata "sysuse auto"}{p_end}
{phang}{stata "replace headroom=round(headroom)"}{p_end}
{phang}{stata "replace price=price/1000"}{p_end}

{pstd} For nonlinear models:
{phang}{stata "qreg mpg price foreign i.headroom, nolog q(10)"}{p_end}
{phang}{stata "cre, abs(headroom): qreg mpg price foreign  , nolog q(10)" }{p_end}

{phang}{stata "logit foreign  mpg price i.headroom"}{p_end}
{phang}{stata "cre, abs(headroom): logit foreign  mpg price  " }{p_end}



{marker Also see}{...}
{title:Also see}

{phang} {help reghdfe}