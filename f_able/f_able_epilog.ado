*! v1.1 fixes epilog for Stata14 
* v1 FRA fail safe for F-able. If post not used, this will drop temp vars. and update them to the correct ones.
program f_able_epilog
	syntax [anything]
	if `c(stata_version)'<15 {
		local anything `e(nldepvar)'
	}
	foreach i of local anything {
	    qui:replace `i'=__`i'
		qui:drop __`i'
	}
end
