capture program drop myreg
program myreg, eclass sortpreserve byable(recall) properties(svyb svyr svyj)
	syntax anything [if] [in] [iw pw fw aw], [*]
	regress `anything' `if' `in' [`weight'`exp'], `options'
	ereturn local predict rif_p
end
program drop rif_p
program rif_p
	syntax anything(id="newvarname") [if] [in] , [*]
	    regres_p `0'
end