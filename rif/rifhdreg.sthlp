{smcl}
{* *! version 2.4 Fernando Rios-Avila May 2021}{...}
{cmd:help rifhdreg}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{cmd:rifhdreg} {hline 2}}Recentered influence function regression with high-dimensional fixed effects{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:rifhdreg} {depvar} [{indepvars}] {ifin} {weight}, {opt rif(RIF_options)} 
[{opt retain(newvar)} {cmd:replace} {opt abs(varlist)} {opt iseed(str)}
{opt over(varname)}
{opt rwlogit(varlist)} {opt rwprobit(varlist)} {opt rwmlogit(varlist)}
{opt rwmprobit(varlist)} [{cmd:ate}|{cmd:att}|{cmd:atu}] 
{opt scale(real)}
{cmd:svy}
{it:regress_options} {it:reghdfe_options}]

{p 8 16 2}
{cmd:bsrifhdreg} {depvar} [{indepvars}] {ifin}  , {opt rif(RIF_options)} 
[{opt retain(newvar)} {cmd:replace} {opt abs(varlist)} {opt iseed(str)}
{opt over(varname)}
{opt rwlogit(varlist)} {opt rwprobit(varlist)} {opt rwmlogit(varlist)}
{opt rwmprobit(varlist)} [{cmd:ate}|{cmd:att}|{cmd:atu}] 
{opt scale(real)}
{it:bootstrap_options}
{it:regress_options} {it:reghdfe_options}]

{synoptset 25 tabbed}{...}
{marker opt}{synopthdr:options}
{synoptline}
{p2coldent :* {opt rif(RIF_options)}}specify the recentered influence function (RIF) statistic used as outcome; see
{helpb rifvar:rifvar()} for details on the distributional statistics currently allowed{p_end}
{synopt :{opt retain(newvar)}}specify a new variable where the generated RIF will be stored based on the sample used in the regression{p_end}
{synopt :{opt replace}}when {cmd:retain()} is specified, 
overwrite the variable {opt retain(newvar)} if it already exists{p_end}
{synopt :{opt abs(varlist)}}identify the fixed effects to be absorbed; each variable listed here represents one set of fixed effects{p_end}
{synopt :{opt iseed(str)}}indicate a particular seed for
replication of rank-dependent indices{p_end}
{synopt :{opt over(varname)}}indicate a variable over which the RIF will be estimated; this can be understood as a partial conditional RIF; when the variable
used is binomial, the regression can be seen as the ordinary least-squares
(OLS) alternative to Oaxaca-Blinder decomposition{p_end}
{synopt :{opt rwlogit(varlist)}}specify the {cmd:logit} regression for the
estimation of the reweighting factors; the variable used in {cmd:over()} is
used as the dependent variable;
this can be used to obtain estimates akin to treatment effects under the assumption of exogeneity{p_end}
{synopt :{opt rwprobit(varlist)}}specify the {cmd:probit} regression for the
estimation of the reweighting factors; the variable used in {cmd:over()} is
used as the dependent variable;
this can be used to obtain estimates akin to treatment effects under the assumption of exogeneity{p_end}
{synopt :{opt trim(numlist)}}specifies the min and max values to trim the propensity score, when {cmd:rwlogit/rwprobit}
are used. This is done to reduce the sensitivy of the IPW strategy when the predicted score is close to 0 or 1.{p_end}
{synopt :{opt rwmlogit(varlist)}}specify the {cmd:mlogit} regression for the
estimation of the reweighting factors; the variable used in {cmd:over()} is
used as the dependent variable;
this can be used to obtain estimates akin to multivalued treatment effects under
the assumption of exogeneity; only average treatment effects ({cmd:ate}) are allowed{p_end}
{synopt :{opt rwmprobit(varlist)}}specify the {cmd:mprobit} regression for the
estimation of the reweighting factors; the variable used in {cmd:over()} is
used as the dependent variable;
this can be used to obtain estimates akin to multivalued treatment effects under
the assumption of exogeneity; only average treatment effects ({cmd:ate}) are allowed{p_end}
{synopt :[{cmd:ate}|{cmd:att}|{cmd:atu}]}indicate which estimator will be
obtained using the reweighted factors; the default is to estimate the average
treatment effect ({cmd:ate});
one can also specify to obtain treatment effect on the treated ({cmd:att}) or on the untreated ({cmd:atu}){p_end}
{synopt :{opt scale(real)}}provide a value for rescaling the dependent
variable{p_end}
{synopt :{opt svy}}obtain estimates using survey design; does not
work when fixed effects are included (option {cmd:abs()}){p_end}
{synopt :{it:regress_options}}when {cmd:abs()} is not used, all options in
{helpb regress} can be used{p_end}
{synopt :{it:reghdfe_options}}when {cmd:abs()} is used, all options in 
{helpb reghdfe} can be used; requires {cmd:reghdfe} be installed{p_end}
{synopt :{it: bootstrap_options}} The command {cmd:bsrifhdreg} is a wrapper around rifhdreg that allows to more easily implement bootstrap standard errors. Specifically, it's use is recommended for plotting unconditional quantile regressions with {help qregplot}. {p_end}
{synopt: } If using this command, one can use the following options: reps(int 50), strata(), seed(), bca, TIEs, cluster(varname), idcluster(newvarname), nodots, level() and force. see {help bootstrap} for details. 
 {p_end}
{synopt :{cmd:old}} This option request using the older {cmd:rifvar} function (for replication purposes). {p_end}
{synoptline}
{p 4 6 2}
{cmd:aweight}s, {cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed;
see {help weight}.{p_end}
{p 4 6 2}
* {cmd:rif()} is required.


{title:RIF options}

{pstd}
The option {opt rif(RIF_options)} allows one to specify a large set of RIF
statistics that can be used to define the dependent variable for modeling.
The RIF statistic is first obtained using the {cmd:egen} function 
{helpb rifvar:rifvar()}, which is then used as the dependent variable in an
OLS model that is fit using {cmd:regress} or {cmd:reghdfe} when fixed effects
are specified.  For more details on the available options, see
{helpb rifvar:rifvar()} and Rios-Avila (2019).

{synoptset 40}{...}
{synopthdr :RIF_options}
{synoptline}
{synopt :{opt mean}}sample mean{p_end}
{synopt :{opt var}}variance{p_end}
{synopt :{opt q(#p)} [{opt kernel(kernel)} {opt bw(#)}]}pth quantile, where
0<{it:#p}<100;
default is to use a {cmd:gaussian} kernel; 
all kernel functions available for the
command {cmd:kdensity} are also allowed; default is 
the Silverman's plugin optimal bandwidth;
full kernel name should be used instead of abbreviations (for example, use
{cmd:biweight} instead of {cmd:bi}); the only exception is that when requesting the
Epanechnikov kernel, one should use {cmd:epan}{p_end}
{synopt :{opt iqr(#p1 #p2)} [{opt kernel(kernel)} {opt bw(#)}]}interquantile
range: {opt q(#p2)} - {opt q(#p1)}, where 0<{it:p1}<={it:p2}<100; {cmd:bw()}
and {cmd:kernel()} are the same as for the quantile case{p_end}
{synopt :{opt gini}}Gini inequality index{p_end}
{synopt :{opt cvar}}coefficient of variation{p_end}
{synopt :{opt std}}standard deviation{p_end}
{synopt :{opt iqratio(#p1 #p2)} [{opt kernel(kernel)} {opt bw(#)}]}interquantile ratio:
{opt q(#p2)}/{opt q(#p1)}, where 0<{it:p1}<={it:p2}<100;
{cmd:bw()} and {cmd:kernel()} are the same as for the quantile case{p_end}
{synopt :{opt entropy(#a)}}entropy inequality index with sensitivity index
{it:#a}{p_end}
{synopt :{opt atkin(#e)}}Atkinson inequality index with inequality aversion
{it:#e}>0{p_end}
{synopt :{opt logvar}}logarithmic variance (different from variance of logarithms){p_end}
{synopt :{opt glor(#p)}}generalized Lorenz ordinate at {it:#p}, where 0<{it:#p}<100{p_end}
{synopt :{opt lor(#p)}}Lorenz ordinate at {it:#p}, where 0<{it:#p}<100{p_end}
{synopt :{opt ucs(#p)}}share of income held by richest 1-p%; 1-{opt lor(#p)}{p_end}
{synopt :{opt iqsr(#p1 #p2)}}interquantile share ratio: 
(1-{opt lor(#p2)})/{opt lor(#p1)},
where 0<p1<=p2<100{p_end}
{synopt :{opt mcs(#p1 #p2)}}share of income held by people between {it:#p1} and
{it:#p2}: {opt lor(#p2)}-{opt lor(#p1)}, where 0<{it:#p1}<{it:#p2}<100; also known as P_shares{p_end}
{synopt :{opt pov(#a)} {opt pline(#|var)}}Foster-Greer-Thorbecke poverty
measure with sensitivity parameter {it:#a}>=0 and poverty line defined by
{cmd:pline()}; {cmd:pline()} can be a single number or a variable{p_end}
{synopt :{opt watts(#povline)}}Watts poverty index; requires a number or variable to define the poverty line{p_end}
{synopt :{opt sen(#povline)}}Sen poverty index; requires a number to define the poverty line{p_end}
{synopt :{opt tip(#p)} {opt pline(#)}}three I's of poverty (TIP) curve ordinate at
{it:#p} for poverty line defined by {opt pline(#)}, where 0<{it:#p}<100{p_end}
{synopt :{opt agini}}absolute Gini{p_end}
{synopt :{opt acindex(varname)}}absolute concentration index using {it:varname} as the rank variable{p_end}
{synopt :{opt cindex(varname)}}concentration index using {it:varname} as the rank variable{p_end}
{synopt :{opt eindex(varname)} {opt lb(#)} {opt ub(#)}}Erreygers's index using
{it:varname} as
the rank variable, with lower bound {cmd:lb()} and upper bound {cmd:ub()}
and where
{cmd:lb()}<{cmd:ub()}{p_end}
{synopt :{opt arcindex(varname)} {opt lb(#)}}attainment relative concentration index
using {it:varname} as the rank variable, with lower bound {cmd:lb()}{p_end}
{synopt :{opt srindex(varname)} {opt ub(#)}}shortfall relative concentration index
using {it:varname} as the rank variable, with upper bound {cmd:ub()}{p_end}
{synopt :{opt windex(varname)} {opt lb(#)} {opt ub(#)}}Wagstaff concentration index using
{it:varname} as the rank variable, with lower bound {cmd:lb()} and upper
bound {cmd:ub()}
and where {cmd:lb()}<{cmd:ub()}{p_end}
{synopt :{opt rifown(str)} {opt rifopt(str)}}these options are added to enable
{cmd:rifvar()} to use other community-contributed programs to estimate RIF for
statistics not available in this list{p_end}
{synoptline}


{title:Description}

{pstd}
rifhdreg is a wrapper command that uses the capabilities of {helpb regress}
and {helpb reghdfe} to estimate recentered influence function (RIF)
regressions.  When requested, it fits models with multiple fixed effects
similarly to the community-contributed command {cmd:xtrifreg} but based on
{helpb reghdfe}, which permits one to include a larger set of fixed effects.

{pstd}
The best-known use of RIF regressions is the estimation of unconditional
quantile regressions (Firpo, Fortin, and Lemieux 2009), but they have also
been proposed for the analysis of other distributional statistics, including
the Gini and the variance (Firpo, Fortin, and Lemieux 2018), entropy index,
Atkinson index (Cowell and Flachaire 2007), poverty indices, Lorenz and
general Lorenz ordinates (Essama-Nssah and Lambert 2012), and bivariate
inequality indices (Heckley, Gerdtham, and Kjellson 2016).

{pstd}
The command fits the RIF-regression model in two steps.  First, it
estimates the RIF for the distributional statistic of interest using
{helpb rifvar:rifvar()}.  Second, it uses the estimated RIF as dependent
variable and fits the RIF model using {helpb regress} if no fixed effects are
declared or {helpb reghdfe} if the fixed effects are declared via
{opt abs(varlist)}.  For an intuitive description of RIFs and this command, see
Rios-Avila (2019).

{pstd}
Because {cmd:rifhdreg} is a wrapper for both {cmd:regress} and {cmd:reghdfe},
all the options for both commands are allowed.  Thus, by default, OLS standard
errors are reported, but both robust and clustered standard errors can be
requested following {cmd:regress} or {cmd:reghdfe} syntax.  Note, however,
that Firpo, Fortin, and Lemieux (2009, 2018) suggest to estimate standard
errors using bootstrap methods because of the intermediate steps used for the
estimation of the RIF functions.

{pstd}
For the correct estimation of bootstrap standard errors, one should 
use the {cmd:bootstrap} prefix rather than {cmd:vce(bootstrap)} to apply the
bootstrap through the whole estimation process.  See 
{it:{help rifhdreg##examples:Examples}} for further
details.

{pstd}
On the other hand, Cowell and Flachaire (2007) and Deville (1999) indicate
that RIFs can be used to easily estimate asymptotic standard errors of complex
distributional functions, in which case reporting robust standard errors
should suffice.  In Rios-Avila (2019), Monte Carlo simulations are run,
showing that robust standard errors seem to be appropriate for statistical
inference for most statistics used here except for the Atkinson inequality
index with an inequality aversion index greater than 2 and for statistics that
are constructed based on unconditional quantiles.

{pstd}
The options {cmd:acindex()}, {cmd:cindex()}, and {cmd:eindex()} estimate the
concentration index based on an additional ranking variable.  If the sorting
variable has ties, the results may not be reproducible because they will
depend on the order of the main variable of interest.

{pstd}
The option {cmd:iseed()} can be used for the replication of results when using
rank-dependent indices.  Otherwise, RIFs for these indices may vary because of
the presence of ties in the distribution of the dependent variable.

{pstd}
The option {cmd:over()} can be used to estimate RIFs over a single categorical
variable.  This can be thought of as a shortcut to estimate the difference in
distribution across a finite number of groups while controlling for other
characteristics.  Using this option can also be thought of as the equivalent
to doing a regression adjustment treatment-effect analysis.

{pstd}
The options {cmd:rwlogit()} and {cmd:rwprobit()} can be used in combination
with {cmd:over()} for the estimation of treatment effects using inverse
probability weighting.  This procedure is based on the parametric strategy
described in Firpo and Pinto (2016).  This can be thought of as the equivalent
to {cmd:teffects, ipwra}.  This makes the estimator a double robust estimator
for treatment effects on distributional statistics under the assumption of
exogeneity of the treatment.

{pstd}
If {cmd:rwlogit()} or {cmd:rwprobit()} is specified, one can also include the
treatment effect to be estimated, which can be average treatment effect
({cmd:ate}), average treatment effect on the treated ({cmd:att}), or average
treatment effect on the untreated ({cmd:atu}).  When using these options, it
is recommended to use the {cmd:bootstrap} prefix to obtain correct standard
errors.

{pstd}
It is also possible to use {cmd:rwmlogit()} or {cmd:rwmprobit()} to request
the estimation of multivalued treatment effects akin to Cattaneo (2010) and
Cattaneo, Drukker, and Holland (2013).  When one of these options is used,
only average treatment effects ({cmd:ate}) can be estimated.  When using these
options, it is recommended to use the {cmd:bootstrap} prefix to obtain correct
standard errors.  Different from Cattaneo, Drukker, and Holland (2013), the
treatment effects are estimated individually rather than jointly; see
{cmd:rifsureg} and {cmd:rifsureg2} for joint estimations.

{pstd}
The option {cmd:svy} allows one to use survey design information for the
estimation of the RIF regressions.  However, this does not correct for the
uncertainty implicit in the estimation of distributional statistics that are
functions of quantiles (or more specifically, density functions).

{pstd}
It is also possible to use the Prefix {cmd:svy} for the estimation of Bootstrap Standard
errors using survey design. This requires having access to Bootstrap weights.

{pstd}
{cmd:rifhdreg} typed without arguments replays the last results.

{pstd}
{cmd:bsrifhdreg} is a wrapper around rifhdreg. See examples for a syntaxis comparison. You should use this if you want to plot coefficient with bootstrapped standard errors using the command {help qregplot}.

{marker examples}{...}
{title:Examples}

{phang2}
{bf:. {stata "use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta"}}

{pstd}
Verify that {cmd:reghdfe} is installed and compiled in your computer.  If
already installed, this step can be skipped.{p_end}
{phang2}
{bf:. {stata ssc install reghdfe, replace}}{p_end}
{phang2}
{bf:. {stata reghdfe, compile}}{p_end}
{phang2}
{bf:. {stata generate wage=exp(lnwage)}}{p_end}

{pstd}
RIF regression for the mean.{p_end}
{phang2} 
{bf:. {stata rifhdreg lnwage educ exper tenure, rif(mean)}}

{pstd}
RIF regression for the 10th quantile, using robust standard errors.{p_end}
{phang2} 
{bf:. {stata rifhdreg lnwage educ exper tenure, rif(q(10)) robust}}

{pstd}
RIF regression for the 90-10 interquantile difference, using clustered
standard errors at {bf:age}.{p_end}
{phang2}
{bf:. {stata rifhdreg lnwage educ exper tenure, rif(iqr(90 10)) cluster(age)}}

{pstd}
RIF regression for the Gini coefficient, using robust standard errors.{p_end}
{phang2}
{bf:. {stata rifhdreg wage educ exper tenure, rif(gini) robust}}

{pstd}
RIF regression for the 90-50 interquantile difference, using clustered
standard errors at {bf:age}.  Retaining RIF statistic.{p_end}
{phang2}
{bf:. {stata rifhdreg lnwage educ exper tenure, rif(iqr(90 50)) retain(rif_q9050) cluster(age)}}{p_end}
{phang2}
{bf:. {stata summarize rif_q9050}}{p_end}

{pstd}
RIF regression for the 50 quantile difference, using clustered standard errors
at {bf:age}.  Retaining RIF statistic.{p_end}
{phang2}
{bf:. {stata rifhdreg lnwage educ exper tenure, rif(q(50)) retain(rif_q50) cluster(age)}}{p_end}
{phang2}
{bf:. {stata summarize rif_q50}}{p_end}

{pstd}
RIF regression for the Gini coefficient, using robust standard errors and one
fixed effect ({cmd:age}).  Note that because we are using {cmd:abs(age)},
{cmd:reghdfe}
does not allow us to use {cmd:robust}.  Instead, we need to use {cmd:vce(robust)}.{p_end}
{phang2}
{bf:. {stata rifhdreg wage educ exper tenure, rif(gini) vce(robust) abs(age)}}

{pstd}
RIF regression for the Atkinson inequality index with coefficient = 1, using
robust standard errors and two fixed effects ({cmd:age} and {cmd:isco}).{p_end}
{phang2}
{bf:. {stata rifhdreg wage educ exper tenure, rif(atkin(1)) vce(robust) abs(age isco)}}

{pstd}
Estimation with bootstrap standard errors, and with the wrapper {p_end}
{phang2}
{bf:. {stata "bootstrap: rifhdreg lnwage educ exper tenure, rif(q(10))"}}{p_end}
{phang2}
{bf:. {stata "bsrifhdreg lnwage educ exper tenure, rif(q(10))"}}

{pstd}
Estimation with bootstrap standard errors with clusters.{p_end}
{phang2}
{bf:. {stata "bootstrap, cluster(age): rifhdreg lnwage educ exper tenure, rif(q(10)) "}}{p_end}
{phang2}
{bf:. {stata "bsrifhdreg lnwage educ exper tenure, rif(q(10)) cluster(age)"}}

{pstd}
Estimation with bootstrap standard errors with clusters and fixed effects, but
fixed effects differ from cluster.{p_end}
{phang2}
{bf:. {stata "bootstrap, cluster(age): rifhdreg lnwage educ exper tenure, rif(q(10)) abs(isco)"}}{p_end}
{phang2}
{bf:. {stata "bsrifhdreg lnwage educ exper tenure, rif(q(10)) abs(isco) cluster(age)"}}

{pstd}
Estimation with bootstrap standard errors with clusters and fixed effects, with
fixed effects the same as cluster.{p_end}
{phang2}
{bf:. {stata "bootstrap, cluster(age) idcluster(idage): rifhdreg lnwage educ exper tenure, rif(q(10)) abs(idage)"}}{p_end}
{phang2}
{bf:. {stata "bsrifhdreg lnwage educ exper tenure, rif(q(10)) abs(idage) cluster(age) idcluster(idage)"}}

{pstd}
Replication of results using {cmd:rifreg} (requires installing the command
from the author's website).{p_end}
{phang2}
{bf:. {stata rifreg lnwage educ exper tenure, q(10)}}{p_end}
{phang2}
{bf:. {stata kdensity lnwage, nograph}}{p_end}
{phang2}
{bf:. {stata local bw=r(bwidth)}}{p_end}
{phang2}
{bf:. {stata rifhdreg lnwage educ exper tenure, rif(q(10) bw(`bw')) robust}}{p_end}

{pstd}
Using community-contributed RIF function.  Be sure to have the program
{cmd:_ghvar} in the right folder.  This estimates the half-variance.  See the
structure of {cmd:_ghvar.ado} as the template.{p_end}
{phang2}
{bf:. {stata rifhdreg lnwage educ exper tenure female age, rif(rifown(hvar) rifopt(hvn))}}{p_end}
{phang2}
{bf:. {stata rifhdreg lnwage educ exper tenure female age, rif(rifown(hvar) rifopt(hvp))}}{p_end}

{pstd}
Estimation of treatment effects under exogeneity.{p_end}
{phang2}
{bf:. {stata webuse cattaneo2, clear}}

{pstd}
Treatment effect of smoking on the median.{p_end}
{phang2}
{bf:. {stata rifhdreg bweight mbsmoke prenatal1 mmarried mage fbaby, rif(q(50)) over(mbsmoke)}}

{pstd}
This would be different if {cmd:over()} is not included.{p_end}
{phang2}
{bf:. {stata rifhdreg bweight mbsmoke prenatal1 mmarried mage fbaby, rif(q(50))}}

{pstd}
Estimation of average treatment effect on the median using inverse-probability
weighting.{p_end}
{phang2}
{bf:. {stata rifhdreg bweight mbsmoke, rif(q(50)) over(mbsmoke) rwlogit(prenatal1 mmarried mage fbaby) ate}}{p_end}

{pstd}
Comparing results with the {cmd:teffects} command.{p_end}
{phang2}
{bf:. {stata teffects ipwra (bweight) (mbsmoke prenatal1 mmarried mage fbaby, logit), ate}}{p_end}
{phang2}
{bf:. {stata rifhdreg bweight mbsmoke, rif(mean) over(mbsmoke) rwlogit(prenatal1 mmarried mage fbaby) ate}}{p_end}

{pstd}
Adjusted for covariates as well.{p_end}
{phang2}
{bf:. {stata teffects ipwra (bweight prenatal1 mmarried mage fbaby) (mbsmoke prenatal1 mmarried mage fbaby, logit), ate}}{p_end}
{phang2}
{bf:. {stata rifhdreg bweight mbsmoke prenatal1 mmarried mage fbaby, rif(mean) over(mbsmoke) rwlogit(prenatal1 mmarried mage fbaby) ate}}{p_end}

{pstd}
Treatment effects with inverse-probability weighting and adjusting for
covariates.{p_end}
{phang2}
{bf:. {stata rifhdreg bweight mbsmoke prenatal1 mmarried mage fbaby, rif(q(10)) over(mbsmoke) rwlogit(prenatal1 mmarried mage fbaby) ate}}{p_end}
{phang2}
{bf:. {stata rifhdreg bweight mbsmoke prenatal1 mmarried mage fbaby, rif(q(25)) over(mbsmoke) rwlogit(prenatal1 mmarried mage fbaby) ate}}{p_end}
{phang2}
{bf:. {stata rifhdreg bweight mbsmoke prenatal1 mmarried mage fbaby, rif(q(50)) over(mbsmoke) rwlogit(prenatal1 mmarried mage fbaby) ate}}{p_end}
{phang2}
{bf:. {stata rifhdreg bweight mbsmoke prenatal1 mmarried mage fbaby, rif(q(75)) over(mbsmoke) rwlogit(prenatal1 mmarried mage fbaby) ate}}{p_end}
{phang2}
{bf:. {stata rifhdreg bweight mbsmoke prenatal1 mmarried mage fbaby, rif(q(90)) over(mbsmoke) rwlogit(prenatal1 mmarried mage fbaby) ate}}{p_end}

{pstd}
Estimation of multivalued treatment effects under exogeneity.{p_end}
{phang2}
{bf:. {stata "use http://www.stata-press.com/data/r13/bdsianesi5, clear"}}

{pstd}
Using {cmd:teffects ipw}.{p_end}
{phang2}
{bf:. {stata teffects ipw  (wage) (ed math7 read7 maed paed)}}

{pstd}
Using {cmd:rifhdreg}.{p_end}
{phang2}
{bf:. {stata rifhdreg wage i.ed, rif(mean) over(ed) rwmlogit(math7 read7 maed paed)}}

{pstd}
Comparing results with {helpb poparms}.{p_end}
{phang2}
{bf:. {stata ssc install poparms}}{p_end}
{phang2}
{bf:. {stata generate c=1}}{p_end}
{phang2}
{bf:. {stata poparms (ed math7 read7 maed paed) (wage c), q(.25 .5 .75) vce(bootstrap, reps(50))}}{p_end}

{pstd}
Using {cmd:rifhdreg}.{p_end}
{phang2}
{bf:. {stata rifhdreg wage ibn.ed, rwmlogit(math7 read7 maed paed) over(ed) rif(q(25)) nocons}}{p_end}
{phang2}
{bf:. {stata rifhdreg wage ibn.ed, rwmlogit(math7 read7 maed paed) over(ed) rif(q(50)) nocons}}{p_end}
{phang2}
{bf:. {stata rifhdreg wage ibn.ed, rwmlogit(math7 read7 maed paed) over(ed) rif(q(75)) nocons}}{p_end}

{pstd}
Simultaneous RIF regressions.  The command {cmd:suest} does not work with
{cmd:rifhdreg}.  For simultaneous unconditional quantile regressions, one
can use {helpb rifsureg}.  However, simultaneous RIF regressions with
{cmd:suest} are possible using a multiple-step approach.

{pstd}
Step 1: Estimation of the models of interest, saving the RIF functions.{p_end}
{phang2}
{bf:. {stata "use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta, clear"}}{p_end}
{phang2}
{bf:. {stata gen wage=exp(lnwage)}}{p_end}
{phang2}
{bf:. {stata rifhdreg lnwage educ exper tenure, rif(q(10)) retain(rifq10)}}{p_end}
{phang2}
{bf:. {stata rifhdreg lnwage educ exper tenure, rif(q(50)) retain(rifq50)}}{p_end}
{phang2}
{bf:. {stata rifhdreg lnwage educ exper tenure, rif(q(90)) retain(rifq90)}}{p_end}
{phang2}
{bf:. {stata rifhdreg lnwage educ exper tenure, rif(iqr(90 10)) retain(rifiqr9010)}}{p_end}
{phang2}
{bf:. {stata rifhdreg wage educ exper tenure, rif(gini) retain(rifgini)}}{p_end}

{pstd}
Step 2: Estimation of RIF regressions using standard OLS using the retained
variables.{p_end}
{phang2}
{bf:. {stata regress rifq10 educ exper tenure}}{p_end}
{phang2}
{bf:. {stata estimates store m1}}{p_end}
{phang2}
{bf:. {stata regress rifq50 educ exper tenure}}{p_end}
{phang2}
{bf:. {stata estimates store m2}}{p_end}
{phang2}
{bf:. {stata regress rifq90 educ exper tenure}}{p_end}
{phang2}
{bf:. {stata estimates store m3}}{p_end}
{phang2}
{bf:. {stata regress rifiqr9010 educ exper tenure}}{p_end}
{phang2}
{bf:. {stata estimates store m4}}{p_end}
{phang2}
{bf:. {stata regress rifgini educ exper tenure}}{p_end}
{phang2}
{bf:. {stata estimates store m5}}

{pstd}
Step 3: Simultaneous estimation with {cmd:suest}.{p_end}
{phang2}
{bf:. {stata suest m1 m2 m3 m4 m5}}


{marker Acknowledgments}{...}
{title:Acknowledgments}

{pstd}
This command is based on the community-contributed commands {cmd:rifreg} and
{cmd:reghdfe}.

{pstd}
This command requires the community-contributed command {cmd:reghdfe} by
Sergio
Correira to fit the models with multiple fixed effects.

{pstd}
RIF variables are estimated using the {cmd:egen} add-on {cmd:rifvar()}.
An intuitive description of RIF regressions is provided in Rios-Avila (2019).

{pstd}
All errors are my own.


{title:References}

{phang}
Cattaneo, M. D. 2010. Efficient semiparametric estimation of multi-valued
treatment effects under ignorability. {it:Journal of Econometrics} 155:
138-154. {browse "https://doi.org/10.1016/j.jeconom.2009.09.023"}.

{phang}
Cattaneo, M. D., D. M. Drukker, and A. D. Holland. 2013. 
{browse "https://doi.org/10.1177/1536867X1301300301":Estimation of multivalued treatment effects under conditional independence}.
{it:Stata Journal} 13: 407-450.

{phang}
Cowell, F. A., and E. Flachaire. 2007. Income distribution and inequality
measurement: The problem of extreme values. {it:Journal of Econometrics} 141:
1044-1072. {browse "https://doi.org/10.1016/j.jeconom.2007.01.001"}.

{phang}
Deville, J.-C. 1999. Variance estimation for complex statistics and
estimators: Linearization and residual techniques. {it:Survey Methodology} 25:
193-203.

{phang}
Essama-Nssah, B., and P. J. Lambert. 2012. Influence functions for policy impact analysis. In {it:Inequality, Mobility and Segregation: Essays in Honor of Jacques Silber}, ed. J. A. Bishop and R. Salas, 135-159.
Bingley, UK: Emerald.

{phang}
Firpo, S. P., N. M. Fortin, and T. Lemieux. 2009. Unconditional quantile
regressions. {it:Econometrica} 77: 953-973.
{browse "https://doi.org/10.3982/ECTA6822"}.

{phang}
------. 2018. Decomposing wage distributions using recentered influence
function regressions. {it:Econometrics} 6: 28. 
{browse "https://doi.org/10.3390/econometrics6020028"}.

{phang}
Firpo, S. P., and C. Pinto. 2016. Identification and estimation of distributional impacts of interventions using changes in inequality measures. {it:Journal of Applied Econometrics} 31: 457-486.
{browse "https://doi.org/10.1002/jae.2448"}.

{phang}
Heckley, G., U.-G. Gerdtham, and G. Kjellsson. 2016. A general method for decomposing the causes of socioeconomic inequality in health. {it:Journal of Health Economics} 48: 89-106.
{browse "https://doi.org/10.1016/j.jhealeco.2016.03.006"}.

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
Help:  {helpb rifvar:rifvar()}, {helpb rifhdreg}, {helpb rifreg},
{helpb rifsureg}, {helpb uqreg}, {helpb hvar()}, {helpb oaxaca_rif}
(if installed), {manhelp regress R}{p_end}
