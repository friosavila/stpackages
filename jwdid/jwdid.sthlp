{smcl}
{* *! version 2.0 May_4_2024}{...}
{title:Title}

{phang}
{bf:jwdid} {hline 2} ETWFE-DID estimator  


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:jwdid}
[{varlist}]
{ifin}
{weight}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}

{synopthdr}
{synoptline}
{syntab :Basic Specification options}
{synopt:{opt i:var(varname)}}Declares the Panel ID variable. If not declared, the data is assumed to be Repeated crossection. {p_end}
{synopt:{opt t:var(varname)}}Declares the time variable{p_end}
{synopt:{opt time(varname)}}Same as tvar() {p_end}
{synopt:{opt g:var(varname)}}Provides the cohort variable{p_end}

{syntab :Treatment-control Specification options}
{synopt:{opt trtvar(varname)}}If Gvar is not available, you can provide the post-treatment variable. By default, the panel data identifier is used to create the equivalent to Gvar{p_end}
{synopt:{opt trgvar(varname)}}If data is repeated crossection (RC), {cmd:trtvar()} can be combined with {cmd: trtgvar()} to identify the cohort variable. {cmd:trtgvar} should identify  a pseudo panels in the data, where each pseudo panel are observations that were (or could have) been treated at the same point in time{p_end}

{syntab :Basic DID Specification options}
{synopt:{opt never}}By default, {cmd: jwdid} uses all never and not-yet treated observations as controls. The option {cmd: never} request to use only never-treated as the control group. With this option, for each group/cohort,  the period g-1 is excluded from the specification. {p_end}
{synopt:{opt group}}Request using Group fixed effects instead of Panel ID fixed effects. In linear models, with balanaced panel, estimates are numerically identical. However, it may reduce the computational burden with nonlinear models. This is the default whenver {cmd: method()} is called for except for {cmd: ppmlhdfe}.{p_end}
{synopt:{opt corr}}When using {cmd:group} with unbalanced panel data, estimates are no longer identical to those that use the panel identifier fixed effect. The option {cmd:corr} applies a correction for this, following a Mundlak approach{p_end}

{synopt:{opt cluster(varname)}} This option is used to request standard errors to be clustered at {cmd: cluster()} level. When using panel data, the default is using {cmd:ivar()} for clustering standard errors. When using RC data, Standard errors are estimated based on the Method default. For {cmd:reghdfe}, one should use {cmd:vce(robust)} to obtain robust standard errors.{p_end}  

{synopt:{opt method(method_name)}}Request other methods for the estimation of ATT's. For example {cmd:poisson} or {cmd:logit}. Default is linear regression model, which is estimated using {cmd: reghdfe}.{p_end}

{synopt:{opt other_options}}It is also possible to request other method/specific options. For example, for {cmd:reghdfe} robust standard errors can be requested using {cmd: vce(robust)}.{p_end}

{syntab :Advanced DID Specification options}
{synopt:{opt hettype(hetspec)}}This option allows to request different types of treatment effect heterogeneity. The default is to use full timecohort heterogeneity. Other options include {cmd:time}, {cmd:cohort}, {cmd: event} and {cmd:twfe}. The last one reduces to the traditional TWFE estimator {p_end}

{synopt:{opt xasis}}Unless this option is requested, all variables in {cmd:varlist} are demeaned and interacted with the corresponding level of treatment heterogeneity. Declaring {cmd: xasis} requests using covariates without transformation. 

{synopt:{opt exovar(varlist)}} Variables declared using this option are added to the model specification without interactions{p_end}

{synopt:{opt xtvar(varlist)}}Variables declared are only interacted with the time variable{p_end}

{synopt:{opt xgvar(varlist)}}Variables declared are only interacted with the group/cohort variable.{p_end}

{synopt:{opt fevar(varlist)}}This option is used to add additional fixed effects to the model, that different from cohort, panel or time. Only valid when using default method (reghdfe) or if using ppmlhdfe.{p_end}

{synopt:{opt anti:cipation(#1)}}This is used to declare period different from g-1 as the baseline. #1 can only take integer positve values, default is 1{p_end}


{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:pweight}s are allowed; see {help weight}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:jwdid} is a program that implements the Extended TWFE estimator proposed by Wooldridge(2021,2023) for a generalized DID design that addresses the problems related to the standard TWFE. The program also incorporates additional options that allow for a more flexible model specification. This includes the guidelines for the estimation of Gravity-trade models as proposed by Nagengast and Yotov (2024) and  Nagengast et al (2024).   

{pstd}In principle, this estimator suggests that to avoid some of the negative aspects of the traditional TWFE-DID estimator, one should simply use a fully interacted set of dummies allowing for treatment effect heterogeneity by cohort and timing. By using such interaction, one avoids using already treated units as controls causing the so-called negative weights problems.

{pstd}Specifically, instead of estimating a model as follows:

{pstd}y_it = gamma * D_it + a_i + b_t + e_t

{pstd}where D_it indicates if unit i is treated at time t. One should estimate a model like the following:

{pstd}y_it = sum(gamma_gt * G_i * T) + a_i + b_t + e_t

{pstd}where G_i * T corresponds to all possible interactions of the cohort unit i belongs to (G_i) and the period we aim to estimate that effect at (T), using as reference group all units that have not been treated yet. 

{pstd}In the simplest case, gamma_gt represents the ATT for cohort G at time t. When the option {cmd: never} is used, the specification also includes the Group period interactions including all those periods before treatment occured. In the case without covariates, the estimates are numerically identical to those identified using Callaway and Sant'Anna (2021)-regression outcome method, or using Sun and Abraham (2021) approach.

{pstd}Similar to {help xthdidregres} and {help hdidregress}, it is possible to estimate the DID model by declaring a treatment variable {cmd:trtvar()} instead of the group variable {cmd:gvar()}. Similarly, to reduce the complexity of the estimation, it is possible to impose some restrictions on the treatment effect heterogeneity using {cmd:hettype()}.

{pstd}In addition to impossing constrains to the treatment effect heterogeneity, it is also possible to add covariates that allows for covariate heterogeneity, as well as restricting the heterogneity only across time, across cohorts or no heterogeneity at all. Any variable that is included in the {cmd:varlist} is interacted with the corresponding level of treatment heterogeneity. The default option is to add sub-group demeaned variables to the model, but it is possible to request using the original variables using the option {cmd: xasis}. Both approaches produces the same aggregate average treatment effects, but the interpretation of the model coefficients is changes. 

{pstd}One can also request adding variable that are interacted with the time variable only {cmd: xtvar()}, cohort variable only {cmd: xgvar()}, or not interacted at all {cmd: exovar()}. Similarly, additional fixed effects can be added to the model using the option {cmd: fevar()}.

{pstd}One should also be aware that {cmd: jwdid} will create as many interactions as cohorts and periods are there in the data, times all possible controls, unless heterogeneity is restricted and covariate heterogeneity is restricted using the above options.

{ptsd}This could provide an extreamly large number of estimated coefficients, which could make some models difficult to estimate.

{pstd}Other estimation methods can be used by declaring the option {cmd: method()}. The default method is {cmd: reghdfe}, which is a linear regression model with fixed effects. Other methods include {cmd: poisson}, {cmd: logit}, or {cmd: ppmlhdfe}, which is the leading approaach for the estimation of gravity-trade models. 

{ptsd} Except when {cmd: ppmlhdfe} is used, whever {cmd: method()} is declared, the program will assume group/cohort fixed effects only, instead of individual fixed effects. This is to avoid the incidental parameter problem.

{marker remarks}{...}
{title:Remarks}

{pstd}
The code of this program is based on some of the advances by Prof. Wooldridge on the estimation of DID models. It has important advantages over other methods: 

{phang2}1. It is based on regression analysis, and most people understand regression, compared to the other alternatives.

{phang2}2. It is flexible for other methods. Namely, you should be easily be able to apply it for binary or count models, or even for the estimation of gravity-trade models, as we show in Nagengast et al (2024).

{pstd}This program was coded independently from Jeff Wooldridge, but is based on some of his early simulation codes he shared with the community. Some further advances were made following the official implentation of {help xthdidregress} and {help hdidregress}. Most advanced were developed for the joint work with Arne Nagengast and Yoto Yotov, for the estimation of DID type models in gravity trade settings.

{pstd}To estimate aggregates, see {help jwdid_postestimation}

{marker examples}{...}
{title:Examples}


{phang}{stata "ssc install frause"}{p_end}
{phang}{stata "frause mpdta.dta, clear"}{p_end}


Simple DID using not-treated as controls

{phang}{stata "jwdid lemp, ivar(countyreal) tvar(year) gvar(first_treat)"}{p_end}

Simple DID using never treated as controls

{phang}{stata "jwdid lemp, ivar(countyreal) tvar(year) gvar(first_treat) never"}{p_end}

Simple DID using not-treated as controls, based on group (rather than individual) fixed effects

{phang}{stata "jwdid lemp, ivar(countyreal) tvar(year) gvar(first_treat) group"}{p_end}

DID using not-treated as controls, based on group (rather than individual) fixed effects, and one time invariant control.

{phang}{stata "jwdid lemp lpop, ivar(countyreal) tvar(year) gvar(first_treat) group"}{p_end}

DID using not-treated as controls, based on group (rather than individual) fixed effects, and one time invariant control. Using poisson regression estimator.

{phang}{stata "gen emp = exp(lemp)"}{p_end}
{phang}{stata "jwdid emp lpop, ivar(countyreal) tvar(year) gvar(first_treat) method(poisson)"}{p_end}

DID using never treated as controls, using different treatment effects heterogeneity restrictions.

{phang}{stata "jwdid lemp, ivar(countyreal) tvar(year) gvar(first_treat) never (time)"}{p_end}

{phang}{stata "jwdid lemp, ivar(countyreal) tvar(year) gvar(first_treat) never hettype(cohort)"}{p_end}

{phang}{stata "jwdid lemp, ivar(countyreal) tvar(year) gvar(first_treat) never hettype(event)"}{p_end}

{phang}{stata "jwdid lemp, ivar(countyreal) tvar(year) gvar(first_treat) never hettype(twfe)"}{p_end}

{marker authors}{...}
{title:Authors}

{pstd}
Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org

{ptsd}
Arne J. Nagengast{break} 
Deutsche Bundesbank{break}
arne.nagengast@bundesbank.de

{ptsd}
Yoto V. Yotov{break}
School of Economics,Drexel University{break}
yotov@drexel.edu

{marker references}{...}
{title:References}

{phang2}Wooldridge, Jeffrey. 2021.
Two-Way Fixed Effects, the Two-Way Mundlak Regression, and Differences-in-Differences 
estimators. Working paper.{p_end}

{phang2}Wooldridge, Jeffrey. 2023.
Simple Approaches to Nonlinear Difference-in-Differences with Panel Data. The Econometrics Journal, Volume 26, Issue 3, September 2023, Pages C31–C66.{p_end}

{phang2}Yoto 1


{marker aknowledgement}{...}
{title:Aknowledgement}

{pstd}This command started as an isolated project before becoming a dad! 2 years later and Im almost ready to get a much better version of it. {p_end}

{title:Also see}

{p 7 14 2}
Help:  {help drdid}, {help csdid}, {help jwdid_postestimation}, {help xtdidregress}, {help xthdidregress}, help hdidregress {p_end}

