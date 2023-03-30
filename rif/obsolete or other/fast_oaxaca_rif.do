use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta
expand 100
** Either do this:
 f_oaxaca_rif lnwage educ exper tenure, by(female) wgt(1) rif(mean) rwlogit(educ exper tenure)
 matrix inb= e(b_logit) 
** or run the logit model to get initial values for the logit/probit

** Now here is the comparision in time 
timer on 1
bootstrap, reps(3):oaxaca_rif lnwage educ exper tenure, by(female) wgt(1) rif(mean) rwlogit(educ exper tenure)
timer off 1

timer on 2
bootstrap, reps(3):f_oaxaca_rif lnwage educ exper tenure, by(female) wgt(1) rif(mean) rwlogit(educ exper tenure) initb(inb, copy)
timer off 2
timer list

** on my runs, this saves about 55% of the time compared to oaxaca_rif.