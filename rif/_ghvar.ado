* This is an example of a program that can be used to estimate other RIFs that are not yet available in rifvar
* but the user may still want to use it with the oaxaca_rif and rifhdreg command.
* This program is meant to estimate the RIF of what i call Half variance:
* half variance positive hvp(x)=sum((X-E(X))^2*(X>E(X))) 
* half variance negative hvn(x)=sum((X-E(X))^2*(X<E(X))) 
* the options hvp and hvn can be used to specify if hvp or hvn will be estimated.
* and i ll assume the default is hvp
* The RIF will be estimated using the Jackknife approach.
*capture program drop _ghvar
program define _ghvar, sortpreserve 
	syntax newvarname =/exp [if] [in], [weight(varname) BY(varlist) hvp hvn]
	* options weight() and BY(*) are mandatory. other options in this case  "hvp hvn" can be added but are optional
	local exp = regexr("`exp'", "\(", "")
	local exp = regexr("`exp'", "\)", "")
	local exp = regexr("`exp'", " ", "")
	qui {
		* defining sample
		
		tempvar touse
		gen byte `touse'=1
		markout `touse' `weight' `exp' `by' 
		sort `touse' `by' `exp' 
		if "`weight'"=="" {
		   local weight=1
		   local fweight=0
		}
		* Checking options
		if "`hvp'"!="" & "`hvn'"!="" {
		*Display error
			noisily display in red "Only one option allowd"
			exit
		} 
		
		if "`hvn'"!="" {
			 local option =2
		} 
		else local option=1
		
		** Statistic calculation Half Variance
		tempvar mn tt hvar t
		by  `touse' `by':gen double `mn'=sum(`exp'*`weight')
		by  `touse' `by':gen double `tt'=sum(`weight')
		if `option'==1 {
			by  `touse' `by':egen double `hvar'=sum((`exp'-`mn'[_N]/`tt'[_N])^2*`weight'/`tt'[_N]*(`exp'>(`mn'[_N]/`tt'[_N])))
		}
		if `option'==2 {
			by  `touse' `by':egen double `hvar'=sum((`exp'-`mn'[_N]/`tt'[_N])^2*`weight'/`tt'[_N]*(`exp'<(`mn'[_N]/`tt'[_N])))
		}
		
		** if Function 
		tempvar N n jkvar jfrif
		gen double `jfrif'=.
		by  `touse' `by':gen double `N'=_N
		by  `touse' `by':gen double `n'=_n
		qui:sum `N' 
		local nmax=r(max)
		** JK estimates the statistic for ALL statistics excluding observation i
		forvalues i=1/`nmax' {
			capture drop `mn' 
			capture drop `t'
			capture drop `jkvar'
				by  `touse' `by':egen double `mn'=sum(`exp'*`weight'*(`n'!=`i')) 
				by  `touse' `by':egen double `t'=sum(`weight'*(`n'!=`i'))
				if `option'==1 {
					by  `touse' `by':egen double `jkvar'=sum((`exp'-`mn'/`t')^2*`weight'/`t'*(`exp'>(`mn'/`t'))*(`n'!=`i'))
				}
				if `option'==2 {
					by  `touse' `by':egen double `jkvar'=sum((`exp'-`mn'/`t')^2*`weight'/`t'*(`exp'<(`mn'/`t'))*(`n'!=`i'))
				} 
				
				replace `jfrif'= `hvar'+(`hvar'-`jkvar')*`tt'[_N]/`weight' if `n'==`i'
			}
		}
		** saving results
		qui: by `touse' `by': gen `typlist' `varlist' = `jfrif'    if `touse'
		if `option'==1 {
			label var `varlist' "RIF for Positive Half variance of `exp'"
		}
		if `option'==2 {
			label var `varlist' "RIF for Negative Half variance of `exp'"
		}


end

