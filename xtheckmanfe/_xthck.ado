*! v1.2 Changes from selection to select SEL eq
*! v1.1 Cleans Demeaned variables to avoid "seen" the same demeaned variable twice
** ad on for xtheckfe
program define _xthck, eclass
syntax [if], y1(str) y2(str)  x1(str) x1m(str) z1(str) z1m(str) time(str)  bpi(str)
	marksample touse
	tempname bp br Vr
	** Probit uses ALL exogenous variables
	** x1 are for main equation only
	** z1 are instruments for Selection
	local xz1m 
 	foreach i in `x1m' `z1m' {
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
 
	probit `y2' i.`time'#c.(`x1' `z1' `xz1m' ) i.`time' if `touse', from(`bpi', skip)
	matrix `bp'=e(b)
	capture drop _sel_imr
	predict double _sel_imr, score
	reg `y1' `x1' `xz1m'  i.`time' i.`time'#c.(_sel_imr) if `y2'==1 & `touse'
	matrix `br'=e(b)
	matrix `Vr'=e(V)
	matrix coleq `bp'= select
	matrix coleq `br' = `y1'
	matrix b=`br' ,`bp'
	ereturn post b , esample(`touse')
end
