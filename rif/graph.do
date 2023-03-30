clear all
 use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta, clear
 gen wt2=round(wt*10)
 keep if lnwage!=.
 ssc install lbsvmat
 forvalues i=5(5)95 {
 rifhdreg lnwage educ exper tenure female age [pw=wt2], rif( q(`i'))   
 matrix tb=r(table)
 matrix bq=nullmat(bq)\tb["b",....]
 matrix llq=nullmat(llq)\tb["ll",....]
 matrix ulq=nullmat(ulq)\tb["ul",....]
 reg lnwage educ exper tenure female age [pw=wt2], 
 matrix tb=r(table)
 matrix bols=nullmat(bols)\tb["b",....]
 matrix llols=nullmat(llols)\tb["ll",....]
 matrix ulols=nullmat(ulols)\tb["ul",....]
 matrix qr=nullmat(qr)\[`i']
 }
 
 foreach i in bq llq ulq bols llols ulols qr {
 	lbsvmat `i'
 }
 
 twoway (line llq2 ulq2 qr1) (line bq2 qr1) /// this is for uqreg
		(line llols2 ulols2 qr1) (line bols2 qr1), /// this is for ols
		legend(order( 3 "Uqreg" 6 "OLS"))