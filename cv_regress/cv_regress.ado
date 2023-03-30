*! v1.1 5 10 2020 Correction for a bug. when the leverage statistic ->1 there is a considerable rounding error for the estimation of 
*!                LOO yhat. The solution here is to use OLD FASHION method for cases with LARGE Leverages. 
capture program drop cv_regress
capture program drop reparser
program define cv_regress, rclass
syntax ,[cvwgt(varname) generr(str) genlev(str) genhat(str)]
**  verify version
    if `c(stata_version)'<7 {
	    display in red "You need Stata 7.0 or higher"
	}
* Step 1. Verify the right command was excecuted in the previous step
	
	if e(cmd)!="regress" {
		display in red ("Last estimates not found or not a regress command")
		display in red ("This version  of the program only allows for regress command")
		exit 
	}
	if "`e(wtype)'"!="" {
		if e(wtype)=="pweight" {
			display in red ("Program not compatible with Robust estimation")
			display in red ("Use aweights, iweights or fweights")
			exit	
		}
	}	
	** check for new variables
	if "`generr'`genlev'`genhat'"!="" {
	    confirm new variable `generr' `genlev' `genhat', exact
	}
	** determine subsample
	tempvar esample
	qui:gen `esample'=e(sample)
	** determine dependent variable and weight
	local yy: word 2 of `e(cmdline)'
	local aux=e(cmdline)
	local wgtwgt:word 2 of `e(wexp)'
	 
	** estimate model predicted value
	tempvar yy_hat lvrg
	qui:predict double `yy_hat' if `esample'==1,
	qui:predict double `lvrg'   if `esample'==1, hat
	 	
	** Estimate leverage adjustment
	tempvar lv_adj
	qui:gen double `lv_adj'=1
	if "`e(wtype)'"=="aweight" {
		qui:sum `wgtwgt' if `esample'==1, meanonly
		qui:replace `lvrg'=`lvrg'*`wgtwgt'/r(mean)
	}
	if "`e(wtype)'"=="fweight" | "`e(wtype)'"=="iweight" {
		qui:replace `lvrg'=`lvrg'*`wgtwgt'
	}
	
	** Added step If lvrg is so close to 1 that makes the program fail.
	tempvar flag
	qui:gen byte `flag'=1 if abs(1-`lvrg')<epsfloat()*100
	
	** Estimate out of sample prediction
	tempvar yloo_hat
	qui:gen double `yloo_hat'=`yy'-(`yy'-`yy_hat')/(1-`lvrg')
	
	** use regression method for special cases
	qui: {
		tempvar n
		gen `n'=_n
		levelsof `n' if `flag'==1, local(slist)
		
		local  cmdln=subinstr("`e(cmdline)'","`e(cmd)'","",1)
		reparser `cmdln'
		local y_x `r(y_x)'
		local wgt `r(wgt)'
		local opts  `r(opts)'
		tempvar yhx
		foreach i of local slist {
			regress `r(y_x)' `wgt' if `esample' & `n'!=`i'
			predict double `yhx'
			replace `yloo_hat'=`yhx' if `esample' & `n'==`i'
			capture drop `yhx'
		}
	}	
	
	** Estimate estatistcs of interest
	tempvar _mse _mae 
	gen double `_mse'=(`yy'-`yloo_hat')^2
	gen double `_mae'=abs(`yy'-`yloo_hat')
	
	if "`cvwgt'"=="" {
		sum `_mse' if `esample'==1, meanonly
		local mse=r(mean)
		sum `_mae' if `esample'==1, meanonly 
		local mae=r(mean)
		capture:qui:corr `yy' `yloo_hat' if `esample'==1
		capture:matrix c=r(C)
		capture:local pr2=c[1,2]^2
		local rmse=(`mse')^0.5
		local lmse=ln(`mse')
	}
	
	else {
		sum `_mse' [aw=`cvwgt'] if `esample'==1, meanonly
		local mse=r(mean)
		sum `_mae' [aw=`cvwgt'] if `esample'==1, meanonly
		local mae=r(mean)
		capture: qui:corr `yy' `yloo_hat' if `esample'==1 [aw=`cvwgt']
		capture:matrix c=r(C)
		capture:local pr2=c[1,2]^2
		local rmse=(`mse')^0.5
		local lmse=ln(`mse')
	}
	
	display _newline
	display as text "Leave-One-Out Cross-Validation Results "
	if "`cvwgt'"!="" {
	display as text "Statistics are estimated using -`cvwgt'- as weights"
	}
	di as text "{hline 25}{c TT}{hline 15}"		
	di as text "         Method          {c |}" _col(30) " Value"
	di as text "{hline 25}{c +}{hline 15}"	
	display as text "Root Mean Squared Errors {c |}" _col(30) as result  %10.4f `rmse'
	display as text "Log Mean Squared Errors  {c |}" _col(30) as result  %10.4f `lmse'
	display as text "Mean Absolute Errors     {c |}" _col(30) as result  %10.4f `mae'
	display as text "Pseudo-R2                {c |}" _col(30) as result  %10.5f `pr2'
	di as text "{hline 25}{c BT}{hline 15}"		

	if "`generr'"!="" {
		qui:gen double `generr'=(`yy'-`yloo_hat') if `esample'==1
		display as text "A new Variable -`generr'- was created with (y-E(y_-i|X))"
	}
	if "`genhat'"!="" {
		qui:gen double `genhat'=`yloo_hat' if `esample'==1
		display as text "A new Variable -`genhat'- was created with E(y_-i|X)"
	}
	if "`genlev'"!="" {
		qui:gen double `genlev'=`lvrg' if `esample'==1
		display as text "A new Variable -`genlev'- was created with Leverage h(x)"
	}
	return scalar pr2=`pr2'
	return scalar lmse=`lmse'
	return scalar rmse=`rmse'
	return scalar mae=`mae'
end

program define reparser, rclass
syntax anything [if] [in] [aw pw iw fw], [*]
   * first word will be command
   return local y_x `anything'
   return local wgt [`weight'`exp']
   return local opts `options'
end