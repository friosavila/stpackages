{smcl}
{* *! version 2.0.0  July 2019 Fernando Rios Avila}{...}
{vieweralsosee "[R] vc_bw" "help vc_bw"}{...}
{vieweralsosee "[R] vc_bwalt" "help vc_bw"}{...}
{vieweralsosee "[R] vc_reg" "help vc_reg"}{...}
{vieweralsosee "[R] vc_preg" "help vc_reg"}{...}
{vieweralsosee "[R] vc_bsreg" "help vc_reg"}{...}
{vieweralsosee "[R] vc_graph" "help vc_graph"}{...}
{vieweralsosee "[R] vc_predict" "help vc_predict"}{...}
{vieweralsosee "[R] cv_regress" "help cv_regress"}{...}

{title:Title}

{phang}
{bf: vc_graph} {hline 2} Command for plotting coefficients obtained with vc_reg or vc_bsreg
 

{marker syntax}{...}
{title: Syntax}

Smooth Varying Coefficient model: Coefficient Plots
{p 8 17 2}
{cmdab:vc_graph}
[{varlist}]
[{cmd:,}   {it:options}]
 
{pstd}
NOTE: Varlist may contain any or all of the variables used for the estimation of the Varying coefficient model in vc_reg or vc_bsreg. {p_end}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main options}
{synopt:{opth ci(#)}} Indicates the level of the confidence interval in percentage. The default is 95% normal based confidence interval {p_end}
{synopt:{opt constant}} Use this option when the interest its on plotting the constant. {p_end}
{synopt:{opt delta}} Use this option when the interest is on plotting rate of change of the coefficients, respect to the smoothing variable. Can be used in combination with constant.
Use this option when the interest its on plotting rate of change of the coefficients with respect to the smoothing variable. For any given model with the form
y=a0(z)+b0(z)*X+a1(z)*delta+b1(z)*X*delta, where delta=(z-z0), this option will plot the coefficients b1. The default is to plot the coefficients b0. If used in combination with
constant, it will plot the coefficient a1(z) as well.  {p_end}
{synopt:{opth xvar(varname)}} Request to use an alternative variable to create the coefficient plots. This new variable should be a monotonic transformation of the original smoothing variable h=h(z). 
For example, one can use lz=log(z) to estimate the SVCM, but decide to use Z to plot the coefficients. In this case one would use xvar(z) {p_end}
{synopt:{opt graph(str)}} Provides a stub to be used as prefix for the created plots, which are saved in memory. Default its "grph". Graphs are named consecutively {p_end}
{synopt:{opt rarea}} Request using "area" graph for the estimation of the confidence intervals. Default its to use rcap. {p_end}
{synopt:{opt ci_off}} Request to plot only the point estimates but not the confidence intervals. {p_end}
{synopt:{opt pci}} When using {help vc_bsreg}, it is possible to request to plot the percentile based confidence intervals rather than normal based. Cannot be used incombination with ci(#) {p_end}
{synopt:{opt addgraph(str)}} It requests to add a plot to the generated graph. For example, vc_graph x1, addplot(scatter g x1) will create a twoway graph that includes the "scatter g x1" {p_end} 
{synoptline}
{p2colreset}{...}
 

{marker description}{...}
{title:Description}

{pstd}
{cmd:vc_graph} is a command used to plot the coefficients of the SVCM, using all the points of reference used in vc_reg, vc_preg or vc_bsreg. You can select to 
plot all the coefficients estimated of the model (i.e b(z)), or the rate of change of those coefficients respect to z (ie db(z)/dz). 
 {p_end}
 
{pstd}
The module also allows you to plot the figures using a variable different from the original vcoeff variable. The alternative variable should be a monotonic transformation from the original variable.
For example, one may want to estimate the varying coefficients with respect to log(z), but plot the figures with respect to z. {p_end}
{pstd}
If B(z0) its the smooth coefficient around the point z0, and h=h(z) is a monotonic transformation of z, then  B(h0) is also the smooth coefficient around the point h0. This can 
be used to implement an strategy alternative to the use of adaptive bandwidth, for segments where the distribution of Z is sparse. {p_end}
  
{pstd}
2 or more points of references needed to be estimated to use vc_graph. {p_end}
{pstd}
Details on the command can be found at Rios-Avila (2019)

{marker examples}{...}
{title:Examples}

* Estimating the SVCM for acceleration as a function of time
* Defining BW
{stata "webuse motorcycle, clear"}
{stata "vc_bw accel, vcoeff(time)"}
* Estimating the SVCoefficients
{stata "vc_reg accel, vcoeff(time)  klist( 2.4/57.6) robust"}
{stata "vc_graph , constant"}
{stata "vc_graph , delta constant"}
{stata "gen lntime=ln(time)"}
{stata "gen sqtime=time^2"}
{stata "vc_graph , delta constant xvar(sqtime)"}
{stata "vc_graph , delta constant xvar(lntime)"}
* Estimating SVCM model for DUI 
{stata "webuse dui, clear"}
{stata "vc_bw citations i.csize college taxes, vcoeff( fines )"}
{stata "vc_reg citations i.csize college taxes, vcoeff( fines ) bw(.7398) klist(7.4(.2)12) robust"}
{stata "vc_graph i.csize college taxes,  constant" }
{stata "vc_graph i.csize college taxes,  delta"}

*Normal transformation for Fines.
{stata "sum fines"}
{stata "gen Fn=normal((fines-r(mean))/r(sd))"}
* Graph agains the normal percentile
{stata "vc_graph i.csize college taxes,  constant  xvar(Fn) " }
{stata "vc_graph i.csize college taxes,  delta xvar(Fn)" }

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
Rios-Avila, Fernando (2019) Smooth varying coefficient models in Stata. Working paper.
