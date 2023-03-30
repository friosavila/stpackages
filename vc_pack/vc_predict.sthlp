{smcl}
{* *! version 2.0.0  July 2019 Fernando Rios Avila}{...}
 
{vieweralsosee "vc_bw" "help vc_bw"}{...}
{vieweralsosee "vc_bwalt" "help vc_bwalt"}{...}
{vieweralsosee "vc_reg" "help vc_reg"}{...}
{vieweralsosee "vc_reg" "help vc_preg"}{...}
{vieweralsosee "vc_bsreg" "help vc_bsreg"}{...}
{vieweralsosee "vc_graph" "help vc_graph"}{...}
{vieweralsosee "cv_regress" "help cv_regress"}{...}
 
{title:Title}

{phang}
{bf:vc_predict} {hline 2} Command used to obtain predictions, Leave-one-out errors, and residuals for the Smooth varying coefficient model. 


{marker syntax}{...}
{title: Syntax}

{p 8 17 2}
{cmdab:vc_predict}
[{varlist}]
{ifin}
[{cmd:,} vcoeff(varname) bw(#) {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opth vcoeff(varname)}} Indicates the variable to be used for the estimation of smooth varying coefficients. The default option is to use the stored variable in global $vcoeff_ after using {help vc_bw} or {help vc_bwalt} {p_end}
{synopt:{opt bw(#)}} Used to provide a Bandwidth for the estimation of the varying coefficient model. The default option is to use the stored value in global $opbw_ after using {help vc_bw} or {help vc_bwalt}  {p_end}
{synopt:{opt kernel(kernel)}} Indicates which kernel function to be used in the varying coefficient model. The default option is to use the stored value in global $kernel_ after using {help vc_bw} or {help vc_bwalt}  {p_end}
{synopt:{opth yhat(newvar)}} Provides the name of a new variable where to save the predicted values {p_end}
{synopt:{opth res(newvar)}}  Provides the name of a new variable where to save the predicted residuals {p_end}
{synopt:{opth looe(newvar)}} Provides the name of a new variable where to save the predicted leave-one-out errors {p_end}
{synopt:{opth lvrg(newvar)}} Provides the name of a new variable where to save the predicted leverage points {p_end}
{synopt:{opt stest}} Option that requests specification test against parametric models that use interactions with linear, quadratic and cubic polynomials of the smooth coefficient, based on Hastie and Tibshirani (1990) {p_end}
{synopt:{opth knots(#)}} This option request the estimation of #k bins that will be used for the estimation og the predicted values, and specification tests. The default is to use all distinct values in vcoeff. 
Using this option provides gains in speed at a cost of lower precision. When knots(0) is specified, the number of knots is given by min{sqrt(N), 10*ln(N)/ln(10). {p_end}
{synopt:{opth km(#)}} This option is ment to be used in combination with knots(0). When used, it requests to use knots=km* min{sqrt(N), 10*ln(N)/ln(10). Default its km(1) {p_end}


All kernel functions are allowed.  

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
{cmd:vc_predict} is a command used obtain the model predictions, LOO errors and leverage for SVCM. The command also reports the R2 for the model, as well
as the average number of kernel observations, and degrees of freedom of the model and residuals. {p_end}
{pstd}The number of Kernel observaions is defined as the weighted sum of the standardized kernel weight of all observations used for regressions in a particular point of interest.  {p_end}
{pstd}The number of degrees of freedom is defined as the sum of the leverage statistics. See Rios-Avila (2019) for details. {p_end}

{marker remarks}{...}
{title:Remarks}

{pstd}
This command is used to obtained predicted values, predicted errors,  Leave-One-Out and leverage error for the varying coefficient model. {p_end}
{pstd} The command requires to specify all the variables for the model specification, as if using the commands {help vc_reg}. By default, information about
the kernel, bandwidth and vcoeff are taken from the macros stored by vc_bw and vc_bwalt {p_end}

{pstd} The default option is to use all  values defined in vcoeff, to obtain the model predictions, however, for an accelerated, but less accurate estimate prediction,
 one can use knots() and km() options. This creates an internally used variable with less variation than the original variable, estimate the varying coefficient models. {p_end}
 
{pstd} The command reports two measures of R2. One based on the Sum of squares, and one based on the recommendation in Henderson and Parmeter (2015). {p_end}

{pstd} The expected number of Kernel Observations and degrees of freedom of the model and degrees of freedom of the error, are also reported.

{pstd} The command also reports basic specification tests against a model with polynomial interactions following an approximate F statistic as described in Hastie and Tibshirani(1990). {p_end}
 
{pstd} Because the F-test does not have a known distribution function, one can use {cmd: vc_test} to implement the wildbootstrap J-statistic.

{marker examples}{...}
{title:Examples}

{stata "webuse motorcycle, clear" }

{stata "vc_bw accel, vcoeff(time)  "}
{stata "vc_predict accel, vcoeff(time)  yhat(accel_hat1) "}
{stata "scatter accel_hat1 time"}
 	  
** DUI dataset
{stata "webuse dui, clear"}
{stata "vc_bw citations i.csize college taxes, vcoeff(fines)  "}
{stata "vc_predict citations i.csize college taxes, vcoeff(fines)  stest"}
 

{marker Author}{...}
{title:Author}

{pstd}Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Blithewood-Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org

{marker references}{...}
{title:References}

Hastie, Trevor, and Robert Tibshirani. 1990. Generalized Additive Models. New York: Chapman and Hall.
Hastie, Trevor, and Robert Tibshirani. 1993. "Varying-Coefficient Models."  Journal of the Royal Statistical Society. Series B (Methodological) 55 (4):757-796.
Henderson, Daniel J., and Christopher F. Parmeter. 2015. Applied Nonparametric Econometrics. Cambridge, United Kingdom: Cambridge University Press.
Li, Qi, and Jeffrey Scott Racine. 2007. Nonparametric Eonometrics: Theory and Practice. New Jersey: Princeton University Press.
Li, Qi, and Jeffrey Scott Racine. 2010. "Smooth Varying-Coefficient Estimation and Inference for Qualitative and Quantitative Data."  Econometric Theory 26 (6):1607-1637.
Rios-Avila, Fernando (2019) Smooth varying coefficient models in Stata. Working paper. {browse "https://drive.google.com/open?id=1dkd-NTsiZjzl8JGImegxfuOe4FZ1YsQ4":vc_pack paper}
