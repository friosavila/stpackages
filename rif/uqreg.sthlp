{smcl}
{* *! version 1.0 Fernando Rios-Avila July 2019}{...}
{cmd:help uqreg}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{cmd:uqreg} {hline 2}}Unconditional quantile regression estimator{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 13 2}
{cmd:uqreg} {depvar} [{indepvars}] {ifin} {weight}{cmd:,} {opt q(#p)} 
{opt method(str)}  [{opt bw(#)} {opt kernel(kernel)} {it:method_options}
{cmdab:n:oisily}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent :* {opt q(#p)}}specify the {it:#p}th unconditional quantile to be estimated{p_end}
{p2coldent :* {opt method(str)}}indicate which method will be used to estimate
the unconditional quantile regression (UQR); see examples below{p_end}
{synopt :{opt bw(#)} {opt kernel(kernel)}}specify the bandwidth function, kernel
function, or both that will be used to estimate the density function; defaults are
{cmd:kernel(gaussian)} and Silverman plugin bandwidth{p_end}
{synopt :{it:method_options}}specify any options appropriate with
the method selected; see examples below{p_end}
{synopt :{cmd:noisily}}display preliminary steps{p_end}
{synoptline}
{pstd}
* {cmd:q()} and {cmd:method()} are required.{p_end}
{pstd}
{cmd:aweight}s, {cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s can be used
depending on the methods chosen; see {help weight}.{p_end}


{title:Description}

{pstd}
{cmd:uqreg} can be used exclusively for the estimation of UQR, which are the
most popular application of recentered influence function (RIF) regressions.

{pstd}
As described in Firpo, Fortin, and Lemieux (2009), because the only element of
the quantile RIF that varies across observations is a binary variable that
indicates if an observation is above or below any given quantile, any linear
or binomial model can be used to estimate UQR.

{pstd}
In the case of RIF ordinary least squares, as performed when using 
{helpb rifhdreg}, one is essentially using a linear probability model to model
this binary variable, whereas a binomial model may be more appropriate.{p_end}

{pstd}
While in practice, a linear probability model can perform well for the
estimation of average treatment effects, one can use {cmd:uqreg} to compare
the results with other model specifications as long as average marginal
effects can be estimated using the {helpb margins} command.{p_end}

{pstd}
By default, the command output provides only point estimates of average
treatment effects, which in the framework of UQR can be interpreted as
unconditional partial effects.  Standard errors can be estimated using
resampling methods with the {helpb bootstrap} prefix.


{title:Examples}

{phang2}
{bf:. {stata "use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta"}}{p_end}

{pstd}
Verify that {cmd:reghdfe} is installed and compiled in your computer.  If
already installed, this step can be skipped.{p_end}
{phang2}
{bf:. {stata ssc install reghdfe, replace}}{p_end}
{phang2}
{bf:. {stata reghdfe, compile}}{p_end}
{phang2}
{bf:. {stata generate wage=exp(lnwage)}}{p_end}
	
{pstd}
RIF regression for the 10th, 50th, and 90th quantiles.

{pstd}
Method: {cmd:regress}{p_end}
{phang2}
{bf:. {stata uqreg lnwage educ exper tenure, q(10) method(regress)}}{p_end}
{phang2}
{bf:. {stata uqreg lnwage educ exper tenure, q(50) method(regress)}}{p_end}
{phang2}
{bf:. {stata uqreg lnwage educ exper tenure, q(90) method(regress)}}{p_end}

{pstd}
Method: {cmd:reghdfe}{p_end}
{phang2}
{bf:. {stata uqreg lnwage educ exper tenure, q(10) method(reghdfe) abs(age)}}{p_end}
{phang2}
{bf:. {stata uqreg lnwage educ exper tenure, q(50) method(reghdfe) abs(age)}}{p_end}
{phang2}
{bf:. {stata uqreg lnwage educ exper tenure, q(90) method(reghdfe) abs(age)}}{p_end}

{pstd}
Method: {cmd:logit}{p_end}
{phang2}
{bf:. {stata uqreg lnwage educ exper tenure, q(10) method(logit)}}{p_end}
{phang2}
{bf:. {stata uqreg lnwage educ exper tenure, q(50) method(logit)}}{p_end}
{phang2}
{bf:. {stata uqreg lnwage educ exper tenure, q(90) method(logit)}}{p_end}	

{pstd}
Method: {cmd:probit}{p_end}
{phang2}
{bf:. {stata uqreg lnwage educ exper tenure, q(10) method(probit)}}{p_end}
{phang2}
{bf:. {stata uqreg lnwage educ exper tenure, q(50) method(probit)}}{p_end}
{phang2}
{bf:. {stata uqreg lnwage educ exper tenure, q(90) method(probit)}}{p_end}	

{pstd}
Method: {cmd:cloglog}{p_end}
{phang2}
{bf:. {stata uqreg lnwage educ exper tenure, q(10) method(cloglog)}}{p_end}
{phang2}
{bf:. {stata uqreg lnwage educ exper tenure, q(50) method(cloglog)}}{p_end}
{phang2}
{bf:. {stata uqreg lnwage educ exper tenure, q(90) method(cloglog)}}{p_end}	

{pstd}
Method: {cmd:hetprobit}{p_end}
{phang2}
{bf:. {stata uqreg lnwage educ exper tenure, q(10) method(hetprobit)   het(educ exper tenure)}}{p_end}
{phang2}
{bf:. {stata uqreg lnwage educ exper tenure, q(50) method(hetprobit)   het(educ exper tenure)}}{p_end}
{phang2}
{bf:. {stata uqreg lnwage educ exper tenure, q(90) method(hetprobit)   het(educ exper tenure)}}{p_end}


{title:References}

{phang}
Firpo, S., N. M. Fortin, and T. Lemieux. 2009. Unconditional quantile
regressions. {it:Econometrica} 77: 953-973.
{browse "https://doi.org/10.3982/ECTA6822"}.

{phang}
Rios-Avila, F. 2020. Recentered influence functions (RIFs) in Stata: RIF regression and RIF decomposition.
Stata Journal, 20(1), 51-94. {browse "https://doi.org/10.1177/1536867X20909690"}. 


{marker Acknowledgments}{...}
{title:Acknowledgments}

{pstd}
This is a standalone command, and it does not depend on {cmd:rifvar()}.
An intuitive description of RIF regressions is provided in Rios-Avila (2019).

{pstd}
All errors are my own.


{marker Author}{...}
{title:Author}

{pstd}
Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org


{title:Also see}

{p 4 14 2}


{p 7 14 2}
Help:  {helpb rifhdreg}, {helpb oaxaca_rif}, {helpb rifvar:rifvar()},
{helpb hvar()}, {helpb rifreg}, {helpb rifsureg} (if installed){p_end}
