*! v1.22 Even more graph options
* v1.21 other Graph options
* v1.2  Compatible with new Group Averages
* v1.1  Problem with TM TP
/*capture program drop  csdid_plot
capture program drop  adds
capture program drop csdid_default
capture program drop csdid_default
capture program drop csdid_plot_event
capture program drop csdid_plot_group
capture program drop isgroup_eq
capture program drop csdid_plot_calendar
capture program drop _matrix_list*/

program csdid_agg_cat, sclass
** levels for agg 
	syntax , [agg(str) ragg(str) eagg(str)]

	if "`agg'"!="" {
		if "`agg'"=="attgt" 		 local agg_cat=1
		else if "`agg'"=="event"     local agg_cat=2
		else if "`agg'"=="calendar"  local agg_cat=3
		else if "`agg'"=="group"     local agg_cat=4
	}
	else if "`ragg'"!="" {
		if "`ragg'"=="attgt" 		 local agg_cat=1
		else if "`ragg'"=="event"    local agg_cat=2
		else if "`ragg'"=="calendar" local agg_cat=3
		else if "`ragg'"=="group"    local agg_cat=4
	}
	else if "`eagg'"!="" {
		if "`eagg'"=="attgt" 		 local agg_cat=1
		else if "`eagg'"=="event"    local agg_cat=2
		else if "`eagg'"=="calendar" local agg_cat=3
		else if "`eagg'"=="group"    local agg_cat=4
	}
	sreturn local agg_cat = `agg_cat'
end

program csdid_plot, rclass
	syntax, [*]
	local cmd `r(cmd)'
	local agg `r(agg)'
	tempname  b V table bb vv
	matrix `b' = r(b)
	matrix `V' = r(V)
	matrix `bb' = r(bb)
	matrix `vv' = r(vv)
	matrix `table' = r(table)
	
	capture noisily csdid_plot_wh, `options'
	return local cmd `cmd'
	return local agg `agg'
	
	return matrix b     =`b'
	return matrix V 	=`V'
	return matrix b     =`bb'
	return matrix vv 	=`vv'
	return matrix table =`table'
	
end 

program csdid_plot_wh
	syntax, [style(passthru) title(passthru) name(passthru) Group(str) ///
							 ytitle(passthru) xtitle(passthru)	///
							 legend(passthru) agg(str) * ]
	tempvar mm 
	tempvar kk
	
	csdid_agg_cat, agg(`agg') ragg(`r(agg)') eagg(`e(agg)')
	
	if `s(agg_cat)'==2 {
		
		if "`e(agg)'"=="event" {
			 qui:csdid
			 local evlist = subinstr("`:colname r(table)'","T","",.)
			 local evlist = subinstr("`evlist'","m","-",.)
			 local evlist = subinstr("`evlist'","p","+",.)
			 matrix `mm'=r(table)'
			 matrix `mm'=`mm'[3...,....]
		}
		else if "`r(agg)'"=="event" {		 
			 local evlist = subinstr("`:colname r(table)'","T","",.)
			 local evlist = subinstr("`evlist'","m","-",.)
			 local evlist = subinstr("`evlist'","p","+",.)
			 matrix `mm'=r(table)'
			 matrix `mm'=`mm'[3...,....]
		}
		tempvar mm1 mm2 mm3 mm4 mm5 mm6
		qui:tsvmat `mm', name(`mm1' `mm2' `mm3' `mm4' `mm5' `mm6')
		qui:gen `kk' =.
 		foreach i of local evlist {
		 	if !inlist("`i'","Pre_avg","Post_avg")  {
				local k = `k'+1
				qui:replace `kk'=`i' in `k'
			} 	
		}
				
		csdid_plot_event `kk'  `mm1'  `mm5' `mm6'	, ///
					  `style' `title' `name'  `ytitle'	`xtitle' `legend'	`options'    
	 
	}
	
	else if `s(agg_cat)'==4 {
		if "`e(agg)'"=="group" {
			 qui:csdid
			 local evlist :colname r(table)
			 matrix `mm'=r(table)'
		}
		else if "`r(agg)'"=="group" {		 
			 local evlist :colname r(table)
			 matrix `mm'=r(table)'
		}
		
		tempvar mm1 mm2 mm3 mm4 mm5 mm6
		qui:tsvmat `mm', name(`mm1' `mm2' `mm3' `mm4' `mm5' `mm6')
		
		qui:gen str `kk' =""
		foreach i of local evlist {
		 	local k = `k'+1
		 	qui:replace `kk'="`i'" in `k'
		}
		tempname k2
		qui:encode `kk', gen(`k2')
		 
		csdid_plot_group `k2'  `mm1'  `mm5' `mm6'	, ///
						 `style' `title' `name'  `ytitle'	`xtitle' `legend'	 `options'  
		 
	}
	
	else if `s(agg_cat)'==3 {
		if "`e(agg)'"=="calendar" {
			 qui:csdid
			 local evlist :colname r(table)
			 matrix `mm'=r(table)'
		}
		else if "`r(agg)'"=="calendar" {		 
			 local evlist :colname r(table)
			 matrix `mm'=r(table)'
		}
		
		tempvar mm1 mm2 mm3 mm4 mm5 mm6
		qui:tsvmat `mm', name(`mm1' `mm2' `mm3' `mm4' `mm5' `mm6')
		
		qui:gen str `kk' =""
		foreach i of local evlist {
		 	local k = `k'+1
		 	qui:replace `kk'="`i'" in `k'
		}
		tempname k2
		qui:encode `kk', gen(`k2')
		 
		
		csdid_plot_calendar `k2'  `mm1'  `mm5' `mm6'	, ///
					`style'  `title' `name'  `ytitle'	`xtitle' `legend' `options'		   
		*drop `mm'? 
	}
	
	else if `s(agg_cat)'==1 {
		* First check all info from e(b)
		if "`e(agg)'"=="attgt" {
			 qui:csdid
			 local evlist : colname e(b)
			 local evqlist: coleq e(b)
			 matrix `mm'=r(table)'
			 matrix roweq `mm'=`evqlist'
			 matrix `mm'=`mm'[1..rowsof(`mm')/2,....]			
		}
		else if "`r(agg)'"=="attgt" {		 
			 local evlist : colname r(b)
			 local evqlist: coleq r(b)
			 matrix `mm'=r(table)'
			 matrix roweq `mm'=`evqlist'
			 matrix `mm'=`mm'[1..rowsof(`mm')/2,....]			
		}
//////////////////////////
		if "`group'"=="" {
			display "Please specify group"
			error 1
		}
		else {
			numlist "`group'"
			isgroup_eq, group(`group') eqlist(`evqlist')
 		}
//////////////////////////
// Break down matrix and create list. 
		tempname nmm
		_matrix_list, group(`group') matrix(`mm')  nmatrix(`nmm')
		local evlist `s(mt0t1)'
		adds local mt0t1
		
		tempvar nmm1 nmm2 nmm3 nmm4 nmm5 nmm6
		qui:tsvmat `nmm', name(`nmm1' `nmm2' `nmm3' `nmm4' `nmm5' `nmm6')
						
		qui:gen `kk' =.
		foreach i of local evlist {
		 	local k = `k'+1
		 	qui:replace `kk'=`i' in `k'
		}
		tempname k2
				*sum `kk'  `nmm'1  `nmm'5 `nmm'6
		csdid_plot_event `kk'  `nmm1'  `nmm5' `nmm6' , ///
					`style'	  `title' `name'  `ytitle'	`xtitle' `legend' `options'		   
		*drop `nmm'? 	
		
	}
end

/***
Idea Get a program that gets this list, and another that IDS the relevant columns.
local evlist1 :colname e(b)
local evlist2 :coleq e(b)

display "`evlist1'"
display "`evlist2'"

local lst "t_1_2 t_2_3 t_3_4 t_4_5 t_5_6 t_6_7 t_7_8 t_8_9 t_9_10 t_9_11 t_9_12 t_9_13 t_9_14 t_9_15"
foreach i of local lst {
	local j: word 2 of `=subinstr(subinstr("`i'","t","",.),"_"," ",.)'
	display "`=`j'-10'"
}
***/

program _matrix_list, sclass
	syntax, group(str) matrix(str) nmatrix(str)
	local eqlist: roweq `matrix'
	tempname mm
	foreach i of local eqlist {
		local k = `k' +1
		if "`i'"=="g`group'" {
			matrix `mm'=nullmat(`mm') \ `matrix'[`k',....]
		}
	}
	local tlist:rowname `mm'
	foreach i in `e(tlev)' {
		*local j1: word 1 of `=subinstr(subinstr("`i'","t","",.),"_"," ",.)'
		*local j2: word 2 of `=subinstr(subinstr("`i'","t","",.),"_"," ",.)'
		local t0t1 `t0t1' `=`i'-`group''
	}
		
	matrix `nmatrix'   = `mm'
	
	sreturn local  mt0t1 `t0t1'
end

program isgroup_eq
	syntax, group(str) eqlist(str)
	local group g`group'
	local flag = 0
	foreach i of local eqlist {
		if "`i'"=="`group'" local flag = 1
	}
	if `flag' == 0 {
		display "group not found"
		error 
	}	
end



program adds, sclass
	sreturn `0'
end

 

program csdid_default, sclass
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

 

program csdid_plot_event 
	syntax varlist,  [style(passthru) title(passthru) name(passthru) ///
								ytitle(passthru) xtitle(passthru)	///
								legend(passthru) * ]
	gettoken t rest:varlist
	gettoken b rest:rest
	gettoken ll rest:rest 
	gettoken uu rest:rest 
		
	** defaults
	if `"`xtitle'"'=="" local xtitle xtitle("Periods to Treatment")
	if `"`ytitle'"'=="" local ytitle ytitle("ATT")
	
	if `"`legend'"'=="" local legend legend(order(1 "Pre-treatment" 3 "Post-treatment"))
	csdid_default , `options' `style'
	
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
		  yline(0 , lp(dash) lcolor(black)) `title' `name'  `dels'
end



program csdid_plot_group
	syntax varlist, [ style(str) title(passthru) name(passthru)	///
								ytitle(passthru) xtitle(passthru) * ]
	gettoken t rest:varlist
	gettoken b rest:rest
	gettoken ll rest:rest 
	gettoken uu rest:rest 
		
	qui:levelsof `t', local(tlev)
	local tlb: value label `t'
	local xlab 0 " "
	foreach i of local tlev {
	    local j = `j'+1
	    local xlab `xlab' `i' "`:label `tlb' `i''"
	}
	
	if `"`xtitle'"'=="" local xtitle xtitle("Groups")
	if `"`ytitle'"'=="" local ytitle ytitle("ATT")
	
	local xlab `xlab' `=`j'+1' " "
	
	csdid_default , `options' `style'
	local gf11  `s(df11)'
	local gf12 `s(df12)'
	
	local style `s(style)'
		local dels  `s(delse)'
	
	two   (`style'  `ll' `uu' `t'  , `gf11' )  ///
		  (scatter  `b'      `t'   , `gf12' ) , ///
		  legend(off) `xtitle'  `ytitle'  ///
		  yline(0 , lp(dash) lcolor(black)) `title' `name' xlabel(`xlab') `dels'
	}
	
end


program csdid_plot_calendar
	syntax varlist, [style(str) title(passthru) name(passthru)	///
								ytitle(passthru) xtitle(passthru) * ]
	gettoken t rest:varlist
	gettoken b rest:rest
	gettoken ll rest:rest 
	gettoken uu rest:rest 
		
	qui:levelsof `t', local(tlev)
	local tlb: value label `t'
	local xlab 0 " "
	foreach i of local tlev {
	    local j = `j'+1
	    local xlab `xlab' `i' "`:label `tlb' `i''"
	}
	
	if `"`xtitle'"'=="" local xtitle xtitle("Periods")
	if `"`ytitle'"'=="" local ytitle ytitle("ATT")
	

	local xlab `xlab' `=`j'+1' " "
	
	csdid_default , `options' `style'
	local gf11  `s(df11)'
	local gf12 `s(df12)'
	
	local style `s(style)'
	local dels  `s(delse)'

	
	two   (`style'  `ll' `uu' `t'  , `gf11' )  ///
		  (scatter  `b'      `t'   , `gf12'  ) , ///
		  legend(off) `xtitle'  `ytitle'  ///
		  yline(0 , lp(dash) lcolor(black)) `title' `name' xlabel(`xlab') `dels'
		  
end



/***
Idea Get a program that gets this list, and another that IDS the relevant columns.
local evlist1 :colname e(b)
local evlist2 :coleq e(b)

display "`evlist1'"
display "`evlist2'"

local lst "t_1_2 t_2_3 t_3_4 t_4_5 t_5_6 t_6_7 t_7_8 t_8_9 t_9_10 t_9_11 t_9_12 t_9_13 t_9_14 t_9_15"
foreach i of local lst {
	local j: word 2 of `=subinstr(subinstr("`i'","t","",.),"_"," ",.)'
	display "`=`j'-10'"
}
***/
