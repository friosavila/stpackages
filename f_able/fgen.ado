*! v1.02 FRA Adds Characteristics Fable
*! v1.01 FRA Change fgen. Note needed to be stored without Quotes
program fgen
	syntax newvarname =/exp [if] [in] 
	local typelist double
	gen `typelist' `varlist'=`exp' 
	if strlen("`exp'")<75 {
	    label var `varlist' "`exp'"
	}
	else  {
	    label var `varlist' "See notes"
		note `varlist': `exp'
	}
	char `varlist'[fbl] "fable"
end