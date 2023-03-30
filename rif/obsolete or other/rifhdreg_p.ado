program drop rifhdreg_p
program rifhdreg_p
	syntax anything(id="newvarname") [if] [in] , [SCores * ]
	if "`scores'"!="" {
		tempvar rif _xb wgt
		qui: gen double `wgt'=1
		if "`e(wexp)'"!="" replace `wgt'`e(wexp)'
		qui: egen double `rif'=rifvar(`e(depvar)') `if' `in', `e(rif)' weight(`wgt') seed(`e(fseed)') by(`e(rifover)')
		local dvar `e(depvar)'
		add_dvar  `rif'*/
		regres_p `0'
		/*add_dvar `dvar'*/
 	}
	else {
	    regres_p `0'
	}
end
capture program drop add_dvar
program add_dvar, eclass
   ereturn local depvar `1'
end