frause oaxaca, clear
program fuzz_binomial
	syntax newvarlist(max=1),[size(real 1.0)]
	if inlist("`e(cmd)'","logit") {
		tempvar xb
		predict double `xb', xb
		gen double `varlist'=logistic(`xb'+rlogistic()*`size')
	}
	else if inlist("`e(cmd)'","probit") {
		tempvar xb
		predict double `xb', xb
		gen double `varlist'=logistic(`xb'+rnormal()*`size')
	}
end
program fuzz_multinomial
	syntax namelist(max=1), [size(real 1.0)]
	forvalues i = 1/`e(k_out)' {
		confirm new variable `namelist'`i'
	}
	
	if inlist("`e(cmd)'","mlogit") {
		** Create gumble
		tempvar tl
		gen double `tl'=0
		forvalues i = 1/`e(k_out)' {
			tempvar g`i' l`i'	 
			gen double `g`i'' = -ln(-ln(runiform()))
			local ii:word `i' of `e(eqnames)'
			predict double `l`i'', xb outcome(`ii')
			replace `tl'=`tl'+exp(`l`i'' + `g`i''*`size')			
		}
		forvalues i = 1/`e(k_out)' {
			gen double `namelist'`i' = exp(`l`i''+`g`i''*`size')/`tl'
		}		
	}
	
end

 