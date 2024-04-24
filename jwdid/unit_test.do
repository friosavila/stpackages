** Unit test
clear
set seed 1
set obs 2000
gen ivar = _n
gen gvar = runiformint(3,6)
replace gvar = 0  if runiform()<.2
gen x1 = runiform()
xtile dx=x1, n(2)
expand 10
bysort ivar:gen tvar = _n
gen te = 1*(t>=(g-1) )*(g!=0)
gen y =  (rnormal()) + te

** installation
capture program drop _all
net install jwdid, from(C:\Users\Fernando\Documents\GitHub\stpackages\) replace
** Run
cd "C:\Users\Fernando\Documents\GitHub\stpackages\jwdid"


jwdid y , ivar(ivar) tvar(tvar) gvar(gvar)  anti(3)
estat event, predict(xb) 
estat plot
estat group, predict(xb)
estat plot
estat calendar, predict(xb)
estat plot
estat simple, over(dx) predict(xb)
estat plot
 
jwdid y , tvar(tvar) gvar(gvar) 
estat event, predict(xb)
estat plot
estat group, predict(xb)
estat plot
estat calendar, predict(xb)
estat plot
estat simple, over(dx)  predict(xb)
estat plot

jwdid y , ivar(ivar) tvar(tvar) gvar(gvar) never   
estat event, predict(xb)
estat plot
estat group, predict(xb)
estat plot
estat calendar, predict(xb)
estat plot
estat simple, over(dx) predict(xb)
estat plot

jwdid y x1, tvar(tvar) gvar(gvar) never  cluster(ivar)
estat event, pretrend
estat plot
estat group
estat plot
estat calendar
estat plot
estat simple, over(dx)
estat plot