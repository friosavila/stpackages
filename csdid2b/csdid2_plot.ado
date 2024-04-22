*! v1.1 csdid2_plot Better names when Date has formats
* v1.03 csdid2_plot Allows for Anticpiation
*  v1.02 csdid2_plot Fixes `'
*  v1.01 csdid2_plot for csdid2 only
 
program csdid2_plot, rclass

	syntax, [* ktype(string)]
	local cmd `r(cmd)'
	local agg `r(agg)'
	tempname  b V table bb vv
	matrix `b' = r(b)
	matrix `V' = r(V)
	matrix `table' = r(table)
	
	if "`agg'"=="group"    local ktype = 3
	if "`agg'"=="calendar" local ktype = 4
	if "`agg'"=="event"    local ktype = 5 
	
	
	capture noisily csdid2_plot_wh, `options' ktype(`ktype') table(`table')
	return local cmd `cmd'
	return local agg `agg'
	
	return matrix b     =`b'
	return matrix V 	=`V'
	return matrix table =`table'

end

program csdid2_plot_wh
	syntax, [  * ktype(int 5) table(str) asy level(int 95)] 	
	
	tempname tbl
	matrix `tbl'=`table'
	capture: confirm matrix `tbl'
	
	*if det(`tbl')==. matrix `tbl'=rtb
	if "`asy'"=="" {
		if `ktype'==5 {
			tempvar t b ll uu
			
			mata:event_p("`t' `b' `ll' `uu'","`tbl'")
			
			csdid_plot_eventx 	`t' `b' `ll' `uu',  `options'		
		}
		else if `ktype'==3 | `ktype'==4 {
			// Group Calendar
			tempvar t b ll uu
			mata:other_p("`t' `b' `ll' `uu'","`tbl'")
			
			csdid_plot_other `t' `b' `ll' `uu',   `options' ktype(`ktype')		
		}
		else {
			display in red "Plot option not allowed"
		}
	}
	else {
		if `ktype'==5 {
			tempvar t b ll uu se all auu
			
			mata:event_p2("`t' `b' `ll' `uu' `se' `all' `auu'","`tbl'", `=`level'/100')
			csdid_plot_eventx 	`t' `b' `ll' `uu' `all' `auu',  `options'	asy	
		}
		else if `ktype'==3 | `ktype'==4 {
			// Group Calendar
			tempvar t b ll uu se all auu
			mata:other_p2("`t' `b' `ll' `uu' `se' `all' `auu'","`tbl'", `=`level'/100')
			csdid_plot_other `t' `b' `ll' `uu' `all' `auu',   `options' ktype(`ktype')	asy	
		}
		else {
			display in red "Plot option not allowed"
		}
	}

end

mata:
 	void event_p2( string scalar newvars, string scalar tblx, real scalar level){
	    real   matrix tbl, ntbl2
		string matrix ntbl
		real scalar alpha
	    tbl = st_matrix(tblx)	
		//asume always here
 
		alpha = 1-level
		ntbl = st_matrixcolstripe(tblx)
		ntbl = usubinstr(ntbl,"tp","+",.)
		ntbl = usubinstr(ntbl,"tm","-",.)	
		ntbl2= strtoreal(ntbl)	
		tbl  = tbl[(1,5,6,2),]'	
		tbl  = tbl,tbl[,1]-tbl[,4]*invnormal(1-alpha/2),tbl[,1]+tbl[,4]*invnormal(1-alpha/2)
		 
		tbl  = select(tbl,(ntbl2[,2]:!=.))		
		ntbl2= select(ntbl2[,2],(ntbl2[,2]:!=.))
        real matrix ss
 		ss= _st_addvar("double",tokens(newvars))
 		st_store((1::rows(tbl)) ,tokens(newvars),(ntbl2,tbl))	
	}
 
	void other_p2(string scalar newvars, string scalar tblx, real scalar level){
	    real   matrix tbl
		string matrix ntbl
		real scalar alpha
		alpha = 1-level
	    tbl  = st_matrix(tblx)		
		ntbl = st_matrixcolstripe(tblx)
		//ntbl = usubinstr(ntbl,"g","",.)
		//ntbl = usubinstr(ntbl,"t","",.)
		ntbl = ntbl [,2]
		tbl  = tbl[(1,5,6,2),]'	
		tbl  = tbl,tbl[,1]-tbl[,4]*invnormal(1-alpha/2),tbl[,1]+tbl[,4]*invnormal(1-alpha/2)

		string matrix tnv
		tnv = tokens(newvars)
		real matrix ss
		ss= _st_addvar(sprintf("str%f",max(strlen(ntbl))),tnv[1])
		ss= _st_addvar("double",tnv[2..7])

		st_sstore((1::rows(tbl)) ,tnv[1],ntbl)	
		st_store((1::rows(tbl)) ,tnv[2..7],tbl)	
	}
end

program csdid2_default, sclass
	syntax, [style(str) PSTYle1(str) color1(str) ///
						PSTYLE2(str) color2(str) ///
						LWidth1(str) lwidth2(str) ///
						BARWidth1(str) barwidth2(str) * asy]  
	
 	if "`style'"=="" local style rspike
	
	
	if "`pstyle1'"=="" local pstyle1 pstyle(p1)
	else  local pstyle1 pstyle(`pstyle1')             
	if "`pstyle2'"=="" local pstyle2 pstyle(p2)
	else  local pstyle2 pstyle(`pstyle2') 
	
	if `"`color1'"'=="" local color1 color(%40)
	else local color1 color(`"`color1'"')
	if `"`color2'"'=="" local color2 color(%40)
	else local color2 color(`"`color2'"')
	
	if "`style'"=="rspike" {
		if "`lwidth1'"=="" local lwidth1 lwidth(3)
		else local lwidth1 lwidth(`lwidth1')		
		if "`lwidth2'"=="" local lwidth2 lwidth(3)
		else local lwidth2 lwidth(`lwidth2')
		if "`asy'"!="" {
			local lwidth1 lwidth(1)		
			local lwidth2 lwidth(1)		
		}
	}
	
	if "`style'"=="rarea" {
		if "`lwidth1'"=="" local lwidth1 lwidth(0)
		else local lwidth1 lwidth(`lwidth1')						
		if "`lwidth2'"=="" local lwidth2 lwidth(0) 
		else local lwidth2 lwidth(`lwidth2')		
		local conn connect(l)
	}
	
	if "`style'"=="rcap" {
		if "`lwidth1'"=="" local lwidth1 lwidth(1)	
		else local lwidth1 lwidth(`lwidth1')		
		if "`lwidth2'"=="" local lwidth2 lwidth(1) 
		else local lwidth2 lwidth(`lwidth2')		

		local conn connect(l)
	}
		
	if "`style'"=="rbar" {
		if "`lwidth1'"=="" local lwidth1 lwidth(0)		
		else local lwidth1 lwidth(`lwidth1')		
		if "`lwidth2'"=="" local lwidth2 lwidth(0) 
		else local lwidth2 lwidth(`lwidth2')		
		if "`barwidth1'"=="" local barwidth1 barwidth(0.5)		
		else local barwidth1 barwidth(`barwidth1')		
		if "`barwidth2'"=="" local barwidth2 barwidth(0.5)
		else local barwidth2 barwidth(`barwidth2')		
		local conn connect(l)
	}
	 
	
	sreturn local style `style' 
	sreturn local df11  `pstyle1'  `color1' `lwidth1' `barwidth1' 
	sreturn local df12  `pstyle1'  `conn'
	sreturn local df21  `pstyle2'  `color2' `lwidth2' `barwidth2'
	sreturn local df22  `pstyle2'  `conn'					  
	sreturn local delse `options'
end

program csdid_plot_eventx 
	syntax varlist,  [ 			 xtitle(passthru)     ytitle(passthru) ///
								 legend(passthru) asy * ]
	gettoken t rest:varlist
	gettoken b rest:rest
	gettoken ll rest:rest 
	gettoken uu rest:rest 
	
 
	** defaults
	
	if `"`xtitle'"'=="" local xtitle xtitle("Periods to Treatment")
	if `"`ytitle'"'=="" local ytitle ytitle("ATT")
	
	if `"`legend'"'=="" local legend legend(order(1 "Pre-treatment" 3 "Post-treatment"))
	csdid2_default , `options'  `asy'
	 
	local gf11  `s(df11)'
	local gf12 `s(df12)'
	local gf21 `s(df21)'
	local gf22 `s(df22)'
	local style `s(style)'
	local dels  `s(delse)'
	
	mata:st_local("adj",strofreal(csdid.antici))
	if "`asy'"=="" {
   	two   (`style'  `ll' `uu' `t'  if `t'<=(-1- `adj'), `gf11') ///
		  (scatter  `b'      `t'   if `t'<=(-1- `adj'), `gf12')  ///
		  (`style'  `ll' `uu' `t'  if `t'> (-1- `adj'), `gf21')  ///
		  (scatter  `b'      `t'   if `t'> (-1- `adj'), `gf22') , ///
		   `legend'  `xtitle' `ytitle' ///
		  yline(0 , lp(dash) lcolor(black))   `dels'
	}
	else {
			//gettoken se rest:rest 
			gettoken all rest:rest 
			gettoken auu rest:rest
			
		   	two   (`style'  `ll'  `uu'  `t'  if `t'<=(-1- `adj'), `gf11') ///
				  (scatter  `b'         `t'  if `t'<=(-1- `adj'), `gf12')  ///
				  (`style'  `ll'  `uu'  `t'  if `t'> (-1- `adj'), `gf21')  ///
				  (scatter  `b'        `t'   if `t'> (-1- `adj'), `gf22') ///
				  (`style'  `all' `auu' `t'  if `t'<=(-1- `adj'), `gf11' lwidth(3))  ///
				  (`style'  `all' `auu' `t'  if `t'> (-1- `adj'), `gf21' lwidth(3)),  /// 
				   `legend'  `xtitle' `ytitle' ///
					yline(0 , lp(dash) lcolor(black))   `dels'	
			
	}
end

 
program csdid_plot_other
	syntax varlist,  [ktype(int 3) * ///
	                  xtitle(passthru) ytitle(passthru) ///
						asy		 legend(passthru) format(passthru)]
    gettoken t rest:varlist
	gettoken b rest:rest
	gettoken ll rest:rest 
	gettoken uu rest:rest 
	
		
	local xlab `xlab' `=`j'+1' " "
	
	csdid2_default , `options'  
	local gf11  `s(df11)'
	local gf12 `s(df12)'
	local style `s(style)'
	local dels  `s(delse)'

	     if `"`xtitle'"'=="" & `ktype' ==3 local xtitle xtitle("Group")
	else if `"`xtitle'"'=="" & `ktype' ==4 local xtitle xtitle("Calendar")
	if `"`ytitle'"'=="" local ytitle ytitle("ATT")
	
	mata:st_local("adj",strofreal(csdid.antici))

	tempvar t2 
 	qui:myencode `t', gen(`t2') `format'
	if "`asy'"=="" {
		two   (`style'  `ll' `uu' `t2'  , `gf11' )  ///
			  (scatter  `b'      `t2'   , `gf12' ) , ///
			  legend(off) `xtitle'  `ytitle'  ///
			  yline(0 , lp(dash) lcolor(black)) `title' ///
			  xlab(   ,val) `name'   `dels' 
	}
	else {
			//gettoken se rest:rest 
			gettoken all rest:rest 
			gettoken auu rest:rest
			 
		two   (`style'  `ll' `uu' `t2'  ,  `gf11' lwidth(1))  ///
			  (`style'  `all' `auu' `t2'  ,  `gf11'  )  ///
				(scatter  `b'      `t2'   , `gf12' ) , ///
				legend(off) `xtitle'  `ytitle'  ///
				yline(0 , lp(dash) lcolor(black)) `title' ///
				xlab(   ,val) `name'   `dels' 	
	}
 
	
end

*program drop myencode
program define myencode
	syntax varname, gen(name) [format(string asis)]	
	if "`=`varlist''"=="GAverage" {
		local torep "GAverage"
		*replace `varlist' = `varlist'[2]-(`varlist'[3]-`varlist'[2])
	}
	if "`=`varlist''"=="TAverage" {
		local torep "TAverage"
		*replace `varlist' = `varlist'[2]-(`varlist'[3]-`varlist'[2])
	}
	
	if "`torep'"!=""  {
		replace `varlist'=subinstr(`varlist',"g","",1) if _n>1
		replace `varlist'=subinstr(`varlist',"t","",1) if _n>1
	}
	else {
	    replace `varlist'=subinstr(`varlist',"g","",1)  
		replace `varlist'=subinstr(`varlist',"t","",1)  
	}
	qui:destring `varlist', force gen(`gen') 
	if "`torep'"!=""  {
 		replace `gen' = `gen'[2]-(`gen'[3]-`gen'[2]) in 1
		tempname aux
		label define _aux_ `=`gen'[1]' "`torep'", modify
		label values `gen' _aux_
	}
qui format `format' `gen'
end


