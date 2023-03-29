cscript
cd "C:\Users\Fernando\Documents\GitHub\playingwithstata\drdid"
use lalonde, clear
gen trt=experimental==1
gen tmt=year==1978
keep if treated==0 | sample==2
global y re
global xvar age educ black married nodegree hisp re74

set seed 1
drop if runiform()<.1
drdid re $xvar ,   time(year) tr( experimental ) all

** manual rc

**# AIPW or IPW Abadie Non standardized weights
preserve
 qui {
logit trt $xvar
predict psc

** 4 potential weights
gen w11=          trt  * (  tmt)
gen w10=          trt  * (1-tmt)
gen w01= psc * (1-trt) * (  tmt)/(1-psc)
gen w00= psc * (1-trt) * (1-tmt)/(1-psc)

sum trt
gen pi_hat			=  r(mean)
sum tmt
gen lambda_hat		=  r(mean)

gen y11 = w11 * re /(pi_hat * (lambda_hat) )
gen y10 = w10 * re /(pi_hat * (1-lambda_hat) )
gen y01 = w01 * re /(pi_hat * (lambda_hat) )
gen y00 = w00 * re /(pi_hat * (1-lambda_hat) )
** dif-in-diff
gen att= (y11-y10)-(y01-y00)
}
sum att

restore

**# dripw Double Robust IPW
preserve
qui {
	logit trt $xvar
	predict psc
	reg $y $xvar if trt==0 & tmt ==0  
	predict double yh00
 
	reg $y $xvar if trt==0 & tmt ==1  
	predict double yh01
 
	reg $y $xvar if trt==1 & tmt ==0  
	predict double yh10
 
	reg $y $xvar if trt==1 & tmt ==1 
	predict double yh11
 	
	gen yh0 = yh00*(1-tmt)+yh01*tmt
	
	gen w11=          trt  * (  tmt)
	gen w10=          trt  * (1-tmt)
	gen w01= psc * (1-trt) * (  tmt)/(1-psc)
	gen w00= psc * (1-trt) * (1-tmt)/(1-psc)
	gen w1 =trt
	
	** weight normalization
	foreach i in w11 w10 w01 w00 w1 {
		qui:sum `i'
		replace `i'=`i'/r(mean)
	}
	gen y10 			= w10 * ($y - yh0)
    gen y11 			= w11 * ($y - yh0)
    gen y00 	  		= w00 * ($y - yh0)
    gen y01  			= w01 * ($y - yh0)
	
	gen y_1c=  w1  * (yh11 - yh01)
	gen y11c= w11  * (yh11 - yh01)
	gen y_0c=  w1  * (yh10 - yh00)
	gen y10c= w10  * (yh10 - yh00)
	
	gen att   =  (y11 - y10)  - (y01 - y00)  ///
				+ (y_1c - y11c) - (y_0c - y10c) 

}
	sum att

restore

**#dr-reg (OR)
preserve

qui {

	reg $y $xvar if trt==0 & tmt ==0  
	predict double yh00
	reg $y $xvar if trt==0 & tmt ==1 
	predict double yh01
	
	gen w11=          trt  * (  tmt)
	gen w10=          trt  * (1-tmt)
	gen w1 =trt

	foreach i in w11 w10 w1 {
		qui:sum `i'
		replace `i'=`i'/r(mean)
	}
	
	gen y11=w11*$y
	gen y10=w10*$y
	gen y01=w1 *yh01
	gen y00=w1 *yh00
	
	gen att = (y11-y10)-(y01-y00)
	}
sum att
restore

**#drdid_sipw
** Standardized Weights IPW
preserve
qui {
	logit trt $xvar
	predict psc
	gen w11=          trt  * (  tmt)
	gen w10=          trt  * (1-tmt)
	gen w01= psc * (1-trt) * (  tmt)/(1-psc)
	gen w00= psc * (1-trt) * (1-tmt)/(1-psc)
	foreach i in w11 w10 w01 w00 {
		qui:sum `i'
		replace `i'=`i'/r(mean)
	}
	gen att = (w11*$y - w10*$y )-( w01*$y - w00*$y)

}
sum att
restore


**#drdid_imp drimp
** Standardized Weights IPW
preserve
qui {
use lalonde, clear
gen trt=experimental==1
gen tmt=year==1978
keep if treated==0 | sample==2
global y re
 global xvar age educ 
 *black married nodegree hisp re74

set seed 1
drop if runiform()<.1
	mlexp (trt*{xb:$xvar _cons}-(trt==0)*exp({xb:})), vce(robust)
	*logit $y $xvar
	predictnl double psc=logistic(xb())
	gen double w11=          trt  * (  tmt)
	gen double w10=          trt  * (1-tmt)
	gen double w01= psc * (1-trt) * (  tmt)/(1-psc)
	gen double w00= psc * (1-trt) * (1-tmt)/(1-psc)
	gen double w0 = psc * (1-trt) / (1-psc)
	gen double w1 = trt
	
	foreach i in w11 w10 w01 w00 w0 w1 {
		qui:sum `i'
		replace `i'=`i'/r(mean)
	}
 
 	reg $y $xvar if trt==0 & tmt ==0  [w=w0]
	predict double yh00
 	reg $y $xvar if trt==0 & tmt ==1  [w=w0] 
	predict double yh01
	reg $y $xvar if trt==1 & tmt ==0  
	predict double yh10
 	reg $y $xvar if trt==1 & tmt ==1 
	predict double yh11
	
	gen double yh0 = yh00*(1-tmt)+yh01*tmt
	gen double y10 			= w10 * ($y - yh0)
    gen double y11 			= w11 * ($y - yh0)
    gen double y00 	  		= w00 * ($y - yh0)
    gen double y01  			= w01 * ($y - yh0)
	
	gen double y_1c=  w1  * (yh11 - yh01)
	gen double y11c= w11  * (yh11 - yh01)
	gen double y_0c=  w1  * (yh10 - yh00)
	gen double y10c= w10  * (yh10 - yh00)
	
	gen double att   =  (y11 - y10)  - (y01 - y00)  ///
				+ (y_1c - y11c) - (y_0c - y10c) 
	
 }
sum att
restore

	global yh0  ({yh00:}*(1-tmt)+{yh01:}*tmt)
	global y10  (w10/{w10} * ($y - $yh0))
    global y11  (w11/{w11} * ($y - $yh0))
    global y00  (w00/{w00} * ($y - $yh0))
    global y01  (w01/{w01} * ($y - $yh0))
	
	global y_1c  (w1/{w1}  * ({yh11:} - {yh01:}))
	global y11c  (w11/{w11} * ({yh11:} - {yh01:}))
	global y_0c  (w1/{w1}  * ({yh10:} - {yh00:}))
	global y10c  (w10/{w10} * ({yh10:} - {yh00:}))
	
	global att  ($y11 - $y10)  - ($y01 - $y00)  + ($y_1c - $y11c) - ($y_0c - $y10c) 
gen t11=(trt==1)*(tmt==1)
gen t10=(trt==1)*(tmt==0)
gen t01=(trt==0)*(tmt==1)
gen t00=(trt==0)*(tmt==0)
gmm (1:($y-{yh11:$xvar _cons})*(t11)) ///
	(2:($y-{yh10:$xvar _cons})*(t10)) ///
	(3:($y-{yh01:$xvar _cons})*(t01*w0)) ///
	(4:($y-{yh00:$xvar _cons})*(t00*w0)) ///
	(5:({att}-($att )) ), ///
	instrument(1:$xvar) ///
	instrument(2:$xvar) ///
	instrument(3:$xvar) ///
	instrument(4:$xvar) ///
	winitial(identity) onestep ///
	derivative(1 /yh11=-t11) ///
	derivative(2 /yh10=-t10) ///
	derivative(3 /yh01=-t01*w0) ///
	derivative(4 /yh00=-t00*w0) ///
	derivative(5 /yh11=-w1+w11) ///
	derivative(5 /yh10= w1-w10) ///
	derivative(5 /yh01=-(-(w11-w10-w01+w00)*(tmt)   -w1+w11 )) ///
	derivative(5 /yh00=-(-(w11-w10-w01+w00)*(1-tmt) +w1-w10 ))  ///
	derivative(5 /att=1) 
	
	
gmm (1:{w00=1}-w00) (2:{w01=1}-w01) (3:{w10=1}-w10) (4:{w11=1}-w11) (5:{w1=1}-w1) (6:{w0=1}-w0) ///
	(7:($y-{yh11:$xvar _cons})*(t11)) ///
	(8:($y-{yh10:$xvar _cons})*(t10)) ///
	(9:($y-{yh01:$xvar _cons})*(t01*w0/{w0:})) ///
	(10:($y-{yh00:$xvar _cons})*(t00*w0/{w0:})) ///
	(11:({att}-($att )) ), ///
	instrument(7:$xvar) ///
	instrument(8:$xvar) ///
	instrument(9:$xvar) ///
	instrument(10:$xvar) ///
	winitial(identity) onestep from(kk)
	///
	derivative(7 /yh11=-t11) ///
	derivative(8 /yh10=-t10) ///
	derivative(9 /yh01=-t01*w0) ///
	derivative(10/yh00=-t00*w0) ///
	derivative(11/yh11=-w1+w11) ///
	derivative(11/yh10= w1-w10) ///
	derivative(11/yh01=-(-(w11-w10-w01+w00)*(tmt)   -w1+w11 )) ///
	derivative(11/yh00=-(-(w11-w10-w01+w00)*(1-tmt) +w1-w10 ))  ///
	derivative(11/att=1)  	
	from(k)

   (w11 * (re - ({yh00:}*(1-tmt)+{yh01:}*tmt))) 
 - (w10 * (re - ({yh00:}*(1-tmt)+{yh01:}*tmt)))
 - (w01 * (re - ({yh00:}*(1-tmt)+{yh01:}*tmt))) 
 + (w00 * (re - ({yh00:}*(1-tmt)+{yh01:}*tmt)))
 + (w1  * ({yh11:} - {yh01:})) 
 - (w11 * ({yh11:} - {yh01:})) 
 - (w1  * ({yh10:} - {yh00:})) 
 + (w10 * ({yh10:} - {yh00:}))

	/***



------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
ATET         |
       dripw |  -579.7414    425.191    -1.36   0.173      -1413.1    253.6176
   dripw_rc1 |  -667.4234   454.8932    -1.47   0.142    -1558.998    224.1508
       drimp |  -608.9098   422.0174    -1.44   0.149    -1436.049    218.2291
   drimp_rc1 |  -700.7786   454.8355    -1.54   0.123     -1592.24    190.6825
         reg |    -908.44   430.2671    -2.11   0.035    -1751.748   -65.13196
         ipw |  -744.3969   637.4138    -1.17   0.243    -1993.705    504.9113
      stdipw |  -591.2276   508.2122    -1.16   0.245    -1587.305      404.85
------------------------------------------------------------------------------

***/

