{smcl}
{* *! version 3.0 3 May 2021}{...}

{hline}
help for {hi:ky_fit}{right:Stephen P. Jenkins and Fernando Rios-Avila (May 2021)}
{hline}

{vieweralsosee "postestimation" "help ky_estat"}{...}
{vieweralsosee "ky_sim" "help ky_sim"}{...}
{viewerjumpto "Syntax" "ky_fit##syntax"}{...}
{viewerjumpto "Description" "ky_fit##description"}{...}
{viewerjumpto "Options" "ky_fit##options"}{...}
{viewerjumpto "Remarks" "ky_fit##remarks"}{...}
{viewerjumpto "Examples" "ky_fit##examples"}{...}
{viewerjumpto "Authors" "ky_fit##authors"}{...}
{viewerjumpto "References" "ky_fit##references"}{...}

{title:Fitting mixture models of the Kapteyn-Ypma type to linked survey and administrative data}

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:ky_fit}
r_var s_var [cl_var]
[{help if}]
[{help in}]
[{help weights:pw fw aw iw}]
[{cmd:,}
{it:options}]


{marker options}{...}
{title:Options}

{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}

{dlgtab:Required}

{synopt:{opt r_var s_var [cl_var]}} Two variables are required for model 
estimation. r_var refers to the measure of (log) earnings from the 
administrative data. s_var refers to the measure of (log) earnings from the 
survey data. cl_var is a binary variable that identifies the 'completely 
labelled' group (observations for whom r_var and s_var are judged by the 
analyst to be sufficiently close to each other and hence also latent 'true' 
earnings to be counted as error-free) {p_end}

{synopt:} If cl_var is not declared, a variable named __ll__ is created
identifying observations for which abs(r_var {c -} s_var) <= delta {p_end}

{synopt:{opt delta(#)}} Declares the value taken by variable __ll__ when cl_var
 is not declared. Default is 0.{p_end}

{synopt:{opt model(#)}} Selects the model that is fitted. Eight different models 
are possible, corresponding to # = 1 through # = 8. The default value is # = 1 
(Basic model). See the Description for further details. {p_end}

{dlgtab:Maximization options}

{synopt:{opt from(init_specs)}} initial values for the coefficients  {p_end}
{synopt:{opt constraint(string)}} constraints by number to be applied {p_end}
{synopt:{opt technique(algorithm_spec)}}  maximization technique  {p_end}
{synopt:{opt search(srch opt)}} search options {p_end}
{synopt:{opt robust}} reports robust standard errors {p_end}
{synopt:{opt cluster(clvar)}} reports clustered standard errors {p_end}
{synopt:{opt trace}} display current parameter vector in iteration log {p_end}
{synopt:{opt diff:icult}} use a different stepping algorithm in nonconcave 
regions {p_end}

{dlgtab:Display options}

{synopt:{opt base:levels}} specifies that base levels be reported for factor 
variables and for interactions with bases that cannot be inferred from 
their component factor variables.  {p_end}
{synopt:{opt allbase:levels}}  specifies that all base levels of factor 
variables and interactions be reported. {p_end}

{dlgtab:Model specification options}

{phang} For each {cmd:model} fitted, every parameter can be modelled as a 
function of covariates using a {it:varlist}. This allows for richer 
specifications in which there is (additional) heterogeneity related to 
observed characteristics. Factor variable notation can be used to specify 
{it:varlist}. {p_end}
 
{synopt:{opt model(1)}} The following parameters can be made functions of covariates: {p_end}
{synopt:} 		mu_e({it:varlist}), ln_sig_e({it:varlist}),  {p_end}
{synopt:} 		mu_n({it:varlist}), ln_sig_n({it:varlist}),  {p_end}
{synopt:}		arho_s({it:varlist}) and lpi_s({it:varlist}) {p_end}

{synopt:{opt model(2)}} The following parameters can be made functions of covariates: {p_end} 
{synopt:} 		mu_e({it:varlist}), ln_sig_e({it:varlist}),  {p_end}
{synopt:} 		mu_n({it:varlist}), ln_sig_n({it:varlist}),  {p_end}
{synopt:} 		mu_w({it:varlist}), ln_sig_w({it:varlist}),  {p_end}
{synopt:}		arho_s({it:varlist}) and lpi_s({it:varlist}) {p_end} 

{synopt:{opt model(3)}} The following parameters can be made functions of covariates: {p_end} 
{synopt:} 		mu_e({it:varlist}), ln_sig_e({it:varlist}),  {p_end}
{synopt:} 		mu_n({it:varlist}), ln_sig_n({it:varlist}),  {p_end}
{synopt:} 		mu_t({it:varlist}), ln_sig_t({it:varlist}),  {p_end}
{synopt:}		arho_s({it:varlist}), lpi_r({it:varlist}) and lpi_s({it:varlist}) {p_end}

{synopt:{opt model(4)}} The following parameters can be made functions of covariates: {p_end} 
{synopt:} 		mu_e({it:varlist}), ln_sig_e({it:varlist}),  {p_end}
{synopt:} 		mu_n({it:varlist}), ln_sig_n({it:varlist}),  {p_end}
{synopt:} 		mu_t({it:varlist}), ln_sig_t({it:varlist}),  {p_end}
{synopt:} 		mu_w({it:varlist}), ln_sig_w({it:varlist}),  {p_end}
{synopt:}		arho_s({it:varlist}), {p_end}
{synopt:}		lpi_r({it:varlist}), lpi_s({it:varlist}) and lpi_w({it:varlist}) {p_end}

{synopt:{opt model(5)}} The following parameters can be made functions of covariates: {p_end} 
{synopt:} 		mu_e({it:varlist}), ln_sig_e({it:varlist}),  {p_end}
{synopt:} 		mu_n({it:varlist}), ln_sig_n({it:varlist}),  {p_end}
{synopt:} 		mu_t({it:varlist}), ln_sig_t({it:varlist}),  {p_end}
{synopt:} 		mu_w({it:varlist}), ln_sig_w({it:varlist}),  {p_end}
{synopt:} 		mu_v({it:varlist}), ln_sig_v({it:varlist}),  {p_end}
{synopt:}		arho_r({it:varlist}), arho_s({it:varlist}),  {p_end}
{synopt:}		lpi_r({it:varlist}), lpi_s({it:varlist}), lpi_w({it:varlist}), {p_end}
{synopt:}		and lpi_v({it:varlist}) {p_end} 

{synopt:{opt model(6)}} The following parameters can be made functions of covariates: {p_end} 
{synopt:} 		mu_e({it:varlist}), ln_sig_e({it:varlist}),  {p_end}
{synopt:} 		mu_n({it:varlist}), ln_sig_n({it:varlist}),  {p_end}
{synopt:} 		mu_t({it:varlist}), ln_sig_t({it:varlist}),  {p_end}
 {synopt:} 		mu_v({it:varlist}), ln_sig_v({it:varlist}),  {p_end}
{synopt:}		arho_r({it:varlist}), arho_s({it:varlist}),  {p_end}
{synopt:}		lpi_r({it:varlist}), lpi_s({it:varlist}), {p_end}
{synopt:}		and lpi_v({it:varlist}) {p_end} 

{synopt:{opt model(7)}} The following parameters can be made functions of covariates: {p_end} 
{synopt:} 		mu_e({it:varlist}), ln_sig_e({it:varlist}),  {p_end}
{synopt:} 		mu_n({it:varlist}), ln_sig_n({it:varlist}),  {p_end}
{synopt:} 		mu_t({it:varlist}), ln_sig_t({it:varlist}),  {p_end}
{synopt:} 		mu_w({it:varlist}), ln_sig_w({it:varlist}),  {p_end}
{synopt:}		arho_s({it:varlist}), arho_w({it:varlist}), {p_end}
{synopt:}		lpi_r({it:varlist}), lpi_s({it:varlist}) and lpi_w({it:varlist}) {p_end}

{synopt:{opt model(8)}} The following parameters can be made functions of covariates: {p_end} 
{synopt:} 		mu_e({it:varlist}), ln_sig_e({it:varlist}),  {p_end}
{synopt:} 		mu_n({it:varlist}), ln_sig_n({it:varlist}),  {p_end}
{synopt:} 		mu_t({it:varlist}), ln_sig_t({it:varlist}),  {p_end}
{synopt:} 		mu_w({it:varlist}), ln_sig_w({it:varlist}),  {p_end}
{synopt:} 		mu_v({it:varlist}), ln_sig_v({it:varlist}),  {p_end}
{synopt:}		arho_r({it:varlist}), arho_s({it:varlist}),  {p_end}
{synopt:}		arho_w({it:varlist}), {p_end}
{synopt:}		lpi_r({it:varlist}), lpi_s({it:varlist}), lpi_w({it:varlist}), {p_end}
{synopt:}		and lpi_v({it:varlist}) {p_end} 

{synoptline}
{p2colreset}{...}

{p 4 6 2}
{cmd:aweight}s, {cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are
allowed; see {help weight}.{p_end}


{marker description}{...}
{title:Description}

{pstd} {cmd:ky_fit} fits 8 finite mixture models of earnings and measurement 
errors of various types using linked survey and administrative data on earnings 
(or similar variables). The first four models were proposed by Kapteyn and 
Ypma (2007); the second four models are generalisations of the Kapteyn-Ypma 
models proposed by Jenkins and Rios-Avila (2021c). We refer here to the general 
class of models as "KY" models. Other innovations relative to Kapteyn and Ypma 
(2007) are: (i) we allow model parameters to be functions of covariates, and 
(ii) we incorporate a potential non-zero correlation betweeen the latent true 
earnings and contamination error.

{pstd} The data comprise a set of observations ('workers', i = 1, ..., N), 
for each of which there are 2 measures of (log) earnings: (a) from a 
survey (denoted s_i) and (b) from an administrative record dataset (r_i). We 
denote latent true (log) earnings by e_i. We refer to the mean of x as mu_x, and
the standard deviation (SD) of x as sig_x. The different combinations of 
error-ridden and/or error-free observations characterize latent classes. 
Latent class probabilities depend on the probabilities of the different 
types of error. 

{pstd} Each of the 8 models is a finite mixture of up to nine bivariate normal 
distributions. In {cmd:ky_fit} we label the KY models 1{c -}8, where
model 1, the Basic Model, is the simplest, and model 8, the Extended Model, is the 
most general. Next we set out out the structure of the Extended Model; the other
models are special cases of this. See Jenkins and Rios-Avila (2021b, c) for 
further details.

{pstd} The distribution of administrative earnings contains observations
that are correctly linked to survey records with probability pi_r,
as well as observations for which the linkage is incorrect ('mismatch') with
probability (1{c -}pi_r). Even if observations are correctly linked, some 
values of r_i may be subject to regression-to-the-mean (RTM) measurement error 
with probability (1{c -}pi_v). For mismatched individuals, observed 
administrative earnings are a draw from the distribution of earnings in the 
administrative data. In sum, there are three types of r_i observation:

{p 8 12 2}R1: r_i = e_i, with probability   pi_r * pi_v {p_end}
{p 8 12 2}R2: r_i = e_i + rho_r*(e_i{c -}mu_e) + v_i , with probability  pi_r * (1 {c -} pi_v) {p_end}
{p 8 12 2}R3: r_i = t_i, with probability 1 {c -} pi_r {p_end}

{pstd} The distribution of survey earnings contains three types of observation. 
First, there are observations with earnings that are reported correctly 
(i.e. without error), with probability pi_s. Second, there are observations with 
earnings reported with measurement error with the error including a RTM 
component, with probability (1{c -}pi_s)*(1{c -}pi_w). Third, there are 
observations that contain additional 'contamination' error in addition to 
RTM measurement error, with probability (1{c -}pi_s)*pi_w. In sum, there are
three types of s_i observation:

{p 8 12 2}S1: s_i = e_i, with probability pi_s {p_end}
{p 8 12 2}S2: s_i = e_i + rho_s*(e_i{c -}mu_e) + n_i
, with probability (1-pi_s)*(1-pi_w) {p_end}
{p 8 12 2}S3: s_i = e_i + rho_s*(e_i{c -}mu_e) + n_i + w_i
, with probability (1{c -}pi_s)*pi_w  {p_end}

{pstd} For model fitting, we follow KY and assume that errors are independently 
and identically distributed normal, with the exception of e_i and w_i,
for which we assume a bivariate normal distribution with correlation rho_w:

{p 8 12 2}(e_i, w_i) ~ BN([mu_e,mu_w], [(sig_e)^2,(sig_w)^2],rho_w*sig_e*sig_w) {p_end}
{p 8 12 2}n_i ~ N(mu_n, (sig_n)^2) {p_end}
{p 8 12 2}v_i ~ N(mu_v, (sig_v)^2) {p_end}
{p 8 12 2}t_i ~ N(mu_t, (sig_t)^2) {p_end}

{pstd} The Extended Model, {cmd:ky_fit}'s model 8, has nine latent classes. It
is a mixture of nine bivariate distributions representing combinations of the 
three types of administrative data observation and the three types of survey 
data observation. Class 1 contains 'completely labeled' observations, i.e. those
for which survey and administrative data earnings measures are error-free and
hence also equal to latent true earnings.

{p 8 12 2}Class 1: r_i ~ R1 and s_i ~ S1, with probability pi_r*pi_v*pi_s {p_end}
{p 8 12 2}Class 2: r_i ~ R1 and s_i ~ S2, with probability pi_r*pi_v*(1{c -}pi_s)*(1{c -}pi_w) {p_end}
{p 8 12 2}Class 3: r_i ~ R1 and s_i ~ S3, with probability pi_r*pi_v*(1{c -}pi_s)*pi_w {p_end}
{p 8 12 2}Class 4: r_i ~ R2 and s_i ~ S1, with probability pi_r*(1{c -}pi_v)*pi_s {p_end}
{p 8 12 2}Class 5: r_i ~ R2 and s_i ~ S2, with probability pi_r*(1{c -}pi_v)*(1{c -}pi_s)*(1{c -}pi_w) {p_end}
{p 8 12 2}Class 6: r_i ~ R2 and s_i ~ S3, with probability pi_r*(1{c -}pi_v)*(1{c -}pi_s)*pi_w {p_end}
{p 8 12 2}Class 7: r_i ~ R3 and s_i ~ S1, with probability (1{c -}pi_r)*pi_s {p_end}
{p 8 12 2}Class 8: r_i ~ R3 and s_i ~ S2, with probability (1{c -}pi_r)*(1{c -}pi_s)*(1{c -}pi_w) {p_end}
{p 8 12 2}Class 9: r_i ~ R3 and s_i ~ S3, with probability (1{c -}pi_r)*(1{c -}pi_s)*pi_w {p_end}

{pstd} Models 1 and 2 assume that the administrative data contain no error (i.e.
no mismatch and no measurement error). {p_end}

{pstd} Models 3, 4, and 7 assume that the administrative data contain only 
mismatch error. {p_end}

{pstd} Models 5, 6, and 8 assume that the administrative data contain mismatch 
error and RTM error. {p_end}

{pstd} Models 1, 3, and 6 assume that the survey data contain only RTM 
measurement error. {p_end}

{pstd} Models 2, 4, 5, 7 and 8 assume that the survey data contain RTM 
measurement error plus contamination error. {p_end}

{pstd} Models 7 and 8 assume the survey contamination error is correlated with 
the latent true earnings. {p_end}

{pstd} When fitting the models by maximum likelihood, we transform parameters 
other than means to ensure their estimates lie within their theoretical ranges.
That is, we ensure that all standard deviations are strictly positive; the RTM 
parameters and correlation between w_i and e_i lie between {c -}1 and 1; and 
error probabilities pi_s, pi_r, pi_w, and pi_v each lie between 0 and 1. {p_end}

{pstd}To report parameters in their natural metric, invert the transformations: {p_end}
{p 8 12 2}sig_x = exp(ln_sig_x) for x = e, n, w, t, v {p_end}
{p 8 12 2}rho_x = tanh(arho_x) for x = r, s, w {p_end}
{p 8 12 2}pi_x = logistic(lpi_x) for x = s, w, r, v {p_end}

{pstd} We provide post-estimation utilities {cmd:ky_estat} and {cmd:ky_p} to 
enable users to derive parameters (and SEs) in their natural metric. See
Jenkins and Rios-Avila (2021b, 2021c) for details.

{pstd} Users should experiment with multiple sets of initial values to check 
that models converge to a global maximum rather than some local maximum. (The 
risk of convergence to local maxima is greater for models with covariates.)
{cmd:ky_fit} fits models in a sequential fashion, beginning with simpler models
that provide starting values for more complex models. This reduces the risk of 
convergence to local maxima but does not remove it altogether.

{pstd}See Kapteyn and Ypma (2007) for details of models 1{c -}4, and estimates 
for a sample of Swedish workers aged 50+ years. For the same models, Jenkins 
and Rios-Avila (2020) provide estimates for a sample of UK workers from 
across the full range, also analyzing estimate sensitivity to the choice of the 
'completely labelled' fraction (the size of class 1). Meijer, Rohwedder, and 
Wansbeek (2012) derive hybrid earnings predictors of latent true earnings 
combining information from administrative and survey data and model estimates,
and measures of reliability. They illustrate their methods using Kapteyn and
Ypma's (2007) Full model (what we label model 4). Jenkins and Rios-Avila (2021a)
replicate Meijer, Rohwedder, and Wansbeek's analysis, and apply their methods
to estimates of model 4 derived from UK data. {p_end}

{pstd} See Jenkins and Rios-Avila (2021c) for discussion of models 5{c -}8, and 
estimates for models with and without parameters expressed as functions of 
covariates. They use UK data. Jenkins and Rios-Avila (2021b) discuss in greater 
detail model fitting using {cmd:ky_fit} and post-estimation methods, 
including the methods of Meijer, Rohwedder, and Wansbeek (2012) for models 
1{c -}8. {p_end}

{marker examples}{...}
{title:Examples}
{pstd}

{pstd} For detailed example, please see do-file "{stata doedit ky_example.do:ky_example.do}". 
{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
In addition to the results stored from {cmd:ml} (see {help maximize}), 
{cmd:ky_fit} stores the following in {cmd:e()}:{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(ic)}}Number of iterations of last model.
 Does not include iterations of intermediate models, if any.{p_end}
{synopt:{cmd:e(method_c)}}Code for estimated model. See model specification.{p_end}


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(predict)}}{cmd:ky_p}: program used to implement {cmd:predict}.{p_end}
{synopt:{cmd:e(estat_cmd)}}{cmd:ky_estat}: program used to implement post-estimation statistics {cmd:estat}.{p_end}
{synopt:{cmd:e(method)}}Description of model specification.{p_end}
{synopt:{cmd:e(cmd)}}{cmd:ky_fit}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}names of dependent variables, i.e. the administrative 
and survey log earnings variables, and completely-labeled group identifier{p_end}
{synopt:{cmd:e(user)}}name of likelihood-evaluator program. ky_ll_# with # = 
1, 2, ..., 8.{p_end}

{marker references}{...}
{title:References}

{pstd}Jenkins, S. P. and Rios-Avila, F. (2020). 
Measurement errors in survey and administrative data on employment earnings: 
sensitivity to the fraction assumed to have error-free earnings’, 
{it: Economics Letters}, 192: 109253. {browse "https://doi.org/10.1016/j.econlet.2020.109253"}

{pstd}Jenkins, S. P. and Rios-Avila, F. (2021a). 
Measurement error in earnings data: replication of 
Meijer, Rohwedder, and Wansbeek’s mixture model
approach to combining survey and register data, 
{it: Journal of Applied Econometrics}, online first. 
{browse "https://doi.org/10.1002/jae.2811"}

{pstd}Jenkins, S. P. and Rios-Avila, F. (2021b). 
Finite mixture models for linked survey and administrative data: estimation and 
post-estimation. IZA Discussion Paper, forthcoming. 
{browse "https://www.iza.org/publications/dp"}
For submission to {it:The Stata Journal}.

{pstd}Jenkins, S. P. and Rios-Avila, F. (2021c). 
Reconciling reports: modelling employment earnings and measurement errors 
using linked survey and administrative data.
IZA Discussion Paper, forthcoming. {browse "https://www.iza.org/publications/dp"}

{pstd}Kapteyn, A. and Ypma, Y. A. (2007). Measurement error and misclassification: a 
comparison of survey and administrative data. 
{it: Journal of Labor Economics} 25 (3): 513{c -}551.
{browse "https://www.journals.uchicago.edu/doi/abs/10.1086/513298"}

{pstd}Meijer, E., Rohwedder, S. and Wansbeek T. (2012). Measurement error in 
earnings data: using a mixture model approach to combine survey and register data. 
{it:Journal of Business & Economic Statistics} 30 (2): 191{c -}201.
{browse "https://www.tandfonline.com/doi/abs/10.1198/jbes.2011.08166"}


{marker authors}{...}
{title:Authors}


{pstd}
Stephen P. Jenkins {break}
Department of Social Policy{break}
London School of Economics and Political Science {break}
Houghton Street, London WC2A 2AE, UK{break}
Email: s.jenkins@lse.ac.uk

{pstd}
Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Annandale-on-Hudson, NY 12504-5000, USA{break}
Email: friosavi@levy.org


{marker alsosee}{...}
{title:Also see}

{p 4 13 2}
{help ky_estat} if installed; {help ky_sim} if installed.


