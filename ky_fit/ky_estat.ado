*! v2.36 09-13-2021 (FRA) Version 14
* v2.35 09-13-2021 (FRA) Add model 9
* v2.32 05-11-2021 (FRA) Change Matrix reference from colname to col number. Stata 15 does not recognize the former.
* v2.31 05-03-2021 (FRA) added surv_only to ky_xirel
* v2.3  12-28-2020 (FRA) added info for Weights
* v2.25 11-13-2020 (FRA) added xi reliability estimate report
* v2.24 9-28-2020 (FRA) added Seed for sim based Rel. And change option from pr_i to pr_j to denote class prbability
* v2.23 7-27-2020 (FRA) last Bug...?
* v2.22 7-27-2020 (FRA) Hopefully last Bug
* v2.21 7-27-2020 (FRA) Additional correction
* v2.2  7-27-2020 (FRA) Corrects REL for adding covariates to REL estatistics. 
*                       This includes analytical for models 7 and 8. 
* v2.12 7-22-2020 (FRA) adds option for IC and VCE from standard estat
* v2.11 7-14-2020 (FRA) fix Rel matrix when using SIM. Also increases Reps to 10 by default
* v2.1  7-14-2020b (FRA) Adds model 8
* v2.1  7-14-2020 (FRA) Adds pr_t pr_i pr_sr and pr_all for model 7. Also includes Pr's when there are covariates.
* v2.1  7-13-2020 (FRA) Leaves the pr_t pr_i pr_sr and pr_all matrix behind
* v2.1  7-11-2020 (FRA) Puts extra step to make sure pr's have no controls. If they do, It will use sim based rel. For now only 1 
* v2.0  7-10-2020 (FRA) This program estimates some reliability statistics for ky_fit model.
* It works IF pi's are not function of parameters.

** for reliability: opt1 cov(e,y) opt2    cov(e,y)^2  
**                        var(y)         var(e)*var(y)

program define ky_estat, 
    syntax anything , [RELiability pr_t pr_j pr_sr pr_all sim reps(int 50) * ]
	
	version 14
	
    ** First option. if there are no controls, then proceed with normal model
	** otherwise use simulation based.
	if "`anything'"=="ic" | "`anything'"=="vce" {
		estat_default `anything'
	}
	else if "`anything'" == "xirel" {
		ky_xirel, reps(`reps') `options'
	}
	else if "`e(lpi_s)'`e(lpi_r)'`e(lpi_w)'`e(lpi_v)'`sim'"=="" {
			 if  e(method_c)==1 {
				ky_est_1, `0'
			 }
		else if  e(method_c)==2 {
				ky_est_2, `0'
			 }
		else if  e(method_c)==3 {
				ky_est_3, `0'
			 }
		else if  e(method_c)==4 {
				ky_est_4, `0'
			 }
		else if  e(method_c)==5 {
				ky_est_5, `0'
			 }	
		else if  e(method_c)==6 {
				ky_est_6, `0'
			 }
		else if  e(method_c)==7 {
				ky_est_7, `0'
		}
		else if  e(method_c)==8 {
				ky_est_8, `0'
		}
		else if  e(method_c)==9 {
				ky_est_9, `0'
		}
	}	 
	else if "`e(lpi_s)'`e(lpi_r)'`e(lpi_w)'`e(lpi_v)'"!="" & "`sim'"=="" {
		ky_est_1p, `0'
	}
	else if "`sim'"!="" {
		local 00= subinstr("`0'" , "," , "" , 1)
		ky_est_1s, `00'
/*
		if  e(method_c)==1 {
				ky_est_1s, `00'
			 }
		else if  e(method_c)==2 {
				ky_est_1s, `00'
			 }
		else if  e(method_c)==3 {
				ky_est_1s, `00'
			 }
		else if  e(method_c)==4 {
				ky_est_1s, `00'
			 }
		else if  e(method_c)==5 {
				ky_est_1s, `00'
			 }	
		else if  e(method_c)==6 {
				ky_est_1s, `00'
			 }
		else if  e(method_c)==7 {
				ky_est_1s, `00'
			 }	 
		else if  e(method_c)==8 {
				ky_est_1s, `00'
			 }
		else if  e(method_c)==9 {
				ky_est_1s, `00'
			 }			 */
	}	 
end

*capture program drop ky_est_1
program define ky_est_1, rclass
	syntax [if] [in], [RELiability pr_t pr_j pr_sr pr_all ]
	
	//////////////////////////////////////////
	/// set weights and sample
	if "`e(wtype)'" != "" {
		tempvar wt
		qui gen float `wt' `e(wexp)'
		local wgtexp "[aw=`wt']"
	}
	tempvar touse yh
	qui gen byte `touse' = e(sample)
	qui:count if `touse'
	if `r(N)'==0 {
		qui:replace `touse'=1
	}
	//////////////////////////////////////////	
	
	local pi_r "(invlogit(_b[lpi_r:_cons]))"
	local pi_s "(invlogit(_b[lpi_s:_cons]))"
	local pi_w "(invlogit(_b[lpi_w:_cons]))"
	local pi_v "(invlogit(_b[lpi_v:_cons]))"
    if "`reliability'"!="" {
		qui:nlcom  (pi_1:    `pi_s'      )  ///	
		           (pi_2: (1-`pi_s')     ) , noheader `post'
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		display  as result _n "Model structure" 
		display  as result "Survey Data with RTM error"   _n
		display as text "Pr of correctly reporting data pi_s: " as result %7.4f `bpi'[1,1]
		
		display  as result _n "Data TYPE for R"   _n
		display as text "Type I : r_i = e_i" _n ///
		                "with p = 1       :"  as result "1"
		display  as result _n "Data TYPE for S"   _n
		display as text "Type I : s_i = e_i " _n ///
		                "with p = pi_s    :" as result  %7.4f `bpi'[1,1]
		display as text "type II: s_i = e_i+rho_s*[e_i-E(e_i|X)]+n_i" _n ///
		                "with p = 1- pi_s :" as result  %7.4f `bpi'[1,2]
		qui {
			tempvar   _muex _munx _sig2_e _sig2_n _pi_s _rho_s
			predictnl double `_muex'  =predict(mean_e)
			predictnl double `_munx'  =predict(mean_n)
			predictnl double `_sig2_e'=predict(sig_e)^2
			predictnl double `_sig2_n'=predict(sig_n)^2
			predictnl double `_rho_s' =predict(rho_s)   
			** pi_s
			// For Reliability we need two moments Covariance and Variance:
			tempname _mn _cv
			qui:tabstat `_muex' `_munx' `_muwx' `_muvx' `_mutx' if `touse' `wgtexp', save
			matrix `_mn'=r(StatTotal)
			qui:corr `_muex' `_munx' if `touse' `wgtexp',  cov
			matrix `_cv'=r(C)
			* Required moments
			local _mue 	 (`_mn'[1,1])
			local _mun 	 (`_mn'[1,2])
			local _vare  (`_sig2_e'+`_cv'[1,1])
			local _varn  (`_sig2_n'+`_cv'[2,2])
 			local _varex  (`_cv'[1,1])
			local _varnx  (`_cv'[2,2])
			local _coven  (`_cv'[1,2])
			
			*display in w `_varex' 
			** Variance for S|1 and S|2
			local var_s1 (`_vare'                                             +((1-`pi_s')*`_mun')^2)
			local var_s2 (`_varex' + (1+ `_rho_s' )^2*`_sig2_e'+`_varn'+2*`_coven'+(`pi_s'*`_mun')^2)
						
			tempvar vs cv_es vr cv_er
			gen double `vs'   =`pi_s'*`var_s1'+(1-`pi_s')*`var_s2'
			gen double `cv_es'=`_vare'+(1-`pi_s')*`_rho_s'*`_sig2_e'+(1-`pi_s')*`_coven'
			gen double `vr'   =`_vare'
			gen double `cv_er'=`_vare'
			tempvar kappa_s kappa_r
			gen double `kappa_r'=`cv_er'/`vr'
			gen double `kappa_s'=`cv_es'/`vs'
			tempvar kappa2_s kappa2_r
			gen double `kappa2_r'=`cv_er'^2/(`vr'*`_vare')
			gen double `kappa2_s'=`cv_es'^2/(`vs'*`_vare')
		}
		display  _n as result "Summary Moments Statistics"   
		tempname mmsum
		sum `_sig2_e' if `touse' `wgtexp', meanonly
		local __sig2_e=r(mean)
		sum `_sig2_n' if `touse' `wgtexp', meanonly
		local __sig2_n=r(mean)
		local _vare   (`__sig2_e'+`_cv'[1,1])
		local _varn   (`__sig2_n'+`_cv'[2,2])
				
		matrix `mmsum'=[`_mue'  ,  `_vare' ,  `_varex' ,   `__sig2_e' \ ///
		                `_mun'  ,  `_varn' ,  `_varnx' ,   `__sig2_n' ]
		matrix colname `mmsum' = E(x_i)   "V(x_i)="   V(E(x_i|X))  Sig_x^2		    
		matrix rowname `mmsum' = e_i n_i 
		matrix list  `mmsum', forma(%6.4f) nohead
 		
		qui:tabstat `vr' `cv_er' `kappa_r' `kappa2_r' `vs' `cv_es' `kappa_s' `kappa2_s' if `touse' `wgtexp' ,save
		tempvar _mnres
		matrix `_mnres'=r(StatTotal)		
		matrix `_mnres'[1,3]=`_mnres'[1,2]/`_mnres'[1,1]
		matrix `_mnres'[1,4]=`_mnres'[1,2]^2/(`_mnres'[1,1]*`_vare')
		matrix `_mnres'[1,7]=`_mnres'[1,6]/`_mnres'[1,5]
		matrix `_mnres'[1,8]=`_mnres'[1,6]^2/(`_mnres'[1,5]*`_vare')		

		display  _n as result "Reliability Statistics: R"  _n
		display as text "Var(r_i)     " as result %7.4f `_mnres'[1,1]
		display as text "Cov(r_i,e_i) " as result %7.4f `_mnres'[1,2]
		display as text "Reliability  " as result %7.4f `_mnres'[1,3]
		display as text "Reliability 2" as result %7.4f `_mnres'[1,4]
		display  _n as result "Reliability Statistics: S"  _n
		display as text "Var(s_i)     " as result %7.4f `_mnres'[1,5]
		display as text "Cov(s_i,e_i) " as result %7.4f `_mnres'[1,6]
		display as text "Reliability  " as result %7.4f `_mnres'[1,7]
		display as text "Reliability 2" as result %7.4f `_mnres'[1,8]
		local coln:colnames `bpi'
		foreach i of local coln {
			local _cnt=`_cnt'+1
			return scalar `i' =`bpi'[1,`_cnt'] 
		}
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'
		matrix `_mnres'=`_mnres'[1,1..4] \ `_mnres'[1,5..8]
		matrix colname `_mnres' = "Var" "Cov" "Rel1" "Rel2"
		matrix rowname `_mnres' = R S
		return scalar rel_r=`_mnres'[1,3]
		return scalar rel_s=`_mnres'[2,3]
		return scalar rel2_r=`_mnres'[1,4]
		return scalar rel2_s=`_mnres'[2,4]
		return matrix rel=`_mnres'
		return matrix mmsum=`mmsum'
	}
	else if "`pr_t'"!="" {
	    nlcom  (pi_s:`pi_s') , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'
	}
	else if "`pr_j'"!="" {
	    nlcom  (pi_1:       `pi_s' ) ///
			   (pi_2:    (1-`pi_s')) , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
	else if "`pr_sr'"!="" {
	    nlcom  (pi_s1:   `pi_s'  )  ///	
			   (pi_s2:(1-`pi_s') )  , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
	else if "`pr_all'"!="" {
		nlcom  (pi_s :    `pi_s' )    ///
			   (pi_s1:    `pi_s' )   ///	
			   (pi_s2: (1-`pi_s'))  ///
			   (pi_1 :    `pi_s' ) ///
			   (pi_2 : (1-`pi_s')) , noheader 
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}	
end


*capture program drop ky_est_2
program define ky_est_2, rclass
	syntax , [RELiability pr_t pr_j pr_sr pr_all]
		//////////////////////////////////////////
	/// set weights and sample
	if "`e(wtype)'" != "" {
		tempvar wt
		qui gen float `wt' `e(wexp)'
		local wgtexp "[aw=`wt']"
	}
	tempvar touse yh
	qui gen byte `touse' = e(sample)
	qui:count if `touse'
	if `r(N)'==0 {
		qui:replace `touse'=1
	}
	//////////////////////////////////////////	
		local pi_r "(invlogit(_b[/lpi_r]))"
		local pi_s "(invlogit(_b[/lpi_s]))"
		local pi_w "(invlogit(_b[/lpi_w]))"
		local pi_v "(invlogit(_b[/lpi_v]))"
		local pi_t "(invlogit(_b[/lpi_t]))"
	if "`reliability'"!="" {
		qui:nlcom  (pi_s:`pi_s')  (pi_w:`pi_w') ///
			   (pi_s1:   `pi_s'               )  ///	
			   (pi_s2:(1-`pi_s')*(1-`pi_w')   )	 ///	
			   (pi_s3:(1-`pi_s')*   `pi_w'    ) , noheader `post'
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)	   
		display  _n as result "Model structure Probabilities:"
		display  as result "Survey Data RTM error and Contamination:"  _n
		display as text "Pr of correctly reporting data pi_s:" as result %7.4f  `bpi'[1,1]
		display as text "Pr of contamination            pi_w:" as result %7.4f  `bpi'[1,2]
		display as result _n "Data TYPE for R"   _n
		display as text "Type I  : r_i = e_i" _n ///
		                "with pr=1                :"  as result "  1"
		display as result _n "Data TYPE for S"   _n
		display as text "Type I  : s_i = e_i" _n ///
						"with pr=pi_s             :" as result %7.4f  `bpi'[1,3] _n
		display as text "Type II : s_i = e_i+rho_s*[e_i-E(e_i|X)]+n_i" _n ///
						"with pr=(1-pi_s)*(1-pi_w):" as result %7.4f  `bpi'[1,4] _n
		display as text "Type III: s_i = e_i+rho_s*[e_i-E(e_i|X)]+n_i+w_i" _n ///
						"with pr=(1-pi_s)*   pi_w :" as result %7.4f  `bpi'[1,5] _n
		qui {
			tempvar   _muex _munx _muwx _sig2_e _sig2_n _sig2_w _rho_s
			predictnl double `_muex'  =predict(mean_e)
			predictnl double `_munx'  =predict(mean_n)
			predictnl double `_muwx'  =predict(mean_w)
			predictnl double `_sig2_e'=predict(sig_e)^2
			predictnl double `_sig2_n'=predict(sig_n)^2
			predictnl double `_sig2_w'=predict(sig_w)^2
			predictnl double `_rho_s' =predict(rho_s)   
			** pi_s
			// For Reliability we need two moments Covariance and Variance:
			tempname _mn _cv
			qui:tabstat `_muex' `_munx' `_muwx' `_muvx' `_mutx' if `touse' `wgtexp', save
			matrix `_mn'=r(StatTotal)
			qui:corr `_muex' `_munx' `_muwx' if `touse' `wgtexp',  cov
			matrix `_cv'=r(C)
			** Required moments
			local _mue 	  (`_mn'[1,1])
			local _mun 	  (`_mn'[1,2])
			local _muw 	  (`_mn'[1,3])
			local _vare   (`_sig2_e'+`_cv'[1,1])
			local _varn   (`_sig2_n'+`_cv'[2,2])
			local _varw   (`_sig2_w'+`_cv'[3,3])
			local _varex  (`_cv'[1,1])
			local _varnx  (`_cv'[2,2])
			local _varwx  (`_cv'[3,3])
			local _coven  (`_cv'[1,2])
			local _covew  (`_cv'[1,3])
			local _covnw  (`_cv'[2,3])
			** Var by type
						
			local var_s1 (`_vare'                                             									+((1-`pi_s')*`_mun'    +`pi_w'*(1-`pi_s') *`_muw')^2)
			local var_s2 (`_varex' + (1+ `_rho_s' )^2*`_sig2_e'+`_varn'		   +2*`_coven'     		            +(  -`pi_s' *`_mun'    +`pi_w'*(1-`pi_s') *`_muw')^2)
			local var_s3 (`_varex' + (1+ `_rho_s' )^2*`_sig2_e'+`_varn'+`_varw'+2*`_coven'+2*`_covew'+2*`_covnw'+(  -`pi_s' *`_mun'+(-1+`pi_w'*(1-`pi_s'))*`_muw')^2)

			tempvar vs cv_es vr cv_er
			gen double `vs'=`pi_s'*`var_s1'+(1-`pi_w')*(1-`pi_s')*`var_s2'+`pi_w' *(1-`pi_s')*`var_s3'
			gen double `cv_es'=`_vare'+ ///
							   (1-`pi_s')*`_rho_s'*`_sig2_e'+ ///
							   (1-`pi_s')*`_coven'+ ///
							   (1-`pi_s')*`pi_w'*`_covew'
			gen double `vr'=`_vare'
			gen double `cv_er'=`_vare'
			tempvar kappa_s kappa_r
			gen double `kappa_r'=`cv_er'/`vr'
			gen double `kappa_s'=`cv_es'/`vs'
			tempvar kappa2_s kappa2_r
			gen double `kappa2_r'=`cv_er'^2/(`vr'*`_vare')
			gen double `kappa2_s'=`cv_es'^2/(`vs'*`_vare')
			
		}	
		display  _n as result "Summary Moments Statistics"  
		sum `_sig2_e' if `touse' `wgtexp', meanonly
		local __sig2_e=r(mean)
		sum `_sig2_n' if `touse' `wgtexp', meanonly
		local __sig2_n=r(mean)
		sum `_sig2_w' if `touse' `wgtexp', meanonly
		local __sig2_w=r(mean)
		local _vare   (`__sig2_e'+`_cv'[1,1])
		local _varn   (`__sig2_n'+`_cv'[2,2])
		local _varw   (`__sig2_w'+`_cv'[3,3])
		tempname mmsum
		matrix `mmsum'=[`_mue'  ,  `_vare' ,  `_varex' ,   `__sig2_e' \ ///
		                `_mun'  ,  `_varn' ,  `_varnx' ,   `__sig2_n' \ ///
					    `_muw'  ,  `_varw' ,  `_varwx' ,   `__sig2_w' ]
		matrix colname `mmsum' = E(x_i)   "V(x_i)="   V(E(x_i|X))  Sig_x^2		    
		matrix rowname `mmsum' = e_i n_i w_i 
		matrix list  `mmsum', forma(%6.4f) nohead
		
qui:tabstat `vr' `cv_er' `kappa_r' `kappa2_r' `vs' `cv_es' `kappa_s' `kappa2_s' if `touse' `wgtexp' ,save
		tempvar _mnres
		matrix `_mnres'=r(StatTotal)
		matrix `_mnres'[1,3]=`_mnres'[1,2]/`_mnres'[1,1]
		matrix `_mnres'[1,4]=`_mnres'[1,2]^2/(`_mnres'[1,1]*`_vare')
		matrix `_mnres'[1,7]=`_mnres'[1,6]/`_mnres'[1,5]
		matrix `_mnres'[1,8]=`_mnres'[1,6]^2/(`_mnres'[1,5]*`_vare')		
		display  _n as result "Reliability Statistics: R"  _n
		display as text "Var(r_i)     " as result %7.4f `_mnres'[1,1]
		display as text "Cov(r_i,e_i) " as result %7.4f `_mnres'[1,2]
		display as text "Reliability  " as result %7.4f `_mnres'[1,3]
		display as text "Reliability 2" as result %7.4f `_mnres'[1,4]
		display  _n as result "Reliability Statistics: S"  _n
		display as text "Var(s_i)     " as result %7.4f `_mnres'[1,5]
		display as text "Cov(s_i,e_i) " as result %7.4f `_mnres'[1,6]
		display as text "Reliability  " as result %7.4f `_mnres'[1,7]
		display as text "Reliability 2" as result %7.4f `_mnres'[1,8]
		local coln:colnames `bpi'
		foreach i of local coln {
			local _cnt=`_cnt'+1
			return scalar `i' =`bpi'[1,`_cnt'] 
		}		
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'
		matrix `_mnres'=`_mnres'[1,1..4] \ `_mnres'[1,5..8]
		matrix colname `_mnres' = "Var" "Cov" "Rel1" "Rel2"
		matrix rowname `_mnres' = R S
		return scalar rel_r=`_mnres'[1,3]
		return scalar rel_s=`_mnres'[2,3]
		return scalar rel2_r=`_mnres'[1,4]
		return scalar rel2_s=`_mnres'[2,4]
		return matrix rel=`_mnres'
		return matrix mmsum=`mmsum'
		
	}
	else if "`pr_t'"!="" {
	    nlcom  (pi_s:`pi_s') /// 
			   (pi_w:`pi_w') , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
	else if "`pr_j'"!="" {
	    nlcom  (pi_1 :   `pi_s'               )  ///	
			   (pi_2 :(1-`pi_s')*(1-`pi_w')   )	 ///	
			   (pi_3 :(1-`pi_s')*   `pi_w'    ), noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
	else if "`pr_sr'"!="" {
	    nlcom  (pi_s1:   `pi_s'               )  ///	
			   (pi_s2:(1-`pi_s')*(1-`pi_w')   )	 ///	
			   (pi_s3:(1-`pi_s')*   `pi_w'    )  , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
	else if "`pr_all'"!="" {
		nlcom  (pi_s :`pi_s')      (pi_w:`pi_w') ///
			   (pi_s1:   `pi_s'               )  ///	
			   (pi_s2:(1-`pi_s')*(1-`pi_w')   )	 ///	
			   (pi_s3:(1-`pi_s')*   `pi_w'    )  ///
			   (pi_1 :   `pi_s'               )  ///	
			   (pi_2 :(1-`pi_s')*(1-`pi_w')   )	 ///	
			   (pi_3 :(1-`pi_s')*   `pi_w'    ), noheader `post'   
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
end


*capture program drop ky_est_3
program define ky_est_3, rclass
syntax , [RELiability pr_t pr_j pr_sr pr_all]
	//////////////////////////////////////////
	/// set weights and sample
	if "`e(wtype)'" != "" {
		tempvar wt
		qui gen float `wt' `e(wexp)'
		local wgtexp "[aw=`wt']"
	}
	tempvar touse yh
	qui gen byte `touse' = e(sample)
	qui:count if `touse'
	if `r(N)'==0 {
		qui:replace `touse'=1
	}
	//////////////////////////////////////////	
	local pi_r "(invlogit(_b[/lpi_r]))"
	local pi_s "(invlogit(_b[/lpi_s]))"
	local pi_w "(invlogit(_b[/lpi_w]))"
	local pi_v "(invlogit(_b[/lpi_v]))"
	if "`reliability'"!="" {
		qui:nlcom  (pi_s:`pi_s')  (pi_r:`pi_r') ///
				   (pi_s1:   `pi_s'    )     ///	
				   (pi_s2:(1-`pi_s')   ) 	 ///	
				   (pi_r1:   `pi_r'    )     ///
				   (pi_r2:(1-`pi_r')   )     ///
				   (pi_1:    `pi_r' *   `pi_s'   )  ///
				   (pi_2:    `pi_r' *(1-`pi_s')  )  ///
				   (pi_3: (1-`pi_r')*   `pi_s'   )  ///
				   (pi_4: (1-`pi_r')*(1-`pi_s')  )   , noheader `post'		   
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)	   
	
		display _n as result "Model structure:"
		display as result "Survey with RTM error and Admin data with Mismatch:"  _n
		display as text "Pr of correctly reporting data pi_s: " as result %7.4f  `bpi'[1,1]
		display as text "Pr of correctly match          pi_r: " as result %7.4f  `bpi'[1,2]
		display as result _n "Data TYPE for R"   _n
		display as text "Type I : r_i = e_i                             " _n "with p =     pi_r : "  as result %7.4f  `bpi'[1,5]
		display as text "type II: r_i = t_i                             " _n "with p = (1- pi_r): "  as result %7.4f  `bpi'[1,6] _n
		display as result "Data TYPE for S"   _n
		display as text "Type I : s_i = e_i                             " _n "with p =     pi_s : "  as result %7.4f  `bpi'[1,3]
		display as text "Type II: s_i = e_i+rho_s*[e_i-E(e_i|X)]+n_i" _n "with p = (1- pi_s): "  as result %7.4f  `bpi'[1,4] _n
		display as result "Class probabilities"  _n
		display as text "Pr R type I  & S Type I : " as result %7.4f  `bpi'[1,7]
		display as text "Pr R type I  & S Type II: " as result %7.4f  `bpi'[1,8]
		display as text "Pr R type II & S Type I : " as result %7.4f  `bpi'[1,9]
		display as text "Pr R type II & S Type II: " as result %7.4f  `bpi'[1,10]
 		qui {
			tempvar  _muex   _munx    _mutx 
			tempvar  _sig2_e _sig2_n  _sig2_t _rho_s
			predictnl double `_muex'  =predict(mean_e)
			predictnl double `_munx'  =predict(mean_n)
			predictnl double `_mutx'  =predict(mean_t)
			predictnl double `_sig2_e'=predict(sig_e)^2
			predictnl double `_sig2_n'=predict(sig_n)^2
			predictnl double `_sig2_t'=predict(sig_t)^2
			predictnl double `_rho_s' =predict(rho_s)   
			
		 
			// For Reliability we need two moments Covariance and Variance:
			tempname _mn _cv
			qui:tabstat `_muex' `_munx' `_muwx' `_muvx' `_mutx' if `touse' `wgtexp', save
			matrix `_mn'=r(StatTotal)
			qui:corr `_muex' `_munx' `_mutx' if `touse' `wgtexp',  cov
			matrix `_cv'=r(C)
			** Required moments
			local _mue 	  (`_mn'[1,1])
			local _mun 	  (`_mn'[1,2])
			local _mut 	  (`_mn'[1,3])
			local _vare   (`_sig2_e'+`_cv'[1,1])
			local _varn   (`_sig2_n'+`_cv'[2,2])
			local _vart   (`_sig2_t'+`_cv'[3,3])
			local _varex  (`_cv'[1,1])
			local _varnx  (`_cv'[2,2])
			local _vartx  (`_cv'[3,3])
			***
			local _coven  (`_cv'[1,2])
			local _covet  (`_cv'[1,3])
			***
			local _covnt  (`_cv'[2,3])
			
			** Var by type
			local var_s1 (`_vare'                                                 +((1-`pi_s')*`_mun')^2)
			local var_s2 (`_varex' + (1+ `_rho_s' )^2*`_sig2_e'+`_varn'+2*`_coven'+(`pi_s'*`_mun')^2)
			local var_r1 ( `_vare' +( (1-`pi_r')*(`_mut'-`_mue'))^2)
			local var_r2 ( `_vart' +(   -`pi_r' *(`_mut'-`_mue'))^2)
			tempvar vs cv_es vr cv_er
			gen double `vs'=`pi_s'*`var_s1'+(1-`pi_s')*`var_s2'
			gen double `cv_es'=`_vare'+ ///
							   (1-`pi_s')*`_rho_s'*`_sig2_e'+ ///
							   (1-`pi_s')*`_coven'
			gen double `vr'=`pi_r'*`var_r1'+(1-`pi_r')*`var_r2'
			gen double `cv_er'=   `pi_r' *`_vare'+ ///
							   (1-`pi_r')*`_covet'				   
			tempvar kappa_s kappa_r
			gen double `kappa_r'=`cv_er'/`vr'
			gen double `kappa_s'=`cv_es'/`vs'
			tempvar kappa2_s kappa2_r
			gen double `kappa2_r'=`cv_er'^2/(`vr'*`_vare')
			gen double `kappa2_s'=`cv_es'^2/(`vs'*`_vare')
		}
		
		display _n as result "Summary Moments Statistics"  
		sum `_sig2_e' if `touse' `wgtexp', meanonly
		local __sig2_e=r(mean)
		sum `_sig2_n' if `touse' `wgtexp', meanonly
		local __sig2_n=r(mean)
		sum `_sig2_t' if `touse' `wgtexp', meanonly
		local __sig2_t=r(mean)
		local _vare   (`__sig2_e'+`_cv'[1,1])
		local _varn   (`__sig2_n'+`_cv'[2,2])
		local _vart   (`__sig2_t'+`_cv'[3,3])
		tempname mmsum
		matrix `mmsum'=[`_mue'  ,  `_vare' ,  `_varex' ,   `__sig2_e' \ ///
		                `_mun'  ,  `_varn' ,  `_varnx' ,   `__sig2_n' \ ///
						`_mut'  ,  `_vart' ,  `_vartx' ,   `__sig2_t' ]
		matrix colname `mmsum' = E(x_i)   "V(x_i)="   V(E(x_i|X))  Sig_x^2		    
		matrix rowname `mmsum' = e_i n_i t_i 
		matrix list  `mmsum', forma(%6.4f) nohead	
		qui:tabstat `vr' `cv_er' `kappa_r' `kappa2_r' `vs' `cv_es' `kappa_s' `kappa2_s' if `touse' `wgtexp' ,save
		tempvar _mnres
		matrix `_mnres'=r(StatTotal)
		matrix `_mnres'[1,3]=`_mnres'[1,2]/`_mnres'[1,1]
		matrix `_mnres'[1,4]=`_mnres'[1,2]^2/(`_mnres'[1,1]*`_vare')
		matrix `_mnres'[1,7]=`_mnres'[1,6]/`_mnres'[1,5]
		matrix `_mnres'[1,8]=`_mnres'[1,6]^2/(`_mnres'[1,5]*`_vare')		
		display  _n as result "Reliability Statistics: R"  _n
		display as text "Var(r_i)     " as result %7.4f `_mnres'[1,1]
		display as text "Cov(r_i,e_i) " as result %7.4f `_mnres'[1,2]
		display as text "Reliability  " as result %7.4f `_mnres'[1,3]
		display as text "Reliability 2" as result %7.4f `_mnres'[1,4]
		display  _n as result "Reliability Statistics: S"  _n
		display as text "Var(s_i)     " as result %7.4f `_mnres'[1,5]
		display as text "Cov(s_i,e_i) " as result %7.4f `_mnres'[1,6]
		display as text "Reliability  " as result %7.4f `_mnres'[1,7]
		display as text "Reliability 2" as result %7.4f `_mnres'[1,8]
		local coln:colnames `bpi'
		foreach i of local coln {
			local _cnt=`_cnt'+1
			return scalar `i' =`bpi'[1,`_cnt'] 
		}
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'
		matrix `_mnres'=`_mnres'[1,1..4] \ `_mnres'[1,5..8]
		matrix colname `_mnres' = "Var" "Cov" "Rel1" "Rel2"
		matrix rowname `_mnres' = R S
		return scalar rel_r=`_mnres'[1,3]
		return scalar rel_s=`_mnres'[2,3]
		return scalar rel2_r=`_mnres'[1,4]
		return scalar rel2_s=`_mnres'[2,4]
		return matrix rel=`_mnres'
		return matrix mmsum=`mmsum'
	}
	else if "`pr_t'"!="" {
	    nlcom  (pi_s:`pi_s')  (pi_r:`pi_r') , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'
	}
	else if "`pr_j'"!="" {
	    nlcom  (pi_1:    `pi_r' *   `pi_s'   )  ///
			   (pi_2:    `pi_r' *(1-`pi_s')  )  ///
			   (pi_3: (1-`pi_r')*   `pi_s'   )  ///
			   (pi_4: (1-`pi_r')*(1-`pi_s')  ), noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
	else if "`pr_sr'"!="" {
	    nlcom  (pi_s1:   `pi_s'    )     ///	
			   (pi_s2:(1-`pi_s')   ) 	 ///	
			   (pi_r1:   `pi_r'    )     ///
			   (pi_r2:(1-`pi_r')   )   , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
	else if "`pr_all'"!="" {
		nlcom  (pi_s:`pi_s')  (pi_r:`pi_r') ///
				   (pi_s1:   `pi_s'    )     ///	
				   (pi_s2:(1-`pi_s')   ) 	 ///	
				   (pi_r1:   `pi_r'    )     ///
				   (pi_r2:(1-`pi_r')   )     ///
				   (pi_1:    `pi_r' *   `pi_s'   )  ///
				   (pi_2:    `pi_r' *(1-`pi_s')  )  ///
				   (pi_3: (1-`pi_r')*   `pi_s'   )  ///
				   (pi_4: (1-`pi_r')*(1-`pi_s')  )   , noheader `post'	
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'		   
	} 
end

*capture program drop ky_est_4
program define ky_est_4, rclass
syntax , [RELiability pr_t pr_j pr_sr pr_all]
	//////////////////////////////////////////
	/// set weights and sample
	if "`e(wtype)'" != "" {
		tempvar wt
		qui gen float `wt' `e(wexp)'
		local wgtexp "[aw=`wt']"
	}
	tempvar touse yh
	qui gen byte `touse' = e(sample)
	qui:count if `touse'
	if `r(N)'==0 {
		qui:replace `touse'=1
	}
	//////////////////////////////////////////	
	local pi_r "(invlogit(_b[/lpi_r]))"
	local pi_s "(invlogit(_b[/lpi_s]))"
	local pi_w "(invlogit(_b[/lpi_w]))"
	local pi_v "(invlogit(_b[/lpi_v]))"
	if "`reliability'"!="" {
		qui:nlcom  (pi_s:`pi_s') (pi_w:`pi_w') (pi_r:`pi_r') ///
	   (pi_s1:   `pi_s'             )  ///	
	   (pi_s2:(1-`pi_s')*(1-`pi_w') )  ///	
	   (pi_s3:(1-`pi_s')*   `pi_w'  )  ///	
	   (pi_r1:   `pi_r'             )  ///
	   (pi_r2:(1-`pi_r')            )  ///
	   (pi_1:    `pi_r' *   `pi_s'             ) ///
	   (pi_2:    `pi_r' *(1-`pi_s')*(1-`pi_w') ) ///
	   (pi_3:    `pi_r' *(1-`pi_s')*   `pi_w'  ) ///
	   (pi_4: (1-`pi_r')*   `pi_s'             ) ///
	   (pi_5: (1-`pi_r')*(1-`pi_s')*(1-`pi_w') ) ///
	   (pi_6: (1-`pi_r')*(1-`pi_s')*   `pi_w'  ) , noheader 		
        tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)	
		display  as result "{bf:Model structure:}"
		display  as result "{bf:Survey with RTM error and contamination and Admin data with Mismatch}"  _n
		display as text "Pr of correctly reporting data pi_s: " as result  %7.4f `bpi'[1,1]
		display as text "Pr of contamination            pi_w: " as result  %7.4f `bpi'[1,2]
		display as text "Pr of correctly match          pi_r: " as result  %7.4f `bpi'[1,3]
		display as result _n "Data TYPE for R"   _n
		display as text "Type I  : r_i = e_i                                 " _n "with p =     pi_r          :" as result %7.4f `bpi'[1,7]
		display as text "Type II : r_i = t_i                                 " _n "with p = (1- pi_r)         :" as result %7.4f `bpi'[1,8] _n 
		display as result "Data TYPE for S"   _n
		display as text "Type I  : s_i = e_i                                 " _n "with p =     pi_s          :" as result %7.4f `bpi'[1,4]
		display as text "Type II : s_i = e_i+rho_s*[e_i-E(e_i|X)]+n_i    " _n "with pr  (1- pi_s)*(1-pi_w):" as result %7.4f `bpi'[1,5]
		display as text "Type III: s_i = e_i+rho_s*[e_i-E(e_i|X)]+n_i+w_i" _n "with pr  (1- pi_s)*   pi_w :" as result %7.4f `bpi'[1,6] _n
		display as result  "{bf:Class probabilities}" _n
		display as text "Pr R type I  & S Type I  : " as result %7.4f `bpi'[1,9]
		display as text "Pr R type I  & S Type II : " as result %7.4f `bpi'[1,10]
		display as text "Pr R type I  & S Type III: " as result %7.4f `bpi'[1,11]
		display as text "Pr R type II & S Type I  : " as result %7.4f `bpi'[1,12]
		display as text "Pr R type II & S Type II : " as result %7.4f `bpi'[1,13]
		display as text "Pr R type II & S Type III: " as result %7.4f `bpi'[1,14]
		qui {
			tempvar  _muex   _munx   _muwx   _mutx 
			tempvar  _sig2_e _sig2_n _sig2_w _sig2_t _rho_s
			predictnl double `_muex'  =predict(mean_e)
			predictnl double `_munx'  =predict(mean_n)
			predictnl double `_muwx'  =predict(mean_w)
			predictnl double `_mutx'  =predict(mean_t)
			predictnl double `_sig2_e'=predict(sig_e)^2
			predictnl double `_sig2_n'=predict(sig_n)^2
			predictnl double `_sig2_w'=predict(sig_w)^2
			predictnl double `_sig2_t'=predict(sig_t)^2
			predictnl double `_rho_s' =predict(rho_s)   


			// For Reliability we need two moments Covariance and Variance:
			tempname _mn _cv
			qui:tabstat `_muex' `_munx' `_muwx' `_muvx' `_mutx' if `touse' `wgtexp', save
			matrix `_mn'=r(StatTotal)
			qui:corr `_muex' `_munx' `_muwx'   `_mutx' if `touse' `wgtexp',  cov
			matrix `_cv'=r(C)
			** Required moments
			local _mue 	  (`_mn'[1,1])
			local _mun 	  (`_mn'[1,2])
			local _muw 	  (`_mn'[1,3])
			local _mut 	  (`_mn'[1,4])
			local _vare   (`_sig2_e'+`_cv'[1,1])
			local _varn   (`_sig2_n'+`_cv'[2,2])
			local _varw   (`_sig2_w'+`_cv'[3,3])
			local _vart   (`_sig2_t'+`_cv'[4,4])
			local _varex  (`_cv'[1,1])
			local _varnx  (`_cv'[2,2])
			local _varwx  (`_cv'[3,3])
			local _vartx  (`_cv'[4,4])
			***
			local _coven  (`_cv'[1,2])
			local _covew  (`_cv'[1,3])
			local _covet  (`_cv'[1,4])
			***
			local _covnw  (`_cv'[2,3])
			local _covnt  (`_cv'[2,4])
			***
			local _covwt  (`_cv'[3,4])
					
			** Var by type
			local var_s1 (`_vare'                                             									+((1-`pi_s')*`_mun'    +`pi_w'*(1-`pi_s') *`_muw')^2)
			local var_s2 (`_varex' + (1+ `_rho_s' )^2*`_sig2_e'+`_varn'		   +2*`_coven'       		        +(  -`pi_s' *`_mun'    +`pi_w'*(1-`pi_s') *`_muw')^2)
			local var_s3 (`_varex' + (1+ `_rho_s' )^2*`_sig2_e'+`_varn'+`_varw'+2*`_coven'+2*`_covew'+2*`_covnw'+(  -`pi_s' *`_mun'+(-1+`pi_w'*(1-`pi_s'))*`_muw')^2)


			local var_r1 ( `_vare' +( (1-`pi_r')*(`_mut'-`_mue'))^2)
			local var_r2 (`_vart'  +(   -`pi_r' *(`_mut'-`_mue'))^2)
			tempvar vs cv_es vr cv_er
			gen double `vs'=`pi_s'*`var_s1'+(1-`pi_w')*(1-`pi_s')*`var_s2'+`pi_w' *(1-`pi_s')*`var_s3'
			gen double `cv_es'=`_vare'+ ///
							   (1-`pi_s')*`_rho_s'*`_sig2_e'+ ///
							   (1-`pi_s')*`_coven'+ ///
							   (1-`pi_s')*`pi_w'*`_covew'
			gen double `vr'=`pi_r'*`var_r1'+(1-`pi_r')*`var_r2'
			gen double `cv_er'=   `pi_r' *`_vare'+ ///
							   (1-`pi_r')*`_covet'				   
			tempvar kappa_s kappa_r
			gen double `kappa_r'=`cv_er'/`vr'
			gen double `kappa_s'=`cv_es'/`vs'
			tempvar kappa2_s kappa2_r
			gen double `kappa2_r'=`cv_er'^2/(`vr'*`_vare')
			gen double `kappa2_s'=`cv_es'^2/(`vs'*`_vare')
		}
		
		display  _n as result  "Summary Moments Statistics"  
		
		sum `_sig2_e' if `touse' `wgtexp', meanonly
		local __sig2_e=r(mean)
		sum `_sig2_n' if `touse' `wgtexp', meanonly
		local __sig2_n=r(mean)
		sum `_sig2_w' if `touse' `wgtexp', meanonly
		local __sig2_w=r(mean)
		sum `_sig2_t' if `touse' `wgtexp', meanonly
		local __sig2_t=r(mean)
		local _vare   (`__sig2_e'+`_cv'[1,1])
		local _varn   (`__sig2_n'+`_cv'[2,2])
		local _varw   (`__sig2_w'+`_cv'[3,3])
		local _vart   (`__sig2_t'+`_cv'[4,4])
		tempname mmsum
		
		matrix `mmsum'=[`_mue'  ,  `_vare' ,  `_varex' ,   `__sig2_e' \ ///
		                  `_mun'  ,  `_varn' ,  `_varnx' ,   `__sig2_n' \ ///
						  `_muw'  ,  `_varw' ,  `_varwx' ,   `__sig2_w' \ ///
						  `_mut'  ,  `_vart' ,  `_vartx' ,   `__sig2_t' ]
		matrix colname `mmsum' = E(x_i)   "V(x_i)="   V(E(x_i|X))  Sig_x^2		    
		matrix rowname `mmsum' = e_i n_i w_i t_i 
		matrix list  `mmsum', forma(%6.4f) nohead

qui:tabstat `vr' `cv_er' `kappa_r' `kappa2_r' `vs' `cv_es' `kappa_s' `kappa2_s' if `touse' `wgtexp' ,save
		tempvar _mnres
		matrix `_mnres'=r(StatTotal)
		matrix `_mnres'[1,3]=`_mnres'[1,2]/`_mnres'[1,1]
		matrix `_mnres'[1,4]=`_mnres'[1,2]^2/(`_mnres'[1,1]*`_vare')
		matrix `_mnres'[1,7]=`_mnres'[1,6]/`_mnres'[1,5]
		matrix `_mnres'[1,8]=`_mnres'[1,6]^2/(`_mnres'[1,5]*`_vare')		
		display  _n as result "Reliability Statistics: R"  _n
		display as text "Var(r_i)     " as result %7.4f `_mnres'[1,1]
		display as text "Cov(r_i,e_i) " as result %7.4f `_mnres'[1,2]
		display as text "Reliability  " as result %7.4f `_mnres'[1,3]
		display as text "Reliability 2" as result %7.4f `_mnres'[1,4]
		display  _n as result "Reliability Statistics: S"  _n
		display as text "Var(s_i)     " as result %7.4f `_mnres'[1,5]
		display as text "Cov(s_i,e_i) " as result %7.4f `_mnres'[1,6]
		display as text "Reliability  " as result %7.4f `_mnres'[1,7]
		display as text "Reliability 2" as result %7.4f `_mnres'[1,8]
		local coln:colnames `bpi'
		foreach i of local coln {
			local _cnt=`_cnt'+1
			return scalar `i' =`bpi'[1,`_cnt'] 
		}
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'
		matrix `_mnres'=`_mnres'[1,1..4] \ `_mnres'[1,5..8]
		matrix colname `_mnres' = "Var" "Cov" "Rel1" "Rel2"
		matrix rowname `_mnres' = R S
		return scalar rel_r=`_mnres'[1,3]
		return scalar rel_s=`_mnres'[2,3]
		return scalar rel2_r=`_mnres'[1,4]
		return scalar rel2_s=`_mnres'[2,4]
		return matrix rel=`_mnres'
		return matrix mmsum=`mmsum'
	}
	else if "`pr_t'"!="" {
	    nlcom  (pi_s:`pi_s') /// 
			   (pi_w:`pi_w') /// 
			   (pi_r:`pi_r') , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'
	}
	else if "`pr_j'"!="" {
	    nlcom  (pi_1:    `pi_r' *   `pi_s'             ) ///
			   (pi_2:    `pi_r' *(1-`pi_s')*(1-`pi_w') ) ///
			   (pi_3:    `pi_r' *(1-`pi_s')*   `pi_w'  ) ///
			   (pi_4: (1-`pi_r')*   `pi_s'             ) ///
			   (pi_5: (1-`pi_r')*(1-`pi_s')*(1-`pi_w') ) ///
			   (pi_6: (1-`pi_r')*(1-`pi_s')*   `pi_w'  ), noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'
	}
	else if "`pr_sr'"!="" {
	    nlcom  (pi_s1:   `pi_s'             )  ///	
			   (pi_s2:(1-`pi_s')*(1-`pi_w') )  ///	
			   (pi_s3:(1-`pi_s')*   `pi_w'  )  ///	
			   (pi_r1:   `pi_r'             )  ///
			   (pi_r2:(1-`pi_r')            )  , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
	else if "`pr_all'"!="" {
		nlcom  (pi_s:`pi_s') (pi_w:`pi_w') (pi_r:`pi_r') ///
			   (pi_s1:   `pi_s'             )  ///	
			   (pi_s2:(1-`pi_s')*(1-`pi_w') )  ///	
			   (pi_s3:(1-`pi_s')*   `pi_w'  )  ///	
			   (pi_r1:   `pi_r'             )  ///
			   (pi_r2:(1-`pi_r')            )  ///
			   (pi_1:    `pi_r' *   `pi_s'             ) ///
			   (pi_2:    `pi_r' *(1-`pi_s')*(1-`pi_w') ) ///
			   (pi_3:    `pi_r' *(1-`pi_s')*   `pi_w'  ) ///
			   (pi_4: (1-`pi_r')*   `pi_s'             ) ///
			   (pi_5: (1-`pi_r')*(1-`pi_s')*(1-`pi_w') ) ///
			   (pi_6: (1-`pi_r')*(1-`pi_s')*   `pi_w'  ) , noheader 
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
end


*capture program drop ky_est_5
program define ky_est_5, rclass
syntax , [RELiability pr_t pr_j pr_sr pr_all]
	//////////////////////////////////////////
	/// set weights and sample
	if "`e(wtype)'" != "" {
		tempvar wt
		qui gen float `wt' `e(wexp)'
		local wgtexp "[aw=`wt']"
	}
	tempvar touse yh
	qui gen byte `touse' = e(sample)
	qui:count if `touse'
	if `r(N)'==0 {
		qui:replace `touse'=1
	}
	//////////////////////////////////////////	   
	local pi_r "(invlogit(_b[/lpi_r]))"
	local pi_s "(invlogit(_b[/lpi_s]))"
	local pi_w "(invlogit(_b[/lpi_w]))"
	local pi_v "(invlogit(_b[/lpi_v]))"
	if "`reliability'"!="" {
		qui: nlcom  (pi_s:`pi_s') /// 
	   (pi_w:`pi_w') /// 
	   (pi_r:`pi_r') /// 
	   (pi_v:`pi_v') ///
	   (pi_s1:   `pi_s'              ) ///	
	   (pi_s2:(1-`pi_s')*(1-`pi_w')  ) ///	
	   (pi_s3:(1-`pi_s')*   `pi_w'   ) ///	
	   (pi_r1:   `pi_r' *   `pi_v'   ) ///	
	   (pi_r2:   `pi_r' *(1-`pi_v')  ) ///	
	   (pi_r3:(1-`pi_r')             ) ///		   
	   (pi_1:    `pi_r'*   `pi_v'*    `pi_s'              ) ///
	   (pi_2:    `pi_r'*   `pi_v'* (1-`pi_s')*(1-`pi_w')  ) ///
	   (pi_3:    `pi_r'*   `pi_v'* (1-`pi_s')*   `pi_w'   ) ///
	   (pi_4:    `pi_r'*(1-`pi_v')*   `pi_s'              ) ///
	   (pi_5:    `pi_r'*(1-`pi_v')*(1-`pi_s')*(1-`pi_w')  ) ///
	   (pi_6:    `pi_r'*(1-`pi_v')*(1-`pi_s')*   `pi_w'   ) ///
	   (pi_7: (1-`pi_r')*             `pi_s'              ) ///
	   (pi_8: (1-`pi_r')*          (1-`pi_s')*(1-`pi_w')  ) ///
	   (pi_9: (1-`pi_r')*          (1-`pi_s')*   `pi_w'   ) , noheader
	   tempname bpi Vpi
	   	matrix `bpi'=r(b)
		matrix `Vpi'=r(V)	 
		
		display as result _n "Model structure:"
		display as result "Survey with RTM error and contamination and" _n "Admin data with RTM error and Mismatch" _n
		display as text "Pr of correctly reporting data  pi_s: "  as result %7.4f `bpi'[1,1]
		display as text "Pr of contamination             pi_w: "  as result %7.4f `bpi'[1,2]
		display as text "Pr of correctly match           pi_r: "  as result %7.4f `bpi'[1,3]
		display as text "Pr of admin data w/o  RTM error pi_v: "  as result %7.4f `bpi'[1,4]
		display as result _n "Data TYPE for R"   _n
		display as text "Type I  : r_i = e_i                             " _n "with pr     pi_r *   pi_v : "  as result %7.4f `bpi'[1,8]
		display as text "Type II : r_i = e_i+rho_r*[e_i-E(e_i|X)]+v_i    " _n "with pr     pi_r *(1-pi_v): "  as result %7.4f `bpi'[1,9] 
		display as text "Type III: r_i = t_i                             " _n "with pr (1- pi_r)         : "  as result %7.4f `bpi'[1,10] _n
		display as result "Data TYPE for S"   _n
		display as text "Type I  : s_i = e_i                             " _n "with pr     pi_s          : "  as result %7.4f `bpi'[1,5]
		display as text "Type II : s_i = e_i+rho_s*[e_i-E(e_i|X)]+n_i    " _n "with pr (1- pi_s)*(1-pi_w): "  as result %7.4f `bpi'[1,6]
		display as text "Type III: s_i = e_i+rho_s*[e_i-E(e_i|X)]+n_i+w_i" _n "with pr (1- pi_s)*   pi_w : "  as result %7.4f `bpi'[1,7] _n
		display as result "Class probabilities" _n
		display as text "Pr R type I   & S Type I  : "  as result %7.4f `bpi'[1,11]
		display as text "Pr R type I   & S Type II : "  as result %7.4f `bpi'[1,12]
		display as text "Pr R type I   & S Type III: "  as result %7.4f `bpi'[1,13]
		display as text "Pr R type II  & S Type I  : "  as result %7.4f `bpi'[1,14]
		display as text "Pr R type II  & S Type II : "  as result %7.4f `bpi'[1,15]
		display as text "Pr R type II  & S Type III: "  as result %7.4f `bpi'[1,16]
		display as text "Pr R type III & S Type I  : "  as result %7.4f `bpi'[1,17]
		display as text "Pr R type III & S Type II : "  as result %7.4f `bpi'[1,18]
		display as text "Pr R type III & S Type III: "  as result %7.4f `bpi'[1,19]
		qui {
			tempvar  _muex _munx _muwx  _muvx _mutx 
			tempvar  _sig2_e _sig2_n _sig2_w _sig2_v _sig2_t 
			tempvar  _rho_s _rho_r
			predictnl double `_muex'  =predict(mean_e)
			predictnl double `_munx'  =predict(mean_n)
			predictnl double `_muwx'  =predict(mean_w)
			predictnl double `_muvx'  =predict(mean_v)
			predictnl double `_mutx'  =predict(mean_t)
			predictnl double `_sig2_e'=predict(sig_e)^2
			predictnl double `_sig2_n'=predict(sig_n)^2
			predictnl double `_sig2_w'=predict(sig_w)^2
			predictnl double `_sig2_v'=predict(sig_v)^2
			predictnl double `_sig2_t'=predict(sig_t)^2
			predictnl double `_rho_s' =predict(rho_s)   
			predictnl double `_rho_r' =predict(rho_r)
		 
			// For Reliability we need two moments Covariance and Variance:
			tempname _mn _cv
			qui:tabstat `_muex' `_munx' `_muwx' `_muvx' `_mutx' if `touse' `wgtexp', save
			matrix `_mn'=r(StatTotal)
			qui:corr `_muex' `_munx' `_muwx' `_muvx' `_mutx' if `touse' `wgtexp',  cov
			matrix `_cv'=r(C)
			** Required moments
			local _mue 	  (`_mn'[1,1])
			local _mun 	  (`_mn'[1,2])
			local _muw 	  (`_mn'[1,3])
			local _muv 	  (`_mn'[1,4])
			local _mut 	  (`_mn'[1,5])
			local _vare   (`_sig2_e'+`_cv'[1,1])
			local _varn   (`_sig2_n'+`_cv'[2,2])
			local _varw   (`_sig2_w'+`_cv'[3,3])
			local _varv   (`_sig2_v'+`_cv'[4,4])
			local _vart   (`_sig2_t'+`_cv'[5,5])
			local _varex  (`_cv'[1,1])
			local _varnx  (`_cv'[2,2])
			local _varwx  (`_cv'[3,3])
			local _varvx  (`_cv'[4,4])
			local _vartx  (`_cv'[5,5])
			***
			local _coven  (`_cv'[1,2])
			local _covew  (`_cv'[1,3])
			local _covev  (`_cv'[1,4])
			local _covet  (`_cv'[1,5])
			***
			local _covnw  (`_cv'[2,3])
			local _covnv  (`_cv'[2,4])
			local _covnt  (`_cv'[2,5])
			***
			local _covwv  (`_cv'[3,4])
			local _covwt  (`_cv'[3,5])
			***
			local _covvt  (`_cv'[4,5])
			
			** Var by type
			local var_s1 (`_vare'                                             									+((1-`pi_s')*`_mun'    +`pi_w'*(1-`pi_s') *`_muw')^2)
			local var_s2 (`_varex' + (1+ `_rho_s' )^2*`_sig2_e'+`_varn'		   +2*`_coven'     		            +(  -`pi_s' *`_mun'    +`pi_w'*(1-`pi_s') *`_muw')^2)
			local var_s3 (`_varex' + (1+ `_rho_s' )^2*`_sig2_e'+`_varn'+`_varw'+2*`_coven'+2*`_covew'+2*`_covnw'+(  -`pi_s' *`_mun'+(-1+`pi_w'*(1-`pi_s'))*`_muw')^2)

			local var_r1 (               `_vare'                                           +((1-`pi_r')*(`_mue'-`_mut')+(0-`pi_r'*(1-`pi_v'))*`_muv')^2)
			local var_r2 (`_varex' + (1+ `_rho_r' )^2*`_sig2_e'+`_varv'        +2*`_covev' +((1-`pi_r')*(`_mue'-`_mut')+(1-`pi_r'*(1-`pi_v'))*`_muv')^2)
			local var_r3 (`_vart'                                                          +(( -`pi_r')*(`_mue'-`_mut')+(0-`pi_r'*(1-`pi_v'))*`_muv')^2)
			tempvar vs cv_es vr cv_er
			gen double `vs'=`pi_s'*`var_s1'+(1-`pi_w')*(1-`pi_s')*`var_s2'+`pi_w' *(1-`pi_s')*`var_s3'
			gen double `cv_es'=`_vare'+ ///
							   (1-`pi_s')*`_rho_s'*`_sig2_e'+ ///
							   (1-`pi_s')*`_coven'+ ///
							   (1-`pi_s')*`pi_w'*`_covew'
							   
			gen double `vr'=`pi_r'*`pi_v'*`var_r1'+(`pi_r')*(1-`pi_v')*`var_r2'+(1-`pi_r')*`var_r3'
			gen double `cv_er'=`pi_r'*`_vare'+ ///
							   `pi_r'*(1-`pi_v')*`_rho_r'*`_sig2_e'+ ///
							   `pi_r'*(1-`pi_v')*`_covev'+ ///
							   (1-`pi_r')*`_covet'				   
			tempvar kappa_s kappa_r
			gen double `kappa_r'=`cv_er'/`vr'
			gen double `kappa_s'=`cv_es'/`vs'
			tempvar kappa2_s kappa2_r
			gen double `kappa2_r'=`cv_er'^2/(`vr'*`_vare')
			gen double `kappa2_s'=`cv_es'^2/(`vs'*`_vare')
		}
		
		display _n as result "Summary Moments Statistics"  
				
		sum `_sig2_e' if `touse' `wgtexp', meanonly
		local __sig2_e=r(mean)
		sum `_sig2_n' if `touse' `wgtexp', meanonly
		local __sig2_n=r(mean)
		sum `_sig2_w' if `touse' `wgtexp', meanonly
		local __sig2_w=r(mean)
		sum `_sig2_v' if `touse' `wgtexp', meanonly
		local __sig2_v=r(mean)
		sum `_sig2_t' if `touse' `wgtexp', meanonly
		local __sig2_t=r(mean)
		local _vare   (`__sig2_e'+`_cv'[1,1])
		local _varn   (`__sig2_n'+`_cv'[2,2])
		local _varw   (`__sig2_w'+`_cv'[3,3])
		local _varv   (`__sig2_v'+`_cv'[4,4])
		local _vart   (`__sig2_t'+`_cv'[5,5])
		tempname mmsum
		
		matrix `mmsum'=[`_mue'  ,  `_vare' ,  `_varex' ,   `__sig2_e' \ ///
		                `_mun'  ,  `_varn' ,  `_varnx' ,   `__sig2_n' \ ///
						`_muw'  ,  `_varw' ,  `_varwx' ,   `__sig2_w' \ ///
						`_muv'  ,  `_varv' ,  `_varvx' ,   `__sig2_v' \ ///
						`_mut'  ,  `_vart' ,  `_vartx' ,   `__sig2_t' ]
		matrix colname `mmsum' = E(x_i)   "V(x_i)="   V(E(x_i|X))  Sig_x^2		    
		matrix rowname `mmsum' = e_i n_i w_i v_i t_i 
		matrix list  `mmsum', forma(%6.4f) nohead
		
		qui:tabstat `vr' `cv_er' `kappa_r' `kappa2_r' `vs' `cv_es' `kappa_s' `kappa2_s' if `touse' `wgtexp' ,save
		tempvar _mnres
		matrix `_mnres'=r(StatTotal)
		matrix `_mnres'[1,3]=`_mnres'[1,2]/`_mnres'[1,1]
		matrix `_mnres'[1,4]=`_mnres'[1,2]^2/(`_mnres'[1,1]*`_vare')
		matrix `_mnres'[1,7]=`_mnres'[1,6]/`_mnres'[1,5]
		matrix `_mnres'[1,8]=`_mnres'[1,6]^2/(`_mnres'[1,5]*`_vare')		
		display  _n as result "Reliability Statistics: R"  _n
		display as text "Var(r_i)     " as result %7.4f `_mnres'[1,1]
		display as text "Cov(r_i,e_i) " as result %7.4f `_mnres'[1,2]
		display as text "Reliability  " as result %7.4f `_mnres'[1,3]
		display as text "Reliability 2" as result %7.4f `_mnres'[1,4]
		display  _n as result "Reliability Statistics: S"  _n
		display as text "Var(s_i)     " as result %7.4f `_mnres'[1,5]
		display as text "Cov(s_i,e_i) " as result %7.4f `_mnres'[1,6]
		display as text "Reliability  " as result %7.4f `_mnres'[1,7]
		display as text "Reliability 2" as result %7.4f `_mnres'[1,8]
		
		local coln:colnames `bpi'
		foreach i of local coln {
			local _cnt=`_cnt'+1
			return scalar `i' =`bpi'[1,`_cnt'] 
		}
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'
		matrix `_mnres'=`_mnres'[1,1..4] \ `_mnres'[1,5..8]
		matrix colname `_mnres' = "Var" "Cov" "Rel1" "Rel2"
		matrix rowname `_mnres' = R S
		return scalar rel_r=`_mnres'[1,3]
		return scalar rel_s=`_mnres'[2,3]
		return scalar rel2_r=`_mnres'[1,4]
		return scalar rel2_s=`_mnres'[2,4]
		return matrix rel=`_mnres'
		return matrix mmsum=`mmsum'
	}
	
	else if "`pr_t'" !="" {
	    nlcom  (pi_s:`pi_s') /// 
			   (pi_r:`pi_r') /// 
			   (pi_w:`pi_w') /// 
			   (pi_v:`pi_v') , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
	else if "`pr_j'"!="" {
	    nlcom  (pi_1:    `pi_r'*   `pi_v'*    `pi_s'              ) ///
			   (pi_2:    `pi_r'*   `pi_v'* (1-`pi_s')*(1-`pi_w')  ) ///
			   (pi_3:    `pi_r'*   `pi_v'* (1-`pi_s')*   `pi_w'   ) ///
			   (pi_4:    `pi_r'*(1-`pi_v')*   `pi_s'              ) ///
			   (pi_5:    `pi_r'*(1-`pi_v')*(1-`pi_s')*(1-`pi_w')  ) ///
			   (pi_6:    `pi_r'*(1-`pi_v')*(1-`pi_s')*   `pi_w'   ) ///
			   (pi_7: (1-`pi_r')*             `pi_s'              ) ///
			   (pi_8: (1-`pi_r')*          (1-`pi_s')*(1-`pi_w')  ) ///
			   (pi_9: (1-`pi_r')*          (1-`pi_s')*   `pi_w'   ) , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
	else if "`pr_sr'"!="" {
	    nlcom  (pi_s1:   `pi_s'              ) ///	
			   (pi_s2:(1-`pi_s')*(1-`pi_w')  ) ///	
			   (pi_s3:(1-`pi_s')*   `pi_w'   ) ///	
			   (pi_r1:   `pi_r' *   `pi_v'   ) ///	
			   (pi_r2:   `pi_r' *(1-`pi_v')  ) ///	
			   (pi_r3:(1-`pi_r')             ) , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
	else if "`pr_all'"!="" {
		nlcom  (pi_r:`pi_r') /// 
			   (pi_s:`pi_s') /// 
			   (pi_w:`pi_w') /// 
			   (pi_v:`pi_v') ///
			   (pi_s1:   `pi_s'              ) ///	
			   (pi_s2:(1-`pi_s')*(1-`pi_w')  ) ///	
			   (pi_s3:(1-`pi_s')*   `pi_w'   ) ///	
			   (pi_r1:   `pi_r' *   `pi_v'   ) ///	
			   (pi_r2:   `pi_r' *(1-`pi_v')  ) ///	
			   (pi_r3:(1-`pi_r')             ) ///		   
			   (pi_1:    `pi_r'*   `pi_v'*    `pi_s'              ) ///
			   (pi_2:    `pi_r'*   `pi_v'* (1-`pi_s')*(1-`pi_w')  ) ///
			   (pi_3:    `pi_r'*   `pi_v'* (1-`pi_s')*   `pi_w'   ) ///
			   (pi_4:    `pi_r'*(1-`pi_v')*   `pi_s'              ) ///
			   (pi_5:    `pi_r'*(1-`pi_v')*(1-`pi_s')*(1-`pi_w')  ) ///
			   (pi_6:    `pi_r'*(1-`pi_v')*(1-`pi_s')*   `pi_w'   ) ///
			   (pi_7: (1-`pi_r')*             `pi_s'              ) ///
			   (pi_8: (1-`pi_r')*          (1-`pi_s')*(1-`pi_w')  ) ///
			   (pi_9: (1-`pi_r')*          (1-`pi_s')*   `pi_w'   ) , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
	
	
end


*capture program drop ky_est_6
program define ky_est_6, rclass
syntax , [RELiability pr_t pr_j pr_sr pr_all]

	//////////////////////////////////////////
	/// set weights and sample
	if "`e(wtype)'" != "" {
		tempvar wt
		qui gen float `wt' `e(wexp)'
		local wgtexp "[aw=`wt']"
	}
	tempvar touse yh
	qui gen byte `touse' = e(sample)
	qui:count if `touse'
	if `r(N)'==0 {
		qui:replace `touse'=1
	}
	//////////////////////////////////////////	   
	local pi_r (invlogit(_b[/lpi_r]))
	local pi_s (invlogit(_b[/lpi_s]))
	local pi_v (invlogit(_b[/lpi_v]))
	if "`reliability'"!="" {
		qui: nlcom  (pi_s:`pi_s') /// 
	   (pi_r:`pi_r') /// 
	   (pi_v:`pi_v') ///
	   (pi_s1:   `pi_s'              ) ///	
	   (pi_s2:(1-`pi_s')             ) ///	
	   (pi_r1:   `pi_r' *   `pi_v'   ) ///	
	   (pi_r2:   `pi_r' *(1-`pi_v')  ) ///	
	   (pi_r3:(1-`pi_r')             ) ///	
	   (pi_1:    `pi_r'*   `pi_v'*    `pi_s' ) ///
	   (pi_2:    `pi_r'*   `pi_v'* (1-`pi_s')) ///
	   (pi_3:    `pi_r'*(1-`pi_v')*   `pi_s' ) ///
	   (pi_4:    `pi_r'*(1-`pi_v')*(1-`pi_s')) ///
	   (pi_5: (1-`pi_r')*             `pi_s' ) ///
	   (pi_6: (1-`pi_r')*          (1-`pi_s')) , noheader
	   tempname bpi Vpi
	   	matrix `bpi'=r(b)
		matrix `Vpi'=r(V)	 
		
		display as result _n "Model structure:"
		display as result "Survey with RTM error and contamination and" _n "Admin data with RTM error and Mismatch" _n
		display as text "Pr of correctly reporting data  pi_s: "  as result %7.4f `bpi'[1,1]
		display as text "Pr of correctly match           pi_r: "  as result %7.4f `bpi'[1,2]
		display as text "Pr of admin data with RTM error pi_v: "  as result %7.4f `bpi'[1,3]
		display  as result _n "Data TYPE for R"   _n
		display as text "Type I  : r_i = e_i                             " _n "with pr     pi_r *   pi_v : "  as result %7.4f `bpi'[1,6]
		display as text "Type II : r_i = e_i+rho_r*[e_i-E(e_i|X)]+v_i    " _n "with pr     pi_r *(1-pi_v): "  as result %7.4f `bpi'[1,7] 
		display as text "Type III: r_i = t_i                             " _n "with pr (1- pi_r)         : "  as result %7.4f `bpi'[1,8] _n
		display  as result "Data TYPE for S"   _n
		display as text "Type I  : s_i = e_i                             " _n "with pr     pi_s          : "  as result %7.4f `bpi'[1,4]
		display as text "Type II : s_i = e_i+rho_s*[e_i-E(e_i|X)]+n_i    " _n "with pr (1- pi_s)         : "  as result %7.4f `bpi'[1,5]
		display as result "Class probabilities" _n
		display as text "Pr R type I   & S Type I  : "  as result %7.4f `bpi'[1,9]
		display as text "Pr R type I   & S Type II : "  as result %7.4f `bpi'[1,10]
		display as text "Pr R type II  & S Type I  : "  as result %7.4f `bpi'[1,11]
		display as text "Pr R type II  & S Type II : "  as result %7.4f `bpi'[1,12]
		display as text "Pr R type III & S Type I  : "  as result %7.4f `bpi'[1,13]
		display as text "Pr R type III & S Type II : "  as result %7.4f `bpi'[1,14]
		qui {
			tempvar  _muex _munx  _muvx _mutx 
			tempvar  _sig2_e _sig2_n _sig2_v _sig2_t 
			tempvar  _rho_s _rho_r
			predictnl double `_muex'  =predict(mean_e)
			predictnl double `_munx'  =predict(mean_n)
			predictnl double `_muvx'  =predict(mean_v)
			predictnl double `_mutx'  =predict(mean_t)
			predictnl double `_sig2_e'=predict(sig_e)^2
			predictnl double `_sig2_n'=predict(sig_n)^2
			predictnl double `_sig2_v'=predict(sig_v)^2
			predictnl double `_sig2_t'=predict(sig_t)^2
			predictnl double `_rho_s' =predict(rho_s)   
			predictnl double `_rho_r' =predict(rho_r)
		 
			// For Reliability we need two moments Covariance and Variance:
			tempname _mn _cv
			qui:tabstat `_muex' `_munx' `_muvx' `_mutx' if `touse' `wgtexp', save
			matrix `_mn'=r(StatTotal)
			qui:corr    `_muex' `_munx' `_muvx' `_mutx' if `touse' `wgtexp',  cov
			matrix `_cv'=r(C)
			** Required moments
			local _mue 	  (`_mn'[1,1])
			local _mun 	  (`_mn'[1,2])
			local _muv 	  (`_mn'[1,3])
			local _mut 	  (`_mn'[1,4])
			local _vare   (`_sig2_e'+`_cv'[1,1])
			local _varn   (`_sig2_n'+`_cv'[2,2])
			local _varv   (`_sig2_v'+`_cv'[3,3])
			local _vart   (`_sig2_t'+`_cv'[4,4])
			local _varex  (`_cv'[1,1])
			local _varnx  (`_cv'[2,2])
			local _varvx  (`_cv'[3,3])
			local _vartx  (`_cv'[4,4])
			***
			local _coven  (`_cv'[1,2])
			local _covev  (`_cv'[1,3])
			local _covet  (`_cv'[1,4])
			***
			local _covnv  (`_cv'[2,3])
			local _covnt  (`_cv'[2,4])
			***
			local _covvt  (`_cv'[3,4])
			
			** Var by type
			local var_s1 (`_vare'                                             +((1-`pi_s')*`_mun')^2)
			local var_s2 (`_varex' + (1+ `_rho_s' )^2*`_sig2_e'+`_varn'+2*`_coven'+(`pi_s'*`_mun')^2)
			
			local var_r1 (`_vare'                                                   +((1-`pi_v'*`pi_r')*`_muv' +(1-`pi_r')*(`_mut'-`_mue'-`_muv'))^2)
			local var_r2 (`_varex' + (1+ `_rho_r' )^2*`_sig2_e'+`_varv' +2*`_covev' +(( -`pi_v'*`pi_r')*`_muv' +(1-`pi_r')*(`_mut'-`_mue'-`_muv'))^2)
			local var_r3 (`_vart'                                                   +(( -`pi_v'*`pi_r')*`_muv'    -`pi_r' *(`_mut'-`_mue'-`_muv'))^2)
			
			tempvar vs cv_es vr cv_er
			gen double `vs'=`pi_s'*`var_s1'+(1-`pi_s')*`var_s2'
			gen double `cv_es'=`_vare'+ ///
							   (1-`pi_s')*`_rho_s'*`_sig2_e'+ ///
							   (1-`pi_s')*`_coven'
							   
			gen double `vr'=`pi_r'*`pi_v'*`var_r1'+(`pi_r')*(1-`pi_v')*`var_r2'+(1-`pi_r')*`var_r3'
			gen double `cv_er'=`pi_r'*`_vare'+ ///
							   `pi_r'*(1-`pi_v')*`_rho_r'*`_sig2_e'+ ///
							   `pi_r'*(1-`pi_v')*`_covev'+ ///
							   (1-`pi_r')*`_covet'				   
			tempvar kappa_s kappa_r
			gen double `kappa_r'=`cv_er'/`vr'
			gen double `kappa_s'=`cv_es'/`vs'
			tempvar kappa2_s kappa2_r
			gen double `kappa2_r'=`cv_er'^2/(`vr'*`_vare')
			gen double `kappa2_s'=`cv_es'^2/(`vs'*`_vare')
		}
		
		display _n as result "Summary Moments Statistics"  
				
		sum `_sig2_e' if `touse' `wgtexp', meanonly
		local __sig2_e=r(mean)
		sum `_sig2_n' if `touse' `wgtexp', meanonly
		local __sig2_n=r(mean)
		sum `_sig2_v' if `touse' `wgtexp', meanonly
		local __sig2_v=r(mean)
		sum `_sig2_t' if `touse' `wgtexp', meanonly
		local __sig2_t=r(mean)
		local _vare   (`__sig2_e'+`_cv'[1,1])
		local _varn   (`__sig2_n'+`_cv'[2,2])
		local _varv   (`__sig2_v'+`_cv'[3,3])
		local _vart   (`__sig2_t'+`_cv'[4,4])
		tempname mmsum
		
		matrix `mmsum'=[`_mue'  ,  `_vare' ,  `_varex' ,   `__sig2_e' \ ///
		                `_mun'  ,  `_varn' ,  `_varnx' ,   `__sig2_n' \ ///
						`_muv'  ,  `_varv' ,  `_varvx' ,   `__sig2_v' \ ///
						`_mut'  ,  `_vart' ,  `_vartx' ,   `__sig2_t' ]
		matrix colname `mmsum' = E(x_i)   "V(x_i)="   V(E(x_i|X))  Sig_x^2		    
		matrix rowname `mmsum' = e_i n_i v_i t_i 
		matrix list  `mmsum', forma(%6.4f) nohead
		qui:tabstat `vr' `cv_er' `kappa_r' `kappa2_r' `vs' `cv_es' `kappa_s' `kappa2_s' if `touse' `wgtexp' ,save
		tempvar _mnres
		matrix `_mnres'=r(StatTotal)
		matrix `_mnres'[1,3]=`_mnres'[1,2]/`_mnres'[1,1]
		matrix `_mnres'[1,4]=`_mnres'[1,2]^2/(`_mnres'[1,1]*`_vare')
		matrix `_mnres'[1,7]=`_mnres'[1,6]/`_mnres'[1,5]
		matrix `_mnres'[1,8]=`_mnres'[1,6]^2/(`_mnres'[1,5]*`_vare')		
		display  _n as result "Reliability Statistics: R"  _n
		display as text "Var(r_i)     " as result %7.4f `_mnres'[1,1]
		display as text "Cov(r_i,e_i) " as result %7.4f `_mnres'[1,2]
		display as text "Reliability  " as result %7.4f `_mnres'[1,3]
		display as text "Reliability 2" as result %7.4f `_mnres'[1,4]
		display  _n as result "Reliability Statistics: S"  _n
		display as text "Var(s_i)     " as result %7.4f `_mnres'[1,5]
		display as text "Cov(s_i,e_i) " as result %7.4f `_mnres'[1,6]
		display as text "Reliability  " as result %7.4f `_mnres'[1,7]
		display as text "Reliability 2" as result %7.4f `_mnres'[1,8]
		local coln:colnames `bpi'
		foreach i of local coln {
			local _cnt=`_cnt'+1
			return scalar `i' =`bpi'[1,`_cnt'] 
		}
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'
		matrix `_mnres'=`_mnres'[1,1..4] \ `_mnres'[1,5..8]
		matrix colname `_mnres' = "Var" "Cov" "Rel1" "Rel2"
		matrix rowname `_mnres' = R S
		return scalar rel_r=`_mnres'[1,3]
		return scalar rel_s=`_mnres'[2,3]
		return scalar rel2_r=`_mnres'[1,4]
		return scalar rel2_s=`_mnres'[2,4]
		return matrix rel=`_mnres'
		return matrix mmsum=`mmsum'	
	}
	else if "`pr_t'"!="" {
	    nlcom  (pi_s:`pi_s') /// 
			   (pi_r:`pi_r') /// 
			   (pi_v:`pi_v') , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
	else if "`pr_j'"!="" {
	    nlcom  (pi_1:    `pi_r'*   `pi_v'*    `pi_s' ) ///
			   (pi_2:    `pi_r'*   `pi_v'* (1-`pi_s')) ///
			   (pi_3:    `pi_r'*(1-`pi_v')*   `pi_s' ) ///
			   (pi_4:    `pi_r'*(1-`pi_v')*(1-`pi_s')) ///
			   (pi_5: (1-`pi_r')*             `pi_s' ) ///
			   (pi_6: (1-`pi_r')*          (1-`pi_s')) , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
	else if "`pr_sr'"!="" {
	    nlcom  (pi_s1:   `pi_s'              ) ///	
			   (pi_s2:(1-`pi_s')             ) ///	
			   (pi_r1:   `pi_r' *   `pi_v'   ) ///	
			   (pi_r2:   `pi_r' *(1-`pi_v')  ) ///	
			   (pi_r3:(1-`pi_r')             ) , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
	else if "`pr_all'"!="" {
	    nlcom  (pi_s:`pi_s') /// 
			   (pi_r:`pi_r') /// 
			   (pi_v:`pi_v') ///
			   (pi_s1:   `pi_s'              ) ///	
			   (pi_s2:(1-`pi_s')             ) ///	
			   (pi_r1:   `pi_r' *   `pi_v'   ) ///	
			   (pi_r2:   `pi_r' *(1-`pi_v')  ) ///	
			   (pi_r3:(1-`pi_r')             ) ///	
			   (pi_1:    `pi_r'*   `pi_v'*    `pi_s' ) ///
			   (pi_2:    `pi_r'*   `pi_v'* (1-`pi_s')) ///
			   (pi_3:    `pi_r'*(1-`pi_v')*   `pi_s' ) ///
			   (pi_4:    `pi_r'*(1-`pi_v')*(1-`pi_s')) ///
			   (pi_5: (1-`pi_r')*             `pi_s' ) ///
			   (pi_6: (1-`pi_r')*          (1-`pi_s')) , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
end

*capture program drop ky_est_7
program define ky_est_7, rclass
syntax , [RELiability pr_t pr_j pr_sr pr_all]
	//////////////////////////////////////////
	/// set weights and sample
	if "`e(wtype)'" != "" {
		tempvar wt
		qui gen float `wt' `e(wexp)'
		local wgtexp "[aw=`wt']"
	}
	tempvar touse yh
	qui gen byte `touse' = e(sample)
	qui:count if `touse'
	if `r(N)'==0 {
		qui:replace `touse'=1
	}
	//////////////////////////////////////////	
	local pi_r "(invlogit(_b[/lpi_r]))"
	local pi_s "(invlogit(_b[/lpi_s]))"
	local pi_w "(invlogit(_b[/lpi_w]))"
	local pi_v "(invlogit(_b[/lpi_v]))"
	
	 
	if "`reliability'"!="" {
		qui:nlcom  (pi_s:`pi_s') (pi_w:`pi_w') (pi_r:`pi_r') ///
	   (pi_s1:   `pi_s'             )  ///	
	   (pi_s2:(1-`pi_s')*(1-`pi_w') )  ///	
	   (pi_s3:(1-`pi_s')*   `pi_w'  )  ///	
	   (pi_r1:   `pi_r'             )  ///
	   (pi_r2:(1-`pi_r')            )  ///
	   (pi_1:    `pi_r' *   `pi_s'             ) ///
	   (pi_2:    `pi_r' *(1-`pi_s')*(1-`pi_w') ) ///
	   (pi_3:    `pi_r' *(1-`pi_s')*   `pi_w'  ) ///
	   (pi_4: (1-`pi_r')*   `pi_s'             ) ///
	   (pi_5: (1-`pi_r')*(1-`pi_s')*(1-`pi_w') ) ///
	   (pi_6: (1-`pi_r')*(1-`pi_s')*   `pi_w'  ) , noheader 		
        tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)	
		display  as result "{bf:Model structure:}"
		display  as result "{bf:Survey with RTM error and contamination and Admin data with Mismatch}"  _n
		display as text "Pr of correctly reporting data pi_s: " as result  %7.4f `bpi'[1,1]
		display as text "Pr of contamination            pi_w: " as result  %7.4f `bpi'[1,2]
		display as text "Pr of correctly match          pi_r: " as result  %7.4f `bpi'[1,3]
		display as result _n "Data TYPE for R"   _n
		display as text "Type I  : r_i = e_i                                 " _n "with p =     pi_r          :" as result %7.4f `bpi'[1,7]
		display as text "Type II : r_i = t_i                                 " _n "with p = (1- pi_r)         :" as result %7.4f `bpi'[1,8] _n 
		display as result "Data TYPE for S"   _n
		display as text "Type I  : s_i = e_i                                 " _n "with p =     pi_s          :" as result %7.4f `bpi'[1,4]
		display as text "Type II : s_i = e_i+rho_s*[e_i-E(e_i|X)]+n_i    " _n "with pr  (1- pi_s)*(1-pi_w):" as result %7.4f `bpi'[1,5]
		display as text "Type III: s_i = e_i+rho_s*[e_i-E(e_i|X)]+n_i+w_i" _n "with pr  (1- pi_s)*   pi_w :" as result %7.4f `bpi'[1,6] _n
		display as result  "{bf:Class probabilities}" _n
		display as text "Pr R type I  & S Type I  : " as result %7.4f `bpi'[1,9]
		display as text "Pr R type I  & S Type II : " as result %7.4f `bpi'[1,10]
		display as text "Pr R type I  & S Type III: " as result %7.4f `bpi'[1,11]
		display as text "Pr R type II & S Type I  : " as result %7.4f `bpi'[1,12]
		display as text "Pr R type II & S Type II : " as result %7.4f `bpi'[1,13]
		display as text "Pr R type II & S Type III: " as result %7.4f `bpi'[1,14]
		qui {
			tempvar  _muex   _munx   _muwx   _mutx 
			tempvar  _sig2_e _sig2_n _sig2_w _sig2_t _rho_s _rho_w
			predictnl double `_muex'  =predict(mean_e)
			predictnl double `_munx'  =predict(mean_n)
			predictnl double `_muwx'  =predict(mean_w)
			predictnl double `_mutx'  =predict(mean_t)
			predictnl double `_sig2_e'=predict(sig_e)^2
			predictnl double `_sig2_n'=predict(sig_n)^2
			predictnl double `_sig2_w'=predict(sig_w)^2
			predictnl double `_sig2_t'=predict(sig_t)^2
			predictnl double `_rho_s' =predict(rho_s)   
			predictnl double `_rho_w' =predict(rho_w)  


			// For Reliability we need two moments Covariance and Variance:
			tempname _mn _cv
			qui:tabstat `_muex' `_munx' `_muwx' `_muvx' `_mutx' if `touse' `wgtexp', save
			matrix `_mn'=r(StatTotal)
			qui:corr `_muex' `_munx' `_muwx'   `_mutx' if `touse' `wgtexp',  cov
			matrix `_cv'=r(C)
			** Required moments
			local _mue 	  (`_mn'[1,1])
			local _mun 	  (`_mn'[1,2])
			local _muw 	  (`_mn'[1,3])
			local _mut 	  (`_mn'[1,4])
			local _vare   (`_sig2_e'+`_cv'[1,1])
			local _varn   (`_sig2_n'+`_cv'[2,2])
			local _varw   (`_sig2_w'+`_cv'[3,3])
			local _vart   (`_sig2_t'+`_cv'[4,4])
			local _varex  (`_cv'[1,1])
			local _varnx  (`_cv'[2,2])
			local _varwx  (`_cv'[3,3])
			local _vartx  (`_cv'[4,4])
			***
			local _coven  (`_cv'[1,2])
			local _covew  (`_cv'[1,3])
			local _covet  (`_cv'[1,4])
			***
			local _covnw  (`_cv'[2,3])
			local _covnt  (`_cv'[2,4])
			***
			local _covwt  (`_cv'[3,4])
		    			
			** Var by type
			local var_s1 (`_vare'                                             								                                                  	  +((1-`pi_s')*`_mun'    +`pi_w'*(1-`pi_s') *`_muw')^2)
			local var_s2 (`_varex' + (1+ `_rho_s' )^2*`_sig2_e'+`_varn'		   +2*`_coven'     		                                                              +(  -`pi_s' *`_mun'    +`pi_w'*(1-`pi_s') *`_muw')^2)
			local var_s3 (`_varex' + (1+ `_rho_s' )^2*`_sig2_e'+`_varn'+`_varw'+2*`_coven'+2*`_covew'+2*`_covnw'+2*(1+`_rho_s')*`_rho_w'*sqrt(`_sig2_w'*`_sig2_e')+(  -`pi_s' *`_mun'+(-1+`pi_w'*(1-`pi_s'))*`_muw')^2)
			
			local var_r1 ( `_vare' +( (1-`pi_r')*(`_mut'-`_mue'))^2)
			local var_r2 ( `_vart' +(   -`pi_r' *(`_mut'-`_mue'))^2)
			tempvar vs cv_es vr cv_er
			gen double `vs'=`pi_s'*`var_s1'+(1-`pi_w')*(1-`pi_s')*`var_s2'+`pi_w' *(1-`pi_s')*`var_s3'
			gen double `cv_es'=`_vare'+ ///
							   (1-`pi_s')*`_rho_s'*`_sig2_e'+ ///
							   (1-`pi_s')*`_coven'+ ///
							   (1-`pi_s')*`pi_w'*(`_covew'+`_rho_w'*sqrt(`_sig2_w'*`_sig2_e'))
			gen double `vr'=`pi_r'*`var_r1'+(1-`pi_r')*`var_r2'
			gen double `cv_er'=   `pi_r' *`_vare'+ ///
							   (1-`pi_r')*`_covet'				   
			tempvar kappa_s kappa_r
			gen double `kappa_r'=`cv_er'/`vr'
			gen double `kappa_s'=`cv_es'/`vs'
			tempvar kappa2_s kappa2_r
			gen double `kappa2_r'=`cv_er'^2/(`vr'*`_vare')
			gen double `kappa2_s'=`cv_es'^2/(`vs'*`_vare')
		}
		
		display  _n as result  "Summary Moments Statistics"  
		
		sum `_sig2_e' if `touse' `wgtexp', meanonly
		local __sig2_e=r(mean)
		sum `_sig2_n' if `touse' `wgtexp', meanonly
		local __sig2_n=r(mean)
		sum `_sig2_w' if `touse' `wgtexp', meanonly
		local __sig2_w=r(mean)
		sum `_sig2_t' if `touse' `wgtexp', meanonly
		local __sig2_t=r(mean)
		local _vare   (`__sig2_e'+`_cv'[1,1])
		local _varn   (`__sig2_n'+`_cv'[2,2])
		local _varw   (`__sig2_w'+`_cv'[3,3])
		local _vart   (`__sig2_t'+`_cv'[4,4])
		tempname mmsum
		
		matrix `mmsum'=[`_mue'  ,  `_vare' ,  `_varex' ,   `__sig2_e' \ ///
		                  `_mun'  ,  `_varn' ,  `_varnx' ,   `__sig2_n' \ ///
						  `_muw'  ,  `_varw' ,  `_varwx' ,   `__sig2_w' \ ///
						  `_mut'  ,  `_vart' ,  `_vartx' ,   `__sig2_t' ]
		matrix colname `mmsum' = E(x_i)   "V(x_i)="   V(E(x_i|X))  Sig_x^2		    
		matrix rowname `mmsum' = e_i n_i w_i t_i 
		matrix list  `mmsum', forma(%6.4f) nohead

qui:tabstat `vr' `cv_er' `kappa_r' `kappa2_r' `vs' `cv_es' `kappa_s' `kappa2_s' if `touse' `wgtexp' ,save
		tempvar _mnres
		matrix `_mnres'=r(StatTotal)
		matrix `_mnres'[1,3]=`_mnres'[1,2]/`_mnres'[1,1]
		matrix `_mnres'[1,4]=`_mnres'[1,2]^2/(`_mnres'[1,1]*`_vare')
		matrix `_mnres'[1,7]=`_mnres'[1,6]/`_mnres'[1,5]
		matrix `_mnres'[1,8]=`_mnres'[1,6]^2/(`_mnres'[1,5]*`_vare')		
		display  _n as result "Reliability Statistics: R"  _n
		display as text "Var(r_i)     " as result %7.4f `_mnres'[1,1]
		display as text "Cov(r_i,e_i) " as result %7.4f `_mnres'[1,2]
		display as text "Reliability  " as result %7.4f `_mnres'[1,3]
		display as text "Reliability 2" as result %7.4f `_mnres'[1,4]
		display  _n as result "Reliability Statistics: S"  _n
		display as text "Var(s_i)     " as result %7.4f `_mnres'[1,5]
		display as text "Cov(s_i,e_i) " as result %7.4f `_mnres'[1,6]
		display as text "Reliability  " as result %7.4f `_mnres'[1,7]
		display as text "Reliability 2" as result %7.4f `_mnres'[1,8]
		local coln:colnames `bpi'
		foreach i of local coln {
			local _cnt=`_cnt'+1
			return scalar `i' =`bpi'[1,`_cnt'] 
		}
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'
		matrix `_mnres'=`_mnres'[1,1..4] \ `_mnres'[1,5..8]
		matrix colname `_mnres' = "Var" "Cov" "Rel1" "Rel2"
		matrix rowname `_mnres' = R S
		return scalar rel_r=`_mnres'[1,3]
		return scalar rel_s=`_mnres'[2,3]
		return scalar rel2_r=`_mnres'[1,4]
		return scalar rel2_s=`_mnres'[2,4]
		return matrix rel=`_mnres'
		return matrix mmsum=`mmsum'
	}
	
	else if "`pr_t'"!="" {
	    nlcom  (pi_s:`pi_s') /// 
			   (pi_w:`pi_w') /// 
			   (pi_r:`pi_r') , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'
	}
	else if "`pr_j'"!="" {
	    nlcom  (pi_1:    `pi_r' *   `pi_s'             ) ///
			   (pi_2:    `pi_r' *(1-`pi_s')*(1-`pi_w') ) ///
			   (pi_3:    `pi_r' *(1-`pi_s')*   `pi_w'  ) ///
			   (pi_4: (1-`pi_r')*   `pi_s'             ) ///
			   (pi_5: (1-`pi_r')*(1-`pi_s')*(1-`pi_w') ) ///
			   (pi_6: (1-`pi_r')*(1-`pi_s')*   `pi_w'  ), noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'
	}
	else if "`pr_sr'"!="" {
	    nlcom  (pi_s1:   `pi_s'             )  ///	
			   (pi_s2:(1-`pi_s')*(1-`pi_w') )  ///	
			   (pi_s3:(1-`pi_s')*   `pi_w'  )  ///	
			   (pi_r1:   `pi_r'             )  ///
			   (pi_r2:(1-`pi_r')            )  , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
	else if "`pr_all'"!="" {
		nlcom  (pi_s:`pi_s') (pi_w:`pi_w') (pi_r:`pi_r') ///
			   (pi_s1:   `pi_s'             )  ///	
			   (pi_s2:(1-`pi_s')*(1-`pi_w') )  ///	
			   (pi_s3:(1-`pi_s')*   `pi_w'  )  ///	
			   (pi_r1:   `pi_r'             )  ///
			   (pi_r2:(1-`pi_r')            )  ///
			   (pi_1:    `pi_r' *   `pi_s'             ) ///
			   (pi_2:    `pi_r' *(1-`pi_s')*(1-`pi_w') ) ///
			   (pi_3:    `pi_r' *(1-`pi_s')*   `pi_w'  ) ///
			   (pi_4: (1-`pi_r')*   `pi_s'             ) ///
			   (pi_5: (1-`pi_r')*(1-`pi_s')*(1-`pi_w') ) ///
			   (pi_6: (1-`pi_r')*(1-`pi_s')*   `pi_w'  ) , noheader 
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
 
end


*capture program drop ky_est_8
program define ky_est_8, rclass
syntax , [RELiability pr_t pr_j pr_sr pr_all]
	//////////////////////////////////////////
	/// set weights and sample
	if "`e(wtype)'" != "" {
		tempvar wt
		qui gen float `wt' `e(wexp)'
		local wgtexp "[aw=`wt']"
	}
	tempvar touse yh
	qui gen byte `touse' = e(sample)
	qui:count if `touse'
	if `r(N)'==0 {
		qui:replace `touse'=1
	}
	//////////////////////////////////////////	
	local pi_r "(invlogit(_b[/lpi_r]))"
	local pi_s "(invlogit(_b[/lpi_s]))"
	local pi_w "(invlogit(_b[/lpi_w]))"
	local pi_v "(invlogit(_b[/lpi_v]))"
	if "`reliability'"!="" {
		qui: nlcom  (pi_s:`pi_s') /// 
	   (pi_w:`pi_w') /// 
	   (pi_r:`pi_r') /// 
	   (pi_v:`pi_v') ///
	   (pi_s1:   `pi_s'              ) ///	
	   (pi_s2:(1-`pi_s')*(1-`pi_w')  ) ///	
	   (pi_s3:(1-`pi_s')*   `pi_w'   ) ///	
	   (pi_r1:   `pi_r' *   `pi_v'   ) ///	
	   (pi_r2:   `pi_r' *(1-`pi_v')  ) ///	
	   (pi_r3:(1-`pi_r')             ) ///		   
	   (pi_1:    `pi_r'*   `pi_v'*    `pi_s'              ) ///
	   (pi_2:    `pi_r'*   `pi_v'* (1-`pi_s')*(1-`pi_w')  ) ///
	   (pi_3:    `pi_r'*   `pi_v'* (1-`pi_s')*   `pi_w'   ) ///
	   (pi_4:    `pi_r'*(1-`pi_v')*   `pi_s'              ) ///
	   (pi_5:    `pi_r'*(1-`pi_v')*(1-`pi_s')*(1-`pi_w')  ) ///
	   (pi_6:    `pi_r'*(1-`pi_v')*(1-`pi_s')*   `pi_w'   ) ///
	   (pi_7: (1-`pi_r')*             `pi_s'              ) ///
	   (pi_8: (1-`pi_r')*          (1-`pi_s')*(1-`pi_w')  ) ///
	   (pi_9: (1-`pi_r')*          (1-`pi_s')*   `pi_w'   ) , noheader
	   tempname bpi Vpi
	   	matrix `bpi'=r(b)
		matrix `Vpi'=r(V)	 
		
		display as result _n "Model structure:"
		display as result "Survey with RTM error and contamination and" _n "Admin data with RTM error and Mismatch" _n
		display as text "Pr of correctly reporting data  pi_s: "  as result %7.4f `bpi'[1,1]
		display as text "Pr of contamination             pi_w: "  as result %7.4f `bpi'[1,2]
		display as text "Pr of correctly match           pi_r: "  as result %7.4f `bpi'[1,3]
		display as text "Pr of admin data w/o  RTM error pi_v: "  as result %7.4f `bpi'[1,4]
		display  as result _n "Data TYPE for R"   _n
		display as text "Type I  : r_i = e_i                             " _n "with pr     pi_r *   pi_v : "  as result %7.4f `bpi'[1,8]
		display as text "Type II : r_i = e_i+rho_r*[e_i-E(e_i|X)]+v_i    " _n "with pr     pi_r *(1-pi_v): "  as result %7.4f `bpi'[1,9] 
		display as text "Type III: r_i = t_i                             " _n "with pr (1- pi_r)         : "  as result %7.4f `bpi'[1,10] _n
		display  as result "Data TYPE for S"   _n
		display as text "Type I  : s_i = e_i                             " _n "with pr     pi_s          : "  as result %7.4f `bpi'[1,5]
		display as text "Type II : s_i = e_i+rho_s*[e_i-E(e_i|X)]+n_i    " _n "with pr (1- pi_s)*(1-pi_w): "  as result %7.4f `bpi'[1,6]
		display as text "Type III: s_i = e_i+rho_s*[e_i-E(e_i|X)]+n_i+w_i" _n "with pr (1- pi_s)*   pi_w : "  as result %7.4f `bpi'[1,7] _n
		display as result "Class probabilities" _n
		display as text "Pr R type I   & S Type I  : "  as result %7.4f `bpi'[1,11]
		display as text "Pr R type I   & S Type II : "  as result %7.4f `bpi'[1,12]
		display as text "Pr R type I   & S Type III: "  as result %7.4f `bpi'[1,13]
		display as text "Pr R type II  & S Type I  : "  as result %7.4f `bpi'[1,14]
		display as text "Pr R type II  & S Type II : "  as result %7.4f `bpi'[1,15]
		display as text "Pr R type II  & S Type III: "  as result %7.4f `bpi'[1,16]
		display as text "Pr R type III & S Type I  : "  as result %7.4f `bpi'[1,17]
		display as text "Pr R type III & S Type II : "  as result %7.4f `bpi'[1,18]
		display as text "Pr R type III & S Type III: "  as result %7.4f `bpi'[1,19]
		qui {
			tempvar  _muex _munx _muwx  _muvx _mutx 
			tempvar  _sig2_e _sig2_n _sig2_w _sig2_v _sig2_t 
			tempvar  _rho_s _rho_r _rho_w
			
			predictnl double `_muex'  =predict(mean_e)
			predictnl double `_munx'  =predict(mean_n)
			predictnl double `_muwx'  =predict(mean_w)
			predictnl double `_muvx'  =predict(mean_v)
			predictnl double `_mutx'  =predict(mean_t)
			predictnl double `_sig2_e'=predict(sig_e)^2
			predictnl double `_sig2_n'=predict(sig_n)^2
			predictnl double `_sig2_w'=predict(sig_w)^2
			predictnl double `_sig2_v'=predict(sig_v)^2
			predictnl double `_sig2_t'=predict(sig_t)^2
			predictnl double `_rho_s' =predict(rho_s)   
			predictnl double `_rho_r' =predict(rho_r)
			predictnl double `_rho_w' =predict(rho_w)
		 
			// For Reliability we need two moments Covariance and Variance:
			tempname _mn _cv
			qui:tabstat `_muex' `_munx' `_muwx' `_muvx' `_mutx' if `touse' `wgtexp', save
			matrix `_mn'=r(StatTotal)
			qui:corr `_muex' `_munx' `_muwx' `_muvx' `_mutx' if `touse' `wgtexp',  cov
			matrix `_cv'=r(C)
			** Required moments
			local _mue 	  (`_mn'[1,1])
			local _mun 	  (`_mn'[1,2])
			local _muw 	  (`_mn'[1,3])
			local _muv 	  (`_mn'[1,4])
			local _mut 	  (`_mn'[1,5])
			local _vare   (`_sig2_e'+`_cv'[1,1])
			local _varn   (`_sig2_n'+`_cv'[2,2])
			local _varw   (`_sig2_w'+`_cv'[3,3])
			local _varv   (`_sig2_v'+`_cv'[4,4])
			local _vart   (`_sig2_t'+`_cv'[5,5])
			local _varex  (`_cv'[1,1])
			local _varnx  (`_cv'[2,2])
			local _varwx  (`_cv'[3,3])
			local _varvx  (`_cv'[4,4])
			local _vartx  (`_cv'[5,5])
			***
			local _coven  (`_cv'[1,2])
			local _covew  (`_cv'[1,3])
			local _covev  (`_cv'[1,4])
			local _covet  (`_cv'[1,5])
			***
			local _covnw  (`_cv'[2,3])
			local _covnv  (`_cv'[2,4])
			local _covnt  (`_cv'[2,5])
			***
			local _covwv  (`_cv'[3,4])
			local _covwt  (`_cv'[3,5])
			***
			local _covvt  (`_cv'[4,5])
			
			** Var by type
			local var_s1 (`_vare'                                             									                                                  +((1-`pi_s')*`_mun'    +`pi_w'*(1-`pi_s') *`_muw')^2)
			local var_s2 (`_varex' + (1+ `_rho_s' )^2*`_sig2_e'+`_varn'		   +2*`_coven'            		                                                      +(  -`pi_s' *`_mun'    +`pi_w'*(1-`pi_s') *`_muw')^2)
			local var_s3 (`_varex' + (1+ `_rho_s' )^2*`_sig2_e'+`_varn'+`_varw'+2*`_coven'+2*`_covew'+2*`_covnw'+2*(1+`_rho_s')*`_rho_w'*sqrt(`_sig2_w'*`_sig2_e')+(  -`pi_s' *`_mun'+(-1+`pi_w'*(1-`pi_s'))*`_muw')^2)

			local var_r1 (               `_vare'                                           +((1-`pi_v'*`pi_r')*`_muv' +(1-`pi_r')*(`_mut'-`_mue'-`_muv'))^2)
			local var_r2 (`_varex' + (1+ `_rho_r' )^2*`_sig2_e'+`_varv'        +2*`_covev' +(( -`pi_v'*`pi_r')*`_muv' +(1-`pi_r')*(`_mut'-`_mue'-`_muv'))^2)
			local var_r3 (`_vart'                                                          +(( -`pi_v'*`pi_r')*`_muv'    -`pi_r' *(`_mut'-`_mue'-`_muv'))^2)
			
			tempvar vs cv_es vr cv_er
			gen double `vs'=`pi_s'*`var_s1'+(1-`pi_w')*(1-`pi_s')*`var_s2'+`pi_w' *(1-`pi_s')*`var_s3'
 			gen double `cv_es'=`_vare'+ ///
							   (1-`pi_s')*`_rho_s'*`_sig2_e'+ ///
							   (1-`pi_s')*`_coven'+ ///
							   (1-`pi_s')*`pi_w'*(`_covew'+`_rho_w'*sqrt(`_sig2_w'*`_sig2_e'))				   
			gen double `vr'=`pi_r'*`pi_v'*`var_r1'+(`pi_r')*(1-`pi_v')*`var_r2'+(1-`pi_r')*`var_r3'
			gen double `cv_er'=`pi_r'*`_vare'+ ///
							   `pi_r'*(1-`pi_v')*`_rho_r'*`_sig2_e'+ ///
							   `pi_r'*(1-`pi_v')*`_covev'+ ///
							   (1-`pi_r')*`_covet'				   
			tempvar kappa_s kappa_r
			gen double `kappa_r'=`cv_er'/`vr'
			gen double `kappa_s'=`cv_es'/`vs'
			tempvar kappa2_s kappa2_r
			gen double `kappa2_r'=`cv_er'^2/(`vr'*`_vare')
			gen double `kappa2_s'=`cv_es'^2/(`vs'*`_vare')
		}
		
		display _n as result "Summary Moments Statistics"  
				
		sum `_sig2_e' if `touse' `wgtexp', meanonly
		local __sig2_e=r(mean)
		sum `_sig2_n' if `touse' `wgtexp', meanonly
		local __sig2_n=r(mean)
		sum `_sig2_w' if `touse' `wgtexp', meanonly
		local __sig2_w=r(mean)
		sum `_sig2_v' if `touse' `wgtexp', meanonly
		local __sig2_v=r(mean)
		sum `_sig2_t' if `touse' `wgtexp', meanonly
		local __sig2_t=r(mean)
		local _vare   (`__sig2_e'+`_cv'[1,1])
		local _varn   (`__sig2_n'+`_cv'[2,2])
		local _varw   (`__sig2_w'+`_cv'[3,3])
		local _varv   (`__sig2_v'+`_cv'[4,4])
		local _vart   (`__sig2_t'+`_cv'[5,5])
		tempname mmsum
		
		matrix `mmsum'=[`_mue'  ,  `_vare' ,  `_varex' ,   `__sig2_e' \ ///
		                `_mun'  ,  `_varn' ,  `_varnx' ,   `__sig2_n' \ ///
						`_muw'  ,  `_varw' ,  `_varwx' ,   `__sig2_w' \ ///
						`_muv'  ,  `_varv' ,  `_varvx' ,   `__sig2_v' \ ///
						`_mut'  ,  `_vart' ,  `_vartx' ,   `__sig2_t' ]
		matrix colname `mmsum' = E(x_i)   "V(x_i)="   V(E(x_i|X))  Sig_x^2		    
		matrix rowname `mmsum' = e_i n_i w_i v_i t_i 
		matrix list  `mmsum', forma(%6.4f) nohead
		
		qui:tabstat `vr' `cv_er' `kappa_r' `kappa2_r' `vs' `cv_es' `kappa_s' `kappa2_s' if `touse' `wgtexp' ,save
		tempvar _mnres
		matrix `_mnres'=r(StatTotal)
		matrix `_mnres'[1,3]=`_mnres'[1,2]/`_mnres'[1,1]
		matrix `_mnres'[1,4]=`_mnres'[1,2]^2/(`_mnres'[1,1]*`_vare')
		matrix `_mnres'[1,7]=`_mnres'[1,6]/`_mnres'[1,5]
		matrix `_mnres'[1,8]=`_mnres'[1,6]^2/(`_mnres'[1,5]*`_vare')		
		display  _n as result "Reliability Statistics: R"  _n
		display as text "Var(r_i)     " as result %7.4f `_mnres'[1,1]
		display as text "Cov(r_i,e_i) " as result %7.4f `_mnres'[1,2]
		display as text "Reliability  " as result %7.4f `_mnres'[1,3]
		display as text "Reliability 2" as result %7.4f `_mnres'[1,4]
		display  _n as result "Reliability Statistics: S"  _n
		display as text "Var(s_i)     " as result %7.4f `_mnres'[1,5]
		display as text "Cov(s_i,e_i) " as result %7.4f `_mnres'[1,6]
		display as text "Reliability  " as result %7.4f `_mnres'[1,7]
		display as text "Reliability 2" as result %7.4f `_mnres'[1,8]
		
		local coln:colnames `bpi'
		foreach i of local coln {
			local _cnt=`_cnt'+1
			return scalar `i' =`bpi'[1,`_cnt'] 
		}
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'
		matrix `_mnres'=`_mnres'[1,1..4] \ `_mnres'[1,5..8]
		matrix colname `_mnres' = "Var" "Cov" "Rel1" "Rel2"
		matrix rowname `_mnres' = R S
		return scalar rel_r=`_mnres'[1,3]
		return scalar rel_s=`_mnres'[2,3]
		return scalar rel2_r=`_mnres'[1,4]
		return scalar rel2_s=`_mnres'[2,4]
		return matrix rel=`_mnres'
		return matrix mmsum=`mmsum'
	}
	
	else if "`pr_t'" !="" {
	    nlcom  (pi_s:`pi_s') /// 
			   (pi_r:`pi_r') /// 
			   (pi_w:`pi_w') /// 
			   (pi_v:`pi_v') , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
	else if "`pr_j'"!="" {
	    nlcom  (pi_1:    `pi_r'*   `pi_v'*    `pi_s'              ) ///
			   (pi_2:    `pi_r'*   `pi_v'* (1-`pi_s')*(1-`pi_w')  ) ///
			   (pi_3:    `pi_r'*   `pi_v'* (1-`pi_s')*   `pi_w'   ) ///
			   (pi_4:    `pi_r'*(1-`pi_v')*   `pi_s'              ) ///
			   (pi_5:    `pi_r'*(1-`pi_v')*(1-`pi_s')*(1-`pi_w')  ) ///
			   (pi_6:    `pi_r'*(1-`pi_v')*(1-`pi_s')*   `pi_w'   ) ///
			   (pi_7: (1-`pi_r')*             `pi_s'              ) ///
			   (pi_8: (1-`pi_r')*          (1-`pi_s')*(1-`pi_w')  ) ///
			   (pi_9: (1-`pi_r')*          (1-`pi_s')*   `pi_w'   ) , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
	else if "`pr_sr'"!="" {
	    nlcom  (pi_s1:   `pi_s'              ) ///	
			   (pi_s2:(1-`pi_s')*(1-`pi_w')  ) ///	
			   (pi_s3:(1-`pi_s')*   `pi_w'   ) ///	
			   (pi_r1:   `pi_r' *   `pi_v'   ) ///	
			   (pi_r2:   `pi_r' *(1-`pi_v')  ) ///	
			   (pi_r3:(1-`pi_r')             ) , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
	else if "`pr_all'"!="" {
		nlcom  (pi_r:`pi_r') /// 
			   (pi_s:`pi_s') /// 
			   (pi_w:`pi_w') /// 
			   (pi_v:`pi_v') ///
			   (pi_s1:   `pi_s'              ) ///	
			   (pi_s2:(1-`pi_s')*(1-`pi_w')  ) ///	
			   (pi_s3:(1-`pi_s')*   `pi_w'   ) ///	
			   (pi_r1:   `pi_r' *   `pi_v'   ) ///	
			   (pi_r2:   `pi_r' *(1-`pi_v')  ) ///	
			   (pi_r3:(1-`pi_r')             ) ///		   
			   (pi_1:    `pi_r'*   `pi_v'*    `pi_s'              ) ///
			   (pi_2:    `pi_r'*   `pi_v'* (1-`pi_s')*(1-`pi_w')  ) ///
			   (pi_3:    `pi_r'*   `pi_v'* (1-`pi_s')*   `pi_w'   ) ///
			   (pi_4:    `pi_r'*(1-`pi_v')*   `pi_s'              ) ///
			   (pi_5:    `pi_r'*(1-`pi_v')*(1-`pi_s')*(1-`pi_w')  ) ///
			   (pi_6:    `pi_r'*(1-`pi_v')*(1-`pi_s')*   `pi_w'   ) ///
			   (pi_7: (1-`pi_r')*             `pi_s'              ) ///
			   (pi_8: (1-`pi_r')*          (1-`pi_s')*(1-`pi_w')  ) ///
			   (pi_9: (1-`pi_r')*          (1-`pi_s')*   `pi_w'   ) , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
 
end

*capture program drop ky_est_5
program define ky_est_9, rclass
syntax , [RELiability pr_t pr_j pr_sr pr_all]
	//////////////////////////////////////////
	/// set weights and sample
	if "`e(wtype)'" != "" {
		tempvar wt
		qui gen float `wt' `e(wexp)'
		local wgtexp "[aw=`wt']"
	}
	tempvar touse yh
	qui gen byte `touse' = e(sample)
	qui:count if `touse'
	if `r(N)'==0 {
		qui:replace `touse'=1
	}
	//////////////////////////////////////////	   
	local pi_r 1
	local pi_s "(invlogit(_b[/lpi_s]))"
	local pi_w "(invlogit(_b[/lpi_w]))"
	local pi_v "(invlogit(_b[/lpi_v]))"
	if "`reliability'"!="" {
		qui: nlcom  (pi_s:`pi_s') /// 
	   (pi_w:`pi_w') /// 
	   (pi_v:`pi_v') ///
	   (pi_s1:   `pi_s'              ) ///	
	   (pi_s2:(1-`pi_s')*(1-`pi_w')  ) ///	
	   (pi_s3:(1-`pi_s')*   `pi_w'   ) ///	
	   (pi_r1:      `pi_v'   ) ///	
	   (pi_r2:   (1-`pi_v')  ) ///	
	   (pi_1:    `pi_r'*   `pi_v'*    `pi_s'              ) ///
	   (pi_2:    `pi_r'*   `pi_v'* (1-`pi_s')*(1-`pi_w')  ) ///
	   (pi_3:    `pi_r'*   `pi_v'* (1-`pi_s')*   `pi_w'   ) ///
	   (pi_4:    `pi_r'*(1-`pi_v')*   `pi_s'              ) ///
	   (pi_5:    `pi_r'*(1-`pi_v')*(1-`pi_s')*(1-`pi_w')  ) ///
	   (pi_6:    `pi_r'*(1-`pi_v')*(1-`pi_s')*   `pi_w'   ) , noheader
	   tempname bpi Vpi
	   	matrix `bpi'=r(b)
		matrix `Vpi'=r(V)	 
		
		display as result _n "Model structure:"
		display as result "Survey with RTM error and contamination and" _n "Admin data with RTM error and Mismatch" _n
		display as text "Pr of correctly reporting data  pi_s: "  as result %7.4f `bpi'[1,1]
		display as text "Pr of contamination             pi_w: "  as result %7.4f `bpi'[1,2]
		display as text "Pr of admin data w/o  RTM error pi_v: "  as result %7.4f `bpi'[1,3]
		display as result _n "Data TYPE for R"   _n
		display as text "Type I  : r_i = e_i                             " _n "with pr     pi_r *   pi_v : "  as result %7.4f `bpi'[1,7]
		display as text "Type II : r_i = e_i+rho_r*[e_i-E(e_i|X)]+v_i    " _n "with pr     pi_r *(1-pi_v): "  as result %7.4f `bpi'[1,8] _n
		display as result "Data TYPE for S"   _n
		display as text "Type I  : s_i = e_i                             " _n "with pr     pi_s          : "  as result %7.4f `bpi'[1,4]
		display as text "Type II : s_i = e_i+rho_s*[e_i-E(e_i|X)]+n_i    " _n "with pr (1- pi_s)*(1-pi_w): "  as result %7.4f `bpi'[1,5]
		display as text "Type III: s_i = e_i+rho_s*[e_i-E(e_i|X)]+n_i+w_i" _n "with pr (1- pi_s)*   pi_w : "  as result %7.4f `bpi'[1,6] _n
		display as result "Class probabilities" _n
		display as text "Pr R type I   & S Type I  : "  as result %7.4f `bpi'[1, 9]
		display as text "Pr R type I   & S Type II : "  as result %7.4f `bpi'[1,10]
		display as text "Pr R type I   & S Type III: "  as result %7.4f `bpi'[1,11]
		display as text "Pr R type II  & S Type I  : "  as result %7.4f `bpi'[1,12]
		display as text "Pr R type II  & S Type II : "  as result %7.4f `bpi'[1,13]
		display as text "Pr R type II  & S Type III: "  as result %7.4f `bpi'[1,14]
		
		qui {
			tempvar  _muex _munx _muwx  _muvx _mutx 
			tempvar  _sig2_e _sig2_n _sig2_w _sig2_v _sig2_t 
			tempvar  _rho_s _rho_r
			predictnl double `_muex'  =predict(mean_e)
			predictnl double `_munx'  =predict(mean_n)
			predictnl double `_muwx'  =predict(mean_w)
			predictnl double `_muvx'  =predict(mean_v)
			
			predictnl double `_sig2_e'=predict(sig_e)^2
			predictnl double `_sig2_n'=predict(sig_n)^2
			predictnl double `_sig2_w'=predict(sig_w)^2
			predictnl double `_sig2_v'=predict(sig_v)^2
			
			predictnl double `_rho_s' =predict(rho_s)   
			predictnl double `_rho_r' =predict(rho_r)
		 
			// For Reliability we need two moments Covariance and Variance:
			tempname _mn _cv
			qui:tabstat `_muex' `_munx' `_muwx' `_muvx' if `touse' `wgtexp', save
			matrix `_mn'=r(StatTotal)
			qui:corr    `_muex' `_munx' `_muwx' `_muvx' if `touse' `wgtexp',  cov
			matrix `_cv'=r(C)
			** Required moments
			local _mue 	  (`_mn'[1,1])
			local _mun 	  (`_mn'[1,2])
			local _muw 	  (`_mn'[1,3])
			local _muv 	  (`_mn'[1,4])
			
			local _vare   (`_sig2_e'+`_cv'[1,1])
			local _varn   (`_sig2_n'+`_cv'[2,2])
			local _varw   (`_sig2_w'+`_cv'[3,3])
			local _varv   (`_sig2_v'+`_cv'[4,4])
			
			local _varex  (`_cv'[1,1])
			local _varnx  (`_cv'[2,2])
			local _varwx  (`_cv'[3,3])
			local _varvx  (`_cv'[4,4])
			
			***
			local _coven  (`_cv'[1,2])
			local _covew  (`_cv'[1,3])
			local _covev  (`_cv'[1,4])
			
			***
			local _covnw  (`_cv'[2,3])
			local _covnv  (`_cv'[2,4])
			
			***
			local _covwv  (`_cv'[3,4])
			
			***
			
			
			** Var by type
			local var_s1 (`_vare'                                             									+((1-`pi_s')*`_mun'    +`pi_w'*(1-`pi_s') *`_muw')^2)
			local var_s2 (`_varex' + (1+ `_rho_s' )^2*`_sig2_e'+`_varn'		   +2*`_coven'     		            +(  -`pi_s' *`_mun'    +`pi_w'*(1-`pi_s') *`_muw')^2)
			local var_s3 (`_varex' + (1+ `_rho_s' )^2*`_sig2_e'+`_varn'+`_varw'+2*`_coven'+2*`_covew'+2*`_covnw'+(  -`pi_s' *`_mun'+(-1+`pi_w'*(1-`pi_s'))*`_muw')^2)

			local var_r1 (               `_vare'                                           +((1-`pi_r')*(`_mue'-`_mut')+(0-`pi_r'*(1-`pi_v'))*`_muv')^2)
			local var_r2 (`_varex' + (1+ `_rho_r' )^2*`_sig2_e'+`_varv'        +2*`_covev' +((1-`pi_r')*(`_mue'-`_mut')+(1-`pi_r'*(1-`pi_v'))*`_muv')^2)
			
			tempvar vs cv_es vr cv_er
			gen double `vs'=`pi_s'*`var_s1'+(1-`pi_w')*(1-`pi_s')*`var_s2'+`pi_w' *(1-`pi_s')*`var_s3'
			gen double `cv_es'=`_vare'+ ///
							   (1-`pi_s')*`_rho_s'*`_sig2_e'+ ///
							   (1-`pi_s')*`_coven'+ ///
							   (1-`pi_s')*`pi_w'*`_covew'
			
			gen double `vr'=`pi_v'*`var_r1'+(1-`pi_v')*`var_r2'
			gen double `cv_er'=`_vare'+ ///
							   (1-`pi_v')*`_rho_r'*`_sig2_e'+ ///
							   (1-`pi_v')*`_covev'+ ///
							   
			tempvar kappa_s kappa_r
			gen double `kappa_r'=`cv_er'/`vr'
			gen double `kappa_s'=`cv_es'/`vs'
			tempvar kappa2_s kappa2_r
			gen double `kappa2_r'=`cv_er'^2/(`vr'*`_vare')
			gen double `kappa2_s'=`cv_es'^2/(`vs'*`_vare')
		}
		
		display _n as result "Summary Moments Statistics"  
				
		sum `_sig2_e' if `touse' `wgtexp', meanonly
		local __sig2_e=r(mean)
		sum `_sig2_n' if `touse' `wgtexp', meanonly
		local __sig2_n=r(mean)
		sum `_sig2_w' if `touse' `wgtexp', meanonly
		local __sig2_w=r(mean)
		sum `_sig2_v' if `touse' `wgtexp', meanonly
		local __sig2_v=r(mean)
		
		local _vare   (`__sig2_e'+`_cv'[1,1])
		local _varn   (`__sig2_n'+`_cv'[2,2])
		local _varw   (`__sig2_w'+`_cv'[3,3])
		local _varv   (`__sig2_v'+`_cv'[4,4])
		
		tempname mmsum
		
		matrix `mmsum'=[`_mue'  ,  `_vare' ,  `_varex' ,   `__sig2_e' \ ///
		                `_mun'  ,  `_varn' ,  `_varnx' ,   `__sig2_n' \ ///
						`_muw'  ,  `_varw' ,  `_varwx' ,   `__sig2_w' \ ///
						`_muv'  ,  `_varv' ,  `_varvx' ,   `__sig2_v' ]
						
		matrix colname `mmsum' = E(x_i)   "V(x_i)="   "V(E(x_i|X))"  "Sig_x^2"
		matrix rowname `mmsum' = e_i n_i w_i v_i 
		matrix list  `mmsum', forma(%6.4f) nohead
		
		qui:tabstat `vr' `cv_er' `kappa_r' `kappa2_r' `vs' `cv_es' `kappa_s' `kappa2_s' if `touse' `wgtexp' ,save
		tempvar _mnres
		matrix `_mnres'=r(StatTotal)
		matrix `_mnres'[1,3]=`_mnres'[1,2]/`_mnres'[1,1]
		matrix `_mnres'[1,4]=`_mnres'[1,2]^2/(`_mnres'[1,1]*`_vare')
		matrix `_mnres'[1,7]=`_mnres'[1,6]/`_mnres'[1,5]
		matrix `_mnres'[1,8]=`_mnres'[1,6]^2/(`_mnres'[1,5]*`_vare')		
		display  _n as result "Reliability Statistics: R"  _n
		display as text "Var(r_i)     " as result %7.4f `_mnres'[1,1]
		display as text "Cov(r_i,e_i) " as result %7.4f `_mnres'[1,2]
		display as text "Reliability  " as result %7.4f `_mnres'[1,3]
		display as text "Reliability 2" as result %7.4f `_mnres'[1,4]
		display  _n as result "Reliability Statistics: S"  _n
		display as text "Var(s_i)     " as result %7.4f `_mnres'[1,5]
		display as text "Cov(s_i,e_i) " as result %7.4f `_mnres'[1,6]
		display as text "Reliability  " as result %7.4f `_mnres'[1,7]
		display as text "Reliability 2" as result %7.4f `_mnres'[1,8]
		
		local coln:colnames `bpi'
		foreach i of local coln {
			local _cnt=`_cnt'+1
			return scalar `i' =`bpi'[1,`_cnt'] 
		}
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'
		matrix `_mnres'=`_mnres'[1,1..4] \ `_mnres'[1,5..8]
		matrix colname `_mnres' = "Var" "Cov" "Rel1" "Rel2"
		matrix rowname `_mnres' = R S
		return scalar rel_r=`_mnres'[1,3]
		return scalar rel_s=`_mnres'[2,3]
		return scalar rel2_r=`_mnres'[1,4]
		return scalar rel2_s=`_mnres'[2,4]
		return matrix rel=`_mnres'
		return matrix mmsum=`mmsum'
	}
	
	else if "`pr_t'" !="" {
	    nlcom  (pi_s:`pi_s') /// 
			   (pi_w:`pi_w') /// 
			   (pi_v:`pi_v') , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
	else if "`pr_j'"!="" {
	    nlcom  (pi_1:       `pi_v'*    `pi_s'              ) ///
			   (pi_2:       `pi_v'* (1-`pi_s')*(1-`pi_w')  ) ///
			   (pi_3:       `pi_v'* (1-`pi_s')*   `pi_w'   ) ///
			   (pi_4:    (1-`pi_v')*   `pi_s'              ) ///
			   (pi_5:    (1-`pi_v')*(1-`pi_s')*(1-`pi_w')  ) ///
			   (pi_6:    (1-`pi_v')*(1-`pi_s')*   `pi_w'   ) , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
	else if "`pr_sr'"!="" {
	    nlcom  (pi_s1:   `pi_s'              ) ///	
			   (pi_s2:(1-`pi_s')*(1-`pi_w')  ) ///	
			   (pi_s3:(1-`pi_s')*   `pi_w'   ) ///	
			   (pi_r1:      `pi_v'   ) ///	
			   (pi_r2:   (1-`pi_v')  ) , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
	else if "`pr_all'"!="" {
		nlcom  (pi_s:`pi_s') /// 
			   (pi_w:`pi_w') /// 
			   (pi_v:`pi_v') ///
			   (pi_s1:   `pi_s'              ) ///	
			   (pi_s2:(1-`pi_s')*(1-`pi_w')  ) ///	
			   (pi_s3:(1-`pi_s')*   `pi_w'   ) ///	
			   (pi_r1:      `pi_v'   ) ///	
			   (pi_r2:   (1-`pi_v')  ) ///		   
			   (pi_1:       `pi_v'*    `pi_s'              ) ///
			   (pi_2:       `pi_v'* (1-`pi_s')*(1-`pi_w')  ) ///
			   (pi_3:       `pi_v'* (1-`pi_s')*   `pi_w'   ) ///
			   (pi_4:    (1-`pi_v')*   `pi_s'              ) ///
			   (pi_5:    (1-`pi_v')*(1-`pi_s')*(1-`pi_w')  ) ///
			   (pi_6:    (1-`pi_v')*(1-`pi_s')*   `pi_w'   ) , noheader
		tempname bpi Vpi
		matrix `bpi'=r(b)
		matrix `Vpi'=r(V)
		return matrix bpi=`bpi'
		return matrix Vpi=`Vpi'	   
	}
	
	
end


*capture program drop ky_est_1s
program define ky_est_1s, rclass
	syntax [if] [in], [RELiability reps(int 50) sim seed(str)]
	//////////////////////////////////////////
	/// set weights and sample
	if "`e(wtype)'" != "" {
		tempvar wt
		qui gen float `wt' `e(wexp)'
		local wgtexp "[aw=`wt']"
	}
	tempvar touse yh
	qui gen byte `touse' = e(sample)
	qui:count if `touse'
	if `r(N)'==0 {
		qui:replace `touse'=1
	}
	//////////////////////////////////////////		
	*pr_t pr_j pr_sr pr_all
	if "`seed'"!="" {
		set seed `seed'
	}
	local rngsd c(rngstate)
	tempname vcv
	matrix `vcv'=J(3,3,0)
	forvalues i=1/`reps'{
		capture drop __x__*
		ky_sim, prefix(__x__)
		qui:corr __x__e_var  __x__r_var __x__s_var if `touse' `wgtexp', cov
		matrix `vcv'=`vcv'+r(C)
	}
 	capture drop __x__*
	matrix `vcv'=`vcv'/`reps'
	tempname _rel
	*matrix list `vcv'
	local rel1r=`vcv'[1,2]/`vcv'[2,2]
	local rel2r=(`vcv'[1,2])^2/(`vcv'[2,2]*`vcv'[1,1])
	local rel1s=`vcv'[1,3]/`vcv'[3,3]
	local rel2s=(`vcv'[1,3])^2/(`vcv'[3,3]*`vcv'[1,1])
	matrix `_rel'=[`vcv'[2,2] ,`vcv'[3,3]  \  ///
	               `vcv'[1,2] ,`vcv'[1,3]  \  ///
					`rel1r', `rel1s' \   ///
					`rel2r', `rel2s' ]
					
	display  _n as result "Reliability Statistics: R"  _n
		display as text "Var(r_i)     " as result %7.4f `_rel'[1,1]
		display as text "Cov(r_i,e_i) " as result %7.4f `_rel'[2,1]
		display as text "Reliability  " as result %7.4f `_rel'[3,1]
		display as text "Reliability 2" as result %7.4f `_rel'[4,1]
		display  _n as result "Reliability Statistics: S"  _n
		display as text "Var(s_i)     " as result %7.4f `_rel'[1,2]
		display as text "Cov(s_i,e_i) " as result %7.4f `_rel'[2,2]
		display as text "Reliability  " as result %7.4f `_rel'[3,2]
		display as text "Reliability 2" as result %7.4f `_rel'[4,2]
	matrix 	`_rel'=`_rel''
	matrix colname 	`_rel' = Var Cov rel1 rel2
	matrix rowname 	`_rel' = R S
	return matrix rel = `_rel'
	return local rngstate = "`rngsd'"
	return local seed  `seed' 
	return scalar N_reps = `reps'
	***************************************************************
	** what to include here? for pi_r
end

program define ky_est_1p, rclass
	syntax [if] [in], [pr_t pr_j pr_sr pr_all]
	** This assumes that atleast 1 of the probs has covariates. Thus, it will estimate it using margins
		
			if  e(method_c)==1 {
					if "`pr_t'"!="" {
					margins, pr(pi_s)
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'
				}
				else if "`pr_j'"!="" {
					margins, pr(pi_1) pr(pi_2)
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'	   
				}
				else if "`pr_sr'"!="" {
					margins, pr(pi_s1) pr(pi_s2)
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'	   
				}
				else if "`pr_all'"!="" {
					margins, pr(pi_s) ///
							 pr(pi_s1) pr(pi_s2) ///
							 pr(pi_1) pr(pi_2) 	
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'
				}	
			 }
		else if  e(method_c)==2 {
					 if "`pr_t'"!="" {
					margins, pr(pi_s) pr(pi_w)
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'
				}
				else if "`pr_j'"!="" {
					margins, pr(pi_1) pr(pi_2) pr(pi_3)
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'	   
				}
				else if "`pr_sr'"!="" {
					margins, pr(pi_s1) pr(pi_s2) pr(pi_s3)
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'	   
				}
				else if "`pr_all'"!="" {
					margins, pr(pi_s) pr(pi_w) ///
							 pr(pi_1) pr(pi_2) pr(pi_3) ///
							 pr(pi_s1) pr(pi_s2) pr(pi_s3)
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'
				}	
			 }
		else if  e(method_c)==3 {
					if "`pr_t'"!="" {
					margins, pr(pi_s) pr(pi_r)
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'
				}
				else if "`pr_j'"!="" {
					margins, pr(pi_1) pr(pi_2) pr(pi_3) pr(pi_4)
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'	   
				}
				else if "`pr_sr'"!="" {
					margins, pr(pi_s1) pr(pi_s2) pr(pi_r1) pr(pi_r2)
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'	   
				}
				else if "`pr_all'"!="" {
					margins, pr(pi_s) pr(pi_r) ///
							 pr(pi_1) pr(pi_2) pr(pi_3) pr(pi_4) /// 
							 pr(pi_s1) pr(pi_s2) pr(pi_r1) pr(pi_r2) 
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'
				}	
			 }
		else if  e(method_c)==4 {
					if "`pr_t'"!="" {
					margins, pr(pi_s) pr(pi_r) pr(pi_w)
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'
				}
				else if "`pr_j'"!="" {
					margins, pr(pi_1) pr(pi_2) pr(pi_3) pr(pi_4) pr(pi_5) pr(pi_6)
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'	   
				}
				else if "`pr_sr'"!="" {
					margins, pr(pi_s1) pr(pi_s2) pr(pi_s3) pr(pi_r1) pr(pi_r2)
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'	   
				}
				else if "`pr_all'"!="" {
					margins, pr(pi_s) pr(pi_r) pr(pi_w) ///
							 pr(pi_1) pr(pi_2) pr(pi_3) pr(pi_4) pr(pi_5) pr(pi_6) /// 	
							 pr(pi_s1) pr(pi_s2) pr(pi_s3) pr(pi_r1) pr(pi_r2)
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'
				}	
			 }
		else if  e(method_c)==5 {
					if "`pr_t'"!="" {
					margins, pr(pi_s) pr(pi_r) pr(pi_w) pr(pi_v)
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'
				}
				else if "`pr_j'"!="" {
					margins, pr(pi_1) pr(pi_2) pr(pi_3) pr(pi_4) pr(pi_5) pr(pi_6) pr(pi_7) pr(pi_8) pr(pi_9) 
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'	   
				}
				else if "`pr_sr'"!="" {
					margins, pr(pi_s1) pr(pi_s2) pr(pi_s3) pr(pi_r1) pr(pi_r2) pr(pi_r3)
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'	   
				}
				else if "`pr_all'"!="" {
					margins, pr(pi_s) pr(pi_r) pr(pi_w) pr(pi_v) ///
							 pr(pi_1) pr(pi_2) pr(pi_3) pr(pi_4) pr(pi_5) pr(pi_6) pr(pi_7) pr(pi_8) pr(pi_9) ///
							 pr(pi_s1) pr(pi_s2) pr(pi_s3) pr(pi_r1) pr(pi_r2) pr(pi_r3)
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'
				}	
			 }	
		else if  e(method_c)==6 {
					if "`pr_t'"!="" {
					margins, pr(pi_s) pr(pi_r) pr(pi_v)
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'
				}
				else if "`pr_j'"!="" {
					margins, pr(pi_1) pr(pi_2) pr(pi_3) pr(pi_4) pr(pi_5) pr(pi_6) 
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'	   
				}
				else if "`pr_sr'"!="" {
					margins, pr(pi_s1) pr(pi_s2) pr(pi_r1) pr(pi_r2) pr(pi_r3)
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'	   
				}
				else if "`pr_all'"!="" {
					margins, pr(pi_s) pr(pi_r) pr(pi_v) ///
							 pr(pi_1) pr(pi_2) pr(pi_3) pr(pi_4) pr(pi_5) pr(pi_6) ///
							 pr(pi_s1) pr(pi_s2) pr(pi_r1) pr(pi_r2) pr(pi_r3)
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'
				}
			 }
		else if  e(method_c)==7 {
					if "`pr_t'"!="" {
					margins, pr(pi_s) pr(pi_r) pr(pi_w)
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'
				}
				else if "`pr_j'"!="" {
					margins, pr(pi_1) pr(pi_2) pr(pi_3) pr(pi_4) pr(pi_5) pr(pi_6)
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'	   
				}
				else if "`pr_sr'"!="" {
					margins, pr(pi_s1) pr(pi_s2) pr(pi_s3) pr(pi_r1) pr(pi_r2)
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'	   
				}
				else if "`pr_all'"!="" {
					margins, pr(pi_s) pr(pi_r) pr(pi_w) ///
							 pr(pi_1) pr(pi_2) pr(pi_3) pr(pi_4) pr(pi_5) pr(pi_6) /// 	
							 pr(pi_s1) pr(pi_s2) pr(pi_s3) pr(pi_r1) pr(pi_r2)
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'
				}
		}	
		else if  e(method_c)==8 {
					if "`pr_t'"!="" {
					margins, pr(pi_s) pr(pi_r) pr(pi_w) pr(pi_v)
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'
				}
				else if "`pr_j'"!="" {
					margins, pr(pi_1) pr(pi_2) pr(pi_3) pr(pi_4) pr(pi_5) pr(pi_6) pr(pi_7) pr(pi_8) pr(pi_9) 
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'	   
				}
				else if "`pr_sr'"!="" {
					margins, pr(pi_s1) pr(pi_s2) pr(pi_s3) pr(pi_r1) pr(pi_r2) pr(pi_r3)
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'	   
				}
				else if "`pr_all'"!="" {
					margins, pr(pi_s) pr(pi_r) pr(pi_w) pr(pi_v) ///
							 pr(pi_1) pr(pi_2) pr(pi_3) pr(pi_4) pr(pi_5) pr(pi_6) pr(pi_7) pr(pi_8) pr(pi_9) ///
							 pr(pi_s1) pr(pi_s2) pr(pi_s3) pr(pi_r1) pr(pi_r2) pr(pi_r3)
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'
				}	
			 }
		else if  e(method_c)==9 {
					if "`pr_t'"!="" {
					margins, pr(pi_s) pr(pi_w) pr(pi_v)
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'
				}
				else if "`pr_j'"!="" {
					margins, pr(pi_1) pr(pi_2) pr(pi_3) pr(pi_4) pr(pi_5) pr(pi_6) 
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'	   
				}
				else if "`pr_sr'"!="" {
					margins, pr(pi_s1) pr(pi_s2) pr(pi_s3) pr(pi_r1) pr(pi_r2) 
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'	   
				}
				else if "`pr_all'"!="" {
					margins, pr(pi_s) pr(pi_w) pr(pi_v) ///
							 pr(pi_1) pr(pi_2) pr(pi_3) pr(pi_4) pr(pi_5) pr(pi_6)  ///
							 pr(pi_s1) pr(pi_s2) pr(pi_s3) pr(pi_r1) pr(pi_r2) 
					tempname bpi Vpi
					matrix `bpi'=r(b)
					matrix `Vpi'=r(V)
					return matrix bpi=`bpi'
					return matrix Vpi=`Vpi'
				}	
			 }			 
end


*capture program drop mse_bias_var
program define mse_bias_var, rclass
	syntax [if] [aw], e_var(varname) o_var(varlist)
	tempvar aux_mse aux_bias aux_rel
	tempname tbl ttbl
	foreach i of local o_var {
		capture drop `aux_mse' `aux_bias'
		gen double `aux_mse'=(`i'-`e_var')^2
		gen double `aux_bias'=(`i'-`e_var')
		qui:sum `aux_mse' `if'  [`weight'`exp'], meanonly
		matrix  `tbl'=r(mean)
		qui:sum `aux_bias',
		matrix  `tbl'=`tbl',r(mean),r(Var)
		matrix   `ttbl'=nullmat(`ttbl') \ `tbl'
	}
	qui:corr `e_var' `o_var' `if'   [`weight'`exp'], cov
	tempname aux_rel
	mata:mm=st_matrix("r(C)")
	mata:mm=(mm[2..rows(mm),1]:/(diagonal(mm[2..rows(mm),2..rows(mm)]))),(mm[2..rows(mm),1]:^2):/(diagonal(mm[2..rows(mm),2..rows(mm)]):*mm[1,1]) 
	mata:st_matrix("`aux_rel'",mm)
	mata:mata drop mm
	matrix `ttbl'=`aux_rel',`ttbl'
	matrix colname `ttbl' = Rel1 Rel2 MSE E(Bias) Var(Bias)
	return matrix mse_bias_var = `ttbl'
end

capture program drop ky_xirel
program ky_xirel, rclass
	syntax, [xirel reps(int 50) seed(str) surv_only ]
	
	//////////////////////////////////////////
	/// set weights and sample
	if "`e(wtype)'" != "" {
		tempvar wt
		qui gen float `wt' `e(wexp)'
		local wgtexp "[aw=`wt']"
	}
	tempvar touse yh
	qui gen byte `touse' = e(sample)
	qui:count if `touse'
	if `r(N)'==0 {
		qui:replace `touse'=1
	}
	///////////////////////////////////////////
	
	*pr_t pr_j pr_sr pr_all
	if "`seed'"!="" {
		set seed `seed'
	}
	local rngsd `c(rngstate)'
	
	tempname vcv
	matrix `vcv'=J(9,5,0)
	forvalues i=1/`reps'{
		capture drop __x__*
		ky_sim  if `touse', prefix(__x__) 
		ky_star if `touse' , rvar(__x__r_var) svar(__x__s_var) lvar(__x__l_var) prefix(__x__) `surv_only'
		** MSE mean(bias) and Var(bias)	
		mse_bias_var if `touse' `wgtexp', e_var(__x__e_var) o_var(__x__r_var __x__s_var __x__1 - __x__7)
		matrix `vcv' =  `vcv' + r(mse_bias_var)
	}
 	capture drop __x__*
	matrix `vcv'=`vcv'/`reps'

	matrix colname 	`vcv' = Rel1 Rel2 MSE E(Bias) Var(Bias)
	matrix rowname 	`vcv' =  r_var s_var e_1 e_2 e_3 e_4 e_5 e_6 e_7
	display as result "Rel Statistics for 'e' predictions"
	matrix list `vcv', format(%5.4f) nohead 
	
	return matrix mbv = `vcv'
	return local rngstate = "`rngsd'"
	return local seed  `seed' 
 	return scalar N_reps = `reps'
	***************************************************************
	if "`seed'"!="" {
		set rngstate `rngsd'
	}
end

