 use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta, clear
drop if lnwage==.
gen wage = exp(lnwage)

recode wage (0 /20=1) (20 /30=2) (30 /40=3 ) (40 /50=4) (50 /200=5), gen(cwage)
gen low_wage=0 if cwage==1
replace low_wage=20 if cwage==2
replace low_wage=30 if cwage==3
replace low_wage=40 if cwage==4
replace low_wage=50 if cwage==5

gen high_wage=20 if cwage==1
replace high_wage=30 if cwage==2
replace high_wage=40 if cwage==3
replace high_wage=50 if cwage==4
replace high_wage=.  if cwage==5

gen loglow_wage =log(low_wage)
gen loghigh_wage=log(high_wage)

intreg loglow_wage loghigh_wage educ exper tenure  female age agesq married divorced kids6 kids714, ///
het(educ exper tenure  female age agesq married divorced kids6 kids714)

intreg_mi ilwage, seed(10)

gen ilogwage = .
tempfile tosave
save `tosave'

mi import wide, imputed(ilogwage=  ilwage* )
mi passive: gen iwage = exp(ilogwage) 

ssc install color_style
set scheme white
forvalues i = 1/9 {
two (kdensity _`i'_iwage ) (kdensity wage, lwidth(1)) , name(m`i', replace) legend(off)
}
graph combine m1 m2 m3 m4 m5 m6 m7 m8 m9

mi estimate, cmdok: mean iwage if female==1, 
mi estimate, cmdok: mean iwage if female==0, 


*rifmean wage, rif(gini, entropy(1))


mi estimate, cmdok: qreg ilogwage  educ exper tenure female age  , q(90)
qreg lnwage  educ exper tenure female age  , q(90) nolog















