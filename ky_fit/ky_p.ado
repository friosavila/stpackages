*! v2.3 3/08/2024.  (FRA) Changes on Names for Predicted values Rho_R
* v2.26 9/13/2021.  (FRA) Change to V14. 
* v2.25 9/13/2021.  (FRA) Adding Model 9
* v2.23 3/09/2021.  (FRA) Correcting Bug for PIP
* v2.22 9/21/2020.  (FRA) Corrected names when requesting sig_s(i) or sig_r(i). and adds sig_r(i) and sig_s(i) for models 1 and 2
* v2.21 7/24/2020.  (FRA) Fix typo from Rho_s to Rho r.
* v2.2  7/14/2020.  (FRA) adds model 8
* v2.12 7/13/2020.  (FRA) corrected for problem predicting values.
* v2.11 7/13/2020.  (FRA) adds Model 7. pip1-pip6 ready
* v2.1  7/12/2020.  (FRA) adds Model 7. PIP1-PIP6 are yet to be added
* v2 KY predictor. (FRA) Baseline
* Improved Predictor. It dropped unnecessary code, and now can be used for "Score"

program define ky_p 
    syntax anything(id="newvarname") [if] [in] , [star * ]
	
	version 14
	
	/*[pi_s pi_r pi_w pi_v  						/// Probabilities of each event
								   pi_r1 pi_r2 pi_r3 pi_s1 pi_s2 pi_s3  		/// Probabilities by category
								   pip_r1 pip_r2 pip_r3 pip_s1 pip_s2 pip_s3  	/// Probabilities by category. Posterior Prob
								   pi_1 pi_2 pi_3 pi_4 pi_5 pi_6 pi_7 pi_8 pi_9 /// Probabilities by group classification
								   pip_1 pip_2 pip_3 pip_4 pip_5 pip_6 pip_7 pip_8 pip_9 /// Probabilities by group classification
								   lf_1 lf_2 lf_3 lf_4 lf_5 lf_6 lf_7 lf_8 lf_9 ///
								   lf_s1 lf_s2 lf_s3 lf_r1 lf_r2 lf_r3  ///
								   rho_s rho_r 							  		/// RHO's (Regression to the mean factors)
								   mean_e  mean_n  mean_w  mean_t  mean_v 		/// Conditional Means
								   sig_e sig_n sig_w sig_t sig_v 	            /// conditional Standard deviations
								   mean_s1 mean_s2 mean_s3 sig_s1 sig_s2 sig_s3 /// intra group mean and sigma  
								   mean_r1 mean_r2 mean_r3 sig_r1 sig_r2 sig_r3 /// intra group mean and sigma 
 								   bclass 	*    ]*/
	*lf_r1 lf_r2 lf_r3 lf_s1 lf_s2 lf_s3   		  /// These will contain the Likelihood function by S/R type
	*lf_1 lf_2 lf_3 lf_4 lf_5 lf_6 lf_7 lf_8 lf_9 /// These will contain the Likelihood function by combination type
    marksample touse, novarlist
	*parse "`0'", parse(",")
	*local opts `3'
	** ky_p_1 to  ky_p_4 still missing. 
	if "`star'"!="" {
		ky_star, `options' prefix(`anything')
	}
    else if  e(method_c)==1 {
		ky_p_1 `0'
	}
	else if  e(method_c)==2 {
		ky_p_2 `0'
	}
	else if  e(method_c)==3 {
		ky_p_3 `0'
	}
	else if  e(method_c)==4 {
		ky_p_4 `0'
	}
	else if  e(method_c)==5 {
		ky_p_5 `0'
	}
	else if  e(method_c)==6 {
		ky_p_6 `0'
	}
	else if  e(method_c)==7 {
		ky_p_7 `0'
	}
	else if  e(method_c)==8 {
		ky_p_8 `0'
	}
	else if  e(method_c)==9 {
		ky_p_9 `0'
	}
	else if  e(method_c)==10 {
		ky_p_10 `0'
	}
	else { 
		display in red "error, method not allowed"
		exit 1
	}
end
** Note: I think it is now far more efficient!
program define ky_p_1 	
version 14
    syntax  anything(id="newvarname") [if] [in] , [pi_s  						/// Probabilities of each event
												   pi_s1 pi_s2 					/// Probabilities by category
												   pip_s1 pip_s2 				/// Probabilities by category, on S only.
												   rho_s  		    		    /// RHO's (Regression to the mean factors)
												   mean_e  mean_n  			    /// Conditional Means
  												   sig_r1 sig_s1 sig_s2         /// Conditional Sig for r1 s1 s2 
												   sig_e sig_n bclass_s	* ]     //  conditional Standard deviations
													
								    					 
    marksample touse, novarlist
 	*** getting dep variables
	tokenize "`e(depvar)'"
	local _r `1'
	local _s `2'
	local _l `3'
	*** This are all Basic variables. Everything else is constructed from this ones
	tempvar _pi_s   _pi_r   _pi_w   _pi_v   
	tempvar _mean_e _mean_n _mean_t _mean_w _mean_v 
	tempvar _sig_e  _sig_n  _sig_t  _sig_w  _sig_v 
	tempvar _rho_s _rho_r

	qui {
	** First Options that are not included above.	
		if "`options'"!="" {
			ml_p `0'
			exit
		}
	** then options that only depend on a single parameter
		else if "`mean_e'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_e)
			label var `varlist' "Conditional mean for component e"
		}
	    else if "`mean_n'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_n)
			label var `varlist' "Conditional mean for component n"
		}
		*** Sigmas
		else if "`sig_e'"!="" {
			_predict double `_sig_e' if `touse', xb eq(ln_sig_e)
		    syntax newvarname [if] [in] [, * ]
		    gen `typlist' `varlist'=exp(`_sig_e') if `touse'
			label var `varlist' "Conditional stdev for component e"
		}
		else if "`sig_n'"!="" {
			_predict double `_sig_n' if `touse', xb eq(ln_sig_n)
		    syntax newvarname [if] [in] [, * ]
		    gen `typlist' `varlist'=exp(`_sig_n') if `touse'
			label var `varlist' "Conditional stdev for component n"
		}
		else if "`rho_s'" != "" {
			_predict double `_rho_s' if `touse', xb eq(arho_s)
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=tanh(`_rho_s') if `touse'
			label var `varlist' "Rho s: RTM Survey data"
		}
		*** pi_s
		else if "`pi_s'" != "" {
			_predict double `_pi_s' if `touse', xb eq(lpi_s)
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=invlogit(`_pi_s') if `touse'
			label var `varlist' "A priori Pi_s"
		}
		** From here we have the ones that derive from everything else
		else if "`pi_s1'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist' if `touse', pi_s
			label var `varlist' "Latent Class pi s type 1"
		}
		else if "`pi_s2'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist' if `touse', pi_s
			replace `varlist'=1-`varlist'
			label var `varlist' "Latent Class pi s type 2"
		}
		** means by type
		else if "`mean_r1'"!="" {
		    syntax newvarname [if] [in] [, * ]
   			_predict `typlist' `varlist' if `touse', xb eq(mu_e)
			label var `varlist' "Conditional mean mean_r1"
		}
		else if "`mean_s1'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_e)
			label var `varlist' "Conditional mean mean_s1"
		}
		else if "`mean_s2'"!="" {
			_predict double `_mean_e' if `touse', xb eq(mu_e)
			_predict double `_mean_n' if `touse', xb eq(mu_n)
		    syntax newvarname [if] [in] [, * ]
		    gen `typlist' `varlist'=`_mean_e'+`_mean_n' if `touse'
			label var `varlist' "Conditional mean mean_s2"
		}
		else if "`sig_r1'"!="" {
			_predict double `_sig_e' if `touse', xb eq(ln_sig_e)
		    syntax newvarname [if] [in] [, * ]
		    gen `typlist' `varlist'=exp(`_sig_e') if `touse'
			label var `varlist' "Conditional sigma sig_r1"
		}
		else if "`sig_s1'"!="" {
			_predict double `_sig_e' if `touse', xb eq(ln_sig_e)
		    syntax newvarname [if] [in] [, * ]
		    gen `typlist' `varlist'=exp(`_sig_e') if `touse'
			label var `varlist' "Conditional sigma sig_s1"
		}
		else if "`sig_s2'"!="" {
			_predict double `_sig_e' if `touse', xb eq(ln_sig_e)
			_predict double `_sig_n' if `touse', xb eq(ln_sig_n)
			_predict double `_rho_s' if `touse', xb eq(arho_s)
			replace `_sig_e'=exp(`_sig_e')
			replace `_sig_n'=exp(`_sig_n')
			replace `_rho_s'=tanh(`_rho_s')
		    syntax newvarname [if] [in] [, * ]
		    gen `typlist' `varlist'=sqrt((1+`_rho_s')^2*`_sig_e'^2+`_sig_n'^2) if `touse'
			label var `varlist' "Conditional sigma sig_s2"
		}
		else if "`pip_s1'" != "" {
		    
			ky_p double `_pi_s' if `touse', pi_s
			ky_p double `_mean_e' if `touse', mean_e
			ky_p double `_mean_n' if `touse', mean_n
			ky_p double `_sig_e'  if `touse', sig_e
			ky_p double `_sig_n'  if `touse', sig_n
			ky_p double `_rho_s'  if `touse', rho_s
			** LL
			tempvar lls1 lls2
			gen double `lls1'=normalden(`_s',`_mean_e',`_sig_e') 
			gen double `lls2'=normalden(`_s',`_mean_e'+`_mean_n',sqrt((1+`_rho_s')^2*`_sig_e'^2+`_sig_n'^2))
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=(`_pi_s'*`lls1')/(`_pi_s'*`lls1'+(1-`_pi_s')*`lls2')
			label var `varlist' "Posterior Latent Class pi S-type 1"
		}
		else if "`pip_s2'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist' if `touse', pip_s1
			replace `varlist'=1-`varlist'
			label var `varlist' "Posterior Latent Class pi s type 2"
		}
	    else if "`bclass_s'"!="" {
			tempvar _pip_s1
			ky_p double `_pip_s1' if `touse', pip_s1
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=1+`_pip_s1'<.5 if `touse'
			label var `varlist' "two-step classification based on S only"
		}              
	}	
	// End qui
end
*********************** *********************** *********************** 

program define ky_p_2 	
version 14
    syntax anything(id="newvarname") [if] [in] ,  [pi_s pi_w    					/// Probabilities of each event
												   pi_s1 pi_s2 pi_s3  		        /// Probabilities by category
												   pip_s1 pip_s2 pip_s3  			/// Probabilities by category. Posterior Prob
												   rho_s 							/// RHO's (Regression to the mean factors)
												   mean_e mean_n mean_w  	 		/// Conditional Means
												   sig_e  sig_n  sig_w 	            /// conditional Standard deviations
												   sig_r1 sig_s1 sig_s2 sig_s3      /// Conditional Sig for r1 s1 s2 s3
												   bclass_s	* ]						//  two step classification if only S is observed
    marksample touse, novarlist
 	*** getting dep variables
	tokenize "`e(depvar)'"
	local _r `1'
	local _s `2'
	local _l `3'
	*** NOW ALL cases
	*** defining all elements:
	tempvar _pi_s   _pi_r   _pi_w   _pi_v   
	tempvar _mean_e _mean_n _mean_t _mean_w _mean_v 
	tempvar _sig_e  _sig_n  _sig_t  _sig_w  _sig_v 
	tempvar _rho_s _rho_r

	qui {
	    if "`options'"!="" {
			ml_p `0'
			exit
		}
		else if "`pi_s'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'=(invlogit(xb(lpi_s))) if `touse' 
			label var `varlist' "A priori Pi_s"
		}
		else if "`pi_w'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'=(invlogit(xb(lpi_w))) if `touse' 
			label var `varlist' "A priori Pi_w"
		}
		else if "`mean_e'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_e)
			label var `varlist' "Conditional mean for component e"
		}
	    else if "`mean_n'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_n)
			label var `varlist' "Conditional mean for component n"
		}
	    else if "`mean_w'"!="" {
		    syntax newvarname [if] [in] [, * ]
			_predict `typlist' `varlist' if `touse', xb eq(mu_w)
			label var `varlist' "Conditional mean for component w"
		}
		else if "`sig_e'"!="" {
		    syntax newvarname [if] [in] [, * ]
			_predict double `_sig_e', xb eq(ln_sig_e)
			predictnl `typlist' `varlist'=exp(xb(ln_sig_e)) if `touse' 
			label var `varlist' "Conditional stdev for component e"
		}
	    else if "`sig_n'"!="" {
		    syntax newvarname [if] [in] [, * ]
			_predict double `_sig_n', xb eq(ln_sig_n)
			gen `typlist' `varlist'=exp(`_sig_n') if `touse' 
			label var `varlist' "Conditional stdev for component n"
		}
	    else if "`sig_w'"!="" {
		    syntax newvarname [if] [in] [, * ]
			_predict double `_sig_w', xb eq(ln_sig_w)
			gen `typlist' `varlist'=exp(`_sig_w') if `touse' 
			label var `varlist' "Conditional stdev for component w"
		}
		else if "`rho_s'"!="" {
		    syntax newvarname [if] [in] [, * ]
			_predict double `_rho_s', xb eq(arho_s)
			gen `typlist' `varlist'=tanh(`_rho_s') if `touse' 
			label var `varlist' "Rho s: RTM Survey data"
		}
		else if "`sig_r1'"!="" {
			_predict double `_sig_e' if `touse', xb eq(ln_sig_e)
		    syntax newvarname [if] [in] [, * ]
		    gen `typlist' `varlist'=exp(`_sig_e') if `touse'
			label var `varlist' "Conditional sigma sig_r1"
		}
		else if "`sig_s1'"!="" {
			_predict double `_sig_e' if `touse', xb eq(ln_sig_e)
		    syntax newvarname [if] [in] [, * ]
		    gen `typlist' `varlist'=exp(`_sig_e') if `touse'
			label var `varlist' "Conditional sigma sig_s1"
		}
		else if "`sig_s2'"!="" {
			_predict double `_sig_e' if `touse', xb eq(ln_sig_e)
			_predict double `_sig_n' if `touse', xb eq(ln_sig_n)
			_predict double `_rho_s' if `touse', xb eq(arho_s)
			replace `_sig_e'=exp(`_sig_e')
			replace `_sig_n'=exp(`_sig_n')
			replace `_rho_s'=tanh(`_rho_s')
		    syntax newvarname [if] [in] [, * ]
		    gen `typlist' `varlist'=sqrt((1+`_rho_s')^2*`_sig_e'^2+`_sig_n'^2) if `touse'
			label var `varlist' "Conditional sigma sig_s2"
		}
		else if "`sig_s3'"!="" {
			_predict double `_sig_e' if `touse', xb eq(ln_sig_e)
			_predict double `_sig_n' if `touse', xb eq(ln_sig_n)
			_predict double `_sig_w' if `touse', xb eq(ln_sig_w)
			_predict double `_rho_s' if `touse', xb eq(arho_s)
			replace `_sig_e'=exp(`_sig_e')
			replace `_sig_n'=exp(`_sig_n')
			replace `_sig_w'=exp(`_sig_w')
			replace `_rho_s'=tanh(`_rho_s')
		    syntax newvarname [if] [in] [, * ]
		    gen `typlist' `varlist'=sqrt((1+`_rho_s')^2*`_sig_e'^2+`_sig_n'^2+`_sig_w'^2) if `touse'
			label var `varlist' "Conditional sigma sig_s3"
		}
 	*** A priori Prob
	*** Prior by Group
	*** This may depend on the model. Assume we start with model 5. And go backward
		else if "`pi_s1'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist' if `touse' , pi_s
			label var `varlist' "Latent Class pi s type 1"
		}
		else if "`pi_s2'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_pi_s'  , pi_s
			ky_p double `_pi_w'  , pi_w
			gen `typlist' `varlist'=(1-`_pi_s')*(1-`_pi_w') if `touse' 
			label var `varlist' "Latent Class pi s type 2"
		}
		else if "`pi_s3'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_pi_s'  , pi_s
			ky_p double `_pi_w'  , pi_w
			gen `typlist' `varlist'=(1-`_pi_s')*(  `_pi_w') if `touse' 
			label var `varlist' "Latent Class pi s type 2"
		}
		else if "`pi_1'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist' if `touse' , pi_s1
			label var `varlist' "Latent Class pi_1"
		}
		else if "`pi_2'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist' if `touse' , pi_s2
			label var `varlist' "Latent Class pi_2"
		}
		else if "`pi_3'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist' if `touse' , pi_s2
			label var `varlist' "Latent Class pi_3"
		}		
	
		*** posterior over Stype.             
		else if "`pip_s1'`pip_s2'`pip_s3'" != "" {
			ky_p double `_pi_s'  , pi_s
			ky_p double `_pi_w'  , pi_w	
			local _pi_s1  (  `_pi_s')
			local _pi_s2 ((1-`_pi_s')*(1-`_pi_w'))
			local _pi_s3 ((1-`_pi_s')*(  `_pi_w'))
			ky_p double `_mean_e'  , mean_e
			ky_p double `_mean_n'  , mean_n
			ky_p double `_mean_w'  , mean_w
			ky_p double `_sig_e'  , sig_e
			ky_p double `_sig_n'  , sig_n
			ky_p double `_sig_w'  , sig_w
			ky_p double `_rho_s'  , rho_s
			tempvar _mean_s1 _mean_s2 _mean_s3
			tempvar _sig_s1 _sig_s2 _sig_s3
			gen double `_mean_s1'= (`_mean_e')
			gen double `_mean_s2'= (`_mean_e'+`_mean_n')
			gen double `_mean_s3'= (`_mean_e'+`_mean_n'+`_mean_w')
			gen double `_sig_s1' =(`_sig_e')
			gen double `_sig_s2' =(sqrt((1+`_rho_s')^2*`_sig_e'^2+`_sig_n'^2))
			gen double `_sig_s3' =(sqrt((1+`_rho_s')^2*`_sig_e'^2+`_sig_n'^2+`_sig_w'^2))
			tempvar _ls1 _ls2 _ls3
			gen double `_ls1'= (normalden(`_s',`_mean_s1',`_sig_s1'))
			gen double `_ls2'= (normalden(`_s',`_mean_s2',`_sig_s2'))
			gen double `_ls3'= (normalden(`_s',`_mean_s3',`_sig_s3'))
		    syntax newvarname [if] [in] [, * ]
			if "`pip_s1'"!="" {
				gen `typlist' `varlist'=(`_pi_s1'*`_ls1')/(`_pi_s1'*`_ls1'+`_pi_s2'*`_ls2'+`_pi_s3'*`_ls3') if `touse' 
				label var `varlist' "Posterior pi s type 1"
			}	
			else if "`pip_s2'"!="" {
				gen `typlist' `varlist'=(`_pi_s2'*`_ls2')/(`_pi_s1'*`_ls1'+`_pi_s2'*`_ls2'+`_pi_s3'*`_ls3') if `touse' 
				label var `varlist' "Posterior pi s type 2"
			}
			else if "`pip_s3'"!="" {
				gen `typlist' `varlist'=(`_pi_s3'*`_ls3')/(`_pi_s1'*`_ls1'+`_pi_s2'*`_ls2'+`_pi_s3'*`_ls3') if `touse' 
				label var `varlist' "Posterior pi s type 3"
			}
		}

		*********************
		else if "`pip_1'" != "" {
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_l' if `touse'
			label var `varlist' "Posterior prob pi_1 Constant and equal to 1"
		}
		else if "`pip_2'" != "" {
			ky_p double `_pi_s'  , pi_s
			ky_p double `_pi_w'  , pi_w		
			local _pi_s2 ((1-`_pi_s')*(1-`_pi_w'))
			local _pi_s3 ((1-`_pi_s')*(  `_pi_w'))			
			ky_p double `_mean_e'  , mean_e
			ky_p double `_mean_n'  , mean_n
			ky_p double `_mean_w'  , mean_w
			ky_p double `_sig_e'  , sig_e
			ky_p double `_sig_n'  , sig_n
			ky_p double `_sig_w'  , sig_w
			ky_p double `_rho_s'  , rho_s
			tempvar _mean_s1 _mean_s2 _mean_s3
			gen double `_mean_s1'= (`_mean_e')
			gen double `_mean_s2'= (`_mean_e'+`_mean_n')
			gen double `_mean_s3'= (`_mean_e'+`_mean_n'+`_mean_w')
			gen double `_sig_s1' =(`_sig_e')
			gen double `_sig_s2' =(sqrt((1+`_rho_s')^2*`_sig_e'^2+`_sig_n'^2))
			gen double `_sig_s3' =(sqrt((1+`_rho_s')^2*`_sig_e'^2+`_sig_n'^2+`_sig_w'^2))
			tempvar _rho_r1s2  _rho_r1s3 
			gen double `_rho_r1s2' = ((1+`_rho_s')*`_sig_e'^2)/(`_sig_r1'*`_sig_s2')
			gen double `_rho_r1s3' = ((1+`_rho_s')*`_sig_e'^2)/(`_sig_r1'*`_sig_s3')

			tempvar _std_r1 _std_s1 _std_s2	 _std_s3
			gen double `_std_r1' =((`_r'-`_mean_s1')/`_sig_s1')
			*gen double `_std_s1' =((`_s'-`_mean_s1')/`_sig_s1')
			gen double `_std_s2' =((`_s'-`_mean_s2')/`_sig_s2')
			gen double `_std_s3' =((`_s'-`_mean_s3')/`_sig_s3')
	
			tempvar _lf_2  _lf_3
			gen double `_lf_2' = (1/(2*_pi*`_sig_r1'*`_sig_s2'*sqrt(1-`_rho_r1s2'^2))*exp(-1/(2*(1-`_rho_r1s2'^2))*(`_std_r1'^2+`_std_s2'^2-2*`_rho_r1s2'*`_std_r1'*`_std_s2')))
			gen double `_lf_3' = (1/(2*_pi*`_sig_r1'*`_sig_s3'*sqrt(1-`_rho_r1s3'^2))*exp(-1/(2*(1-`_rho_r1s3'^2))*(`_std_r1'^2+`_std_s3'^2-2*`_rho_r1s3'*`_std_r1'*`_std_s3'))) 
		
		    syntax newvarname [if] [in] [, * ]
		    gen `typlist' `varlist'=(`_pi_s2'*`_lf_2')/(`_pi_s2'*`_lf_2'+`_pi_s3'*`_lf_3') if `touse'
			replace   `varlist'=0 if `touse' & `_l'==1
			label var `varlist' "Posterior prob pi_2"
		}
		else if "`pip_3'" != "" {
			tempvar _pip_2
			ky_p double `_pip_2'  , pip_2
		    syntax newvarname [if] [in] [, * ]
		    gen `typlist' `varlist'=1-`_pip_2' if `touse'
			replace   `varlist'=0 if `touse' & `_l'==1
			label var `varlist' "Posterior prob pi_3"
		}
		else if "`bclass_s'"!="" {
			tempvar _pip_s1 _pip_s2  
			ky_p double `_pip_s1' , pip_s1
			ky_p double `_pip_s2' , pip_s2
			local _pip_s3 (1-`_pip_s1'-`_pip_s2')
			tempvar _high
			gen double `_high'=0 
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=0 
			forvalues i=1/3 {
				replace `varlist'=`i'         if `_pip_s`i''>`_high' 
				replace `_high'  =`_pip_s`i'' if `_pip_s`i''>`_high' 
			}			
			label var `varlist' "two-step classification based on S only"
		}				
	}
end
*********************** *********************** ***********************  
 	
program define ky_p_3 	
version 14
    syntax anything(id="newvarname") [if] [in] , [pi_s pi_r 		 /// Probabilities of each event
								   pi_r1  pi_r2  pi_s1 pi_s2         /// Probabilities by category
								   pip_r1 pip_r2 pip_s1 pip_s2       /// Probabilities by category. Posterior Prob
								   pi_1  pi_2  pi_3  pi_4  			 /// Probabilities by group classification
								   pip_1 pip_2 pip_3 pip_4  		 /// Probabilities by group classification
								   rho_s 							 /// RHO's (Regression to the mean factors)
								   mean_e  mean_n mean_t             /// Conditional Means
								   sig_e sig_n sig_t                 /// conditional Standard deviations
								   mean_r1 mean_r2 mean_s1 mean_s2   /// mean by group
								   sig_r1  sig_r2  sig_s1  sig_s2    /// sigma by group
								   bclass_r bclass_s bclass	*  ]
    marksample touse, novarlist
 	*** getting dep variables
	tokenize "`e(depvar)'"
	local _r `1'
	local _s `2'
	local _l `3'
	*** NOW ALL cases
	*** defining all elements:
	tempvar _pi_s   _pi_r   _pi_w   _pi_v   
	tempvar _mean_e _mean_n _mean_t _mean_w _mean_v 
	tempvar _sig_e  _sig_n  _sig_t  _sig_w  _sig_v 
	tempvar _rho_s _rho_r

    qui {
	    if "`options'"!="" {
			ml_p `0'
			exit
		}
*** A priori Prob
		else if "`pi_s'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'  =(invlogit(xb(lpi_s)))  if `touse' 
			label var `varlist' "A priori Pi_s"
		}
		else if "`pi_r'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'  =(invlogit(xb(lpi_r)))  if `touse' 
			label var `varlist' "A priori Pi_r"
		}
		****************
	    else if "`mean_e'"!="" {
		    syntax newvarname [if] [in] [, * ]
			_predict `typlist' `varlist' if `touse', xb eq(mu_e)
			label var `varlist' "Conditional mean for component e"
		}
	    else if "`mean_n'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_n)
			label var `varlist' "Conditional mean for component n"
		}
	    else if "`mean_t'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_t)
			label var `varlist' "Conditional mean for component t"
		}
	   
		*** Sigmas
		else if "`sig_e'"!="" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist' =exp(xb(ln_sig_e)) if `touse'
			label var `varlist' "Conditional stdev for component e"
		}
	    else if "`sig_n'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    predictnl `typlist' `varlist' =exp(xb(ln_sig_n)) if `touse'
			label var `varlist' "Conditional stdev for component n"
		}
	    else if "`sig_t'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    predictnl `typlist' `varlist' =exp(xb(ln_sig_t)) if `touse'
			label var `varlist' "Conditional stdev for component t"
		}		
		else if "`rho_s'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'=tanh(xb(arho_s)) if `touse'
			label var `varlist' "Rho s: RTM Survey data"
		}		
	    else if "`pi_r1'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , pi_r  
			label var `varlist' "Latent Class pi r type 1"
		}
		else if "`pi_r2'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , pi_r  
			replace `varlist'=1-`varlist'
			label var `varlist' "Latent Class pi r type 2"
		}		
		else if "`pi_s1'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , pi_s  
			label var `varlist' "Latent Class pi s type 1"
		}
		else if "`pi_s2'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , pi_s  
			replace `varlist'=1-`varlist'
			label var `varlist' "Latent Class pi s type 2"
		}
		*** dependent from above
		else if "`mean_r1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , mean_e
			label var `varlist' "Conditional mean R1"
		}
		else if "`mean_r2'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , mean_t
			label var `varlist' "Conditional mean R2"
		}
		else if "`mean_s1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , mean_e
			label var `varlist' "Conditional mean S1"
		}
		else if "`mean_s2'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_mean_e', mean_e
			ky_p double `_mean_n', mean_n
			gen `typlist' `varlist'=`_mean_e'+`_mean_n' if `touse'
			label var `varlist' "Conditional mean S2"
		}
		*** 
		else if "`sig_r1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , sig_e
			label var `varlist' "Conditional sigma R1"
		}
		else if "`sig_r2'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , sig_t
			label var `varlist' "Conditional sigma R2"
		}
		else if "`sig_s1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , sig_e
			label var `varlist' "Conditional sigma S1"
		}
		else if "`sig_s2'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_sig_e', sig_e
			ky_p double `_sig_n', sig_n
			ky_p double `_rho_s', rho_s
			gen `typlist' `varlist'=(sqrt((1+`_rho_s')^2*`_sig_e'^2+`_sig_n'^2)) if `touse'
			label var `varlist' "Conditional sigma S2"
		}
        else if "`pi_1'" != "" {
			ky_p double `_pi_r', pi_r
			ky_p double `_pi_s', pi_s
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_1"
		}
		else if "`pi_2'" != "" {
			ky_p double `_pi_r', pi_r
			ky_p double `_pi_s', pi_s
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*(1-`_pi_s') if `touse'
			label var `varlist' "Latent Class pi_2"
		}
		else if "`pi_3'" != "" {
			ky_p double `_pi_r', pi_r
			ky_p double `_pi_s', pi_s
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=(1-`_pi_r')*`_pi_s' if `touse'
			label var `varlist' "Latent Class pi_3"
		}
		else if "`pi_4'" != "" {
			ky_p double `_pi_r', pi_r
			ky_p double `_pi_s', pi_s
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=(1-`_pi_r')*(1-`_pi_s') if `touse'
			label var `varlist' "Latent Class pi_4"
		}
		*** posterior. assuming we see only 1 thing.
		else if "`pip_r1'" != "" {
			tempvar _mean_r1 _mean_r2  _sig_r1 _sig_r2 _pi_r1
			ky_p double `_mean_r1', mean_r1
			ky_p double `_sig_r1',  sig_r1
			ky_p double `_mean_r2', mean_r2
			ky_p double `_sig_r2',  sig_r2
			ky_p double `_pi_r1',  pi_r1
			tempvar _pip_1 _pip_2
			gen double `_pip_1' =    `_pi_r1'*normalden(`_r',`_mean_r1',`_sig_r1')
			gen double `_pip_2' =(1-`_pi_r1')*normalden(`_r',`_mean_r2',`_sig_r2')
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pip_1'/(`_pip_1'+`_pip_2')  if `touse' 
			label var `varlist' "Posterior pi r type 1"
		}
		else if "`pip_r2'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist' if `touse', pip_r1
			replace `varlist'=1-`varlist'
			label var `varlist' "Posterior pi r type 2"
		}
		else if "`pip_s1'" != "" {
		    syntax newvarname [if] [in] [, * ]
			tempvar _mean_s1 _mean_s2  _sig_s1 _sig_s2 _pi_s1
			ky_p double `_mean_s1', mean_s1
			ky_p double `_sig_s1' ,  sig_s1
			ky_p double `_mean_s2', mean_s2
			ky_p double `_sig_s2' ,  sig_s2
			ky_p double `_pi_s1'  ,  pi_s1
			tempvar _pip_1 _pip_2
			gen double `_pip_1' =    `_pi_s1' *normalden(`_s',`_mean_s1',`_sig_s1')
			gen double `_pip_2' =(1- `_pi_s1')*normalden(`_s',`_mean_s2',`_sig_s2')
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pip_1'/(`_pip_1'+`_pip_2')  if `touse' 
			label var `varlist' "Posterior pi s type 1"
		}
		else if "`pip_s2'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist' if `touse', pip_s1
			replace `varlist'=1-`varlist'
			label var `varlist' "Posterior pi s type 2"
		}
	************************************************************
		else if "`pip_1'" != "" {
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_l' if `touse'
			label var `varlist' "Posterior prob pi_1 Constant and equal to 1"
		}
		else if "`pip_2'`pip_3'`pip_4'" != "" {
			tempvar _mean_s1 _sig_s1 ///
			        _mean_s2 _sig_s2 ///
					_mean_r2 _sig_r2
			*_mean_r1 sig_r1 
			ky_p double `_mean_s1', mean_s1
			ky_p double `_sig_s1' ,  sig_s1
			ky_p double `_mean_s2', mean_s2
			ky_p double `_sig_s2' ,  sig_s2
			*ky_p double `_mean_r1', mean_r1
			*ky_p double `_sig_r1' ,  sig_r1
			ky_p double `_mean_r2', mean_r2
			ky_p double `_sig_r2' ,  sig_r2
			ky_p double `_rho_s'  ,  rho_s
			tempvar _pi_2 _pi_3 _pi_4			
			ky_p double `_pi_2'  ,  pi_2
			ky_p double `_pi_3'  ,  pi_3
			ky_p double `_pi_4'  ,  pi_4
			
			ky_p double `_sig_e'  , sig_e
			
			local _mean_r1 (`_mean_s1')
			local _sig_r1 (`_sig_s1')
			local _rho_r1s1  1
			local _rho_r1s2  (((1+`_rho_s')*`_sig_e'^2)/(`_sig_r1'*`_sig_s2'))
			local _rho_r3s1  0
			local _rho_r3s2  0
			tempvar _pip2 _pip3 _pip4 
			local _std_r1 ((`_r'-`_mean_r1')/`_sig_r1')
			local _std_r2 ((`_r'-`_mean_r2')/`_sig_r2')
			local _std_s1 ((`_s'-`_mean_s1')/`_sig_s1')
			local _std_s2 ((`_s'-`_mean_s2')/`_sig_s2')
			gen double `_pip2'=`_pi_2'*(1/(2*_pi*`_sig_r1'*`_sig_s2'*sqrt(1-`_rho_r1s2'^2))*exp(-1/(2*(1-`_rho_r1s2'^2))*(`_std_r1'^2+`_std_s2'^2-2*`_rho_r1s2'*`_std_r1'*`_std_s2')))
			gen double `_pip3'=`_pi_3'*(normalden(`_r',`_mean_r2',`_sig_r2')*normalden(`_s',`_mean_s1',`_sig_s1'))
			gen double `_pip4'=`_pi_4'*(normalden(`_r',`_mean_r2',`_sig_r2')*normalden(`_s',`_mean_s2',`_sig_s2'))
			
			syntax newvarname [if] [in] [, * ]
			if "`pip_2'" != "" {
				gen `typlist' `varlist'=`_pip2'/(`_pip2'+`_pip3'+`_pip4') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_2"
			}
			else if "`pip_3'" != "" {
				gen `typlist' `varlist'=`_pip3'/(`_pip2'+`_pip3'+`_pip4') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_3"
			}
			else if "`pip_4'" != "" {
				gen `typlist' `varlist'=`_pip4'/(`_pip2'+`_pip3'+`_pip4') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_4"
			}
		}
		 
		**** mean and sigmas for 6 elements?
		else if "`bclass_s'"!="" {
			tempvar _pip_s1
			ky_p `typlist' `_pip_s1' , pip_s1
		    syntax newvarname [if] [in] [, * ]
			gen  `typlist' `varlist'=1+`_pip_s1'<.5 if `touse'
		}
		else if "`bclass_r'"!="" {
			tempvar _pip_r1
			ky_p `typlist' `_pip_r1' , pip_r1
		    syntax newvarname [if] [in] [, * ]
			gen  `typlist' `varlist'=1+`_pip_r1'<.5 if `touse'
		}
		
		else if "`bclass'"!="" {
			tempvar _high
			gen double `_high'=.
			replace `_high'=0 if `_l'==0
			
			tempvar _mean_s1 _sig_s1 ///
			        _mean_s2 _sig_s2 ///
					_mean_r2 _sig_r2
			*_mean_r1 sig_r1 
			ky_p double `_mean_s1', mean_s1
			ky_p double `_sig_s1' ,  sig_s1
			ky_p double `_mean_s2', mean_s2
			ky_p double `_sig_s2' ,  sig_s2
			*ky_p double `_mean_r1', mean_r1
			*ky_p double `_sig_r1' ,  sig_r1
			ky_p double `_mean_r2', mean_r2
			ky_p double `_sig_r2' ,  sig_r2
			ky_p double `_rho_s'  ,  rho_s
			tempvar _pi_2 _pi_3 _pi_4			
			ky_p double `_pi_2'  ,  pi_2
			ky_p double `_pi_3'  ,  pi_3
			ky_p double `_pi_4'  ,  pi_4
			
			ky_p double `_sig_e'  , sig_e
			
			
			local _mean_r1 (`_mean_s1')
			local _sig_r1 (`_sig_s1')
			
			local _rho_r1s1  1
			local _rho_r1s2  (((1+`_rho_s')*`_sig_e'^2)/(`_sig_r1'*`_sig_s2'))
			local _rho_r3s1  0
			local _rho_r3s2  0
			tempvar _pip2 _pip3 _pip4 
			local _std_r1 ((`_r'-`_mean_r1')/`_sig_r1')
			local _std_r2 ((`_r'-`_mean_r2')/`_sig_r2')
			local _std_s1 ((`_s'-`_mean_s1')/`_sig_s1')
			local _std_s2 ((`_s'-`_mean_s2')/`_sig_s2')
			
			gen double `_pip2'=`_pi_2'*(1/(2*_pi*`_sig_r1'*`_sig_s2'*sqrt(1-`_rho_r1s2'^2))*exp(-1/(2*(1-`_rho_r1s2'^2))*(`_std_r1'^2+`_std_s2'^2-2*`_rho_r1s2'*`_std_r1'*`_std_s2')))
			gen double `_pip3'=`_pi_3'*(normalden(`_r',`_mean_r2',`_sig_r2')*normalden(`_s',`_mean_s1',`_sig_s1'))
			gen double `_pip4'=`_pi_4'*(normalden(`_r',`_mean_r2',`_sig_r2')*normalden(`_s',`_mean_s2',`_sig_s2'))

		    tempvar _pip_2 _pip_3 _pip_4
			gen double `_pip_2'=`_pip2'/(`_pip2'+`_pip3'+`_pip4') if `touse'
			gen double `_pip_3'=`_pip3'/(`_pip2'+`_pip3'+`_pip4') if `touse'
			gen double `_pip_4'=`_pip4'/(`_pip2'+`_pip3'+`_pip4') if `touse'
			
			syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=1 if `_l'==1
			forvalues i=2/4 {
				replace `varlist'=`i'        if `_pip_`i''>`_high' & `_l'==0
				replace `_high'  =`_pip_`i'' if `_pip_`i''>`_high' & `_l'==0
			}
		}
	}
end

*********************** *********************** ***********************  

program define ky_p_4 	
version 14
    syntax anything(id="newvarname") [if] [in] , [pi_s pi_r pi_w    			/// Probabilities of each event
								   rho_s 	 							  		/// RHO's (Regression to the mean factors)
								   mean_e mean_n mean_w mean_t       		    /// Conditional Means
								   sig_e  sig_n  sig_w  sig_t      	            /// conditional Standard deviations
								   mean_r1 mean_r2 mean_s1 mean_s2 mean_s3      /// mean by group
								   sig_r1  sig_r2  sig_s1  sig_s2  sig_s3       /// sigma by group
								   pi_r1  pi_r2  pi_s1  pi_s2  pi_s3            /// Probabilities by category
								   pip_r1 pip_r2 pip_s1 pip_s2 pip_s3  	        /// Probabilities by category. Posterior Prob
								   pi_1  pi_2  pi_3  pi_4  pi_5  pi_6           /// Probabilities by group classification
								   pip_1 pip_2 pip_3 pip_4 pip_5 pip_6          /// Probabilities by group classification
								   bclass_r bclass_s bclass	*  ]
    
    marksample touse, novarlist
 	*** getting dep variables
	tokenize "`e(depvar)'"
	local _r `1'
	local _s `2'
	local _l `3'
	*** NOW ALL cases
	*** defining all elements:
	tempvar _pi_s   _pi_r   _pi_w   _pi_v   
	tempvar _mean_e _mean_n _mean_t _mean_w _mean_v 
	tempvar _sig_e  _sig_n  _sig_t  _sig_w  _sig_v 
	tempvar _rho_s _rho_r
	
	*** Moments based on parameters:
    qui {
	    if "`options'"!="" {
			ml_p `0'
			exit
		}
		else if "`pi_s'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'  =(invlogit(xb(lpi_s)))  if `touse' 
			label var `varlist' "A priori Pi_s"
		}
		else if "`pi_r'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'  =(invlogit(xb(lpi_r)))  if `touse' 
			label var `varlist' "A priori Pi_r"
		}
		else if "`pi_w'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'  =(invlogit(xb(lpi_w)))  if `touse' 
			label var `varlist' "A priori Pi_r"
		}
		****************
	    else if "`mean_e'"!="" {
		    syntax newvarname [if] [in] [, * ]
			_predict `typlist' `varlist' if `touse', xb eq(mu_e)
			label var `varlist' "Conditional mean for component e"
		}
	    else if "`mean_n'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_n)
			label var `varlist' "Conditional mean for component n"
		}
		else if "`mean_w'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_w)
			label var `varlist' "Conditional mean for component w"
		}
	    else if "`mean_t'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_t)
			label var `varlist' "Conditional mean for component t"
		}
	   
		*** Sigmas
		else if "`sig_e'"!="" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist' =exp(xb(ln_sig_e)) if `touse'
			label var `varlist' "Conditional stdev for component e"
		}
	    else if "`sig_n'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    predictnl `typlist' `varlist' =exp(xb(ln_sig_n)) if `touse'
			label var `varlist' "Conditional stdev for component n"
		}
		else if "`sig_w'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    predictnl `typlist' `varlist' =exp(xb(ln_sig_w)) if `touse'
			label var `varlist' "Conditional stdev for component w"
		}
	    else if "`sig_t'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    predictnl `typlist' `varlist' =exp(xb(ln_sig_t)) if `touse'
			label var `varlist' "Conditional stdev for component t"
		}		
		else if "`rho_s'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'=tanh(xb(arho_s)) if `touse'
			label var `varlist' "Rho s: RTM Survey data"
		}	
		***********************************************
		else if "`mean_r1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , mean_e
			label var `varlist' "Conditional mean R1"
		}
		else if "`mean_r2'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , mean_t
			label var `varlist' "Conditional mean R2"
		}
		else if "`mean_s1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , mean_e
			label var `varlist' "Conditional mean S1"
		}
		else if "`mean_s2'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_mean_e', mean_e
			ky_p double `_mean_n', mean_n
			gen `typlist' `varlist'=`_mean_e'+`_mean_n' if `touse'
			label var `varlist' "Conditional mean S2"
		}
		else if "`mean_s3'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_mean_e', mean_e
			ky_p double `_mean_n', mean_n
			ky_p double `_mean_w', mean_w
			gen `typlist' `varlist'=`_mean_e'+`_mean_n'+`_mean_w' if `touse'
			label var `varlist' "Conditional mean S3"
		}
		else if "`sig_r1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , sig_e
			label var `varlist' "Conditional sigma R1"
		}
		else if "`sig_r2'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , sig_t
			label var `varlist' "Conditional sigma R2"
		}
		else if "`sig_s1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , sig_e
			label var `varlist' "Conditional sigma S1"
		}
		else if "`sig_s2'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_sig_e', sig_e
			ky_p double `_sig_n', sig_n
			ky_p double `_rho_s', rho_s
			gen `typlist' `varlist'=(sqrt((1+`_rho_s')^2*`_sig_e'^2+`_sig_n'^2)) if `touse'
			label var `varlist' "Conditional sigma S2"
		}
		else if "`sig_s3'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_sig_e', sig_e
			ky_p double `_sig_n', sig_n
			ky_p double `_sig_w', sig_w
			ky_p double `_rho_s', rho_s
			gen `typlist' `varlist'=(sqrt((1+`_rho_s')^2*`_sig_e'^2+`_sig_n'^2+`_sig_w'^2)) if `touse'
			label var `varlist' "Conditional sigma S3"
		}
		***************************************
		else if "`pi_r1'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , pi_r  
			label var `varlist' "Latent Class pi r type 1"
		}
		else if "`pi_r2'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , pi_r  
			replace `varlist'=1-`varlist'  if `touse'
			label var `varlist' "Latent Class pi r type 2"
		}
		
		else if "`pi_s1'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , pi_s  
			label var `varlist' "Latent Class pi s type 1"
		}
		else if "`pi_s2'" != "" {
		    ky_p double `_pi_s'  if `touse' , pi_s  
			ky_p double `_pi_w'  if `touse' , pi_w  
			syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=((1-`_pi_s')*(1-`_pi_w')) if `touse'
			label var `varlist' "Latent Class pi s type 2"
		}
		else if "`pi_s3'" != "" {
		    ky_p double `_pi_s'  if `touse' , pi_s  
			ky_p double `_pi_w'  if `touse' , pi_w  
			syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=((1-`_pi_s')*( `_pi_w')) if `touse'
			label var `varlist' "Latent Class pi s type 3"
		}
		***************************************
        else if "`pi_1'" != "" {
			ky_p double `_pi_r', pi_r1
			ky_p double `_pi_s', pi_s1
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_1"
		}
		else if "`pi_2'" != "" {
			ky_p double `_pi_r', pi_r1
			ky_p double `_pi_s', pi_s2
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_2"
		}
		else if "`pi_3'" != "" {
			ky_p double `_pi_r', pi_r1
			ky_p double `_pi_s', pi_s3
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_3"
		}
		else if "`pi_4'" != "" {
			ky_p double `_pi_r', pi_r2
			ky_p double `_pi_s', pi_s1
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_4"
		}
		else if "`pi_5'" != "" {
			ky_p double `_pi_r', pi_r2
			ky_p double `_pi_s', pi_s2
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_5"
		}
		else if "`pi_6'" != "" {
			ky_p double `_pi_r', pi_r2
			ky_p double `_pi_s', pi_s3
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_6"
		}
		*** posterior. assuming we see only 1 thing.
		else if "`pip_r1'" != "" {
			tempvar _mean_r1 _mean_r2  _sig_r1 _sig_r2 _pi_r1
			ky_p double `_mean_r1', mean_r1
			ky_p double `_sig_r1',  sig_r1
			ky_p double `_mean_r2', mean_r2
			ky_p double `_sig_r2',  sig_r2
			ky_p double `_pi_r1',  pi_r1
			tempvar _pip_1 _pip_2
			gen double `_pip_1' =    `_pi_r1'*normalden(`_r',`_mean_r1',`_sig_r1')
			gen double `_pip_2' =(1-`_pi_r1')*normalden(`_r',`_mean_r2',`_sig_r2')
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pip_1'/(`_pip_1'+`_pip_2')  if `touse' 
			label var `varlist' "Posterior pi r type 1"
		}
		else if "`pip_r2'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist' if `touse', pip_r1
			replace `varlist'=1-`varlist'
			label var `varlist' "Posterior pi r type 2"
		}
		
		else if "`pip_s1'`pip_s2'`pip_s3'" != "" {
			tempvar _mean_s1 _mean_s2  _mean_s3 ///
				    _sig_s1 _sig_s2 _sig_s3 ///
					_pi_s1 _pi_s2
			ky_p double `_mean_s1', mean_s1
			ky_p double `_sig_s1' ,  sig_s1
			ky_p double `_mean_s2', mean_s2
			ky_p double `_sig_s2' ,  sig_s2
			ky_p double `_mean_s3', mean_s3
			ky_p double `_sig_s3' ,  sig_s3
			ky_p double `_pi_s1'  ,  pi_s1
			ky_p double `_pi_s2'  ,  pi_s2
			local _pi_s3 (1-`_pi_s1'-`_pi_s2')
			
			tempvar _pip_1 _pip_2 _pip_3
			gen double `_pip_1' =    `_pi_s1' *normalden(`_s',`_mean_s1',`_sig_s1')
			gen double `_pip_2' =    `_pi_s2' *normalden(`_s',`_mean_s2',`_sig_s2')
			gen double `_pip_3' =    `_pi_s3' *normalden(`_s',`_mean_s3',`_sig_s3')
			if "`pip_s1'"!="" {	
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_1'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi s type 1"
			}	
			else if "`pip_s2'"!="" {	
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_2'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi s type 2"
			}
			else if "`pip_s3'"!="" {	
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_3'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi s type 3"
			}
		}
		
		********************************************
		else if "`pip_1'" != "" {
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_l' if `touse'
			label var `varlist' "Posterior prob pi_1 Constant and equal to 1"
		}
		else if "`pip_2'`pip_3'`pip_4'`pip_5'`pip_6'" != "" {
			tempvar _mean_s1 _sig_s1 ///
			        _mean_s2 _sig_s2 ///
					_mean_s3 _sig_s3 ///
					_mean_r2 _sig_r2
			*_mean_r1 sig_r1 
			ky_p double `_mean_s1', mean_s1
			ky_p double `_sig_s1' ,  sig_s1
			ky_p double `_mean_s2', mean_s2
			ky_p double `_sig_s2' ,  sig_s2
			ky_p double `_mean_s3', mean_s3
			ky_p double `_sig_s3' ,  sig_s3
			*ky_p double `_mean_r1', mean_r1
			*ky_p double `_sig_r1' ,  sig_r1
			ky_p double `_mean_r2', mean_r2
			ky_p double `_sig_r2' ,  sig_r2
			
			ky_p double `_sig_e'  , sig_e
			
			ky_p double `_rho_s'  ,  rho_s
			tempvar _pi_2 _pi_3 _pi_4 _pi_5 _pi_6
			ky_p double `_pi_2'  ,  pi_2
			ky_p double `_pi_3'  ,  pi_3
			ky_p double `_pi_4'  ,  pi_4
			ky_p double `_pi_5'  ,  pi_5
			ky_p double `_pi_6'  ,  pi_6
			
			local _mean_r1 (`_mean_s1')
			local _sig_r1 (`_sig_s1')
			
			local _rho_r1s1  1
			local _rho_r1s2  (((1+`_rho_s')*`_sig_e'^2)/(`_sig_r1'*`_sig_s2'))
			local _rho_r1s3  (((1+`_rho_s')*`_sig_e'^2)/(`_sig_r1'*`_sig_s3'))
			local _rho_r2s1  0
			local _rho_r2s2  0
			local _rho_r2s3  0
	
			tempvar _pip2 _pip3 _pip4 _pip5 _pip6  
			local _std_r1 ((`_r'-`_mean_r1')/`_sig_r1')
			local _std_r2 ((`_r'-`_mean_r2')/`_sig_r2')
			local _std_s1 ((`_s'-`_mean_s1')/`_sig_s1')
			local _std_s2 ((`_s'-`_mean_s2')/`_sig_s2')
			local _std_s3 ((`_s'-`_mean_s3')/`_sig_s3')
			
			gen double `_pip2'=`_pi_2'*(1/(2*_pi*`_sig_r1'*`_sig_s2'*sqrt(1-`_rho_r1s2'^2))*exp(-1/(2*(1-`_rho_r1s2'^2))*(`_std_r1'^2+`_std_s2'^2-2*`_rho_r1s2'*`_std_r1'*`_std_s2')))
			gen double `_pip3'=`_pi_3'*(1/(2*_pi*`_sig_r1'*`_sig_s3'*sqrt(1-`_rho_r1s3'^2))*exp(-1/(2*(1-`_rho_r1s3'^2))*(`_std_r1'^2+`_std_s3'^2-2*`_rho_r1s3'*`_std_r1'*`_std_s3'))) 
			gen double `_pip4'=`_pi_4'*(normalden(`_r',`_mean_r2',`_sig_r2')*normalden(`_s',`_mean_s1',`_sig_s1'))
			gen double `_pip5'=`_pi_5'*(normalden(`_r',`_mean_r2',`_sig_r2')*normalden(`_s',`_mean_s2',`_sig_s2'))
			gen double `_pip6'=`_pi_6'*(normalden(`_r',`_mean_r2',`_sig_r2')*normalden(`_s',`_mean_s3',`_sig_s3'))
			
			syntax newvarname [if] [in] [, * ]
			if "`pip_2'"!="" {
				gen `typlist' `varlist'=`_pip2'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_2"
			}
			if "`pip_3'"!="" {
				gen `typlist' `varlist'=`_pip3'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_3"
			}
			if "`pip_4'"!="" {
				gen `typlist' `varlist'=`_pip4'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_4"
			}
			if "`pip_5'"!="" {
				gen `typlist' `varlist'=`_pip5'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_5"
			}
			if "`pip_6'"!="" {
				gen `typlist' `varlist'=`_pip6'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_6"
			}
		}
*************************************************************************
		else if "`bclass_s'"!="" {
			tempvar _pip_s1 _pip_s2  
			ky_p double `_pip_s1' , pip_s1
			ky_p double `_pip_s2' , pip_s2
			local _pip_s3 (1-`_pip_s1'-`_pip_s2')
			tempvar _high
			gen double `_high'=0 
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=0 
			forvalues i=1/3 {
				replace `varlist'=`i'         if `_pip_s`i''>`_high' 
				replace `_high'  =`_pip_s`i'' if `_pip_s`i''>`_high' 
			}			
			label var `varlist' "two-step classification based on S only"
		}
		else if "`bclass_r'"!="" {
			tempvar _pip_r1
			ky_p `typlist' `_pip_r1' , pip_r1
		    syntax newvarname [if] [in] [, * ]
			gen  `typlist' `varlist'=1+`_pip_r1'<.5 if `touse'
		}
		
		else if "`bclass'"!="" {
			tempvar _mean_s1 _sig_s1 ///
			        _mean_s2 _sig_s2 ///
					_mean_s3 _sig_s3 ///
					_mean_r2 _sig_r2
			*_mean_r1 sig_r1 
			ky_p double `_mean_s1', mean_s1
			ky_p double `_sig_s1' ,  sig_s1
			ky_p double `_mean_s2', mean_s2
			ky_p double `_sig_s2' ,  sig_s2
			ky_p double `_mean_s3', mean_s3
			ky_p double `_sig_s3' ,  sig_s3
			*ky_p double `_mean_r1', mean_r1
			*ky_p double `_sig_r1' ,  sig_r1
			ky_p double `_mean_r2', mean_r2
			ky_p double `_sig_r2' ,  sig_r2
			
			ky_p double `_rho_s'  ,  rho_s
			ky_p double `_sig_e'  , sig_e
			
			tempvar _pi_2 _pi_3 _pi_4 _pi_5 _pi_6
			ky_p double `_pi_2'  ,  pi_2
			ky_p double `_pi_3'  ,  pi_3
			ky_p double `_pi_4'  ,  pi_4
			ky_p double `_pi_5'  ,  pi_5
			ky_p double `_pi_6'  ,  pi_6
			
			local _mean_r1 (`_mean_s1')
			local _sig_r1 (`_sig_s1')
			
			local _rho_r1s1  1
			local _rho_r1s2  (((1+`_rho_s')*`_sig_e'^2)/(`_sig_r1'*`_sig_s2'))
			local _rho_r1s3  (((1+`_rho_s')*`_sig_e'^2)/(`_sig_r1'*`_sig_s3'))
			local _rho_r2s1  0
			local _rho_r2s2  0
			local _rho_r2s3  0
	
			tempvar _pip2 _pip3 _pip4 _pip5 _pip6  
			local _std_r1 ((`_r'-`_mean_r1')/`_sig_r1')
			local _std_r2 ((`_r'-`_mean_r2')/`_sig_r2')
			local _std_s1 ((`_s'-`_mean_s1')/`_sig_s1')
			local _std_s2 ((`_s'-`_mean_s2')/`_sig_s2')
			local _std_s3 ((`_s'-`_mean_s3')/`_sig_s3')
			
			gen double `_pip2'=`_pi_2'*(1/(2*_pi*`_sig_r1'*`_sig_s2'*sqrt(1-`_rho_r1s2'^2))*exp(-1/(2*(1-`_rho_r1s2'^2))*(`_std_r1'^2+`_std_s2'^2-2*`_rho_r1s2'*`_std_r1'*`_std_s2')))
			gen double `_pip3'=`_pi_3'*(1/(2*_pi*`_sig_r1'*`_sig_s3'*sqrt(1-`_rho_r1s3'^2))*exp(-1/(2*(1-`_rho_r1s3'^2))*(`_std_r1'^2+`_std_s3'^2-2*`_rho_r1s3'*`_std_r1'*`_std_s3'))) 
			gen double `_pip4'=`_pi_4'*(normalden(`_r',`_mean_r2',`_sig_r2')*normalden(`_s',`_mean_s1',`_sig_s1'))
			gen double `_pip5'=`_pi_5'*(normalden(`_r',`_mean_r2',`_sig_r2')*normalden(`_s',`_mean_s2',`_sig_s2'))
			gen double `_pip6'=`_pi_6'*(normalden(`_r',`_mean_r2',`_sig_r2')*normalden(`_s',`_mean_s3',`_sig_s3'))
			
			tempvar _pip_2 _pip_3 _pip_4 _pip_5 _pip_6
			gen double `_pip_2'=`_pip2'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
			gen double `_pip_3'=`_pip3'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
			gen double `_pip_4'=`_pip4'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
			gen double `_pip_5'=`_pip5'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
			gen double `_pip_6'=`_pip6'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
			
			tempvar _high
			gen double `_high'=.
			replace `_high'=0 if `_l'==0
			syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=1 if `_l'==1
			forvalues i=2/6 {
				replace `varlist'=`i'        if `_pip_`i''>`_high' & `_l'==0
				replace `_high'  =`_pip_`i'' if `_pip_`i''>`_high' & `_l'==0
			}
		}
	}
end

*********************** *********************** ***********************  

program define ky_p_5 	
version 14
    syntax anything(id="newvarname") [if] [in] , [pi_s pi_r pi_w pi_v  				/// Probabilities of each event
								   rho_s  rho_r 							  		/// RHO's (Regression to the mean factors)
								   mean_e mean_n mean_w mean_t mean_v 				/// Conditional Means
								   sig_e  sig_n  sig_w  sig_t  sig_v 	        	/// conditional Standard deviations
								   mean_r1 mean_r2 mean_r3 mean_s1 mean_s2 mean_s3  /// mean by group
								   sig_r1  sig_r2  sig_r3  sig_s1  sig_s2  sig_s3   /// sigma by group
								   pi_r1  pi_r2  pi_r3  pi_s1  pi_s2  pi_s3  		/// Probabilities by category
								   pip_r1 pip_r2 pip_r3 pip_s1 pip_s2 pip_s3  		/// Probabilities by category. Posterior Prob
								   pi_1 pi_2 pi_3 pi_4 pi_5 pi_6 pi_7 pi_8 pi_9 	/// Probabilities by group classification
								   pip_1 pip_2 pip_3 pip_4 pip_5 pip_6 pip_7 pip_8 pip_9 /// Probabilities by group classification
								   bclass_r bclass_s bclass	* ]
								   
    marksample touse, novarlist
 	*** getting dep variables
	tokenize "`e(depvar)'"
	local _r `1'
	local _s `2'
	local _l `3'
	*** NOW ALL cases
	*** defining all elements:
	*** Creating this variables first may make this program more efficient.
	tempvar _pi_s   _pi_r   _pi_w   _pi_v   
	tempvar _mean_e _mean_n _mean_t _mean_w _mean_v 
	tempvar _sig_e  _sig_n  _sig_t  _sig_w  _sig_v 
	tempvar _rho_s _rho_r
***************************************************************
	qui {
	    if "`options'"!="" {
			ml_p `0'
			exit
		}
		else if "`pi_s'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'  =(invlogit(xb(lpi_s)))  if `touse' 
			label var `varlist' "A priori Pi_s"
		}
		else if "`pi_r'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'  =(invlogit(xb(lpi_r)))  if `touse' 
			label var `varlist' "A priori Pi_r"
		}
		else if "`pi_w'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'  =(invlogit(xb(lpi_w)))  if `touse' 
			label var `varlist' "A priori Pi_r"
		}
		else if "`pi_v'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'  =(invlogit(xb(lpi_v)))  if `touse' 
			label var `varlist' "A priori Pi_v"
		}
		****************
	    else if "`mean_e'"!="" {
		    syntax newvarname [if] [in] [, * ]
			_predict `typlist' `varlist' if `touse', xb eq(mu_e)
			label var `varlist' "Conditional mean for component e"
		}
	    else if "`mean_n'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_n)
			label var `varlist' "Conditional mean for component n"
		}
		else if "`mean_w'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_w)
			label var `varlist' "Conditional mean for component w"
		}
	    else if "`mean_t'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_t)
			label var `varlist' "Conditional mean for component t"
		}
		else if "`mean_v'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_v)
			label var `varlist' "Conditional mean for component v"
		}
	   
		*** Sigmas
		else if "`sig_e'"!="" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist' =exp(xb(ln_sig_e)) if `touse'
			label var `varlist' "Conditional stdev for component e"
		}
	    else if "`sig_n'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    predictnl `typlist' `varlist' =exp(xb(ln_sig_n)) if `touse'
			label var `varlist' "Conditional stdev for component n"
		}
		else if "`sig_w'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    predictnl `typlist' `varlist' =exp(xb(ln_sig_w)) if `touse'
			label var `varlist' "Conditional stdev for component w"
		}
	    else if "`sig_t'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    predictnl `typlist' `varlist' =exp(xb(ln_sig_t)) if `touse'
			label var `varlist' "Conditional stdev for component t"
		}
		else if "`sig_v'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    predictnl `typlist' `varlist' =exp(xb(ln_sig_v)) if `touse'
			label var `varlist' "Conditional stdev for component v"
		}
		else if "`rho_r'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'=tanh(xb(arho_r)) if `touse'
			label var `varlist' "Rho r: RTM Admin data"
		}
		else if "`rho_s'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'=tanh(xb(arho_s)) if `touse'
			label var `varlist' "Rho s: RTM Survey data"
		}
		***********************************************
		else if "`mean_r1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , mean_e
			label var `varlist' "Conditional mean R1"
		}
		else if "`mean_r2'"!="" {
			ky_p double `_mean_e', mean_e
			ky_p double `_mean_v', mean_v
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_mean_e'+`_mean_v' if `touse'
			label var `varlist' "Conditional mean R2"
		}
		else if "`mean_r3'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , mean_t
			label var `varlist' "Conditional mean R3"
		}
		else if "`mean_s1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , mean_e
			label var `varlist' "Conditional mean S1"
		}
		else if "`mean_s2'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_mean_e', mean_e
			ky_p double `_mean_n', mean_n
			gen `typlist' `varlist'=`_mean_e'+`_mean_n' if `touse'
			label var `varlist' "Conditional mean S2"
		}
		else if "`mean_s3'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_mean_e', mean_e
			ky_p double `_mean_n', mean_n
			ky_p double `_mean_w', mean_w
			gen `typlist' `varlist'=`_mean_e'+`_mean_n'+`_mean_w' if `touse'
			label var `varlist' "Conditional mean S3"
		}
		else if "`sig_r1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , sig_e
			label var `varlist' "Conditional sigma R1"
		}
		else if "`sig_r2'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_sig_e', sig_e
			ky_p double `_sig_v', sig_v
			ky_p double `_rho_r', rho_r
			gen `typlist' `varlist'=(sqrt((1+`_rho_r')^2*`_sig_e'^2+`_sig_v'^2)) if `touse'
			label var `varlist' "Conditional sigma R2"
		}
		else if "`sig_r3'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , sig_t
			label var `varlist' "Conditional sigma R3"
		}
		else if "`sig_s1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , sig_e
			label var `varlist' "Conditional sigma S1"
		}
		else if "`sig_s2'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_sig_e', sig_e
			ky_p double `_sig_n', sig_n
			ky_p double `_rho_s', rho_s
			gen `typlist' `varlist'=(sqrt((1+`_rho_s')^2*`_sig_e'^2+`_sig_n'^2)) if `touse'
			label var `varlist' "Conditional sigma S2"
		}
		else if "`sig_s3'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_sig_e', sig_e
			ky_p double `_sig_n', sig_n
			ky_p double `_sig_w', sig_w
			ky_p double `_rho_s', rho_s
			gen `typlist' `varlist'=(sqrt((1+`_rho_s')^2*`_sig_e'^2+`_sig_n'^2+`_sig_w'^2)) if `touse'
			label var `varlist' "Conditional sigma S3"
		}
		***************************************
		else if "`pi_r1'" != "" {
			ky_p double `_pi_r'  if `touse' , pi_r  
			ky_p double `_pi_v'  if `touse' , pi_v 
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=(( `_pi_r')*(  `_pi_v')) if `touse'
			label var `varlist' "Latent Class pi r type 1"
		}
		else if "`pi_r2'" != "" {
			ky_p double `_pi_r'  if `touse' , pi_r  
			ky_p double `_pi_v'  if `touse' , pi_v 
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=(( `_pi_r')*(1-`_pi_v')) if `touse'
			label var `varlist' "Latent Class pi r type 2"
		}
		else if "`pi_r3'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , pi_r  
			replace `varlist'=1-`varlist'  if `touse'
			label var `varlist' "Latent Class pi r type 3"
		}
		else if "`pi_s1'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , pi_s  
			label var `varlist' "Latent Class pi s type 1"
		}
		else if "`pi_s2'" != "" {
		    ky_p double `_pi_s'  if `touse' , pi_s  
			ky_p double `_pi_w'  if `touse' , pi_w  
			syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=((1-`_pi_s')*(1-`_pi_w')) if `touse'
			label var `varlist' "Latent Class pi s type 2"
		}
		else if "`pi_s3'" != "" {
		    ky_p double `_pi_s'  if `touse' , pi_s  
			ky_p double `_pi_w'  if `touse' , pi_w  
			syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=((1-`_pi_s')*( `_pi_w')) if `touse'
			label var `varlist' "Latent Class pi s type 3"
		}
		***************************************
        else if "`pi_1'" != "" {
			ky_p double `_pi_r', pi_r1
			ky_p double `_pi_s', pi_s1
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_1"
		}
		else if "`pi_2'" != "" {
			ky_p double `_pi_r', pi_r1
			ky_p double `_pi_s', pi_s2
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_2"
		}
		else if "`pi_3'" != "" {
			ky_p double `_pi_r', pi_r1
			ky_p double `_pi_s', pi_s3
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_3"
		}
		else if "`pi_4'" != "" {
			ky_p double `_pi_r', pi_r2
			ky_p double `_pi_s', pi_s1
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_4"
		}
		else if "`pi_5'" != "" {
			ky_p double `_pi_r', pi_r2
			ky_p double `_pi_s', pi_s2
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_5"
		}
		else if "`pi_6'" != "" {
			ky_p double `_pi_r', pi_r2
			ky_p double `_pi_s', pi_s3
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_6"
		}
		else if "`pi_7'" != "" {
			ky_p double `_pi_r', pi_r3
			ky_p double `_pi_s', pi_s1
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_7"
		}
		else if "`pi_8'" != "" {
			ky_p double `_pi_r', pi_r3
			ky_p double `_pi_s', pi_s2
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_8"
		}
		else if "`pi_9'" != "" {
			ky_p double `_pi_r', pi_r3
			ky_p double `_pi_s', pi_s3
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_9"
		}
		*** posterior. assuming we see only 1 thing.
		else if "`pip_r1'`pip_r2'`pip_r3'" != "" {
			tempvar _mean_r1 _mean_r2  _mean_r3 ///
				    _sig_r1 _sig_r2 _sig_r3 ///
					_pi_r1 _pi_r2
			ky_p double `_mean_r1', mean_r1
			ky_p double `_sig_r1' ,  sig_r1
			ky_p double `_mean_r2', mean_r2
			ky_p double `_sig_r2' ,  sig_r2
			ky_p double `_mean_r3', mean_r3
			ky_p double `_sig_r3' ,  sig_r3			
			ky_p double `_pi_r1'  ,  pi_r1
			ky_p double `_pi_r2'  ,  pi_r2
			local _pi_r3 (1-`_pi_r1'-`_pi_r2')
			
			tempvar _pip_1 _pip_2 _pip_3
			gen double `_pip_1' =    `_pi_r1' *normalden(`_r',`_mean_r1',`_sig_r1')
			gen double `_pip_2' =    `_pi_r2' *normalden(`_r',`_mean_r2',`_sig_r2')
			gen double `_pip_3' =    `_pi_r3' *normalden(`_r',`_mean_r3',`_sig_r3')
			if "`pip_r1'"!=""	{
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_1'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi r type 1"
			}
			else if "`pip_r2'"!=""	{
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_2'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi r type 2"
			}
			else if "`pip_r3'"!=""	{
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_3'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi r type 3"
			}
		}
		else if "`pip_s1'`pip_s2'`pip_s3'" != "" {
			tempvar _mean_s1 _mean_s2  _mean_s3 ///
				    _sig_s1 _sig_s2 _sig_s3 ///
					_pi_s1 _pi_s2
			ky_p double `_mean_s1', mean_s1
			ky_p double `_sig_s1' ,  sig_s1
			ky_p double `_mean_s2', mean_s2
			ky_p double `_sig_s2' ,  sig_s2
			ky_p double `_mean_s3', mean_s3
			ky_p double `_sig_s3' ,  sig_s3			
			ky_p double `_pi_s1'  ,  pi_s1
			ky_p double `_pi_s2'  ,  pi_s2
			local _pi_s3 (1-`_pi_s1'-`_pi_s2')
			
			tempvar _pip_1 _pip_2 _pip_3
			gen double `_pip_1' =    `_pi_s1' *normalden(`_s',`_mean_s1',`_sig_s1')
			gen double `_pip_2' =    `_pi_s2' *normalden(`_s',`_mean_s2',`_sig_s2')
			gen double `_pip_3' =    `_pi_s3' *normalden(`_s',`_mean_s3',`_sig_s3')
			if "`pip_s1'" != "" {
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_1'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi s type 1"
			}	
			else if "`pip_s2'" != "" {
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_2'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi s type 2"
			}
			else if "`pip_s3'" != "" {
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_3'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi s type 3"
			}
		}
		********************************************
		else if "`pip_1'" != "" {
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_l' if `touse'
			label var `varlist' "Posterior prob pi_1 Constant and equal to 1"
		}
		else if "`pip_2'`pip_3'`pip_4'`pip_5'`pip_6'`pip_7'`pip_8'`pip_9'" != "" {
			tempvar _mean_s1 _sig_s1 ///
			        _mean_s2 _sig_s2 ///
					_mean_s3 _sig_s3 ///
					_mean_r2 _sig_r2 ///
					_mean_r3 _sig_r3
			*_mean_r1 sig_r1 
			ky_p double `_mean_s1', mean_s1
			ky_p double `_sig_s1' ,  sig_s1
			ky_p double `_mean_s2', mean_s2
			ky_p double `_sig_s2' ,  sig_s2
			ky_p double `_mean_s3', mean_s3
			ky_p double `_sig_s3' ,  sig_s3
			*ky_p double `_mean_r1', mean_r1
			*ky_p double `_sig_r1' ,  sig_r1
			ky_p double `_mean_r2', mean_r2
			ky_p double `_sig_r2' ,  sig_r2
			ky_p double `_mean_r3', mean_r3
			ky_p double `_sig_r3' ,  sig_r3
			
			ky_p double `_rho_s'  ,  rho_s
			ky_p double `_rho_r'  ,  rho_r
			
			ky_p double `_sig_e'  , sig_e
			
			tempvar _pi_2 _pi_3 _pi_4 _pi_5 _pi_6 _pi_7 _pi_8 _pi_9
			ky_p double `_pi_2'  ,  pi_2
			ky_p double `_pi_3'  ,  pi_3
			ky_p double `_pi_4'  ,  pi_4
			ky_p double `_pi_5'  ,  pi_5
			ky_p double `_pi_6'  ,  pi_6
			ky_p double `_pi_7'  ,  pi_7
			ky_p double `_pi_8'  ,  pi_8
			ky_p double `_pi_9'  ,  pi_9
			
			local _mean_r1 (`_mean_s1')
			local _sig_r1 (`_sig_s1')
			
			local _rho_r1s1  1
			local _rho_r1s2  (((1+`_rho_s')*`_sig_e'^2)/(`_sig_r1'*`_sig_s2'))
			local _rho_r1s3  (((1+`_rho_s')*`_sig_e'^2)/(`_sig_r1'*`_sig_s3'))
			local _rho_r2s1  ((             (1+`_rho_r')*`_sig_e'^2)/(`_sig_r2'*`_sig_s1'))
			local _rho_r2s2  (((1+`_rho_s')*(1+`_rho_r')*`_sig_e'^2)/(`_sig_r2'*`_sig_s2'))
			local _rho_r2s3  (((1+`_rho_s')*(1+`_rho_r')*`_sig_e'^2)/(`_sig_r2'*`_sig_s3'))
			local _rho_r3s1  0
			local _rho_r3s2  0
			local _rho_r3s3  0
	
			tempvar _pip2 _pip3 _pip4 _pip5 _pip6 _pip7 _pip8 _pip9
			local _std_r1 ((`_r'-`_mean_r1')/`_sig_r1')
			local _std_r2 ((`_r'-`_mean_r2')/`_sig_r2')
			local _std_r3 ((`_r'-`_mean_r3')/`_sig_r3')
			local _std_s1 ((`_s'-`_mean_s1')/`_sig_s1')
			local _std_s2 ((`_s'-`_mean_s2')/`_sig_s2')
			local _std_s3 ((`_s'-`_mean_s3')/`_sig_s3')
			
			gen double `_pip2'=`_pi_2'*(1/(2*_pi*`_sig_r1'*`_sig_s2'*sqrt(1-`_rho_r1s2'^2))*exp(-1/(2*(1-`_rho_r1s2'^2))*(`_std_r1'^2+`_std_s2'^2-2*`_rho_r1s2'*`_std_r1'*`_std_s2')))
			gen double `_pip3'=`_pi_3'*(1/(2*_pi*`_sig_r1'*`_sig_s3'*sqrt(1-`_rho_r1s3'^2))*exp(-1/(2*(1-`_rho_r1s3'^2))*(`_std_r1'^2+`_std_s3'^2-2*`_rho_r1s3'*`_std_r1'*`_std_s3'))) 
			gen double `_pip4'=`_pi_4'*(1/(2*_pi*`_sig_r2'*`_sig_s1'*sqrt(1-`_rho_r2s1'^2))*exp(-1/(2*(1-`_rho_r2s1'^2))*(`_std_r2'^2+`_std_s1'^2-2*`_rho_r2s1'*`_std_r2'*`_std_s1'))) 
			gen double `_pip5'=`_pi_5'*(1/(2*_pi*`_sig_r2'*`_sig_s2'*sqrt(1-`_rho_r2s2'^2))*exp(-1/(2*(1-`_rho_r2s2'^2))*(`_std_r2'^2+`_std_s2'^2-2*`_rho_r2s2'*`_std_r2'*`_std_s2'))) 
			gen double `_pip6'=`_pi_6'*(1/(2*_pi*`_sig_r2'*`_sig_s3'*sqrt(1-`_rho_r2s3'^2))*exp(-1/(2*(1-`_rho_r2s3'^2))*(`_std_r2'^2+`_std_s3'^2-2*`_rho_r2s3'*`_std_r2'*`_std_s3'))) 
			gen double `_pip7'=`_pi_7'*(normalden(`_r',`_mean_r3',`_sig_r3')*normalden(`_s',`_mean_s1',`_sig_s1'))
			gen double `_pip8'=`_pi_8'*(normalden(`_r',`_mean_r3',`_sig_r3')*normalden(`_s',`_mean_s2',`_sig_s2'))
			gen double `_pip9'=`_pi_9'*(normalden(`_r',`_mean_r3',`_sig_r3')*normalden(`_s',`_mean_s3',`_sig_s3'))
			
			syntax newvarname [if] [in] [, * ]
			if "`pip_2'"!="" {
				gen `typlist' `varlist'=`_pip2'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_2"
			}
			if "`pip_3'"!="" {
				gen `typlist' `varlist'=`_pip3'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_3"
			}
			if "`pip_4'"!="" {
				gen `typlist' `varlist'=`_pip4'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_4"
			}
			if "`pip_5'"!="" {
				gen `typlist' `varlist'=`_pip5'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_5"
			}
			if "`pip_6'"!="" {
				gen `typlist' `varlist'=`_pip6'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_6"
			}
			if "`pip_7'"!="" {
				gen `typlist' `varlist'=`_pip7'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_7"
			}
			if "`pip_8'"!="" {
				gen `typlist' `varlist'=`_pip8'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_8"
			}
			if "`pip_9'"!="" {
				gen `typlist' `varlist'=`_pip9'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_9"
			}			
		}
*************************************************************************
		else if "`bclass_s'"!="" {
			tempvar _pip_s1 _pip_s2  
			ky_p double `_pip_s1' , pip_s1
			ky_p double `_pip_s2' , pip_s2
			local _pip_s3 (1-`_pip_s1'-`_pip_s2')
			tempvar _high
			gen double `_high'=0 
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=0 
			forvalues i=1/3 {
				replace `varlist'=`i'         if `_pip_s`i''>`_high' 
				replace `_high'  =`_pip_s`i'' if `_pip_s`i''>`_high' 
			}			
			label var `varlist' "two-step classification based on S only"
		}
		else if "`bclass_r'"!="" {
			tempvar _pip_r1 _pip_r2  
			ky_p double `_pip_r1' , pip_r1
			ky_p double `_pip_r2' , pip_r2
			local _pip_r3 (1-`_pip_r1'-`_pip_r2')
			tempvar _high
			gen double `_high'=0 
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=0 
			forvalues i=1/3 {
				replace `varlist'=`i'         if `_pip_r`i''>`_high' 
				replace `_high'  =`_pip_r`i'' if `_pip_r`i''>`_high' 
			}			
			label var `varlist' "two-step classification based on R only"
		}
		
		else if "`bclass'"!="" {
			tempvar _mean_s1 _sig_s1 ///
			        _mean_s2 _sig_s2 ///
					_mean_s3 _sig_s3 ///
					_mean_r2 _sig_r2 ///
					_mean_r3 _sig_r3
			*_mean_r1 sig_r1 
			ky_p double `_mean_s1', mean_s1
			ky_p double `_sig_s1' ,  sig_s1
			ky_p double `_mean_s2', mean_s2
			ky_p double `_sig_s2' ,  sig_s2
			ky_p double `_mean_s3', mean_s3
			ky_p double `_sig_s3' ,  sig_s3
			*ky_p double `_mean_r1', mean_r1
			*ky_p double `_sig_r1' ,  sig_r1
			ky_p double `_mean_r2', mean_r2
			ky_p double `_sig_r2' ,  sig_r2
			ky_p double `_mean_r3', mean_r3
			ky_p double `_sig_r3' ,  sig_r3
			
			ky_p double `_rho_s'  ,  rho_s
			ky_p double `_rho_r'  ,  rho_r
			
			ky_p double `_sig_e'  , sig_e
			
			tempvar _pi_2 _pi_3 _pi_4 _pi_5 _pi_6 _pi_7 _pi_8 _pi_9
			ky_p double `_pi_2'  ,  pi_2
			ky_p double `_pi_3'  ,  pi_3
			ky_p double `_pi_4'  ,  pi_4
			ky_p double `_pi_5'  ,  pi_5
			ky_p double `_pi_6'  ,  pi_6
			ky_p double `_pi_7'  ,  pi_7
			ky_p double `_pi_8'  ,  pi_8
			ky_p double `_pi_9'  ,  pi_9
			
			local _mean_r1 (`_mean_s1')
			local _sig_r1 (`_sig_s1')
			
			local _rho_r1s1  1
			local _rho_r1s2  (((1+`_rho_s')*`_sig_e'^2)/(`_sig_r1'*`_sig_s2'))
			local _rho_r1s3  (((1+`_rho_s')*`_sig_e'^2)/(`_sig_r1'*`_sig_s3'))
			local _rho_r2s1  ((             (1+`_rho_r')*`_sig_e'^2)/(`_sig_r2'*`_sig_s1'))
			local _rho_r2s2  (((1+`_rho_s')*(1+`_rho_r')*`_sig_e'^2)/(`_sig_r2'*`_sig_s2'))
			local _rho_r2s3  (((1+`_rho_s')*(1+`_rho_r')*`_sig_e'^2)/(`_sig_r2'*`_sig_s3'))
			local _rho_r3s1  0
			local _rho_r3s2  0
			local _rho_r3s3  0
	
			tempvar _pip2 _pip3 _pip4 _pip5 _pip6 _pip7 _pip8 _pip9
			local _std_r1 ((`_r'-`_mean_r1')/`_sig_r1')
			local _std_r2 ((`_r'-`_mean_r2')/`_sig_r2')
			local _std_r3 ((`_r'-`_mean_r3')/`_sig_r3')
			local _std_s1 ((`_s'-`_mean_s1')/`_sig_s1')
			local _std_s2 ((`_s'-`_mean_s2')/`_sig_s2')
			local _std_s3 ((`_s'-`_mean_s3')/`_sig_s3')
			
			gen double `_pip2'=`_pi_2'*(1/(2*_pi*`_sig_r1'*`_sig_s2'*sqrt(1-`_rho_r1s2'^2))*exp(-1/(2*(1-`_rho_r1s2'^2))*(`_std_r1'^2+`_std_s2'^2-2*`_rho_r1s2'*`_std_r1'*`_std_s2')))
			gen double `_pip3'=`_pi_3'*(1/(2*_pi*`_sig_r1'*`_sig_s3'*sqrt(1-`_rho_r1s3'^2))*exp(-1/(2*(1-`_rho_r1s3'^2))*(`_std_r1'^2+`_std_s3'^2-2*`_rho_r1s3'*`_std_r1'*`_std_s3'))) 
			gen double `_pip4'=`_pi_4'*(1/(2*_pi*`_sig_r2'*`_sig_s1'*sqrt(1-`_rho_r2s1'^2))*exp(-1/(2*(1-`_rho_r2s1'^2))*(`_std_r2'^2+`_std_s1'^2-2*`_rho_r2s1'*`_std_r2'*`_std_s1'))) 
			gen double `_pip5'=`_pi_5'*(1/(2*_pi*`_sig_r2'*`_sig_s2'*sqrt(1-`_rho_r2s2'^2))*exp(-1/(2*(1-`_rho_r2s2'^2))*(`_std_r2'^2+`_std_s2'^2-2*`_rho_r2s2'*`_std_r2'*`_std_s2'))) 
			gen double `_pip6'=`_pi_6'*(1/(2*_pi*`_sig_r2'*`_sig_s3'*sqrt(1-`_rho_r2s3'^2))*exp(-1/(2*(1-`_rho_r2s3'^2))*(`_std_r2'^2+`_std_s3'^2-2*`_rho_r2s3'*`_std_r2'*`_std_s3'))) 
			gen double `_pip7'=`_pi_7'*(normalden(`_r',`_mean_r3',`_sig_r3')*normalden(`_s',`_mean_s1',`_sig_s1'))
			gen double `_pip8'=`_pi_8'*(normalden(`_r',`_mean_r3',`_sig_r3')*normalden(`_s',`_mean_s2',`_sig_s2'))
			gen double `_pip9'=`_pi_9'*(normalden(`_r',`_mean_r3',`_sig_r3')*normalden(`_s',`_mean_s3',`_sig_s3'))
			
			tempvar _pip_2 _pip_3 _pip_4 _pip_5 _pip_6 _pip_7 _pip_8 _pip_9
			gen double `_pip_2'=`_pip2'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
			gen double `_pip_3'=`_pip3'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
			gen double `_pip_4'=`_pip4'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
			gen double `_pip_5'=`_pip5'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
			gen double `_pip_6'=`_pip6'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
			gen double `_pip_7'=`_pip7'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
			gen double `_pip_8'=`_pip8'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
			gen double `_pip_9'=`_pip9'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
			
			tempvar _high
			gen double `_high'=.
			replace `_high'=0 if `_l'==0
			syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=1 if `_l'==1
			forvalues i=2/9 {
				replace `varlist'=`i'        if `_pip_`i''>`_high' & `_l'==0
				replace `_high'  =`_pip_`i'' if `_pip_`i''>`_high' & `_l'==0
			}
		}
	}
    
end

*********************** *********************** ***********************  
program define ky_p_6 	
version 14
        syntax anything(id="newvarname") [if] [in] , [pi_s pi_r   pi_v  		/// Probabilities of each event
								   rho_s  rho_r 							  	/// RHO's (Regression to the mean factors)
								   mean_e mean_n   mean_t mean_v 			    /// Conditional Means
								   sig_e  sig_n     sig_t  sig_v 	            /// conditional Standard deviations
								   mean_r1 mean_r2 mean_r3 mean_s1 mean_s2      /// mean by group
								   sig_r1  sig_r2  sig_r3  sig_s1  sig_s2       /// sigma by group
								   pi_r1  pi_r2  pi_r3  pi_s1  pi_s2     		/// Probabilities by category
								   pip_r1 pip_r2 pip_r3 pip_s1 pip_s2    		/// Probabilities by category. Posterior Prob
								   pi_1  pi_2  pi_3  pi_4  pi_5  pi_6           /// Probabilities by group classification
								   pip_1 pip_2 pip_3 pip_4 pip_5 pip_6          /// Probabilities by group classification
								   bclass_r bclass_s bclass	* ]
								   
    marksample touse, novarlist
 	*** getting dep variables
	tokenize "`e(depvar)'"
	local _r `1'
	local _s `2'
	local _l `3'
	*** NOW ALL cases
	*** defining all elements:
	*** Creating this variables first may make this program more efficient.
	tempvar _pi_s   _pi_r   _pi_w   _pi_v   
	tempvar _mean_e _mean_n _mean_t _mean_w _mean_v 
	tempvar _sig_e  _sig_n  _sig_t  _sig_w  _sig_v 
	tempvar _rho_s _rho_r
***************************************************************
	qui {
	    if "`options'"!="" {
			ml_p `0'
			exit
		}
		else if "`pi_s'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'  =(invlogit(xb(lpi_s)))  if `touse' 
			label var `varlist' "A priori Pi_s"
		}
		else if "`pi_r'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'  =(invlogit(xb(lpi_r)))  if `touse' 
			label var `varlist' "A priori Pi_r"
		}
		else if "`pi_v'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'  =(invlogit(xb(lpi_v)))  if `touse' 
			label var `varlist' "A priori Pi_v"
		}
		****************
	    else if "`mean_e'"!="" {
		    syntax newvarname [if] [in] [, * ]
			_predict `typlist' `varlist' if `touse', xb eq(mu_e)
			label var `varlist' "Conditional mean for component e"
		}
	    else if "`mean_n'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_n)
			label var `varlist' "Conditional mean for component n"
		}
	    else if "`mean_t'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_t)
			label var `varlist' "Conditional mean for component t"
		}
		else if "`mean_v'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_v)
			label var `varlist' "Conditional mean for component v"
		}
	   
		*** Sigmas
		else if "`sig_e'"!="" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist' =exp(xb(ln_sig_e)) if `touse'
			label var `varlist' "Conditional stdev for component e"
		}
	    else if "`sig_n'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    predictnl `typlist' `varlist' =exp(xb(ln_sig_n)) if `touse'
			label var `varlist' "Conditional stdev for component n"
		}
	    else if "`sig_t'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    predictnl `typlist' `varlist' =exp(xb(ln_sig_t)) if `touse'
			label var `varlist' "Conditional stdev for component t"
		}
		else if "`sig_v'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    predictnl `typlist' `varlist' =exp(xb(ln_sig_v)) if `touse'
			label var `varlist' "Conditional stdev for component v"
		}
		else if "`rho_r'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'=tanh(xb(arho_r)) if `touse'
			label var `varlist' "Rho r: RTM Admin data"
		}
		else if "`rho_s'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'=tanh(xb(arho_s)) if `touse'
			label var `varlist' "Rho s: RTM Survey data"
		}
		***********************************************
		else if "`mean_r1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , mean_e
			label var `varlist' "Conditional mean R1"
		}
		else if "`mean_r2'"!="" {
			ky_p double `_mean_e', mean_e
			ky_p double `_mean_v', mean_v
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_mean_e'+`_mean_v' if `touse'
			label var `varlist' "Conditional mean R2"
		}
		else if "`mean_r3'"!="" {			
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , mean_t
			label var `varlist' "Conditional mean R3"
		}
		else if "`mean_s1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , mean_e
			label var `varlist' "Conditional mean S1"
		}
		else if "`mean_s2'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_mean_e', mean_e
			ky_p double `_mean_n', mean_n
			gen `typlist' `varlist'=`_mean_e'+`_mean_n' if `touse'
			label var `varlist' "Conditional mean S2"
		}
		else if "`sig_r1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , sig_e
			label var `varlist' "Conditional sigma R1"
		}
		else if "`sig_r2'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_sig_e', sig_e
			ky_p double `_sig_v', sig_v
			ky_p double `_rho_r', rho_r
			gen `typlist' `varlist'=(sqrt((1+`_rho_r')^2*`_sig_e'^2+`_sig_v'^2)) if `touse'
			label var `varlist' "Conditional sigma R2"
		}
		else if "`sig_r3'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , sig_t
			label var `varlist' "Conditional sigma R3"
		}
		else if "`sig_s1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , sig_e
			label var `varlist' "Conditional sigma S1"
		}
		else if "`sig_s2'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_sig_e', sig_e
			ky_p double `_sig_n', sig_n
			ky_p double `_rho_s', rho_s
			gen `typlist' `varlist'=(sqrt((1+`_rho_s')^2*`_sig_e'^2+`_sig_n'^2)) if `touse'
			label var `varlist' "Conditional sigma S2"
		}
		***************************************
		else if "`pi_r1'" != "" {
			ky_p double `_pi_r'  if `touse' , pi_r  
			ky_p double `_pi_v'  if `touse' , pi_v 
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=(( `_pi_r')*(  `_pi_v')) if `touse'
			label var `varlist' "Latent Class pi r type 1"
		}
		else if "`pi_r2'" != "" {
			ky_p double `_pi_r'  if `touse' , pi_r  
			ky_p double `_pi_v'  if `touse' , pi_v 
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=(( `_pi_r')*(1-`_pi_v')) if `touse'
			label var `varlist' "Latent Class pi r type 2"
		}
		else if "`pi_r3'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , pi_r  
			replace `varlist'=1-`varlist'  if `touse'
			label var `varlist' "Latent Class pi r type 3"
		}
		else if "`pi_s1'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , pi_s  
			label var `varlist' "Latent Class pi s type 1"
		}
		else if "`pi_s2'" != "" {
		    ky_p double `_pi_s'  if `touse' , pi_s  
			syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=(1-`_pi_s') if `touse'
			label var `varlist' "Latent Class pi s type 2"
		}
		***************************************
        else if "`pi_1'" != "" {
			ky_p double `_pi_r', pi_r1
			ky_p double `_pi_s', pi_s1
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_1"
		}
		else if "`pi_2'" != "" {
			ky_p double `_pi_r', pi_r1
			ky_p double `_pi_s', pi_s2
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_2"
		}
		else if "`pi_3'" != "" {
			ky_p double `_pi_r', pi_r2
			ky_p double `_pi_s', pi_s1
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_3"
		}
		else if "`pi_4'" != "" {
			ky_p double `_pi_r', pi_r2
			ky_p double `_pi_s', pi_s2
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_4"
		}
		else if "`pi_5'" != "" {
			ky_p double `_pi_r', pi_r3
			ky_p double `_pi_s', pi_s1
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_5"
		}
		else if "`pi_6'" != "" {
			ky_p double `_pi_r', pi_r3
			ky_p double `_pi_s', pi_s2
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_6"
		}
		*** posterior. assuming we see only 1 thing.
		else if "`pip_r1'`pip_r2'`pip_r3'" != "" {
			tempvar _mean_r1 _mean_r2  _mean_r3 ///
				    _sig_r1 _sig_r2 _sig_r3 ///
					_pi_r1 _pi_r2
			ky_p double `_mean_r1', mean_r1
			ky_p double `_sig_r1' ,  sig_r1
			ky_p double `_mean_r2', mean_r2
			ky_p double `_sig_r2' ,  sig_r2
			ky_p double `_mean_r3', mean_r3
			ky_p double `_sig_r3' ,  sig_r3
			ky_p double `_pi_r1'  ,  pi_r1
			ky_p double `_pi_r2'  ,  pi_r2
			local _pi_r3 (1-`_pi_r1'-`_pi_r2')
			tempvar _pip_1 _pip_2 _pip_3
			gen double `_pip_1' =    `_pi_r1' *normalden(`_r',`_mean_r1',`_sig_r1')
			gen double `_pip_2' =    `_pi_r2' *normalden(`_r',`_mean_r2',`_sig_r2')
			gen double `_pip_3' =    `_pi_r3' *normalden(`_r',`_mean_r3',`_sig_r3')
			if "`pip_r1'" != "" {
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_1'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi r type 1"
			}	
			else if "`pip_r2'" != "" {
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_2'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi r type 2"
			}
			else if "`pip_r3'" != "" {
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_3'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi r type 3"
			}
		}
		else if "`pip_s1'`pip_s2'" != "" {
			tempvar _mean_s1 _mean_s2  _mean_s3 ///
				    _sig_s1 _sig_s2 _sig_s3 ///
					_pi_s1 
			ky_p double `_mean_s1', mean_s1
			ky_p double `_sig_s1' ,  sig_s1
			ky_p double `_mean_s2', mean_s2
			ky_p double `_sig_s2' ,  sig_s2
			ky_p double `_pi_s1'  ,  pi_s1
			local _pi_s2 (1-`_pi_s1')
			tempvar _pip_1 _pip_2 _pip_3
			gen double `_pip_1' =    `_pi_s1' *normalden(`_s',`_mean_s1',`_sig_s1')
			gen double `_pip_2' =    `_pi_s2' *normalden(`_s',`_mean_s2',`_sig_s2')
			if "`pip_s1'" != "" {
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_1'/(`_pip_1'+`_pip_2')  if `touse' 
				label var `varlist' "Posterior pi s type 1"
			}	
			else if "`pip_s2'" != "" {
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_2'/(`_pip_1'+`_pip_2')  if `touse' 
				label var `varlist' "Posterior pi s type 2"
			}
		}
		*******************************************
		else if "`pip_1'" != "" {
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_l' if `touse'
			label var `varlist' "Posterior prob pi_1 Constant and equal to 1"
		}
		else if "`pip_2'`pip_3'`pip_4'`pip_5'`pip_6'" != "" {
			tempvar _mean_s1 _sig_s1 ///
			        _mean_s2 _sig_s2 ///
					_mean_r2 _sig_r2 ///
					_mean_r3 _sig_r3
			*_mean_r1 sig_r1 
			ky_p double `_mean_s1', mean_s1
			ky_p double `_sig_s1' ,  sig_s1
			ky_p double `_mean_s2', mean_s2
			ky_p double `_sig_s2' ,  sig_s2

			*ky_p double `_mean_r1', mean_r1
			*ky_p double `_sig_r1' ,  sig_r1
			ky_p double `_mean_r2', mean_r2
			ky_p double `_sig_r2' ,  sig_r2
			ky_p double `_mean_r3', mean_r3
			ky_p double `_sig_r3' ,  sig_r3
			
			ky_p double `_rho_s'  ,  rho_s
			ky_p double `_rho_r'  ,  rho_r
			
			ky_p double `_sig_e'  , sig_e
			
			tempvar _pi_2 _pi_3 _pi_4 _pi_5 _pi_6 _pi_7 _pi_8 _pi_9
			ky_p double `_pi_2'  ,  pi_2
			ky_p double `_pi_3'  ,  pi_3
			ky_p double `_pi_4'  ,  pi_4
			ky_p double `_pi_5'  ,  pi_5
			ky_p double `_pi_6'  ,  pi_6
			
			
			local _mean_r1 (`_mean_s1')
			local _sig_r1 (`_sig_s1')
			
			local _rho_r1s1  1
			local _rho_r1s2  (((1+`_rho_s')*`_sig_e'^2)/(`_sig_r1'*`_sig_s2'))
			
			local _rho_r2s1  ((             (1+`_rho_r')*`_sig_e'^2)/(`_sig_r2'*`_sig_s1'))
			local _rho_r2s2  (((1+`_rho_s')*(1+`_rho_r')*`_sig_e'^2)/(`_sig_r2'*`_sig_s2'))
			
			local _rho_r3s1  0
			local _rho_r3s2  0
			
	
			tempvar _pip2 _pip3 _pip4 _pip5 _pip6 _pip7 _pip8 _pip9
			local _std_r1 ((`_r'-`_mean_r1')/`_sig_r1')
			local _std_r2 ((`_r'-`_mean_r2')/`_sig_r2')
			local _std_r3 ((`_r'-`_mean_r3')/`_sig_r3')
			local _std_s1 ((`_s'-`_mean_s1')/`_sig_s1')
			local _std_s2 ((`_s'-`_mean_s2')/`_sig_s2')
			
			
			gen double `_pip2'=`_pi_2'*(1/(2*_pi*`_sig_r1'*`_sig_s2'*sqrt(1-`_rho_r1s2'^2))*exp(-1/(2*(1-`_rho_r1s2'^2))*(`_std_r1'^2+`_std_s2'^2-2*`_rho_r1s2'*`_std_r1'*`_std_s2')))
			gen double `_pip3'=`_pi_3'*(1/(2*_pi*`_sig_r2'*`_sig_s1'*sqrt(1-`_rho_r2s1'^2))*exp(-1/(2*(1-`_rho_r2s1'^2))*(`_std_r2'^2+`_std_s1'^2-2*`_rho_r2s1'*`_std_r2'*`_std_s1'))) 
			gen double `_pip4'=`_pi_4'*(1/(2*_pi*`_sig_r2'*`_sig_s2'*sqrt(1-`_rho_r2s2'^2))*exp(-1/(2*(1-`_rho_r2s2'^2))*(`_std_r2'^2+`_std_s2'^2-2*`_rho_r2s2'*`_std_r2'*`_std_s2'))) 
			gen double `_pip5'=`_pi_5'*(normalden(`_r',`_mean_r3',`_sig_r3')*normalden(`_s',`_mean_s1',`_sig_s1'))
			gen double `_pip6'=`_pi_6'*(normalden(`_r',`_mean_r3',`_sig_r3')*normalden(`_s',`_mean_s2',`_sig_s2'))
			
			
			syntax newvarname [if] [in] [, * ]
			if "`pip_2'"!="" {
				gen `typlist' `varlist'=`_pip2'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_2"
			}
			if "`pip_3'"!="" {
				gen `typlist' `varlist'=`_pip3'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_3"
			}
			if "`pip_4'"!="" {
				gen `typlist' `varlist'=`_pip4'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_4"
			}
			if "`pip_5'"!="" {
				gen `typlist' `varlist'=`_pip5'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_5"
			}
			if "`pip_6'"!="" {
				gen `typlist' `varlist'=`_pip6'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_6"
			}
		}
*************************************************************************
		else if "`bclass_s'"!="" {
			tempvar _pip_s1
			ky_p `typlist' `_pip_s1' , pip_s1
		    syntax newvarname [if] [in] [, * ]
			gen  `typlist' `varlist'=1+`_pip_s1'<.5 if `touse'			
			label var `varlist' "two-step classification based on S only"
		}
		else if "`bclass_r'"!="" {
			tempvar _pip_r1 _pip_r2  
			ky_p double `_pip_r1' , pip_r1
			ky_p double `_pip_r2' , pip_r2
			local _pip_r3 (1-`_pip_r1'-`_pip_r2')
			tempvar _high
			gen double `_high'=0 
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=0 
			forvalues i=1/3 {
				replace `varlist'=`i'         if `_pip_r`i''>`_high' 
				replace `_high'  =`_pip_r`i'' if `_pip_r`i''>`_high' 
			}			
			label var `varlist' "two-step classification based on R only"
		}
		
		else if "`bclass'"!="" {
			tempvar _mean_s1 _sig_s1 ///
			        _mean_s2 _sig_s2 ///
					_mean_r2 _sig_r2 ///
					_mean_r3 _sig_r3
			*_mean_r1 sig_r1 
			ky_p double `_mean_s1', mean_s1
			ky_p double `_sig_s1' ,  sig_s1
			ky_p double `_mean_s2', mean_s2
			ky_p double `_sig_s2' ,  sig_s2

			*ky_p double `_mean_r1', mean_r1
			*ky_p double `_sig_r1' ,  sig_r1
			ky_p double `_mean_r2', mean_r2
			ky_p double `_sig_r2' ,  sig_r2
			ky_p double `_mean_r3', mean_r3
			ky_p double `_sig_r3' ,  sig_r3
			
			ky_p double `_rho_s'  ,  rho_s
			ky_p double `_rho_r'  ,  rho_r

			ky_p double `_sig_e'  ,  sig_e

			tempvar _pi_2 _pi_3 _pi_4 _pi_5 _pi_6 _pi_7 _pi_8 _pi_9
			ky_p double `_pi_2'  ,  pi_2
			ky_p double `_pi_3'  ,  pi_3
			ky_p double `_pi_4'  ,  pi_4
			ky_p double `_pi_5'  ,  pi_5
			ky_p double `_pi_6'  ,  pi_6
			
			
			local _mean_r1 (`_mean_s1')
			local _sig_r1 (`_sig_s1')
			
			local _rho_r1s1  1
			local _rho_r1s2  (((1+`_rho_s')*`_sig_e'^2)/(`_sig_r1'*`_sig_s2'))
			
			local _rho_r2s1  ((             (1+`_rho_r')*`_sig_e'^2)/(`_sig_r2'*`_sig_s1'))
			local _rho_r2s2  (((1+`_rho_s')*(1+`_rho_r')*`_sig_e'^2)/(`_sig_r2'*`_sig_s2'))
			
			local _rho_r3s1  0
			local _rho_r3s2  0
			
	
			tempvar _pip2 _pip3 _pip4 _pip5 _pip6 _pip7 _pip8 _pip9
			local _std_r1 ((`_r'-`_mean_r1')/`_sig_r1')
			local _std_r2 ((`_r'-`_mean_r2')/`_sig_r2')
			local _std_r3 ((`_r'-`_mean_r3')/`_sig_r3')
			local _std_s1 ((`_s'-`_mean_s1')/`_sig_s1')
			local _std_s2 ((`_s'-`_mean_s2')/`_sig_s2')
			
			gen double `_pip2'=`_pi_2'*(1/(2*_pi*`_sig_r1'*`_sig_s2'*sqrt(1-`_rho_r1s2'^2))*exp(-1/(2*(1-`_rho_r1s2'^2))*(`_std_r1'^2+`_std_s2'^2-2*`_rho_r1s2'*`_std_r1'*`_std_s2')))
			gen double `_pip3'=`_pi_3'*(1/(2*_pi*`_sig_r2'*`_sig_s1'*sqrt(1-`_rho_r2s1'^2))*exp(-1/(2*(1-`_rho_r2s1'^2))*(`_std_r2'^2+`_std_s1'^2-2*`_rho_r2s1'*`_std_r2'*`_std_s1'))) 
			gen double `_pip4'=`_pi_4'*(1/(2*_pi*`_sig_r2'*`_sig_s2'*sqrt(1-`_rho_r2s2'^2))*exp(-1/(2*(1-`_rho_r2s2'^2))*(`_std_r2'^2+`_std_s2'^2-2*`_rho_r2s2'*`_std_r2'*`_std_s2'))) 
			gen double `_pip5'=`_pi_5'*(normalden(`_r',`_mean_r3',`_sig_r3')*normalden(`_s',`_mean_s1',`_sig_s1'))
			gen double `_pip6'=`_pi_6'*(normalden(`_r',`_mean_r3',`_sig_r3')*normalden(`_s',`_mean_s2',`_sig_s2'))
				
			tempvar _pip_2 _pip_3 _pip_4 _pip_5 _pip_6 
			gen double `_pip_2'=`_pip2'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
			gen double `_pip_3'=`_pip3'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
			gen double `_pip_4'=`_pip4'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
			gen double `_pip_5'=`_pip5'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
			gen double `_pip_6'=`_pip6'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
						
			tempvar _high
			gen double `_high'=.
			replace `_high'=0 if `_l'==0
			syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=1 if `_l'==1
			forvalues i=2/6 {
				replace `varlist'=`i'        if `_pip_`i''>`_high' & `_l'==0
				replace `_high'  =`_pip_`i'' if `_pip_`i''>`_high' & `_l'==0
			}
		}
	}
end


program define ky_p_7 	
version 14
    syntax anything(id="newvarname") [if] [in] , [pi_s pi_r pi_w    			/// Probabilities of each event
								   rho_s rho_w 							  		/// RHO's (Regression to the mean factors)
								   mean_e mean_n mean_w mean_t       		    /// Conditional Means
								   sig_e  sig_n  sig_w  sig_t      	            /// conditional Standard deviations
								   mean_r1 mean_r2 mean_s1 mean_s2 mean_s3      /// mean by group
								   sig_r1  sig_r2  sig_s1  sig_s2  sig_s3       /// sigma by group
								   pi_r1  pi_r2  pi_s1  pi_s2  pi_s3            /// Probabilities by category
								   pip_r1 pip_r2 pip_s1 pip_s2 pip_s3  	        /// Probabilities by category. Posterior Prob
								   pi_1  pi_2  pi_3  pi_4  pi_5  pi_6           /// Probabilities by group classification
								   pip_1 pip_2 pip_3 pip_4 pip_5 pip_6          /// Probabilities by group classification
								   bclass_r bclass_s bclass	*  ]
    
    marksample touse, novarlist
 	*** getting dep variables
	tokenize "`e(depvar)'"
	local _r `1'
	local _s `2'
	local _l `3'
	*** NOW ALL cases
	*** defining all elements:
	tempvar _pi_s   _pi_r   _pi_w   _pi_v   
	tempvar _mean_e _mean_n _mean_t _mean_w _mean_v 
	tempvar _sig_e  _sig_n  _sig_t  _sig_w  _sig_v 
	tempvar _rho_s _rho_r _rho_w
	
	*** Moments based on parameters:
    qui {
	    if "`options'"!="" {
			ml_p `0'
			exit
		}
		else if "`pi_s'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'  =(invlogit(xb(lpi_s)))  if `touse' 
			label var `varlist' "A priori Pi_s"
		}
		else if "`pi_r'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'  =(invlogit(xb(lpi_r)))  if `touse' 
			label var `varlist' "A priori Pi_r"
		}
		else if "`pi_w'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'  =(invlogit(xb(lpi_w)))  if `touse' 
			label var `varlist' "A priori Pi_r"
		}
		****************
	    else if "`mean_e'"!="" {
		    syntax newvarname [if] [in] [, * ]
			_predict `typlist' `varlist' if `touse', xb eq(mu_e)
			label var `varlist' "Conditional mean for component e"
		}
	    else if "`mean_n'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_n)
			label var `varlist' "Conditional mean for component n"
		}
		else if "`mean_w'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_w)
			label var `varlist' "Conditional mean for component w"
		}
	    else if "`mean_t'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_t)
			label var `varlist' "Conditional mean for component t"
		}
	   
		*** Sigmas
		else if "`sig_e'"!="" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist' =exp(xb(ln_sig_e)) if `touse'
			label var `varlist' "Conditional stdev for component e"
		}
	    else if "`sig_n'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    predictnl `typlist' `varlist' =exp(xb(ln_sig_n)) if `touse'
			label var `varlist' "Conditional stdev for component n"
		}
		else if "`sig_w'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    predictnl `typlist' `varlist' =exp(xb(ln_sig_w)) if `touse'
			label var `varlist' "Conditional stdev for component w"
		}
	    else if "`sig_t'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    predictnl `typlist' `varlist' =exp(xb(ln_sig_t)) if `touse'
			label var `varlist' "Conditional stdev for component t"
		}		
		else if "`rho_s'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'=tanh(xb(arho_s)) if `touse'
			label var `varlist' "Rho s: RTM Survey data"
		}	
		else if "`rho_w'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'=tanh(xb(arho_w)) if `touse'
			label var `varlist' "Rho w: corr(e_i,w_i)"
		}	
		***********************************************
		else if "`mean_r1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , mean_e
			label var `varlist' "Conditional mean R1"
		}
		else if "`mean_r2'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , mean_t
			label var `varlist' "Conditional mean R2"
		}
		else if "`mean_s1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , mean_e
			label var `varlist' "Conditional mean S1"
		}
		else if "`mean_s2'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_mean_e', mean_e
			ky_p double `_mean_n', mean_n
			gen `typlist' `varlist'=`_mean_e'+`_mean_n' if `touse'
			label var `varlist' "Conditional mean S2"
		}
		else if "`mean_s3'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_mean_e', mean_e
			ky_p double `_mean_n', mean_n
			ky_p double `_mean_w', mean_w
			gen `typlist' `varlist'=`_mean_e'+`_mean_n'+`_mean_w' if `touse'
			label var `varlist' "Conditional mean S3"
		}
		else if "`sig_r1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , sig_e
			label var `varlist' "Conditional sigma R1"
		}
		else if "`sig_r2'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , sig_t
			label var `varlist' "Conditional sigma R2"
		}
		else if "`sig_s1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , sig_e
			label var `varlist' "Conditional sigma S1"
		}
		else if "`sig_s2'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_sig_e', sig_e
			ky_p double `_sig_n', sig_n
			ky_p double `_rho_s', rho_s
			gen `typlist' `varlist'=(sqrt((1+`_rho_s')^2*`_sig_e'^2+`_sig_n'^2)) if `touse'
			label var `varlist' "Conditional sigma S2"
		}
		else if "`sig_s3'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_sig_e', sig_e
			ky_p double `_sig_n', sig_n
			ky_p double `_sig_w', sig_w
			ky_p double `_rho_s', rho_s
			ky_p double `_rho_w', rho_w
			gen `typlist' `varlist'=sqrt((1+`_rho_s')^2*`_sig_e'^2+`_sig_n'^2+`_sig_w'^2+2*(1+`_rho_s')*`_rho_w'*`_sig_w'*`_sig_e')	if `touse'	
			label var `varlist' "Conditional sigma S3"
		}

		***************************************
		else if "`pi_r1'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , pi_r  
			label var `varlist' "Latent Class pi r type 1"
		}
		else if "`pi_r2'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , pi_r  
			replace `varlist'=1-`varlist'  if `touse'
			label var `varlist' "Latent Class pi r type 2"
		}
		
		else if "`pi_s1'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , pi_s  
			label var `varlist' "Latent Class pi s type 1"
		}
		else if "`pi_s2'" != "" {
		    ky_p double `_pi_s'  if `touse' , pi_s  
			ky_p double `_pi_w'  if `touse' , pi_w  
			syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=((1-`_pi_s')*(1-`_pi_w')) if `touse'
			label var `varlist' "Latent Class pi s type 2"
		}
		else if "`pi_s3'" != "" {
		    ky_p double `_pi_s'  if `touse' , pi_s  
			ky_p double `_pi_w'  if `touse' , pi_w  
			syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=((1-`_pi_s')*( `_pi_w')) if `touse'
			label var `varlist' "Latent Class pi s type 3"
		}
		***************************************
        else if "`pi_1'" != "" {
			ky_p double `_pi_r', pi_r1
			ky_p double `_pi_s', pi_s1
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_1"
		}
		else if "`pi_2'" != "" {
			ky_p double `_pi_r', pi_r1
			ky_p double `_pi_s', pi_s2
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_2"
		}
		else if "`pi_3'" != "" {
			ky_p double `_pi_r', pi_r1
			ky_p double `_pi_s', pi_s3
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_3"
		}
		else if "`pi_4'" != "" {
			ky_p double `_pi_r', pi_r2
			ky_p double `_pi_s', pi_s1
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_4"
		}
		else if "`pi_5'" != "" {
			ky_p double `_pi_r', pi_r2
			ky_p double `_pi_s', pi_s2
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_5"
		}
		else if "`pi_6'" != "" {
			ky_p double `_pi_r', pi_r2
			ky_p double `_pi_s', pi_s3
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_6"
		}
		*** posterior. assuming we see only 1 thing.
		else if "`pip_r1'" != "" {
			tempvar _mean_r1 _mean_r2  _sig_r1 _sig_r2 _pi_r1
			ky_p double `_mean_r1', mean_r1
			ky_p double `_sig_r1',  sig_r1
			ky_p double `_mean_r2', mean_r2
			ky_p double `_sig_r2',  sig_r2
			ky_p double `_pi_r1',  pi_r1
			tempvar _pip_1 _pip_2
			gen double `_pip_1' =    `_pi_r1'*normalden(`_r',`_mean_r1',`_sig_r1')
			gen double `_pip_2' =(1-`_pi_r1')*normalden(`_r',`_mean_r2',`_sig_r2')
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pip_1'/(`_pip_1'+`_pip_2')  if `touse' 
			label var `varlist' "Posterior pi r type 1"
		}
		else if "`pip_r2'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist' if `touse', pip_r1
			replace `varlist'=1-`varlist'
			label var `varlist' "Posterior pi r type 2"
		}
		
		else if "`pip_s1'`pip_s2'`pip_s3'" != "" {
			tempvar _mean_s1 _mean_s2  _mean_s3 ///
				    _sig_s1 _sig_s2 _sig_s3 ///
					_pi_s1 _pi_s2
			ky_p double `_mean_s1', mean_s1
			ky_p double `_sig_s1' ,  sig_s1
			ky_p double `_mean_s2', mean_s2
			ky_p double `_sig_s2' ,  sig_s2
			ky_p double `_mean_s3', mean_s3
			ky_p double `_sig_s3' ,  sig_s3
			ky_p double `_pi_s1'  ,  pi_s1
			ky_p double `_pi_s2'  ,  pi_s2
			local _pi_s3 (1-`_pi_s1'-`_pi_s2')
			
			tempvar _pip_1 _pip_2 _pip_3
			gen double `_pip_1' =    `_pi_s1' *normalden(`_s',`_mean_s1',`_sig_s1')
			gen double `_pip_2' =    `_pi_s2' *normalden(`_s',`_mean_s2',`_sig_s2')
			gen double `_pip_3' =    `_pi_s3' *normalden(`_s',`_mean_s3',`_sig_s3')
			if "`pip_s1'"!="" {	
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_1'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi s type 1"
			}	
			else if "`pip_s2'"!="" {	
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_2'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi s type 2"
			}
			else if "`pip_s3'"!="" {	
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_3'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi s type 3"
			}
		}
		
		********************************************
 
		else if "`pip_1'" != "" {
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_l' if `touse'
			label var `varlist' "Posterior prob pi_1 Constant and equal to 1"
		}
		else if "`pip_2'`pip_3'`pip_4'`pip_5'`pip_6'" != "" {
			tempvar _mean_s1 _sig_s1 ///
			        _mean_s2 _sig_s2 ///
					_mean_s3 _sig_s3 ///
					_mean_r2 _sig_r2
			*_mean_r1 sig_r1 
			ky_p double `_mean_s1', mean_s1
			ky_p double `_sig_s1' ,  sig_s1
			ky_p double `_mean_s2', mean_s2
			ky_p double `_sig_s2' ,  sig_s2
			ky_p double `_mean_s3', mean_s3
			ky_p double `_sig_s3' ,  sig_s3
			*ky_p double `_mean_r1', mean_r1
			*ky_p double `_sig_r1' ,  sig_r1
			ky_p double `_mean_r2', mean_r2
			ky_p double `_sig_r2' ,  sig_r2
			
			ky_p double `_rho_s'  ,  rho_s
			ky_p double `_rho_w'  ,  rho_w
			* 
			ky_p double `_sig_w'  ,  sig_w
			ky_p double `_sig_e'  ,  sig_e
			
			tempvar _pi_2 _pi_3 _pi_4 _pi_5 _pi_6
			ky_p double `_pi_2'  ,  pi_2
			ky_p double `_pi_3'  ,  pi_3
			ky_p double `_pi_4'  ,  pi_4
			ky_p double `_pi_5'  ,  pi_5
			ky_p double `_pi_6'  ,  pi_6
			
			local _mean_r1 (`_mean_s1')
			local _sig_r1 (`_sig_s1')
			
			
			
			local _rho_r1s1  1
			local _rho_r1s2  (((1+`_rho_s')*`_sig_e'^2)/(`_sig_r1'*`_sig_s2'))
			local _rho_r1s3  (((1+`_rho_s')*`_sig_e'+`_rho_w'*`_sig_w')/`_sig_s3')
			local _rho_r2s1  0
			local _rho_r2s2  0
			local _rho_r2s3  0
	
			tempvar _pip2 _pip3 _pip4 _pip5 _pip6  
			local _std_r1 ((`_r'-`_mean_r1')/`_sig_r1')
			local _std_r2 ((`_r'-`_mean_r2')/`_sig_r2')
			local _std_s1 ((`_s'-`_mean_s1')/`_sig_s1')
			local _std_s2 ((`_s'-`_mean_s2')/`_sig_s2')
			local _std_s3 ((`_s'-`_mean_s3')/`_sig_s3')
			
			gen double `_pip2'=`_pi_2'*(1/(2*_pi*`_sig_r1'*`_sig_s2'*sqrt(1-`_rho_r1s2'^2))*exp(-1/(2*(1-`_rho_r1s2'^2))*(`_std_r1'^2+`_std_s2'^2-2*`_rho_r1s2'*`_std_r1'*`_std_s2')))
			gen double `_pip3'=`_pi_3'*(1/(2*_pi*`_sig_r1'*`_sig_s3'*sqrt(1-`_rho_r1s3'^2))*exp(-1/(2*(1-`_rho_r1s3'^2))*(`_std_r1'^2+`_std_s3'^2-2*`_rho_r1s3'*`_std_r1'*`_std_s3'))) 
			gen double `_pip4'=`_pi_4'*(normalden(`_r',`_mean_r2',`_sig_r2')*normalden(`_s',`_mean_s1',`_sig_s1'))
			gen double `_pip5'=`_pi_5'*(normalden(`_r',`_mean_r2',`_sig_r2')*normalden(`_s',`_mean_s2',`_sig_s2'))
			gen double `_pip6'=`_pi_6'*(normalden(`_r',`_mean_r2',`_sig_r2')*normalden(`_s',`_mean_s3',`_sig_s3'))
			
			syntax newvarname [if] [in] [, * ]
			if "`pip_2'"!="" {
				gen `typlist' `varlist'=`_pip2'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_2"
			}
			if "`pip_3'"!="" {
				gen `typlist' `varlist'=`_pip3'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_3"
			}
			if "`pip_4'"!="" {
				gen `typlist' `varlist'=`_pip4'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_4"
			}
			if "`pip_5'"!="" {
				gen `typlist' `varlist'=`_pip5'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_5"
			}
			if "`pip_6'"!="" {
				gen `typlist' `varlist'=`_pip6'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_6"
			}
		}
*************************************************************************
		else if "`bclass_s'"!="" {
			tempvar _pip_s1 _pip_s2  
			ky_p double `_pip_s1' , pip_s1
			ky_p double `_pip_s2' , pip_s2
			local _pip_s3 (1-`_pip_s1'-`_pip_s2')
			tempvar _high
			gen double `_high'=0 
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=0 
			forvalues i=1/3 {
				replace `varlist'=`i'         if `_pip_s`i''>`_high' 
				replace `_high'  =`_pip_s`i'' if `_pip_s`i''>`_high' 
			}			
			label var `varlist' "two-step classification based on S only"
		}
		else if "`bclass_r'"!="" {
			tempvar _pip_r1
			ky_p `typlist' `_pip_r1' , pip_r1
			syntax newvarname [if] [in] [, * ]
			gen  `typlist' `varlist'=1+`_pip_r1'<.5 if `touse'
		}
		
		else if "`bclass'"!="" {
			tempvar _mean_s1 _sig_s1 ///
			        _mean_s2 _sig_s2 ///
					_mean_s3 _sig_s3 ///
					_mean_r2 _sig_r2
			*_mean_r1 sig_r1 
			ky_p double `_mean_s1', mean_s1
			ky_p double `_sig_s1' ,  sig_s1
			ky_p double `_mean_s2', mean_s2
			ky_p double `_sig_s2' ,  sig_s2
			ky_p double `_mean_s3', mean_s3
			ky_p double `_sig_s3' ,  sig_s3
			*ky_p double `_mean_r1', mean_r1
			*ky_p double `_sig_r1' ,  sig_r1
			ky_p double `_mean_r2', mean_r2
			ky_p double `_sig_r2' ,  sig_r2
			
			ky_p double `_rho_s'  ,  rho_s
			ky_p double `_rho_w'  ,  rho_w
			
			ky_p double `_sig_w' , sig_w
			ky_p double `_sig_e'  ,  sig_e
			
			tempvar _pi_2 _pi_3 _pi_4 _pi_5 _pi_6
			ky_p double `_pi_2'  ,  pi_2
			ky_p double `_pi_3'  ,  pi_3
			ky_p double `_pi_4'  ,  pi_4
			ky_p double `_pi_5'  ,  pi_5
			ky_p double `_pi_6'  ,  pi_6
			
			local _mean_r1 (`_mean_s1')
			local _sig_r1 (`_sig_s1')
			
			local _rho_r1s1  1
			local _rho_r1s2  (((1+`_rho_s')*`_sig_e'^2)/(`_sig_r1'*`_sig_s2'))
			local _rho_r1s3  (((1+`_rho_s')*`_sig_e'+`_rho_w'*`_sig_w')/`_sig_s3')
			local _rho_r2s1  0
			local _rho_r2s2  0
			local _rho_r2s3  0
	
			tempvar _pip2 _pip3 _pip4 _pip5 _pip6  
			local _std_r1 ((`_r'-`_mean_r1')/`_sig_r1')
			local _std_r2 ((`_r'-`_mean_r2')/`_sig_r2')
			local _std_s1 ((`_s'-`_mean_s1')/`_sig_s1')
			local _std_s2 ((`_s'-`_mean_s2')/`_sig_s2')
			local _std_s3 ((`_s'-`_mean_s3')/`_sig_s3')
			
			gen double `_pip2'=`_pi_2'*(1/(2*_pi*`_sig_r1'*`_sig_s2'*sqrt(1-`_rho_r1s2'^2))*exp(-1/(2*(1-`_rho_r1s2'^2))*(`_std_r1'^2+`_std_s2'^2-2*`_rho_r1s2'*`_std_r1'*`_std_s2')))
			gen double `_pip3'=`_pi_3'*(1/(2*_pi*`_sig_r1'*`_sig_s3'*sqrt(1-`_rho_r1s3'^2))*exp(-1/(2*(1-`_rho_r1s3'^2))*(`_std_r1'^2+`_std_s3'^2-2*`_rho_r1s3'*`_std_r1'*`_std_s3'))) 
			gen double `_pip4'=`_pi_4'*(normalden(`_r',`_mean_r2',`_sig_r2')*normalden(`_s',`_mean_s1',`_sig_s1'))
			gen double `_pip5'=`_pi_5'*(normalden(`_r',`_mean_r2',`_sig_r2')*normalden(`_s',`_mean_s2',`_sig_s2'))
			gen double `_pip6'=`_pi_6'*(normalden(`_r',`_mean_r2',`_sig_r2')*normalden(`_s',`_mean_s3',`_sig_s3'))
			
			tempvar _pip_2 _pip_3 _pip_4 _pip_5 _pip_6
			gen double `_pip_2'=`_pip2'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
			gen double `_pip_3'=`_pip3'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
			gen double `_pip_4'=`_pip4'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
			gen double `_pip_5'=`_pip5'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
			gen double `_pip_6'=`_pip6'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6') if `touse'
			
			tempvar _high
			gen double `_high'=.
			replace `_high'=0 if `_l'==0
			syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=1 if `_l'==1
			forvalues i=2/6 {
				replace `varlist'=`i'        if `_pip_`i''>`_high' & `_l'==0
				replace `_high'  =`_pip_`i'' if `_pip_`i''>`_high' & `_l'==0
			}
		}
	}
end


program define ky_p_8 	
version 14
    syntax anything(id="newvarname") [if] [in] , [pi_s pi_r pi_w pi_v  				/// Probabilities of each event
								   rho_s  rho_r rho_w						  		/// RHO's (Regression to the mean factors)
								   mean_e mean_n mean_w mean_t mean_v 				/// Conditional Means
								   sig_e  sig_n  sig_w  sig_t  sig_v 	        	/// conditional Standard deviations
								   mean_r1 mean_r2 mean_r3 mean_s1 mean_s2 mean_s3  /// mean by group
								   sig_r1  sig_r2  sig_r3  sig_s1  sig_s2  sig_s3   /// sigma by group
								   pi_r1  pi_r2  pi_r3  pi_s1  pi_s2  pi_s3  		/// Probabilities by category
								   pip_r1 pip_r2 pip_r3 pip_s1 pip_s2 pip_s3  		/// Probabilities by category. Posterior Prob
								   pi_1 pi_2 pi_3 pi_4 pi_5 pi_6 pi_7 pi_8 pi_9 	/// Probabilities by group classification
								   pip_1 pip_2 pip_3 pip_4 pip_5 pip_6 pip_7 pip_8 pip_9 /// Probabilities by group classification
								   bclass_r bclass_s bclass	* ]
	marksample touse, novarlist
 	*** getting dep variables
	tokenize "`e(depvar)'"
	local _r `1'
	local _s `2'
	local _l `3'
	*** NOW ALL cases
	*** defining all elements:
	*** Creating this variables first may make this program more efficient.
	tempvar _pi_s   _pi_r   _pi_w   _pi_v   
	tempvar _mean_e _mean_n _mean_t _mean_w _mean_v 
	tempvar _sig_e  _sig_n  _sig_t  _sig_w  _sig_v 
	tempvar _rho_s _rho_r _rho_w
***************************************************************
	qui {
	    if "`options'"!="" {
			ml_p `0'
			exit
		}
		else if "`pi_s'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'  =(invlogit(xb(lpi_s)))  if `touse' 
			label var `varlist' "A priori Pi_s"
		}
		else if "`pi_r'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'  =(invlogit(xb(lpi_r)))  if `touse' 
			label var `varlist' "A priori Pi_r"
		}
		else if "`pi_w'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'  =(invlogit(xb(lpi_w)))  if `touse' 
			label var `varlist' "A priori Pi_r"
		}
		else if "`pi_v'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'  =(invlogit(xb(lpi_v)))  if `touse' 
			label var `varlist' "A priori Pi_v"
		}
		****************
	    else if "`mean_e'"!="" {
		    syntax newvarname [if] [in] [, * ]
			_predict `typlist' `varlist' if `touse', xb eq(mu_e)
			label var `varlist' "Conditional mean for component e"
		}
	    else if "`mean_n'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_n)
			label var `varlist' "Conditional mean for component n"
		}
		else if "`mean_w'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_w)
			label var `varlist' "Conditional mean for component w"
		}
	    else if "`mean_t'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_t)
			label var `varlist' "Conditional mean for component t"
		}
		else if "`mean_v'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_v)
			label var `varlist' "Conditional mean for component v"
		}
	   
		*** Sigmas
		else if "`sig_e'"!="" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist' =exp(xb(ln_sig_e)) if `touse'
			label var `varlist' "Conditional stdev for component e"
		}
	    else if "`sig_n'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    predictnl `typlist' `varlist' =exp(xb(ln_sig_n)) if `touse'
			label var `varlist' "Conditional stdev for component n"
		}
		else if "`sig_w'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    predictnl `typlist' `varlist' =exp(xb(ln_sig_w)) if `touse'
			label var `varlist' "Conditional stdev for component w"
		}
	    else if "`sig_t'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    predictnl `typlist' `varlist' =exp(xb(ln_sig_t)) if `touse'
			label var `varlist' "Conditional stdev for component t"
		}
		else if "`sig_v'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    predictnl `typlist' `varlist' =exp(xb(ln_sig_v)) if `touse'
			label var `varlist' "Conditional stdev for component v"
		}
		else if "`rho_r'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'=tanh(xb(arho_r)) if `touse'
			label var `varlist' "Rho r: RTM Admin data"
		}
		else if "`rho_s'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'=tanh(xb(arho_s)) if `touse'
			label var `varlist' "Rho s: RTM Survey data"
		}
		else if "`rho_w'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'=tanh(xb(arho_w)) if `touse'
			label var `varlist' "Rho w: corr(e_i,w_i)"
		}
		***********************************************
		else if "`mean_r1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , mean_e
			label var `varlist' "Conditional mean R1"
		}
		else if "`mean_r2'"!="" {
			ky_p double `_mean_e', mean_e
			ky_p double `_mean_v', mean_v
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_mean_e'+`_mean_v' if `touse'
			label var `varlist' "Conditional mean R2"
		}
		else if "`mean_r3'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , mean_t
			label var `varlist' "Conditional mean R3"
		}
		else if "`mean_s1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , mean_e
			label var `varlist' "Conditional mean S1"
		}
		else if "`mean_s2'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_mean_e', mean_e
			ky_p double `_mean_n', mean_n
			gen `typlist' `varlist'=`_mean_e'+`_mean_n' if `touse'
			label var `varlist' "Conditional mean S2"
		}
		else if "`mean_s3'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_mean_e', mean_e
			ky_p double `_mean_n', mean_n
			ky_p double `_mean_w', mean_w
			gen `typlist' `varlist'=`_mean_e'+`_mean_n'+`_mean_w' if `touse'
			label var `varlist' "Conditional mean S3"
		}
		else if "`sig_r1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , sig_e
			label var `varlist' "Conditional mean R1"
		}
		else if "`sig_r2'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_sig_e', sig_e
			ky_p double `_sig_v', sig_v
			ky_p double `_rho_r', rho_r
			gen `typlist' `varlist'=(sqrt((1+`_rho_r')^2*`_sig_e'^2+`_sig_v'^2)) if `touse'
			label var `varlist' "Conditional sigma R2"
		}
		else if "`sig_r3'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , sig_t
			label var `varlist' "Conditional sigma R3"
		}
		else if "`sig_s1'"!="" {
 		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , sig_e
			label var `varlist' "Conditional sigma S1"
		}
		else if "`sig_s2'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_sig_e', sig_e
			ky_p double `_sig_n', sig_n
			ky_p double `_rho_s', rho_s
			gen `typlist' `varlist'=(sqrt((1+`_rho_s')^2*`_sig_e'^2+`_sig_n'^2)) if `touse'
			label var `varlist' "Conditional sigma S2"
		}
		else if "`sig_s3'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_sig_e', sig_e
			ky_p double `_sig_n', sig_n
			ky_p double `_sig_w', sig_w
			ky_p double `_rho_s', rho_s
			ky_p double `_rho_w', rho_w
			gen `typlist' `varlist'=sqrt((1+`_rho_s')^2*`_sig_e'^2+`_sig_n'^2+`_sig_w'^2+2*(1+`_rho_s')*`_rho_w'*`_sig_w'*`_sig_e')	if `touse'	
			label var `varlist' "Conditional sigma S3"
		}
		***************************************
		else if "`pi_r1'" != "" {
			ky_p double `_pi_r'  if `touse' , pi_r  
			ky_p double `_pi_v'  if `touse' , pi_v 
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=(( `_pi_r')*(  `_pi_v')) if `touse'
			label var `varlist' "Latent Class pi r type 1"
		}
		else if "`pi_r2'" != "" {
			ky_p double `_pi_r'  if `touse' , pi_r  
			ky_p double `_pi_v'  if `touse' , pi_v 
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=(( `_pi_r')*(1-`_pi_v')) if `touse'
			label var `varlist' "Latent Class pi r type 2"
		}
		else if "`pi_r3'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , pi_r  
			replace `varlist'=1-`varlist'  if `touse'
			label var `varlist' "Latent Class pi r type 3"
		}
		else if "`pi_s1'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , pi_s  
			label var `varlist' "Latent Class pi s type 1"
		}
		else if "`pi_s2'" != "" {
		    ky_p double `_pi_s'  if `touse' , pi_s  
			ky_p double `_pi_w'  if `touse' , pi_w  
			syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=((1-`_pi_s')*(1-`_pi_w')) if `touse'
			label var `varlist' "Latent Class pi s type 2"
		}
		else if "`pi_s3'" != "" {
		    ky_p double `_pi_s'  if `touse' , pi_s  
			ky_p double `_pi_w'  if `touse' , pi_w  
			syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=((1-`_pi_s')*( `_pi_w')) if `touse'
			label var `varlist' "Latent Class pi s type 3"
		}
		***************************************
        else if "`pi_1'" != "" {
			ky_p double `_pi_r', pi_r1
			ky_p double `_pi_s', pi_s1
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_1"
		}
		else if "`pi_2'" != "" {
			ky_p double `_pi_r', pi_r1
			ky_p double `_pi_s', pi_s2
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_2"
		}
		else if "`pi_3'" != "" {
			ky_p double `_pi_r', pi_r1
			ky_p double `_pi_s', pi_s3
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_3"
		}
		else if "`pi_4'" != "" {
			ky_p double `_pi_r', pi_r2
			ky_p double `_pi_s', pi_s1
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_4"
		}
		else if "`pi_5'" != "" {
			ky_p double `_pi_r', pi_r2
			ky_p double `_pi_s', pi_s2
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_5"
		}
		else if "`pi_6'" != "" {
			ky_p double `_pi_r', pi_r2
			ky_p double `_pi_s', pi_s3
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_6"
		}
		else if "`pi_7'" != "" {
			ky_p double `_pi_r', pi_r3
			ky_p double `_pi_s', pi_s1
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_7"
		}
		else if "`pi_8'" != "" {
			ky_p double `_pi_r', pi_r3
			ky_p double `_pi_s', pi_s2
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_8"
		}
		else if "`pi_9'" != "" {
			ky_p double `_pi_r', pi_r3
			ky_p double `_pi_s', pi_s3
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_9"
		}
		*** posterior. assuming we see only 1 thing.
		else if "`pip_r1'`pip_r2'`pip_r3'" != "" {
			tempvar _mean_r1 _mean_r2  _mean_r3 ///
				    _sig_r1 _sig_r2 _sig_r3 ///
					_pi_r1 _pi_r2
			ky_p double `_mean_r1', mean_r1
			ky_p double `_sig_r1' ,  sig_r1
			ky_p double `_mean_r2', mean_r2
			ky_p double `_sig_r2' ,  sig_r2
			ky_p double `_mean_r3', mean_r3
			ky_p double `_sig_r3' ,  sig_r3			
			ky_p double `_pi_r1'  ,  pi_r1
			ky_p double `_pi_r2'  ,  pi_r2
			local _pi_r3 (1-`_pi_r1'-`_pi_r2')
			
			tempvar _pip_1 _pip_2 _pip_3
			gen double `_pip_1' =    `_pi_r1' *normalden(`_r',`_mean_r1',`_sig_r1')
			gen double `_pip_2' =    `_pi_r2' *normalden(`_r',`_mean_r2',`_sig_r2')
			gen double `_pip_3' =    `_pi_r3' *normalden(`_r',`_mean_r3',`_sig_r3')
			if "`pip_r1'"!=""	{
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_1'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi r type 1"
			}
			else if "`pip_r2'"!=""	{
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_2'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi r type 2"
			}
			else if "`pip_r3'"!=""	{
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_3'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi r type 3"
			}
		}
		else if "`pip_s1'`pip_s2'`pip_s3'" != "" {
			tempvar _mean_s1 _mean_s2  _mean_s3 ///
				    _sig_s1 _sig_s2 _sig_s3 ///
					_pi_s1 _pi_s2
			ky_p double `_mean_s1', mean_s1
			ky_p double `_sig_s1' ,  sig_s1
			ky_p double `_mean_s2', mean_s2
			ky_p double `_sig_s2' ,  sig_s2
			ky_p double `_mean_s3', mean_s3
			ky_p double `_sig_s3' ,  sig_s3			
			ky_p double `_pi_s1'  ,  pi_s1
			ky_p double `_pi_s2'  ,  pi_s2
			local _pi_s3 (1-`_pi_s1'-`_pi_s2')
			
			tempvar _pip_1 _pip_2 _pip_3
			gen double `_pip_1' =    `_pi_s1' *normalden(`_s',`_mean_s1',`_sig_s1')
			gen double `_pip_2' =    `_pi_s2' *normalden(`_s',`_mean_s2',`_sig_s2')
			gen double `_pip_3' =    `_pi_s3' *normalden(`_s',`_mean_s3',`_sig_s3')
			if "`pip_s1'" != "" {
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_1'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi s type 1"
			}	
			else if "`pip_s2'" != "" {
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_2'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi s type 2"
			}
			else if "`pip_s3'" != "" {
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_3'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi s type 3"
			}
		}
		********************************************
		else if "`pip_1'" != "" {
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_l' if `touse'
			label var `varlist' "Posterior prob pi_1 Constant and equal to 1"
		}
		else if "`pip_2'`pip_3'`pip_4'`pip_5'`pip_6'`pip_7'`pip_8'`pip_9'" != "" {
			tempvar _mean_s1 _sig_s1 ///
			        _mean_s2 _sig_s2 ///
					_mean_s3 _sig_s3 ///
					_mean_r2 _sig_r2 ///
					_mean_r3 _sig_r3
			*_mean_r1 sig_r1 
			ky_p double `_mean_s1', mean_s1
			ky_p double `_sig_s1' ,  sig_s1
			ky_p double `_mean_s2', mean_s2
			ky_p double `_sig_s2' ,  sig_s2
			ky_p double `_mean_s3', mean_s3
			ky_p double `_sig_s3' ,  sig_s3
			*ky_p double `_mean_r1', mean_r1
			*ky_p double `_sig_r1' ,  sig_r1
			ky_p double `_mean_r2', mean_r2
			ky_p double `_sig_r2' ,  sig_r2
			ky_p double `_mean_r3', mean_r3
			ky_p double `_sig_r3' ,  sig_r3
			
			ky_p double `_rho_s'  ,  rho_s
			ky_p double `_rho_r'  ,  rho_r
			ky_p double `_rho_w'  ,  rho_w
			
			ky_p double `_sig_e'  ,  sig_e
			ky_p double `_sig_w'  ,  sig_w
			
			tempvar _pi_2 _pi_3 _pi_4 _pi_5 _pi_6 _pi_7 _pi_8 _pi_9
			ky_p double `_pi_2'  ,  pi_2
			ky_p double `_pi_3'  ,  pi_3
			ky_p double `_pi_4'  ,  pi_4
			ky_p double `_pi_5'  ,  pi_5
			ky_p double `_pi_6'  ,  pi_6
			ky_p double `_pi_7'  ,  pi_7
			ky_p double `_pi_8'  ,  pi_8
			ky_p double `_pi_9'  ,  pi_9
			
			local _mean_r1 (`_mean_s1')
			local _sig_r1  (`_sig_s1')
			tempvar _rho_r1s2 _rho_r1s3 _rho_r2s1 _rho_r2s2 _rho_r2s3
			local _rho_r1s1  1
			gen double `_rho_r1s2' = (((1+`_rho_s')*             `_sig_e'^2)/(`_sig_r1'*`_sig_s2'))
			gen double `_rho_r1s3' = (((1+`_rho_s')*             `_sig_e'^2+`_rho_w'*`_sig_e'*`_sig_w')/(`_sig_r1'*`_sig_s3'))
			gen double `_rho_r2s1' = ((             (1+`_rho_r')*`_sig_e'^2)/(`_sig_r2'*`_sig_s1'))
			gen double `_rho_r2s2' = (((1+`_rho_s')*(1+`_rho_r')*`_sig_e'^2)/(`_sig_r2'*`_sig_s2'))
			gen double `_rho_r2s3' = (((1+`_rho_s')*(1+`_rho_r')*`_sig_e'^2+`_rho_w'*(1+`_rho_r')*`_sig_e'*`_sig_w')/(`_sig_r2'*`_sig_s3'))
			local _rho_r3s1  0
			local _rho_r3s2  0
			local _rho_r3s3  0
	
			tempvar _pip2 _pip3 _pip4 _pip5 _pip6 _pip7 _pip8 _pip9
			local _std_r1 ((`_r'-`_mean_r1')/`_sig_r1')
			local _std_r2 ((`_r'-`_mean_r2')/`_sig_r2')
			local _std_r3 ((`_r'-`_mean_r3')/`_sig_r3')
			local _std_s1 ((`_s'-`_mean_s1')/`_sig_s1')
			local _std_s2 ((`_s'-`_mean_s2')/`_sig_s2')
			local _std_s3 ((`_s'-`_mean_s3')/`_sig_s3')
			
			gen double `_pip2'=`_pi_2'*(1/(2*_pi*`_sig_r1'*`_sig_s2'*sqrt(1-`_rho_r1s2'^2))*exp(-1/(2*(1-`_rho_r1s2'^2))*(`_std_r1'^2+`_std_s2'^2-2*`_rho_r1s2'*`_std_r1'*`_std_s2')))
			gen double `_pip3'=`_pi_3'*(1/(2*_pi*`_sig_r1'*`_sig_s3'*sqrt(1-`_rho_r1s3'^2))*exp(-1/(2*(1-`_rho_r1s3'^2))*(`_std_r1'^2+`_std_s3'^2-2*`_rho_r1s3'*`_std_r1'*`_std_s3'))) 
			gen double `_pip4'=`_pi_4'*(1/(2*_pi*`_sig_r2'*`_sig_s1'*sqrt(1-`_rho_r2s1'^2))*exp(-1/(2*(1-`_rho_r2s1'^2))*(`_std_r2'^2+`_std_s1'^2-2*`_rho_r2s1'*`_std_r2'*`_std_s1'))) 
			gen double `_pip5'=`_pi_5'*(1/(2*_pi*`_sig_r2'*`_sig_s2'*sqrt(1-`_rho_r2s2'^2))*exp(-1/(2*(1-`_rho_r2s2'^2))*(`_std_r2'^2+`_std_s2'^2-2*`_rho_r2s2'*`_std_r2'*`_std_s2'))) 
			gen double `_pip6'=`_pi_6'*(1/(2*_pi*`_sig_r2'*`_sig_s3'*sqrt(1-`_rho_r2s3'^2))*exp(-1/(2*(1-`_rho_r2s3'^2))*(`_std_r2'^2+`_std_s3'^2-2*`_rho_r2s3'*`_std_r2'*`_std_s3'))) 
			gen double `_pip7'=`_pi_7'*(normalden(`_r',`_mean_r3',`_sig_r3')*normalden(`_s',`_mean_s1',`_sig_s1'))
			gen double `_pip8'=`_pi_8'*(normalden(`_r',`_mean_r3',`_sig_r3')*normalden(`_s',`_mean_s2',`_sig_s2'))
			gen double `_pip9'=`_pi_9'*(normalden(`_r',`_mean_r3',`_sig_r3')*normalden(`_s',`_mean_s3',`_sig_s3'))
			
			syntax newvarname [if] [in] [, * ]
			if "`pip_2'"!="" {
				gen `typlist' `varlist'=`_pip2'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_2"
			}
			if "`pip_3'"!="" {
				gen `typlist' `varlist'=`_pip3'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_3"
			}
			if "`pip_4'"!="" {
				gen `typlist' `varlist'=`_pip4'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_4"
			}
			if "`pip_5'"!="" {
				gen `typlist' `varlist'=`_pip5'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_5"
			}
			if "`pip_6'"!="" {
				gen `typlist' `varlist'=`_pip6'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_6"
			}
			if "`pip_7'"!="" {
				gen `typlist' `varlist'=`_pip7'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_7"
			}
			if "`pip_8'"!="" {
				gen `typlist' `varlist'=`_pip8'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_8"
			}
			if "`pip_9'"!="" {
				gen `typlist' `varlist'=`_pip9'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_9"
			}			
		}
*************************************************************************
		else if "`bclass_s'"!="" {
			tempvar _pip_s1 _pip_s2  
			ky_p double `_pip_s1' , pip_s1
			ky_p double `_pip_s2' , pip_s2
			local _pip_s3 (1-`_pip_s1'-`_pip_s2')
			tempvar _high
			gen double `_high'=0 
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=0 
			forvalues i=1/3 {
				replace `varlist'=`i'         if `_pip_s`i''>`_high' 
				replace `_high'  =`_pip_s`i'' if `_pip_s`i''>`_high' 
			}			
			label var `varlist' "two-step classification based on S only"
		}
		else if "`bclass_r'"!="" {
			tempvar _pip_r1 _pip_r2  
			ky_p double `_pip_r1' , pip_r1
			ky_p double `_pip_r2' , pip_r2
			local _pip_r3 (1-`_pip_r1'-`_pip_r2')
			tempvar _high
			gen double `_high'=0 
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=0 
			forvalues i=1/3 {
				replace `varlist'=`i'         if `_pip_r`i''>`_high' 
				replace `_high'  =`_pip_r`i'' if `_pip_r`i''>`_high' 
			}			
			label var `varlist' "two-step classification based on R only"
		}
		
		else if "`bclass'"!="" {
			tempvar _mean_s1 _sig_s1 ///
			        _mean_s2 _sig_s2 ///
					_mean_s3 _sig_s3 ///
					_mean_r2 _sig_r2 ///
					_mean_r3 _sig_r3
			*_mean_r1 sig_r1 
			ky_p double `_mean_s1', mean_s1
			ky_p double `_sig_s1' ,  sig_s1
			ky_p double `_mean_s2', mean_s2
			ky_p double `_sig_s2' ,  sig_s2
			ky_p double `_mean_s3', mean_s3
			ky_p double `_sig_s3' ,  sig_s3
			*ky_p double `_mean_r1', mean_r1
			*ky_p double `_sig_r1' ,  sig_r1
			ky_p double `_mean_r2', mean_r2
			ky_p double `_sig_r2' ,  sig_r2
			ky_p double `_mean_r3', mean_r3
			ky_p double `_sig_r3' ,  sig_r3
			
			ky_p double `_rho_s'  ,  rho_s
			ky_p double `_rho_r'  ,  rho_r
			ky_p double `_rho_w'  ,  rho_w
			
			ky_p double `_sig_e'  , sig_e
			ky_p double `_sig_w'  , sig_w
			
			tempvar _pi_2 _pi_3 _pi_4 _pi_5 _pi_6 _pi_7 _pi_8 _pi_9
			ky_p double `_pi_2'  ,  pi_2
			ky_p double `_pi_3'  ,  pi_3
			ky_p double `_pi_4'  ,  pi_4
			ky_p double `_pi_5'  ,  pi_5
			ky_p double `_pi_6'  ,  pi_6
			ky_p double `_pi_7'  ,  pi_7
			ky_p double `_pi_8'  ,  pi_8
			ky_p double `_pi_9'  ,  pi_9
			
			local _mean_r1 (`_mean_s1')
			local _sig_r1 (`_sig_s1')
			
			tempvar _rho_r1s2 _rho_r1s3 _rho_r2s1 _rho_r2s2 _rho_r2s3
			local _rho_r1s1  1
			gen double `_rho_r1s2' = (((1+`_rho_s')*             `_sig_e'^2)/(`_sig_r1'*`_sig_s2'))
			gen double `_rho_r1s3' = (((1+`_rho_s')*             `_sig_e'^2+`_rho_w'*`_sig_e'*`_sig_w')/(`_sig_r1'*`_sig_s3'))
			gen double `_rho_r2s1' = ((             (1+`_rho_r')*`_sig_e'^2)/(`_sig_r2'*`_sig_s1'))
			gen double `_rho_r2s2' = (((1+`_rho_s')*(1+`_rho_r')*`_sig_e'^2)/(`_sig_r2'*`_sig_s2'))
			gen double `_rho_r2s3' = (((1+`_rho_s')*(1+`_rho_r')*`_sig_e'^2+`_rho_w'*(1+`_rho_r')*`_sig_e'*`_sig_w')/(`_sig_r2'*`_sig_s3'))
			local _rho_r3s1  0
			local _rho_r3s2  0
			local _rho_r3s3  0
	
			tempvar _pip2 _pip3 _pip4 _pip5 _pip6 _pip7 _pip8 _pip9
			local _std_r1 ((`_r'-`_mean_r1')/`_sig_r1')
			local _std_r2 ((`_r'-`_mean_r2')/`_sig_r2')
			local _std_r3 ((`_r'-`_mean_r3')/`_sig_r3')
			local _std_s1 ((`_s'-`_mean_s1')/`_sig_s1')
			local _std_s2 ((`_s'-`_mean_s2')/`_sig_s2')
			local _std_s3 ((`_s'-`_mean_s3')/`_sig_s3')
			
			gen double `_pip2'=`_pi_2'*(1/(2*_pi*`_sig_r1'*`_sig_s2'*sqrt(1-`_rho_r1s2'^2))*exp(-1/(2*(1-`_rho_r1s2'^2))*(`_std_r1'^2+`_std_s2'^2-2*`_rho_r1s2'*`_std_r1'*`_std_s2')))
			gen double `_pip3'=`_pi_3'*(1/(2*_pi*`_sig_r1'*`_sig_s3'*sqrt(1-`_rho_r1s3'^2))*exp(-1/(2*(1-`_rho_r1s3'^2))*(`_std_r1'^2+`_std_s3'^2-2*`_rho_r1s3'*`_std_r1'*`_std_s3'))) 
			gen double `_pip4'=`_pi_4'*(1/(2*_pi*`_sig_r2'*`_sig_s1'*sqrt(1-`_rho_r2s1'^2))*exp(-1/(2*(1-`_rho_r2s1'^2))*(`_std_r2'^2+`_std_s1'^2-2*`_rho_r2s1'*`_std_r2'*`_std_s1'))) 
			gen double `_pip5'=`_pi_5'*(1/(2*_pi*`_sig_r2'*`_sig_s2'*sqrt(1-`_rho_r2s2'^2))*exp(-1/(2*(1-`_rho_r2s2'^2))*(`_std_r2'^2+`_std_s2'^2-2*`_rho_r2s2'*`_std_r2'*`_std_s2'))) 
			gen double `_pip6'=`_pi_6'*(1/(2*_pi*`_sig_r2'*`_sig_s3'*sqrt(1-`_rho_r2s3'^2))*exp(-1/(2*(1-`_rho_r2s3'^2))*(`_std_r2'^2+`_std_s3'^2-2*`_rho_r2s3'*`_std_r2'*`_std_s3'))) 
			gen double `_pip7'=`_pi_7'*(normalden(`_r',`_mean_r3',`_sig_r3')*normalden(`_s',`_mean_s1',`_sig_s1'))
			gen double `_pip8'=`_pi_8'*(normalden(`_r',`_mean_r3',`_sig_r3')*normalden(`_s',`_mean_s2',`_sig_s2'))
			gen double `_pip9'=`_pi_9'*(normalden(`_r',`_mean_r3',`_sig_r3')*normalden(`_s',`_mean_s3',`_sig_s3'))
			
			tempvar _pip_2 _pip_3 _pip_4 _pip_5 _pip_6 _pip_7 _pip_8 _pip_9
			gen double `_pip_2'=`_pip2'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
			gen double `_pip_3'=`_pip3'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
			gen double `_pip_4'=`_pip4'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
			gen double `_pip_5'=`_pip5'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
			gen double `_pip_6'=`_pip6'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
			gen double `_pip_7'=`_pip7'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
			gen double `_pip_8'=`_pip8'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
			gen double `_pip_9'=`_pip9'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'+`_pip7'+`_pip8'+`_pip9') if `touse'
			
			tempvar _high
			gen double `_high'=.
			replace `_high'=0 if `_l'==0
			syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=1 if `_l'==1
			forvalues i=2/9 {
				replace `varlist'=`i'        if `_pip_`i''>`_high' & `_l'==0
				replace `_high'  =`_pip_`i'' if `_pip_`i''>`_high' & `_l'==0
			}
		}
	}
    
end

program define ky_p_9 	
version 14
    syntax anything(id="newvarname") [if] [in] , [pi_s   pi_w pi_v  				/// Probabilities of each event
								   rho_s  rho_r 							  		/// RHO's (Regression to the mean factors)
								   mean_e mean_n mean_w mean_t mean_v 				/// Conditional Means
								   sig_e  sig_n  sig_w  sig_t  sig_v 	        	/// conditional Standard deviations
								   mean_r1 mean_r2 mean_s1 mean_s2 mean_s3  /// mean by group
								   sig_r1  sig_r2  sig_s1  sig_s2  sig_s3   /// sigma by group
								   pi_r1  pi_r2  pi_s1  pi_s2  pi_s3  		/// Probabilities by category
								   pip_r1 pip_r2 pip_s1 pip_s2 pip_s3  		/// Probabilities by category. Posterior Prob
								   pi_1 pi_2 pi_3 pi_4 pi_5 pi_6 			/// Probabilities by group classification
								   pip_1 pip_2 pip_3 pip_4 pip_5 pip_6 		/// Probabilities by group classification
								   bclass_r bclass_s bclass	* ]
								   
    marksample touse, novarlist
 	*** getting dep variables
	tokenize "`e(depvar)'"
	local _r `1'
	local _s `2'
	local _l `3'
	*** NOW ALL cases
	*** defining all elements:
	*** Creating this variables first may make this program more efficient.
	tempvar _pi_s   _pi_r   _pi_w   _pi_v   
	tempvar _mean_e _mean_n _mean_t _mean_w _mean_v 
	tempvar _sig_e  _sig_n  _sig_t  _sig_w  _sig_v 
	tempvar _rho_s _rho_r
***************************************************************
	qui {
	    if "`options'"!="" {
			ml_p `0'
			exit
		}
		else if "`pi_s'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'  =(invlogit(xb(lpi_s)))  if `touse' 
			label var `varlist' "A priori Pi_s"
		}
		else if "`pi_w'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'  =(invlogit(xb(lpi_w)))  if `touse' 
			label var `varlist' "A priori Pi_r"
		}
		else if "`pi_v'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'  =(invlogit(xb(lpi_v)))  if `touse' 
			label var `varlist' "A priori Pi_v"
		}
		****************
	    else if "`mean_e'"!="" {
		    syntax newvarname [if] [in] [, * ]
			_predict `typlist' `varlist' if `touse', xb eq(mu_e)
			label var `varlist' "Conditional mean for component e"
		}
	    else if "`mean_n'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_n)
			label var `varlist' "Conditional mean for component n"
		}
		else if "`mean_w'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_w)
			label var `varlist' "Conditional mean for component w"
		}
		else if "`mean_v'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    _predict `typlist' `varlist' if `touse', xb eq(mu_v)
			label var `varlist' "Conditional mean for component v"
		}
	   
		*** Sigmas
		else if "`sig_e'"!="" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist' =exp(xb(ln_sig_e)) if `touse'
			label var `varlist' "Conditional stdev for component e"
		}
	    else if "`sig_n'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    predictnl `typlist' `varlist' =exp(xb(ln_sig_n)) if `touse'
			label var `varlist' "Conditional stdev for component n"
		}
		else if "`sig_w'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    predictnl `typlist' `varlist' =exp(xb(ln_sig_w)) if `touse'
			label var `varlist' "Conditional stdev for component w"
		}
		else if "`sig_v'"!="" {
		    syntax newvarname [if] [in] [, * ]
		    predictnl `typlist' `varlist' =exp(xb(ln_sig_v)) if `touse'
			label var `varlist' "Conditional stdev for component v"
		}
		else if "`rho_r'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'=tanh(xb(arho_r)) if `touse'
			label var `varlist' "Rho r: RTM Admin data"
		}
		else if "`rho_s'" != "" {
		    syntax newvarname [if] [in] [, * ]
			predictnl `typlist' `varlist'=tanh(xb(arho_s)) if `touse'
			label var `varlist' "Rho s: RTM Survey data"
		}
		***********************************************
		else if "`mean_r1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , mean_e
			label var `varlist' "Conditional mean R1"
		}
		else if "`mean_r2'"!="" {
			ky_p double `_mean_e', mean_e
			ky_p double `_mean_v', mean_v
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_mean_e'+`_mean_v' if `touse'
			label var `varlist' "Conditional mean R2"
		}
		else if "`mean_s1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , mean_e
			label var `varlist' "Conditional mean S1"
		}
		else if "`mean_s2'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_mean_e', mean_e
			ky_p double `_mean_n', mean_n
			gen `typlist' `varlist'=`_mean_e'+`_mean_n' if `touse'
			label var `varlist' "Conditional mean S2"
		}
		else if "`mean_s3'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_mean_e', mean_e
			ky_p double `_mean_n', mean_n
			ky_p double `_mean_w', mean_w
			gen `typlist' `varlist'=`_mean_e'+`_mean_n'+`_mean_w' if `touse'
			label var `varlist' "Conditional mean S3"
		}
		else if "`sig_r1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , sig_e
			label var `varlist' "Conditional sigma R1"
		}
		else if "`sig_r2'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_sig_e', sig_e
			ky_p double `_sig_v', sig_v
			ky_p double `_rho_r', rho_r
			gen `typlist' `varlist'=(sqrt((1+`_rho_r')^2*`_sig_e'^2+`_sig_v'^2)) if `touse'
			label var `varlist' "Conditional sigma R2"
		}
		else if "`sig_s1'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , sig_e
			label var `varlist' "Conditional sigma S1"
		}
		else if "`sig_s2'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_sig_e', sig_e
			ky_p double `_sig_n', sig_n
			ky_p double `_rho_s', rho_s
			gen `typlist' `varlist'=(sqrt((1+`_rho_s')^2*`_sig_e'^2+`_sig_n'^2)) if `touse'
			label var `varlist' "Conditional sigma S2"
		}
		else if "`sig_s3'"!="" {
		    syntax newvarname [if] [in] [, * ]
			ky_p double `_sig_e', sig_e
			ky_p double `_sig_n', sig_n
			ky_p double `_sig_w', sig_w
			ky_p double `_rho_s', rho_s
			gen `typlist' `varlist'=(sqrt((1+`_rho_s')^2*`_sig_e'^2+`_sig_n'^2+`_sig_w'^2)) if `touse'
			label var `varlist' "Conditional sigma S3"
		}
		***************************************
		else if "`pi_r1'" != "" {
			*ky_p double `_pi_r'  if `touse' , pi_r  
			ky_p double `_pi_v'  if `touse' , pi_v 
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=((  `_pi_v')) if `touse'
			label var `varlist' "Latent Class pi r type 1"
		}
		else if "`pi_r2'" != "" {
			*ky_p double `_pi_r'  if `touse' , pi_r  
			ky_p double `_pi_v'  if `touse' , pi_v 
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=((1-`_pi_v')) if `touse'
			label var `varlist' "Latent Class pi r type 2"
		}
		
		else if "`pi_s1'" != "" {
		    syntax newvarname [if] [in] [, * ]
			ky_p `typlist' `varlist'  if `touse' , pi_s  
			label var `varlist' "Latent Class pi s type 1"
		}
		else if "`pi_s2'" != "" {
		    ky_p double `_pi_s'  if `touse' , pi_s  
			ky_p double `_pi_w'  if `touse' , pi_w  
			syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=((1-`_pi_s')*(1-`_pi_w')) if `touse'
			label var `varlist' "Latent Class pi s type 2"
		}
		else if "`pi_s3'" != "" {
		    ky_p double `_pi_s'  if `touse' , pi_s  
			ky_p double `_pi_w'  if `touse' , pi_w  
			syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=((1-`_pi_s')*( `_pi_w')) if `touse'
			label var `varlist' "Latent Class pi s type 3"
		}
		***************************************
        else if "`pi_1'" != "" {
			ky_p double `_pi_r', pi_r1
			ky_p double `_pi_s', pi_s1
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_1"
		}
		else if "`pi_2'" != "" {
			ky_p double `_pi_r', pi_r1
			ky_p double `_pi_s', pi_s2
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_2"
		}
		else if "`pi_3'" != "" {
			ky_p double `_pi_r', pi_r1
			ky_p double `_pi_s', pi_s3
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_3"
		}
		else if "`pi_4'" != "" {
			ky_p double `_pi_r', pi_r2
			ky_p double `_pi_s', pi_s1
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_4"
		}
		else if "`pi_5'" != "" {
			ky_p double `_pi_r', pi_r2
			ky_p double `_pi_s', pi_s2
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_5"
		}
		else if "`pi_6'" != "" {
			ky_p double `_pi_r', pi_r2
			ky_p double `_pi_s', pi_s3
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_pi_r'*`_pi_s'  if `touse'
			label var `varlist' "Latent Class pi_6"
		}
		*** posterior. assuming we see only 1 thing.
		else if "`pip_r1'`pip_r2'" != "" {
			tempvar _mean_r1 _mean_r2  ///
				    _sig_r1 _sig_r2 ///
					_pi_r1 _pi_r2
			ky_p double `_mean_r1', mean_r1
			ky_p double `_sig_r1' ,  sig_r1
			ky_p double `_mean_r2', mean_r2
			ky_p double `_sig_r2' ,  sig_r2
			ky_p double `_pi_r1'  ,  pi_r1
			ky_p double `_pi_r2'  ,  pi_r2
			
			tempvar _pip_1 _pip_2 _pip_3
			gen double `_pip_1' =    `_pi_r1' *normalden(`_r',`_mean_r1',`_sig_r1')
			gen double `_pip_2' =    `_pi_r2' *normalden(`_r',`_mean_r2',`_sig_r2')

			if "`pip_r1'"!=""	{
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_1'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi r type 1"
			}
			else if "`pip_r2'"!=""	{
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_2'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi r type 2"
			}
		}
		else if "`pip_s1'`pip_s2'`pip_s3'" != "" {
			tempvar _mean_s1 _mean_s2  _mean_s3 ///
				    _sig_s1 _sig_s2 _sig_s3 ///
					_pi_s1 _pi_s2
			ky_p double `_mean_s1', mean_s1
			ky_p double `_sig_s1' ,  sig_s1
			ky_p double `_mean_s2', mean_s2
			ky_p double `_sig_s2' ,  sig_s2
			ky_p double `_mean_s3', mean_s3
			ky_p double `_sig_s3' ,  sig_s3			
			ky_p double `_pi_s1'  ,  pi_s1
			ky_p double `_pi_s2'  ,  pi_s2
			local _pi_s3 (1-`_pi_s1'-`_pi_s2')
			
			tempvar _pip_1 _pip_2 _pip_3
			gen double `_pip_1' =    `_pi_s1' *normalden(`_s',`_mean_s1',`_sig_s1')
			gen double `_pip_2' =    `_pi_s2' *normalden(`_s',`_mean_s2',`_sig_s2')
			gen double `_pip_3' =    `_pi_s3' *normalden(`_s',`_mean_s3',`_sig_s3')
			if "`pip_s1'" != "" {
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_1'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi s type 1"
			}	
			else if "`pip_s2'" != "" {
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_2'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi s type 2"
			}
			else if "`pip_s3'" != "" {
				syntax newvarname [if] [in] [, * ]
				gen `typlist' `varlist'=`_pip_3'/(`_pip_1'+`_pip_2'+`_pip_3')  if `touse' 
				label var `varlist' "Posterior pi s type 3"
			}
		}
		********************************************
		else if "`pip_1'" != "" {
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=`_l' if `touse'
			label var `varlist' "Posterior prob pi_1 Constant and equal to 1"
		}
		else if "`pip_2'`pip_3'`pip_4'`pip_5'`pip_6'" != "" {
			tempvar _mean_s1 _sig_s1 ///
			        _mean_s2 _sig_s2 ///
					_mean_s3 _sig_s3 ///
					_mean_r2 _sig_r2 ///
					_mean_r3 _sig_r3
			*_mean_r1 sig_r1 
			ky_p double `_mean_s1', mean_s1
			ky_p double `_sig_s1' ,  sig_s1
			ky_p double `_mean_s2', mean_s2
			ky_p double `_sig_s2' ,  sig_s2
			ky_p double `_mean_s3', mean_s3
			ky_p double `_sig_s3' ,  sig_s3
			*ky_p double `_mean_r1', mean_r1
			*ky_p double `_sig_r1' ,  sig_r1
			ky_p double `_mean_r2', mean_r2
			ky_p double `_sig_r2' ,  sig_r2

			
			ky_p double `_rho_s'  ,  rho_s
			ky_p double `_rho_r'  ,  rho_r
			
			ky_p double `_sig_e'  , sig_e
			
			tempvar _pi_2 _pi_3 _pi_4 _pi_5 _pi_6  
			ky_p double `_pi_2'  ,  pi_2
			ky_p double `_pi_3'  ,  pi_3
			ky_p double `_pi_4'  ,  pi_4
			ky_p double `_pi_5'  ,  pi_5
			ky_p double `_pi_6'  ,  pi_6
			
			
			local _mean_r1 (`_mean_s1')
			local _sig_r1 (`_sig_s1')
			
			local _rho_r1s1  1
			local _rho_r1s2  (((1+`_rho_s')*`_sig_e'^2)/(`_sig_r1'*`_sig_s2'))
			local _rho_r1s3  (((1+`_rho_s')*`_sig_e'^2)/(`_sig_r1'*`_sig_s3'))
			local _rho_r2s1  ((             (1+`_rho_r')*`_sig_e'^2)/(`_sig_r2'*`_sig_s1'))
			local _rho_r2s2  (((1+`_rho_s')*(1+`_rho_r')*`_sig_e'^2)/(`_sig_r2'*`_sig_s2'))
			local _rho_r2s3  (((1+`_rho_s')*(1+`_rho_r')*`_sig_e'^2)/(`_sig_r2'*`_sig_s3'))
			
			tempvar _pip2 _pip3 _pip4 _pip5 _pip6 _pip7 _pip8 _pip9
			local _std_r1 ((`_r'-`_mean_r1')/`_sig_r1')
			local _std_r2 ((`_r'-`_mean_r2')/`_sig_r2')
			*local _std_r3 ((`_r'-`_mean_r3')/`_sig_r3')
			local _std_s1 ((`_s'-`_mean_s1')/`_sig_s1')
			local _std_s2 ((`_s'-`_mean_s2')/`_sig_s2')
			local _std_s3 ((`_s'-`_mean_s3')/`_sig_s3')
			
			gen double `_pip2'=`_pi_2'*(1/(2*_pi*`_sig_r1'*`_sig_s2'*sqrt(1-`_rho_r1s2'^2))*exp(-1/(2*(1-`_rho_r1s2'^2))*(`_std_r1'^2+`_std_s2'^2-2*`_rho_r1s2'*`_std_r1'*`_std_s2')))
			gen double `_pip3'=`_pi_3'*(1/(2*_pi*`_sig_r1'*`_sig_s3'*sqrt(1-`_rho_r1s3'^2))*exp(-1/(2*(1-`_rho_r1s3'^2))*(`_std_r1'^2+`_std_s3'^2-2*`_rho_r1s3'*`_std_r1'*`_std_s3'))) 
			gen double `_pip4'=`_pi_4'*(1/(2*_pi*`_sig_r2'*`_sig_s1'*sqrt(1-`_rho_r2s1'^2))*exp(-1/(2*(1-`_rho_r2s1'^2))*(`_std_r2'^2+`_std_s1'^2-2*`_rho_r2s1'*`_std_r2'*`_std_s1'))) 
			gen double `_pip5'=`_pi_5'*(1/(2*_pi*`_sig_r2'*`_sig_s2'*sqrt(1-`_rho_r2s2'^2))*exp(-1/(2*(1-`_rho_r2s2'^2))*(`_std_r2'^2+`_std_s2'^2-2*`_rho_r2s2'*`_std_r2'*`_std_s2'))) 
			gen double `_pip6'=`_pi_6'*(1/(2*_pi*`_sig_r2'*`_sig_s3'*sqrt(1-`_rho_r2s3'^2))*exp(-1/(2*(1-`_rho_r2s3'^2))*(`_std_r2'^2+`_std_s3'^2-2*`_rho_r2s3'*`_std_r2'*`_std_s3'))) 
			
			syntax newvarname [if] [in] [, * ]
			local _pip_t  `_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6'
			if "`pip_2'"!="" {
				gen `typlist' `varlist'=`_pip2'/(`_pip_t') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_2"
			}
			if "`pip_3'"!="" {
				gen `typlist' `varlist'=`_pip3'/(`_pip_t') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_3"
			}
			if "`pip_4'"!="" {
				gen `typlist' `varlist'=`_pip4'/(`_pip_t') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_4"
			}
			if "`pip_5'"!="" {
				gen `typlist' `varlist'=`_pip5'/(`_pip_t') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_5"
			}
			if "`pip_6'"!="" {
				gen `typlist' `varlist'=`_pip6'/(`_pip_t') if `touse'
				replace   `varlist'=0 if `touse' & `_l'==1
				label var `varlist' "Posterior prob pi_6"
			}
		}
*************************************************************************
		else if "`bclass_s'"!="" {
			tempvar _pip_s1 _pip_s2  
			ky_p double `_pip_s1' , pip_s1
			ky_p double `_pip_s2' , pip_s2
			local _pip_s3 (1-`_pip_s1'-`_pip_s2')
			tempvar _high
			gen double `_high'=0 
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=0 
			forvalues i=1/3 {
				replace `varlist'=`i'         if `_pip_s`i''>`_high' 
				replace `_high'  =`_pip_s`i'' if `_pip_s`i''>`_high' 
			}			
			label var `varlist' "two-step classification based on S only"
		}
		else if "`bclass_r'"!="" {
			tempvar _pip_r1 _pip_r2  
			ky_p double `_pip_r1' , pip_r1
			ky_p double `_pip_r2' , pip_r2
			
			tempvar _high
			gen double `_high'=0 
		    syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=0 
			forvalues i=1/2 {
				replace `varlist'=`i'         if `_pip_r`i''>`_high' 
				replace `_high'  =`_pip_r`i'' if `_pip_r`i''>`_high' 
			}			
			label var `varlist' "two-step classification based on R only"
		}
		
		else if "`bclass'"!="" {
			tempvar _mean_s1 _sig_s1 ///
			        _mean_s2 _sig_s2 ///
					_mean_s3 _sig_s3 ///
					_mean_r2 _sig_r2 ///
					
			*_mean_r1 sig_r1 
			ky_p double `_mean_s1', mean_s1
			ky_p double `_sig_s1' ,  sig_s1
			ky_p double `_mean_s2', mean_s2
			ky_p double `_sig_s2' ,  sig_s2
			ky_p double `_mean_s3', mean_s3
			ky_p double `_sig_s3' ,  sig_s3
			*ky_p double `_mean_r1', mean_r1
			*ky_p double `_sig_r1' ,  sig_r1
			ky_p double `_mean_r2', mean_r2
			ky_p double `_sig_r2' ,  sig_r2
			
			ky_p double `_rho_s'  ,  rho_s
			ky_p double `_rho_r'  ,  rho_r
			
			ky_p double `_sig_e'  , sig_e
			
			tempvar _pi_2 _pi_3 _pi_4 _pi_5 _pi_6 
			ky_p double `_pi_2'  ,  pi_2
			ky_p double `_pi_3'  ,  pi_3
			ky_p double `_pi_4'  ,  pi_4
			ky_p double `_pi_5'  ,  pi_5
			ky_p double `_pi_6'  ,  pi_6
			
			
			local _mean_r1 (`_mean_s1')
			local _sig_r1 (`_sig_s1')
			
			local _rho_r1s1  1
			local _rho_r1s2  (((1+`_rho_s')*`_sig_e'^2)/(`_sig_r1'*`_sig_s2'))
			local _rho_r1s3  (((1+`_rho_s')*`_sig_e'^2)/(`_sig_r1'*`_sig_s3'))
			local _rho_r2s1  ((             (1+`_rho_r')*`_sig_e'^2)/(`_sig_r2'*`_sig_s1'))
			local _rho_r2s2  (((1+`_rho_s')*(1+`_rho_r')*`_sig_e'^2)/(`_sig_r2'*`_sig_s2'))
			local _rho_r2s3  (((1+`_rho_s')*(1+`_rho_r')*`_sig_e'^2)/(`_sig_r2'*`_sig_s3'))
			
			tempvar _pip2 _pip3 _pip4 _pip5 _pip6 
			local _std_r1 ((`_r'-`_mean_r1')/`_sig_r1')
			local _std_r2 ((`_r'-`_mean_r2')/`_sig_r2')
			
			local _std_s1 ((`_s'-`_mean_s1')/`_sig_s1')
			local _std_s2 ((`_s'-`_mean_s2')/`_sig_s2')
			local _std_s3 ((`_s'-`_mean_s3')/`_sig_s3')
			
			gen double `_pip2'=`_pi_2'*(1/(2*_pi*`_sig_r1'*`_sig_s2'*sqrt(1-`_rho_r1s2'^2))*exp(-1/(2*(1-`_rho_r1s2'^2))*(`_std_r1'^2+`_std_s2'^2-2*`_rho_r1s2'*`_std_r1'*`_std_s2')))
			gen double `_pip3'=`_pi_3'*(1/(2*_pi*`_sig_r1'*`_sig_s3'*sqrt(1-`_rho_r1s3'^2))*exp(-1/(2*(1-`_rho_r1s3'^2))*(`_std_r1'^2+`_std_s3'^2-2*`_rho_r1s3'*`_std_r1'*`_std_s3'))) 
			gen double `_pip4'=`_pi_4'*(1/(2*_pi*`_sig_r2'*`_sig_s1'*sqrt(1-`_rho_r2s1'^2))*exp(-1/(2*(1-`_rho_r2s1'^2))*(`_std_r2'^2+`_std_s1'^2-2*`_rho_r2s1'*`_std_r2'*`_std_s1'))) 
			gen double `_pip5'=`_pi_5'*(1/(2*_pi*`_sig_r2'*`_sig_s2'*sqrt(1-`_rho_r2s2'^2))*exp(-1/(2*(1-`_rho_r2s2'^2))*(`_std_r2'^2+`_std_s2'^2-2*`_rho_r2s2'*`_std_r2'*`_std_s2'))) 
			gen double `_pip6'=`_pi_6'*(1/(2*_pi*`_sig_r2'*`_sig_s3'*sqrt(1-`_rho_r2s3'^2))*exp(-1/(2*(1-`_rho_r2s3'^2))*(`_std_r2'^2+`_std_s3'^2-2*`_rho_r2s3'*`_std_r2'*`_std_s3'))) 
			
			tempvar _pip_2 _pip_3 _pip_4 _pip_5 _pip_6 _pip_7 _pip_8 _pip_9
			gen double `_pip_2'=`_pip2'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6' ) if `touse'
			gen double `_pip_3'=`_pip3'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6' ) if `touse'
			gen double `_pip_4'=`_pip4'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6' ) if `touse'
			gen double `_pip_5'=`_pip5'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6' ) if `touse'
			gen double `_pip_6'=`_pip6'/(`_pip2'+`_pip3'+`_pip4'+`_pip5'+`_pip6' ) if `touse'
			
			tempvar _high
			gen double `_high'=.
			replace `_high'=0 if `_l'==0
			syntax newvarname [if] [in] [, * ]
			gen `typlist' `varlist'=1 if `_l'==1
			forvalues i=2/6 {
				replace `varlist'=`i'        if `_pip_`i''>`_high' & `_l'==0
				replace `_high'  =`_pip_`i'' if `_pip_`i''>`_high' & `_l'==0
			}
		}
	}    
end
