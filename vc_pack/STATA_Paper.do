**SVCM: Model examples and implementations
clear all
webuse dui, clear


* Section 2.4
* Standard OLS model
regress citations college taxes i.csize fines

* Local regression constraining the data to observations where fines=9
regress citations college taxes i.csize   if fines==9
 
* local constant estimator, using Gaussian Kernel weight
regress citations college taxes i.csize   [aw=normalden(fines,9,0.5)]

* Creation auxiliary variable (Zi-z) where z=9
gen df=fines-9
* Estimation of the local linear estimator, using Gaussian Kernel weight
regress citations c.(college taxes i.csize)##c.df  [aw=normalden(fines,9,0.5)]

** estimation through all possible values of FINES 
** exact sample
levelsof fines, local(fines)
foreach i of local fines {
	regress citations college taxes i.csize   if fines==float(`i')
	matrix m=e(b)	
	if colsof(m)==6 	matrix b1=nullmat(b1)\[`i', e(b)]
}

** Local Constant SVCM
levelsof fines, local(fines)
foreach i of local fines {
	
	regress citations college taxes i.csize   [aw=normalden(fines,`i',0.5)]
	matrix b2=nullmat(b2)\[`i', e(b)]
}	

** Local Linear SVCM
levelsof fines, local(fines)
foreach i of local fines {
	capture drop df
	gen df=fines-`i'
	regress citations c.(college taxes i.csize)##c.df [aw=normalden(fines,`i',0.5)]
	matrix b3=nullmat(b3)\[`i', e(b)]
	
	}	

* same as before tomake plots. Fig1 and fig2	
levelsof fines, local(fines)
foreach i of local fines {
	regress citations college taxes i.csize fines
	matrix b4=nullmat(b4)\[`i', e(b)]
	}		
	svmat b1
	svmat b2
	svmat b3
	svmat b4
	
set scheme sj,	
graph set window fontface "Times New Roman"
two line b42 b41 || line b12 b11 || line b22 b21 || line b32 b31, legend(order(1 "OLS" 2 "VCM-Exact" 3 "SVCM-LC" 4 "SVCM-LL")) title("Coefficients on College") xtitle(Fines)

 	
two line b43 b41 || line b13 b11 || line b23 b21 || line b33 b31, legend(order(1 "OLS" 2 "VCM-Exact" 3 "SVCM-LC" 4 "SVCM-LL")) title("Coefficients on Taxes") xtitle(fines)

** Section 4. Ilustration. Determinants of Citations across fines
clear all
webuse dui, clear


** 1. Model selection
** Alternative not in paper. Uses vc_bwalt
vc_bwalt citations taxes college i.csize, vcoeff(fines)
** Example in paper using vc_bw
vc_bw citations taxes college i.csize, vcoeff(fines)
** Summary statistics
vc_predict citations taxes college i.csize, vcoeff(fines) stest
** Not in paper
** OLS model
reg citations taxes college i.csize fines
** Full nonparametric Kernel
npregress kernel citations i.taxes i.college i.csize fines, kernel(gaussian)
** J statitsic
** H0 Model 1
vc_test citations taxes college i.csize, degree(1) wbsrep(200) seed(1) 
** H0 Model 2
vc_test citations taxes college i.csize, degree(2) wbsrep(200) seed(1) 

** Estimation of SVCM for 3 points. Different Standard errors

* Robust Standard errors  using Local predicted errors
regress citations taxes college i.csize fines, robust
est sto m0
vc_reg citations taxes college i.csize, klist(9)
est sto m1
vc_reg citations taxes college i.csize, klist(10)
est sto m2
vc_reg citations taxes college i.csize, klist(11)
est sto m3

esttab m0 m1 m2 m3 using tb1, se nostar csv replace nogaps noomit label

* Robust Standard errors using full sample predicted errors
regress citations taxes college i.csize fines, robust
est sto m0
vc_preg citations taxes college i.csize, klist(9)
est sto m1
vc_preg citations taxes college i.csize, klist(10)
est sto m2
vc_preg citations taxes college i.csize, klist(11)
est sto m3

esttab m0 m1 m2 m3 using tb1, se nostar csv append nogaps noomit label
esttab m0 m1 m2 m3 

* Bootstrap standard errors 

bootstrap, seed(1) reps(100) nodots:regress citations taxes college i.csize fines,
est sto m0
vc_bsreg citations taxes college i.csize, klist(9) seed(1) reps(100)
est sto m1
vc_bsreg citations taxes college i.csize, klist(10) seed(1) reps(100)
est sto m2
vc_bsreg citations taxes college i.csize, klist(11) seed(1) reps(100)
est sto m3

esttab m0 m1 m2 m3 using tb1, se nostar csv append nogaps noomit label
** Table in paper needs additional editings.


** graphs using vc_preg
vc_preg citations taxes college i.csize, klist(7.4(.2)12)
** Figure 2: Graphs for b(z)
vc_graph taxes college i.csize,  
graph combine grph1 grph2 grph3 grph4
** Figure 2: Graphs for db(z)/dz
vc_graph taxes college i.csize,  delta
graph combine grph1 grph2 grph3 grph4

** using vc_bsreg and percentile ci
vc_bsreg citations taxes college i.csize, klist(7.4(.2)12) reps(100) seed(1)
vc_graph taxes college i.csize, pci
graph combine grph1 grph2 grph3 grph4



* This section is not in the working paper.
webuse dui, clear
* It aims to show how to replicate npregress with vc_pack when only 1 explanatory variable is used

npregress kernel citations fines, kernel(gaussian)
*npregress estimates two Bandwidths, one for the mean function, and one for the gradient.
local bwm=.6256079    // CV:   4.008821 
local bwd=.7082928    //
*vc_bw only estimates the bandiwdth for the mean function
vc_bw citations, vcoeff(fines)
local bw1= 0.6351275  // CV:   4.008814
* This bw is larger than the one estimated by npregress, but the CV is slighly smaller, which accounts for the difference

* npregress kernel can estimate both the conditional mean and marginal effect at some value of fines. 
* standard errors in both cases can be obtained using Bootstrap standard errors:
qui:npregress kernel citations fines, kernel(gaussian)
set seed 1
margins, at(fines=10) reps(50)
 
set seed 1
margins, dydx(fines) at(fines=10) reps(50)
 

* This can be replicated with vc_reg straight forward. Just making sure we use the same Bandwidths
set seed 1
vc_bsreg citations, vcoeff(fines) klist(10) bw(.6256079)
 
set seed 1
vc_bsreg citations, vcoeff(fines) klist(10) bw(.7082928)

** E(kobs) using fines and rescaled fines. 
gen double fines2=fines*10
** estimating npregress
npregress kernel citations fines2, kernel(gaussian)
* new Mean bandwidth  6.215959 
* But now kernel observations is 500

* Same excercise with vc_bw
vc_bw      citations, vcoeff(fines)
vc_predict citations, vcoeff(fines)
** BW = 0.6351275 E(Kobs) = 248.808
vc_bw      citations, vcoeff(fines2)
vc_predict citations, vcoeff(fines2)
** BW = 6.3512579 E(Kobs) = 248.808

** using xvar to change the scale of the smoothing variable:
 webuse motorcycle, clear
 gen sqtime=(time^.5)
** First estimate the model 
vc_bw      accel, vcoeff(time)
vc_predict accel, vcoeff(time) yhat(accel_hat)
vc_preg    accel, vcoeff(time) klist(2.5(2.5)55)
** simple plot
vc_graph , constant 
** using a different variable for the plot
vc_graph , constant xvar(sqtime)
** adding a scatter plot
vc_graph , constant  addgraph("scatter accel_hat time")
