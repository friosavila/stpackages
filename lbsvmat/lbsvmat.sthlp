{smcl}
{* *! version 1.0 Fernando Rios-Avila May 2020}{...}
{cmd:help lbsvmat}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{cmd:lbsvmat} {hline 1}} Module to create labeled variables from a matrix {p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{opt  lbsvmat [type] A}, [name(string) matname] 

{title:Options}
 
{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}

{p2coldent : {opt name(string)}} specifies how the new variables are to be named. If left empty (default), the new variables will 
be created using the matrix name as prefix. Otherwise, it uses {it:name} as the variable variable prefix. {p_end}
{p2coldent : {opt matname}} if specified, the new variables are named using the matrix coleq and colname information. 
It can be combined with name. {p_end}

{synoptline}
 
{title:Description}

{pstd}
{cmd:lbsvmat} is a command that is similarly to {help svmat}. It can be used to create variables 
from a matrix A, using a variable format of your choice, The default is {cmd: float}.{p_end}

{pstd}
In contrast with {help svmat}, the default option is for the newly created variables 
to be labeled using the matrix column names and column equations names. {p_end}

{pstd}
One can also use the options {cmd:name} as a prefix for the new variables, and matname to use 
to name the variables based on the columns name and equation.{p_end}

{pstd}  
This can be useful for identifying which new variable corresponds to the original matrix column. 
Useful for creation of coefficient plots with qreg, or other similar plots. See anscilliary dofile for some examples.
 
{marker Acknowledgments}{...}
{title:Acknowledgments}

{pstd}
This program was inspired by various request about how to easily plot coefficients from quantile regressions models
(on its many flavors).

{pstd}
All errors are my own.

{marker Author}{...}
{title:Author}

{pstd}
Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org


