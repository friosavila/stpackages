*** Alternative to box plot

frause oaxaca
drop if lnwage==.

tabstat2 lnwage, by(educ) stats(p1 p5 p25 p50 p75 p95 p99) save

matrix rt = r(tmatrix)'

gen flag=.
levelsof educ, local(led)
foreach i of local led {
	local j = `j'+1
	display rt[`j',1] ":" rt[`j',7]
	replace flag = 1 if (lnwage<rt[`j',1] | lnwage>rt[`j',7]) & educ==`i'
}

mata:mt = st_matrix("rt")
mata:bs = uniqrows(st_data(.,"educ"))
mata:bs2=range(1,rows(mt),1)
mata:mt1 = mt[,(1,7)], bs2
mata:mt2 = mt[,(2,6)], bs2
mata:mt3 = mt[,(3,5)], bs2
mata:mt4 = mt[,(4)], bs2

egen bs = group(educ)
two scatter lnwage bs   ///
	|| rbar matamatrix(mt1), pstyle(1) color(%25) ///
	|| rbar matamatrix(mt2), pstyle(1) color(%50) ///
	|| rbar matamatrix(mt3), pstyle(1) color(%75) ///
	|| scatter matamatrix(mt4), pstyle(1)
	