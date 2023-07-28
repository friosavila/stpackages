** only for OLS
* capture program drop model_display
*! v0 Simple Ado to display REG model
program model_display
	syntax, [format(string asis)]
	
	if missing("`format'") local format "%5.3f"
	tempname b
	matrix `b'=e(b)
	local cname:colname `b'
	local k = colsof(`b')
	local dep `e(depvar)'
	
	local coef = `b'[1,`k']
	if sign(`coef')==-1 local sgn "-"
	local coef:display %5.3f (`coef')
	local todisp "`dep' = `coef'"
	
	forvalues i = 1/`=`k'-1' {
		local coef = `b'[1,`i']
		local sgn  "+"
		if sign(`coef')==-1 local sgn "-"
		local coef:display `format' abs(`coef')
		local cnamex:word `i' of `cname'
		local todisp `todisp' `sgn' `coef' `cnamex'
	}
	display "{p}`todisp'{p_end}"
end