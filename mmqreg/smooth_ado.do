program drop _parse_smqreg 
program _parse_smqreg , rclass
	syntax anything
	
	gettoken p1 p2:0, parse("()")
	gettoken y   x :p1 
	local p2 `=subinstr("`p2'","(","",.)'
	local p2 `=subinstr("`p2'",")","",.)'
	gettoken y1  z :p2 , parse("=")
	local z  `=subinstr("`z'","=","",.)'
	return local yvar   `y'
	return local xvar   `x'
	if "`y1'"!="" return local y1var  `y1'
	if "`z'"!="" return local zvar   `z'
end
program drop smqreg
program smqreg, eclass
syntax anything [if] [in] [aw pw iw fw], [Quantile(int 50) * kernel(str) bw(int 0) from(str)]
	** Stripdown variables
	_parse_smqreg `anything'
	local q  = `quantile'/100
	local y  = r(yvar)
	local x  = r(xvar)
	if "r(y1var)"!=""	local y1   `r(y1var)'
	if "r(zvar)"!=""    local z    `r(zvar)'
 	marksample touse, novar
	markout    `touse' `y' `x' `y1' `z'
	**get Initial values
	tempname bini
	qui:reg `y' `x' `y1' if `touse' [`weight'`exp']
	matrix `bini'=e(b)
	tempvar res
	qui:predict `res', res
	qui:kdensity `res', nograph kernel(gaussian)
	local bw = `=r(bwidth)'
	**estimate Smooth GMM
	if "`from'"!="" local bini `from'
	
	if "`from'"=="" | "`z'`y1'"=="" {
		gmm ( normal( ({q: `x' `y1' _cons}-`y')/`bw' ) - `q' ), ///
			instruments(`x' `y1') `options' from(`bini')  
		tempname bini
		matrix `bini'=e(b)
	}
	**estimate IV
	if "`z'`y1'"!="" {
		gmm ( normal( ({q: `x' `y1' _cons}-`y')/`bw' ) - `q' ), ///
			instruments(`x' `z')  `options' from(`bini')  
	}
end