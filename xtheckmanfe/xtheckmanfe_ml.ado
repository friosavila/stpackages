*! v1  Pseudo two-ml for xtheckmanfe
program define xtheckmanfe_ml
	args lnf xb zg  arho lnsigma 
	qui {
		tempvar rho  sigma 
		*gen double `rho'   = tanh(`arho')
		gen double `sigma' = exp(`lnsigma')
		** probit first
		replace `lnf'=log(normal(-`zg')) if $ML_y2==0
		replace `lnf'=log(normal( `zg')) if $ML_y2==1
		tempvar imr
		gen double `imr'=normalden(`zg')/normal(`zg')
		replace `lnf'=`lnf'+log(normalden($ML_y1 , `xb'+`arho'*`imr',`sigma')) if $ML_y2==1
	}
end