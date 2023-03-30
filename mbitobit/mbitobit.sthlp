{smcl}
{*  version 1.0  Feb2020 by Fernando Rios-Avila}{...}

{viewerjumpto "Syntax" "mbitobit##syntax"}{...}
{viewerjumpto "Options" "mbitobit##options"}{...}
{viewerjumpto "Examples" "mbitobit##examples"}{...}

{p2colset 1 17 19 2}{...}
{p2col:{bf: mbitobit} {hline 2}}Bivariate Tobit regression
{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{phang}Bivariate Tobit regression

{p 8 17 2}
{cmd:biprobit}
{it:equation1} {it:equation2}
{ifin}
[{it:{help mbitobit##weight:weight}}]
[{cmd:,} {it:{help mbitobit##options:options}}]


{pstd}where {it:equation1} and {it:equation2} are specified as

{p 8 12 2}{cmd:(} [{it:eqname}{cmd:: }] {depvar} {cmd:=} [{indepvars}]  {cmd:)}

{synoptset 28 tabbed}{...}
{marker options_table}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt :{cmdab:const:raints(}{it:{help estimation options##constraints():constraints}}{cmd:)}}apply specified linear constraints{p_end}
{synopt :{cmdab:lns1(}{it:{help varlist:varlist}}{cmd:)}} Allows to add explanatory variables for the Standard error of equation #1 
Standard errors estimated using the transformation sd1=exp(lns1){p_end}
{synopt :{cmdab:lns2(}{it:{help varlist:varlist}}{cmd:)}} Allows to add explanatory variables for the Standard error of equation #2 
Standard errors estimated using the transformation sd1=exp(lns1){p_end}
{synopt :{cmdab:arho(}{it:{help varlist:varlist}}{cmd:)}} Allows to add explanatory variables for the correlation 
Rho estimated using the transformation rho=tanh(a){p_end}

{syntab:SE/Robust}
{synopt : {opt r:obust}, {opt cl:uster}({it:clustvar})}Defines type of Standard Errors{p_end}

{syntab:Maximization}
{synopt :{it:{cmd:maximize_options}}}control the maximization process. 
{it:maximize_options}: {opt dif:ficult},
{opth tech:nique(maximize##algorithm_spec:algorithm_spec)},
{opt iter:ate(#)}, {opt tr:ace}, and {opt init(init_specs)}.
These options are seldom used.
{p_end}

{synoptline}
{p2colreset}{...}

INCLUDE help fvvarlist

{p 4 6 2}Weights are not allowed with the {helpb bootstrap} prefix.{p_end}
{marker weight}{...}
{p 4 6 2}{opt pweight}s, {opt fweight}s, and {opt iweight}s are allowed; see 
{help weight}.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:mbitobit} fits a maximum-likelihood two-equation tobit models.{p_end}

{pstd}
The command estimates a model of the following form:{p_end}

{pstd}
h1=max(h1*,0)+e1_i {p_end}
{pstd}
h2=max(h2*,0)+e2_i {p_end}
{pstd}
where (e1_i,e2_i)~N(0,S), where S is the var-cov matrix with variance {cmd:sd1}^2 and {cmd:sd2}^2 and correlaton {cmd:rho}.  {p_end}
{pstd}
h1 and h2 are left censored variables at 0. {p_end}

{pstd}
While there are other commands that allow users to estimate Bivariate tobits like 
{cmd:bitobit}, {cmd:mvtobit} and {cmd:cmp}, the advantage of this command is that it 
allows users to easily obtain predicted values and margins on the most common 
moments of interest, using Stata's {help margins} and {help predict}. 
See the next section for details.

{marker PostEstimation}{...}
{title:PostEstimation}

{pstd}
The following options are available when using {cmd:predict} and {cmd:margins}

{synoptset 28 tabbed}{...}
{synopt :{opt eq:uation}{cmd:(}{it:eqno}[{cmd:,}{it:eqno}]{cmd:)}}specify equation from which to calculate Linear prediction {p_end}
{synopt :{opt xb1 xb2}}Calculate Linear predictions for Eq1 and Eq2{p_end}
{synopt :{opt rho}}Calculate the correlation between latent variables{p_end}
{synopt :{opt sd1 sd2}}Calculate residual standard errors for eq1 and eq2 {p_end}
{synopt :{opt pr1 pr2}}Calculate Marginal probability for eq1 and eq2 P(y_i>0) {p_end}
{synopt :{opt yc1 yc2}}Calculate Expected value conditional on success E(y_i|y_i>0) {p_end}
{synopt :{opt ys1 ys2}}Calculate Expected unconditional value E(y_i|y_i>0)*P(y_i>0){p_end}
{synopt :{opt tt}}Calculate total expected value: ys1+ys2 {p_end}
{synopt :{opt uhs1 uhs2}}Calculate the expected share defined as 100*ys1/(ys1+ys2){p_end}
{synopt :{opt yc1_1 yc2_1}}Calculate expected value conditional on success and second equation success E(y_1|y_1>0,y_2> 0) & E(y_2|y_1> 0,y_2>0) {p_end}
{synopt :{opt yc1_0 yc2_0}}Calculate expected value conditional on success and second equation failure E(y_1|y_1>0,y_2<=0) & E(y_2|y_1<=0,y_2>0) {p_end}
{synopt :{opt pr1_1 pr2_1}}Calculate Probability of success conditional on second equation success P(y_1>0|y_2> 0)  & P(y_2>0|y_1> 0) {p_end}
{synopt :{opt pr1_0 pr2_0}}Calculate Probability of success conditional on second equation feilure P(y_1>0|y_2<=0)  & P(y_2>0|y_1<=0) {p_end}
{synopt :{opt p00}}Pr(y_1<=0, y_2<=0) {p_end}
{synopt :{opt p10}}Pr(y_1> 0, y_2<=0) {p_end}
{synopt :{opt p01}}Pr(y_1<=0, y_2> 0) {p_end}
{synopt :{opt p11}}Pr(y_1> 0, y_2> 0) {p_end}
{synopt :{opt sim}}This options allows to simulate data based on the estimated model. It can only be used with {cmd:predict}.
It will create 2 variables with conditional means equal to {cmd:xb1} & {cmd:xb2}, conditional variances equal to {cmd:sd1} & {cmd:sd2}, and correlation {cmd:rho}. 
For example, using the command {cmd:predict new, sim} will create two variables new_{it:eq1} new_{it:eq2} {p_end}									
									
{marker examples}{...}
{title:Examples}

{pstd}Setup: Requires you to install or download data_sample.dta {p_end}
{phang2}{stata use data_sample}{p_end}

{pstd}Bivariate Tobit regression: No controls {p_end}
{phang2}{stata "mbitobit (h_ttime =) (w_ttime=)"}{p_end}

{pstd}Bivariate Tobit regression: Controlling for age, #children and Urban-Rural {p_end}
{phang2}{stata "global indepvar h_age w_age nchild05 nchild617_f nchild617_m i.urban "}{p_end}
{phang2}{stata "mbitobit (h_ttime = $indepvar) (w_ttime = $indepvar), allbase"}{p_end}

{pstd}Replaying last results{p_end}
{phang2}{stata mbitobit}{p_end}

{pstd}Estimating marginal effects{p_end}
{phang2}{stata margins, dydx(nchild05 nchild617_f nchild617_m) predict(ys1)}{p_end}
{phang2}{stata margins, dydx(nchild05 nchild617_f nchild617_m) predict(ys2)}{p_end}

{pstd}Predicting expected values ys1 and ys2 {p_end}
{phang2}{stata predict h1_s, ys1 }{p_end}
{phang2}{stata predict h2_s, ys2 }{p_end}
             
{pstd}Allowing for differences in Standard errors and correlations across Urban-Rural areas{p_end}
{phang2}{stata "mbitobit (h_ttime = $indepvar) (w_ttime = $indepvar), lns1(i.urban) lns2(i.urban) arho(i.urban) allbase"}{p_end}

{pstd}Allowing for differences in Standard errors: All variables {p_end}
{phang2}{stata "mbitobit (h_ttime = $indepvar) (w_ttime = $indepvar), lns1($indepvar) lns2($indepvar) arho($indepvar) allbase"}{p_end}

{pstd}Simulating data based on last model estimated {p_end}
{phang2}{stata "predict s, sim"}{p_end}

{pstd}Bivariate Tobit regression: Controlling for age, #children and Urban-Rural on simulated data{p_end}
{phang2}{stata "mbitobit (s_h_ttime = $indepvar) (s_w_ttime = $indepvar), allbase"}{p_end}

{marker Acknowledgments}{...}
{title:Acknowledgments}

{pstd}
This command was written as part of a project for the Levy Economic Institute,
aiming to analyze the allocation of time, between husband and wife, 
on household production in selected African countries. {break}
I thank the comments and suggestions of Luiza Nassif Pires and Thomas Masterson.

{pstd}
Program is estimated using Stata's {help ml}, and has been tested to work under Stata 13.

{marker Author}{...}
{title:Author}

{pstd}
Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org
