
capture program drop _gwberr
program define _gwberr
	version 8
	syntax newvarname =/exp [if] [in] , err(varname) [, BY(varlist) permute dropna seed(str)   ]
	tempvar touse  
	gen byte `touse' =0
	replace  `touse'=1 `if' `in' 
	if "`weight'"!="" {
	replace `touse'=0 if `weight'==.
	}
	if "`by'"!="" {
	replace `touse'=0 if `by'==.
	}
	if "`dropna'"!="" {
	replace `touse'=0 if `exp'==.
	}
	** with replacement.
 
	** This will be for a pseudo WILD bootstrap. The idea will be to create the residuals according to WB procedure
 	if "`seed'"!="" set seed `seed'
		sort `touse' `by'
		tempvar rnd exp2 rnd2
		qui:gen byte `rnd'=(runiform()<((1+sqrt(5))/(2*sqrt(5))))
		qui:gen `typlist' `varlist'=`exp'-`err'+(0.5*(1+sqrt(5))-sqrt(5)*`rnd')*`err'
 end
