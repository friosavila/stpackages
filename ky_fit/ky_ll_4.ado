*** Model with mismatch and RTM + contamination
/*
r_i 
r1=e_i
r2=t_i

s_i
s1=e_i
s2=e_i+rho_s*(e_i-mu_e)+n_i
s3=e_i+rho_s*(e_i-mu_e)+n_i+w_i
*/

program define ky_ll_4
version 14

** all variables that require estimation
args lnf mu_e mu_n mu_w mu_t  ln_sig_e ln_sig_n ln_sig_w ln_sig_t arho_s lpi_r  lpi_s  lpi_w
qui {
	** Program interesting 
	tempvar pi_s pi_r pi_w pi_v
	gen double `pi_r'=exp(`lpi_r')/(1+exp(`lpi_r'))
	gen double `pi_s'=exp(`lpi_s')/(1+exp(`lpi_s'))
	gen double `pi_w'=exp(`lpi_w')/(1+exp(`lpi_w'))
	*gen double `pi_v'=exp(`lpi_v')/(1+exp(`lpi_v'))
	
	***
	local pi_r1    `pi_r' 
	local pi_r2 (1-`pi_r')
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
	local sig_t exp(`ln_sig_t')
	local rho_s   tanh(`arho_s')

	** means
	local mnr_1 (`mu_e')
	local mnr_2 (`mu_t')
	
	local mns_1 (`mu_e')
	local mns_2 (`mu_e'+`mu_n')
	local mns_3 (`mu_e'+`mu_n'+`mu_w')
	
	** variances
	local sr_1 `sig_e'
	local sr_2 `sig_t'
	
	local ss_1 `sig_e'
	tempvar ss_2 ss_3
	gen double `ss_2'= ((1+`rho_s')^2*`sig_e'^2+`sig_n'^2)^.5
	gen double `ss_3'= ((1+`rho_s')^2*`sig_e'^2+`sig_n'^2+`sig_w'^2)^.5
	
	** corr
	local cr_r1s1 1
	tempvar cr_r1s2 cr_r1s3
	gen double `cr_r1s2'= ((1+`rho_s')*`sig_e'^2)/(`sr_1'*`ss_2')
	gen double `cr_r1s3'= ((1+`rho_s')*`sig_e'^2)/(`sr_1'*`ss_3')
	local cr_r2s1 0
	local cr_r2s2 0
	local cr_r2s3 0
	
	** all densities
	tempvar lnf1 lnf2 lnf3 lnf4 lnf5 lnf6 lnf7 lnf8 lnf9		  	  


	local mean_r  `mnr_1' 
	local mean_s  `mns_2'
	local sigma_r `sr_1'
	local sigma_s `ss_2'
	local rho_rs  `cr_r1s2'
	
	tempvar rs1 rs2 rs3
	gen double `rs1'= ($ML_y1-`mean_r')^2/`sigma_r'^2 
	gen double `rs2'= ($ML_y2-`mean_s')^2/`sigma_s'^2
	gen double `rs3'= 2*`rho_rs'*($ML_y1-`mean_r')*($ML_y2-`mean_s')/(`sigma_r'*`sigma_s')
	
	gen double `lnf2'=-ln(2*_pi*`sigma_r'*`sigma_s'*(1-`rho_rs'^2)^.5)-1/(2*(1-`rho_rs'^2))*(`rs1'+`rs2'-`rs3') 
	
	local mean_r  `mnr_1' 
	local mean_s  `mns_3'
	local sigma_r `sr_1'
	local sigma_s `ss_3'
	local rho_rs  `cr_r1s3'
 
	replace `rs1'= ($ML_y1-`mean_r')^2/`sigma_r'^2 
	replace `rs2'= ($ML_y2-`mean_s')^2/`sigma_s'^2
	replace `rs3'= 2*`rho_rs'*($ML_y1-`mean_r')*($ML_y2-`mean_s')/(`sigma_r'*`sigma_s')
	gen double `lnf3'=-ln(2*_pi*`sigma_r'*`sigma_s'*(1-`rho_rs'^2)^.5)-1/(2*(1-`rho_rs'^2))*(`rs1'+`rs2'-`rs3') 
	
	local mean_r  `mnr_2' 
	local mean_s  `mns_1'
	local sigma_r `sr_2'
	local sigma_s `ss_1'
	local rho_rs  `cr_r2s1'
	
	replace `rs1'= ($ML_y1-`mean_r')^2/`sigma_r'^2 
	replace `rs2'= ($ML_y2-`mean_s')^2/`sigma_s'^2
	replace `rs3'= 2*`rho_rs'*($ML_y1-`mean_r')*($ML_y2-`mean_s')/(`sigma_r'*`sigma_s')
	gen double `lnf4'=-ln(2*_pi*`sigma_r'*`sigma_s'*(1-`rho_rs'^2)^.5)-1/(2*(1-`rho_rs'^2))*(`rs1'+`rs2'-`rs3') 
	
 	local mean_r  `mnr_2' 
	local mean_s  `mns_2'
	local sigma_r `sr_2'
	local sigma_s `ss_2'
	local rho_rs  `cr_r2s2'
	
	replace `rs1'= ($ML_y1-`mean_r')^2/`sigma_r'^2 
	replace `rs2'= ($ML_y2-`mean_s')^2/`sigma_s'^2
	replace `rs3'= 2*`rho_rs'*($ML_y1-`mean_r')*($ML_y2-`mean_s')/(`sigma_r'*`sigma_s')
	gen double `lnf5'=-ln(2*_pi*`sigma_r'*`sigma_s'*(1-`rho_rs'^2)^.5)-1/(2*(1-`rho_rs'^2))*(`rs1'+`rs2'-`rs3') 
	
 	local mean_r  `mnr_2' 
	local mean_s  `mns_3'
	local sigma_r `sr_2'
	local sigma_s `ss_3'
	local rho_rs  `cr_r2s3'
	
	replace `rs1'= ($ML_y1-`mean_r')^2/`sigma_r'^2 
	replace `rs2'= ($ML_y2-`mean_s')^2/`sigma_s'^2
	replace `rs3'= 2*`rho_rs'*($ML_y1-`mean_r')*($ML_y2-`mean_s')/(`sigma_r'*`sigma_s')
	gen double `lnf6'=-ln(2*_pi*`sigma_r'*`sigma_s'*(1-`rho_rs'^2)^.5)-1/(2*(1-`rho_rs'^2))*(`rs1'+`rs2'-`rs3') 
	
	
	** all together
		
	gen double `lnf1'=log(normalden($ML_y1,`mnr_1',`sr_1'))	
	replace `lnf'=`lnf1'+log(`pi_1')                                            if $ML_y3==1
	replace `lnf'=log(`pi_2'*exp(`lnf2')+`pi_3'*exp(`lnf3') ///
	                 +`pi_4'*exp(`lnf4')+`pi_5'*exp(`lnf5')+`pi_6'*exp(`lnf6')) if $ML_y3==0
    }
 end	
