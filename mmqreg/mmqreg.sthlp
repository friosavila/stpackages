{smcl}
{* *! version 2.0 June 2022}{...}
{cmd:help mmqreg} 

{hline}

{title:Title}

{p2colset 8 18 19 2}{...}
{p2col :{cmd: mmqreg} {hline 2}} MM-Quantile regression {p_end}
{p2colreset}{...}


{title:Syntax}

{phang}

{p 8 13 2}
{cmd:mmqreg} {depvar} {indepvars} {ifin} [aw] [{cmd:,} {it:options}]


{synoptset 25 tabbed}{...}
{marker options}{...}
{synopthdr :options}
{synoptline}

{synopt :{opt q:uantile(#[#[# ...]])}}estimate {it:#} quantile, where 0<#q<100; default is {cmd:quantile(50)}. One can simulatenously estimate 
any number of quantiles given by the numlist. {p_end}

{synopt:{opt abs:orb(varlist)}}specifies the variable(s) that will be absorbed in the estimation. Default is to absorb no variables. {p_end}

{synopt :{opt denopt(denmethod bwidth)}}can be used to specify the method for the density and bandwith estimation. see {it:{help qreg##qreg_method:denmethod}} 
and {it:{help qreg##qreg_bwidth:bwidth}}. The default are {cmd:bwmethod}="hsheather" and {cmd:denmethod}="fitted" {p_end}

{synopt :{opt dfadj}}request using degrees of freedom adjustment equal to k+absc, where k is the number of variables, including constant, in the model , and 
absc the number of absorbed coefficients. {p_end}

{synopt :{opt nowarning}}request showing no warning when the scale function predicts negative values.{p_end}

{synopt :{opt nols}}request not to show the location or scale coefficients{p_end}

{synopt :{robust}}request reporting standard errors that are robust to heteroskedasticty, based on the White Huber estimator/sandwidth estimator. The default is to report standard errors under the assumption of correctly specified Scale model{p_end}

{synopt :{cluster(cvar)}}request reporting clustered standard errors. Only accepts one way clustered cvar{p_end}

{synoptline}
{p2colreset}{...}
{phang} {it: indepvars} may contain factor variables; see {help fvvarlist}.{p_end}
{phang}{cmd:mmqreg} does allows for {cmd:aweight}.{p_end}


{title:Description}

{pstd}
{cmd:mmqreg} estimates quantile regressions using the method of moments as described in Machado and Santos Silva (2019), and expanding the methodology to allow for multiple fixed effects. {p_end}
{pstd} In contrast with {help xtqreg}, {cmd:mmqreg} adds three features to the estimation of this type of models:{p_end}
{pstd} 1. It allows the estimation of the Location-Scale quantile regressions when there are no fixed effects. {p_end}
{pstd} 2. Using the command {cmd:hdfe} it allows the estimation of LS quantile regression absorbing multiple fix effects {p_end}
{pstd} 3. It reports the estimation of various quantiles jointly, which facilitates testing of coefficients across quantiles, using resampling 
methods like Bootstrap. (see {help bootstrap}), or based on analytical standard errors. {p_end}
{pstd} Also, in contrast with {help xtqreg}, standard errors for quantiles, location, and scale effects, can be 
estimated adjusting for the degrees of freedom.{p_end}
{pstd} Furthermore, because this is a GMM estimator, -mmqreg- also provides 3 options for standard errors, the default which is the same as -xtqreg-, robust standard errors, and clustered standard errors.

{title:Remarks}

{pstd}
As the command stands, {cmd: mmqreg} provides the asymptotic approximations for the correlations of coefficients across quantiles, and also provides two different standard error options. Their properties derive from it being a GMM estimator. However, you may also wish to consider resampling methods.

{pstd} I want to thank to J.M.C. Santos Silva for claryfing some of the details regarding the estimation methodology. {p_end}
{pstd} All errors are my own.

{title:Examples}

    {hline}
{pstd}Setup{p_end}
{phang2}
{stata webuse nlswork, clear}{p_end}

{pstd}You will also need this command to be installed{p_end}
{phang2}{stata ssc install xtqreg}{p_end}
{phang2}{stata ssc install ftools}{p_end}
{phang2}{stata ssc install hdfe}{p_end}

{pstd}Median regression with fixed effects for idcode. Using {cmd:xtqreg} {p_end}
{phang2}
{stata xtqreg ln_w   age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp tenure c.tenure#c.tenure   not_smsa south, i(idcode) ls}{p_end}

{pstd}Median regression with fixed effects for idcode. Using {cmd:mmqreg} {p_end}
{phang2}
{stata mmqreg ln_w   age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp tenure c.tenure#c.tenure   not_smsa south, abs(idcode) }{p_end}

{pstd}q25 and q75 regression with fixed effects for idcode. Using {cmd:mmqreg} {p_end}
{phang2}
{stata mmqreg ln_w  age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp tenure c.tenure#c.tenure   not_smsa south, abs(idcode) q(25 75)}{p_end}

{pstd}Comparing mmqreg with and without fixed effects.{p_end}
{phang2}
{stata "use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta, clear"} {p_end}

{phang2}
{stata mmqreg lnwage i.female educ exper tenure i.isco, q(25 75)} {p_end}
{phang2}
{stata mmqreg lnwage i.female educ exper tenure  , q(25 75) abs(isco) }{p_end}
{phang2}
{stata mmqreg lnwage  educ exper tenure  , q(25 75) abs(isco female) }{p_end}

    {hline}
 
{title:References}

{phang} Machado, J.A.F. and Santos Silva, J.M.C. (2019), 
{browse "https://doi.org/10.1016/j.jeconom.2019.04.009":Quantiles via Moments}, 
{it: Journal of Econometrics}, 213(1), pp. 145-173.{p_end} 

{phang} Rios-Avila, Fernando (2020), 
Extending Quantile regressions via Method of Moments using multiple fixed effects. MIMEO
{p_end} 

{title:Also see}

{psee}
{help xtqreg}, {help hdfe}, {help ftools}

