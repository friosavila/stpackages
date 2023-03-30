{smcl}
{* *! version 3.0 3 May 2021}{...}

{hline}
help for {hi:ky_estat}{right:Stephen P. Jenkins and Fernando Rios-Avila (May 2021)}
{hline}

{viewerjumpto "Syntax" "ky_estat##syntax"}{...}
{viewerjumpto "Description" "ky_estat##description"}{...}
{viewerjumpto "Options" "ky_estat##options"}{...}
{viewerjumpto "Remarks" "ky_estat##remarks"}{...}
{viewerjumpto "Examples" "ky_estat##examples"}{...}
{viewerjumpto "Authors" "ky_estat##authors"}{...}
{viewerjumpto "References" "ky_estat##references"}{...}

{title:Post-estimation tools for ky_fit}

{phang}Post-estimation tools for Kapteyn-Ypma-type (KY) models of earnings and measurement error fitted using {cmd:ky_fit}


{marker syntax}{...}
{title:Syntax}
{p 8 17 2}

{phang}{cmdab:estat} [option]

{dlgtab:estat options}

{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt pr_t}}Provides unconditional probabilities of errors (pi_r, pi_s, 
pi_w, pi_v). If any error probability is modeled as a function of 
covariates, average predicted probabilities are reported.  {p_end}
{synopt:{opt pr_j}}Provides unconditional probabilities of belonging to 
latent class (mixture group) {it:j} = 1, 2,..., 9. If any error 
probability is modeled as a function of covariates, average predicted 
probabilities are reported. {p_end}
{synopt:{opt pr_sr}}Provides unconditional probabilities of data type 
(pi_s1, pi_s2, pi_s3, pi_r1, pi_r2, pi_r3). If any error probability is modeled 
as a function of covariates, average predicted probabilities are reported.  {p_end}
{synopt:{opt pr_all}}Reports all unconditional probabilities. If any error 
probability is modeled as a function of covariates, average predicted 
probabilities are reported.  {p_end}
{synopt:{opt rel:iability}, [sim reps(#) seed(#)]}Provides a full report of 
the unconditional error probabilities (pi_r, pi_s, pi_w, pi_v), probabilities by 
data type (pi_s1, pi_s2, pi_s3, pi_r1, pi_r2, pi_r3), probabilities of 
latent class membership (pi_1, ..., pi_9), as well as means and standard 
deviations of latent 'true' income (e_i) and all the errors in the model 
(n_i, w_i, v_i, t_i). The option also provides two reliability statistics. {p_end}
{synopt:}Rel1 = cov(e,x)/var(x), and Rel2 = cov(e,x)^2/(var(x)var(e)), where 
"e" denotes the latent measure of 'true' log earnings and 'x' denotes the data 
source (adminstrative 'r' or survey 's') {p_end}
{synopt:}If any error probability is modeled as a function of covariates, 
{cmd: reliablity} produces simulation-based reliability statistics. Use option 
{cmd:reps()} to choose the number of replications used for the simulations 
(default is 50), and option {cmd:seed(#)} to define a seed for replication 
purposes. {p_end}
{synopt:}Simulation-based reliability statistics can also be requested directly 
using the option {cmd: sim} {p_end}
{synopt:{opt xirel}, [reps(#) seed(#)]}Provides a report for the Reliability 
statistics, MSE, E(bias) and Var(bias) for all potential estimations for 
e_i(hat), via simulation. (See option {cmd:predict newvar, star}.)
{cmd:reps()} can be used to define the number of replications (default is 50), 
and {cmd:seed()} for replication purposes.{p_end}
 
{pstd} When used after {cmd:ky_fit}, {cmd:ky_estat} automatically 
identifies the previously-fitted model, and reports the appropiate statistics. {p_end}

{dlgtab:predict and margins}

{pstd}In addition to the standard {help predict} and {help margins} options 
that can be used after {help ml} estimators, you may use predict and margins 
with the following options (depending on the model previously fitted).


{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{dlgtab:Structural model parameters}
{synopt:{opt mean_e, sig_e}}Mean and standard deviation of latent true earnings 
e_i {p_end}
{synopt:{opt mean_n, sig_n}}Mean and standard deviation of RTM additive error 
n_i in the survey data {p_end}
{synopt:{opt mean_w, sig_w}}Mean and standard deviation of contamination 
error in the survey data{p_end}
{synopt:{opt mean_v, sig_v}}Mean and standard deviation of RTM additive error 
in the administrative data{p_end}
{synopt:{opt mean_t, sig_t}}Mean and standard deviation of the distribution 
of mismatched earnings in the adminstrative data{p_end}
{synopt:{opt pi_s, pi_r, pi_w, pi_v}}Probabilities of: correct reporting in the 
survey data (pi_s), i.e. no survey measurement error; correctly linked survey 
and administrative data (pr_r), i.e. no 'mismatch'; survey data having additional 
contamination (pr_w); and administrative data having measurement error (pr_v).{p_end}
{synopt:{opt rho_s, rho_r}}Regression-to-the-mean error parameters for survey 
data (rho_s), and administrative data (rho_r){p_end}
{synopt:{opt rho_w}}Conditional correlation between true latent earnings 'e' 
and survey contamination error 'w'. {p_end}

{dlgtab:Constructed model moments}
{synopt:{opt mean_r1, sig_r1}}Mean and standard error of R1 {p_end}
{synopt:{opt mean_r2, sig_r2}}Mean and standard error of R2 {p_end}
{synopt:{opt mean_r3, sig_r3}}Mean and standard error of R3 {p_end}
{synopt:{opt mean_s1, sig_s1}}Mean and standard error of S1 {p_end}
{synopt:{opt mean_s2, sig_s2}}Mean and standard error of S2 {p_end}
{synopt:{opt mean_s3, sig_s3}}Mean and standard error of S3 {p_end}

{synopt:{opt pi_r1, pi_r2, pi_r3}}Probability observation is of type R1, R2 or R3 {p_end}
{synopt:{opt pi_s1, pi_s2, pi_s3}}Probability observation is of type S1, S2 or S3 {p_end}
{synopt:{opt pi_1, pi_2 ,..., pi_9}}Probability observation belongs to latent class 
{it:j} = 1, 2, ..., 9 {p_end}

{synoptline}

{pstd} {help margins} can be used with all options described above. {p_end}

{pstd} In addition, it is possible to use {cmd:predict} to obtain posterior 
probability predictions, a Bayesian two-step classification, and predictors of
latent true earnings. They cannot be used in combination with {cmd: margins}.

{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt pip_r1, pip_r2, pip_r3}}Posterior probability observation is of type 
R1, R2 or R3 {p_end}
{synopt:{opt pip_s1, pip_s2, pip_s3}}Posterior probability observation is of type 
S1, S2 or S3 {p_end}
{synopt:{opt pip_1, pip_2, ..., pip_9}}Posterior probability observation belongs
to latent class {it:i} = 1, 2, ..., 9  {p_end}
{synopt:{opt bclass_r}}Bayesian classification of observation i into R1, 
R2 or R3 {p_end}
{synopt:{opt bclass_s}}Bayesian classification of observation i into S1, 
S2 or S3 {p_end}
{synopt:{opt bclass}}Bayesian classification of observation i into latent class
{it:j} = 1, 2, ..., 9  {p_end}
{synoptline}

{synopt:{opt star, [replace surv_only]}}Obtains estimates for latent true 
earnings e_i, combining information from the adminstrative and survey data. 
Following the methods of Rohwedder and Wansbeek (2012) that they illustrated 
using estimates from Kapteyn and Ypma (2007), this command obtains 7 predictors 
of e_i, as default, using the declared variable name as prefix. All new 
variables are created as type double. {p_end}
{synopt:} Option {cmd:replace} replaces the contents of the variables if they 
already exist in memory. {p_end}
{synopt:} Option {cmd:surv_only} requests prediction of the latent variable 
assuming you only have access to survey data. {p_end}
{synoptline}


{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}{help ky_fit} has three types of post-estimation command. {p_end}

{pstd}First, you can use {cmd:estat} to produce reports about the 
error probabilities, analytical variance and covariance matrices, and 
reliability statistics.  {p_end}

{pstd}Analytical variances and reliability statistics are unavailable if an 
error probability is a function of covariates. In this case, the command 
reports reliability statistics using simulated data. Using a sufficiently large 
number of replications should produce statistics identical to those derived
using the analytical formulas. {p_end}

{pstd}Second, you can use {help margins} to obtain marginal effects with 
respect to the latent and analytical moments associated with the 
previously-fitted model. {p_end}

{pstd} Third, you can use {help predict} to make predictions for a larger set of 
statistics of interest, including posterior probabilities, and Bayesian 
classifications. {p_end}

{pstd}See Jenkins and Rios-Avila (2021a, 2021b, 2021c) for details. {p_end}

{marker examples}{...}
{title:Examples}
{pstd}

{pstd} For examples, please see do-file "{stata doedit ky_example.do:ky_example.do}". 
{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:estat pr_t [pr_j pr_sr pr_all]} stores the following in {cmd:r()}:{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: matrix}{p_end}
{synopt:{cmd:r(bpi)}} contains point estimates for the associated probability. 
It may include the unconditional/average error-type probability, class 
probability ({it:j} = 1, ..., 9), observation type probability 
(R1, R2, R3, S1, S2, S3).   {p_end}
{synopt:{cmd:r(Vpi)}} contains point estimates of the variance covariance matrix 
of the associated probabilities. It may include unconditional/average 
error-type probabilities, latent class probabilities, or observation type 
probabilities.     {p_end}

{pstd}
If error probabilities are not expressed as functions of covariates,  
{cmd:estat rel} stores the following in {cmd:r()}:{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: scalar}{p_end}
{synopt:{cmd:r(pi_?)}} contains estimates of the probabilities associated 
with error types (? = s, r, w, v). {p_end}
{synopt:{cmd:r(pi_s#), r(pi_r#)}} contains estimates of the probabilities 
of observation types (R1, R2, R3, S1, S2, S3){p_end}
{synopt:{cmd:r(pi_#)}} contains estimates of latent class probabilities.{p_end}
{synopt:{cmd:r(rel#_?)}} contains two (# = 1, 2) relibility statistics for survey 
and administrative data (? = s, r).{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: matrix}{p_end}
{synopt:{cmd:r(bpi)}} contains point estimates for the associated probabilities. 
{p_end}
{synopt:{cmd:r(Vpi)}} contains point estimates for the variance-covariance matrix 
of the associated probabilities. {p_end}
{synopt:{cmd:r(mmsum)}} contains the unconditional mean, and conditional and 
unconditional of the latent variables e_i, n_i, w_i and t_i. {p_end}
{synopt:{cmd:r(rel)}} contains the analytical variance of {cmd:r} and {cmd:s}, 
the covariance with the latent true earnings {cmd:e_i}, and two reliability 
statistics{p_end}
 
{pstd}If {cmd:estat reliability} is used with covariates in the error 
probabilities or the {cmd:sim} option, the command stores the following in 
{cmd:r()}:{p_end}

{p2col 5 20 24 2: scalar}{p_end}
{synopt:{cmd:r(N_reps)}} number of replications. {p_end}
{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: macro}{p_end}
{synopt:{cmd:r(rngstate)}} random-number state used. {p_end}
{synopt:{cmd:r(seed)}} contains the seed used for simulations. {p_end}
{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: matrix}{p_end}
{synopt:{cmd:r(rel)}} contains the analytical variance of {cmd:r} and {cmd:s}, 
the covariance with the latent true earnings {cmd:e_i}, and two reliability 
statistcs. {p_end}

{pstd}If {cmd:estat xirel} is used, the following are stored in {cmd:r()}:{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: scalar}{p_end}
{synopt:{cmd:r(N_reps)}} number of replications. {p_end}
{p2col 5 20 24 2: macro}{p_end}
{synopt:{cmd:r(rngstate)}} random-number state used. {p_end}
{synopt:{cmd:r(seed)}} seed used for simulations.{p_end}
{p2col 5 20 24 2: matrix}{p_end}
{synopt:{cmd:r(mbv)}} simulated statistics for all 'e_i' predictions. {p_end}

{marker references}{...}
{title:References}

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



