* v0.1 Join Dummies
*capture program drop vjoin

program vjoin
	syntax varlist [if] [in], [name(name) varlab(string asis) replace]
	display "Assumes all variables are mutually exclusive" _n ///
            "Using var=1 to identify a group"
	if "`name'"=="" {
		capture drop newvar
		local name newvar
	}
	else {
        if "`replace'"=="" confirm new variable `name'
    }
	foreach i of local varlist {
		qui:levelsof `i'
		if `r(r)'>2 {
			display "All Variables should have only 2 levels"
			error 1233
		}
	}
	capture gen `name'=0 `if' `in'
	foreach i of local varlist {
        local jj = `jj'+1
		qui:levelsof `i'
		qui:replace `name'=`jj' if `i'==1
        
        if `"`:variable label `i''"'!="" local tolab `tolab'  `jj' "`:variable label `i''"
        else                             local tolab `tolab'  `jj' `i'   
	}
    label define `name' `tolab', modify
    label values `name' `name'
    label variable `name' "`varlab'"
end

