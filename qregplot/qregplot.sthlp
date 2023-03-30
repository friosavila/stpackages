{smcl}
{* 24 Feb 2022}
{hline}
help for {cmd:qregplot}{right:Fernando Rios Avila}
{hline}

{title:Module for plotting coefficients of a {cmd:Quantile Regressions}}

{p 8 21 2}{cmdab:qregplot}
[{it:varlist}]
[{cmd:,}
    {cmdab:q:uantiles}{cmd:(numlist{cmd:)}}
    {cmd:cons}
    {cmd:ols}
    {cmd:olsopt(}{it:regress options}{cmd:)}
    {cmdab:seed}{cmd:(}{it:seed number}{cmd:)}
    {cmdab:raopt}{cmd:(}{it:rarea options}{cmd:)}
	{cmdab:lnopt}{cmd:(}{it:line options}{cmd:)}
	{cmdab:twopt}{cmd:(}{it:twoway options}{cmd:)}
	{cmdab:estore}{cmd:(}{it:name} {cmd:)}
	{cmdab:from}{cmd:(}{it:name}{cmd:)}
	{cmdab:label}
	{cmdab:labelopt(}{it:label options}{cmd:)}
	{cmdab:mtitles(}{it:titles}{cmd:)}
	{cmdab:grcopt}{cmd:(}{it:graph combine options}{cmd:)}
	{cmd:graph_combine_options}
	]

{title:Description}

{phang}{cmd:qregplot} graphs the coefficients of a quantile regression produces by various 
programs that produce quantile coefficients including, qreg, bsqreg, sqreg,
mmqreg, smqreg, sivqr, and rifhdreg (for unconditional quantiles).{p_end}

{phang}{cmd:qregplot} Works in a similar way as {help grqreg}, but provides added options
to give the user more control on the creation of the requested figures, also allowing 
for the use of factor notation. {p_end}

{phang}The command works as follows.{p_end}

{p 8 6} Step 1. It gathers all the information of a previously
estimated model (for example via {help qreg}). This information is used as template
for the estimation of quantile regression models across the distribution. {p_end}

{p 8 6} Step 2. Using the information from Step 1, {cmd:qregplot} estimates {cmd:N} 
quantile regressions following the same specification as the original model.
One can select which quantiles will be used for the estimation of this models.  {p_end}

{p 8 6} Step 3. Once all coefficients, and CI are stored, {cmd:qregplot} plots all requested coefficients
using a {cmd:twoway rarea} for ploting CI, combined with {cmd:twoway line} for plotting the point estimates. 
Each figure is stored temporary as a graph in memory. {p_end}

{p 8 6} Step 3b. If requested, OLS coefficients and CI are added to each figure in step 3. {p_end}

{p 8 6} Step 4. If more than 1 variable is requested for plotting, 
all plots from Step 3 are combined using {cmd: graph combine}.{p_end}

{phang} The only exception to this process is {help sqreg}. When used after this
command, coefficients are collected from sqreg output, rather than reestimated. {p_end}

{phang} Standard errors are estimated based on the original command specifications. For example. If 
{cmd: qreg} was first estimated using {cmd:vce(robust)}, {cmd:qregplot} will use 
the same type of standard errors for plotting {p_end}

{phang} Since the most time consumming part of quantile regressions is the estimation 
of the qregressions themselves, specially if using boostrap standard errors, 
one can request {cmd:qregplot} to store all coefficients and CI in memory using the option 
estore({it:name}). The advantage of doing this is that plots can be created using the stored coefficients
directly. {p_end}

{phang} In all cases, CI are plotted automatically using the same level of confidence as the original 
estimation specification (typically 95%) {p_end}

{synoptset 30 tabbed}{...}

{marker {cmd:Options}}{...}
{synopthdr :{cmd:Options}}
{synoptline}

{synopt:{opt varlist}} Select variables that will be graphed. If none is provided, 
all coefficients except the intercept, will be plotted. This accepts factor notation. {p_end}

{synopt:{cmdab:q:uantiles(numlist)}} Indicates which quantiles to use for plotting. One can use
any {help numlist} to do so. The default is quantile(10(5)90). This is ignored after {cmd: sqreg}. {p_end}
  
{synopt:{cmdab:cons}} Requests the intercept to be plotted.{p_end}

{synopt:{cmdab:ols}} Requests to include in the graph the coefficients and CI for the standard
ols model (via {help regress}).{p_end}

{synopt:{cmdab:olsopt(regress options)}} Used to provide additional information to estimate the model
via {help regress}. For example, {cmd:olsopt(robust)} request OLS regression to 
estimate the model using robust standard errors.{p_end}

{synopt:{cmdab:seed}(seed number)} If one used {help bsqreg}, seed can be used to set the same seed
number for each quantile replication. {p_end}

{synopt:{cmdab:raopt}{cmd:(}{it:rarea options}{cmd:)}} 
Provides options to be used in the "twoway rarea" part of the graph. This controls 
the aspects of the Confidence intervals.
The default options are pstyle(p1) fintensity(30) lwidth(none)
{p_end}

{synopt:{cmdab:lnopt}{cmd:(}{it:line options}{cmd:)}} 
Provides options to be used in the "twoway line" part of the graph. This controls 
aspects of the point estimates. 
The default options are pstyle(p1) lwidth(0.3)({p_end}

{synopt:{cmdab:twopt}{cmd:(}{it:twoway options}{cmd:)}} 
Provides options to be used on the "twoway" graph. This controls
aspects of the twoway graph, after combining rarea and line. 
The default options is to set graph and plot region margins to vsmall ({p_end}

{synopt:{cmdab:grcopt}{cmd:(}{it:graph combine options}{cmd:)}} 
Provides options to be used along with "graph combine". This controls 
aspects for the combined graph of all coefficients. {p_end}

{synopt:{it:graph combine options}}It is no longer needed to provide Graph combine options with grcopt(). One can simply add any of those options directly in the command line. This controls 
aspects for the combined graph of all coefficients. However, if you are plotting a single coefficient, it will affect the {help twoway options} {p_end}

{synopt:{cmdab:estore}{cmd:(}{it:name}{cmd:)}} Request to save all estimated coefficients 
and CI in e(). This will be stored in memory under {it: name }. This could be used later on
for plotting coefficients only, without re-estimating the quantile regressions. One could also Save this results in a file as a ster file. See {help estimates save}{p_end}

{synopt:{cmdab:from}{cmd:(}{it:name}{cmd:)}} Request to plot quantile coefficients using
the information previously stored in e(). 
When this option is used, one graph aspects options can be used. {p_end}
 
{synopt:{cmdab:label}} Request the use variable (or value) labels to be used as titles
for each individual quantile plot. The default option is to use the variable name. {p_end}
 
{synopt:{cmdab:labelopt(}options{cmd:)}} Provides additional information to handle "long"
variable labels. The two options are: {p_end} 
{synopt:} - {cmd:lines(#L)} Request to break a label into #L lines. {p_end} 
{synopt:} - {cmd:maxlength(#k)} Request to break a label into lines of maxlength #k. 
This be superseeded by lines if #k is too small to break a label into #L lines. {p_end} 
{synopt:{cmd:mtitles(titles)}}One also has the option of providing titles for each sub-graph. They should be written within double quotes. For exaple mtitles("first" "second") will use 'first' and 'second' as title graphs. See examples for details.{p_end} 

{marker Examples} 
{title:Examples}

{pstd}
Setup. {p_end}
{phang2}
{bf: {stata webuse womenwk}}

{pstd}Simple Conditional quantile regression using {help qreg}. {p_end}
{phang2}
{bf: {stata qreg wage age education i.married children i.county}}

{pstd} Ploting all coefficients of interest, for quantiles 5 95 in 2.5 increments. Storing coefficients in qp {p_end}
{phang2}
{bf: {stata qregplot age education i.married children, q(5(2.5)95) estore(qp)}}

{pstd} Same as above but adding OLS coefficients and CI {p_end}
{phang2}
{bf: {stata qregplot age education i.married children, q(5(2.5)95) ols }}

{pstd} Changing the look for the CI across quantiles {p_end}
{phang2}
{bf: {stata qregplot age education i.married children, q(5(2.5)95) ols raopt( color(black%5))}}

{pstd} Same as above, but ploting in only 1 column for the combined graph {p_end}
{phang2}
{bf: {stata qregplot age education i.married children, q(5(2.5)95) ols raopt( color(black%5)) col(1) }}

{pstd} Same as above, but changing the aspect of the graph for better readability {p_end}
{phang2}
{bf: {stata qregplot age education i.married children, q(5(2.5)95) ols  col(1) ysize(20) xsize(8) }}

{pstd} Using only 3 variables and use results from qp (see above) {p_end}
{phang2}{bf: {stata qregplot age education  children, from(qp) }}

{pstd} Same as above but using labels as titles {p_end}
{phang2}{bf: {stata qregplot age education  children, from(qp) label }}

{pstd} Same as above but using own titles for figures 1 and 2 {p_end}
{phang2}{bf: {stata qregplot age education  children, from(qp) label mtitles("Age in years since 1980" "Years of education")}}

{pstd} Same as above but using own titles for figures 1 and 2, written in two lines {p_end}
{phang2}{bf: {stata qregplot age education  children, from(qp) label mtitles("Age in years since 1980 I want this to be long" "Years of education, including Highschool and college") labelopt(lines(2)) }}  

{pstd} Using alternative estimator, bsqreg {p_end}
{phang2}
{bf: {stata bsqreg wage age education i.married children i.county}} {p_end}
{phang2}
{bf: {stata qregplot age education i.married children, q(5(5)95)  }}

{pstd} Using alternative estimator, qrprocess (if installed) {p_end}
{phang2}
{bf: {stata qrprocess wage age education i.married children i.county}} {p_end}
{phang2}
{bf: {stata qregplot age education i.married children, q(5(5)95)  }}

{pstd} Using alternative estimator, qreg2 (if installed) {p_end}
{phang2}
{bf: {stata qreg2 wage age education i.married children i.county}} {p_end}
{phang2}
{bf: {stata qregplot age education i.married children, q(5(5)95)  }}

{pstd} Using alternative estimator, ivqreg2 (if installed) {p_end}
{phang2}
{bf: {stata ivqreg2 wage age education married  , inst(age education married   children)}} {p_end}
{phang2}
{bf: {stata qregplot age education married , q(5(5)95)  }}

{pstd} Using alternative estimator, xtqreg (if installed) {p_end}
{phang2}
{bf: {stata xtqreg wage age education i.married children , i(county) }} {p_end}
{phang2}
{bf: {stata qregplot age education i.married children, q(5(5)95)  }}

{pstd} Using alternative estimator, mmqreg (if installed) {p_end}
{phang2}
{bf: {stata mmqreg wage age education i.married children }} {p_end}
{phang2}
{bf: {stata qregplot age education i.married children, q(5(5)95)  }}

{pstd} Using alternative estimator, sqreg {p_end}
{phang2}
{bf: {stata sqreg wage age education i.married children i.county, q(10 25 50 75 90)}} {p_end}
{phang2}
{bf: {stata qregplot age education i.married children,   }}

{pstd} Using alternative estimator, rifhdreg {p_end}
{phang2}
{bf: {stata rifhdreg wage age education i.married children i.county, rif(q(50)) }} {p_end}
{phang2}
{bf: {stata qregplot age education i.married children, q(5(5)95)  }}

{pstd} Using alternative estimator, sivqr {p_end}
{phang2}
{bf: {stata sivqr  wage age education married children , q(50) }} {p_end}
{phang2}
{bf: {stata qregplot age education married children, q(5(5)95)  }}


{pstd} Storing regressions information in memory {p_end}
{phang2}
{bf: {stata qreg wage age education i.married children i.county, q(50) }} {p_end}
{phang2}
{bf: {stata qregplot age education i.married children, q(5(5)95) estore(qreg_1) }}

{pstd} Ploting coefficients from stored estimations {p_end}
{phang2}
{bf: {stata qregplot age education i.married children, from(qreg_1) }}

{pstd} Same as above but using labels for titles {p_end}
{phang2}
{bf: {stata qregplot age education i.married children, from(qreg_1) label }}

{marker Aknowledgements}{...}
{title:Aknowledgements}

{p 4} This program was created as a companion for {help rifhdreg}, for making it easier
to plot coefficients across different quantiles, but also as an answer to a regular question
regarding plotting dummies with {help grqreg} when using factor notation. {p_end}

{p 4} This program requires ftools, for expanding varlists with factor notation.{p_end}

{p}The usual disclaimer applies.{p_end}

{p}And if interested or curious about smqreg, shoot me an email.{p_end}

{marker Author}{...}
{title:Author}

{pstd}Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Blithewood-Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org


{title:Also see}

{p 4 13 2}help for {help qreg}, {help qreg2}, {help ivqreg2}, {help qrprocess}, 
{help bsqreg}, {help sqreg}, {help rifhdreg}, {help xtqreg}, {help mmqreg}, {help sivqr} {p_end}
