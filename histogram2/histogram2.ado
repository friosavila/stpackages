*capture program drop histogram2
*program drop parse_colors
program histogram2
	syntax varname [if] [in] [fw], ///
		by(varname) ///
		[bin(numlist >0) width(numlist >0) start(numlist ) * freq color(passthru)]
	// Setup sample
    	marksample touse
		markout `touse' `by'
	// Do we need Bin width start?
		sum `varlist' `if' [`weight'`exp'], meanonly
		local min = r(min)
		local max = r(max)
		local nobs= r(N)
		if "`start'"=="" local start = `min'
		else             local start = max(`start',`min')
	// what matters most is width	
 		if "`bin'`width'"=="" {
			local bin = round( min(sqrt(`nobs'), 10*ln(`nobs')/ln(10)) )
			local width = (`max'-`min')/`bin'
		}
		else if "`bin'"!="" {
			local width = (`max'-`min')/`bin'
		}
 	// levels of by
	qui:levelsof `by' if `touse', local(bylvl)
	parse_colors, `color'
  	foreach i of local bylvl {
		local jj = `jj'+1
		local toplot `toplot' ///
			  (histogram `varlist' if `touse' & `by'==`i', ///
			  `freq' pstyle(p`jj') color(`r(rcolor`jj')') start(`start') width(`width'))
	}
 	// plot
 	two `toplot', `options'
end	

program parse_colors, rclass
	syntax, [color(string asis)]
	forvalues i = 1/15 {
		gettoken thiscolor color: color, parse(",") 
 		if `"`thiscolor'"'=="," {
			gettoken thiscolor color: color, parse(",")   
		}
		if `"`thiscolor'"'!="" {
				local lastcolor `"`thiscolor'"'
			}
			else local thiscolor `"`lastcolor'"'
			return local rcolor`i' `"`thiscolor'"'		
	}
end

