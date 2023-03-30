matrix drop b
forvalues i = 1/99 {
	local j = `i'/100
qrprocess ln_wage union age race grade nev_mar, q(`j')
ereturn display
matrix b=nullmat(b)\e(b)
	matrix l = r(table)

	matrix auu = nullmat(auu)\l["ul",....]
	matrix all = nullmat(all)\l["ll",....]
}


smqreg ln_wage union age race grade nev_mar, q(1)
matrix k=e(b)
forvalues i = 1/99 {
	local j = `i'/100
	smqreg ln_wage union age race grade nev_mar, q(`i')  onestep from(k) 
	matrix l = r(table)
	matrix uu = nullmat(uu)\l["ul",....]
	matrix ll = nullmat(ll)\l["ll",....]
	matrix c=nullmat(c)\e(b)
	matrix k = e(b)
}

svmat uu
svmat ll
svmat c
gen q=_n if _n<100
two rarea ll3 uu3 q if inrange(q,3,97) , color(%30) || line c3 q if inrange(q,3,97) 
local i 1
two rarea ll`i' uu`i' q if inrange(q,3,97) , color(%30) || line c`i' q if inrange(q,3,97) 


forvalues i = 1/99 {
	local j = `i'/100
	qui:qrprocess ln_wage union age race grade nev_mar, q(`j')  
	ereturn display
	matrix l = r(table)
	matrix xuu = nullmat(xuu)\l["ul",....]
	matrix xll = nullmat(xll)\l["ll",....]
	matrix xc=nullmat(xc)\e(b)
	
}

svmat xuu
svmat xll
svmat xc


local i 5
two rarea ll`i' uu`i' q if inrange(q,3,97) , color(%30) || line c`i' q if inrange(q,3,97) || ///
	rarea xll`i' xuu`i' q if inrange(q,3,97) , color(%30) || line xc`i' q if inrange(q,3,97) 