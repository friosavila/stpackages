capture program drop _all
program myreg, eclass sortpreserve byable(recall) properties(svyb svyr svyj)
capture set prefix 
display in w "`c(prefix)'"
syntax anything [if] [in] [iw pw fw aw], [*]
if "`weight'"=="iweight" & "`c(prefix)'"=="svy" regress `anything' `if' `in' [pw`exp'], `options'
else regress `anything' `if' `in' [`weight'`exp'], `options'
ereturn local predict rif_p

end
 program rif_p
  syntax anything(id="newvarname") [if] [in] , [*]
 regres_p `0'
end

   . webuse nhanes2f
    . svyset psuid [pweight=finalwgt], strata(stratid)
    . svy: regress zinc
    . svy: 	myreg zinc 
