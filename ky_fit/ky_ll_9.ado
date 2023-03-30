** MLE for Scenario with all cases. mismatch and measurment errors  
** Assumes no error in t
/*
 s_i
 s1=e_i
 s2=e_i+rho_s(e_i-mu_e)+n_i
 s3=e_i+rho_s(e_i-mu_e)+n_i+w_i
 
 r_i
 r1=e_i
 r2=e_i+rho_r(e_i-mu_e)+v_i
 
*/
program define ky_ll_9
version 14

** all variables that require estimation
args lnf mu_e     mu_n     mu_w     mu_v ///
         ln_sig_e ln_sig_n ln_sig_w ln_sig_v ///
		 arho_s arho_r ///
		 lpi_s  lpi_w lpi_v
		 *lpi_r mu_t ln_sig_t
qui {
	*set trace on
	** Program interesting 
	tempvar pi_s pi_r pi_w pi_v
	*gen double `pi_r'=logistic(`lpi_r')
	gen double `pi_s'=logistic(`lpi_s')
	gen double `pi_w'=logistic(`lpi_w')
	gen double `pi_v'=logistic(`lpi_v')
	
	***
	local pi_r1    `pi_v'
	local pi_r2    (1-`pi_v')
	*local pi_r3 (1-`pi_r')
	local pi_s1    `pi_s'
	local pi_s2 (1-`pi_s')*(1-`pi_w')
	local pi_s3 (1-`pi_s')*   `pi_w'
	
	tempvar pi_1 pi_2 pi_3 pi_4 pi_5 pi_6 pi_7 pi_8 pi_9
	
	gen double `pi_1'=`pi_r1'*`pi_s1'
	gen double `pi_2'=`pi_r1'*`pi_s2'
	gen double `pi_3'=`pi_r1'*`pi_s3'
	gen double `pi_4'=`pi_r2'*`pi_s1'
	gen double `pi_5'=`pi_r2'*`pi_s2'
	gen double `pi_6'=`pi_r2'*`pi_s3'
	
	** means u_e u_n u_w
	
	** sigmas and rho
	local sig_e exp(`ln_sig_e')
	local sig_n exp(`ln_sig_n') 
	local sig_w exp(`ln_sig_w')
	local sig_v exp(`ln_sig_v')
	*local sig_t exp(`ln_sig_t')
	local rho_s tanh(`arho_s')
	local rho_r tanh(`arho_r')

	** means
	tempvar mnr_1 mnr_2 mnr_3 mns_1 mns_2 mns_3
	gen double `mnr_1'= (`mu_e')
	gen double `mnr_2'= (`mu_e'+`mu_v')
	*gen double `mnr_3'= (`mu_t')
	gen double `mns_1'= (`mu_e')
	gen double `mns_2'= (`mu_e'+`mu_n')
	gen double `mns_3'= (`mu_e'+`mu_n'+`mu_w')
	
	** variances: Standard errors
	tempvar sr_2
	local       sr_1 `sig_e'
	gen double `sr_2'=sqrt((1+`rho_r')^2*`sig_e'^2+`sig_v'^2)
	*local       sr_3 `sig_t'
	
	tempvar ss_2 ss_3
	local       ss_1   `sig_e'
	gen double `ss_2'= sqrt((1+`rho_s')^2*`sig_e'^2+`sig_n'^2)
	gen double `ss_3'= sqrt((1+`rho_s')^2*`sig_e'^2+`sig_n'^2+`sig_w'^2)
	** corr
	tempvar cr_r1s2  cr_r1s3 cr_r2s1 cr_r2s2 cr_r2s3
	
	local       cr_r1s1 =1
	gen double `cr_r1s2'= ((1+`rho_s')            *`sig_e'^2)/(`sr_1'*`ss_2')
	gen double `cr_r1s3'= ((1+`rho_s')            *`sig_e'^2)/(`sr_1'*`ss_3')
	gen double `cr_r2s1'= (            (1+`rho_r')*`sig_e'^2)/(`sr_2'*`ss_1')
	gen double `cr_r2s2'= ((1+`rho_s')*(1+`rho_r')*`sig_e'^2)/(`sr_2'*`ss_2')
	gen double `cr_r2s3'= ((1+`rho_s')*(1+`rho_r')*`sig_e'^2)/(`sr_2'*`ss_3')
	*local       cr_r3s1 =0
	*local       cr_r3s2 =0
	*local       cr_r3s3 =0
	
	** all densities
	tempvar lnf1 lnf2 lnf3 lnf4 lnf5 lnf6 
     **** R1 S1 goes at the very end.
	 *** R1 S2
	local mean_r  `mnr_1' 
	local mean_s  `mns_2'
	local sigma_r `sr_1'
	local sigma_s `ss_2'
	local rho_rs  `cr_r1s2'
	tempvar rs1 rs2 rs3
	gen double `rs1'= ($ML_y1-`mean_r')/`sigma_r' 
	gen double `rs2'= ($ML_y2-`mean_s')/`sigma_s'
	gen double `lnf2'=-ln(2*_pi*`sigma_r'*`sigma_s'*sqrt(1-`rho_rs'^2))  ///
	                  -1/(2*(1-`rho_rs'^2)) * (`rs1'^2+`rs2'^2-2*`rho_rs'*`rs1'*`rs2') 
	
	local mean_r  `mnr_1' 
	local mean_s  `mns_3'
	local sigma_r `sr_1'
	local sigma_s `ss_3'
	local rho_rs  `cr_r1s3'
 
	replace `rs1'= ($ML_y1-`mean_r')/`sigma_r' 
	replace `rs2'= ($ML_y2-`mean_s')/`sigma_s'
	gen double `lnf3'=-ln(2*_pi*`sigma_r'*`sigma_s'*sqrt(1-`rho_rs'^2)) ///
	                  -1/(2*(1-`rho_rs'^2))* (`rs1'^2+`rs2'^2-2*`rho_rs'*`rs1'*`rs2') 
	
	local mean_r  `mnr_2' 
	local mean_s  `mns_1'
	local sigma_r `sr_2'
	local sigma_s `ss_1'
	local rho_rs  `cr_r2s1'
	
	replace `rs1'= ($ML_y1-`mean_r')/`sigma_r' 
	replace `rs2'= ($ML_y2-`mean_s')/`sigma_s'
	gen double `lnf4'=-ln(2*_pi*`sigma_r'*`sigma_s'*sqrt(1-`rho_rs'^2))  ///
	                  -1/(2*(1-`rho_rs'^2)) * (`rs1'^2+`rs2'^2-2*`rho_rs'*`rs1'*`rs2') 
	
 	local mean_r  `mnr_2' 
	local mean_s  `mns_2'
	local sigma_r `sr_2'
	local sigma_s `ss_2'
	local rho_rs  `cr_r2s2'
	
	replace `rs1'= ($ML_y1-`mean_r')/`sigma_r' 
	replace `rs2'= ($ML_y2-`mean_s')/`sigma_s'
	gen double `lnf5'=-ln(2*_pi*`sigma_r'*`sigma_s'*sqrt(1-`rho_rs'^2))  ///
	                  -1/(2*(1-`rho_rs'^2)) * (`rs1'^2+`rs2'^2-2*`rho_rs'*`rs1'*`rs2') 
	
 	local mean_r  `mnr_2' 
	local mean_s  `mns_3'
	local sigma_r `sr_2'
	local sigma_s `ss_3'
	local rho_rs  `cr_r2s3'
	
	replace `rs1'= ($ML_y1-`mean_r')/`sigma_r' 
	replace `rs2'= ($ML_y2-`mean_s')/`sigma_s'
	gen double `lnf6'=-ln(2*_pi*`sigma_r'*`sigma_s'*sqrt(1-`rho_rs'^2))  ///
	                  -1/(2*(1-`rho_rs'^2)) * (`rs1'^2+`rs2'^2-2*`rho_rs'*`rs1'*`rs2') 
	
 	
	** all together
	gen double `lnf1'=log(normalden($ML_y1,`mnr_1',`sr_1'))	
	replace `lnf'=`lnf1'+log(`pi_1')     if $ML_y3==1
	replace `lnf'=log(                   `pi_2'*exp(`lnf2')+`pi_3'*exp(`lnf3') ///
	                 +`pi_4'*exp(`lnf4')+`pi_5'*exp(`lnf5')+`pi_6'*exp(`lnf6') ) if $ML_y3==0
    }
 end		 

 