{smcl}
{* *! version 2.0.0  July 2019 Fernando Rios Avila}{...}
 
{vieweralsosee "vc_bw" "help vc_bw"}{...}
{vieweralsosee "vc_bwalt" "help vc_bwalt"}{...}
{vieweralsosee "vc_reg" "help vc_reg"}{...}
{vieweralsosee "vc_reg" "help vc_preg"}{...}
{vieweralsosee "vc_bsreg" "help vc_bsreg"}{...}
{vieweralsosee "vc_graph" "help vc_graph"}{...}
{vieweralsosee "vc_test" "help vc_test"}{...}
{vieweralsosee "cv_regress" "help cv_regress"}{...}
 
{title:Title}

{phang}
{bf:vc_test} {hline 2} Command used to implement J-Statistic Wild Bootstrap specification test. 


{marker syntax}{...}
{title: Syntax}

{p 8 17 2}
{cmdab:vc_test}
[{varlist}]
{ifin}
[{cmd:,} vcoeff(varname) {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opth vcoeff(varname)}} Indicates the variable to be used for the estimation of smooth varying coefficients. The default option is to use the stored variable in global $vcoeff_ after using {help vc_bw} or {help vc_bwalt} {p_end}
{synopt:{opt bw(#)}} Used to provide a Bandwidth for the estimation of the varying coefficient model. The default option is to use the stored value in global $opbw_ after using {help vc_bw} or {help vc_bwalt}  {p_end}
{synopt:{opt kernel(kernel)}} Indicates which kernel function to be used in the varying coefficient model. The default option is to use the stored value in global $kernel_ after using {help vc_bw} or {help vc_bwalt}  {p_end}
{synopt:{opth knots(#)}} This option request the estimation of #k bins that will be used for the estimation og the predicted values, and specification tests. The default is to use all distinct values in vcoeff. 
Using this option provides gains in speed at a cost of lower precision. When knots(0) is specified, the number of knots is given by 2*min(sqrt(N), 10*ln(N)/ln(10). {p_end}
{synopt:{opth km(#)}} This option is ment to be used in combination with knots(0). When used, it requests to use knots=km* min(sqrt(N), 10*ln(N)/ln(10). Default its km(2) {p_end}
{synopt:{opth degree(#)}} Specifies the alternative parametric model will be used as null hypothesis agains the SVCM. Model 0 to 3 follow the same specification as vc_predict approximate F-test {p_end}
{synopt:{opth wbsrep(#)}} Specifies the number of Wildbootstrap samples to used. Default is 50 repetitions.

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
{cmd:vc_test} implements the specification test proposed by Cai, Fan, and Yao (2000), based on a wild bootstrapped approach, as described in Henderson and Parmeter (2015).
The test statistic is constructed in a similar way as an F-statistic, but without adjusting for degrees of freedom.

The wildbootstrap procedure is implemented under the null that the parametric model is correctly specified, and the empirical distribution of J is used to find critical values
to evaluate the null hypothesis.

The parametric model is defined using degree(#), where each model is defined as follows:

Model 0 y=xb0+gz+e

Model 1 y=xb0+gz+(z*x)b1+e

Model 2 y=xb0+gz+(z*x)b2+(z^2*x)b2+e

Model 3 y=xb0+gz+(z*x)b2+(z^2*x)b2+(z^3*x)b3+e

See Rios-Avila (2019) for details.  

{marker examples}{...}
{title:Examples}
* Specification test example
{stata "webuse motorcycle, clear"}
{stata "vc_bw accel, vcoeff(time)"}
{stata "vc_test accel, vcoeff(time)  degree(0)"}
{stata "vc_test accel, vcoeff(time)  degree(1)"}
{stata "vc_test accel, vcoeff(time)  degree(2)"}
{stata "vc_test accel, vcoeff(time)  degree(3)"}
 
{stata "webuse dui, clear"}
{stata "vc_bw citations taxes i.csize college , vcoeff(fines)"}

{stata "vc_test citations taxes i.csize college , vcoeff(fines ) degree(0)"}
{stata "vc_test citations taxes i.csize college , vcoeff(fines ) degree(0) wbsrep(100)"}

{stata "vc_test citations taxes i.csize college , vcoeff(fines ) degree(1)"}
{stata "vc_test citations taxes i.csize college , vcoeff(fines ) degree(1) wbsrep(100)"}

{stata "vc_test citations taxes i.csize college , vcoeff(fines ) degree(2)"}
{stata "vc_test citations taxes i.csize college , vcoeff(fines ) degree(2) wbsrep(100)"}


{marker Author}{...}
{title:Author}

{pstd}Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Blithewood-Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org

{marker references}{...}
{title:References}

Cai, Zongwu, Jianqing Fan, and Qiwei Yao. 2000. "Functional-Coefficient Regression Models for Nonlinear Time Series."  Journal of the American Statistical Association 95 (451):941-956. 
Hastie, Trevor, and Robert Tibshirani. 1990. Generalized Additive Models. New York: Chapman and Hall.
Hastie, Trevor, and Robert Tibshirani. 1993. "Varying-Coefficient Models."  Journal of the Royal Statistical Society. Series B (Methodological) 55 (4):757-796.
Henderson, Daniel J., and Christopher F. Parmeter. 2015. Applied Nonparametric Econometrics. Cambridge, United Kingdom: Cambridge University Press.
Li, Qi, and Jeffrey Scott Racine. 2007. Nonparametric Eonometrics: Theory and Practice. New Jersey: Princeton University Press.
Li, Qi, and Jeffrey Scott Racine. 2010. "Smooth Varying-Coefficient Estimation and Inference for Qualitative and Quantitative Data."  Econometric Theory 26 (6):1607-1637.
Rios-Avila, Fernando (2019) Smooth varying coefficient models in Stata. Working paper. {browse "https://drive.google.com/open?id=1dkd-NTsiZjzl8JGImegxfuOe4FZ1YsQ4":vc_pack paper}

