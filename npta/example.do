** Simple case, no Xvar
** staggered treatment
clear all
set obs 1000
gen ivar = _n
gen gvar = runiformint(3,10)
replace  gvar = 0 if runiform()<.2
gen teff = runiform(0.05,0.1)
expand 15
bysort ivar:gen tvar = _n

** no PTA violation
*gen y =rnormal() 

** with PTA violation
 
gen y =rnormal() - 0.1*tvar + 0.01*tvar^2 + 0.1*tvar * (gvar!=0)

replace teff = teff * (tvar-gvar+1) * (gvar!=0) * (tvar>=gvar) - 0.2*teff * (tvar-gvar+1)^2 * (gvar!=0) * (tvar>=gvar) + rnormal()*0
gen yd = y + teff

gen event = (tvar-gvar) if gvar!=0
gen event2 = event + 10
mean teff if event!=-1, over(event2) 
matrix bt=e(b)

** Estimating effect
*net install csdid2, from("https://friosavila.github.io/stpackages") replace
csdid2 yd, ivar(ivar) gvar(gvar) tvar(tvar)
estat event, noavg

** get b and v
matrix b=e(b)
matrix V=e(V)

frame create new
frame change new

drawnorm v1-v21, mean(b) cov(V) n(1000)
svmat bt
 
gen id = _n
reshape long v bt, i(id) j(ev)
replace ev = ev - 10
replace ev = ev+1 if ev>=-1
** No analysis, using qreg

qreg v ev if ev<0
predict v_pre
qreg v ev if ev>=0
predict v_post

gen post=(v-v_pre )*(ev>0)


** estimated effect (via simulations)
label var  post "Effect via proposed method"
label var v "Estimated effect"


graph box post v bt, over(ev) name(f2, replace)  




