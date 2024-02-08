*! v0.1 Very Basic!
capture program drop canayqreg
program define canayqreg, eclass
syntax varlist(fv ts) [if] [in] [iw], ABSorb(varlist)    /// variables to absorb
		[Quantile(numlist >0 <100) /// quantile to estimate <- Lets use numbers between 0-100
		 qmethod(str asis) ///		
		 MODified bs *]  
		 
marksample touse
markout `touse' `absorb'

// Setting Seed
if "`seed'"!="" set seed `seed'

// Getting Quantile
if "`quantile'"=="" local quantile = 50

// qmethod.

if "`qmethod'"=="" local qmethod qreg
if "`qmethod'"=="qrprocess" local quantile = `quantile'/100

// Setup Y and X
	tokenize `varlist'
	local yvar `1'
	macro shift
	local xvar `*'

// Getting fixed effects

	foreach i of local absorb {
		local j = `j'+1
		if "`modified'"=="" {
			tempvar f`j'
			local toabs `toabs' `f`j''=`i'
			local vlist `vlist' `f`j''
		}	
		else {
			capture drop __f`j'__
			local toabs `toabs' __f`j'__=`i'
			local vlist `vlist' __f`j'__
		}
	}
	
//  Step 1 in Canay's method: Obtain FEs
	capture drop __fe__
	
	quietly: reghdfe `yvar' `xvar' if `touse', abs(`toabs') keepsingletons
	qui: gen double __fe__	= 0 if e(sample)
//  Aggregating FE
	
	if "`modified'" =="" {
		foreach i of local vlist {
			replace __fe__=__fe__+`i'
		}
	}
	
	* Step 2: Simple version, Requires Modifying Dep variable

	tempname bq
	
	if "`modified'" != "" {		
		`qmethod' `yvar' `xvar' `vlist' if `touse', q(`quantile')  	 	`options'
	}
	else {
		// Canay Original
		tempvar yvar_hat			
		qui: gen double `yvar_hat' = `yvar' - __fe__
		`qmethod' `yvar_hat' `xvar'       if `touse', q(`quantile')	    `options'
	}
	
	if "`bs'"=="" display in white "Std Errors are not valid for Inference. Try bscanayreg"
	ereturn local depvar "`yvar'"
	ereturn local quantile `quantile'
end

 