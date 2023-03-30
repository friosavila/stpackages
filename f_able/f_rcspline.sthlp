{smcl}
{* *! version 3.0 Fernando Rios-Avila September 2022}{...}
{cmd:help f_rcspline}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{cmd:f_rcspline} {hline 1}} Module for the construction of restricted cubic spline for {cmd:f_able} {p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{phang}
Restricted cubic spline

{p 8 17 2}
{cmd:f_rcspline}
{it:{help prefix}}
{cmd:=}
{it:oldvar}
{ifin}
[{cmd:,  {opt k:nots(numlist)} {opt nk:nots(#k)} weight(varname) replace}]

{marker description}{...}
{title:Description}

{pstd}
{cmd:f_rcspline} creates new variables containing restricted cubic spline of an existing variable. 
Restricted cubic splines are constructed in a similar way to {help mkspline}.
When no weights are provided, knots are calculated using {help centile}, however if weights are specified
the programm uses {help _pctile} instead. This may case small differences with respect to mkspline.
{p_end}

{pstd}
As with {cmd: mkspline}, knot locations are based on Harrell's (2001) recommended
    percentiles {cmd:nknots(#k)} or user-specified points (option {cmd:knots(numlist)}).
{p_end}

{pstd}	
It will use {it: prefix} to create the necessary number of new variables to create the splines.
Each new variable will be named consecutively starting from 2.
{p_end}

{marker options}{...}
{title:Options}

{dlgtab:Options}

{phang}
{cmd: {opt nk:nots(numlist)}}  It specifies the number of knots that are to be used for a
        restricted cubic spline.  This number must be between 3 and 7 unless the knot locations are specified using
        knots().  
		
{phang}		
{cmd: {opt k:nots(#k)}}  It specifies the exact location of the knots to be used for a
        restricted cubic spline.  
		
{phang}
{cmd:weight(varname)} it specifies a weight variable to be used internally 
to determine the empirical distribution of {it: oldvar}, and determine the 
location of the knots when using the option {cmd: nk:nots(#k)}.

{phang}		
{cmd: {opt replace}}  Request to replace the variables if they already exist in the dataset.  
		
{marker examples}{...}
{title:Examples}

{pstd}  Perform a logistic regression of outcome against a restricted cubic spline
function of dosage with four knots chosen according to Harrell(2001) recommended percentiles
{p_end}

{phang2}{stata webuse mksp2, clear}{p_end}
{phang2}{stata f_rcspline dose = dosage, nknots(4)} {p_end}
{phang2}{stata logistic outcome dosage dose2 dose3}{p_end}
{phang2}{stata f_able dose2 dose3, auto}{p_end}
{phang2}{stata margins, dydx(dosage)}{p_end}

{title:Reference}

{marker harrell2001}{...}
{phang}
Harrell, F. E., Jr.  2001.
{it:Regression Modeling Strategies: With Applications to Linear Models, Logistic Regression, and Survival Analysis}.
New York: Springer.
{p_end}


{title:Also see}

{p 7 14 2}
Help:  {helpb f_able}, {helpb f_spline}, {helpb mkspline}, {p_end}

