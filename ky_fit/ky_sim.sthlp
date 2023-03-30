{smcl}
{* *! version 3.0 3 May 2021}{...}

{hline}
help for {hi:ky_sim}{right:Stephen P. Jenkins and Fernando Rios-Avila (May 2021)}
{hline}

{vieweralsosee "" "--"}{...}
{vieweralsosee ky_fit "help ky_fit"}{...}
{vieweralsosee postestimation "help ky_estat"}{...}
{viewerjumpto "Syntax" "ky_sim##syntax"}{...}
{viewerjumpto "Description" "ky_sim##description"}{...}
{viewerjumpto "Specification_option_1" "ky_sim##specification_option_1"}{...}
{viewerjumpto "Specification_option_2" "ky_sim##specification_option_2"}{...}
{viewerjumpto "Options" "ky_sim##options"}{...}
{viewerjumpto "Remarks" "ky_sim##remarks"}{...}
{viewerjumpto "Examples" "ky_sim##examples"}{...}
{viewerjumpto "Authors" "ky_fit##authors"}{...}

{title:Simulate data consistent with mixture models of the Kapteyn & Ypma type}

{marker syntax}{...}
{title:Syntax}

{pstd}{cmd:ky_sim} is a utility command for simulating data where the data 
 generating process is defined by one of 8 variants of a finite mixture 
 model of earnings and measurement errors of various types. The first four models
 were proposed by Kapteyn and Ypma (2007); the second four models are 
 generalisations of the Kapteyn-Ypma models proposed by Jenkins and 
 Rios-Avila (2021a, 2021b). We refer here to the general class of models as "KY" models.
 The simulated data comprise a set of observations ('workers', i = 1,...,N), 
 for each of which there are 2 measures of (log) earnings: (a) from a 
 survey (s_i) and (b) from an administrative record dataset (r_i). {p_end}

{pstd}{cmd:ky_sim} simulates the joint distribution of administrative and 
survey log earnings using two options.

{marker specification_option_1}{...}
{dlgtab:Option 1. You select the model and supply the parameters}

{pstd}This option allows you to simulate data, based on a fit of a specific
model. You have to specify the desired number of observations (Nobs), and 
values for the model parameters. The number of parameters required depends on 
which model is selected: see {help ky_fit} for more details. 
All parameters are assumed to be constant (i.e. not functions of covariates).

{p 8 17 2}
{cmdab:ky_sim,}
model(#) nobs(#) [{cmd:} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt model(#)}}The KY model used to simulate the data. {p_end}
{synopt:{opt nobs(#)}}The number of observations in the dataset created
created. {p_end}
{synopt:{opt clear}}Clears the dataset in memory, even if unsaved changes 
exist.{p_end}
{synopt:{opt seed(#)}}Set random-number seed to #{p_end}
{synopt:{opt parameter_values}}Parameter values (required){p_end}


{pstd}Depending on the model selected, you have to specify values for the 
following parameters: {p_end}

{p 8 12 2}{cmd:Means:} mean_e(#) mean_n(#) mean_t(#) mean_w(#) mean_v(#)  {p_end}
{p 8 12 2}{cmd:SDs:} sig_e(#) sig_n(#) sig_t(#) sig_w(#) sig_v(#) {p_end}
{p 8 12 2}{cmd:Correlations:} rho_r(#) rho_s(#) rho_w(#) {p_end}
{p 8 12 2}{cmd:Probabilities:} pi_s(#) pi_w(#) pi_r(#) pi_v(#) {p_end}

{pstd}A real number, local, or global can be used to initialize values for each
parameter. {p_end}
{pstd} If you specify a parameter that is not relevant to the model you 
selected, it will be ignored. For example, if you choose Model 1 or Model 2, 
and specify a value for pi_r(#), it is ignored.

{pstd} Depending on the simulated model(#), the post-simulation dataset contains 
the following variables:

{p 8 12 2}{cmd:r_var, s_var, l_var}: simulated administrative and survey 
log(earnings), and a variable identifying observations that are members of
the 'completely labeled' class (class 1). {p_end}
{p 8 12 2}{cmd:e_var, n_var, w_var, v_var, t_var}: Latent true log(earnings) 
and model errors.{p_end}
{p 8 12 2}{cmd:pi_si, pi_ri, pi_wi, pi_vi}: Binary variable indicating 
type of error. {p_end}

{marker specification_option_2}{...}
{dlgtab:Option 2. The parameters come from a fitted model}

{pstd}{cmd:ky_sim} can also be used as a post-estimation command. In this mode, 
{cmd:ky_sim} uses all of the data currently in memory and results 
from a previously-fitted model to generate the simulated data.

{p 8 17 2}
{cmdab:ky_sim}
[{cmd:,}
{it:options}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt est_sto(store_name)}} Uses a previously-fitted model store in 
memory under the name "store_name". {p_end}
{synopt:{opt est_sav(file_name)}} Uses a previously-fitted model saved 
as a "ster" file named "file_name".{p_end}
{synopt:{opt prefix(str)}} Indicates the {cmd:prefix} to be used to name 
the new variables. {p_end}
{synopt:{opt seed(#)}} Set random-number seed to # {p_end}
{synopt:{opt replace}} Overwrites variables if they already exist in the 
dataset {p_end}
{synoptline}

{p2colreset}{...}
{p 4 6 2}
When neither {cmd:est_sto()} nor {cmd:est_sav()} is specified, {cmd: ky_sim} 
will attempt to simulate data using the last estimates obtained with 
{cmd:ky_fit} that resides in memory. 

{p 4 6 2}
In all cases, the command assumes that all variables used as covariates in 
the model exist in the data currently in memory. 

{pstd} Depending on the simulated model(#), the post-simulation dataset 
includes following variables:

{p 8 12 2}{cmd:r_var, s_var, l_var}: simulated administrative and survey 
log(earnings), and a variable identifying class 1 data. {p_end}
{p 8 12 2}{cmd:e_var, n_var, w_var, v_var, t_var}: latent true log(earnings) 
and model errors.{p_end}
{p 8 12 2}{cmd:pi_si, pi_ri, pi_wi, pi_vi}: binary variable indicating 
type of error. {p_end}

{pstd} If the {cmd:prefix} option is used, all the names of variables 
created start with "prefix".

{marker examples}{...}
{title:Examples}
{pstd}

{pstd} For detailed examples, please see do-file "{stata viewsource ky_example.do:ky_example.do}". 
{p_end}


{marker references}{...}
{title:References}

{pstd}Jenkins, S.P. and Rios-Avila, F. (2021a). 
Finite mixture models for linked survey and administrative data: estimation and 
post-estimation. IZA Discussion Paper, forthcoming. 
{browse "https://www.iza.org/publications/dp"}
For submission to {it:The Stata Journal}.

{pstd}Jenkins, S. P. and Rios-Avila, F. (2021b). 
Reconciling reports: modelling employment earnings and measurement errors 
using linked survey and administrative data.
IZA Discussion Paper, forthcoming. {browse "https://www.iza.org/publications/dp"}

{pstd}Kapteyn, A. and Ypma, Y.A. (2007) Measurement error and misclassification: 
a comparison of survey and administrative data. 
{it: Journal of Labor Economics} 25 (3): 513{c -}51. 
{browse "https://www.journals.uchicago.edu/doi/abs/10.1086/513298"}


{marker results}{...}
{title:Stored results}

{pstd}
When using {cmd:ky_sim} to simulate data given exogenous parameters (option 1),
the following results are stored in e(). {p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: scalars}{p_end}
{synopt:{cmd:e(method_c)}}Code for fitted model. See model specification.{p_end}

{p2col 5 20 24 2: macros}{p_end}
{synopt:{cmd:e(predict)}}{cmd:ky_p}: program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(depvar)}}List of dependent variables{p_end}
{synopt:{cmd:e(estat_cmd)}}{cmd:ky_estat}: program used to implement 
post-estimation statistics {cmd:estat}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:ky_fit}{p_end}

{p2col 5 20 24 2: matrices}{p_end}
{synopt:{cmd:e(b)}}Vector containing the parameters{p_end}
{synopt:{cmd:e(V)}}Empty matrix{p_end}


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

