*!v1.66 ADS EVENT TO HET
*!v1.65 Adds restrictions to Heterogeneity of Treatment Effect time / cohort
* v1.6  FEVAR: Allows Interactions
* v1.52 Minor Bug. No coeff if not existent
* v1.51 Addressed Bug when there is no never treated (but using never)
* v1.5  Multiple Methods plus extra
* some options not yet documented
* v1.42 Fixes Bug with Continuous Trt
* v1.41 Allows for multiple Options
*       Also FV and TS     
* v1.4  Allows for TRT to be continuous, and adds example
* v1.36 Adds TrtVar or Gvar
* v1.35 Adds method for margins
* v1.34 Minor Improv to Combinations. Also only works St15 or above
* v1.33 reduces ammount of ommited empty
* v1.32 Corrects for bug with no ivar
* v1.31 Corrects for Never group
* v1.3 Corrects for Nonlinear models
* 8/30/2022 corrects for long variables
* v1.2 FRA 8/17/2022 Adds Correction unbalanced panel
* v1.1 FRA 8/5/2022 Redef not yet treated. 
* v1   FRA 8/5/2022 Has almost everything we need
****
* Add to estat event, an option for Any ATTGT
* This means, a way to do simple, for post and pre..algo como el cevent. But based on Everything
* This version aims to incorporate features for Gravity

*** Incorporar Intensidad con dos tratamientos para Gravity. bi ffects

program jwdid_example
	preserve
	frause mpdta, clear
	display "jwdid lemp, ivar(countyreal) tvar(year) gvar(first) never"
	jwdid lemp, ivar(countyreal) tvar(year) gvar(first) never
	display "estat simple"
	estat simple
	display "estat calendar"
	estat calendar
	display "estat group"
	estat group
	display "estat event"
	estat event
	restore  	
end

program method_parser, rclass
	syntax namelist , [*]
	local method1:word 1 of `namelist'
	return local method `namelist'
	return local method1 `method1'
	return local options `options'
end

 program check_install, rclass
	syntax [namelist]
	foreach i in reghdfe hdfe `namelist' {
		capture which `i'
		if _rc!=0 {
			display in red as error "You need to install `i' from SSC"
			error 198
		}
	}
end

program jwdid, eclass
	** Error with 14 or earlier
	version 15
	** Replay
	syntax [ anything(everything)] [in] [pw iw aw], [example *]
	if replay() {
		if "`example'" !="" {
			jwdid_example
		}
		else {
			if "`e(cmd)'"=="jwdid" ereturn display
			else display "Last estimation not found"
		}
		exit
	}
	
	syntax varlist( fv ts) [if] [in] [pw iw aw],  [  Ivar(varname)  cluster(varlist) ] ///
								  [Tvar(varname) time(varname)   fevar(varlist fv ts)] /// fevar for other Fixed effects Valid for reghdfe and pmlhdfe
								  [Gvar(varname) trtvar(varname) trgvar(varname)] ///
								  [never group method(string asis) corr  ] ///
								  [hettype(string) * ]    ///
								  [exogvar(str asis) ]  /// Variables not to be interacted with Gvar Tvar Treatment
                                  [xtvar(str asis) ]  /// Variables interacted with  Tvar 
                                  [xgvar(str asis) ]  /// Variables interacted with Gvar 
								  [diff(str) ]
						
	// For Gravity
	// trendvar(varlist) trendt trendg trendij 
	if "`method'"!="" {
		method_parser `method'
		local method `r(method)'
		local method1 `r(method1)'
		local method_option `r(options)'
	}

	if "`hettype'"=="" local hettype timecohort

	if !inlist("`hettype'","time","cohort","timecohort","event") {
		display in red "hettype must be time, cohort, or timecohort"
		error 198
	}

	// Check installation
	check_install `method'

	marksample  touse
	markout    `touse' `ivar' `tvar' `gvar'
	gettoken y x:varlist 
	// y dep variable
	// x indep in Jwdid y xs
	if "`tvar'`time'"=="" {
		display in red "option time/tvar() required"
		error 198
	}
	if "`tvar'"=="" local tvar `time'

	if "`gvar'`trtvar'"=="" {
		display in red "option gvar/trtvar() required"
		error 198
	}

	if "`trtvar'`gvar'"=="" {
		display as error "Cohort variable not specified"
		error 198
	} 
	else if "`trtvar'"!="" & "`gvar'"!="" {
		display as error "You can only specify gvar or trtvar. Not both"		
		error 198
	}
	else if "`trtvar'"!="" {
		capture drop __gvar
		qui:_gjwgvar __gvar=`trtvar', tvar(`tvar') ivar(`ivar') 
		local gvar __gvar
	}
	// Groups refer to Gvar. Not compatible if not panel
	if "`ivar'"=="" local group group
	
	*easter_egg
	** Count gvar
	/*qui:count if `gvar'==0 & `touse'==1 
	if `r(N)'==0 {
		*qui:sum `gvar' if `touse'==1 , meanonly
		
	}*/
	** Take out of sample units that have always been treated.
	tempvar tvar2
	qui:bysort `touse' `ivar': egen long `tvar2'=min(`tvar')
	qui:replace `touse'=0 if `touse'==1 & `tvar2'>=`gvar' & `gvar'!=0 & `tvar'>=`gvar'
	
	** If no never treated
	qui:count if `gvar'==0 & `touse'==1 
	local nnever=0
	local gvarmax= .
	if `r(N)'==0 {
		qui:sum `gvar' if `touse'==1 , meanonly
		local gvarmax = r(max)
		qui:replace `touse'=0 if `touse'==1 & `tvar'>=`gvarmax' 
		local nnever=1
	}
	
	** Never makes estimation like SUN ABRaham
	** or CSDID with REG
	if "`trtvar'"=="" {
		qui:capture drop __tr__
		qui:gen byte __tr__=0 if `touse'
		display in w "`gvarmax'"
		qui:replace  __tr__=1 if `tvar'>=`gvar' & `gvar'>0  & `touse' 
		qui:replace  __tr__=1 if `touse' & "`never'"!=""  
		qui:replace  __tr__=0 if `touse' & `gvar'>=`gvarmax'		
	}	
	else {
		qui:capture drop __tr__
		qui:gen      __tr__=`trtvar' if `touse'
		qui:replace  __tr__=1        if `touse' & "`never'"!="" & `trtvar'==0 & `gvar'!=0
		qui:replace  __tr__=0        if `touse' & `gvar'>=`gvarmax'		
	}
	** But effect is done for effectively treated so
	qui:capture drop __etr__
	qui:gen byte __etr__=0 if `touse'
	qui:replace  __etr__=1 if `touse' & `tvar'>=`gvar' & `gvar'>0
	
	qui:levels `gvar' if `touse' & `gvar'>0 & `gvar'<`gvarmax', local(glist)
	sum `tvar' if `touse' , meanonly
	qui:levels `tvar' if `touse' & `tvar'>=r(min), local(tlist)
	
	** Center Covariates
	if "`weight'"!="" local wgt aw
	if "`diff'"=="" {
		if "`x'"!="" {
		// May need to add options for covariate heterogeneity	
				capture drop _x_*
				qui:hdfe `y' `x' if `touse'	[`wgt'`exp'], abs(`gvar') 	keepsingletons  gen(_x_)
				capture drop _x_`y'
				local xxvar _x_*
		
		}
	}
	else local xxvar `x'
	***
	mata: st_view(xs1 =.,.,"`gvar'","`touse'")
	mata: st_view(xs2 =.,.,"`tvar'","`touse'")
	mata: xs = uniqrows((xs1\xs2))
	mata: xs=select(xs,(xs:>0))
	mata: gap=min((xs[2..rows(xs),1]:-xs[1..rows(xs)-1,1]))
	mata: st_local("gap",strofreal(gap))
	mata: mata drop xs gap xs1 xs2
	*****************************************************
	*****************************************************
	// If Hettype Full
	if "`hettype'"=="timecohort" {
**********************************************************************************************************
		foreach i of local glist {
			foreach j of local tlist {
				qui:count if `i'==`gvar' & `j'==`tvar' & `touse'
				if `r(N)'>0 {
					if "`never'"!="" {
						if (`i'-`gap')!=`j' {
						
						local xvar `xvar'   c.__tr__#i`i'.`gvar'#i`j'.`tvar' 							  
						local xvar2 `xvar2'          i`i'.`gvar'#i`j'.`tvar' 
						
						if "`x'"!="" {
							local xvar `xvar'   c.__tr__#i`i'.`gvar'#i`j'.`tvar'#c.(`xxvar') 
							local xvar3 `xvar3'          i`i'.`gvar'#i`j'.`tvar'#c.(`xxvar')  
							}
						}
					}
					else if `j'>=`i' {

						local xvar `xvar'   c.__tr__#i`i'.`gvar'#i`j'.`tvar' 							  
						local xvar2 `xvar2' i`i'.`gvar'#i`j'.`tvar' 
						
						if "`x'"!="" {
							local xvar  `xvar'  c.__tr__#i`i'.`gvar'#i`j'.`tvar'#c.(`xxvar') 
							local xvar3 `xvar3'          i`i'.`gvar'#i`j'.`tvar'#c.(`xxvar')  
						}

					}
				}
			}
		}
**********************************************************************************************************
	}
	else if "`hettype'"=="time" {
**********************************************************************************************************
	qui: capture drop __post__
	qui: gen byte __post__ = 0 if `touse'
	qui: replace  __post__ = 1 if `tvar'<(`gvar'-`gap') & `gvar'>0
	qui: replace  __post__ = 2 if `tvar'>=`gvar'        & `gvar'>0
	qui: label define __post__ 0 "Base" 1 "Pre-Trt" 2 "Post-Trt", modify
	qui: label values __post__ __post__
		foreach i in 1 2 {
			foreach j of local tlist {
				qui:count if `i'==__post__ & `j'==`tvar' & `touse'
				if `r(N)'>0 {
					if "`never'"!="" {
											
						local xvar `xvar'   c.__tr__#i`i'.__post__#i`j'.`tvar' 							  
						local xvar2 `xvar2'          i`i'.__post__#i`j'.`tvar' 
						
						if "`x'"!="" {
							local xvar `xvar'   c.__tr__#i`i'.__post__#i`j'.`tvar'#c.(`xxvar') 
							local xvar3 `xvar3'          i`i'.__post__#i`j'.`tvar'#c.(`xxvar')  
						}
						
					}
					else if `i'==2 {

						local xvar `xvar'   c.__tr__#i`i'.__post__#i`j'.`tvar' 							  
						local xvar2 `xvar2'          i`i'.__post__#i`j'.`tvar' 
						
						if "`x'"!="" {
							local xvar  `xvar'  c.__tr__#i`i'.__post__#i`j'.`tvar'#c.(`xxvar') 
							local xvar3 `xvar3'          i`i'.__post__#i`j'.`tvar'#c.(`xxvar')  
						}

					}
				}
			}
		}
		
**********************************************************************************************************		
	}
	else if "`hettype'"=="cohort" {
**********************************************************************************************************
	qui: capture drop __post__
	qui: gen byte __post__ = 0 if `touse'
	qui: replace  __post__ = 1 if `tvar'<(`gvar'-`gap') & `gvar'>0
	qui: replace  __post__ = 2 if `tvar'>=`gvar'        & `gvar'>0
	qui: label define __post__ 0 "Base" 1 "Pre-Trt" 2 "Post-Trt", modify
	qui: label values __post__ __post__
		foreach i of local glist {
			foreach j in 1 2 {
				qui:count if `i'==`gvar' & `j'==__post__ & `touse'
				if `r(N)'>0 {
					if "`never'"!="" {
											
						local xvar `xvar'   c.__tr__#i`i'.`gvar'#i`j'.__post__ 							  
						local xvar2 `xvar2'          i`i'.`gvar'#i`j'.__post__
						
						if "`x'"!="" {
							local xvar `xvar'   c.__tr__#i`i'.`gvar'#i`j'.__post__#c.(`xxvar') 
							local xvar3 `xvar3'          i`i'.`gvar'#i`j'.__post__#c.(`xxvar')  
						}
						
					}
					else if `j'==2 {

						local xvar `xvar'   c.__tr__#i`i'.`gvar'#i`j'.__post__ 							  
						local xvar2 `xvar2'          i`i'.`gvar'#i`j'.__post__ 
						
						if "`x'"!="" {
							local xvar  `xvar'  c.__tr__#i`i'.`gvar'#i`j'.__post__#c.(`xxvar') 
							local xvar3 `xvar3'          i`i'.`gvar'#i`j'.__post__#c.(`xxvar')  
						}

					}
				}
			}
		}
		
**********************************************************************************************************	
	}
	else if "`hettype'"=="event" {
**********************************************************************************************************
	qui: capture drop __evnt__
	qui: gen byte __evnt__ = (`tvar'-`gvar')*(`gvar'>0) -`gap'*(`gvar'==0) if `touse'
	
        qui: sum __evnt__ if `touse', meanonly
        local cev = 1-`r(min)'
        qui: replace __evnt__ = __evnt__+(`cev')
        local gpevent = -`gap'
    
    qui:levelsof __evnt__ if `touse', local(elist)
    if "`never'"=="" qui:levelsof __evnt__ if `touse' & __evnt__>-1, local(elist)
 
	** Create __event__ and label it
	** use __evnt__ to avoid conflict with other variables
	foreach i of local elist {
		local ccev = `i'-`cev'
		  if (`ccev')< 0  label define __evnt__ `i' "t`ccev'" , modify
		else if (`i'+`cev')> 0  label define __evnt__ `i' "t+`ccev'", modify
		else if (`i'+`cev')==0  label define __evnt__ `i' "t+0"     , modify
	}
	label values __evnt__ __evnt__
	foreach i of local elist {
		local ccev = `i'-`cev'
		qui:count if `i'==__evnt__ & `touse'
			if `r(N)'>0 {
				if "`never'"=="" & (`ccev'>-1) {	
					local xvar `xvar'   c.__tr__#i`i'.__evnt__
					local xvar2 `xvar2'          i`i'.__evnt__						
					if "`x'"!="" {
						local xvar `xvar'   c.__tr__#i`i'.__evnt__#c.(`xxvar') 
						local xvar3 `xvar3'          i`i'.__evnt__#c.(`xxvar')  
					}
				}
				if "`never'"!="" & `ccev'!=(-`gap') {	
					local xvar `xvar'   c.__tr__#i`i'.__evnt__
					local xvar2 `xvar2'          i`i'.__evnt__						
					if "`x'"!="" {
						local xvar `xvar'   c.__tr__#i`i'.__evnt__#c.(`xxvar') 
						local xvar3 `xvar3'          i`i'.__evnt__#c.(`xxvar')  
					}
				}
			}
		}
		
**********************************************************************************************************	
	}	

	** for xs
	
	foreach i of local glist {
		local ogxvar `ogxvar'           i`i'.`gvar'#c.(`x' `xgvar')
	}
	
	foreach j of local tlist {
        local cj = `cj'+1
        if `cj'>1 local otxvar `otxvar' i`j'.`tvar'#c.(`x' `xtvar')
	}

	
 	*display in w "t:`otxvar'"
	*display in w "g:`xvar'"
	** Cluster level
	if "`cluster'"=="" & "`ivar'"=="" local cvar 
	if "`cluster'"=="" & "`ivar'"!="" local cvar `ivar'
	if "`cluster'"!=""                local cvar `cluster'
	
	if "`method1'"=="fracreg" local tocluster vce(cluster `cvar')
	else local tocluster cluster(`cvar')
	
	if "`method'"=="" {
		if "`group'"=="" {
			
			reghdfe `y' `xvar'   `otxvar' 	`exogvar' ///
				if `touse' [`weight'`exp'], abs(`ivar' `tvar' `fevar') `tocluster' keepsingletons
			local scmd `e(cmdline)'		
		}	
		else {
			if "`ivar'"!="" {
				qui:xtset `ivar' `tvar'
				mata:is_balanced("`ivar' `tvar'","`touse'")
		 
				if `ibal'==0 & "`corr'"!="" {
					** Correction 
					qui:myhdmean `xvar2' `xvar3' `otxvar' i.`tvar' if `touse'	[`wgt'`exp'] , prefix(_z_) keepsingletons abs(`ivar')
					local xcorr  `r(vlist)'
				}
			}	
			reghdfe `y' `xvar'  `x'  `ogxvar' `otxvar'  `xcorr' `exogvar' ///
			if `touse' [`weight'`exp'], abs(`gvar'  `tvar' `fevar') `tocluster' keepsingletons noempty
			local scmd `e(cmdline)'
		}
	}
	else if "`method'"=="ppmlhdfe" {
		ppmlhdfe `y' `xvar'   `otxvar'	`exogvar' ///
				if `touse' [`weight'`exp'], abs(`ivar' `tvar' `fevar') `tocluster' keepsingletons ///
				d `method_option'
		local scmd `e(cmdline)'				
	}	
	else {
		if "`ivar'"!="" {
			qui:xtset `ivar' `tvar'
			mata:is_balanced("`ivar' `tvar'","`touse'")	
			if   "`corr'"!=""  {
					** Correction 
					qui:myhdmean `xvar2'  i.`tvar' if `touse'	[`wgt'`exp'] , prefix(_z_) keepsingletons abs(`ivar')
					local xcorr  `r(vlist)'				
			} 
		}
		`method'  `y' `xvar'  `x'  `ogxvar' `otxvar' `xcorr' `exogvar'   i.`gvar' i.`tvar' ///
		if `touse' [`weight'`exp'], `tocluster' `method_option'
		local scmd `e(cmdline)'
	}
	
	ereturn local cmd jwdid
	ereturn local cmd2 `method'
	ereturn local cmdopt `method_option'

	ereturn local cmdline jwdid `0'
	ereturn local scmd `scmd'
	ereturn local hettype `hettype'
	ereturn local estat_cmd jwdid_estat
	if "`never'"!="" ereturn local type  never
	else 			 ereturn local type  notyet

	ereturn local ivar `ivar'
	ereturn local tvar `tvar'
	ereturn local gvar `gvar'
	
end

mata
void is_balanced(string scalar ivars, string scalar touse){
	real matrix ivar, tvar, inf, ord
	
	ivar=st_data(.,ivars,touse)
	ord=order(ivar,(1,2))
	inf=panelsetup(ivar,1)
	// same number of observations
	real scalar max1, min1, max2 , max3, min2 , min3
	max1=max(inf[,2]:-inf[,1])
	min1=min(inf[,2]:-inf[,1])
	// same max and min
	max2=max(ivar[inf[,1],2])
	min2=min(ivar[inf[,1],2])
	max3=max(ivar[inf[,2],2])
	min3=min(ivar[inf[,2],2])
	if ( (max1==min1) & (max2==min2) & (max3==min3)) st_local("ibal","1")
	else st_local("ibal","0")
}
end

program easter_egg
	
	local date_to = date("`c(current_date)'","DMY")
	local month   = month(`date_to')
	local day     = day(`date_to')
	
	if runiform()<0.001 | (`month'==8 & `day'==6 & runiform()<0.1 ) {
	display in w "{p}Hi there, thank you for using this command. I hope you are finding this 'easter egg' as a surprised, and not because you " ///
	"decided to take a peak on the code. But if you did, shame on me for not making a better easter egg {p_end}"
	display in w "{p}Anyways, This easter egg is for my Daughter! Yes as of August 6th 2022 (Viva Bolivia) my little one was born!. " _n  ///
		"so if you happen to read this, two things happen. Either you were in the 0.1% lucky to see this, or its my little one birthday. If the latter  please send my little one, a Happy Birthday! {p_end}"
	}
end

program myhdmean, rclass
	syntax anything [if] [aw iw pw fw], abs(varlist) prefix(name) [compact  keepsingletons]
	
	ms_fvstrip `anything' `if', expand dropomit
	local vvlist `r(varlist)'
	** First check and create
	** local k =0 for names
	foreach i in `vvlist' {
		local k=`k'+1
		capture confirm variable `i'
		if _rc!=0 {
			if length(strtoname("`i'"))<25 local vn = strtoname("`i'")
			else local vn _nvar_`k'
			gen double `vn'=`i'
			label var `vn' `"`i'"'
			local dropvlist `dropvlist' `vn'
			
		}
		else local vn `i'
		
		local vflist `vflist' `vn'
	}
	
	if "`compact'"=="" {
		foreach i in `vflist' {
			local cnt
			local fex
			foreach j of varlist `abs' {
				local cnt=`cnt'+1
				capture drop `prefix'`cnt'_`i'
				local fex `fex' `prefix'`cnt'_`i'=`j'
				local vlist `vlist' `prefix'`cnt'_`i'
			}
			qui:reghdfe `i' `if'  [`weight'`exp'], abs(`fex')  `keepsingletons'
			local vlab:variable label `i'
			
			label var `prefix'`cnt'_`i' "`vlab'"
		}
		local vflist `vlist'
		local vlist
		foreach i in `vflist' {
			capture:{
				sum `i', meanonly
				if abs(`r(max)'-`r(min)')>epsfloat() local vlist `vlist' `i'
				else local dropvlist `dropvlist' `i'
			}
		}
		
		return local vlist  `vlist'
	}
	else {
		foreach i in  `vflist' {
			local cnt
			local fex
			capture drop `prefix'`cnt'_`i'
			qui:reghdfe `i' `if'  [`weight'`exp'], abs(`abs') resid `keepsingletons'
			qui:gen double `prefix'`cnt'_`i'=`i'-_reghdfe_resid-_cons
			local vlist `vlist' `prefix'`cnt'_`i'
			qui:drop _reghdfe_resid
			
		}
		
		local vflist `vlist'
		local vlist
		foreach i in `vflist' {
			sum `i', meanonly
			if abs(`r(max)'-`r(min)')>epsfloat() local vlist `vlist' `i'
			else local dropvlist `dropvlist' `i'
		}
		return local vlist   `vlist'
	}
	*display in w "`dropvlist'"
	if "`dropvlist'"!="" drop `dropvlist'
	
end

** Aux var for jwdid
program _gjwgvar, sortpreserve
	syntax newvarname =/exp [if] [in], tvar(varname) ivar(varname)
	local exp = subinstr("`exp'","(","",.)
	local exp = subinstr("`exp'",")","",.)
	tempvar touse
	qui:gen byte `touse'=0
	qui:replace `touse'=1 `if' `in'
	qui:replace `touse'=0 if `tvar'==. | `ivar'==. | `exp'==.
	tempvar vals
	sum `exp' if `touse' , meanonly
	local lmin=r(min)
	local lmax=r(max)
	if `lmin'<0 | `lmax'>1 {
			display in r "`exp' can only have values between 0 and 1"
			error 4444
	}
	qui: {
		tempvar aux auxd
		qui: gen byte `auxd'=`exp'>0 if `exp'!=.
		bysort `touse' `ivar' `auxd':egen `aux'=min(`tvar')
		replace `aux'=0 if `exp'==0
		by     `touse' `ivar':egen `varlist'=max(`aux')
		replace `varlist'=. if `exp'==. | !`touse'
	}
	label var `varlist' "Group Variable based on `exp'"
end

*** Problem.
/*
What to do if DIF(1) c.x does give you a different result from dif() c.dx
So far Cohort works well, because DIFF is based on cohort
We need to figure something similar for the others. Perhaps it would work 
if DIFF depends on the Constrained variable
*/