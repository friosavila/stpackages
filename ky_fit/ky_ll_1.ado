* model with RTM on survey data only
/*
r_i=e_i
s_i
s1 =e_i
s1 =e_i+rho_s*(e_i-mu_e)+n_i
*/


program define ky_ll_1
version 14

** all variables that require estimation
args lnf mu_e mu_n ln_sig_e ln_sig_n arho_s lpi_s   
qui {
	** Program interesting 
	tempvar pi_s pi_r pi_w pi_v
 
	gen double `pi_s'=exp(`lpi_s')/(1+exp(`lpi_s'))
 
	
	***
	local pi_r1    1
	local pi_s1    (`pi_s')
	local pi_s2 (1-`pi_s')
		
	tempvar pi_1 pi_2 pi_3 pi_4 pi_5 pi_6 pi_7 pi_8 pi_9
	
	gen double `pi_1'=`pi_r1'*`pi_s1'
	gen double `pi_2'=`pi_r1'*`pi_s2'
	
 	** sigmas and rho
	local sig_e exp(`ln_sig_e')
	local sig_n exp(`ln_sig_n') 
	local rho_s tanh(`arho_s')

	** means
	local mnr_1 (`mu_e')
		
	local mns_1 (`mu_e')
	local mns_2 (`mu_e'+`mu_n')
 	
	** variances
	local sr_1 `sig_e'
		
	local ss_1 `sig_e'
	tempvar ss_2 
	gen double `ss_2'= ((1+`rho_s')^2*`sig_e'^2+`sig_n'^2)^.5
	
 	** corr
	local cr_r1s1 (1)
	tempvar cr_r1s2 
	gen double `cr_r1s2'=((1+`rho_s')*`sig_e'^2)/(`sr_1'*`ss_2')
  
	
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
		 
	** all together
	tempvar	lnfx
	gen double `lnf1'=log(normalden($ML_y1,`mnr_1',`sr_1'))	
	replace `lnf'=`lnf1'+log(`pi_1') if $ML_y3==1	
	replace `lnf'=`lnf2'+log(`pi_2') if $ML_y3==0
    }
	*sum `lnf' `mu_e' `ln_sig_e' 
	*a 
end	
   	 