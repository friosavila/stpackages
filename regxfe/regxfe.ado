*! regxfe 1.1 Sep 2016
*! Author: Fernando Rios Avila
* Program has been tested to Run under Stata 12 or higher.
version 12
capture program drop regxfe
program define regxfe, eclass
syntax [varlist] [if] [in] [aw fw iw] , fe(varlist min=1 max=7) ///
[tolerance(str)] [cluster(varname)] [robust] [xfe(str)] [file(str)] [replace] [mg(integer -1)] [maxiter(integer 10000)]

tempfile tempfile 
tempname regfe
tempvar clst
tempvar test
*install programs required:
qui gen `test'=1 in 1/2
qui reg `test'
capture which  tuples
if _rc {
di as err "Error: {regxfe} works with {tuples}."
di `"To install or update it, type or click on {stata "ssc install tuples, replace"}."'
exit 199
}
capture which center
if _rc==111 {
di as err "Error: {regxfe} works with {center}."
di `"To install or update it, type or click on {stata "ssc install center, replace"}."'
exit 199
}
capture which a2group
if _rc==111 {
di as err "Error: {regxfe} works with {a2reg}."
di `"To install or update it, type or click on {stata "ssc install a2reg, replace"}."'
exit 199
}
capture which distinct  
if _rc==111 {
di as err "Error: {regxfe} works with {distinct}."
di `"To install or update it, type or click on {stata "ssc install distinct, replace"}."'
exit 199
}
 
 capture confirm new file "`file'.dta"
 if _rc==602 & "`replace'"==""{
 display in red "File `file' already exists. Add replace option to overwrite the data"
 exit 602
 }

tokenize `varlist'
local y `1'
//get the rest of the vars
macro shift
local rest `*'
	  
marksample touse

foreach i in `fe' {
  qui:compress `i'
  local test: type `i' 
  if "`test'"!="byte" & "`test'"!="int" & "`test'"!="long"  {
     di in red "One of the FE variables is not byte, int or long"
		exit 322
  }
}

foreach i in `fe' `cluster' {
qui replace `touse'=0 if `i'==.
}

* check if fixed effects can be created
if "`xfe'"!="" {
    foreach h of local fe {
	     gen double `xfe'_`h'=0
	}
}
 
 local w:word 2 of `exp'

 *Check colinearity between Fixed effects
_rmcoll `fe', forcedrop

local fe2=r(varlist)

preserve
	tempname res
	qui: keep if `touse'
	qui: keep `varlist' `w' `cluster' `fe2'  
    if "`cluster'"!="" {
	 qui capture clonevar _`cluster'=`cluster'
	 local cl="_`cluster'"
     }
	qui: reg `varlist' [`weight'`exp'], `robust'  cluster(`cl')
	local rssc=e(rss)
	local tss=e(rss)+e(mss)
	local r2c=e(r2)

	if "`weight'"=="" {
		qui:sum `y' 
	}
	if "`weight'"!="" {
		qui:sum `y' [w`exp']
	}
	local yy=r(Var)

	foreach i in `varlist' {
		if "`weight'"=="" {
			qui:sum `i' , meanonly
			local `i'_=r(mean)
		}
		if "`weight'"!="" {
			qui:sum `i' [w`exp'], meanonly
			local `i'_=r(mean)
		}
	}
	 display "Transforming the data"
	 itercenter `varlist' [`weight'`exp'], fe(`fe2')  tolerance(`tolerance') maxiter(`maxiter') replace

	foreach i in `varlist' {
	qui:    replace `i'=`i'+``i'_' if `maxiter'!=0
	}
	local varlist2
	foreach i in `rest' {
		qui: sum `i' [`weight'`exp']
		*** the second condition is to reduce unnecessary iterations for cases of X variables colinear to the fixed effects
		if (r(sd))^2>0.000001 {
			local varlist2 `varlist2' `i'
		}
	}

	qui reg `y' `varlist2' [`weight'`exp'], `robust'  cluster(`cl')
	local mss=e(mss)
	local rssu=e(rss)
    
	
	qui:predict double `res', res

	qui:sum `res' [`weight'`exp']

	local rr=r(Var)
	if `mg'==-1 {
	display _newline "Estimating redundant parameters"   
		 nredound `fe2'
	}
	if `mg'!=-1 {
		ereturn scalar M=`mg'
	}
	local DF=0
	foreach h of local fe2 {
	 qui:distinct `h'
	 local DF=`DF'+r(ndistinct)
	}
	if "`file'"!="" {
	  foreach i of varlist `y' `varlist2' {
		  label var `i' "Demeaned `i'"
		  ren `i' d_`i'
		  }
	  save "`file'", replace
	}
restore

local dfm0=e(df_m)
matrix V=e(V)*(e(N)-e(df_m)-1)/(e(N)-e(df_m)-`DF'+e(M))
ereturn repost V=V, 

local df_m=e(df_m)+`DF'-e(M)-1
local df_r=e(N)-`df_m'-1
 

tempvar i_ 
tempvar res res2

qui:predict double `res' if `touse', res
 
if "`xfe'"!="" {
    display _newline "Recovering Fixed effects" 
    if "`tolerance'"==""   local tolerance=epsfloat() 
	local a0=0
	local a1=10
	local cntr=`maxiter'
	while abs(`a0'-`a1')>`tolerance' & `cntr'>0 {
		di "." _cont
		local cntr=`cntr'-1
		local a0=`a1'
		qui: sum `res'
		local a1=r(sd) 
		qui: foreach h of local fe {
		   capture gen double `xfe'_`h'=0
		   capture drop `i_'
		   bysort `h':center `res' [`weight'`exp'] if `touse', gen(`i_') double
		   replace `xfe'_`h'=`xfe'_`h'+`res'-`i_'
		   replace `res'=`i_'
		  }
	 }
	qui: foreach h of local fe {
	label var `xfe'_`h' "Estimated Fixed effect respect to `h'"
	}
}

if "`varlist2'"!="" {
qui test `varlist2'
local Fm=r(F)
}
else {
local Fm=0
}

local dfe=`DF'-e(M)-1
local Ff=((`tss'-`rssu')/(`df_m'))/(`rssu'/(`df_r'))
local Ffe=((`rssc'-`rssu')/(`DF'-e(M)-1))/(`rssu'/`df_r')
local r2=1-`rr'/`yy'
local M=e(M)
local r2w=e(r2)

ereturn repost, esample(`touse')
ereturn scalar r2o=`r2'
ereturn scalar r2w=`r2w'
ereturn scalar M=`M'

ereturn scalar Fm=`Fm'
local flag=e(vcetype)
if "`flag'"=="." { 
ereturn scalar Ff=`Ff'
ereturn scalar Ffe=`Ffe'
}
ereturn scalar df_m=`df_m'
ereturn scalar df_r=`df_r'
ereturn scalar dfm0=`dfm0'
ereturn scalar dfe=`dfe'
***other macross

ereturn local cmdline ="regxfe `varlist' `if' [`weight'`exp'], fe(`fe') cluster(`cluster') `roboust' xfe(`xfe') file(`file') mg(`mg') maxiter(`maxiter')"
ereturn local title="N-FE Linear regression"
ereturn local marginsok="XB default"
ereturn local depvar="`y'"
ereturn local cmd="regxfe"
ereturn local properties="b V"
ereturn local fe_varlist="`fe'"
*ereturn local predict="regxfe_p"
*ereturn local estat_cmd="regxfe_estat"

est_out
ereturn display
if `df_r'<0 {
  di "There is something wrong in the model, the number of degrees of freedom for the residuals shouldnt be negative"
}
if `r2'>0.99 {
   di "There is something wrong in the model, The overall model almost perfectly predicts the dependent variable"
}
end

capture program drop est_out
program est_out
  #delimit ;
  di ;
  di in gr _col(50) "Number of obs      = " in ye %8.0f e(N) ;
  ** Overall F
  di in gr "{hline 13}{c +}{hline 30}" _c;
  local flag=e(vcetype);
   if "`flag'"=="." { ;
  di in gr _col(50) "F_all(" %5.0f e(df_m) "," %6.0f e(df_r) ")= " in ye %8.3f e(Ff) ;
  di in gr _col(50) "Prob > F_all       = "  in ye %8.4f Ftail(e(df_m),e(df_r),e(Ff)) ;
  };
  ** Model F (without FE)
  di in gr "{hline 13}{c +}{hline 30}" _c;
   di in gr _col(50) "F_xb (" %5.0f e(dfm0) "," %6.0f e(df_r) ")= " in ye %8.3f e(Fm) ;
  di in gr _col(50) "Prob > F_xb        = "  in ye %8.4f Ftail(e(dfm0),e(df_r),e(Fm)) ;
  ** FE (joint test)
  di in gr "{hline 13}{c +}{hline 30}" _c;
  local flag=e(vcetype);
  if "`flag'"=="." { ;
  di in gr _col(50) "F_fe (" %5.0f e(dfe) "," %6.0f e(df_r) ")= " in ye %8.3f e(Ffe) ;
  di in gr _col(50) "Prob > F_fe        = "  in ye %8.4f Ftail(e(dfe),e(df_r),e(Ffe)) ;
  };
  di in gr _col(50) "R2-Overall         = " in ye %8.4f e(r2o) ; 
  di in gr _col(50) "R2-Within          = " in ye %8.4f e(r2w);
  local M=e(M)+1;
  di in gr _col(50) "# redundant FE     = " in ye %8.0f e(M) ;
  #delimit cr
  //display table 
end

*** version 1.1 Allows you to install the programs needed from excecution.
