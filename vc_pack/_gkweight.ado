* version 1.0 dec 2018 Fernando Rios Avila
* This program is used to created normalized kernel weight. 
* Normalized kernel weights are such that k(0)=1. Good for measuring effective number of observations "close" to the pofr
 
capture program drop _gkweight
program define _gkweight
	version 6
	syntax newvarname =/exp [if] [in] , bw(real) pofr(real) [kernel(str)]
	tempvar touse 
	quietly {
		gen byte `touse' =0
		replace `touse'= 1 `if' `in' 
		tempvar z
		gen double `z'=(`exp'-`pofr')/`bw'
		if "`kernel'"=="" | "`kernel'"=="gaussian" { 
		  gen `typlist' `varlist' = normalden(`z')/normalden(0)  if `touse' == 1 
		}
		else if  "`kernel'"=="epan" { 
		  gen `typlist' `varlist' = (1-0.2*`z'^2) if `touse' == 1 & abs(`z')<5^.5
		}
		else if  "`kernel'"=="epan2" { 
		 gen `typlist' `varlist' = (1-`z'^2)  if `touse' == 1 & abs(`z')<1
		}
		else if  "`kernel'"=="biweight" { 
		  gen `typlist' `varlist' = (1-`z'^2)^2   if `touse' == 1 & abs(`z')<1
		}
		else if  "`kernel'"=="cosine" { 
		 gen `typlist' `varlist' = (1+cos(2*_pi*`z'))/2  if `touse' == 1  & abs(`z')<0.5
		}
		else if  "`kernel'"=="cosine2" { 
		 gen `typlist' `varlist' = cos(_pi*`z'/2)  if `touse' == 1  & abs(`z')<1
		}
		else if  "`kernel'"=="parzen" { 
		  gen `typlist' `varlist' = (1-6*`z'^2+6*abs(`z')^3)  if `touse' == 1 & abs(`z')<=0.5 
		  replace `varlist' = 2*(1-abs(`z'))^3  if `touse' == 1 & abs(`z')>0.5 & abs(`z')<=1
		}
		else if  "`kernel'"=="rectan" { 
		 gen `typlist' `varlist' = 1  if `touse' == 1 & abs(`z')<1
		}
		else if  "`kernel'"=="trian" { 
		  gen `typlist' `varlist' = 1-abs(`z')  if `touse' == 1 & abs(`z')<1
		}
		else if  "`kernel'"=="logistic" { 
		  gen `typlist' `varlist' = 4*(1/(2+exp(`z')+exp(-`z')))  if `touse' == 1  
		}
		else if  "`kernel'"=="tricube" { 
		  gen `typlist' `varlist' = (1-abs(`z')^3)^3  if `touse' == 1  & abs(`z')<1
		}
		else if  "`kernel'"=="triweight" { 
		  gen `typlist' `varlist' = (1-`z'^2)^3  if `touse' == 1  & abs(`z')<1
		}
		***For discreet Data
		** For unordered Data
		else if  "`kernel'"=="liracine" { 
		  if `bw'>=0 & `bw'<=1 {
		    gen `typlist' `varlist' = 1  if `touse' == 1  & float(abs(`exp'-`pofr'))==0
			replace   `varlist' = `bw'  if `touse' == 1  & float(abs(`exp'-`pofr'))!=0
		   }
		   else {
		   display "For liracine, Bandwidth needs to be between 0 and 1"
		   exit
		   }
		}
		** For ordered Data
		else if  "`kernel'"=="liracine2" { 
		  if `bw'>=0 & `bw'<=1 {
		    gen `typlist' `varlist' = 1  if `touse' == 1  & float(abs(`exp'-`pofr'))==0
			replace   `varlist' = `bw'^abs(`exp'-`pofr')  if `touse' == 1  & float(abs(`exp'-`pofr'))!=0
		   }
		   else {
		   display "For liracine2, Bandwidth needs to be between 0 and 1"
		   exit
		   }
		}
		else if  "`kernel'"=="habbena" { 
		  if `bw'>=0 & `bw'<=1 {
		    gen `typlist' `varlist' = 1  if `touse' == 1  & float(abs(`exp'-`pofr'))==0
			replace   `varlist' = `bw'^(abs(`exp'-`pofr')^2)  if `touse' == 1  & float(abs(`exp'-`pofr'))!=0
		   }
		   else {
		   display "For habbena, Bandwidth needs to be between 0 and 1"
		   exit
		   }
		}
		else if  "`kernel'"=="logdis" { 
		  if `bw'>=0 & `bw'<=1 {
		    gen `typlist' `varlist' = 1  if `touse' == 1  & float(abs(`exp'-`pofr'))==0
			replace   `varlist' = `bw'^(ln(abs(`exp'-`pofr')+1))  if `touse' == 1  & float(abs(`exp'-`pofr'))!=0
		   }
		   else {
		   display "For logdis, Bandwidth needs to be between 0 and 1"
		   exit
		   }
		}
		else if  "`kernel'"=="dtrian" { 
		  if `bw'>=0 & `bw'<=1 {
		    gen `typlist' `varlist' = 1  if `touse' == 1  & float(abs(`exp'-`pofr'))==0
			replace   `varlist' = 1-(1-`bw')*abs(`exp'-`pofr')  if `touse' == 1  & float(abs(`exp'-`pofr'))!=0
		    replace   `varlist' = 0 if `varlist'<0
		   }
		   else {
		   display "For dtrian, Bandwidth needs to be between 0 and 1"
		   exit
		   }
		}
		replace `varlist' =0 if `varlist'==. & `touse' == 1
	}
 end
