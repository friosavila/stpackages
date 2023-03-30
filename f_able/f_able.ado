*! v2.0 FRA adds option auto, to exclude nlvars of covariates. 
*  v1.1 FRA Extra safe guards to make sure fable is used correctly

** This program will try to make an exhaustive search of commands from which obtain the list of covariates
 program f_able_cov, eclass
	*** stripper
	local coln:colnames e(b)
	local coln=subinstr("`coln'","#"," ",.)
	local coln=subinstr("`coln'","c.","",.)
	local coln=subinstr("`coln'","co.","",.)
	local coln=subinstr("`coln'","o.","",.)
	local coln=subinstr("`coln'","_cons","",.)
	**this identifies what are variables
	foreach i of local coln {
	    error 0
	    capture qui _ms_dydx_parse `i'
		if _rc==0 {
			local coln2 `coln2' `i'
		}
	}
	**This eliminates doubles.
	foreach i of local coln2 {
	    local flag=1
	    foreach j of local coln3 {
			if ("`i'"=="`j'") {
				local flag=0
			}
		}
		if `flag' == 1 {
			local coln3 `coln3' `i'
		}
	}
	ereturn local covariates `coln3' 
end	

program f_able, eclass
	syntax [varlist(default=none)], [NLvar(varlist)] [auto]
	*** This should detect all covariates
	*f_able_cov
		local nlvar `varlist' `nlvar'
 		if "`nlvar'"=="" {
			display "nothing was declared"
			exit
		}					
	*** This captures all variables in List of covariates
		_ms_dydx_parse `nlvar'
		ereturn local margins_cmd "fmargins"
	if "`e(predict_old)'"=="" {
		ereturn local predict_old  `e(predict)'
		ereturn local predict  		f_able_p
	}
	foreach i of varlist `nlvar' {
		local fnc:variable label `i'
		if "`fnc'"=="See notes" {
		    local fnc: char `i'[note1]
		}
		** Here we check if working
		if "`fnc'"=="" {
			display in red "Variable `i' contains no information" _n "either label the variable or use " as text "fgen or frep" in red " to generate the variable"
			error 111
		}
		else {
			tempvar xvar
			capture gen double `xvar'=`fnc'
			if _rc!=0 {
				display in red "The function stored in label or note for variable `i' is not valid" _n "please verify that information is correct"
				exit 111
			}
			else if _rc==0 {
				qui:count if `xvar'!=`i'
				if r(N)==0 {
					ereturn hidden local _`i' `fnc'
				}
				else {
					display in red "The function stored in label or note for variable `i' " _n "does not reproduce the original variable" _n "please verify that information is correct"
					exit 111
				}
			}
			capture drop `xvar'
		}		
	}
	if "`auto'"!="" {
		f_able_cov
		local covr `e(covariates)'
		display "This is an experimental feature in f_able" _n ///
		        "Using this option, you do not need to add {cmd:nochain} or {cmd:numerical} options in margins"
 		foreach i of local covr {
			local flag=0
			foreach j of local nlvar {
				if "`i'"=="`j'" {
					local flag=1
				}
			}
			if `flag'==0 {
				local covr2 `covr2' `i'
			}
		}
  		ereturn local covariates `covr2'	
	}
	if "`auto'"=="" {
		display "Do not forget include {cmd:nochain} and {cmd:numerical} when obtaining margins" 
	}
 
	ereturn local nldepvar `nlvar'
	*ereturn local covariates `covr2'
	ereturn hidden local margins_prolog f_able_prolog
	ereturn hidden local margins_epilog f_able_epilog
	
	display "All variables in -nlvar- have been declared"
end
