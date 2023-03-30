*! v1.1 Updates all predicted values Faster option
program f_able_p
	syntax newvarname [if] [in], [*]
	local idepvar `e(nldepvar)'
	foreach i of local idepvar {    
 			*tempvar _`i'
			*qui:clonevar `_`i''=`i'	
			qui:replace `i'=`e(_`i')'
	}
	`e(predict_old)' `0'
*	foreach i of local idepvar {
*	    if "`i'"!="_cons" {
*			qui:replace `i'=__`i'
*		}
*	}
end
