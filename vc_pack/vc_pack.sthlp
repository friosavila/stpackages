{smcl}
{* *! version 1.0.0  February 2020}{...}
{vieweralsosee "vc_bw" "help vc_bw"}{...}
{vieweralsosee "vc_bwalt" "help vc_bw"}{...}
{vieweralsosee "vc_reg" "help vc_reg"}{...}
{vieweralsosee "vc_preg" "help vc_preg"}{...}
{vieweralsosee "vc_bsreg" "help vc_bsreg"}{...}
{vieweralsosee "vc_graph" "help vc_graph"}{...}
{vieweralsosee "vc_predict" "help vc_predict"}{...}
{vieweralsosee "cv_regress" "help cv_regress"}{...}


{title:Title}

{phang}
{bf:vc_pack} {hline 2} Modules for the model selection, estimation, and visualization of Smooth Varying Coefficient Models (SVCM). 
 
{marker description}{...}
{title:Description}

{pstd}
Non-parametric regressions are powerful statistical tools that can be used to model 
relationships between dependent and independent variables with minimal assumptions on
the underlying functional forms. 

{pstd}
Despite its potential benefits, these types of models have two weaknesses: 

{pstd}
- The added flexibility creates a curse of dimensionality, 

{pstd}
- And procedures available for model selection, like cross-validation, have a high computational 
cost in samples with even moderate sizes.

{pstd}
An alternative to fully-nonparametric models are semiparametric models that combine the flexibility 
of non-parametric regressions with the structure of standard models. 
 
{pstd} 
This package estimates a particular type of semiparametric models known as Smooth Varying Voefficient Models
(Hastie and Tibshirani 1993), based on kernel regression methods, assuming a single smoothing variable. 

{pstd}
These commands aim to facilitate bandwidth selection, model estimation, implementation of specification tests, and create visualizations of the results.

{pstd}
In this package you will find the following commands:

{pstd}
{help vc_bw} and {help vc_bwalt} are commands used for the bandwidth selection, using two maximization methods for the crossvalidation procedure.

{pstd}
{help vc_reg}, {help vc_bsreg} and {help vc_preg} are commands used for the estimation of the SVCM, based on different strategies for the estimation of the Variance Covariance matrix of the coefficients.

{pstd}
{help vc_predict} is a commands used for the the estimation of predicted values, predicted errors, and leave-one-out errors.
It also provides basic summary statistics for the SVCM, and performs the approximate F test for model specification.

{pstd}
{help vc_test} is a commands used to implement the J-statistic specification test, using a wild bootstrap procedure.

{pstd}
{help vc_graph} is a commands used to obtain plots of the estimated smooth coefficients after the model has been estimated using 
{help vc_reg}, {help vc_bsreg} or {help vc_preg}.

{pstd}
For details on the commands, please refer to Rios-Avila(2020).

{marker Author}{...}
{title:Author}

{pstd}Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Blithewood-Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org

{marker references}{...}
{title:References}

{pstd}
Hastie, Trevor, and Robert Tibshirani. 1993. "Varying-Coefficient Models."  Journal of the Royal Statistical Society. Series B (Methodological) 55 (4):757-796.
{pstd}
Rios-Avila, Fernando (2020) Smooth varying coefficient models in Stata. Working paper. {browse "https://drive.google.com/open?id=1dkd-NTsiZjzl8JGImegxfuOe4FZ1YsQ4":vc_reg paper}
