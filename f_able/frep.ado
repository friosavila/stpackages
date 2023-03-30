*! v1.01 FRA Change frep. Note needed to be stored without Quotes
program frep 
	syntax varname =/exp [if] [in] 
	qui:recast double `varlist'
	replace  `varlist'=`exp' 
    if strlen("`exp'")<75 {
	    label var `varlist' "`exp'"
	}
	else {
		qui:notes drop `varlist'	
		label var `varlist' "See notes"
		note `varlist': `exp'
	}
	char `varlist'[fbl] "fable"
end
