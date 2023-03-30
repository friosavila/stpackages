*! 1.0 checkvar: module to check if any of the variables in the list is present.

*capture program drop drop2
program checkvar, rclass
	novarabbrev {
		syntax anything 
		foreach i in `anything' {
			capture noisily fvexpand `i'			
			if _rc == 0 {
				local cvar `cvar' `r(varlist)' 
			}
		}
	}
	return local cvar `cvar'
end
