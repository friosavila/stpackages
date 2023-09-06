*! v1.03 FRA Allows for other formats. With Care
*! v1.02 FRA Adds Characteristics Fable
*! v1.01 FRA Change fgen. Note needed to be stored without Quotes
program fgen
	syntax newvarname =/exp [if] [in] 
	local sm0 "`typlist'"

	set type double
	syntax newvarname =/exp [if] [in]

	gen `typlist' `varlist'=`exp' 
	if strlen("`exp'")<75 {
	    label var `varlist' "`exp'"
	}
	else  {
	    label var `varlist' "See notes"
		note `varlist': `exp'
	}
	char `varlist'[fbl] "fable"
	set type `sm0'
end