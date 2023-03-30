capture program  drop tabstat2
program define tabstat2, rclass
	 syntax varlist(numeric) [if] [in] [aw fw] [ , save *]
	 tempname tstat
	 tabstat `0'
	if "`save'"!="" {
	    local i = 1 
		local nm = r(name`i')
		while "`nm'"!="" {
		    tempname m
			matrix `m'=r(Stat`i')
			matrix roweq `m' = "`r(name`i')'"
			matrix `tstat' = nullmat(`tstat') \ `m'
			local i =`i'+1
			local nm  `r(name`i')'
		}	    
		
		return matrix tstat = `tstat'
	}
	
end