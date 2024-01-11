*! v2.46 (fra) 4/2022: Chnage to v14
* v2.45 (fra) 09/13/2021: Adds Model 9
* v2.43 (fra) 03/21/2021: Adds data class to sim no covariates
* v2.42 (fra) 03/09/2021: correcting bug for Sim8, and others. PIP and Bayesian
* v2.41 (fra) 12/29/2020: add IF for special cases. small bug with ky_sim8
* v2.4  (fra) 11/12/2020: Adds new feature. when using ky_sim with paramters, stores info in e(b) for ky_star
* v2.33 (fra) 7/15/2020: adds some options for labelling variables and "clearing data"
* v2.32 (fra) 7/15/2020: adds seed for replication purposes. 
* v2.31 (fra) 7/15/2020: corrects for bug when using "set varabbrev off"
* v2.3 (fra) 7/14/2020 : adds Model 8
* v2.2 (fra) 7/13/2020 : Corrected. Adds option for model 7. Correlation between w_i and e_i.
* v2.1 (fra) 7/11/2020 : Adds option for model 7. Correlation between w_i and e_i.
* v2.0 (fra) 7/10/2020 : Simulation for after ky_fit. Should allow for different types of simulation.
*** Adjusting for changes from ky_estimator to ky_fit. And how e(model) is read.
** This does 2 types of simulations
** 1. Creates a sample size N with parameters amd model defined. Simulates R and S
** 2. Uses data and model previouly estimated to simulate data. Simulates R and S. It may use previously estimated model, 
** model stored in memory, saved model 
** 3. Attempt to do simulation conditional on S. (S is observed)

*capture program drop ky_sim
program define ky_sim

version 14

syntax [if], [model(numlist max=1 min=1)  /// this will be for No controls.
		 est_sto(str) est_sav(str) seed(str) *      /// this for stored or saved results
		]
		
	if "`seed'"!="" {
		local rnstate=c(rngstate)
		set seed `seed'
	}
		 if "`model'"=="1" ky_sim1 `if', `options'	 
	else if "`model'"=="2" ky_sim2 `if', `options'
	else if "`model'"=="3" ky_sim3 `if', `options'
	else if "`model'"=="4" ky_sim4 `if', `options'
	else if "`model'"=="5" ky_sim5 `if', `options'
	else if "`model'"=="6" ky_sim6 `if', `options'
	else if "`model'"=="7" ky_sim7 `if', `options'
	else if "`model'"=="8" ky_sim8 `if', `options'
	else if "`model'"=="9" ky_sim9 `if', `options'
	else if "`model'"!="" {
		display in red "Model `model' does not exist. Please choose between 1 - 8"
		error 9999
	}
	else if "`est_sto'"!="" {
	        est restore `est_sto'
				 if "`e(method_c)'"=="1" ky_sim1cv `if', `options'
			else if "`e(method_c)'"=="2" ky_sim2cv `if', `options'
			else if "`e(method_c)'"=="3" ky_sim3cv `if', `options'
			else if "`e(method_c)'"=="4" ky_sim4cv `if', `options'
			else if "`e(method_c)'"=="5" ky_sim5cv `if', `options'
			else if "`e(method_c)'"=="6" ky_sim6cv `if', `options'
			else if "`e(method_c)'"=="7" ky_sim7cv `if', `options'
			else if "`e(method_c)'"=="8" ky_sim8cv `if', `options'
			else if "`e(method_c)'"=="9" ky_sim9cv `if', `options'
		 }
	else if "`est_sav'"!="" {
	        est use `est_sav' 
				 if "`e(method_c)'"=="1" ky_sim1cv `if', `options'
			else if "`e(method_c)'"=="2" ky_sim2cv `if', `options'
			else if "`e(method_c)'"=="3" ky_sim3cv `if', `options'
			else if "`e(method_c)'"=="4" ky_sim4cv `if', `options'
			else if "`e(method_c)'"=="5" ky_sim5cv `if', `options'
			else if "`e(method_c)'"=="6" ky_sim6cv `if', `options'	    
			else if "`e(method_c)'"=="7" ky_sim7cv `if', `options'	    
			else if "`e(method_c)'"=="8" ky_sim8cv `if', `options'
			else if "`e(method_c)'"=="9" ky_sim9cv `if', `options'
		 }	 
	else if "`e(cmd)'"=="ky_fit" {
				 if "`e(method_c)'"=="1" ky_sim1cv `if', `options'
			else if "`e(method_c)'"=="2" ky_sim2cv `if', `options'
			else if "`e(method_c)'"=="3" ky_sim3cv `if', `options'
			else if "`e(method_c)'"=="4" ky_sim4cv `if', `options'
			else if "`e(method_c)'"=="5" ky_sim5cv `if', `options'
			else if "`e(method_c)'"=="6" ky_sim6cv `if', `options'
			else if "`e(method_c)'"=="7" ky_sim7cv `if', `options'
			else if "`e(method_c)'"=="8" ky_sim8cv `if', `options'
			else if "`e(method_c)'"=="9" ky_sim9cv `if', `options'
	     }
	if "`seed'"!="" {
		set rngstate `rnstate'
	}
	
end

/*Survey Data with RTM error*/
/*admin data no problem*/
 program label_vars
 version 14
 syntax, [prefix(str)]
	capture:label var `prefix'e_var "True Latent log(earnings) "   
	capture:label var `prefix'n_var "Noise in RTM survey data"
	capture:label var `prefix'w_var "Contamination error in survey"
	capture:label var `prefix'v_var "Noise in RTM administrative data"
	capture:label var `prefix't_var "Mismatched values to admin data"
	capture:label var `prefix'pi_ri "=1 if data are matched correctly"
	capture:label var `prefix'pi_vi "=1 if data have no RTM error in admin data"
	capture:label var `prefix'pi_si "=1 if data reported correctly"
	capture:label var `prefix'pi_wi "=1 if data have additional contamination in survey data"
	capture:label var `prefix'r_var "Administrative log(earnings)"
	capture:label var `prefix's_var "Survey log(earnings)"
	capture:label var `prefix'l_var "=1 if r_i and s_i are error free"
	capture:label var `prefix'rclass "Data type for R"
	capture:label var `prefix'sclass "Data type for S"
	capture:label var `prefix'class  "Data type for (R,S)"
end	

program toclear
version 14
syntax , [clear]
	qui:`clear'
	capture:use ___extra___
	if _rc==4 {
		display in red "There is data in memory, use option 'clear' to replace the dataset in memory"
		error 4
	}
	else {
		clear
	}
end

program define make_eq, eclass
version 14
syntax,  [mean_e(str ) mean_n(str) mean_v(str) mean_t(str) mean_w(str) /// unconditional mean for variable
		 sig_e(str )  sig_n(str ) sig_v(str)  sig_t(str)  sig_w(str) /// unconditional variances
		 rho_s(str )  rho_r(str ) rho_w(str )  /// Level of regression to the mean error
		 pi_s(str ) pi_w(str ) pi_v(str )  pi_r(str ) model(str) depvar(varlist) ] // Probability of each type of data being created.
		 
** This program will use all the information provided to construct elements for e(b). 
** This may prove usefull for simulated data
	tempname mb
	
	foreach i in e n v t w {
	    
	    if "`mean_`i''" !="" {
		    matrix `mb' = nullmat(`mb') , `mean_`i''
			local coln `coln' mu_`i'
		}
	}
	foreach i in e n v t w {	
		if "`sig_`i''"!="" {
		    matrix `mb' = nullmat(`mb') , ln(`sig_`i'')
			local coln `coln' ln_sig_`i'
		}
	}
	foreach i in s r w {
		if "`rho_`i''"!="" {
			matrix `mb' = nullmat(`mb') , atanh(`rho_`i'')
			local coln `coln' arho_`i'
		}
	}	
	foreach i in r s w v  {
		if "`pi_`i''"!="" {
		    matrix `mb' = nullmat(`mb') , invlogistic(`pi_`i'')
			local coln `coln' lpi_`i'
		}
	}	 
	tempname V
	matrix `V'=I(`=colsof(`mb')')*0
	matrix coleq   `V' = `coln'
	matrix colname `V' = _cons
	matrix roweq   `V' = `coln'
	matrix rowname `V' = _cons
	
	matrix coleq `mb' = `coln'
	matrix colname `mb' = _cons
	matrix list `mb'
	ereturn post `mb' `V'
	ereturn local cmd ky_fit
	ereturn local predict ky_p
	ereturn local depvar `depvar'
	ereturn scalar method_c = `model'
	ereturn local estat_cmd  ky_estat
end
*capture program drop ky_sim1
program define ky_sim1
version 14

syntax [if],  nobs(int)		 /// sample size
		 mean_e(str ) mean_n(str) /// unconditional mean for variable
		 sig_e(str ) sig_n(str ) /// unconditional variances
		 rho_s(str )  /// Level of regression to the mean error
		 pi_s(str )    [clear  *]  // Probability of each type of data being created.
	qui {	 
	** set observations
		toclear, `clear'
		set obs `nobs'
		** generating latent variables
		gen double e_var=`mean_e'+rnormal()*`sig_e' `if'
		gen double n_var=`mean_n'+rnormal()*`sig_n' `if'
		gen byte   pi_si=runiform()<=`pi_s' `if'
		gen double r_var=e_var
		gen double s_var=e_var  if pi_si==1
		   replace s_var=e_var+(`rho_s')*(e_var-`mean_e')+n_var if pi_si==0
	    gen double l_var= r_var == s_var
		gen byte rclass=1
		gen byte sclass=1 if pi_si==1
		replace  sclass=2 if pi_si==0
		gen byte class=1 if rclass==1 & sclass==1
		replace  class=2 if rclass==1 & sclass==2
		label_vars
		make_eq, mean_e(`mean_e' ) mean_n(`mean_n') ///
			 sig_e(`sig_e' )  sig_n(`sig_n') ///
			 rho_s(`rho_s' )  pi_s(`pi_s' ) model(1) depvar(r_var s_var l_var)
	} 
end

/*Survey Data RTM error and Contamination*/
/*admin data no problem*/

*capture program drop ky_sim2
program define ky_sim2
version 14
syntax [if],  nobs(int)		 /// sample size
		 mean_e(str ) mean_n(str) mean_w(str) /// unconditional mean for variable
		 sig_e(str ) sig_n(str ) sig_w(str) /// unconditional variances
		 rho_s(str )  /// Level of regression to the mean error
		 pi_s(str ) pi_w(str )   [clear  *]  // Probability of each type of data being created. last part will be to allow other parameters 
	qui {	 
	** set observations
	toclear, `clear'
	set obs `nobs'
	** generating latent variables
	gen double e_var=`mean_e'+rnormal()*`sig_e' `if'
	gen double n_var=`mean_n'+rnormal()*`sig_n' `if'
	gen double w_var=`mean_w'+rnormal()*`sig_w' `if'
	
	gen byte   pi_si=runiform()<=`pi_s' `if'
	gen byte   pi_wi=runiform()<=`pi_w' `if'
	
	gen double r_var=e_var
	gen double s_var=e_var  if pi_si==1
	   replace s_var=e_var+(`rho_s')*(e_var-`mean_e')+n_var       if pi_si==0 & pi_wi==0
	   replace s_var=e_var+(`rho_s')*(e_var-`mean_e')+n_var+w_var if pi_si==0 & pi_wi==1
	gen double l_var= r_var == s_var
	
	gen byte rclass=1
	gen byte sclass=1 if pi_si==1
	replace  sclass=2 if pi_si==0 & pi_wi==0
	replace  sclass=3 if pi_si==0 & pi_wi==1
	gen byte class=1 if rclass==1 & sclass==1
	replace  class=2 if rclass==1 & sclass==2
	replace  class=3 if rclass==1 & sclass==3
		
		label_vars
		make_eq, mean_e(`mean_e' ) mean_n(`mean_n') mean_w(`mean_w') ///
			 sig_e(`sig_e' )  sig_n(`sig_n') sig_w(`sig_w') ///
			 rho_s(`rho_s' )  pi_s(`pi_s' ) pi_w(`pi_w' ) model(2) depvar(r_var s_var l_var)
	}
end

/*"Survey with RTM error and Admin data with Mismatch:"*/
*capture program drop ky_sim3
program define ky_sim3
version 14
syntax [if],  nobs(int)		 /// sample size
		 mean_e(str ) mean_n(str) mean_t(str) /// unconditional mean for variable
		 sig_e(str ) sig_n(str ) sig_t(str) /// unconditional variances
		 rho_s(str )  /// Level of regression to the mean error
		 pi_s(str ) pi_r(str )   [clear *]  // Probability of each type of data being created.
	qui {	 
	** set observations
	toclear, `clear'	
	set obs `nobs'
	** generating latent variables
	gen double e_var=`mean_e'+rnormal()*`sig_e' `if'
	gen double n_var=`mean_n'+rnormal()*`sig_n' `if'
	gen double t_var=`mean_t'+rnormal()*`sig_t' `if'
	
	gen byte   pi_si=runiform()<=`pi_s' `if'
	gen byte   pi_ri=runiform()<=`pi_r' `if'
	
	gen double r_var=e_var  if pi_ri==1
	   replace r_var=t_var  if pi_ri==0
	gen double s_var=e_var  if pi_si==1
	   replace s_var=e_var+(`rho_s')*(e_var-`mean_e')+n_var       if pi_si==0 	   
	gen double l_var= r_var == s_var
	
	gen byte rclass=1 if pi_ri==1
	replace  rclass=2 if pi_ri==0
	gen byte sclass=1 if pi_si==1
	replace  sclass=2 if pi_si==0 
	gen byte class=1 if rclass==1 & sclass==1
	replace  class=2 if rclass==1 & sclass==2
	replace  class=3 if rclass==2 & sclass==1
	replace  class=4 if rclass==2 & sclass==2
	
		label_vars
		make_eq, mean_e(`mean_e' ) mean_n(`mean_n') mean_t(`mean_t') ///
			 sig_e(`sig_e' )  sig_n(`sig_n') sig_t(`sig_t') ///
			 rho_s(`rho_s' )  pi_s(`pi_s' ) pi_r(`pi_r' ) model(3) depvar(r_var s_var l_var)
	}	 
end

/*Survey with RTM error and contamination and Admin data with Mismatch*/
*capture program drop ky_sim4
program define ky_sim4
version 14
syntax [if],  nobs(int)		 /// sample size
		 mean_e(str ) mean_n(str) mean_t(str) mean_w(str) /// unconditional mean for variable
		 sig_e(str ) sig_n(str ) sig_t(str) sig_w(str) /// unconditional variances
		 rho_s(str )  /// Level of regression to the mean error
		 pi_s(str ) pi_w(str )  pi_r(str ) [ clear *]   // Probability of each type of data being created.
	qui {	 
	** set observations
	toclear, `clear'	
	set obs `nobs'
	** generating latent variables
	gen double e_var=`mean_e'+rnormal()*`sig_e' `if'
	gen double n_var=`mean_n'+rnormal()*`sig_n' `if'
	gen double w_var=`mean_w'+rnormal()*`sig_w' `if'
	gen double t_var=`mean_t'+rnormal()*`sig_t' `if'
	
	gen byte   pi_si=runiform()<=`pi_s' `if'
	gen byte   pi_wi=runiform()<=`pi_w' `if'
	gen byte   pi_ri=runiform()<=`pi_r' `if'
	
	gen double r_var=e_var  if pi_ri==1
	   replace r_var=t_var  if pi_ri==0 
	gen double s_var=e_var  if pi_si==1
	   replace s_var=e_var+(`rho_s')*(e_var-`mean_e')+n_var       if pi_si==0 & pi_wi==0
	   replace s_var=e_var+(`rho_s')*(e_var-`mean_e')+n_var+w_var if pi_si==0 & pi_wi==1
	gen double l_var= r_var == s_var
	
	gen byte rclass=1 if pi_ri==1
	replace  rclass=2 if pi_ri==0
	gen byte sclass=1 if pi_si==1
	replace  sclass=2 if pi_si==0 & pi_wi==0
	replace  sclass=3 if pi_si==0 & pi_wi==1 
	gen byte class=1 if rclass==1 & sclass==1
	replace  class=2 if rclass==1 & sclass==2
	replace  class=3 if rclass==1 & sclass==3
	replace  class=4 if rclass==2 & sclass==1
	replace  class=5 if rclass==2 & sclass==2
	replace  class=6 if rclass==2 & sclass==3
		label_vars
		make_eq, mean_e(`mean_e') mean_n(`mean_n') mean_t(`mean_t') mean_w(`mean_w') ///
				 sig_e(`sig_e')   sig_n(`sig_n')   sig_t(`sig_t')   sig_w(`sig_w') ///
				 rho_s(`rho_s')   ///
				 pi_s(`pi_s') 	  pi_w(`pi_w' )     pi_r(`pi_r' ) ///
				 model(4) depvar(r_var s_var l_var)
 
	}	   
end


/*"Survey with RTM error and contamination and" 
  "Admin data with RTM error and Mismatch" 
*/
*capture program drop ky_sim5
program define ky_sim5
version 14
syntax [if],  nobs(int)		 /// sample size
		 mean_e(str ) mean_n(str) mean_v(str) mean_t(str) mean_w(str) /// unconditional mean for variable
		 sig_e(str )  sig_n(str ) sig_v(str)  sig_t(str)  sig_w(str) /// unconditional variances
		 rho_s(str )  rho_r(str )  /// Level of regression to the mean error
		 pi_s(str ) pi_w(str ) pi_v(str )  pi_r(str ) [clear  *]   // Probability of each type of data being created.
	qui {	 
	** set observations
	toclear, `clear'		
	set obs `nobs'
	** generating latent variables
	gen double e_var=`mean_e'+rnormal()*`sig_e' `if'
	gen double n_var=`mean_n'+rnormal()*`sig_n' `if'
	gen double w_var=`mean_w'+rnormal()*`sig_w' `if'
	gen double v_var=`mean_v'+rnormal()*`sig_v' `if'
	gen double t_var=`mean_t'+rnormal()*`sig_t' `if'
	
	gen byte   pi_si=runiform()<=`pi_s' `if'
	gen byte   pi_wi=runiform()<=`pi_w' `if'
	gen byte   pi_vi=runiform()<=`pi_v' `if'
	gen byte   pi_ri=runiform()<=`pi_r' `if'
	
	gen double r_var=e_var                                        if pi_ri==1 & pi_vi==1
	   replace r_var=e_var+(`rho_r')*(e_var-`mean_e')+v_var       if pi_ri==1 & pi_vi==0
	   replace r_var=t_var                                 	      if pi_ri==0 
	gen double s_var=e_var                                        if pi_si==1
	   replace s_var=e_var+(`rho_s')*(e_var-`mean_e')+n_var       if pi_si==0 & pi_wi==0
	   replace s_var=e_var+(`rho_s')*(e_var-`mean_e')+n_var+w_var if pi_si==0 & pi_wi==1
	gen double l_var= r_var == s_var
	
	gen byte rclass=1 if pi_ri==1 & pi_vi==1
	replace  rclass=2 if pi_ri==1 & pi_vi==0
	replace  rclass=3 if pi_ri==0 
	gen byte sclass=1 if pi_si==1
	replace  sclass=2 if pi_si==0 & pi_wi==0
	replace  sclass=3 if pi_si==0 & pi_wi==1 
	gen byte class=1 if rclass==1 & sclass==1
	replace  class=2 if rclass==1 & sclass==2
	replace  class=3 if rclass==1 & sclass==3
	replace  class=4 if rclass==2 & sclass==1
	replace  class=5 if rclass==2 & sclass==2
	replace  class=6 if rclass==2 & sclass==3
	replace  class=7 if rclass==3 & sclass==1
	replace  class=8 if rclass==3 & sclass==2
	replace  class=9 if rclass==3 & sclass==3
	
		label_vars
		make_eq, mean_e(`mean_e') mean_n(`mean_n') mean_v(`mean_v')  mean_t(`mean_t') mean_w(`mean_w') ///
				 sig_e(`sig_e')   sig_n(`sig_n')   sig_v(`sig_v')    sig_t(`sig_t')   sig_w(`sig_w') ///
				 rho_s(`rho_s')   rho_r(`rho_r')   ///
				 pi_s(`pi_s') 	  pi_w(`pi_w' )    pi_v(`pi_v' ) pi_r(`pi_r' ) ///
				 model(5) depvar(r_var s_var l_var)
	}	      
end



/*"Survey with RTM error " 
  "Admin data with RTM error and Mismatch" 
*/
*capture program drop ky_sim6
program define ky_sim6
version 14
syntax [if],  nobs(int)		 /// sample size
		 mean_e(str ) mean_n(str) mean_v(str) mean_t(str) /// unconditional mean for variable
		 sig_e(str )  sig_n(str ) sig_v(str)  sig_t(str)  /// unconditional variances
		 rho_s(str )  rho_r(str )  /// Level of regression to the mean error
		 pi_s(str )  pi_v(str )  pi_r(str ) [ clear  *]  // Probability of each type of data being created.
	qui {	 
	** set observations
	toclear, `clear'	
	set obs `nobs'
	** generating latent variables
	gen double e_var=`mean_e'+rnormal()*`sig_e'  `if'
	gen double n_var=`mean_n'+rnormal()*`sig_n'  `if'
	
	gen double v_var=`mean_v'+rnormal()*`sig_v'  `if'
	gen double t_var=`mean_t'+rnormal()*`sig_t'  `if'
	
	gen byte   pi_si=runiform()<=`pi_s'  `if'
	gen byte   pi_vi=runiform()<=`pi_v'  `if'
	gen byte   pi_ri=runiform()<=`pi_r'  `if'
	
	gen double r_var=e_var                                 if pi_ri==1 & pi_vi==1
	   replace r_var=e_var+`rho_r'*(e_var-`mean_e')+v_var  if pi_ri==1 & pi_vi==0
	   replace r_var=t_var                                 if pi_ri==0 
	gen double s_var=e_var                                 if pi_si==1
	   replace s_var=e_var+`rho_s'*(e_var-`mean_e')+n_var  if pi_si==0 
	gen double l_var= r_var == s_var
	
	gen byte rclass=1 if pi_ri==1 & pi_vi==1
	replace  rclass=2 if pi_ri==1 & pi_vi==0
	replace  rclass=3 if pi_ri==0 
	gen byte sclass=1 if pi_si==1
	replace  sclass=2 if pi_si==0 & pi_wi==0
	replace  sclass=3 if pi_si==0 & pi_wi==1 
	gen byte class=1 if rclass==1 & sclass==1
	replace  class=2 if rclass==1 & sclass==2
	replace  class=3 if rclass==2 & sclass==1
	replace  class=4 if rclass==2 & sclass==2
	replace  class=5 if rclass==3 & sclass==1
	replace  class=6 if rclass==3 & sclass==2
	
		label_vars
		make_eq, mean_e(`mean_e') mean_n(`mean_n') mean_v(`mean_v')  mean_t(`mean_t')  ///
				 sig_e(`sig_e')   sig_n(`sig_n')   sig_v(`sig_v')    sig_t(`sig_t')    ///
				 rho_s(`rho_s')   rho_r(`rho_r')   ///
				 pi_s(`pi_s') 	  pi_v(`pi_v' ) pi_r(`pi_r' ) ///
				 model(6) depvar(r_var s_var l_var)
	}	   	   
end

program define ky_sim7
version 14
syntax [if],  nobs(int)		 /// sample size
		 mean_e(str ) mean_n(str) mean_t(str) mean_w(str) /// unconditional mean for variable
		 sig_e(str ) sig_n(str ) sig_t(str) sig_w(str) /// unconditional variances
		 rho_w(str) rho_s(str )  /// Level of regression to the mean error
		 pi_s(str ) pi_w(str )  pi_r(str ) [clear  *]   // Probability of each type of data being created.
	qui {	 
	** set observations
	toclear, `clear'		
	set obs `nobs'
	** generating latent variables
	tempname ewcorr
	matrix `ewcorr'=[1,`rho_w' \ `rho_w' ,1]
	drawnorm double e_var w_var  `if', corr(`ewcorr')
	replace e_var=`mean_e'+e_var*`sig_e'  `if'
	gen double n_var=`mean_n'+rnormal()*`sig_n'  `if'
	replace w_var=`mean_w'+w_var*`sig_w'  `if'
	gen double t_var=`mean_t'+rnormal()*`sig_t'  `if'
	
	gen byte   pi_si=runiform()<=`pi_s'  `if'
	gen byte   pi_wi=runiform()<=`pi_w'  `if'
	gen byte   pi_ri=runiform()<=`pi_r'  `if'
	
	gen double r_var=e_var  if pi_ri==1
	   replace r_var=t_var  if pi_ri==0 
	gen double s_var=e_var  if pi_si==1
	   replace s_var=e_var+(`rho_s')*(e_var-`mean_e')+n_var       if pi_si==0 & pi_wi==0
	   replace s_var=e_var+(`rho_s')*(e_var-`mean_e')+n_var+w_var if pi_si==0 & pi_wi==1
	gen double l_var= r_var == s_var

	gen byte rclass=1 if pi_ri==1 & pi_vi==1
	replace  rclass=2 if pi_ri==1 & pi_vi==0
	gen byte sclass=1 if pi_si==1
	replace  sclass=2 if pi_si==0 & pi_wi==0
	replace  sclass=3 if pi_si==0 & pi_wi==1 
	gen byte class=1 if rclass==1 & sclass==1
	replace  class=2 if rclass==1 & sclass==2
	replace  class=3 if rclass==1 & sclass==3
	replace  class=4 if rclass==2 & sclass==1
	replace  class=5 if rclass==2 & sclass==2
	replace  class=6 if rclass==2 & sclass==3
	
		label_vars
		make_eq, mean_e(`mean_e') mean_n(`mean_n') mean_t(`mean_t') mean_w(`mean_w') ///
				 sig_e(`sig_e')   sig_n(`sig_n')   sig_t(`sig_t')   sig_w(`sig_w') ///
				 rho_s(`rho_s')   rho_w(`rho_w') ///
				 pi_s(`pi_s') 	  pi_w(`pi_w' )    pi_r(`pi_r' ) ///
				 model(7) depvar(r_var s_var l_var)
	}	   
end

program define ky_sim8
version 14
syntax [if],  nobs(int)		 /// sample size
		 mean_e(str ) mean_n(str) mean_v(str) mean_t(str) mean_w(str) /// unconditional mean for variable
		 sig_e(str )  sig_n(str ) sig_v(str)  sig_t(str)  sig_w(str) /// unconditional variances
		 rho_s(str )  rho_r(str ) rho_w(str )  /// Level of regression to the mean error
		 pi_s(str ) pi_w(str ) pi_v(str )  pi_r(str ) [clear  *]   // Probability of each type of data being created.
	qui {	 
	** set observations
	toclear, `clear'		
	set obs `nobs'
	** generating latent variables
	tempname ewcorr
	matrix `ewcorr'=[1,`rho_w' \ `rho_w' ,1]
	drawnorm double e_var w_var  `if', corr(`ewcorr')   
	replace    e_var=`mean_e'+e_var*`sig_e'  `if'
	gen double n_var=`mean_n'+rnormal()*`sig_n'  `if'
	replace    w_var=`mean_w'+w_var*`sig_w'  `if'

	gen double v_var=`mean_v'+rnormal()*`sig_v'  `if'
	gen double t_var=`mean_t'+rnormal()*`sig_t'  `if'
	
	gen byte   pi_si=runiform()<=`pi_s'  `if'
	gen byte   pi_wi=runiform()<=`pi_w'  `if'
	gen byte   pi_vi=runiform()<=`pi_v'  `if'
	gen byte   pi_ri=runiform()<=`pi_r'  `if'
		
	gen double r_var=e_var                                 if pi_ri==1 & pi_vi==1
	   replace r_var=e_var+`rho_r'*(e_var-`mean_e')+v_var  if pi_ri==1 & pi_vi==0
	   replace r_var=t_var                                 if pi_ri==0 
	gen double s_var=e_var                                        if pi_si==1
	   replace s_var=e_var+(`rho_s')*(e_var-`mean_e')+n_var       if pi_si==0 & pi_wi==0
	   replace s_var=e_var+(`rho_s')*(e_var-`mean_e')+n_var+w_var if pi_si==0 & pi_wi==1
	gen double l_var= r_var == s_var  `if'
	
	gen byte rclass=1 if pi_ri==1 & pi_vi==1
	replace  rclass=2 if pi_ri==1 & pi_vi==0
	replace  rclass=3 if pi_ri==0 
	gen byte sclass=1 if pi_si==1
	replace  sclass=2 if pi_si==0 & pi_wi==0
	replace  sclass=3 if pi_si==0 & pi_wi==1 
	gen byte class=1 if rclass==1 & sclass==1
	replace  class=2 if rclass==1 & sclass==2
	replace  class=3 if rclass==1 & sclass==3
	replace  class=4 if rclass==2 & sclass==1
	replace  class=5 if rclass==2 & sclass==2
	replace  class=6 if rclass==2 & sclass==3
	replace  class=7 if rclass==3 & sclass==1
	replace  class=8 if rclass==3 & sclass==2
	replace  class=9 if rclass==3 & sclass==3
	
		label_vars
		make_eq, mean_e(`mean_e') mean_n(`mean_n') mean_v(`mean_v')  mean_t(`mean_t') mean_w(`mean_w') ///
				 sig_e(`sig_e')   sig_n(`sig_n')   sig_v(`sig_v')    sig_t(`sig_t')   sig_w(`sig_w') ///
				 rho_s(`rho_s')   rho_r(`rho_r')   rho_w(`rho_w') ///
				 pi_s(`pi_s') 	  pi_w(`pi_w' )    pi_v(`pi_v' ) pi_r(`pi_r' ) ///
				 model(8) depvar(r_var s_var l_var)
	}	   
end


program define ky_sim9
version 14
syntax [if],  nobs(int)		 /// sample size
		 mean_e(str ) mean_n(str) mean_v(str) mean_w(str) /// unconditional mean for variable
		 sig_e(str )  sig_n(str ) sig_v(str)  sig_w(str) /// unconditional variances
		 rho_s(str )  rho_r(str )  /// Level of regression to the mean error
		 pi_s(str ) pi_w(str ) pi_v(str )  [clear  *]   // Probability of each type of data being created.
	qui {	 
	** set observations
	toclear, `clear'		
	set obs `nobs'
	** generating latent variables
	gen double e_var=`mean_e'+rnormal()*`sig_e' `if'
	gen double n_var=`mean_n'+rnormal()*`sig_n' `if'
	gen double w_var=`mean_w'+rnormal()*`sig_w' `if'
	gen double v_var=`mean_v'+rnormal()*`sig_v' `if'
		
	gen byte   pi_si=runiform()<=`pi_s' `if'
	gen byte   pi_wi=runiform()<=`pi_w' `if'
	gen byte   pi_vi=runiform()<=`pi_v' `if'
	gen byte   pi_ri=1
	gen double r_var=e_var                                        if pi_vi==1
	   replace r_var=e_var+(`rho_r')*(e_var-`mean_e')+v_var       if pi_vi==0
	*   replace r_var=t_var                                 	      if pi_ri==0 
	gen double s_var=e_var                                        if pi_si==1
	   replace s_var=e_var+(`rho_s')*(e_var-`mean_e')+n_var       if pi_si==0 & pi_wi==0
	   replace s_var=e_var+(`rho_s')*(e_var-`mean_e')+n_var+w_var if pi_si==0 & pi_wi==1
	gen double l_var= r_var == s_var
	
	gen byte rclass=1 if pi_ri==1 & pi_vi==1
	replace  rclass=2 if pi_ri==1 & pi_vi==0
	
	gen byte sclass=1 if pi_si==1
	replace  sclass=2 if pi_si==0 & pi_wi==0
	replace  sclass=3 if pi_si==0 & pi_wi==1 
	
	gen byte class=1 if rclass==1 & sclass==1
	replace  class=2 if rclass==1 & sclass==2
	replace  class=3 if rclass==1 & sclass==3
	replace  class=4 if rclass==2 & sclass==1
	replace  class=5 if rclass==2 & sclass==2
	replace  class=6 if rclass==2 & sclass==3
		
		label_vars
		make_eq, mean_e(`mean_e') mean_n(`mean_n') mean_v(`mean_v')  mean_t(`mean_t') mean_w(`mean_w') ///
				 sig_e(`sig_e')   sig_n(`sig_n')   sig_v(`sig_v')    sig_t(`sig_t')   sig_w(`sig_w') ///
				 rho_s(`rho_s')   rho_r(`rho_r')   ///
				 pi_s(`pi_s') 	  pi_w(`pi_w' )    pi_v(`pi_v' ) pi_r(`pi_r' ) ///
				 model(9) depvar(r_var s_var l_var)
	}	      
end



program define drop_ky_sim
version 14
	syntax, prefix(str)
	foreach i in e_var w_var n_var v_var t_var pi_ri pi_si pi_wi pi_vi r_var s_var l_var {
	    capture drop `prefix'`i'
	}
end
*capture program drop ky_sim1cv
program define ky_sim1cv
version 14
syntax [if],  [est_sto(str) est_sav(str) prefix(str) replace ] // Probability of each type of data being created.
	qui {	 
		** set observations
		tempvar mean_e mean_n sig_e sig_n pi_s rho_s
		
		predictnl double `pi_s'  =(invlogit(xb(lpi_s)))  `if'
		predictnl double `mean_e'=(xb(mu_e))	 `if'	
		predictnl double `mean_n'=(xb(mu_n)) `if'
		predictnl double `sig_e' =(exp(xb(ln_sig_e)))		 `if'
		predictnl double `sig_n' =(exp(xb(ln_sig_n))) `if'
		predictnl double `rho_s' =(tanh(xb(arho_s)))  `if'
		
		** generating latent variables
		if "`replace'"!="" {
		    drop_ky_sim, prefix(`prefix')
		}
		gen double `prefix'e_var=`mean_e'+rnormal()*`sig_e'
		gen double `prefix'n_var=`mean_n'+rnormal()*`sig_n'
		gen byte   `prefix'pi_si=runiform()<=`pi_s'
		** R
		gen double `prefix'r_var=`prefix'e_var
		** S
		gen double `prefix's_var=`prefix'e_var 													if `prefix'pi_si==1
	       replace `prefix's_var=`prefix'e_var+(`rho_s')*(`prefix'e_var-`mean_e')+`prefix'n_var if `prefix'pi_si==0
		gen byte   `prefix'l_var= `prefix'r_var == `prefix's_var
		   
	   }
	label_vars, prefix(`prefix')   
end


*capture program drop ky_sim2cv
program define ky_sim2cv
version 14
syntax [if],  [est_sto(str) est_sav(str) prefix(str) replace ] // Probability of each type of data being created.
	qui {	 
		tempvar mean_e mean_n mean_w sig_e sig_n sig_w pi_s pi_w rho_s
		predictnl double `pi_s'  =(invlogit(xb(lpi_s)))  `if'
		predictnl double `pi_w'  =(invlogit(xb(lpi_w)))  `if'
		predictnl double `mean_e'=(xb(mu_e))	 `if'	
		predictnl double `mean_n'=(xb(mu_n)) `if'
		predictnl double `mean_w'=(xb(mu_w)) `if'
		predictnl double `sig_e' =(exp(xb(ln_sig_e)))		 `if'
		predictnl double `sig_n' =(exp(xb(ln_sig_n))) `if'
		predictnl double `sig_w' =(exp(xb(ln_sig_w))) `if'
		predictnl double `rho_s' =(tanh(xb(arho_s)))  `if'
	
	** generating latent variables
		if "`replace'"!="" {
		    drop_ky_sim, prefix(`prefix')
		}	
		gen double `prefix'e_var=`mean_e'+rnormal()*`sig_e'
		gen double `prefix'n_var=`mean_n'+rnormal()*`sig_n'
		gen double `prefix'w_var=`mean_w'+rnormal()*`sig_w'
		
		gen byte   `prefix'pi_si=runiform()<=`pi_s'
		gen byte   `prefix'pi_wi=runiform()<=`pi_w'
		** R
		gen double `prefix'r_var=`prefix'e_var
		** S
		gen double `prefix's_var=`prefix'e_var  															  if `prefix'pi_si==1
		   replace `prefix's_var=`prefix'e_var+(`rho_s')*(`prefix'e_var-`mean_e')+`prefix'n_var       		  if `prefix'pi_si==0 & `prefix'pi_wi==0
		   replace `prefix's_var=`prefix'e_var+(`rho_s')*(`prefix'e_var-`mean_e')+`prefix'n_var+`prefix'w_var if `prefix'pi_si==0 & `prefix'pi_wi==1
		gen byte   `prefix'l_var= `prefix'r_var == `prefix's_var
		   
	   }
	label_vars, prefix(`prefix')	   
end

/*"Survey with RTM error and Admin data with Mismatch:"*/
*capture program drop ky_sim3cv
program define ky_sim3cv
version 14
syntax [if],  [est_sto(str) est_sav(str) prefix(str) replace ] // Probability of each type of data being created.
	qui {	 
	** set observations
		tempvar pi_s pi_r mean_e mean_n mean_t sig_e sig_n sig_t rho_s
		predictnl double `pi_s'  =(invlogit(xb(lpi_s)))  `if'
		predictnl double `pi_r'  =(invlogit(xb(lpi_r)))  `if'
		predictnl double `mean_e'=(xb(mu_e))	 `if'	
		predictnl double `mean_n'=(xb(mu_n)) `if'
		predictnl double `mean_t'=(xb(mu_t)) `if'
		predictnl double `sig_e' =(exp(xb(ln_sig_e)))		 `if'
		predictnl double `sig_n' =(exp(xb(ln_sig_n))) `if'
		predictnl double `sig_t' =(exp(xb(ln_sig_t))) `if'
		predictnl double `rho_s' =(tanh(xb(arho_s))) `if'
		
	** generating latent variables
		if "`replace'"!="" {
		    drop_ky_sim, prefix(`prefix')
		}	
		gen double `prefix'e_var=`mean_e'+rnormal()*`sig_e'
		gen double `prefix'n_var=`mean_n'+rnormal()*`sig_n'
		gen double `prefix't_var=`mean_t'+rnormal()*`sig_t'

		gen byte   `prefix'pi_si=runiform()<=`pi_s'
		gen byte   `prefix'pi_ri=runiform()<=`pi_r'

		gen double `prefix'r_var=`prefix'e_var  if `prefix'pi_ri==1
		replace    `prefix'r_var=`prefix't_var  if `prefix'pi_ri==0
		gen double `prefix's_var=`prefix'e_var  if `prefix'pi_si==1
		replace    `prefix's_var=`prefix'e_var+(`rho_s')*(`prefix'e_var-`mean_e')+`prefix'n_var       if `prefix'pi_si==0 	   
	   }
	label_vars, prefix(`prefix')   
end

/*Survey with RTM error and contamination and Admin data with Mismatch*/
*capture program drop ky_sim4cv
program define ky_sim4cv
version 14
syntax [if],  [est_sto(str) est_sav(str) prefix(str) replace ] // Probability of each type of data being created.
	qui {	 
	** set observations
		tempvar pi_s   pi_r   pi_w   pi_v   
		tempvar mean_e mean_n mean_t mean_w mean_v 
		tempvar sig_e  sig_n  sig_t  sig_w  sig_v 
		tempvar rho_s  rho_r
		qui {
			predictnl double `pi_s'  =(invlogit(xb(lpi_s)))  `if'
			predictnl double `pi_r'  =(invlogit(xb(lpi_r)))  `if'
			predictnl double `pi_w'  =(invlogit(xb(lpi_w)))  `if'
			predictnl double `mean_e'=(xb(mu_e))	 `if'	
			predictnl double `mean_n'=(xb(mu_n)) `if'
			predictnl double `mean_w'=(xb(mu_w)) `if'
			predictnl double `mean_t'=(xb(mu_t)) `if'
			predictnl double `sig_e' =(exp(xb(ln_sig_e)))		 `if'
			predictnl double `sig_n' =(exp(xb(ln_sig_n))) `if'
			predictnl double `sig_w' =(exp(xb(ln_sig_w))) `if'
			predictnl double `sig_t' =(exp(xb(ln_sig_t))) `if'
			predictnl double `rho_s' =(tanh(xb(arho_s))) `if'
		}
	
	** generating latent variables
		if "`replace'"!="" {
		    drop_ky_sim, prefix(`prefix')
		}	
		gen double `prefix'e_var=`mean_e'+rnormal()*`sig_e'
		gen double `prefix'n_var=`mean_n'+rnormal()*`sig_n'
		gen double `prefix'w_var=`mean_w'+rnormal()*`sig_w'
		gen double `prefix't_var=`mean_t'+rnormal()*`sig_t'
		
		gen byte   `prefix'pi_si=runiform()<=`pi_s'
		gen byte   `prefix'pi_wi=runiform()<=`pi_w'
		gen byte   `prefix'pi_ri=runiform()<=`pi_r'
		
		gen double `prefix'r_var=`prefix'e_var  if `prefix'pi_ri==1
		   replace `prefix'r_var=`prefix't_var  if `prefix'pi_ri==0 
		gen double `prefix's_var=`prefix'e_var  if `prefix'pi_si==1
		   replace `prefix's_var=`prefix'e_var+(`rho_s')*(`prefix'e_var-`mean_e')+`prefix'n_var               if `prefix'pi_si==0 & `prefix'pi_wi==0
		   replace `prefix's_var=`prefix'e_var+(`rho_s')*(`prefix'e_var-`mean_e')+`prefix'n_var+`prefix'w_var if `prefix'pi_si==0 & `prefix'pi_wi==1
		gen byte   `prefix'l_var= `prefix'r_var == `prefix's_var
		   
	   }
	label_vars, prefix(`prefix')   
end


/*"Survey with RTM error and contamination and" 
  "Admin data with RTM error and Mismatch" 
*/
*capture program drop ky_sim5cv
program define ky_sim5cv
version 14
syntax [if],  [est_sto(str) est_sav(str) prefix(str) replace ] // Probability of each type of data being created.
	qui {	 
		** set observations
		tempvar pi_s   pi_r   pi_w   pi_v   
		tempvar mean_e mean_n mean_t mean_w mean_v 
		tempvar sig_e  sig_n  sig_t  sig_w  sig_v 
		tempvar rho_s  rho_r
		qui {
			predictnl double `pi_s'  =(invlogit(xb(lpi_s)))  `if'
			predictnl double `pi_r'  =(invlogit(xb(lpi_r)))  `if'
			predictnl double `pi_w'  =(invlogit(xb(lpi_w)))  `if'
			predictnl double `pi_v'  =(invlogit(xb(lpi_v)))  `if'
			predictnl double `mean_e'=(xb(mu_e))	 `if'	
			predictnl double `mean_n'=(xb(mu_n)) `if'
			predictnl double `mean_w'=(xb(mu_w)) `if'
			predictnl double `mean_t'=(xb(mu_t)) `if'
			predictnl double `mean_v'=(xb(mu_v)) `if'
			predictnl double `sig_e' =(exp(xb(ln_sig_e)))		 `if'
			predictnl double `sig_n' =(exp(xb(ln_sig_n))) `if'
			predictnl double `sig_w' =(exp(xb(ln_sig_w))) `if'
			predictnl double `sig_t' =(exp(xb(ln_sig_t))) `if'
			predictnl double `sig_v' =(exp(xb(ln_sig_v))) `if'
			predictnl double `rho_s' =(tanh(xb(arho_s))) `if'
			predictnl double `rho_r' =(tanh(xb(arho_r))) `if'
		}
		** generating latent variables
		if "`replace'"!="" {
		    drop_ky_sim, prefix(`prefix')
		}		
		gen double `prefix'e_var=`mean_e'+rnormal()*`sig_e'
		gen double `prefix'n_var=`mean_n'+rnormal()*`sig_n'
		gen double `prefix'w_var=`mean_w'+rnormal()*`sig_w'
		gen double `prefix'v_var=`mean_v'+rnormal()*`sig_v'
		gen double `prefix't_var=`mean_t'+rnormal()*`sig_t'
		
		gen byte  `prefix'pi_si=runiform()<=`pi_s'
		gen byte  `prefix'pi_wi=runiform()<=`pi_w'
		gen byte  `prefix'pi_vi=runiform()<=`pi_v'
		gen byte  `prefix'pi_ri=runiform()<=`pi_r'
		
		gen double `prefix'r_var=`prefix'e_var                                                 				if `prefix'pi_ri==1 & `prefix'pi_vi==1
		   replace `prefix'r_var=`prefix'e_var+`rho_r'*(`prefix'e_var-`mean_e')+`prefix'v_var  				if `prefix'pi_ri==1 & `prefix'pi_vi==0
		   replace `prefix'r_var=`prefix't_var                                                 				if `prefix'pi_ri==0 
		gen double `prefix's_var=`prefix'e_var                                                 				if `prefix'pi_si==1
		   replace `prefix's_var=`prefix'e_var+`rho_s'*(`prefix'e_var-`mean_e')+`prefix'n_var       		if `prefix'pi_si==0 & `prefix'pi_wi==0
		   replace `prefix's_var=`prefix'e_var+`rho_s'*(`prefix'e_var-`mean_e')+`prefix'n_var+`prefix'w_var if `prefix'pi_si==0 & `prefix'pi_wi==1
		gen byte   `prefix'l_var= `prefix'r_var == `prefix's_var
		   
		   }
	label_vars, prefix(`prefix')	   
end


/*"Survey with RTM error " 
  "Admin data with RTM error and Mismatch" 
*/
*capture program drop ky_sim6cv
program define ky_sim6cv
version 14
syntax [if],  [est_sto(str) est_sav(str) prefix(str) replace ] // Probability of each type of data being created.
	qui {	 
		** set observations
		tempvar pi_s   pi_r   pi_w   pi_v   
		tempvar mean_e mean_n mean_t mean_w mean_v 
		tempvar sig_e  sig_n  sig_t  sig_w  sig_v 
		tempvar rho_s  rho_r
		qui {
			predictnl double `pi_s'  =(invlogit(xb(lpi_s)))  `if'
			predictnl double `pi_r'  =(invlogit(xb(lpi_r)))  `if'
			predictnl double `pi_v'  =(invlogit(xb(lpi_v)))  `if'
			predictnl double `mean_e'=(xb(mu_e))	 `if'	
			predictnl double `mean_n'=(xb(mu_n)) `if'
			predictnl double `mean_t'=(xb(mu_t)) `if'
			predictnl double `mean_v'=(xb(mu_v)) `if'
			predictnl double `sig_e' =(exp(xb(ln_sig_e)))		 `if'
			predictnl double `sig_n' =(exp(xb(ln_sig_n))) `if'
			predictnl double `sig_t' =(exp(xb(ln_sig_t))) `if'
			predictnl double `sig_v' =(exp(xb(ln_sig_v))) `if'
			predictnl double `rho_s' =(tanh(xb(arho_s))) `if'
			predictnl double `rho_r' =(tanh(xb(arho_r))) `if'
		}
		** generating latent variables
		if "`replace'"!="" {
		    drop_ky_sim, prefix(`prefix')
		}		
		gen double `prefix'e_var=`mean_e'+rnormal()*`sig_e'
		gen double `prefix'n_var=`mean_n'+rnormal()*`sig_n'
		gen double `prefix'v_var=`mean_v'+rnormal()*`sig_v'
		gen double `prefix't_var=`mean_t'+rnormal()*`sig_t'
		
		gen byte   `prefix'pi_si=runiform()<=`pi_s'
		gen byte   `prefix'pi_vi=runiform()<=`pi_v'
		gen byte   `prefix'pi_ri=runiform()<=`pi_r'
		
		gen double `prefix'r_var=`prefix'e_var                                                if `prefix'pi_ri==1 & `prefix'pi_vi==1
		   replace `prefix'r_var=`prefix'e_var+`rho_r'*(`prefix'e_var-`mean_e')+`prefix'v_var if `prefix'pi_ri==1 & `prefix'pi_vi==0
		   replace `prefix'r_var=`prefix't_var                                                if `prefix'pi_ri==0 
		gen double `prefix's_var=`prefix'e_var                                                if `prefix'pi_si==1
		   replace `prefix's_var=`prefix'e_var+`rho_s'*(`prefix'e_var-`mean_e')+`prefix'n_var if `prefix'pi_si==0 
		gen byte   `prefix'l_var= `prefix'r_var == `prefix's_var
		
		   }
	label_vars, prefix(`prefix')	   
end

program define ky_sim7cv
version 14
syntax [if],   [est_sto(str) est_sav(str) prefix(str)  replace ] // Probability of each type of data being created.
	qui {	 
	** set observations
		tempvar pi_s   pi_r   pi_w   pi_v   
		tempvar mean_e mean_n mean_t mean_w mean_v 
		tempvar sig_e  sig_n  sig_t  sig_w  sig_v 
		tempvar rho_w  rho_s  rho_r
		qui {
			predictnl double `pi_s'  =(invlogit(xb(lpi_s)))  `if'
			predictnl double `pi_r'  =(invlogit(xb(lpi_r))) `if'
			predictnl double `pi_w'  =(invlogit(xb(lpi_w))) `if'
			predictnl double `mean_e'=(xb(mu_e))		`if'
			predictnl double `mean_n'=(xb(mu_n)) `if'
			predictnl double `mean_w'=(xb(mu_w)) `if'
			predictnl double `mean_t'=(xb(mu_t)) `if'
			predictnl double `sig_e' =(exp(xb(ln_sig_e)))		 `if'
			predictnl double `sig_n' =(exp(xb(ln_sig_n))) `if'
			predictnl double `sig_w' =(exp(xb(ln_sig_w))) `if'
			predictnl double `sig_t' =(exp(xb(ln_sig_t))) `if'
			predictnl double `rho_s' =(tanh(xb(arho_s))) `if'
			predictnl double `rho_w' =(tanh(xb(arho_w))) `if'
		}
		tempname ewcorr
	** generating latent variables
		if "`replace'"!="" {
		    drop_ky_sim, prefix(`prefix')
		}		
		gen double `prefix'e_var=`mean_e'+rnormal()*`sig_e'
		gen double `prefix'w_var=`mean_w'+`rho_w'*`sig_w'/`sig_e'*(`prefix'e_var-`mean_e')+rnormal()*sqrt(1-`rho_w'^2)*`sig_w'
		
		gen double `prefix'n_var=`mean_n'+rnormal()*`sig_n'
		gen double `prefix't_var=`mean_t'+rnormal()*`sig_t'
		
		gen byte   `prefix'pi_si=runiform()<=`pi_s'
		gen byte   `prefix'pi_wi=runiform()<=`pi_w'
		gen byte   `prefix'pi_ri=runiform()<=`pi_r'
		
		gen double `prefix'r_var=`prefix'e_var  if `prefix'pi_ri==1
		   replace `prefix'r_var=`prefix't_var  if `prefix'pi_ri==0 
		gen double `prefix's_var=`prefix'e_var  if `prefix'pi_si==1
	       replace `prefix's_var=`prefix'e_var+(`rho_s')*(`prefix'e_var-`mean_e')+`prefix'n_var               if `prefix'pi_si==0 & `prefix'pi_wi==0
	       replace `prefix's_var=`prefix'e_var+(`rho_s')*(`prefix'e_var-`mean_e')+`prefix'n_var+`prefix'w_var if `prefix'pi_si==0 & `prefix'pi_wi==1
		gen byte   `prefix'l_var= `prefix'r_var == `prefix's_var
		   
	   }
	label_vars, prefix(`prefix')   
end

program define ky_sim8cv
version 14
syntax [if],  [est_sto(str) est_sav(str) prefix(str) replace ] // Probability of each type of data being created.
	qui {	 
		** set observations
		tempvar pi_s   pi_r   pi_w   pi_v   
		tempvar mean_e mean_n mean_t mean_w mean_v 
		tempvar sig_e  sig_n  sig_t  sig_w  sig_v 
		tempvar rho_s  rho_r  rho_w
		 qui {
			predictnl double `pi_s'  =(invlogit(xb(lpi_s))) 
			predictnl double `pi_r'  =(invlogit(xb(lpi_r))) 
			predictnl double `pi_w'  =(invlogit(xb(lpi_w))) 
			predictnl double `pi_v'  =(invlogit(xb(lpi_v))) 
			predictnl double `mean_e'=(xb(mu_e))		
			predictnl double `mean_n'=(xb(mu_n))
			predictnl double `mean_w'=(xb(mu_w))
			predictnl double `mean_t'=(xb(mu_t))
			predictnl double `mean_v'=(xb(mu_v))
			predictnl double `sig_e' =(exp(xb(ln_sig_e)))		
			predictnl double `sig_n' =(exp(xb(ln_sig_n)))
			predictnl double `sig_w' =(exp(xb(ln_sig_w)))
			predictnl double `sig_t' =(exp(xb(ln_sig_t)))
			predictnl double `sig_v' =(exp(xb(ln_sig_v)))
			predictnl double `rho_s' =(tanh(xb(arho_s)))
			predictnl double `rho_r' =(tanh(xb(arho_r)))
			predictnl double `rho_w' =(tanh(xb(arho_w)))
		}
		** generating latent variables
		gen double `prefix'e_var=`mean_e'+rnormal()*`sig_e'  `if' 
		gen double `prefix'w_var=`mean_w'+`rho_w'*`sig_w'/`sig_e'*(`prefix'e_var-`mean_e')+rnormal()*sqrt(1-`rho_w'^2)*`sig_w' `if'
		*gen double `prefix'e_var=`mean_e'+rnormal()*`sig_e' 
		gen double `prefix'n_var=`mean_n'+rnormal()*`sig_n' `if'
		*gen double `prefix'w_var=`mean_w'+rnormal()*`sig_w' 
		gen double `prefix'v_var=`mean_v'+rnormal()*`sig_v' `if'
		gen double `prefix't_var=`mean_t'+rnormal()*`sig_t' `if'
		
		gen byte  `prefix'pi_ri=runiform()<=`pi_r' `if'
		gen byte  `prefix'pi_si=runiform()<=`pi_s' `if'
		gen byte  `prefix'pi_wi=runiform()<=`pi_w' `if'
		gen byte  `prefix'pi_vi=runiform()<=`pi_v' `if'
		
		
		gen double `prefix'r_var=`prefix'e_var                                                 				if `prefix'pi_ri==1 & `prefix'pi_vi==1   
		   replace `prefix'r_var=`prefix'e_var+`rho_r'*(`prefix'e_var-`mean_e')+`prefix'v_var  				if `prefix'pi_ri==1 & `prefix'pi_vi==0
		   replace `prefix'r_var=`prefix't_var                                                 				if `prefix'pi_ri==0 
		gen double `prefix's_var=`prefix'e_var                                                 				if `prefix'pi_si==1
		   replace `prefix's_var=`prefix'e_var+`rho_s'*(`prefix'e_var-`mean_e')+`prefix'n_var       		if `prefix'pi_si==0 & `prefix'pi_wi==0
		   replace `prefix's_var=`prefix'e_var+`rho_s'*(`prefix'e_var-`mean_e')+`prefix'n_var+`prefix'w_var if `prefix'pi_si==0 & `prefix'pi_wi==1
		gen byte   `prefix'l_var= `prefix'r_var == `prefix's_var 
		   }
	label_vars, prefix(`prefix')	   
end


program define ky_sim9cv
version 14
syntax [if],  [est_sto(str) est_sav(str) prefix(str) replace ] // Probability of each type of data being created.
	qui {	 
		** set observations
		tempvar pi_s   pi_w   pi_v   
		tempvar mean_e mean_n mean_w mean_v 
		tempvar sig_e  sig_n  sig_w  sig_v 
		tempvar rho_s  rho_r
		qui {
			predictnl double `pi_s'  =(invlogit(xb(lpi_s)))  `if'
			predictnl double `pi_w'  =(invlogit(xb(lpi_w)))  `if'
			predictnl double `pi_v'  =(invlogit(xb(lpi_v)))  `if'
			predictnl double `mean_e'=(xb(mu_e))	 `if'	
			predictnl double `mean_n'=(xb(mu_n)) `if'
			predictnl double `mean_w'=(xb(mu_w)) `if'
			predictnl double `mean_v'=(xb(mu_v)) `if'
			predictnl double `sig_e' =(exp(xb(ln_sig_e))) `if'
			predictnl double `sig_n' =(exp(xb(ln_sig_n))) `if'
			predictnl double `sig_w' =(exp(xb(ln_sig_w))) `if'
			predictnl double `sig_v' =(exp(xb(ln_sig_v))) `if'
			predictnl double `rho_s' =(tanh(xb(arho_s))) `if'
			predictnl double `rho_r' =(tanh(xb(arho_r))) `if'
		}
		** generating latent variables
		if "`replace'"!="" {
		    drop_ky_sim, prefix(`prefix')
		}		
		gen double `prefix'e_var=`mean_e'+rnormal()*`sig_e'
		gen double `prefix'n_var=`mean_n'+rnormal()*`sig_n'
		gen double `prefix'w_var=`mean_w'+rnormal()*`sig_w'
		gen double `prefix'v_var=`mean_v'+rnormal()*`sig_v'
				
		gen byte  `prefix'pi_si=runiform()<=`pi_s'
		gen byte  `prefix'pi_wi=runiform()<=`pi_w'
		gen byte  `prefix'pi_vi=runiform()<=`pi_v'
				
		gen double `prefix'r_var=`prefix'e_var                                                 				if `prefix'pi_vi==1
		   replace `prefix'r_var=`prefix'e_var+`rho_r'*(`prefix'e_var-`mean_e')+`prefix'v_var  				if `prefix'pi_vi==0
		
		gen double `prefix's_var=`prefix'e_var                                                 				if `prefix'pi_si==1
		   replace `prefix's_var=`prefix'e_var+`rho_s'*(`prefix'e_var-`mean_e')+`prefix'n_var       		if `prefix'pi_si==0 & `prefix'pi_wi==0
		   replace `prefix's_var=`prefix'e_var+`rho_s'*(`prefix'e_var-`mean_e')+`prefix'n_var+`prefix'w_var if `prefix'pi_si==0 & `prefix'pi_wi==1
		gen byte   `prefix'l_var= `prefix'r_var == `prefix's_var
		   
		   }
	label_vars, prefix(`prefix')	   
end
