** Load Data
use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta if lnwage!=., clear
** Create Censored data
gen ll=floor(lnwage*2)/2  // lower bracket
gen ul=ceil(lnwage*2)/2  // upper bracket
replace ul=5 if ul>5
replace ul=1.5 if ul<1.5
replace ll=4.5 if ll>4.5
replace ll=0.5 if ll<=1

mi set wide
mi impute chain (intreg , ll(ll) ul(ul)) lnwage_h = educ exper tenure female age agesq married divorced, add(10)

capture matrix drop bm bmll bmuu
forvalues i = 5(5)95 {
	mi estimate:qreg lnwage_h educ exper tenure female, q(`i')
	matrix x=r(table)
	matrix bm=nullmat(bm)\x[1,....]
	matrix bmll=nullmat(bmll)\x[5,....]
	matrix bmuu=nullmat(bmuu)\x[6,....]
}


use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta if lnwage!=., clear
** Create Censored data
gen ll=floor(lnwage*2)/2  // lower bracket
gen ul=ceil(lnwage*2)/2  // upper bracket
replace ul=5 if ul>5
replace ul=1.5 if ul<1.5
replace ll=4.5 if ll>4.5
replace ll=0.5 if ll<=1
gen lnbx=(ll+ul)
gen lnb=(ll+ul)+rnormal()*.1
color_style tableau
two (scatter lnwage lnb) (kdensity lnwage, horizontal) (histogram lnbx, pstyle(p3)), xlabel(2 "<1.5" 3.5 "1.5-2" 4.5 "2-2.5" 5.5 "2.5-3" ///
						   6.5 "3-3.5" 7.5 "3.5-4" 8.5 "4-4.5" 9.5 "4.5-5.5" ) legend(off) ///
						   xtitle("Censored Log Wages") ytitle("True log wages")
graph export ng1.png						   
two kdensity lnwage || histogram lnb, freq yaxis(2) 

intreg ll ul educ exper tenure female age agesq married divorced , ///
			het(educ exper tenure female age agesq married divorced )
			
intreg_mi lw			
sum lnwage lw1 lw2 lw3

gen lnwage_h=.
tempfile s1
save `s1'
mi import wide, impute(lnwage_h = lw*)

matrix drop b bmi
matrix drop bll bmill
matrix drop buu bmiuu
forvalues i = 5(5)95 {
	qreg lnwage educ exper tenure female,q(`i')
	matrix x=r(table)
	matrix b=nullmat(b)\x[1,....]
	matrix bll=nullmat(bll)\x[5,....]
	matrix buu=nullmat(buu)\x[6,....]
	mi estimate:qreg lnwage_h educ exper tenure female, q(`i')
	matrix x=r(table)
	matrix bmi=nullmat(bmi)\x[1,....]
	matrix bmill=nullmat(bmill)\x[5,....]
	matrix bmiuu=nullmat(bmiuu)\x[6,....]
}

frame create newx
frame newx:clear
frame newx:svmat b
frame newx:svmat bll
frame newx:svmat buu
frame newx:svmat bmi
frame newx:svmat bmill
frame newx:svmat bmiuu
frame newx:svmat bm
frame newx:svmat bmll
frame newx:svmat bmuu
frame newx:gen q= _n*5
frame newx:{
		two (rarea bll1 buu1 q , pstyle(p1) color(%10) ) ( line b1 q, pstyle(p1)) ///
			(rarea bmll1 bmuu1 q , pstyle(p2) color(%10) ) ( line bm1 q, pstyle(p2)) ///
			(rarea bmill1 bmiuu1 q , pstyle(p3) color(%10) ) ( line bmi1 q, pstyle(p3)) , ///
			legend(order(1 "True Data" 3 "mi Intreg" 5 "intreg_mi"))
frame newx:{		
	    local i 4	
		two  ( line b`i' q, pstyle(p1)) ///
			(rarea bmll`i' bmuu`i' q , pstyle(p2) color(%10) ) ( line bm`i' q, pstyle(p2)) ///
			(rarea bmill`i' bmiuu`i' q , pstyle(p3) color(%10) ) ( line bmi`i' q, pstyle(p3)) , ///
			legend(order(1 "True Data" 3 "mi Intreg" 5 "intreg_mi"))	
}
frame newx:line b2 bmi2 q, name(m2b, replace)
frame newx:line b3 bmi3 q, name(m3b, replace)

