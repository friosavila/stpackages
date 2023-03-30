** example. Unemployment duration 
** first reset data so it has a more typical panel data structure

use http://cameron.econ.ucdavis.edu/mmabook/ema1996.dta, clear
global xvars logwage tenure slack explose houshead married female ychild nonwhite age schgt12  

gen id=_n
expand 2 if event==0
bysort id:gen time=_n
replace spell=spell+1 if time==2
gen logspell=log(spell)
gen exit=1 if event==1 & time==1
replace exit=0 if exit==.
bysort id (time):gen spell0=spell[1]-1
** First Simple Logit model using indicator.
logit event $xvars logspell if time==1
est sto m1
** second Setting up data for Surv model.

stset spell, failure(exit) enter(spell0) id(id)
streg $xvars , distribution(exponential) nohr
est sto m2

** Third using ghsurv assuming we do not know data comes from same individuals
stset, clear 
ghsurv_set, dur(spell) time(time) nowarning
gen logdur=log(_dur)

ghsurv $xvars logdur, alpha(logdur) technique(nr bhhh)  
est sto m3

ghsurv $xvars logdur, alpha(logdur) technique(nr bhhh) cluster(id)  
est sto m4


