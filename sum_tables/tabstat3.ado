capture program  drop tabstat3
program define tabstat3, rclass
	syntax varlist(numeric) [if] [in] [aw fw] [ , save *]
	tempname tstat
	tabstat `0'
	mata:st_matrix("aux",(st_matrix("r(Stat1)"):/st_matrix("r(Stat2)"))\(st_matrix("r(Stat1)"):/st_matrix("r(Stat2)")))
	
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
		matrix 	`tstat'=`tstat',aux
		return matrix tstat = `tstat'
	}
end

