*! v1 FRA Fail safe for F_able. This drops if __varname exists. If not just creates clones to keep copies.
program f_able_prolog
	local idepvar `e(nldepvar)'
	foreach i of local idepvar {
		*qui:capture drop __`i'
    	qui:clonevar __`i'=`i'
	}
end
