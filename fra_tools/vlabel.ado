*! v0.1 Labels V1 with values of LV1 (assumes matching)
program vlabel, 
	args v1 lv1
	qui: {
		local tt = _N
		forvalues i = 1/`tt' {
			label define `v1' `=`v1'[`i']' `"`=`lv1'[`i']'"', modify
		}
		label values `v1'	 `v1'
	}
end