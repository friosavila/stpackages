{smcl}
{* *! version 2.6 Fernando Rios-Avila May 2021}{...}
{cmd:help rifvar()}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{cmd:rifvar()} {hline 2}}Extension to generate recentered influence
functions{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:egen} [{it:type}] {it:newvar} {cmd:=}
{cmd:rifvar}{cmd:(}{it:varname}{cmd:)} 
{ifin}
[{cmd:,} {it:options}]

{p 8 17 2}
{cmd:egen} [{it:type}] {it:newvar} {cmd:=}
{cmd:rifvar_old}{cmd:(}{it:varname}{cmd:)} 
{ifin}
[{cmd:,} {it:options}]

{synoptset 40 tabbed}{...}
{marker options}{...}
{synopthdr :options}
{synoptline}
{syntab :Main}
{synopt:{opth by(varname)}}indicate the variables over which the recentered
influence
functions (RIFs) will be estimated{p_end}
{synopt:{opt weight(varname)}}indicate the weight to be used for the estimation of RIFs{p_end}
{synopt:{opt seed(str)}}indicate a particular seed for replication
of rank-dependent indices. no longer needed with newer algorithm{p_end}

{marker rifopt}{...}
{syntab:RIF_options}
{synopt :{opt mean}}sample mean{p_end}
{synopt :{opt var}}variance{p_end}
{synopt :{opt q(#p)} [{opt kernel(kernel)} {opt bw(#)}]}{it:p}th quantile, where
0<{it:#p}<100;
the kernel functions available are {cmd:gaussian} (default), {cmd:epan},
{cmd:epan2}, {cmd:biweight}, {cmd:cosine}, {cmd:parzen}, {cmd:rectan},
{cmd:triangle}, and {cmd:triweight}; 
all kernel functions available for the
command {cmd:kdensity} are also allowed; bandwidth default is the Silverman's plugin optimal bandwidth{p_end}
{synopt :{opt iqr(#p1 #p2)} [{opt kernel(kernel)} {opt bw(#)}]}interquantile
range: {opt q(#p2)} - {opt q(#p1)}, where 0<{it:p1}<={it:p2}<100; {cmd:bw()}
and {cmd:kernel()} are the same as for the quantile case{p_end}
{synopt :{opt gini}}Gini inequality index{p_end}
{synopt :{opt cvar}}coefficient of variation{p_end}
{synopt :{opt std}}standard deviation{p_end}
{synopt :{opt iqratio(#p1 #p2)} [{opt kernel(kernel)} {opt bw(#)}]}interquantile ratio:
{opt q(#p2)}/{opt q(#p1)}, where 0<{it:p1}<={it:p2}<100;
{cmd:bw()} and {cmd:kernel()} are the same as for the quantile case{p_end}
{synopt :{opt entropy(#a)}}generalized entropy inequality index with sensitivity index
{it:#a}{p_end}
{synopt :{opt atkin(#e)}}Atkinson inequality index with inequality aversion
{it:#e}>0{p_end}
{synopt :{opt logvar}}logarithmic variance (different from variance of logarithms){p_end}
{synopt :{opt glor(#p)}}generalized Lorenz ordinate at {it:#p}, where 0<{it:#p}<100{p_end}
{synopt :{opt lor(#p)}}Lorenz ordinate at {it:#p}, where 0<{it:#p}<100{p_end}
{synopt :{opt ucs(#p)}}share of income held by richest 1-p%; 1-{opt lor(#p)}{p_end}
{synopt :{opt iqsr(#p1 #p2)}}interquantile share ratio: 
(1-{opt lor(#p2)})/{opt lor(#p1)},
where 0<{it:#p1}<={it:#p2}<100{p_end}
{synopt :{opt mcs(#p1 #p2)}}share of income held by people between {it:#p1} and
{it:#p2}: {opt lor(#p2)}-{opt lor(#p1)}, where 0<{it:#p1}<{it:#p2}<100; also known as P_shares{p_end}
{synopt :{opt pov(#a)} {opt pline(#|varname)}}Foster-Greer-Thorbecke
poverty index given sensitivity parameter {it:#a}; {cmd:pov(0)} obtains the
poverty head count, {cmd:pov(1)} obtains the poverty gap, and {cmd:pov(2)}
obtains the poverty
severity; Foster-Greer-Thorbecke indices
are defined based on the poverty line {cmd:pline()}, which can be a scalar
(fixed poverty line) or a variable (variable poverty line){p_end}
{synopt :{opt watts(#povline)}}Watts poverty index; requires a number or variable to define the poverty line{p_end}
{synopt :{opt sen(#povline)}}Sen poverty index; requires a number to define the poverty line{p_end}
{synopt :{opt tip(#p)} {opt pline(#)}}three I's of poverty (TIP) curve ordinate at
{it:#p} for poverty line defined by {opt pline(#)}, where 0<{it:#p}<100{p_end}
{synopt :{opt agini}}absolute Gini{p_end}
{synopt :{opt acindex(varname)}}absolute concentration index using {it:varname} as the rank variable{p_end}
{synopt :{opt cindex(varname)}}concentration index using {it:varname} as the rank variable{p_end}
{synopt :{opt eindex(varname)} {opt lb(#)} {opt ub(#)}}Erreygers's index using
{it:varname} as
the rank variable, with lower bound {cmd:lb()} and upper bound {cmd:ub()} and
where {cmd:lb()}<{cmd:ub()}{p_end}
{synopt :{opt arcindex(varname)} {opt lb(#)}}attainment relative concentration index
using {it:varname} as the rank variable, with lower bound {cmd:lb()}{p_end}
{synopt :{opt srindex(varname)} {opt ub(#)}}shortfall relative concentration index
using {it:varname} as the rank variable, with upper bound {cmd:ub()}{p_end}
{synopt :{opt windex(varname)} {opt lb(#)} {opt ub(#)}}Wagstaff concentration index using
{it:varname} as the rank variable, with lower bound {cmd:lb()} and upper bound
{cmd:ub()}
and where {cmd:lb()}<{cmd:ub()}{p_end}
{synopt :{opt rifown(str)} {opt rifopt(str)}}these options are added to enable
{cmd:rifvar()} to use other community-contributed programs to estimate RIF for
statistics not available in this list; one can potentially use
analytical methods or numerical methods (like jackknife) to estimate the RIF
functions; community-contributed programs should be compatible to be used
with {helpb egen} and should allow for two options: {cmd:by()} and
{cmd:weight}; other options are allowed;
to use it, the name of the program should be indicated in {cmd:rifown()},
whereas options other than {cmd:weight} or {cmd:by()} would go in
{cmd:rifopt()};
see the file {bf:{stata "viewsource _ghvar.ado":_ghvar.ado}} for a template of a program;
this program estimates the RIF for half-variance using jackknife methods;
the option {cmd:hvp} estimates the RIF positive half-variance, and {cmd:hvn}
estimates the RIF negative half-variance;
an example of  how it can be used with {helpb oaxaca_rif} and {helpb rifhdreg}
is available in their respective help files{p_end}
{synoptline}


{title:Description}

{p 4 4 2}
{cmd:egen} {cmd:rifvar()} creates a new variable, {it:newvar}, of the
optionally specified storage type equal to the RIF of the specified statistic,
over a set of groups specified with {cmd:by()} and considering weights
specified by {cmd:weight()}. The newest version uses {cmd:Mata} for all RIF calculations
improving the precision and stability of some concentration and rank dependence indices. 
For replication purposes, one can use the older program now named {cmd:rifvar_old()}


{title:Remarks}

{pstd}
The function {cmd:rifvar()} creates a corresponding RIF for the specified
distributional statistic  (see {help rifvar##rifopt:{it:RIF_options}}), over a
set of groups defined in {opt by()} and allowing for the use of weights
{cmd:weight()}.{p_end}

{pstd}
Because of their nature, rank-dependent indices like the concentration ratio
may be slightly different every time if there are ties within
observations. In the newest algorithm, this has been fixed, and seed is no longer needed.{p_end}

{pstd}
A similar problem is observed with indices like the Lorenz and generalized
Lorenz coordinates. To obtain indices that can be fully replicated, one can
use the option {cmd:seed()}.  This option creates an auxiliary random variable
that is used to break the ties when ranking observations.{p_end}

{pstd}
To allow for greater flexibility with the commands {helpb oaxaca_rif} and
{helpb rifhdreg}, one can use the options {opt rifown(str)} and 
{opt rifopt(str)} to apply other community-contributed commands.
 

{title:Acknowledgments}

{pstd}
Some of the RIF derivations were taken based on the community-contributed
command {cmd:rifreg} and the do-file for {cmd:rifireg}.

{pstd}
The derivations of the RIFs for all the other statistics were taken from
various sources, all cited in the reference section.

{pstd}
An intuitive description of RIFs, RIF regressions, and RIF decompositions is
provided in Rios-Avila (2020).  The appendix of that article also provides the
exact formulas used for defining the RIFs, as well as the sources that were
used to obtain them.

{pstd}
All errors are my own.


{title:Reference}

{phang}
Rios-Avila, F. 2020. Recentered influence functions (RIFs) in Stata: RIF regression and RIF decomposition.
Stata Journal, 20(1), 51-94. {browse "https://doi.org/10.1177/1536867X20909690"}. 


{marker Author}{...}
{title:Author}

{pstd}Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org


{title:Also see}

{p 4 14 2}
 
{p 7 14 2}
Help:  {helpb rifhdreg}, {helpb rifreg}, {helpb rifsureg}, {helpb rifsureg2},
{helpb uqreg}, {helpb hvar:hvar()} (if installed), {manhelp egen D}{p_end}
