*! v1.01 csdid2_plot for csdid2 only
 
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
	syntax, [  * ktype(int 5) table(str)] 	
	
	tempname tbl
	matrix `tbl'=`table'
	capture: confirm matrix `tbl'
	
	*if det(`tbl')==. matrix `tbl'=rtb
	
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
end

program csdid2_default, sclass
	syntax, [style(str) PSTYle1(str) color1(str) ///
						PSTYLE2(str) color2(str) ///
						LWidth1(str) lwidth2(str) ///
						BARWidth1(str) barwidth2(str) * ]  
	
 	if "`style'"=="" local style rspike
	
	
	if "`pstyle1'"=="" local pstyle1 pstyle(p1)
	else  local pstyle1 pstyle(`pstyle1')             
	if "`pstyle2'"=="" local pstyle2 pstyle(p2)
	else  local pstyle2 pstyle(`pstyle2') 
	
	if "`color1'"=="" local color1 color(%40)
	else local color1 color(`"`color1'"')
	if "`color2'"=="" local color2 color(%40)
	else local color2 color(`"`color2'"')
	
	if "`style'"=="rspike" {
		if "`lwidth1'"=="" local lwidth1 lwidth(3)		
		if "`lwidth2'"=="" local lwidth2 lwidth(3)
	}
	
	if "`style'"=="rarea" {
		if "`lwidth1'"=="" local lwidth1 lwidth(0)		
		if "`lwidth2'"=="" local lwidth2 lwidth(0) 
		local conn connect(l)
	}
	
	if "`style'"=="rcap" {
		if "`lwidth1'"=="" local lwidth1 lwidth(1)		
		if "`lwidth2'"=="" local lwidth2 lwidth(1) 
		local conn connect(l)
	}
		
	if "`style'"=="rbar" {
		if "`lwidth1'"=="" local lwidth1 lwidth(0)		
		if "`lwidth2'"=="" local lwidth2 lwidth(0) 
		if "`barwidth1'"=="" local barwidth1 barwidth(0.5)		
		if "`barwidth2'"=="" local barwidth2 barwidth(0.5)
		local conn connect(l)
	}
	 
	
	sreturn local style `style' 
	sreturn local df11  `pstyle1'  `color1'  `lwidth1'  `barwidth1' 
	sreturn local df12  `pstyle1'  `conn'
	sreturn local df21  `pstyle2' `color2' `lwidth2' `barwidth2'
	sreturn local df22  `pstyle2'  `conn'					  
	sreturn local delse `options'
end

program csdid_plot_eventx 
	syntax varlist,  [ 			 xtitle(passthru)     ytitle(passthru) ///
								 legend(passthru)  * ]
	gettoken t rest:varlist
	gettoken b rest:rest
	gettoken ll rest:rest 
	gettoken uu rest:rest 
	** defaults
	
	** defaults
	if `"`xtitle'"'=="" local xtitle xtitle("Periods to Treatment")
	if `"`ytitle'"'=="" local ytitle ytitle("ATT")
	
	if `"`legend'"'=="" local legend legend(order(1 "Pre-treatment" 3 "Post-treatment"))
	csdid2_default , `options'  
	
	local gf11  `s(df11)'
	local gf12 `s(df12)'
	local gf21 `s(df21)'
	local gf22 `s(df22)'
	local style `s(style)'
	local dels  `s(delse)'
	
	
 	
  	two   (`style'  `ll' `uu' `t'  if `t'<=-1 , `gf11') ///
		  (scatter  `b'      `t'   if `t'<=-1 , `gf12')  ///
		  (`style'  `ll' `uu' `t'  if `t'>-1, `gf21')  ///
		  (scatter  `b'      `t'   if `t'>-1, `gf22') , ///
		   `legend'  `xtitle' `ytitle' ///
		  yline(0 , lp(dash) lcolor(black))   `dels'
 
end

program csdid_plot_other
	syntax varlist,  [ktype(int 3) * ///
	                  xtitle(passthru) ytitle(passthru) ///
								 legend(passthru)]
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
	
	tempvar t2
	qui:encode `t', gen(`t2')

	two   (`style'  `ll' `uu' `t2'  , `gf11' )  ///
		  (scatter  `b'      `t2'   , `gf12' ) , ///
		  legend(off) `xtitle'  `ytitle'  ///
		  yline(0 , lp(dash) lcolor(black)) `title' ///
		  xlab(   ,val) `name'   `dels' 
		  
 
	
end

