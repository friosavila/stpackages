{smcl}
{* *! version 1.0 Fernando Rios-Avila July 2019}{...}
{cmd:help hvar()}
{hline}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col :{cmd:hvar()} {hline 2}}Extension to generates recentered influence
function for half-variance{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:egen} [{it:type}] {it:newvar} {cmd:=}
{cmd:hvar}{cmd:(}{it:varname}{cmd:)} 
{ifin}
[{cmd:,} {opt by(varname)} {opt weight(varname)} [{cmd:hvp}|{cmd:hvn}]]

{synoptset 20}
{synopthdr}
{synoptline}
{synopt:{opth by(varname)}}indicate the variables over which the recentered
influence function (RIF) will be
estimated{p_end}
{synopt:{opth weight(varname)}}indicate the weight to be used for the
estimation of RIFs{p_end}
{synopt:{opt hvp}}estimate the positive half-variance (default){p_end}
{synopt:{opt hvn}}estimate the negative half-variance{p_end}
{synoptline}


{title:Description}

{p 4 4 2}
{cmd:egen} {cmd:hvar()} creates a new variable, {it:newvar}, of the optionally
specified storage type equal to the RIF for the half-variance using the
jackknife method, over a set of groups specified with {cmd:by()} and
considering weights specified with {cmd:weight()}.


{title:Remarks}

{pstd}
This program is meant to be a template to write programs that can be used to
create RIF functions for statistics not available in {helpb rifvar:rifvar()}
so that {helpb rifvar:rifvar()}, {helpb oaxaca_rif}, and {helpb rifhdreg} can
be used with other RIFs.{p_end}

{pstd}
The program estimates the half-variance, which is defined as follows:{p_end}

{phang2}
HVAR_positive = sum[{x>E(x)}*{x-E(x)}^2]{p_end}

{phang2}
HVAR_negative = sum[{x<E(x)}*{x-E(x)}^2]{p_end}

{pstd}
HVAR_positive can be requested with the option {cmd:hvp}, and HVAR_negative
can be requested with the option {cmd:hvn}.
 
 
{marker Author}{...}
{title:Author}

{pstd}
Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org


{title:Also see}

{p 4 14 2}

{p 7 14 2}
Help:  {helpb rifvar:rifvar()} {helpb rifhdreg}, {helpb rifreg},
{helpb rifsureg}, {helpb rifsureg2}, {helpb uqreg}, (if installed),
{manhelp egen D}{p_end}
