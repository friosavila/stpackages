sysuse auto, clear
capture program drop table_by_stat
program table_by_stat , rclass
syntax varlist [if] [in], [weight(varname) label stat(name) * ]  by(varlist min=1 max=3)
	if "`weight'"=="" {
		tempvar weight
		gen byte `weight'=1
	}
	if "`stat'"=="" {
		local stat mean
	}
	tempname frm
	frame put `varlist' `by' `weight' `if' `in', into(`frm')
	frame `frm':collapse (`stat') `varlist' [aw=`weight'] , by(`by') fast
	qui: foreach i in `varlist' {
		if "`label'"!="" {
			local lvl: variable label `i'
			frame `frm':label var `i' "`lvl'"
		}
		else {
			frame `frm':label var `i' `i'
		}
	}
	frame `frm':tabdisp `by', cellvar(`varlist') `options'
	frame `frm' {
		* is by string?
		capture confirm numeric variable `by' 
		local oby `by'
		if _rc==7 {
			tempvar by2 
			encode `by', gen(`by2')
			local by `by2'
		}
 		
		tempname aux res
		qui:levelsof `by',local(lby)
		foreach i of local lby {
			mkmat `varlist' if `by'==`i', matrix(`aux')
			matrix `res'=nullmat(`res')\ `aux'
			local rlv:label (`by') `i' 
			local rlv =  subinstr("`rlv'"," ","_",.)
			local rlv =  subinstr("`rlv'",".","_",.)
			local rowname `rowname' `rlv'
		}
		* for rownames
				
		matrix colname `res'= `varlist'
		matrix rowname `res'= `rowname'
		return matrix table = `res'
	}
end

 
 


