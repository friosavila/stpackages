*!v1.1 FRA resets cmd
*!v1 FRA restores Est attributes
program f_able_reset, eclass
	if "`e(predict_old)'"!="" {
		ereturn local predict `e(predict_old)'
		ereturn local predict_old  
	}
	
	foreach i of varlist `e(nldepvar)' {
		ereturn hidden local _`i' 
	}
	ereturn local nldepvar 
	ereturn local margins_prolog  
	ereturn local margins_epilog 
	ereturn local margins_cmd
end