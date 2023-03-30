capture program drop _all
 
 program sscore 
	syntax anything [if] [in] , ivars(varlist fv) bystrata(varlist) ///
								[ survey(varname) depvar(varlist) pca weight(varname) method(string) ] 
	
	if "`pca'"!="" {
	    sscore_pca    `0'
	}
	else if "`survey'"!="" {
	    sscore_pscore `0'
	}
	else if "`depvar'"!="" {
	    sscore_vpca   `0'
	}
	else {
	    display as error "No options specified. Did nothing"
	}
	
 end

 program display_dots
	syntax ,  ndots(int) [maxdot(int 50)]
	if mod(`ndots',`maxdot')!=0 {
		display _c as text "."
	}
	else {
		display _c as text "." as result "`ndots'" _n
	}
 end
 
 program sscore_vpca ,
	syntax anything [if] [in] , ivars(varlist fv) bystrata(varlist) ///
								[ survey(varname) depvar(varlist) pca weight(varname) method(string) ] 
	tempvar pcax touse
	qui {
	    gen byte `touse' = 0
		replace `touse'=1  `if' `in'
		markout `touse' `ivars'    `bystrata' `weight' 
	}
	
	foreach k of varlist `depvar' {
		tempvar `k'
		qui:gen double ``k''=.
		local nlist `nlist' ``k''
		local dcount=`dcount'+1
	}
	
	foreach i of varlist `bystrata' {
	    qui:levelsof `i' if `touse', local(level)
		local wrds:word count `level'
		if `wrds'>500 {
		    display in red "too many (500+) levels `i'" _n "Skipping variable"
		}
		else {
			display _n "Calculating matching scores for " as result "`i'" as text " with " as result "`wrds'" as text " levels"
		    gen double `anything'_`i' = . 
			local ndots = 0
		    foreach j of local level {
				local ndots = `ndots'+1
				display_dots, ndots(`ndots')
			    foreach k of varlist `depvar' {
					qui:capture: regress `k' `ivars' if `i' == `j' & `touse'  
					if _rc ==0 {
						qui:capture drop `pcax'	
						qui: predict `pcax' 
					}
					else {
						qui:replace `pcax'=0
					}
					qui:replace ``k'' = `pcax' if `i' == `j' & `touse'
				}
				if `dcount'>1 {
					qui:capture: pca `nlist' if `i' == `j' & `touse' , comp(1)
					if _rc ==0 {
						qui:capture drop `pcax'
						qui: predict `pcax' 
					}
					else {
						qui:replace `pcax'=0
					}
					qui:replace `anything'_`i' = `pcax' if `i' == `j'  & `touse'
				}
				else {
				    qui:replace `anything'_`i' = `nlist' if `i' == `j'  & `touse'
				}
			}
			
		}
	}
end
	
program sscore_pscore ,
	syntax anything [if] [in] , ivars(varlist fv) bystrata(varlist)  ///
								[ survey(varname) depvar(varlist) pca weight(varname) method(string) ] 
/// this will create a more traditional Score. xb just bc
	tempvar pcax touse
	qui {
	    gen byte `touse' = 0
		replace `touse'=1  `if' `in'
		markout `touse' `ivars' `survey' `bystrata' `weight' 
	}
	if "`method'"=="" {
	    local method regress
	}
	if "`weight'"!="" {
		local pw pw=
	}
	tempvar ssurvey
	qui:egen byte `ssurvey'=group(`survey') if `touse'
		qui:sum `ssurvey' if `touse', meanonly
	***
	if r(max)>2 {
		display "More than 2 groups detected. Only 2 groups allowed"
		error 1
	}
	else if r(max)==1 {
	    display "Only 1 group detected. 2 groups required"
		error 1
	}
	qui:replace `ssurvey'=`ssurvey'==2 if `touse'
	tempvar vals 
	foreach i of varlist `bystrata' {
	    qui:levelsof `i', local(level)
		local wrds:word count `level'
		if `wrds'>500 {
		    display in red "too many (200+) levels `i'" _n "Skipping variable"
		}
		else {
			display _n "Calculating matching scores for " as result "`i'" as text " with " as result "`wrds'" as text " levels"
			gen double `anything'_`i' = . 
			local ndots = 0
		    foreach j of local level {
				local ndots = `ndots'+1
				display_dots, ndots(`ndots')
				
				qui:capture: `method' `ssurvey' `ivars' if `i' == `j' & `touse' [`pw'`weight'], 
				
				if 	_rc==0 {
					capture drop `pcax'
					qui: predict `pcax' , xb
					qui: replace `anything'_`i'=`pcax' if `i' == `j' & `touse'
				}
				else {
					qui: replace `anything'_`i'=0 if `i' == `j' & `touse'
				}
			}
			
		}
	}
end
 
program sscore_pca ,
	syntax anything [if] [in] , ivars(varlist fv ) bystrata(varlist) ///
								[ survey(varname) depvar(varlist) pca weight(varname) method(string) ] 
	
	tempvar pcax touse
	qui {
	    gen byte `touse' = 0
		replace `touse'=1  `if' `in'
		markout `touse' `ivars'   `bystrata' `weight' 
	}
	
	ms_fvstrip `ivars', expand 
	local ivlist `r(varlist)'
	local nivlist
	foreach j in  `ivlist' {
	    qui:capture confirm var `j'
		if _rc ==0 {
			local nivlist `nivlist' `j'
		}
		else {
		    local cnt = `cnt'+1
			tempvar var`cnt'
			qui:gen double `var`cnt'' = `j'
			local nivlist `nivlist' `var`cnt''
		}
	}
	
	tempvar pcax
	foreach i of varlist `bystrata' {
	    qui:levelsof `i', local(level)
		local wrds:word count `level'
		if `wrds'>500 {
		    display in red "too many (500+) levels `i'" _n "Skipping variable"
		}
		else {
			display _n "Calculating matching scores for " as result "`i'" as text " with " as result "`wrds'" as text " levels"
		    gen double `anything'_`i' = . 
			local ndots = 0
		    foreach j of local level {
				local ndots = `ndots'+1
				display_dots, ndots(`ndots')
			    qui:capture: pca `nivlist' if `i' == `j' & `touse', comp(1)
				if _rc ==0 {
				qui:capture drop `pcax'
				qui: predict `pcax' 
				}
				else {
				qui:replace `pcax'=0
				}
				qui:replace `anything'_`i'=`pcax' if `i' == `j' & `touse'
			}
			
		}
	}
end	