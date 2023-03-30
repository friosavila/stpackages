capture program drop sum_table
program sum_table, rclass
syntax varlist(fv) [if] [in]  [aw fw iw] [, by(varname)  ]
ms_fvstrip `varlist', expand 
local vlist `r(varlist)'
tempname res aux aux2
	if "`by'"!="" {
	    local oby `by'
	    tempvar by2
		confirm numeric variable `by'
		if _rc==7 {
			encode `by', gen(`by2')			 
			local by `by2'
		}
	}
	if "`by'"!="" {
	    qui:levelsof `by', local(lby)
		foreach j of local lby {
		    capture matrix drop `aux2'
			foreach i of local vlist {
				qui:sum `i' `if' `in' if `by'==`j' [`weight'`exp']
				matrix `aux' = [ r(mean) , r(sd)]
				matrix colname `aux' = mean sd
				matrix coleq `aux' = "`oby'-`j'"
				matrix rowname `aux' = `i'
				matrix `aux2' = nullmat(`aux2') \ `aux'
			}
			matrix `res'=nullmat(`res'),`aux2'
		}	
	}	
	else {
	    foreach i of local vlist {
			qui:sum `i' `if' `in' [`weight'`exp']
			matrix `aux' = [ r(mean) , r(sd)]
			matrix colname `aux' = mean sd
			matrix rowname `aux' = `i'
			matrix `res' = nullmat(`res') \ `aux'
		}
	}
	matrix list `res'
end
*ms_fvstrip i.foreign, expand 