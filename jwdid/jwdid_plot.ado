*!v1.2 Bugs with Lwidth
*v1.1 Plot for SIMPLE OVER
* v1 Clone for jwdid:
/*capture program drop  csdid_plot
capture program drop  adds
capture program drop jwdid_default
capture program drop jwdid_default
capture program drop csdid_plot_event
capture program drop csdid_plot_group
capture program drop isgroup_eq
capture program drop csdid_plot_calendar
capture program drop _matrix_list*/

program jwdid_agg_cat, sclass
** levels for agg 
	syntax , [agg(str) ragg(str) eagg(str)]

	if "`agg'"!="" {
		if "`agg'"=="attgt" 		 local agg_cat=1
		else if "`agg'"=="event"     local agg_cat=2
		else if "`agg'"=="calendar"  local agg_cat=3
		else if "`agg'"=="group"     local agg_cat=4
		else if "`agg'"=="simple"     local agg_cat=5
	}
	else if "`ragg'"!="" {
		if "`ragg'"=="attgt" 		 local agg_cat=1
		else if "`ragg'"=="event"    local agg_cat=2
		else if "`ragg'"=="calendar" local agg_cat=3
		else if "`ragg'"=="group"    local agg_cat=4
		else if "`ragg'"=="simple"   local agg_cat=5
	}
	else if "`eagg'"!="" {
		if "`eagg'"=="attgt" 		 local agg_cat=1
		else if "`eagg'"=="event"    local agg_cat=2
		else if "`eagg'"=="calendar" local agg_cat=3
		else if "`eagg'"=="group"    local agg_cat=4
		else if "`eagg'"=="simple"   local agg_cat=5
	}
	sreturn local agg_cat = `agg_cat'
end

program jwdid_plot, rclass
	syntax, [*]
	local cmd `r(cmd)'
	local agg `r(agg)'
	tempname  b V table
	if "`e(agg)'"!="" qui:ereturn display
	matrix `b' = r(b)
	matrix `V' = r(V)
	matrix `table' = r(table)
	capture noisily jwdid_plot_wh, `options'
	return local cmd `cmd'
	return local agg `agg'
	
	return matrix b     =`b'
	return matrix V 	=`V'
	return matrix table =`table'
end 

program jwdid_plot_wh
	syntax, [style(passthru) title(passthru) name(passthru) Group(str) ///
							 ytitle(passthru) xtitle(passthru)	///
							 legend(passthru) agg(str) * ]
	tempvar mm  b
	tempvar kk
	
	jwdid_agg_cat, agg(`agg') ragg(`r(agg)') eagg(`e(agg)')
	
	if `s(agg_cat)'==2 {
		
		matrix `b'=r(table)
		
		local coln:colname `b'
 
		local coln= subinstr("`coln'","r2vs1._at@","",.)
		local coln= subinstr("`coln'","bn","",.)
		local coln= subinstr("`coln'",".__event__","",.)
 			 
		matrix `mm'=r(table)'
 
		foreach i of local coln {
			local ll:label (__event__) `i'
			local lcoln `lcoln' `ll'
		}
		tempvar mm1 mm2 mm3 mm4 mm5 mm6
		qui:tsvmat `mm', name(`mm1' `mm2' `mm3' `mm4' `mm5' `mm6')
		qui:gen `kk' =.
				
 		foreach i of local lcoln {
		 	    local k = `k'+1
			qui:replace `kk'=`i' in `k'
		}
	
		jwdid_plot_event `kk'  `mm1'  `mm5' `mm6'	, ///
					`style' `title' `name'  `ytitle'	`xtitle' `legend'	`options'    
	}
	
	else if `s(agg_cat)'==4 {
		* if "`e(agg)'"=="group" {
		matrix `b'=r(table)
		
		local coln:colname `b'
 
		local coln= subinstr("`coln'","r2vs1._at@","",.)
		local coln= subinstr("`coln'","bn","",.)
		local coln= subinstr("`coln'",".__group__","",.)
 		
		matrix `mm'=r(table)'
		 
		tempvar mm1 mm2 mm3 mm4 mm5 mm6
		qui:tsvmat `mm', name(`mm1' `mm2' `mm3' `mm4' `mm5' `mm6')
		
		qui:gen str `kk' =""
		foreach i of local coln {
		 	local k = `k'+1
		 	qui:replace `kk'="`i'" in `k'
		}
		tempname k2
		qui:destring `kk', gen(`k2')
		 
		jwdid_plot_group `k2'  `mm1'  `mm5' `mm6'	, ///
					`style' `title' `name'  `ytitle'	`xtitle' `legend'	 `options'  
		*drop `mm'? 
	}
	
	else if `s(agg_cat)'==3 {
		*if "`e(agg)'"=="calendar"  
		
		matrix `b'=r(table)
		
		local coln:colname `b'
 
		local coln= subinstr("`coln'","r2vs1._at@","",.)
		local coln= subinstr("`coln'","bn","",.)
		local coln= subinstr("`coln'",".__calendar__","",.)
 		
		matrix `mm'=r(table)'
		
		tempvar mm1 mm2 mm3 mm4 mm5 mm6
		qui:tsvmat `mm', name(`mm1' `mm2' `mm3' `mm4' `mm5' `mm6')
		
		qui:gen str `kk' =""
		foreach i of local coln {
		 	local k = `k'+1
		 	qui:replace `kk'="`i'" in `k'
		}
		tempname k2
		qui:destring `kk', gen(`k2')
		 
		jwdid_plot_calendar `k2'  `mm1'  `mm5' `mm6'	, ///
					`style'	  `title' `name'  `ytitle'	`xtitle' `legend' `options'		   
		*drop `mm'? 
	}
	
	else if `s(agg_cat)'==5 {
		*if "`e(agg)'"=="Simple"  
		
		matrix `b'=r(table)		
		local coln:colname `b'
 
		matrix `mm'=r(table)'
		
		tempvar mm1 mm2 mm3 mm4 mm5 mm6
		qui:tsvmat `mm', name(`mm1' `mm2' `mm3' `mm4' `mm5' `mm6')
		
		qui:gen str `kk' =""
		foreach i of local coln {
		 	local k = `k'+1
		 	qui:replace `kk'="`i'" in `k'
		}
		tempname k2
		qui:encode `kk', gen(`k2')
		 
		jwdid_plot_simple `k2'  `mm1'  `mm5' `mm6'	, ///
					`style'	  `title' `name'  `ytitle'	`xtitle' `legend' `options'		   
		*drop `mm'? 
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

 

program jwdid_default, sclass
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
		else               local lwidth1 lwidth(`lwidth1') 
		if "`lwidth2'"=="" local lwidth2 lwidth(3)
        else               local lwidth2 lwidth(`lwidth2') 
	}
	
	if "`style'"=="rarea" {
		if "`lwidth1'"=="" local lwidth1 lwidth(0)		
   		else               local lwidth1 lwidth(`lwidth1') 

		if "`lwidth2'"=="" local lwidth2 lwidth(0) 
		else               local lwidth2 lwidth(`lwidth2') 
        
		local conn connect(l)
	}
	
	if "`style'"=="rcap" {
		if "`lwidth1'"=="" local lwidth1 lwidth(1)		
		else               local lwidth1 lwidth(`lwidth1') 
        
		if "`lwidth2'"=="" local lwidth2 lwidth(1) 
		else               local lwidth2 lwidth(`lwidth2') 
        
		local conn connect(l)
	}
		
	if "`style'"=="rbar" {
		if "`lwidth1'"=="" local lwidth1 lwidth(0)		
   		else               local lwidth1 lwidth(`lwidth1') 

		if "`lwidth2'"=="" local lwidth2 lwidth(0) 
		else               local lwidth2 lwidth(`lwidth2') 
        
		if "`barwidth1'"=="" local barwidth1 barwidth(0.5)		
        els                  local barwidth1 barwidth(`barwidth1')	
		if "`barwidth2'"=="" local barwidth2 barwidth(0.5)
        els                  local barwidth2 barwidth(`barwidth2')	
		local conn connect(l)
	}
	 
	
	sreturn local style `style' 
	sreturn local df11  `pstyle1'  `color1'  `lwidth1'  `barwidth1' 
	sreturn local df12  `pstyle1'  `conn'
	sreturn local df21  `pstyle2' `color2' `lwidth2' `barwidth2'
	sreturn local df22  `pstyle2'  `conn'					  
	sreturn local delse `options'
end

 program define tsvmat
        syntax anything, name(string)
        version 7
		 
        local nx = rowsof(matrix(`anything'))
        local nc = colsof(matrix(`anything'))
        ***************************************
        // here is where the safegards will be done.
        if _N<`nx' {
            display as result "Expanding observations to `nx'"
                set obs `nx'
        }
        // here we create all variables
        foreach i in `name' {
			local j = `j'+1
			qui:gen `type' `i'=matrix(`anything'[_n,`j'])			
        }
        // here is where they are renamed.

end


program jwdid_plot_event 
	syntax varlist, [style(passthru) title(passthru) name(passthru) ///
					ytitle(passthru) * xtitle(passthru)	///
					legend(passthru)  ]
	gettoken t rest:varlist
	gettoken b rest:rest
	gettoken ll rest:rest 
	gettoken uu rest:rest 
	
	** defaults
	if `"`xtitle'"'=="" local xtitle xtitle("Periods to Treatment")
	if `"`ytitle'"'=="" local ytitle ytitle("ATT")
	
	if `"`legend'"'=="" local legend legend(order(1 "Pre-treatment" 3 "Post-treatment"))
	jwdid_default , `options' `style'

	local antigap (`e(antigap)')
	
	local gf11  `s(df11)'
	local gf12 `s(df12)'
	local gf21 `s(df21)'
	local gf22 `s(df22)'
	local style `s(style)'
	local dels  `s(delse)'
 	two   (`style'  `ll' `uu' `t'  if `t'<=-`antigap' , `gf11') ///
		  (scatter  `b'      `t'   if `t'<=-`antigap' , `gf12')  ///
		  (`style'  `ll' `uu' `t'  if `t'>-`antigap', `gf21')  ///
		  (scatter  `b'      `t'   if `t'>-`antigap', `gf22') , ///
		   `legend'  `xtitle' `ytitle' ///
		  yline(0 , lp(dash) lcolor(black)) `title' `name'  `dels'
 
end



program jwdid_plot_group
	syntax varlist, [title(passthru) name(passthru)	///
								ytitle(passthru) xtitle(passthru) * ]
	gettoken t rest:varlist
	gettoken b rest:rest
	gettoken ll rest:rest 
	gettoken uu rest:rest 
		
	/*qui:levelsof `t', local(tlev)
	local tlb: value label `t'
	local xlab 0 " "
	foreach i of local tlev {
	    local j = `j'+1
	    local xlab `xlab' `i' "`:label `tlb' `i''"
	}*/
	
	if `"`xtitle'"'=="" local xtitle xtitle("Groups")
	if `"`ytitle'"'=="" local ytitle ytitle("ATT")
	
	*local xlab `xlab' `=`j'+1' " "
	
	jwdid_default , `options' `style'
	local gf11  `s(df11)'
	local gf12 `s(df12)'
	
	local style `s(style)'
		local dels  `s(delse)'
	
	two   (`style'  `ll' `uu' `t'  , `gf11' )  ///
		  (scatter  `b'      `t'   , `gf12' ) , ///
		  legend(off) `xtitle'  `ytitle'  ///
		  yline(0 , lp(dash) lcolor(black)) `title' `name' xlabel(`xlab') `dels'
	
end


program jwdid_plot_calendar
	syntax varlist, [title(passthru) name(passthru)	///
								ytitle(passthru) xtitle(passthru) * ]
	gettoken t rest:varlist
	gettoken b rest:rest
	gettoken ll rest:rest 
	gettoken uu rest:rest 
		
	/*qui:levelsof `t', local(tlev)
	local tlb: value label `t'
	local xlab 0 " "
	foreach i of local tlev {
	    local j = `j'+1
	    local xlab `xlab' `i' "`:label `tlb' `i''"
	}*/
	
	if `"`xtitle'"'=="" local xtitle xtitle("Periods")
	if `"`ytitle'"'=="" local ytitle ytitle("ATT")
	

	*local xlab `xlab' `=`j'+1' " "
	
	jwdid_default , `options' `style'
	local gf11  `s(df11)'
	local gf12 `s(df12)'
	
	local style `s(style)'
	local dels  `s(delse)'

	
	two   (`style'  `ll' `uu' `t'  , `gf11' )  ///
		  (scatter  `b'      `t'   , `gf12'  ) , ///
		  legend(off) `xtitle'  `ytitle'  ///
		  yline(0 , lp(dash) lcolor(black)) `title' `name' xlabel(`xlab') `dels'
end


program jwdid_plot_simple
	syntax varlist, [title(passthru) name(passthru)	///
						*		ytitle(passthru) xtitle(passthru) * ]
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
	
	if `"`xtitle'"'=="" local xtitle xtitle("Over Groups")
	if `"`ytitle'"'=="" local ytitle ytitle("ATT")
	

	local xlab `xlab' `=`j'+1' " "
	
	jwdid_default , `options' `style'
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
