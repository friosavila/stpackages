*! v1.51 4/2022  FRA Version 14
* v1.5 09/13/2021  FRA Adding model 9
** No apparent changes
* v1.1 11/12/2020  FRA Now accepts different rvar svar lvar. Hidden option.
* v1.0 9/28/2020  FRA Module to obtain xi predictions. 

*************************************************************
** program for the estimation of within cla_s bias and unbiased estimators.
** Required. Within cla_s Probabilities
** In theory this has ALL cases. SO next. do for reduced cases.
*************************************************************

** predict all needed variances and covariances
** Generating model parameters
** This corrects for type...

program ky_star, 
version 14

// rvar svar and lvar will be hidden options for simulation purposes only
syntax [if],  [prefix(name) replace surv_only rvar(varname) svar(varname) lvar(varname)]
	
	if "`e(cmd)'"!="ky_fit" {
		error 301
	}
	
	if "`rvar'`svar'`lvar'"=="" {
		** This will detect all variables of interest (r s l)
		local dpvar `e(depvar)'
		gettoken _r dpvar:dpvar 
		gettoken _s dpvar:dpvar 
		local _l `dpvar'
	}
	else {
	    local _r `rvar'
		local _s `svar'
		local _l `lvar'
	}
	if "`prefix'"=="" {
	    local prefix _
	}
	tempvar tose 
	qui:gen byte `tose'=0 
	qui:replace  `tose'=1 `if'
	
	if "`surv_only'"=="" {
		qui {
	** This tries to create the variables.
			foreach i in ys1 ys1b ys2 ys2b ys3 ys3b ys4 {
			    local cnt =`cnt'+1
				if "`replace'" == "" {
					gen double `prefix'`cnt'=.
				}
				else {
					capture gen double `prefix'`cnt'=.
					capture replace    `prefix'`cnt'=.
				}	
				local `i' `prefix'`cnt'
			}

			foreach i in  pi_s   pi_r   pi_w   pi_v           ///
						  mean_e mean_n mean_t mean_w mean_v  ///
						  sig_e  sig_n  sig_t  sig_w  sig_v   ///
						  rho_s  rho_r  rho_w  {
							  tempvar _`i'
							  error 0
							  capture:qui:ky_p double `_`i'', `i'
							  if _rc!=0 {
								local _`i' 0
								if "`i'"=="pi_v" | "`i'"=="pi_r" {
									local _`i' 1
								}
								
							  }
						  }
			** Generating within cla_s moments Mean and variances			  
			** From here predict conditional means and variances
			tempvar mean_r1 mean_r2 mean_r3
			tempvar mean_s1 mean_s2 mean_s3
			*** Means
			gen double `mean_r1'= (`_mean_e')
			gen double `mean_r2'= (`_mean_e'+`_mean_v')
			gen double `mean_r3'= (`_mean_t')

			gen double `mean_s1'= (`_mean_e')
			gen double `mean_s2'= (`_mean_e'+`_mean_n')
			gen double `mean_s3'= (`_mean_e'+`_mean_n'+`_mean_w')
			*** variances
			tempvar sig2_r1 sig2_r2 sig2_r3
			tempvar sig2_s1 sig2_s2 sig2_s3

			gen double `sig2_r1' = `_sig_e'^2
			gen double `sig2_r2' = (1+`_rho_r')^2*`_sig_e'^2+`_sig_v'^2
			gen double `sig2_r3' = `_sig_t'^2
 
			gen double `sig2_s1' = `_sig_e'^2
			gen double `sig2_s2' = (1+`_rho_s')^2*`_sig_e'^2+`_sig_n'^2
			gen double `sig2_s3' = (1+`_rho_s')^2*`_sig_e'^2+`_sig_n'^2  +`_sig_w'^2 + 2*(1+`_rho_s')*`_rho_w'*`_sig_e'*`_sig_w'
			*** covariances
			tempvar cov_e_r1 cov_e_r2 cov_e_r3
			tempvar cov_e_s1 cov_e_s2 cov_e_s3
								 
			gen double `cov_e_r1' = `_sig_e'^2
			gen double `cov_e_r2' = (1+`_rho_r')*`_sig_e'^2
			gen double `cov_e_r3' = 0

			gen double `cov_e_s1' = `_sig_e'^2
			gen double `cov_e_s2' =  (1+`_rho_s')*`_sig_e'^2
			gen double `cov_e_s3' =  (1+`_rho_s')*`_sig_e'^2 + `_rho_w'*`_sig_e'*`_sig_w'

			*** covariances r and s

			tempvar cov_r1_s1 cov_r1_s2 cov_r1_s3
			tempvar cov_r2_s1 cov_r2_s2 cov_r2_s3
			tempvar cov_r3_s1 cov_r3_s2 cov_r3_s3

			gen double `cov_r1_s1' =`_sig_e'^2
			gen double `cov_r1_s2' =(1+`_rho_s')*`_sig_e'^2
			gen double `cov_r1_s3' =(1+`_rho_s')*`_sig_e'^2+`_rho_w'*`_sig_e'*`_sig_w'

			gen double `cov_r2_s1' =(1+`_rho_r')*`_sig_e'^2
			gen double `cov_r2_s2' =(1+`_rho_r')*(1+`_rho_s')*`_sig_e'^2
			gen double `cov_r2_s3' =(1+`_rho_r')*(1+`_rho_s')*`_sig_e'^2+(1+`_rho_r')*`_rho_w'*`_sig_e'*`_sig_w'

			local cov_r3_s1 0
			local cov_r3_s2 0
			local cov_r3_s3 0
			** Generating within R and S cla_s probabilities unconditional 
			** by Cla_s Probabilities

			tempvar _pr1 _pr2 _pr3
			tempvar _ps1 _ps2 _ps3
			gen double `_pr1' = `_pi_r' * `_pi_v'
			gen double `_pr2' = `_pi_r' * (1 - `_pi_v')
			gen double `_pr3' = 1 - `_pi_r'

			gen double `_ps1' = `_pi_s'
			gen double `_ps2' = (1-`_pi_s')*(1-`_pi_w')
			gen double `_ps3' = (1-`_pi_s')*   `_pi_w'

			** Within cla_s 1-9
			local pi_1 (`_pr1'*`_ps1')
			local pi_2 (`_pr1'*`_ps2')
			local pi_3 (`_pr1'*`_ps3')
			local pi_4 (`_pr2'*`_ps1')
			local pi_5 (`_pr2'*`_ps2')
			local pi_6 (`_pr2'*`_ps3')
			local pi_7 (`_pr3'*`_ps1')
			local pi_8 (`_pr3'*`_ps2')
			local pi_9 (`_pr3'*`_ps3')

			*** overall moments
			*** Variance and covariances overall but conditional on X:

			tempvar mean_r  mean_s
			tempvar sig2_r  sig2_s
			tempvar cov_e_r cov_e_s
			tempvar cov_r_s 

			gen double `mean_r'=`_pr1'*`mean_r1'+`_pr2'*`mean_r2'+`_pr3'*`mean_r3'
			gen double `mean_s'=`_ps1'*`mean_s1'+`_ps2'*`mean_s2'+`_ps3'*`mean_s3'

			gen double `sig2_r'=((`_pr1'*`sig2_r1'+`_pr2'*`sig2_r2'+`_pr3'*`sig2_r3') + ///
								`_pr1'*(`mean_r1'-`mean_r')^2+`_pr2'*(`mean_r2'-`mean_r')^2 + `_pr3'*(`mean_r3'-`mean_r')^2) 
			 
			gen double `sig2_s'=((`_ps1'*`sig2_s1'+`_ps2'*`sig2_s2'+`_ps3'*`sig2_s3') + ///
								`_ps1'*(`mean_s1'-`mean_s')^2+`_ps2'*(`mean_s2'-`mean_s')^2 +`_ps3'*(`mean_s3'-`mean_s')^2)
						
			gen double `cov_e_r'=(`_pr1'*`cov_e_r1'+`_pr2'*`cov_e_r2'+`_pr3'*`cov_e_r3')
			gen double `cov_e_s'=(`_ps1'*`cov_e_s1'+`_ps2'*`cov_e_s2'+`_ps3'*`cov_e_s3')

			gen double `cov_r_s'=`pi_1'*`cov_r1_s1'+`pi_2'*`cov_r1_s2'+`pi_3'*`cov_r1_s3'+ ///
								 `pi_4'*`cov_r2_s1'+`pi_5'*`cov_r2_s2'+`pi_6'*`cov_r2_s3'+ ///
								 `pi_7'*`cov_r3_s1'+`pi_8'*`cov_r3_s2'+`pi_9'*`cov_r3_s3'

			********************************************************************************
			********************************************************************************					 
			** First Within cla_s elements
			** latent e/xi_j for j=1...9
			tempvar xi_1 xi_2 xi_3
			tempvar xi_4 xi_5 xi_6
			tempvar xi_7 xi_8 xi_9

			** Here a question... should i use _r+_s?
			** Was never explicit in KY so i ll use _r a_suming is the best measure
			** It shouldnt matter for ML (unless delta is large). It will matter for star
			** because unconditional weighting matters. If unconditional...then we do not observe pi_1?
			gen double `xi_1'= (`_r'+ `_s')/2
			gen double `xi_2'=`_r'
			gen double `xi_3'=`_r'
			gen double `xi_4'=`_s'

			*** First complicated case. Either r2 or s2

			local a `cov_e_r2'
			local b `cov_e_s2'

			local c `sig2_r2'
			local d `cov_r2_s2'
			local e `sig2_s2'
			local f (`_r'-`mean_r2')
			local g (`_s'-`mean_s2')


			gen double `xi_5'=`_mean_e'+(`f'*(`a'*`e'-`b'*`d')+`g'*(`b'*`c'-`a'*`d')) ///
										/(`c'*`e'-`d'*`d')
			*** Second complicated case. Either r2 or s3
			local a `cov_e_r2'
			local b `cov_e_s3'
			local c `sig2_r3'
			local d `cov_r2_s3'
			local e `sig2_s2'
			local f (`_r'-`mean_r2')
			local g (`_s'-`mean_s3')

							 
			gen double `xi_6'=`_mean_e'+(`f'*(`a'*`e'-`b'*`d')+`g'*(`b'*`c'-`a'*`d')) ///
										/(`c'*`e'-`d'*`d')

			gen double `xi_7'=`_s'
			** Just like before
			gen double `xi_8'=`_mean_e'+`cov_e_s2'/`sig2_s2' * (`_s' - `mean_s2')
			gen double `xi_9'=`_mean_e'+`cov_e_s3'/`sig2_s3' * (`_s' - `mean_s3')

			***************************
			***************************
			***************************
			** For the unbiased..a_sume sigmas are zero

			tempvar xi_5b xi_6b
			tempvar xi_8b xi_9b

			tempvar d1 d2
			local tr2 (1/(1+`_rho_r'))
			local ts2 (1/(1+`_rho_s'))
			local ts3 (1/(1+`_rho_s'+`_rho_w'*`_sig_w'/`_sig_e'))

			gen double `d1' = (`tr2'*`cov_e_r2'-`ts2'*`cov_e_s2'-`tr2'*`ts2'*`cov_r2_s2'+`ts2'^2*`sig2_s2')/ ///
							  (`tr2'^2 * `sig2_r2' - 2*`tr2'*`ts2'*`cov_r2_s2' +`ts2'^2 * `sig2_s2' )	
			gen double `d2' = (`tr2'*`cov_e_r2'-`ts3'*`cov_e_s3'-`tr2'*`ts3'*`cov_r2_s3'+`ts3'^2*`sig2_s3')/ ///
							  (`tr2'^2 * `sig2_r2' - 2*`tr2'*`ts3'*`cov_r2_s3' +`ts3'^2 * `sig2_s3' )	
							  
			gen double `xi_5b' = `_mean_e' + `tr2' * `d1' * (`_r' - `mean_r2') + `ts2'*(1-`d1') * (`_s' - `mean_s2')
			gen double `xi_6b' = `_mean_e' + `tr2' * `d2' * (`_r' - `mean_r2') + `ts3'*(1-`d2') * (`_s' - `mean_s3')
							  
			gen double `xi_8b' = `_mean_e' + `ts2' * (`_s' - `mean_s2')
			gen double `xi_9b' = `_mean_e' + `ts3' * (`_s' - `mean_s3')


			*****************************
			**** Overall 			

			local a `cov_e_r'
			local b `cov_e_s'
			local c `sig2_r'
			local d `cov_r_s'
			local e `sig2_s'
			local f (`_r'-`mean_r')
			local g (`_s'-`mean_s')

			tempvar xi_all 
			gen double `xi_all'=`_mean_e'+ (  `f'*( `a'*`e' - `b'*`d')    ///
											 +`g'*(-`a'*`d' + `b'*`c')  ) ///
												/(`c'*`e'-`d'*`d')					 	
			
		**** Estimation of pip or conditional probabilities by cla_s
			local _rho_r1s1  1
			tempvar _rho_r1s2 _rho_r1s3 _rho_r2s1 _rho_r2s2 _rho_r2s3
			
			gen double `_rho_r1s2' = `cov_r1_s2'/sqrt(`sig2_r1'*`sig2_s2')
			gen double `_rho_r1s3' = `cov_r1_s3'/sqrt(`sig2_r1'*`sig2_s3')
			gen double `_rho_r2s1' = `cov_r2_s1'/sqrt(`sig2_r2'*`sig2_s1')
			gen double `_rho_r2s2' = `cov_r2_s2'/sqrt(`sig2_r2'*`sig2_s2')
			gen double `_rho_r2s3' = `cov_r2_s3'/sqrt(`sig2_r2'*`sig2_s3')
			local _rho_r3s1  0
			local _rho_r3s2  0
			local _rho_r3s3  0

			local _std_r1 ((`_r'-`mean_r1')/sqrt(`sig2_r1'))
			local _std_r2 ((`_r'-`mean_r2')/sqrt(`sig2_r2'))
			local _std_r3 ((`_r'-`mean_r3')/sqrt(`sig2_r3'))
			local _std_s1 ((`_s'-`mean_s1')/sqrt(`sig2_s1'))
			local _std_s2 ((`_s'-`mean_s2')/sqrt(`sig2_s2'))
			local _std_s3 ((`_s'-`mean_s3')/sqrt(`sig2_s3'))
						
			tempvar _pip_1 _pip_2 _pip_3 _pip_4 _pip_5 _pip_6 _pip_7 _pip_8 _pip_9
			gen double `_pip_2'=`pi_2'*(1/(2*_pi*sqrt(`sig2_r1'*`sig2_s2')*sqrt(1-`_rho_r1s2'^2))*exp(-1/(2*(1-`_rho_r1s2'^2))*(`_std_r1'^2+`_std_s2'^2-2*`_rho_r1s2'*`_std_r1'*`_std_s2')))
			gen double `_pip_3'=`pi_3'*(1/(2*_pi*sqrt(`sig2_r1'*`sig2_s3')*sqrt(1-`_rho_r1s3'^2))*exp(-1/(2*(1-`_rho_r1s3'^2))*(`_std_r1'^2+`_std_s3'^2-2*`_rho_r1s3'*`_std_r1'*`_std_s3'))) 
			gen double `_pip_4'=`pi_4'*(1/(2*_pi*sqrt(`sig2_r2'*`sig2_s1')*sqrt(1-`_rho_r2s1'^2))*exp(-1/(2*(1-`_rho_r2s1'^2))*(`_std_r2'^2+`_std_s1'^2-2*`_rho_r2s1'*`_std_r2'*`_std_s1'))) 
			gen double `_pip_5'=`pi_5'*(1/(2*_pi*sqrt(`sig2_r2'*`sig2_s2')*sqrt(1-`_rho_r2s2'^2))*exp(-1/(2*(1-`_rho_r2s2'^2))*(`_std_r2'^2+`_std_s2'^2-2*`_rho_r2s2'*`_std_r2'*`_std_s2'))) 
			gen double `_pip_6'=`pi_6'*(1/(2*_pi*sqrt(`sig2_r2'*`sig2_s3')*sqrt(1-`_rho_r2s3'^2))*exp(-1/(2*(1-`_rho_r2s3'^2))*(`_std_r2'^2+`_std_s3'^2-2*`_rho_r2s3'*`_std_r2'*`_std_s3'))) 
			gen double `_pip_7'=`pi_7'*(normalden(`_r',`mean_r3',sqrt(`sig2_r3'))*normalden(`_s',`mean_s1',sqrt(`sig2_s1')))
			gen double `_pip_8'=`pi_8'*(normalden(`_r',`mean_r3',sqrt(`sig2_r3'))*normalden(`_s',`mean_s2',sqrt(`sig2_s2')))
			gen double `_pip_9'=`pi_9'*(normalden(`_r',`mean_r3',sqrt(`sig2_r3'))*normalden(`_s',`mean_s3',sqrt(`sig2_s3')))
			
			forvalues i=2/9 {
				** if doesnt exist, very likely it is equal to zero, thus undefined.
				replace `_pip_`i''=0  if `_pip_`i''==.
			}
			
			tempvar pip_1 pip_2 pip_3 pip_4 pip_5 pip_6 pip_6 pip_7 pip_8 pip_9
			gen double `pip_1'=(`_l'==1)
			gen double `pip_2'=(`_l'==0)*`_pip_2'/(`_pip_2'+`_pip_3'+`_pip_4'+`_pip_5'+`_pip_6'+`_pip_7'+`_pip_8'+`_pip_9') 
			gen double `pip_3'=(`_l'==0)*`_pip_3'/(`_pip_2'+`_pip_3'+`_pip_4'+`_pip_5'+`_pip_6'+`_pip_7'+`_pip_8'+`_pip_9') 
			gen double `pip_4'=(`_l'==0)*`_pip_4'/(`_pip_2'+`_pip_3'+`_pip_4'+`_pip_5'+`_pip_6'+`_pip_7'+`_pip_8'+`_pip_9') 
			gen double `pip_5'=(`_l'==0)*`_pip_5'/(`_pip_2'+`_pip_3'+`_pip_4'+`_pip_5'+`_pip_6'+`_pip_7'+`_pip_8'+`_pip_9') 
			gen double `pip_6'=(`_l'==0)*`_pip_6'/(`_pip_2'+`_pip_3'+`_pip_4'+`_pip_5'+`_pip_6'+`_pip_7'+`_pip_8'+`_pip_9') 
			
			gen double `pip_7'=(`_l'==0)*`_pip_7'/(`_pip_2'+`_pip_3'+`_pip_4'+`_pip_5'+`_pip_6'+`_pip_7'+`_pip_8'+`_pip_9') 
			gen double `pip_8'=(`_l'==0)*`_pip_8'/(`_pip_2'+`_pip_3'+`_pip_4'+`_pip_5'+`_pip_6'+`_pip_7'+`_pip_8'+`_pip_9') 
			gen double `pip_9'=(`_l'==0)*`_pip_9'/(`_pip_2'+`_pip_3'+`_pip_4'+`_pip_5'+`_pip_6'+`_pip_7'+`_pip_8'+`_pip_9') 
 
			*** Corrections for models 1 and 2
			if e(method_c)==1 | e(method_c)==2 {
				replace `pip_1'  =1
				replace `xi_all' =`_r'
				forvalues i=2/9 {
					replace `pip_`i''  =0
				}
			}
			
			tempvar _high
			gen double `_high'=.
			replace `_high'=`pip_1' 
			
			
			tempvar class
			gen byte `class'=1 if `pip_1'==1
			forvalues i=2/9 {
				replace `class'=`i'         if `pip_`i''>`_high' & `_l'==0
				replace `_high'  =`pip_`i'' if `pip_`i''>`_high' & `_l'==0
			}

			*** ** unconditional
		/*	replace `ys1' =(`_l'==1) * `xi_1' +(`_l'==0) * (`pi_2' * `xi_2' + `pi_3' * `xi_3' + ///
							`pi_4' * `xi_4' + `pi_5' * `xi_5' + `pi_6' * `xi_6' + ///
							`pi_7' * `xi_7' + `pi_8' * `xi_8' + `pi_9' * `xi_9')/(1-`pi_1')
			
			replace `ys1b'=(`_l'==1) * `xi_1' +(`_l'==0) * (`pi_2' * `xi_2' + `pi_3' * `xi_3' + ///
							`pi_4' * `xi_4' + `pi_5' * `xi_5b'+ `pi_6' * `xi_6b' + ///
							`pi_7' * `xi_7' + `pi_8' * `xi_8b'+ `pi_9' * `xi_9b')/(1-`pi_1')*/
			
			replace `ys1' =`pi_1' * `xi_1' + `pi_2' * `xi_2' + `pi_3' * `xi_3' + ///
							`pi_4' * `xi_4' + `pi_5' * `xi_5' + `pi_6' * `xi_6' + ///
							`pi_7' * `xi_7' + `pi_8' * `xi_8' + `pi_9' * `xi_9'
			
			replace `ys1b'=`pi_1' * `xi_1' + `pi_2' * `xi_2' + `pi_3' * `xi_3' + ///
							`pi_4' * `xi_4' + `pi_5' * `xi_5b'+ `pi_6' * `xi_6b' + ///
							`pi_7' * `xi_7' + `pi_8' * `xi_8b'+ `pi_9' * `xi_9b'
	
			** conditional or using posterior probabilities
		 
			replace `ys2' =`pip_1' * `xi_1' + `pip_2' * `xi_2' + `pip_3' * `xi_3' + ///
							`pip_4' * `xi_4' + `pip_5' * `xi_5' + `pip_6' * `xi_6' + ///
							`pip_7' * `xi_7' + `pip_8' * `xi_8' + `pip_9' * `xi_9'
			
			replace `ys2b'=`pip_1' * `xi_1' + `pip_2' * `xi_2' + `pip_3' * `xi_3' + ///
							`pip_4' * `xi_4' + `pip_5' * `xi_5b'+ `pip_6' * `xi_6b' + ///
							`pip_7' * `xi_7' + `pip_8' * `xi_8b'+ `pip_9' * `xi_9b'
		 
			** twostep. Based on optimal assignment
			replace `ys3' =(`class'==1) * `xi_1' + (`class'==2) * `xi_2' + (`class'==3) * `xi_3' + ///
							(`class'==4) * `xi_4' + (`class'==5) * `xi_5' + (`class'==6) * `xi_6' + ///
							(`class'==7) * `xi_7' + (`class'==8) * `xi_8' + (`class'==9) * `xi_9'
			replace `ys3b'=(`class'==1) * `xi_1' + (`class'==2) * `xi_2' + (`class'==3) * `xi_3' + ///
							(`class'==4) * `xi_4' + (`class'==5) * `xi_5b' + (`class'==6) * `xi_6b' + ///
							(`class'==7) * `xi_7' + (`class'==8) * `xi_8b' + (`class'==9) * `xi_9b'
			
			** Here I estimate system wide predictions
			replace `ys4' = `xi_all'
			
			label var `ys1'  "Weighted unconditional prediction for e" 
			label var `ys1b' "Weighted unconditional, unbiased prediction for e" 
			label var `ys2'  "Weighted conditional prediction for e" 
			label var `ys2b' "Weighted conditional, unbiased prediction for e" 
			label var `ys3'  "Two-stage prediction for e" 
			label var `ys3b' "Two-stage, unbiased prediction for e" 
			label var `ys4'  "System-wide, linear prediction for e" 
			
			foreach i in  ys1 ys1b ys2 ys2b ys3 ys3b ys4 {
			    replace ``i''=. if `tose'==0
			}
		}	
	}
	if "`surv_only'"!="" {
		qui {
			foreach i in ys1 ys1b ys2 ys2b ys3 ys3b ys4 {
			    local cnt =`cnt'+1
				if "`replace'" == "" {
					gen double `prefix'`cnt'=.
				}
				else {
					capture gen double `prefix'`cnt'=.
					capture replace    `prefix'`cnt'=.
				}	
				local `i' `prefix'`cnt'
			}

			foreach i in  pi_s   pi_w   ///
						  mean_e mean_n mean_w ///
						  sig_e  sig_n  sig_w  ///
						  rho_s  rho_w  {
							tempvar _`i'
							error 0
							capture:qui:ky_p double `_`i'', `i'
							if _rc!=0 {
								local _`i' 0
								if "`i'"=="pi_v" | "`i'"=="pi_r" {
									local _`i' 1
								}
								
							}
						}
			
			*************************
			** Surv Only assumes we only have access to survey data. So predictors need to be based on this only
			tempvar mean_s1 mean_s2 mean_s3
			*** Means
			gen double `mean_s1'= (`_mean_e')
			gen double `mean_s2'= (`_mean_e'+`_mean_n')
			gen double `mean_s3'= (`_mean_e'+`_mean_n'+`_mean_w')
			*** variances
			tempvar sig2_s1 sig2_s2 sig2_s3
			gen double `sig2_s1' = `_sig_e'^2
			gen double `sig2_s2' = (1+`_rho_s')^2*`_sig_e'^2+`_sig_n'^2
			gen double `sig2_s3' = (1+`_rho_s')^2*`_sig_e'^2+`_sig_n'^2  +`_sig_w'^2 + 2*(1+`_rho_s')*`_rho_w'*`_sig_e'*`_sig_w'
			*** covariances
			tempvar cov_e_s1 cov_e_s2 cov_e_s3
			gen double `cov_e_s1' = `_sig_e'^2
			gen double `cov_e_s2' =  (1+`_rho_s')*`_sig_e'^2
			gen double `cov_e_s3' =  (1+`_rho_s')*`_sig_e'^2 + `_rho_w'*`_sig_e'*`_sig_w'

			** Generating within R and S cla_s probabilities unconditional 
			** by Cla_s Probabilities
			tempvar _ps1 _ps2 _ps3
			gen double `_ps1' = `_pi_s'
			gen double `_ps2' = (1-`_pi_s')*(1-`_pi_w')
			gen double `_ps3' = (1-`_pi_s')*   `_pi_w'

			*** overall moments
			*** Variance and covariances overall but conditional on X:
			tempvar mean_s
			tempvar sig2_s
			tempvar cov_e_s

			gen double `mean_s'=`_ps1'*`mean_s1'+`_ps2'*`mean_s2'+`_ps3'*`mean_s3'
			gen double `sig2_s'=((`_ps1'*`sig2_s1'+`_ps2'*`sig2_s2'+`_ps3'*`sig2_s3') + ///
								`_ps1'*(`mean_s1'-`mean_s')^2+`_ps2'*(`mean_s2'-`mean_s')^2 +`_ps3'*(`mean_s3'-`mean_s')^2)
			gen double `cov_e_s'=(`_ps1'*`cov_e_s1'+`_ps2'*`cov_e_s2'+`_ps3'*`cov_e_s3')
 
 
			********************************************************************************
			********************************************************************************					 
			** First Within cla_s elements
			** latent e/xi_j for j=1...9
			tempvar xi_1 xi_2  xi_3
			tempvar      xi_2b xi_3b
			** Here a question... should i use _r+_s? Was never explicit in KY so i ll use _r a_suming is the best measure
			gen double `xi_1'=`_r'
			gen double `xi_2'=`_mean_e'+`cov_e_s2'/`sig2_s2' * (`_s' - `mean_s2')
			gen double `xi_3'=`_mean_e'+`cov_e_s3'/`sig2_s3' * (`_s' - `mean_s3')
			local ts2 (1/(1+`_rho_s'))
			local ts3 (1/(1+`_rho_s'+`_rho_w'*`_sig_w'/`_sig_e'))
			gen double `xi_2b'=`_mean_e'+`ts2' * (`_s' - `mean_s2')
			gen double `xi_3b'=`_mean_e'+`ts3' * (`_s' - `mean_s3')
			 
			
			tempvar xi_all 
			gen double `xi_all'=`_mean_e'+`cov_e_s'/`sig2_s' * (`_s' - `mean_s')

		**** Estimation of pip or conditional probabilities by cla_s
			
			local _std_s1 ((`_s'-`mean_s1')/sqrt(`sig2_s1'))
			local _std_s2 ((`_s'-`mean_s2')/sqrt(`sig2_s2'))
			local _std_s3 ((`_s'-`mean_s3')/sqrt(`sig2_s3'))

			tempvar _pip_1 _pip_2 _pip_3 
			gen double `_pip_1'=`_ps1'*normalden(`_s',`mean_s1',sqrt(`sig2_s1'))
			gen double `_pip_2'=`_ps2'*normalden(`_s',`mean_s2',sqrt(`sig2_s2'))
			gen double `_pip_3'=`_ps3'*normalden(`_s',`mean_s3',sqrt(`sig2_s3'))
			
			forvalues i=2/3 {
				** if doesnt exist, very likely it is equal to zero, thus undefined.
				replace `_pip_`i''=0  if `_pip_`i''==.
			}
			
			tempvar pip_1 pip_2 pip_3 
			gen double `pip_1'=`_pip_1'/(`_pip_1'+`_pip_2'+`_pip_3')
			gen double `pip_2'=`_pip_2'/(`_pip_1'+`_pip_2'+`_pip_3')
			gen double `pip_3'=`_pip_3'/(`_pip_1'+`_pip_2'+`_pip_3')
			
			*** Corrections for models 1 and 2
			
			tempvar _high
			gen double `_high'=.
			replace `_high'=0
			tempvar class
			gen byte `class'=0 
			forvalues i=1/3 {
				replace `class'=`i'         if `pip_`i''>`_high'
				replace `_high'  =`pip_`i'' if `pip_`i''>`_high'
			}
			

			*** ** unconditional
			
			replace `ys1'  =`_ps1' * `xi_1' + `_ps2' * `xi_2'  + `_ps3' * `xi_3' 
			replace `ys1b' =`_ps1' * `xi_1' + `_ps2' * `xi_2b' + `_ps3' * `xi_3b' 
			
			** conditional or using posterior probabilities
		 
			replace `ys2'  =`pip_1' * `xi_1' + `pip_2' * `xi_2'  + `pip_3' * `xi_3' 
			replace `ys2b' =`pip_1' * `xi_1' + `pip_2' * `xi_2b' + `pip_3' * `xi_3b' 
			
		 
			** twostep. Based on optimal assignment
			replace `ys3' =(`class'==1) * `xi_1' + (`class'==2) * `xi_2' + (`class'==3) * `xi_3' 
			replace `ys3b'=(`class'==1) * `xi_1' + (`class'==2) * `xi_2b'+ (`class'==3) * `xi_3b'  
 
			
			** Here I estimate system wide predictions
			replace `ys4' = `xi_all'
			
			label var `ys1'  "Weighted unconditional prediction for e" 
			label var `ys1b' "Weighted unconditional, unbiased prediction for e" 
			label var `ys2'  "Weighted conditional prediction for e" 
			label var `ys2b' "Weighted conditional, unbiased prediction for e" 
			label var `ys3'  "Two-stage prediction for e" 
			label var `ys3b' "Two-stage, unbiased prediction for e" 
			label var `ys4'  "System-wide, linear prediction for e" 
			foreach i in  ys1 ys1b ys2 ys2b ys3 ys3b ys4 {
			    replace ``i''=. if `tose'==0
			}
		}				  
	}
end	
