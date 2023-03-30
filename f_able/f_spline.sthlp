{smcl}
{* *! version 3.0 Fernando Rios-Avila September 2022}{...}
{cmd:help f_spline}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{cmd:f_spline} {hline 1}} Module for the construction of polynomial splines for {cmd:f_able} {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{phang}
Polynomial spline of degree #d with knots at specified points

{p 8 17 2}
{cmd:f_spline}
{it:{help prefix}}
{cmd:=}
{it:oldvar}
{ifin}
[{cmd:,  {opt k:nots(numlist)} {opt d:egree}(#d) }]

{phang}
Polynomial spline of degree #d with equally spaced #k knots

{p 8 17 2}
{cmd:f_spline}
{it:{help prefix}}
{cmd:=}
{it:oldvar}
{ifin}
[{cmd:,  {opt nk:nots(#k)} {opt d:egree}(#d) }]

{phang}
Polynomial spline of degree #d with knots set at predefined percentiles

{p 8 17 2}
{cmd:f_spline}
{it:{help prefix}}
{cmd:=}
{it:oldvar}
{ifin}
[{cmd:,  weight(varname) {opt kp:ctile(numlist)} {opt d:egree}(#d)}]

{phang}
Polynomial spline of degree #d with #k knots set at equally distant #k percentiles.

{p 8 17 2}
{cmd:f_spline}
{it:{help prefix}}
{cmd:=}
{it:oldvar}
{ifin}
[{cmd:,  weight(varname) {opt np:ctile(#k)} {opt d:egree}(#d)}]


{marker description}{...}
{title:Description}

{pstd}
{opt f_spline} is a companion program for {help f_able} that 
creates variables containing a polynomial spline of any degree for an existing variable.{p_end}

{pstd}
It will use {it: prefix} to create the necessary number of new variables to create the splines.
Each new variable will be named consecutively starting from 2. For example, if one creates a linear spline
with 2 knots, the program will generate 2 new variables named {it: prefix}2 and {it: prefix}3.
{p_end}

{pstd}
For a given set of knots kn_1, kn_2,..., kn_k, and degre #d, the new variables are created using the following formula:
{p_end}

{pstd}v_j=oldvar^j for j=2...d             if d>=2   {p_end}
{pstd}v_j=max(oldvar-kn_h,0)^d for j=d+1...d+k & h=j-d           {p_end}
 
{pstd}where the definition for knots kn_1,...,kn_k depend on which syntax was used.{p_end}
 
{marker options}{...}
{title:Options}

{dlgtab:Options}

{phang}
{cmd: {opt d:egree(numlist)}} Indicates the degree of the spline polynomials. 
The default is 1 (linear spline). 

{phang}
{cmd: {opt k:nots(numlist)}} When used, the list of numbers provided 
are used to define the relevant knots. This knots have to be larger 
than the minimum value of {it: oldvar} but smaller than the maximum value.

{phang}
{cmd: {opt nk:nots(#nk)}} When used, #k equally spaced values between the minimum 
and maximum value of {it: oldvar} are used as knots.

{phang}
{cmd: {opt kp:ctile(numlist)}} When used, the list of numbers corresponds to the
percentiles that would be used define the knots based on the of the empirical 
distribution of {it: oldvar}. The list of numbers has to be >0 and <100.

{phang}
{cmd: {opt np:ctile(#nk)}} When used, #k equally spaced percentiles are 
used to define the knots based on the empirical distribution of {it: oldvar}.
 
{phang}
{cmd:weight(varname)} Used to indicate a weight variable to be used internally 
to determine the empirical distribution of {it: oldvar}. It can only be used with 
the 3rd and 4th syntax of {cmd: f_spline}.

{phang}
{cmd:replace} Request replacing variables if they already exist in memory.

{marker examples}{...}
{title:Examples}

{pstd} Fit a regression of log income on education and age by using a piecewise
linear function for age, with predefined knots {p_end}
{phang2}{stata webuse mksp1, clear}{p_end}
{phang2}{stata f_spline sage = age, knots(20 30 40 50 60) }{p_end}
{phang2}{stata regress lninc educ age sage2-sage6}{p_end}
{phang2}{stata f_able sage2-sage6, auto}{p_end}
{phang2}{stata margins, dydx(age)}{p_end}

{pstd} Fit a regression of log income on education and age by using a piecewise
linear function for age, using 5 equally spaced percentiles {p_end}
{phang2}{stata webuse mksp1, clear}{p_end}
{phang2}{stata f_spline sage = age, npctile(5) }{p_end}
{phang2}{stata regress lninc educ age sage2-sage6}{p_end}
{phang2}{stata f_able sage2-sage6, auto}{p_end}
{phang2}{stata margins, dydx(age)}{p_end}
 
{pstd}Perform a logistic regression of outcome against a quadratic spline with 
3 knots defined at specific percentiles{p_end}
{phang2}{stata webuse mksp2, clear}{p_end}
{phang2}{stata f_spline dose = dosage, degree(2) kpctile(25 50 75) }{p_end}
{phang2}{stata logistic outcome dosage dose2-dose5}{p_end}
{phang2}{stata f_able dose2-dose5, auto}{p_end}
{phang2}{stata margins, dydx(dosage)}{p_end}


{title:Also see}

{p 7 14 2}
Help:  {helpb f_able}, {helpb f_rcspline}, {helpb mkspline}{p_end}
