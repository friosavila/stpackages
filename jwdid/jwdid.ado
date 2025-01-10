*!v2.12 Bug with tobit
*v2.11 Bug with trtvar
*v2.10 CRE! An addition of corrections for nonlinear models 
*v2.01 xattvar
*v2.00 Paper Out
*v1.77 Allows Anticipation 
*v1.76 Excludes Fixed variables from the interactions with Cohort
*v1.75 May allow for Intervalled Event
*v1.71  Better Hettype
*v1.7  Adds Event Hettype. Also allows to use Characteristics as is, or demean.
* Further Panel Data Corrections
* v1.65 Adds restrictions to Heterogeneity of Treatment Effect time / cohort
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

program parse_hettype, rclass
    syntax anything, [ll(numlist max =1) ul(numlist max=1) * ]
    
    if ("`ll'"!="") & ("`ul'"!="") {
        if `ll'>=`ul' {
            display as err "ll() has to be smaller than ul()"
            error 911
        }
    }
    
    return local hettype `anything'
    return local ll `ll'
    return local ul `ul'
end

program parse_hettype_evco, rclass
    syntax anything,  evbase(numlist max=1) erecode(string asis) [* ]
    tempvar aux
    ren __evnt__ `aux'
    recode `aux' `erecode', gen(__evnt__)    
    return local evbase = `evbase'

end

** Gets list of variables
program getvarlist, rclass 
    syntax varlist (fv ts)
    ** First Get varlist
    fvexpand `varlist' 
    local vlist = subinstr("`r(varlist)'","."," ",.)
    local vlist = subinstr("`vlist'","#"," ",.)
    novarabbrev {
        foreach i of local vlist {
            capture confirm numeric var `i'
            if _rc ==0 {
                local vvlist `vvlist' `i'
                
            }
            
        }
    }
    ** Keep nonrepeating ones
    mata: a=tokens("`vvlist'");a=uniqrows(a')';st_local("vvlist",invtokens(a))
    return local varlist `vvlist'        
end

**  Small program to check fix vars
mata:
    void mt_fixvar(string scalar xvarname, string scalar touse){
        real matrix xvar
        real matrix info
        real scalar i
        real matrix csum
        string matrix toret1 , toret2
        // Load all data
        xvar = st_data(.,xvarname,touse)        
        // sort and PanelStup 
        xvar=xvar[order(xvar[,1],1) ,]
        // panel
        info = panelsetup(xvar,1)
        // sort across all variables
        for(i=2;i<=cols(xvar);i++)    xvar[,i]=xvar[order(xvar[,(1,i)],(1,2)),i]
        // verify if Variables change
        csum =colsum(xvar[info[,2],]:-xvar[info[,1],])
        toret1 = invtokens(select(tokens(xvarname), csum ))
        toret2 = invtokens(select(tokens(xvarname),!csum ))
        st_global("r(xvarvar)",toret1)
        st_global("r(xvarcons)",toret2)
    }
end

program is_x_fix, rclass
    syntax varlist(fv ts) [if], ivar(varname)
    ** Expand Interactions
    marksample touse
    ms_fvstrip `varlist', expand dropomit
    local evarlist `r(varlist)'    
    ** ID original variables
    getvarlist `varlist'
    local xvarlist `r(varlist)'    
  fvset base none `xvarlist '
    mata:mt_fixvar("`ivar' `evarlist '","`touse'")
  fvset base default `xvarlist'
    
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
								  [hettype(string asis) * ]    ///
								  [exovar(varlist fv ts) exogvar(varlist fv ts) ]  /// Variables not to be interacted with Gvar Tvar Treatment
                                  [xtvar(varlist fv ts) ]  /// Variables interacted with  Tvar 
                                  [xgvar(varlist fv ts) ]  /// Variables interacted with Gvar 
                                  [xattvar(varlist fv ts) ]  /// Variables interacted with Tvar x Gvar <- for Treatment Heterogeneity
								  [xasis cre] ///  
								  [ANTIcipation(numlist max=1 >0) ] // Allows for Anticipation
						
	// For Gravity
	// Anticipation is the number of periods before the event
	// Default is 1 (so g-1 is the excluded period)
	if "`anticipation'"=="" local anti 1
	else local anti `anticipation'

	if "`method'"!="" {
		method_parser `method'
		local method `r(method)'
		local method1 `r(method1)'
		local method_option `r(options)'
	}
	** Does not matter if one uses Exovar or Exogvar. Same thing
	local exogvar `exovar' `exogvar'

	if "`hettype'"=="" local hettype timecohort
   
    parse_hettype `hettype'
    local ehettype `r(hettype)'
    local rll     `r(ll)'
    local rul     `r(ul)'
    
	if !inlist("`ehettype'","time","cohort","timecohort","event","eventcohort","twfe") {
		display in red "hettype must be time, cohort, or timecohort"
		error 198
	}
    if "`ehettype'"=="eventcohort" local never never
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
	if "`method'"!="" & "`method'"!="ppmlhdfe" {
		local group group
	} 
	// ID Time Fixed Variables
	local xvarvar `x'

 	if "`ivar'"!="" & "`group'"=="" & "`x'"!="" {
		is_x_fix `x' if `touse', ivar(`ivar')
		local xvarcons  `r(xvarcons)'
		local xvarvar   `r(xvarvar)'
 
	}

 	*easter_egg
	** Count gvar
	/*qui:count if `gvar'==0 & `touse'==1 
	if `r(N)'==0 {
		*qui:sum `gvar' if `touse'==1 , meanonly
		
	}*/

	** Exclude of sample units that have always been treated.
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
	
	*** Define the gap (across gvar tvar)
	mata: st_view(xs1 =.,.,"`gvar'","`touse'")
	mata: st_view(xs2 =.,.,"`tvar'","`touse'")
	mata: xs = uniqrows((xs1\xs2))
	mata: xs=select(xs,(xs:>0))
	mata: gap=min((xs[2..rows(xs),1]:-xs[1..rows(xs)-1,1]))
	mata: st_local("gap",strofreal(gap))
	mata: mata drop xs gap xs1 xs2

	local antigap = `gap'*`anti'
	local antigap0 = `gap'*(`anti'-1)


	** Redefine Always treated
	tempvar tvar2
	qui:bysort `touse' `ivar': egen long `tvar2'=min(`tvar')
	qui:replace `touse'=0 if `touse'==1 & `tvar2'>=(`gvar'-`antigap0') & `gvar'!=0 & `tvar'>=(`gvar'-`antigap0')


	** Never makes estimation like SUN ABRaham
	** or CSDID with REG
	if "`trtvar'"=="" {
		qui:capture drop __tr__
		qui:gen byte __tr__=0 if `touse'
		//display in w "`gvarmax'"
		qui:replace  __tr__=1 if `tvar'>=(`gvar'-`antigap') & `gvar'>0  & `touse' 
		qui:replace  __tr__=1 if `touse' & "`never'"!=""  
		qui:replace  __tr__=0 if `touse' & `gvar'>=`gvarmax'	
		
	}	
	else {		
		qui:capture drop __tr__
		qui:gen      __tr__=`trtvar' if `touse'
		qui:replace  __tr__=1        if `touse' & "`never'"!="" & `trtvar'==0 & `gvar'!=0
		qui:replace  __tr__=0        if `touse' & `gvar'>=`gvarmax'		
		qui:replace  __tr__=0 if `touse' & `tvar'<(`gvar'-`antigap')	
	}
	
	** But effect is done for effectively treated so
	qui:capture drop __etr__
	qui:gen byte __etr__=0 if `touse'
	qui:replace  __etr__=1 if `touse' & `tvar'>(`gvar'-`antigap') & `gvar'>0
	
	qui:levels `gvar' if `touse' & `gvar'>0 & `gvar'<`gvarmax', local(glist)
	sum `tvar' if `touse' , meanonly
	qui:levels `tvar' if `touse' & `tvar'>=r(min), local(tlist)
	
	*** Center Covariates
	if "`weight'"!="" local wgt aw

** Define Toabs based on Het Type
************************************
	tempvar toabshere
	if "`ehettype'"=="timecohort"  qui:egen `toabshere'=group(`gvar' `tvar') if `touse'
	if "`ehettype'"=="cohort"      {
		qui: capture drop __post__
		qui: gen byte __post__ = 0 if `touse'
		qui: replace  __post__ = 1 if `tvar'< (`gvar'-`antigap' ) & `gvar'>0 &  `touse'
		qui: replace  __post__ = 2 if `tvar'>=(`gvar'-`antigap0') & `gvar'>0 &  `touse'
		qui: label define __post__ 0 "Base" 1 "Pre-Trt" 2 "Post-Trt", modify
		qui: label values __post__ __post__		
		qui:egen `toabshere'=group(`gvar' __post__) if `touse'
	}
	if "`ehettype'"=="time"        {
		qui: capture drop __post__
		qui: gen byte __post__ = 0 if `touse'
		qui: replace  __post__ = 1 if `tvar'< (`gvar'-`antigap' ) & `gvar'>0 &  `touse'
		qui: replace  __post__ = 2 if `tvar'>=(`gvar'-`antigap0') & `gvar'>0 &  `touse'
		qui: label define __post__ 0 "Base" 1 "Pre-Trt" 2 "Post-Trt", modify
		qui: label values __post__ __post__
		qui:egen `toabshere'=group(`tvar' __post__ ) if `touse'
	}
	if "`ehettype'"=="twfe"        {
		qui: capture drop __post__
		qui: gen byte __post__ = 0 if `touse'
		qui: replace  __post__ = 1 if `tvar'< (`gvar'-`antigap' ) & `gvar'>0 &  `touse'
		qui: replace  __post__ = 2 if `tvar'>=(`gvar'-`antigap0') & `gvar'>0 &  `touse'
		qui: label define __post__ 0 "Base" 1 "Pre-Trt" 2 "Post-Trt", modify
		qui: label values __post__ __post__
		qui:egen `toabshere'=group( __post__ ) if `touse'
	}
	if "`ehettype'"=="event"        {
        
		qui: capture drop __evnt__
		qui: gen byte __evnt__ = (`tvar'-`gvar')*(`gvar'>0) -`gap'*(`gvar'==0) if `touse'	
        if "`rul'"!="" qui: replace __evnt__=`rul' if __evnt__>`rul' & __evnt__!=.
        if "never"!="" & "`rll'"!="" qui: replace __evnt__=`rll' if __evnt__<`rll' & __evnt__!=.
        qui: sum __evnt__ if `touse', meanonly
        local cev = 1-`r(min)'
        qui: replace __evnt__ = __evnt__+(`cev')
		qui:egen `toabshere'=group( __evnt__ ) if `touse'
        
	}
    if "`ehettype'"=="eventcohort"  {
        local never never
    	qui: capture drop __evnt__
		qui: gen byte __evnt__ = (`tvar'-`gvar')*(`gvar'>0) -`gap'*(`gvar'==0) if `touse'
        ** Recodes
        parse_hettype_evco `hettype'
        local evbase = r(evbase)
        **base(numlist max=1) erecode(stringasis)
        sum __evnt__, meanonly
        if `r(min)'<0 {
            display as error "All values after Recode should be strictly possitive"
            error 1
        }
        
        qui:egen `toabshere'=group(`gvar' __evnt__ ) if `touse'
    }
************************************
** Two options: Either we Demean  data, or used actual data
** Same Results		
	if "`xasis'"=="" {
		if "`x'`xattvar'"!="" {
				capture drop _x_*
				qui:hdfe `y' `x' `xattvar' if `touse'	[`wgt'`exp'], abs(`toabshere') 	keepsingletons  gen(_x_)
				capture drop _x_`y'
				local xxvar _x_*
		}
	}
	else local xxvar `x' `xattvar'
 
	*****************************************************
	*****************************************************
	// If Hettype Full
	if "`ehettype'"=="timecohort" {
**********************************************************************************************************
		foreach i of local glist {
			foreach j of local tlist {
				qui:count if `i'==`gvar' & `j'==`tvar' & `touse'
				if `r(N)'>0 {
					if "`never'"!="" {
						if (`i'-`antigap')!=`j' {
						
						local xvar  `xvar'   c.__tr__#i`i'.`gvar'#i`j'.`tvar' 							  
						local xvar2 `xvar2'           i`i'.`gvar'#i`j'.`tvar' 
						
						if "`x'`xxvar'"!="" {
							local xvar  `xvar'   c.__tr__#i`i'.`gvar'#i`j'.`tvar'#c.(`xxvar') 
							local xvar3 `xvar3'           i`i'.`gvar'#i`j'.`tvar'#c.(`xxvar')  
							}
						}
					}
					else if `j'>=(`i'-`antigap0') {

						local xvar `xvar'   c.__tr__#i`i'.`gvar'#i`j'.`tvar' 							  
						local xvar2 `xvar2'          i`i'.`gvar'#i`j'.`tvar' 
						
						if "`x'`xxvar'"!="" {
							local xvar  `xvar'  c.__tr__#i`i'.`gvar'#i`j'.`tvar'#c.(`xxvar') 
							local xvar3 `xvar3'          i`i'.`gvar'#i`j'.`tvar'#c.(`xxvar')  
						}

					}
				}
			}
		}
**********************************************************************************************************
	}
	else if "`ehettype'"=="time" {
**********************************************************************************************************
		foreach i in 1 2 {
			foreach j of local tlist {
				qui:count if `i'==__post__ & `j'==`tvar' & `touse'
				if `r(N)'>0 {
					if "`never'"!="" {
											
						local xvar `xvar'   c.__tr__#i`i'.__post__#i`j'.`tvar' 							  
						local xvar2 `xvar2'          i`i'.__post__#i`j'.`tvar' 
						
						if "`x'`xxvar'"!="" {
							local xvar `xvar'   c.__tr__#i`i'.__post__#i`j'.`tvar'#c.(`xxvar') 
							local xvar3 `xvar3'          i`i'.__post__#i`j'.`tvar'#c.(`xxvar')  
						}
						
					}
					else if `i'==2 {

						local xvar `xvar'   c.__tr__#i`i'.__post__#i`j'.`tvar' 							  
						local xvar2 `xvar2'          i`i'.__post__#i`j'.`tvar' 
						
						if "`x'`xxvar'"!="" {
							local xvar  `xvar'  c.__tr__#i`i'.__post__#i`j'.`tvar'#c.(`xxvar') 
							local xvar3 `xvar3'          i`i'.__post__#i`j'.`tvar'#c.(`xxvar')  
						}

					}
				}
			}
		}
		
**********************************************************************************************************		
	}
	else if "`ehettype'"=="cohort" {
**********************************************************************************************************
		foreach i of local glist {
			foreach j in 1 2 {
				qui:count if `i'==`gvar' & `j'==__post__ & `touse'
				if `r(N)'>0 {
					if "`never'"!="" {
											
						local xvar `xvar'   c.__tr__#i`i'.`gvar'#i`j'.__post__ 							  
						local xvar2 `xvar2'          i`i'.`gvar'#i`j'.__post__
						
						if "`x'`xxvar'"!="" {
							local xvar `xvar'   c.__tr__#i`i'.`gvar'#i`j'.__post__#c.(`xxvar') 
							local xvar3 `xvar3'          i`i'.`gvar'#i`j'.__post__#c.(`xxvar')  
						}
						
					}
					else if `j'==2 {

						local xvar `xvar'   c.__tr__#i`i'.`gvar'#i`j'.__post__ 							  
						local xvar2 `xvar2'          i`i'.`gvar'#i`j'.__post__ 
						
						if "`x'`xxvar'"!="" {
							local xvar  `xvar'  c.__tr__#i`i'.`gvar'#i`j'.__post__#c.(`xxvar') 
							local xvar3 `xvar3'          i`i'.`gvar'#i`j'.__post__#c.(`xxvar')  
						}

					}
				}
			}
		}
		
**********************************************************************************************************	
	}
	else if "`ehettype'"=="event" {
**********************************************************************************************************
    local gpevent = -`antigap'
    qui:levelsof __evnt__ if `touse', local(elist)
    if "`never'"=="" qui:levelsof __evnt__ if `touse' & __evnt__>-`gap', local(elist)
 
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
				if "`never'"=="" & (`ccev'>-`antigap') {	
					local xvar `xvar'   c.__tr__#i`i'.__evnt__
					local xvar2 `xvar2'          i`i'.__evnt__						
					if "`x'`xxvar'"!="" {
						local xvar `xvar'   c.__tr__#i`i'.__evnt__#c.(`xxvar') 
						local xvar3 `xvar3'          i`i'.__evnt__#c.(`xxvar')  
					}
				}
				if "`never'"!="" & `ccev'!=(-`antigap') {	
					local xvar `xvar'   c.__tr__#i`i'.__evnt__
					local xvar2 `xvar2'          i`i'.__evnt__						
					if "`x'`xxvar'"!="" {
						local xvar `xvar'   c.__tr__#i`i'.__evnt__#c.(`xxvar') 
						local xvar3 `xvar3'          i`i'.__evnt__#c.(`xxvar')  
					}
				}
			}
		}
		
**********************************************************************************************************	
	}	
    else if "`ehettype'"=="eventcohort" {
**********************************************************************************************************
	qui:levelsof __evnt__, local(elist)
    	foreach i of local glist {
			foreach j of local elist {
				qui:count if `i'==`gvar' & `j'==__evnt__ & `touse'
				if `r(N)'>0 {
					if `j'!=`evbase' {						
						local xvar `xvar'   c.__tr__#i`i'.`gvar'#i`j'.__evnt__ 							  
						local xvar2 `xvar2'          i`i'.`gvar'#i`j'.__evnt__
						
						if "`x'`xxvar'"!="" {
							local xvar `xvar'   c.__tr__#i`i'.`gvar'#i`j'.__evnt__#c.(`xxvar') 
							local xvar3 `xvar3'          i`i'.`gvar'#i`j'.__evnt__#c.(`xxvar')  
							}
					}
					
				}
			}
		}
		
**********************************************************************************************************	
	}	
	else if "`ehettype'"=="twfe" {
		** TWFE, Thus imposing no heterogeneity. One can still estimate Event effects based on covariate heterogeneity
		foreach i in 1 2 {
				if "`never'"!="" {
										
					local xvar `xvar'   c.__tr__#i`i'.__post__
					local xvar2 `xvar2'          i`i'.__post__ 
					
					if "`x'`xxvar'"!="" {
						local xvar `xvar'   c.__tr__#i`i'.__post__#c.(`xxvar') 
						local xvar3 `xvar3'          i`i'.__post__#c.(`xxvar')  
					}
					
				}
				else if `i'==2 {

					local xvar `xvar'   c.__tr__#i`i'.__post__
					local xvar2 `xvar2'          i`i'.__post__
					
					if "`x'`xxvar'"!="" {
						local xvar  `xvar'  c.__tr__#i`i'.__post__#c.(`xxvar') 
						local xvar3 `xvar3'          i`i'.__post__#c.(`xxvar')  
					}

				}			
		}		
	}
	** for xs: Interaction with Glist and Tlist
	
	foreach i of local glist {
		          local ogxvar `ogxvar' i`i'.`gvar'#c.(`xvarvar' `xgvar')
	}
	
	foreach j of local tlist {
		* To avoid Multicolinearity in Simple cases
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
	else if "`method1'"=="tobit" local tocluster vce(cluster `cvar')
	else local tocluster cluster(`cvar')
	
    
    ***
	if "`method'"=="" {
		if "`group'"=="" {
			** ogxvar  will be excluded if they are fixed across time
			if "`tocluster'"=="" local tocluster vce(robust)
			reghdfe `y' `xvar' `ogxvar'  `otxvar' 	`exogvar' ///
				if `touse' [`weight'`exp'], abs(`ivar' `tvar' `fevar') `tocluster' keepsingletons `options'
			local scmd `e(cmdline)'		
		}	
		else {
			if "`ivar'"!="" {
				qui:xtset `ivar' `tvar'
				mata:is_balanced("`ivar' `tvar'","`touse'")
		 
				if "`corr'"!="" {
					** Correction 
					qui:myhdmean `xvar' `x' `ogxvar'  `otxvar' `exogvar'  i.`tvar' if `touse'	[`wgt'`exp'] , prefix(_z_) keepsingletons abs(`ivar')
					local xcorr  `r(vlist)'
				}
			}	
			reghdfe `y' `xvar'  `x'  `ogxvar' `otxvar'   `exogvar' `xcorr' ///
			if `touse' [`weight'`exp'], abs(`gvar'  `tvar' `fevar') `tocluster' keepsingletons noempty `options'
			local scmd `e(cmdline)'
		}
	}
	else if "`method'"=="ppmlhdfe" {
		
		ppmlhdfe `y' `xvar' `ogxvar'  `otxvar'	`exogvar' ///
				if `touse' [`weight'`exp'], abs(`ivar' `tvar' `fevar') `tocluster' keepsingletons ///
				d `method_option' `options'
		local scmd `e(cmdline)'				
	}
	**** Else Two Add CRE option
	else {
        if "`cre'"=="" {        
            if "`ivar'"!="" {
                qui:xtset `ivar' `tvar'
                mata:is_balanced("`ivar' `tvar'","`touse'")	
                if   "`corr'"!=""  {
                        ** Correction 
                        qui:myhdmean `xvar'  `x'  `ogxvar' `otxvar' `xcorr' `exogvar'  i.`tvar' if `touse'	///
                                     [`wgt'`exp'] , prefix(_z_) keepsingletons abs(`ivar')
                        local xcorr  `r(vlist)'				
                } 
            }
            `method'  `y' `xvar'  `x'  `ogxvar' `otxvar' `xcorr' `exogvar'   i.`gvar' i.`tvar' ///
            if `touse' [`weight'`exp'], `tocluster' `method_option' `options'
            local scmd `e(cmdline)'
        }
        else {
            if "`ivar'"!="" local tofe  `ivar'
            else local tofe `gvar'
            qui:cre_jwdid `xvar'  `x'  `ogxvar' `otxvar' `xcorr' `exogvar' i.`tvar' if `touse' [`weight'`exp'], abs(`tofe')
            
            qui: `method'  `y' `xvar'  `x'  `ogxvar' `otxvar' `xcorr' `exogvar' /// Main Variables
                           _cre_* i.`tvar' /// Mundlak terms  + time FE
                           if `touse' [`weight'`exp'], `tocluster' `method_option' `options'
            
            display "Estimation Done" _n ///
                    "{p}If Need to see results type -ereturn display-. They could be very extensive, depending on the model{p_end}" _n ///
                    "Otherwise, type -estat [simple/event]- for aggregates"
            
        }
	}
	
	ereturn local cmd jwdid
	ereturn local cmd2 `method'
	ereturn local cmdopt `method_option'

	ereturn local cmdline jwdid `0'
	ereturn local scmd `scmd'
	ereturn local hettype `ehettype'
	ereturn local estat_cmd jwdid_estat
	if "`never'"!="" ereturn local type  never
	else 			 ereturn local type  notyet

	ereturn local ivar `ivar'
	ereturn local tvar `tvar'
	ereturn local gvar `gvar'
	
	ereturn scalar  gap =  `gap'
	ereturn scalar  anticipation =  `anti'
	ereturn scalar  antigap =  `antigap'
	
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

program cre_jwdid, rclass sortpreserve
    syntax varlist(fv ts) [if] [aw iw pw], abs(varname)
    capture drop _cre_*
    ** Capturing sample
    marksample  touse 
    markout    `touse' `abs'
	sort `touse' `abs' 
    ** expand Varlist
    fvexpand `varlist'
    local mfvlist `r(varlist)'
    ** define weights
    if "`weight'"!="" local weight aw
    local exp = subinstr("`exp'","=","",1)
    if "`exp'"=="" local exp 1
    ** Counts Obs
    count if `touse'
    
    ** Gets Weight
    tempvar vwexp
    by `touse' `abs':gen double `vwexp' =  sum(`exp')
    by `touse' `abs':replace    `vwexp' =  `vwexp'[_N]
    
    tempvar res_mm
    qui:gen double `res_mm'=.
    local cnt 0
    foreach i of local mfvlist {
        
        ** Create
        local cnt = `cnt'+1
        by `touse' `abs':gen double _cre_`cnt'=sum((`i')*`exp') if `touse'
        by `touse' `abs':replace    _cre_`cnt'=_cre_`cnt'[_N]/`vwexp'
        ** check if Any Var
        replace `res_mm' = abs((`i')-_cre_`cnt') if `touse'
        sum `res_mm', meanonly
        if (r(max)-r(min))>epsfloat()  {
            local flist `flist' _cre_`cnt'
            label var _cre_`cnt' "mndlk `i'"
        }
        else drop _cre_`cnt'
    }
    
    ** Final Collinearity Check
    qui: _rmcoll _cre_*
    return list 
    local fflist  `r(varlist)'
    local flist
    
    foreach i of local fflist {
        
        if strpos("`i'","o.")>0 {
            local todr= subinstr("`i'","o.","",1)
            drop `todr'
        }
        else local flist `flist' `i'
    }
    return local varlist `flist'    
    
    
end 
*** Problem.
/*
What to do if DIF(1) c.x does give you a different result from dif() c.dx
So far Cohort works well, because DIFF is based on cohort
We need to figure something similar for the others. Perhaps it would work 
if DIFF depends on the Constrained variable
*/
