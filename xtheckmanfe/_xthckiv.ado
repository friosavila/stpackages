*! v1.1 Changes from selection to select SEL eq
** add on of xtheckmanfe with endogenous
program define _xthckiv, eclass
	syntax [if], y1(str) x1(str) x1m(str) y2(str) z1(str)  z1m(str) y3(str) z2(str) z2m(str)  time(str) bpi(str)
	marksample touse
	tempname bp br Vr
	** Probit uses ALL exogenous variables
	local xz1m 
 	foreach i in `x1m' `z1m' `z2m' {
		local flag 0
		foreach j in `xz1m' {
			if "`i'" == "`j'" {
				local flag 1
			}	
		}
		if `flag'==0 {
			local xz1m `xz1m' `i'
		}
	}
	
	** x1 are for main equation only
	** z2 are instruments for IV
	** z1 are instruments for Selection
	probit `y2' i.`time'#c.(`x1' `x1m' `z1' `z1m' `z2' `z2m') i.`time' if `touse', from(`bpi', skip)
	matrix `bp'=e(b)
	capture drop _sel_imr
	predict double _sel_imr, score
	ivregress 2sls `y1' `x1' `xz1m' i.`time' i.`time'#c.(_sel_imr) (`y3' = `z2' ) if `y2'==1 & `touse'
	matrix `br'=e(b)
	matrix `Vr'=e(V)
	matrix coleq `bp'= select
	matrix coleq `br' = `y1'
	matrix b=`br' ,`bp'
	ereturn post b , esample(`touse')
end
