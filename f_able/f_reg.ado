*! v1 To make automatic reg selection
*capture program drop f_reg
*capture program drop f_able_covx
 program define f_reg, 
	syntax anything(everything), [*]
	*gettoken cmd z:anything
	`0'
	f_able_covx
	qui:{
	foreach i in `r(covariates)' {
	    if "`:char `i'[fbl]'"=="fable" {
		    local fblist `fblist' `i'
		}
	}
	}
	f_able `fblist', auto
end

program f_able_covx, rclass
	*** stripper
	local coln:colnames e(b)
	local coln=subinstr("`coln'","#"," ",.)
	local coln=subinstr("`coln'","c.","",.)
	local coln=subinstr("`coln'","co.","",.)
	local coln=subinstr("`coln'","o.","",.)
	local coln=subinstr("`coln'","_cons","",.)
	local coln=subinstr("`coln'","."," ",.)
	**this identifies what are variables
	foreach i of local coln {
	    error 0
	    capture qui _ms_dydx_parse `i'
		if _rc==0 {
			local coln2 `coln2' `i'
		}
	}
	**This eliminates doubles.
	foreach i of local coln2 {
	    local flag=1
	    foreach j of local coln3 {
			if ("`i'"=="`j'") {
				local flag=0
			}
		}
		if `flag' == 1 {
			local coln3 `coln3' `i'
		}
	}
	return local covariates `coln3' 
end	