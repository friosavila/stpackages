clear all
adopath + "C:\Users\Fernando\Dropbox (Personal)\projects\00 New Projects\rnd stata programs"
** reproducible example
 use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta, clear
 ** mqreg using factor notation, and 2 quantiles
 mmqreg lnwage i.female educ exper tenure i.isco, q(25 75)
 est sto m1
 ** Same but absorving isco , and 2 quantiles
 mmqreg lnwage female educ exper tenure , q(25 75) abs(isco)
 est sto m2
 ** Same but with xtqreg
 xtqreg lnwage i.female educ exper tenure , i(isco) q(.25 .75) ls
 
 *** for
 
 