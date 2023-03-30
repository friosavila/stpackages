** This contains the ML for the model.
capture program drop mbitobit_lf
program mbitobit_lf
args lnf xb1 xb2 lns1 lns2 arho
qui {
    *** We first construct correlation and Sigmas
	tempvar s1 s2 rho
	gen double `rho'=tanh(`arho')
	gen double `s1'=exp(`lns1')
	gen double `s2'=exp(`lns2')
	****Define some variables to be used
	tempvar lnf1 lnf2 lnf3 lnf4
	local std1 (($ML_y1-`xb1')/`s1')
	local std2 (($ML_y2-`xb2')/`s2')
	local h1 $ML_y1
	local h2 $ML_y2
	** and construct the ML
	** Case1 h1>0 h2>0
	** try adjusted to different thresholds
	gen double `lnf1'=-ln(2*_pi)-`lns1'-`lns2'  ///
					   -0.5*ln(1-`rho'^2)       ///
					   -(1/2)*(1/(1-`rho'^2))*[(`std1')^2+(`std2')^2-2*`rho'*(`std1'*`std2')] if `h2'>0 & `h1'>0
	** Case2 h1>0 h2=0
	gen double `lnf2'=ln(normalden(`std1'))-`lns1' ///
					 +ln(normal((`std2'-`rho'*`std1')/(sqrt(1-`rho'^2)))) if `h2'==0 & `h1'>0
	** Case3 h1=0 h2>0
	gen double `lnf3'=ln(normalden(`std2'))-`lns2' ///
					 +ln(normal((`std1'-`rho'*`std2')/(sqrt(1-`rho'^2)))) if `h2'>0 & `h1'==0
	** Case4 h1=0 h2=0
	gen double `lnf4'=ln(binormal(`std1',`std2',`rho')) if `h2'==0 & `h1'==0
	** The rest is just set it where it belongs
	replace `lnf'=`lnf1' if `h2'>0  & `h1'>0
	replace `lnf'=`lnf2' if `h2'==0 & `h1'>0
	replace `lnf'=`lnf3' if `h2'>0  & `h1'==0
	replace `lnf'=`lnf4' if `h2'==0 & `h1'==0
}
end


  
