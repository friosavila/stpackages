*! v1.21 Change Renaming of variables from _x_ to simply X when #
*! v1.2 Adds labels to _mn_vars
*! v1.1 Fixes a problem for endogenous option 
*Original code by Anastasia Semykina
*This version Modified by Fernando Rios-Avila
*adding instruments
* Tried to do asymptotic moments but was too difficult. Perhaps at some other time.

*capture program define  drop parseselection 
*capture program define  drop _xthck 
*capture program define  drop _xthckiv 
*capture program define  drop xtheckmanfe
*capture program define  drop myparse_endog

program define  myparse_endog, rclass
syntax anything, 
	local rest `anything'
	while "`rest'"!="" {
	   gettoken eqt rest: rest, match(nvu) parse("(")
	   if "`eqt'"!="" {
		  local cnt=`cnt'+1
		  local r`cnt' `eqt'
	   }
	}
	forvalues j=1/`cnt' {
		return local m`j' `r`j''
	}
return scalar cnt =`cnt'
end

program define  parseselection, rclass
	syntax anything(equalok)
	
	local equal=strrpos("`anything'","=")
	if `equal'==0  {
		local z2 `anything'
		}
	else if `equal'!=0  {
	    local sel2=subinstr("`anything'","="," ",.)
		tokenize `sel2'
		local y2 `1'
		macro shift
		local z2 `*'
	}	
	return local selvar  ="`y2'"
	return local xselvar ="`z2'"
end

program define  parseselection2, rclass
	syntax anything(equalok)
	
	local equal=strrpos("`anything'","=")
	if `equal'==0  {
		noisily:display in red "No endogenous variables declared"
		error 1
		}
	else if `equal'!=0  {
		tokenize `anything', parse("=")
		local y2 `1'
		local z2 `3'
	}	
	return local endvar  ="`y2'"
	return local xendvar ="`z2'"
end

*if `touse', y1(`y1') y2(`y2') z1(i.time#c.(`z1' `mn_var_z1')) x1(`x1' `mn_var_x1') time(`time')

program define  xtheckmanfe2, eclass
	if replay() {
		if "`e(cmd)'"=="xtheckmanfe2" {
			ereturn display
			exit
		}
		else {
			display in red "last extimates not found"
			exit 301
		}
	}
	
version 13
syntax varlist(fv) [if], SELECtion(str) [ ENDogenous(str) id(varname) time(varname) reps(integ 50) seed(str)]
 
** This version will be based on Semykina, but standard errors will be done using Bootstrap
** Step 1. Gather all variables of interest
	qui:capture which ftools
	if _rc==111 {
		display in red "The command requires " as result "ftools"
		display as text "You can install it using {stata ssc install ftools}"
		exit 111
	}
		
	capture:qui:drop _mn_*
	capture:qui:drop _sel_imr
*** This get main model and explanatory variables
    tokenize `varlist'
	local y1 `1'
	macro shift
	local x1 `*'

*** Need to parse Selection
	parseselection `selection'
	local y2 `r(selvar)'
	local z1 `r(xselvar)'
	
*** Need to parse Endogenous
	if "`endogenous'"!="" {
		parseselection2 `endogenous'
		local y3 `r(endvar)'
		local z2 `r(xendvar)'
	}
*** sample def
	marksample touse , novarlist
	markout `touse' `x1' `y2' `z1' `y3' `z2' `id' `time', strok
	
 *** redefine smp
	if "`y2'"=="" {
		tempvar ss 
		qui:gen byte `ss'=`y1'!=.
		local y2 `ss'
	}
	
*** define id and time
	if ("`id'"!="" & "`time'"=="") | ("`id'"=="" & "`time'"!="") {
		display in red "Need to define id and time. Otherwise leave blank to use information from xtset"
		exit 1
	}
	else if ("`id'"=="" & "`time'"=="") {
		qui:xtset
		local id   `r(panelvar)'
		local time `r(timevar)'
		local isxtset = 1 
	}
 *** Generate variables for Probit. The Mundalk version
	** may consider doing this using myhdfe 
	* the model is defined as
	* y1 = xb+y3*g+e if y2==1
	* selection
	* y2 = xb+z1 +z2 
	* endogeneity
	* y3 = xb+z2 
	* main variables all Exogenous
	myhdfe `x1' if `touse', abs(`id')
		 local mn_var_x1  `r(mn_varlist)'
	* selection variables. can be empty? should not	
	myhdfe `z1' if `touse', abs(`id')
		 local mn_var_z1  `r(mn_varlist)'		
	if "`endogenous'"!="" {
		* endogenous variables	
		*myhdfe `y3' if `touse', abs(`id')
		*** Here is the question. What happens if a variable is endogenous. would mean_y be instrumented with mean_z? mean_y not for now
		*local mn_var_y3  `r(mn_varlist)'
		* instruments for endogenous variables 
		myhdfe `z2' if `touse', abs(`id')
			 local mn_var_z2  `r(mn_varlist)'
	}

	//	Initial model estimation quietly
	if "`endogenous'"==""  {
		qui:xtset, clear
 	 
		* Very simple heckman model with time interaction
		* Try doing it!
		probit `y2' i.`time'#c.(`x1' `z1' `xz1m' ) i.`time' if `touse', from(`bpi', skip)
		reg `y1' `x1' `xz1m'  i.`time' i.`time'#c.(_sel_imr) if `y2'==1 & `touse'	
		
		ml model lf xtheckmanfe_ml ///
		(wage:wage = education age) /lnsigma ///
		(wageseen:wageseen = married children educ age) (arho:  ) , ///
		init(b, skip) maximize ///
		technique(nr bhhh) missing 
		
		if "`isxtset'"=="1" qui:xtset `id' `time'
	}

	
	ereturn local cmd      "xtheckmanfe2"
	ereturn local cmdline  "xtheckmanfe2 `0'"
end 
**	
program drop xtheckmanfe_ml
program define xtheckmanfe_ml
	args lnf xb lnsigma zg  arho
	qui {
		tempvar rho  sigma 
		 
		*gen double `rho'   = tanh(`arho')
		gen double `sigma' = exp(`lnsigma')
		** probit first
		replace `lnf'=log(normal(-`zg')) if $ML_y2==0
		replace `lnf'=log(normal( `zg')) if $ML_y2==1
		tempvar imr
		gen double `imr'=normalden(`zg')/normal(`zg')
		replace `lnf'=`lnf'+log(normalden($ML_y1 , `xb'+`arho'*`imr',`sigma')) if $ML_y2==1
	}
end

		


 program define  myhdfe, rclass
syntax varlist(fv) [if] , abs(varname)
	marksample touse
 	ms_fvstrip `varlist' if `touse', expand dropomit
	local 1:word count `r(nobase)'
	local nb `r(nobase)'
	local fvl `r(fullvarlist)'
	forvalues i=1/`1' {
		local i1:word `i' of `nb'
		local i2:word `i' of `fvl'
		local vnm = subinstr("`i2'",".","_",.)
		local vnm = subinstr("`vnm'","#","X",.)
		local flag = 0
		if strlen("`vnm'")>25 {
		    local flag = 1
			local lvnm "`vnm'" 
			local vnm `i'
		}
		if "`i1'"=="0" {
			capture:qui:gen byte _mn_`vnm'=0
		}
		else if "`i1'"=="1" {
			capture:qui:egen double _mn_`vnm' = mean(`i2') if `touse', by(`abs')
		}
		label var _mn_`vnm' "Mean of `i2'"
		
		local mn_varlist `mn_varlist' _mn_`vnm'
	}
 	return local mn_varlist  `mn_varlist'
 end 
/*
notes for me and asymptotic
W=x y2 mill     K
Z=x z1 mill     J
h=x z1 z2       H
e=y1-W*b 

ZEEZ=Z(ee)Z' J x J 
EE=residuals original model
ZEQ JxH 
ZEQ Z*e * mills * h   by ID
where: 
   ZEQ=Z*ehat by panel... X QxVar   JxH 
   qui gen eh`var'=`var'*ehat;
   qui egen t`var' = sum(eh`var'), by(`id');
   Q is mills from Probit     (score0

   H = VCOV probit 
   
ZG = H x J
Z*(-lambda*(lambda+xb)*gamma`i')*h 
** see how they "are"

mat TERM2=ZEQ*H*ZG'; 13x28 28x28 28x13

QQ = h x q x q x h
mat TERM4=ZG*H*QQ*H*ZG';

WZ*invsym(ZZ)*WZ'

mat VB=WZ*invsym(ZZ)*(TERM1-TERM2-TERM2'+TERM4)*invsym(ZZ)*WZ';

mat V2=invsym(A)*B*invsym(A)*(e(N)-1)*g/((g-1)*(e(N)-K-L2-2*tmax));
*/
