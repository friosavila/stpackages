*! 1.0 sum2: module to summarize variables in data
*** Does not give error if variable doesnt exist
*capture program drop sum2
program sum2
	novarabbrev {
		syntax anything [if] [in] [iw fw aw],  [*]
		foreach i in `anything' {
			capture noisily fvexpand `i'			
			if _rc == 0 {
				local flist  `flist' `r(varlist)'
			}
		}
		sum `flist' `if' `in' [`weight'`exp'], `options'
	}
end
