cscript
version 15
capture log close

log using ky_example.log, replace


////////////////////////////////////////////////////////////////////////////////
/// This file provides a working example that uses ky_fit
/// to simulate data used in Kapteyn-Ypma (Journal of Labor Economics, 2007) = "KY" 
/// , estimate those models, and provide relevant summary statistics
///
/// The code replicates some of the tables in KY as well as the
/// reliability reports in Meijer, Rohwedder & Wansbeek (Journal of Business
///		and Economic Statistics, 2012) = "MRW"
////////////////////////////////////////////////////////////////////////////////

/// SET UP: Storing model parameters reported in KY, Table C2

global mean_e  12.283
global mean_t   9.187
global mean_w  (-0.304)
global mean_n  (-0.048)

global sig_e  0.717
global sig_t  1.807
global sig_w  1.239
global sig_n  0.099 

global pi_r  0.959
global pi_s  0.152
global pi_w  0.156

global rho_s  (-0.013)

/// Step 1: Simulating data using -ky_fit-

/// Notice that this includes option "clear" to replace any data in memory

// First, declare the model to be used for simulation
// Second, 	declare values of model parameters
ky_sim, nobs(400) model(4) seed(101) /// 
		mean_e($mean_e) mean_t($mean_t) mean_w($mean_w) mean_n($mean_n) /// 
		sig_e($sig_e)   sig_t($sig_t)   sig_w($sig_w)   sig_n($sig_n)   ///
		pi_r($pi_r)     pi_s($pi_s)     pi_w($pi_w)     rho_s($rho_s)  clear
		
/// This also stores all coefficients in equation form:

ereturn display

/// which are stored for later use	

estimates store model0		

/// some summary statistics and data description
	
describe *
summarize *, sep(0)
	
/// We first show how -ky_fit- can be used to estimate KY models using simulated data
/// For simplicity, we replicate all models shown in KY, Table 2C:

// Basic model (using contraint)
constraint 1 [mu_n]_cons = 0
ky_fit r_var s_var l_var, model(1) technique(nr bhhh) constraint(1)
estimates store model1

//  No mismatch	
ky_fit r_var s_var l_var, model(2) 
estimates store model2 

//  No contamination
ky_fit r_var s_var l_var, model(3) 
estimates store model3 

//  Full model
ky_fit r_var s_var l_var, model(4) 
estimates store model4

// all models can be also be estimated allowing for covariates. 
//		For illustrative purposes, create a covariate as a random variable

generate x = rnormal()

ky_fit r_var s_var l_var, model(4) mu_e(x) ln_sig_e(x) 

//  For reporting, we use Ben Jann's "estout"
		 
capture ssc install estout
esttab model0 model4 model3 model2 model1 , se wide compress b(3) ///
	nostar scalars(ll) nogaps ///
	mtitle(Original  "Full model" "No contamination" "No mismatch" "Basic Model") ///
	noeqline 

// 	The results reported are very similar to those reported by KY

//////////////////////////////////////////////////////////////////////////////////////////////////////
//  Post estimation:

quietly: ky_fit r_var s_var l_var, model(4) 

//  We can request the full report of probabilities and reliability from this data:

estat reliability,

//  and we can also obtain the simulation based reliabilities	

estat reliability, sim seed(10)

//  More interestingly, we can also report the coefficients in their original scales 
//   as well as estimating marginal effects via -margins-
//  Here is an example for predicted means, which could be extended 
//   to marginal effects, or means by groups defined by covariate levels and combinations

margins , predict(mean_e) predict(sig_e) ///
		  predict(mean_t) predict(sig_t) ///
		  predict(mean_w) predict(sig_w) ///
		  predict(mean_n) predict(sig_n) ///
		  predict(pi_r) predict(pi_s) predict(pi_w) ///
		  predict(rho_s)

/////////////////////////////////////////////////////////////////////
/// The last exercise uses -predict-'s "star" option to obtain 
///	hybrid earnings predictors, combining information from the survey and admin data
/// For this we simulate the data again, using KY's parameters for the excercise
	
// First, declare the model to be used for simulation
// Second, 	declare values of model parameters
ky_sim, nobs(400) model(4) seed(101) /// 
	mean_e($mean_e) mean_t($mean_t) mean_w($mean_w) mean_n($mean_n) /// 
	sig_e($sig_e)   sig_t($sig_t)   sig_w($sig_w)   sig_n($sig_n)   ///
	pi_r($pi_r)     pi_s($pi_s)     pi_w($pi_w)     rho_s($rho_s)  clear
		
predict xi_, star
// we can compare the true value of the latent data (simulated) with estimators
// proposed by MRW(12)
sum e_var xi_*, sep(0)

corr e_var xi_*, 
// The following provides simple plots for the true e_var and the predictions based on MRW
plot e_var xi_1
plot e_var xi_2
plot e_var xi_7

// we could even produce the predictions assuming we only have access to survey data:
predict xis_, star surv_only
corr e_var xis_*, 

// finally, we prepare some summary statistics that show 
// the reliability of the data as suggested by MRW
// This replicates MRW reliability (rel2) for survey and admin data exactly. 
quietly: estat reliability
matrix rel_analytical = r(rel)
quietly: estat reliability, sim reps(100) seed(10)
matrix rel_simulation = r(rel)
matrix roweq rel_analytical = Analytical
matrix roweq rel_simulation = Simulation
matrix result = rel_analytical \ rel_simulation
matrix list result, format(%5.4f)

// We can report the Reliability for all 7 hybrid earnings predictors
// following MRW's methodology. 
// This replicates MRW's Table 6: 
estat xirel, seed(10) reps(100)

****
log close	