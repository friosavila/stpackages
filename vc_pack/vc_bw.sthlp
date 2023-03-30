{smcl}
{* *! version 2.0  Fernando Rios-Avila July 2019 }{...}
{vieweralsosee "vc_bw" "help vc_bw"}{...}
{vieweralsosee "vc_bwalt" "help vc_bwalt"}{...}
{vieweralsosee "vc_reg" "help vc_reg"}{...}
{vieweralsosee "vc_bsreg" "help vc_bsreg"}{...}
{vieweralsosee "vc_preg" "help vc_preg"}{...}
{vieweralsosee "vc_graph" "help vc_graph"}{...}
{vieweralsosee "vc_predict" "help vc_predict"}{...}
{vieweralsosee "cv_regress" "help cv_regress"}{...}


{title:Title}

{phang}
{bf:vc_bw & vc_bwalt} {hline 2} Commands for model Bandwidth selection for Smooth varying coefficient models based on Leave-one-out Crossvalidation.  {p_end}


{marker syntax}{...}
{title: Syntax}

{p 8 17 2}
Newton-Raphson like algorithm {p_end}
{p 8 17 2}
{cmdab:vc_bw} [{varlist}] [if] [in] [{cmd:,} vcoeff(varname) {it:options}]

{p 8 17 2}
Bisection like algorithm {p_end}
{p 8 17 2}
{cmdab:vc_bwalt} [{varlist}] [if] [in] [{cmd:,} vcoeff(varname) {it:options}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opth vcoeff(varname)}} Indicates the variable to be used for the estimation of smooth varying coefficients {p_end}
{synopt:{opt knots(#)}} Defines how many knots will be used for the Cross validation search. Using this option will prebin the data in #k+1 groups of equal bin.
The default is to use all the distinct values of {cmd: vcoeff()} if they are less than 500 distinct values. Otherwise it uses the nearest integer to
knots =2* min{sqrt(N), 10*ln(N)/ln(10)}.  This is similar to the choice of bins when using histograms. Using knots(0) request using knots = min{sqrt(N), 10*ln(N)/ln(10)}. To request using ALL distinct values in {cmd: vcoeff()} 
use knots(-2). Any other possitive number will be used directly as the specified number of knots. 
When Knots is specified, the command will also report the Implicit Bin width. The rule of thumb is for the ratio between the Binwdith and optimal bandwidh to be less than 0.3 (gaussian Kernal) or 0.1 otherwise (Hoti and Homstrom, 2003) {p_end}
{synopt:{opt km(#)}} This option is ment to be used in combination with knots(0). It indicates to use a number of knots defined by knots = km * min{sqrt(N), 10*ln(N)/ln(10)}. {p_end}
{synopt:{opt bwi(#)}} Used to set the initial value for the Bandwidth. The default is to use lpoly plug-in bandwidth. {p_end}
{synopt:{opth trimsample(varname)}} Provides a variable that indicates which observations within the sample will be used for the calculation of the Cross validation criteria.
This is used to reduce the influence of sparse data around the endpoints of the distribution of the running variable (vcoeff) for the estimation of the optimal bandwidth. Values of zero 
indicate that those observations will not be used for calculating the CV criteria (but are used in the local linear regression) {p_end}
{synopt:{opt kernel(kernel)}} Indicates which kernel function to be used in the process. Default is  Gaussian Kernel. All kernel functions are allowed. gaussian, biweight, cosine, epan, epan2, parzen, trian and rectan {p_end}
{synopt:{opt plot}} This option requests to provide the plot of the CrossValidation criteria and Bandwidths. Use it when encountering problematic maximization areas and for visual inspection. {p_end}
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
{cmd:vc_bw} and {cmd:vc_bwalt} are modules used to calculate the Optimal bandwidth for smooth varying coefficient model. This is done by minimizing a Leave-one-out crossvalidation (LOOCV) criteria. {p_end}
{pstd}
vc_bw uses a Newton-Raphson type of algorithm to find the optimal bandwith. This should be more precise but may have difficulties in some cases where the objective function is not differentiable, or not concave. See Rios-Avila (2019) for details algorithm. {p_end}
{pstd}
vc_bwalt uses is a Bisection type algorithm to find the optimal bandwith. This should should have fewer problems finding the optimal bandiwdth with all kernel functions, but might will be less precise. See Rios-Avila (2019) for details on the algorithm.
The CrossValidation Criteria is the log of the LOO mean squared error. The LOO errors are calculated over the data defined by the IF and IN qualifiers, and the Mean Squared error is constrained to the TRIM-sample.{p_end}
{pstd}
While most algorithms use all distinct values in the smoothing variable {cmd: vcoeff()} to find the optimal bandwidth, this command estimates the Cross validation criteria using local approximation based on binned data, defined by knots. 
This strategy provides less accurate results, but at a lower computational cost. Simulations show that the loss in precision is relatively small when the ratio between the binwidth and optimanl bandwith is small, with a large gain in computational speed. See Rios-Avila(2019) for details.
{p_end}
 

{marker remarks}{...}
{title:Remarks}

{pstd}
vc_bw program uses numerical derivatives and a Newton-Raphson type of algorithm to find the optimal bandwith that minimizes the LOOCV criteria, for a corresponding smooth varying coefficient model. This is done using local linear approximations and leverage to estimate the Leave-one-out error. {p_end}

{pstd}
vc_bwalt uses a Bisection type algorithm to find the optimal bandwith that minimizes the LOOCV criteria. Details on both algorithms can be found in Rios-Avila (2019) {p_end}

{pstd}
While both commands can be used for all the standard kernel functions, vw_bc may performs better with the gaussian kernel. vc_bwalt is more likely to find a solution in cases 
with a more complex optimization problem. For example when using rectan(gular) kernel. {p_end}

{pstd}
vw_bc may have difficulties finding the optimal bandwidth when the LOOCV criteria is not differentiable.  {p_end}

{pstd}
As part of the output, a matrix is provided containing each bandwidth, and its corresponding loocv cross validation criteria,
estimated through the program. It is suggested to review this when encountering difficult or unexpected optimization patterns. One can also use the option {cmd: plot} to provide a simple scatter of the Crossvalidation and bandwidths.{p_end}

{pstd}
When using knots(0) or knots(#), one can accelerate the optimization by performing block crossvalidation procedure, similar to the one described in Hardle and Linton (1994). Simulations show that the block crosvalidated Bandiwdths are close to the full data optimal bandwidths with large gains in computational speed.{p_end}

{pstd}
After the program is finished, three globals are set containig the optimal bandwidth, the kernel used for the estimation, and the variable used as smoothing variable. Commands {help vc_reg},{help vc_bsreg} and {help vc_predict} use this information as default.
{p_end}
 
 
{marker examples}{...}
{title:Examples}

** Choosing Optimal BW for Motorcycle data
{stata "webuse motorcycle, clear"}
 
{stata "vc_bw accel, vcoeff(time)" }

{stata "vc_bwalt accel, vcoeff(time) plot" }

** Compared to npregress (Available for Stata 15 or higher}

{stata "npregress kernel accel time, noderiv kernel(gaussian)"}

** Using DUI data 
{stata "webuse dui, clear"}
{stata "vc_bw citations, vcoeff(fines)"}
{stata "vc_bwalt citations, vcoeff(fines)"} 
{stata "npregress kernel citations fines, kernel(gaussian) noderiv"} 

*** Addint other explanatory variables
{stata "vc_bw citations taxes i.csize college, vcoeff(fines)"}
{stata "vc_bwalt citations taxes i.csize college, vcoeff(fines) plot"}
 
 
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
Hoti, Fabian, and Lasse Holmström. 2003. "On the estimation error in binned local linear regression."  Journal of Nonparametric Statistics 15 (4-5):625-642. 
Li, Qi, and Jeffrey Scott Racine. 2007. Nonparametric Eonometrics: Theory and Practice. New Jersey: Princeton University Press.
Li, Qi, and Jeffrey Scott Racine. 2010. "Smooth Varying-Coefficient Estimation and Inference for Qualitative and Quantitative Data."  Econometric Theory 26 (6):1607-1637.
Rios-Avila, Fernando (2019) Smooth varying coefficient models in Stata. Working paper. {browse "https://drive.google.com/open?id=1dkd-NTsiZjzl8JGImegxfuOe4FZ1YsQ4":vc_pack paper}

