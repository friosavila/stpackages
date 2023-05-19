program drop kdensity_eye
program kdensity_eye
	syntax varlist [aw], [IQR1(numlist min=2 max=2 >0 <100) ] ///
						 [IQR2(numlist min=2 max=2 >0 <100)] ///
						 [IQR3(numlist min=2 max=2 >0 <100)] ///
						 [IQR4(numlist min=2 max=2 >0 <100)] ///
						 [IQR5(numlist min=2 max=2 >0 <100)] ///
						 [offset(real 0.0) wm(numlist min=1 max=1 >0)]
	local block_t = 1
	if "`wm'"=="" local wm 1
	while `block_t' {
		local j = `j'	+1
		local jj=`j'*`wm'
		capture numlist "`iqr`j''", sort
		if _rc==0 {
			local nmlist  `r(numlist)'
			_pctile `varlist', percentiles(`nmlist')
			local m0 `r(r1)'
			local m1 `r(r2)'
			local zerop = 0 + `offset'
			local eye `eye' (pci `zerop' `m0' `zerop' `m1', lw(`jj') pstyle(p1) )
		}
		else local block_t=0
	}
	two (kdensity `varlist') `eye'
end 