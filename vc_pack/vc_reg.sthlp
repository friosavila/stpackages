{smcl}
{* *! version 3.0.0  July2019}{...}
{vieweralsosee "vc_bw" "help vc_bw"}{...}
{vieweralsosee "vc_bwalt" "help vc_bw"}{...}
{vieweralsosee "vc_reg" "help vc_reg"}{...}
{vieweralsosee "vc_preg" "help vc_preg"}{...}
{vieweralsosee "vc_bsreg" "help vc_bsreg"}{...}
{vieweralsosee "vc_graph" "help vc_graph"}{...}
{vieweralsosee "vc_predict" "help vc_predict"}{...}
{vieweralsosee "cv_regress" "help cv_regress"}{...}

{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}

{title:Title}

{phang}
{bf:vc_reg, vc_preg and vc_bsreg} {hline 2} Modules for the estimation of a Smooth varying coefficient model. 
 

{marker syntax}{...}
{title: Syntax}

Varying Coefficient model with Local Linear errors OLS standard errors
{p 8 17 2}
{cmdab:vc_reg}
[{varlist}]
{ifin}
[{cmd:,} vcoeff(varname) bw(#) {it:options}]

Varying Coefficient model with full Sample error OLS standard errors
{p 8 17 2}
{cmdab:vc_preg}
[{varlist}]
{ifin}
[{cmd:,} vcoeff(varname) bw(#) {it:options}]

Varying Coefficient model with Bootstrap Standard errors
{p 8 17 2}
{cmdab:vc_bsreg}
[{varlist}]
{ifin}
[{cmd:,} vcoeff(varname) bw(#) {it:options}]

 

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:vc_reg options}
{synopt:{opth vcoeff(varname)}} Indicates the variable to be used for the estimation of smooth varying coefficients model (SVCM).
 The default is to use the variable stored in global $vcoeff_, which was stored in memory after using {cmd: vc_bw} or {cmd: vc_bwalt}  {p_end}
{synopt:{opth bw(#)}} Used to provide a Bandwidth for the estimation of the SVCM. The default uses the optimal bandwidth stored in global $opbw_ 
after using {cmd: vc_bw} or {cmd: vc_bwalt} {p_end}
{synopt:{opt kernel(kernel)}} Indicates which kernel function to be used in the varying coefficient model. Default is the one stored in global $kernel_ after  using {cmd: vc_bw} or {cmd: vc_bwalt} {p_end}
{synopt:{opth cluster(varname)}} Request the local linear cluster standard errors. cannot be combined with hc2 or hc3  {p_end}
{synopt:{opt robust}} Requests the local linear robust standard errors. {p_end}
{synopt:{opt hc2 hc3}} Requests the local linear vce(hc2) or vce(hc3) standard errors. {p_end}
{synopt:{opth k(#)}} Indicates how many points will be used for the model estimation. Has to be an integer larger than 2. The points of reference 
are created to be equidistant between the 1st and 99th percentiles of the sample.
of the empirical distribution of the smoothing variable. Cannot be used with klist(). {p_end}
{synopt:{opth klist(numlist)}} Indicates a list of numbers to be used for the model estimation. If only 1 value is specified, the output of the model at that point will be shown. Cannot be used with k(). {p_end}

{syntab:vc_preg specific options}

{synopt:{opth knots(real -1) km(real 1)}} This options can be used to define how are the full sample errors estimated. The default is to use all distinct 
values in vcoeff(varname). knots(#) with a number equal or larger than 2 request to estimate # regressions using groups of equal width, and simple average of the 
smoothing variable as point of reference. Using knots(0) request estimating #=round(min(sqrt(N),10*log(N)/log(10)). Similar criteria is used to choose number
of bins using histograms. If knots(0) is used, km can be requested to estimate #km*round(min(sqrt(N),10*log(N)/log(10)) regressions. {p_end}
{synopt:{opth err(varname)} {opth lev(varname)}}  To accelerate the estimation of the standard errors, one can provide the command with errors and leverage statistic estimated in a previous step. 
by default, the command estimates the full sample errors internally. {p_end}
 
{syntab:vc_bsreg options}
 
{synopt:{opth reps(#)}} Indicates the number of repetitions for the bootstrap process. Default is 50. {p_end}
{synopt:{opth seed(#)}} Sets the seed number for the generation of bootstrap samples {p_end}
{synopt:{opth cluster(varname)}} Provides a variable identifying resampling clusters  {p_end}
{synopt:{opth strata(varname)}}  Provides a variable identifying strata {p_end}
{synopt:{opth pci(#)}}  Can be used to set the level of the percentile based confidence intervals. {p_end}
{synopt:{opt skf(#)}}  Provides a number that should be between 0 and 1. When this option is used, the bootstrap standard errors will be estimated using a smaller bandwidth than the one used for the point estimates.   {p_end}
 
{synoptline}
{p2colreset}{...}

{synoptset 29}{...}
{synopthdr :kernel}
{synoptline}
{synopt :{opt gaussian}}Gaussian kernel function; The default{p_end}
{synopt :{opt epan}}Epanechnikov kernel function {p_end}
{synopt :{opt epan2}}alternative Epanechnikov kernel function{p_end}
{synopt :{opt biweight}}biweight kernel function{p_end}
{synopt :{opt cosine}}cosine trace kernel function{p_end}
{synopt :{opt parzen}}Parzen kernel function{p_end}
{synopt :{opt rectan}}rectangle kernel function{p_end}
{synopt :{opt trian}}triangle kernel function{p_end}
{synoptline}
{p2colreset}{...}
{marker weight}{...}
{p 8 17 2}


{marker description}{...}
{title:Description}

{pstd}
{cmd:vc_reg, vc_preg and vc_bsreg} are commands used to estimate  SVCM using a local linear kernel smoothing, as described in Rios-Avila (2019).
This is done over a list of points of reference (klist()) or simply declaring number of points (k()) across the data. When using k(), the points are choosen to be equidistant
between the 1st and 99th percentile. For example k(2) will estimate 2 models, at the p1 and p99 of the distribution. {p_end}

{pstd}
When vc_reg or vc_preg are used, standard errors are estimated using local errors, following the estimation proposed by Racine and Li (2007,2010). The default is to use robust standard errors, where the weights are determined by the kernel and bandwidth used. 
It is also possible to request robust standard errors, clustered standard errors, or those based on HC2 and HC3. {p_end}

{pstd}
The difference between both commands is that vc_reg uses the local linear predicted errors and leverage to estimate the coefficients standard errors. In contrast, vc_preg
uses the full sample errors and leverages. This is done either by estimating the model errors and leverages for the whole model internally, or using predictions obtained in a previous step. {p_end}

{pstd}
Similar to the command {help npregress}, one can also request bootstrap standard errors, specifying the number of repetitions, cluster variable or strata variable. 
The output reports normal-based confidence intervals, but one can request percentile based confidence intervals. {p_end}

{pstd}
When Bootstrap regressions are estimated, one can also request the estimation of standard errors using a different bandwidth with the option skf(). For example, using 
a value less than 1, say 0.8, request that Bootstrap standard errors to be estimated using a bandwidth that is 20% than the bandwidth used for the main regression. The default uses a skf of 1.
{p_end}

{pstd}
When only 1 point of reference is provided, all comands display the standard regression output. When 2 or more points of references are provided, no output is provided byt betas and variance matrices for each model are saved separatey as e(b#) e(V#)  {p_end}

{pstd}
In all cases, two matrices e(betas) and e(stds) are saved containing the betas and standard errors for all the estimated models. This can be used for obtaining plots of the results see {help vc_graph}  {p_end}

{marker remarks}{...}
{title:Remarks}

{pstd}
This program estimates a semiparametric model known as Smooth varying coefficient model (Hastie and Tibshirani, 1993). 
In specific, it esimates a model that has the following form: {p_end}

{pstd}
y=f0(z)+f1(z)*x1+f2(z)*x1+...+error {p_end}

{pstd}
where f0(z), f1(z),..., fk(z) are unknown nonlinear functions of z. 
{p_end} 
{pstd}
To estimate this model, the commands {cmd: vc_reg}, {cmd: vc_preg} or {cmd: vc_bsreg} to compute weighted regression in the neighborhood of some point of reference z0, 
using a local linear approximation. For any specific point of reference, z0, the program estimates a model of the following form: {p_end}

{pstd}
y=a0+b0*x+a1*(z-z0)+b0*x*(z-z0)+e{p_end}

{pstd}
Call X=[1 x (z-z0) x*(z-z0)], the estimation for the parameters B=[a0 a1 b0 b1]' are given by {p_end}

{pstd}
B=(X'W(z0)X)^-1 * X'W(z0)y {p_end}

{pstd}
with W(z) being a matrix of kernel weights depending on how close an observation is to the point of interest z0.{p_end}
{pstd}
It should be noticed when no additional variables X are specified, the regression provides estimates equivalent to those from {help lpoly} and {help npregress kernel}. 
{p_end}
{pstd} vc_reg and vc_preg report the standard OLS standard errors using iweights and robust standard errors, as suggested in Racine and Li (2007,2010). Bootstrap standard errors can be obtained using vc_bsreg.
{p_end}
{pstd} Further details on the command, the models and estimation methods can be found in Rios-Avila (2019).
{p_end}

{marker examples}{...}
{title:Examples}

{stata "webuse motorcycle, clear"}
{stata "vc_bw accel, vcoeff(time)"}
* Estimating model at time=25 using vc_reg
{stata "vc_reg accel, vcoeff(time) klist(25) robust"}
* Same model using vc_bsreg
{stata "vc_bsreg accel, vcoeff(time) klist(25) reps(50) seed(1)"}
{stata "estat bootstrap, percentile"}

* Compared to npregress
{stata "qui:npregress kernel accel time, kernel(gaussian) bw($opbw_ $opbw_, copy)"}
{stata "margins , at(time=25) reps(50) seed(1)"}
{stata "margins , dydx(time) at(time=25) reps(50) seed(1)"}

 
** Using the DUI dataset

{stata "webuse dui, clear"}
{stata "vc_bw citations i.csize taxes college, vcoeff(fines)"}

** Varying coefficient model using Local Approximations 
{stata "qui:vc_reg citations i.csize taxes college, vcoeff(fines) bw(0.7398) klist(9) robust"}
{stata "est sto m1a"}
{stata "qui:vc_reg citations i.csize taxes college, vcoeff(fines) bw(0.7398) klist(10) robust"}
{stata "est sto m2a"}
{stata "qui:vc_reg citations i.csize taxes college, vcoeff(fines) bw(0.7398) klist(11) robust"}
{stata "est sto m3a"}
{stata "ssc install estout"}


** Varying coefficient model using Full sample errors
{stata "qui:vc_preg citations i.csize taxes college, vcoeff(fines) bw(0.7398) klist(9) robust"}
{stata "est sto m1b"}
{stata "qui:vc_preg citations i.csize taxes college, vcoeff(fines) bw(0.7398) klist(10) robust"}
{stata "est sto m2b"}
{stata "qui:vc_preg citations i.csize taxes college, vcoeff(fines) bw(0.7398) klist(11) robust"}
{stata "est sto m3b"}


** Varying coefficient model using Bootstrap Standard errors
{stata "qui:vc_bsreg citations i.csize taxes college, vcoeff(fines) bw(0.7398) klist(9) seed(1)"}
{stata "est sto m1c"}
{stata "qui:vc_bsreg citations i.csize taxes college, vcoeff(fines) bw(0.7398) klist(10) seed(1)"}
{stata "est sto m2c"}
{stata "qui:vc_bsreg citations i.csize taxes college, vcoeff(fines) bw(0.7398) klist(11) seed(1)"}
{stata "est sto m3c"}
{stata "esttab m1a m1b m1c m2a m2b m2c m3a m3b m3c  , se noomit nogaps "}

{marker Author}{...}
{title:Author}

{pstd}Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Blithewood-Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org


{marker references}{...}
{title:References}

Hastie, Trevor, and Robert Tibshirani. 1993. "Varying-Coefficient Models."  Journal of the Royal Statistical Society. Series B (Methodological) 55 (4):757-796.
Li, Qi, and Jeffrey Scott Racine. 2007. Nonparametric Eonometrics: Theory and Practice. New Jersey: Princeton University Press.
Li, Qi, and Jeffrey Scott Racine. 2010. "Smooth Varying-Coefficient Estimation and Inference for Qualitative and Quantitative Data."  Econometric Theory 26 (6):1607-1637.
Rios-Avila, Fernando (2019) Smooth varying coefficient models in Stata. Working paper. {browse "https://drive.google.com/open?id=1dkd-NTsiZjzl8JGImegxfuOe4FZ1YsQ4":vc_pack paper}
