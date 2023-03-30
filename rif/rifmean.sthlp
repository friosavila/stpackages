{smcl}
{* *! version 1 Fernando Rios-Avila May 2021}{...}
{cmd:help rifmean} 
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{cmd:rifmean} {hline 2}}Estimate means for recentered influence
functions{p_end}
{p2colreset}{...}


{title:Syntax}
 
{p 8 17 2}
{cmd:rifmean} {varname} {ifin} {weight}{cmd:,}
{opt rif(RIF_options)} [{it:mean_options}]

{synoptset 25 tabbed}{...}
{marker opt}{synopthdr:options}
{synoptline}
{p2coldent :* {opt rif(RIF_options)}}specify a list of statistics for which
recentered influence functions (RIFs) will be estimated, including their statistic options, separated by a comma; see {helpb rifvar:rifvar()} for specifics{p_end}

{p2coldent : {it: mean_options}}One can use all {help mean} options with this command. The only one that is recycled is the option {cmd:over(varname)}. This is used to appropriately estimate the RIF function across different groups. {p_end}
{synoptline}
{p 4 6 2}
* {cmd:rif()} is required.
 

{title:Description}

{pstd}
{cmd:rifmean} is a wrapper command that uses the capabilities of {helpb mean}
to estimate statistics and its standard errors.
 
{pstd}
Because the command is a wrapper for {cmd:mean}, most options from
{cmd:mean} are available but have not been fully tested.

{pstd}
For the correct estimation of bootstrap standard errors, it is recommended to
use the {cmd:bootstrap} prefix to apply the bootstrap through the whole
estimation process.

{pstd}
{cmd:rifmean} typed without arguments replays the last results.

{title:Examples}

{phang2}
{bf:. {stata "webuse cattaneo2"}}

{pstd}
Simultaneous RIFs across quantiles, and standard deviation.{p_end}
{phang2}
{bf:. {stata rifmean bweight , rif(q(10),q(90),std)}}

{pstd}
Simultaneous RIFs across quantiles, and standard deviation. Means over mbsmoke.{p_end}
{phang2}
{bf:. {stata rifmean bweight , rif(q(10),q(90),std) over(mbsmoke)}}
 
{phang2}
{bf:. {stata "bootstrap: rifmean bweight , rif(q(10),q(90),std) over(mbsmoke)"}}
 

{marker Acknowledgments}{...}
{title:Acknowledgments}

{pstd}
RIF variables are estimated using the {cmd:egen} add-on {cmd:rifvar()}.  An
intuitive description of RIF regressions is provided in Rios-Avila (2020).

{pstd}
All errors are my own.

{title:References}

{phang}
Rios-Avila, F. 2020. Recentered influence functions (RIFs) in Stata: RIF regression and RIF decomposition.
Stata Journal, 20(1), 51-94. {browse "https://doi.org/10.1177/1536867X20909690"}. 


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
Help:  {helpb rifreg}, {helpb reghdfe}, {helpb oaxaca_rif}, 
{helpb rifvar:rifvar()},  {helpb rifhdreg}, {helpb rifsureg}, {helpb uqreg},
{helpb hvar:hvar()} (if installed), {manhelp sureg R}, {manhelp mean R} {p_end}
