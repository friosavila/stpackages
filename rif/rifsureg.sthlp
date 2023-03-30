{smcl}
{* *! version 1.1 Fernando Rios-Avila July 2019}{...}
{cmd:help rifsureg}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{cmd:rifsureg} {hline 2}}Seemingly unrelated recentered influence
function regression{p_end}
{p2colreset}{...}

{title:Syntax}
 
{p 8 16 2}
{cmd:rifsureg} {depvar} [{indepvars}] {ifin} {weight}{cmd:,} 
{opt qs(numlist)} [{it:options}]

{synoptset 25 tabbed}{...}
{marker opt}{synopthdr:options}
{synoptline}
{p2coldent :* {opt qs(numlist)}}specify a list of numbers corresponding to the
quantiles of interest to be estimated; one can use any number between 0 and
100{p_end}
{synopt :{opt bw(#)}}specify bandwidth{p_end}
{synopt :{opt kernel(kernel)}}specify a specific kernel function{p_end}
{synopt :{opt retain(str)}}specify a prefix for a new variable where the
generated recentered influence functions (RIFs) will be stored, based on the sample used in the regression; by
default, new variables are stored as {cmd:__}{it:depvar}{cmd:_q}{it:##}{p_end}
{synopt :{opt replace}}when {cmd:retain()} is specified, 
overwrite the variable {opt retain(str)} if it already exists{p_end}
{synopt :{opt over(varname)}}indicate a variable over which the RIF will be
estimated; this can be understood as a partial conditional RIF; when the variable
used is binomial, the regression can be seen as the ordinary least-squares
alternative to Oaxaca-Blinder decomposition{p_end}
{synopt :{opt rwlogit(varlist)}}specify the {cmd:logit} regression for the
estimation of the reweighting factors; the variable used in {cmd:over()} is
used as the dependent variable;
this can be used to obtain estimates akin to treatment effects under the assumption of exogeneity{p_end}
{synopt :{opt rwprobit(varlist)}}specify the {cmd:probit} regression for the
estimation of the reweighting factors; the variable used in {cmd:over()} is
used as the dependent variable;
this can be used to obtain estimates akin to treatment effects under the assumption of exogeneity{p_end}
{synopt :{opt rwmlogit(varlist)}}specify the {cmd:mlogit} regression for the
estimation of the reweighting factors; the variable used in {cmd:over()} is
used as the dependent variable;
this can be used to obtain estimates akin to multivalued treatment effects under
the assumption of exogeneity; only average treatment effects ({cmd:ate}) are allowed{p_end}
{synopt :{opt rwmprobit(varlist)}}specify the {cmd:mprobit} regression for the
estimation of the reweighting factors; the variable used in {cmd:over()} is
used as the dependent variable;
this can be used to obtain estimates akin to multivalued treatment effects under
the assumption of exogeneity; only average treatment effects ({cmd:ate}) are
allowed{p_end}
{synopt :[{cmd:ate}|{cmd:att}|{cmd:atu}]}indicate which estimator will be
obtained using the reweighted factors; the default is to estimate the average
treatment effect ({cmd:ate});
one can also specify to obtain treatment effect on the treated ({cmd:att}) or
on the untreated ({cmd:atu}){p_end}
{synopt :{it:sureg_options}}most options in {helpb sureg} can be used but have not been extensively tested{p_end}
{synoptline}
{p 4 6 2}
{cmd:fweight}s and {cmd:aweight}s are allowed.  When using
{opt rwlogit(varlist)}, {opt rwprobit(varlist)}, {opt rwmlogit(varlist)}, or
{opt rwmprobit(varlist)}, weights are used as {cmd:aweight}s; see 
{help weight}.{p_end}
{p 4 6 2}
* {cmd:qs()} is required.  The option {opt qs(numlist)} allows one to specify
all the quantiles of interest for the dependent variable.  The RIF quantile
statistic is first obtained using the {cmd:egen} function
{helpb rifvar:rifvar()}, which is then used as the dependent variable in an
ordinary least-squares model that is fit using {cmd:sureg}.{p_end}


{title:Description}

{pstd}
{cmd:rifsureg} is a wrapper command that uses the capabilities of {helpb sureg} to estimate simultaneous RIF regressions for a set of quantiles.
 
{pstd}
The command fits the RIF-regression models in two steps.  First, it estimates
the RIF for all the quantile statistics of interest using 
{helpb rifvar:rifvar()}.  Second, it uses the estimated RIF as the dependent
variable and fits the simultaneous RIF models using {helpb sureg}.  Using a
similar syntax to {helpb rifhdreg}, {cmd:rifsureg} can be used to estimate
simultaneous regressions for treatment effects by using the option
{cmd:over()} in combination with {cmd:rwlogit()} or {cmd:rwprobit()} after
selecting the estimation of the type of treatment effects to be estimated
(Firpo and Pinto 2016).  This can be thought of as the equivalent to
{cmd:teffects, ipwra}.  This makes the estimator a double robust estimator for
treatment effects on distributional statistics under the assumption of
exogeneity of the treatment.

{pstd}
Because the command is a wrapper for {cmd:sureg}, most options from
this command are available but have not been fully tested.

{pstd}
For the correct estimation of bootstrap standard errors, it is recommended to
use the {cmd:bootstrap} prefix to apply the bootstrap through the whole
estimation process.

{pstd}
{cmd:rifsureg} typed without arguments replays the last results.


{title:Examples}

{phang2}
{bf:. {stata "webuse cattaneo2"}}

{pstd}
Simultaneous RIF regressions across quantiles.{p_end}
{phang2}
{bf:. {stata  rifsureg bweight mbsmoke prenatal1 mmarried mage fbaby, qs(5(10)95)}}

{pstd}
Simultaneous RIF regressions across quantiles.  Treatment effects of
smoking.{p_end}
{phang2}
{bf:. {stata  rifsureg bweight mbsmoke prenatal1 mmarried mage fbaby, qs(5(10)95) over(mbsmoke)}}

{pstd}
Simultaneous RIF regressions across quantiles.  Treatment effects of smoking.
Using inverse-probability weighting with {cmd:ate}.{p_end}
{phang2}
{bf:. {stata rifsureg bweight mbsmoke prenatal1 mmarried mage fbaby, qs(5(10)95) over(mbsmoke) rwlogit(prenatal1 mmarried mage fbaby) ate}}

{pstd}
Simultaneous RIF regressions across quantiles.  Treatment effects of smoking.
Using inverse-probability weighting with {cmd:ate}.  Bootstrapped standard
errors.{p_end}
{phang2}
{bf:. {stata  "bootstrap: rifsureg bweight mbsmoke prenatal1 mmarried mage fbaby, qs(5(10)95) over(mbsmoke) rwlogit(prenatal1 mmarried mage fbaby) ate"}}


{marker Acknowledgments}{...}
{title:Acknowledgments}

{pstd}
This command is based on the community-contributed command {cmd:rifreg}.

{pstd}
RIF variables are estimated using the {cmd:egen} addon {cmd:rifvar()}.

{pstd}
An intuitive description of RIF regressions is provided in Rios-Avila (2019).

{pstd}
All errors are my own.


{title:References}

{phang}
Firpo, S. P., and C. Pinto. 2016. Identification and estimation of
distributional impacts of interventions using changes in inequality measures.
{it:Journal of Applied Econometrics} 31: 457-486. {browse "https://doi.org/10.1002/jae.2448"}.

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
Help:  {helpb rifreg}, {helpb rifhdreg}, {helpb rifsureg}, {helpb rifsureg2}, 
{helpb uqreg}, {helpb hvar:hvar()}, {helpb reghdfe}, {helpb oaxaca_rif},
{helpb rifvar:rifvar()}, {manhelp sureg R}{p_end}
