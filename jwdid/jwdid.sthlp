{smcl}
{* *! version 1.1 2_feb_2023}{...}
{title:Title}

{phang}
{bf:jwdid} {hline 2} DID estimator using Mundlak approach


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
{synopt:{opt i:var(varname)}}Declares the Panel ID variable{p_end}
{synopt:{opt t:var(varname)}}Declares the time variable{p_end}
{synopt:{opt g:var(varname)}}Provides the cohort variable{p_end}
{synopt:{opt trtvar(varname)}}If no Gvar is available, you can provide the post-treatment variable. This works if data is panel.{p_end}
{synopt:{opt trgvar(varname)}}If data is RC, you can use trtvar() option with this one. It should be a pseudo panel id in your data for people who share the treatment status at the same time{p_end}
{synopt:{opt never}}Request using Never treated as control group. Default is using not yet treated. Using this, will exclude g-1 period from the interactions {p_end}
{synopt:{opt group}}Request using Group fixed effects instead of Panel ID fixed effects. In linear models, with balanaced panel, estimates are numerically identical{p_end}
{synopt:{opt method(method name, options)}}Request other methods for the estimation of ATT's. For example {cmd:poisson} or {cmd:logit}. 
Default is linear regression model. One can also add some options for other methods (GLM for example){p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:pweight}s are allowed; see {help weight}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:jwdid} is a program that implements the Extended TWFE estimator proposed by Jeff Wooldridge for the estimation of ATT's based on a generalized DID design. 

{pstd}In principle, this estimator simply suggests that to avoid some of the negative aspects of the traditional TWFE-DID estimator, which uses already treated units as controls causing the so-called negative weights, one should simply use a fully interacted set of dummies allowing for treatment effect heterogeneity by cohort and timing. 

{pstd}Specifically, instead of estimating a model as follows:

{pstd}y_it = gamma * D_it + a_i + b_t + e_t

{pstd}where D_it indicates if unit i is treated at time t. One should estimate a model like the following:

{pstd}y_it = sum(gamma_gt * G_i * t) + a_i + b_t + e_t

{pstd}where G_i * t corresponds to all possible interactions of the cohort unit i belongs to (G_i) and the period we aim to estimate that effect at (t). 

{pstd}In the simplest case, gamma_gt represents the ATT for cohort G at time t, and the estimates are comparable to the ones one could obtain using {cmd: csdid}.

{pstd}This command also allows you to add controls to the model, but those controls should be time invariant. The command will NOT verify that this is the case. 

{pstd}One should also be aware that {cmd: jwdid} will create as many interactions as cohorts and periods are there in the data, times all possible controls. 
This could provide an extreamly large number of estimated coefficients, which could make the models difficult to estimate.

{pstd}When using other estimation methods using {cmd: method()}, the program will assume group/cohort fixed effects only, instead of individual fixed effects. Mostly, this is to avoid the incidental parameter problem.

{pstd}The default comparison group only the interactions of cohort and time AFTER treatment occurred are included in the specification. This effectively uses not-yet treated as controls. When using the option {cmd:never}, all posible interactions of cohort 
and time are used, thus considering only the never treated as controls. The results from this are equivalent to Callaway and Sant'Anna (2021) and {cmd: csdid}, and the proposition by Sun and Abraham (2021). 

{marker remarks}{...}
{title:Remarks}

{pstd}
The first version of this command came out as one of my attempts of learning some of the new DID methods. 
For a while, most of my efforts were centered on {cmd:drdid} and {cmd:csdid}. 
However, the methodology proposed by Prof. Wooldridge has important advantages over other methods, which called my applied econometrician's attention. 

{pstd}The two most important advantages are: 

{phang2}1. It is based on regression analysis, and most people understand regression, compared to the other alternatives

{phang2}2. It is flexible for other methods. Namely, you should be easily be able to apply it for binary or count models (or other methods yet untested?)

{pstd}Also, this program was coded independently from Jeff Wooldridge, but mostly based on some of his simulation codes he shared with the community. 
Thus all errors of interpretation, and re-implementation (some of my own views on it) are my own. 
If you see an error or bug, Please let me know.

{pstd}And of course, there are now other two options to do the same in Stata. In Stata18, they lunch -xthdidregress- and -hdidregress-, which have the option 
to estimate DID models using the same approach. And most recently, someone developed -wooldid-. Lots of options! but I still like mine better! Just saying.

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

DID using not-treated as controls, based on group (rather than individual) fixed effects, and one time invariant control

{phang}{stata "jwdid lemp lpop, ivar(countyreal) tvar(year) gvar(first_treat) group"}{p_end}

DID using not-treated as controls, based on group (rather than individual) fixed effects, and one time invariant control. 
Poisson regression estimator.

{phang}{stata "gen emp = exp(lemp)"}{p_end}
{phang}{stata "jwdid emp lpop, ivar(countyreal) tvar(year) gvar(first_treat) method(poisson)"}{p_end}


{marker authors}{...}
{title:Authors}

{pstd}
Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org

{marker references}{...}
{title:References}

{phang2}Wooldridge, Jeffrey. 2021.
Two-Way Fixed Effects, the Two-Way Mundlak Regression, and Differences-in-Differences 
estimators. Working paper.{p_end}

{phang2}Wooldridge, Jeffrey. 2023.
Simple Approaches to Nonlinear Difference-in-Differences with Panel Data. The Econometrics Journal, Volume 26, Issue 3, September 2023, Pages C31–C66.{p_end}


{marker aknowledgement}{...}
{title:Aknowledgement}

{pstd}This command was put together just for fun, and as my last push of "productivity" before my 
baby girl was born! (she is now 15months!) {p_end}

{title:Also see}

{p 7 14 2}
Help:  {help drdid}, {help csdid}, {help jwdid_postestimation}, {help xtdidregress}, {help xthdidregress}, help hdidregress {p_end}

