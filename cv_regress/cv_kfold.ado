*! v1.2 cv_kfold. OCT 2022 by Fernando Rios-Avila
* v1.1 cv_kfold. August 2020 by Fernando Rios-Avila
* correct for poisson. 
* try adding something for predicted models. Reg poisson tobit

* v1.0 cv_kfold. 22 May 2020 by Fernando Rios-Avila
* First version. limitted number of commands
** program define for k-fold cross validation
/*
capture program   drop cv_kfold
capture program   drop reparser
capture program   drop cross_reg
capture program   drop cross_probit
capture program   drop cross_poisson
capture program   drop cross_mlogit
*/

program define cv_kfold, sortpreserve
syntax, [ k(int 5) reps(int 1) seed(str) gen(str)] 
	*version depends on features used in the command
	if "`seed'"!="" {
		local crng `c(rngstate)'
		set seed `seed'
	}
	     if "`e(cmd)'"=="regress" {
		     cross_reg    , k(`k') reps(`reps') gen(`gen')
		 }
	else if "`e(cmd)'"=="logit"   {
			cross_probit , k(`k') reps(`reps') gen(`gen')
		}
	else if "`e(cmd)'"=="probit"  {
			cross_probit , k(`k') reps(`reps') gen(`gen')
		}
	else if "`e(cmd)'"=="cloglog" {
	    cross_probit , k(`k') reps(`reps') gen(`gen')
	}
	else if "`e(cmd)'"=="poisson" {
	    cross_poisson, k(`k') reps(`reps') gen(`gen')
	}
	else if "`e(cmd)'"=="nbreg"   {
	    cross_poisson, k(`k') reps(`reps') gen(`gen')
	}
	else if "`e(cmd)'"=="mprobit" {
	    cross_mlogit , k(`k') reps(`reps') gen(`gen')
	}
	else if "`e(cmd)'"=="mlogit"  {
	    cross_mlogit , k(`k') reps(`reps') gen(`gen')
	}
	else if "`e(cmd)'"=="oprobit"  {
	    cross_mlogit , k(`k') reps(`reps') gen(`gen')
	}
	else if "`e(cmd)'"=="ologit"  {
	    cross_mlogit , k(`k') reps(`reps') gen(`gen')
	}
	else {
	    display in red "Command not allowed"
		exit 1
	}
	if "`seed'"!="" {
		set rngstate `crng'
	}
	
end

program define cross_reg, rclass
	syntax, k(int) reps(int) [seed(str) gen(str)]
	tempname eqreg
	** save eq
	qui:est sto `eqreg'
	** get what I need.
	tempvar touse
	qui:gen byte `touse'=e(sample)
	local  cmdln=subinstr("`e(cmdline)'","`e(cmd)'","",1)
	qui:reparser `cmdln'
	local y_x `r(y_x)'
	local wgt `r(wgt)'
	local opts  `r(opts)'
	local cmd  `e(cmd)'
	** regress uses residuals
	tempvar kfld resid tmpresid
	tempname msqr
	local mmsqr=0
	qui:gen double `resid'=.
	forvalues ii=1/`reps' {
	    capture drop `kfld'
		qui:xtile `kfld'=runiform() if `touse', n(`k')
		forvalues j=1/`k' {
		    qui:`cmd' `y_x' `wgt' if `touse' & `kfld'!=`j', `opts'
			qui:capture drop `tmpresid'
			qui:predict double `tmpresid', resid
			qui:replace `resid'=`tmpresid'^2 if `touse' & `kfld'==`j'
		}
		** Root MSQR
		if "`gen'"!="" {
			qui:gen double `gen'`ii'=`resid'
		}
		qui:sum `resid' if `touse', meanonly
		qui:matrix `msqr'=nullmat(`msqr')\sqrt(r(mean))
		local mmsqr=`mmsqr'+sqrt(r(mean))
	}
	local mmsqr = `mmsqr'/`reps'
	matrix colname `msqr'=msqr
	return local mmsqr = `mmsqr'
	return matrix msqr = `msqr'
	return local k = `k'
	return local reps = `reps'
	return local seed  `seed'
	qui:est restore `eqreg'
	display as result "k-fold Cross validation"
	display as text   "Number of Folds     : " %10.0f `k' 
	display as text   "Number of Repetions : " %10.0f `reps'
	display as text   "Avg Root Mean SE    : " %10.5f `mmsqr'
end


program define cross_probit, rclass
	syntax, k(int) reps(int) [seed(str) gen(str)]
	tempname eqreg
	** save eq
	qui:est sto `eqreg'
	** get what I need.
	tempvar touse
	qui:gen byte `touse'=e(sample)
	local  cmdln=subinstr("`e(cmdline)'","`e(cmd)'","",1)
	qui:reparser `cmdln'
	local y_x `r(y_x)'
	local wgt `r(wgt)'
	local opts  `r(opts)'
	local cmd  `e(cmd)'
	tempvar y
	qui:clonevar `y'=`e(depvar)'  if `touse'
	qui:replace `y'=`y'!=0   if `touse'
	tempname binit
	matrix `binit'=e(b)
	** regress uses residuals
	tempvar kfld resid tmpresid
	tempname msqr
	local mmsqr=0
	qui:gen double `resid'=.
	forvalues ii=1/`reps' {
	    capture drop `kfld'
		qui:xtile `kfld'=runiform() if `touse', n(`k')
		forvalues j=1/`k' {
		    qui:`cmd' `y_x' `wgt' if `touse' & `kfld'!=`j', `opts' from(`binit',skip)
			qui:capture drop `tmpresid'
			qui:predict double `tmpresid', pr 
			qui:replace `resid'=log(`tmpresid')*(`y'==1)+log(1-`tmpresid')*(`y'==1) if `touse' & `kfld'==`j'
			
		}
		** Root MSQR
		if "`gen'"!="" {
			qui:gen `double' `gen'`ii'=`resid'
		}
		qui:sum `resid' if `touse', meanonly
		qui:matrix `msqr'=nullmat(`msqr')\ (r(mean)*r(N))
		local mmsqr=`mmsqr'+(r(mean)*r(N))
	}
	local mmsqr = `mmsqr'/`reps'
	matrix colname `msqr'=msqr
	return local mmsqr = `mmsqr'
	return matrix msqr = `msqr'
	return local k = `k'
	return local reps = `reps'
	return local seed  `seed'
	qui:est restore `eqreg'
	display as result "k-fold Cross validation"
	display as text   "Number of Folds     : " %10.0f `k' 
	display as text   "Number of Repetions : " %10.0f `reps'
	display as text   "Avg LL              : " %10.5f `mmsqr'
end

program define cross_poisson, rclass
	syntax, k(int) reps(int) [seed(str) gen(str)]
	tempname eqreg
	** save eq
	qui:est sto `eqreg'
	** get what I need.
	tempvar touse
	qui:gen byte `touse'=e(sample)
	local  cmdln=subinstr("`e(cmdline)'","`e(cmd)'","",1)
	qui:reparser `cmdln'
	local y_x `r(y_x)'
	local wgt `r(wgt)'
	local opts  `r(opts)'
	local cmd  `e(cmd)'
	local kk `e(k)'
	tempvar y
	clonevar `y'=`e(depvar)' if `touse'
	tempname binit
	matrix `binit'=e(b)
	** regress uses residuals
	tempvar kfld resid tmpresid
	tempname msqr
	local mmsqr=0
	qui:gen double `resid'=.
	forvalues ii=1/`reps' {
	    capture drop `kfld'
		qui:xtile `kfld'=runiform() if `touse', n(`k')
		forvalues j=1/`k' {
		    qui:`cmd' `y_x' `wgt' if `touse' & `kfld'!=`j', `opts' from(`binit',skip)
			qui:capture drop `tmpresid'
			qui:predict double `tmpresid', xb
					
			qui:replace `resid'=-exp(`tmpresid') + `y' * `tmpresid' -  lngamma(`y'+1) if `touse' & `kfld'==`j'
		}
		** Root MSQR
		if "`gen'"!="" {
			qui:gen `double' `gen'`ii'=`resid'
		}
		qui:sum `resid' if `touse', meanonly
		qui:matrix `msqr'=nullmat(`msqr')\ (r(mean)*r(N))
		local mmsqr=`mmsqr'+(r(mean)*r(N))
	}
	local mmsqr = `mmsqr'/`reps'
	matrix colname `msqr'=msqr
	return local mmsqr = `mmsqr'
	return matrix msqr = `msqr'
	return local k = `k'
	return local reps = `reps'
	return local seed  `seed'
	qui:est restore `eqreg'
	display as result "k-fold Cross validation"
	display as text   "Number of Folds     : " %10.0f `k' 
	display as text   "Number of Repetions : " %10.0f `reps'
	display as text   "Avg LL              : " %10.5f `mmsqr'
end

program define cross_mlogit, rclass
	syntax, k(int) reps(int) [seed(str) gen(str)]
	tempname eqreg
	** save eq
	qui:est sto `eqreg'
	** get what I need.
	tempvar touse
	qui:gen byte `touse'=e(sample)
	local  cmdln=subinstr("`e(cmdline)'","`e(cmd)'","",1)
	qui:reparser `cmdln'
	local y_x `r(y_x)'
	local wgt `r(wgt)'
	local opts  `r(opts)'
	local cmd  `e(cmd)'
	local kk `e(k)'
	tempvar y
	clonevar `y'=`e(depvar)' if `touse'
	tempname binit
	matrix `binit'=e(b)
	** regress uses residuals
	tempvar kfld resid tmpresid
	tempname msqr
	local mmsqr=0
	qui:gen double `resid'=.
 	forvalues ii=1/`reps' {
	    capture drop `kfld'
		qui:xtile `kfld'=runiform() if `touse', n(`k')
		forvalues j=1/`k' {
		    qui:`cmd' `y_x' `wgt' if `touse' & `kfld'!=`j', `opts' from(`binit',skip)
			qui:capture drop `tmpresid'*
			qui:predict double `tmpresid'*, pr
			qui:levelsof `y' if `touse', local(yval)
			local cnts=0
			foreach i of local yval {
			local cnts=`cnts'+1
			qui:replace `resid'=log(`tmpresid'`cnts') if `touse' & `kfld'==`j' & `i'==`y'
			}
			
		}
		** Root MSQR
		if "`gen'"!="" {
			qui:gen `double' `gen'`ii'=`resid'
		}
		qui:sum `resid' if `touse', meanonly
		qui:matrix `msqr'=nullmat(`msqr')\ (r(mean)*r(N))
		local mmsqr=`mmsqr'+(r(mean)*r(N))
	}
 	local mmsqr = `mmsqr'/`reps'
	matrix colname `msqr'=msqr
	return local mmsqr = `mmsqr'
	return matrix msqr = `msqr'
	return local k = `k'
	return local reps = `reps'
	return local seed  `seed'
	qui:est restore `eqreg'
	display as result "k-fold Cross validation"
	display as text   "Number of Folds     : " %10.0f `k' 
	display as text   "Number of Repetions : " %10.0f `reps'
	display as text   "Avg LL              : " %10.5f `mmsqr'
end


program define reparser, rclass
syntax anything [if] [in] [aw pw iw fw], [*]
   * first word will be command
   return local y_x `anything'
   return local wgt [`weight'`exp']
   return local opts `options'
end
