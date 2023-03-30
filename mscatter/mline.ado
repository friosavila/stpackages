** mline
*! v1.2  4/21/2022 by FRA: Works with Stata < 16
*! v1.1  4/11/2022 by FRA
** Scatter with across multiple groups

program byparse, rclass
	syntax [anything], [*]
	if "`anything'"!=""	return local byvlist `anything'
	return local byopt   `options'
end

program easter_egg
display in w "{p}This is a small easter egg! And you are lucky because only 0.1% of people may ever see this!{p_end}"
display in w "{p}I should have come up with this at some point. And hopefully Stata will use this too (officially) {p_end}"
display in w "{p}Granted, using color in papers is tough (most prints are black and white). However, if you are into visualizations, color palettes are your friends {p_end}"
display in w "{p}All right, that is it! {p_end}"
end 

program colorpalette_parser, rclass
	syntax [anything(everything)], [nograph * n(string asis) opacity(passthru)]
	return local clp   = `"`anything', `options'"'
	return local clpop = `"`anything', `options' `opacity'"'
end

program mline
	* If nothing is done, all goes to 0
	*syntax  anything(everything), [*] 
	if runiform()<0.001 {
		easter_egg
	}
	mscatterx `0'
end


 
	
program mscatterx 
 	syntax varlist(max=2)   [if] [in] [aw/], [over(varname)] [ alegend legend(string asis) color(string asis) colorpalette(string asis) by(string asis) ///
										connect(passthru) cmissing(passthru) ///
										lpattern(passthru) lwidth(passthru) lcolor(passthru) strict ///
										lalign(passthru) lstyle(passthru)  sort(passthru) * ]
	** First Parse
	tempvar touse
	qui:gen byte `touse'=0
	qui:replace `touse'=1 `if' `in'
	** over?
	if "`over'"=="" {
		tempvar over
		qui:gen byte `over'=1
	}
	tempname new
	** Check color 
	capture confirm var `color'
	if _rc==0 	local myvlist `color'
	** check by
	byparse `by'
	***	
	local byvlist `r(byvlist)'
	local byopts  `r(byopt)'
	*display "`myvlist' `varlist' `byvlist' `over' `exp'"

	** markout only works with numeric	
	markout `touse' `varlist' `byvlist' `over' `exp', strok
	
	local myvlist `myvlist' `varlist' `byvlist' `over' `exp'
	
	** Put into Frame
	if `c(stata_version)'>=16 {
		frame put `myvlist' if `touse', into(`new')
		frame `new':mscatter_do `0'
	}
	else {
		preserve
			qui:keep if `touse'
			keep `myvlist' 
			mscatter_do `0'
		restore
	}
	
	
end 


program mscatter_do 
 	syntax varlist(max=2)   [if] [in] [aw/], [over(varname)] [ alegend legend(string asis) color(string asis) colorpalette(string asis) by(string asis) ///
										connect(passthru) cmissing(passthru) ///
										lpattern(passthru) lwidth(passthru) lcolor(passthru) strict ///
										lalign(passthru) lstyle(passthru)  SORT SORT1(passthru) * ]
	** First Parse
	tempvar touse
	qui:gen byte `touse'=0
	qui:replace `touse'=1 `if' `in'
	** over?
	if "`over'"=="" {
		tempvar over
		qui:gen byte `over'=1
	}
	tempname new
	** Check color 
	capture confirm var `color'
	if _rc==0 	local myvlist `color'
	** check by
	byparse `by'
	***	
	local byvlist `r(byvlist)'
	local byopts  `r(byopt)'
	*display "`myvlist' `varlist' `byvlist' `over' `exp'"

	** markout only works with numeric	
 
	
	local myvlist `myvlist' `varlist' `byvlist' `over' `exp'
	
	** Put into Frame
 	qui {
		**Check Weight 
		capture confirm numeric var `over'
			if _rc!=0 {
				tempvar nover
				encode `over', gen(`nover')
				local over `nover'
			}
	
		if "`exp'"!="" local wexp [aw=`exp']
		
		** Check over to be numeric.

		** sort so 1 per over
		
 		tempvar flag
		bysort `over':gen __flag=_n
		 
		sort __flag `over'
		qui:levelsof `over' , local(lvlby)
		
		** Which color options:
		if `"`color'"'!="" {
			capture confirm var `color'
			if _rc==0 local col_op = 1   // <--- provides colors by variable
			else      local col_op = 2   // <--- provides colors by color list
		}
		else {
			if "`colorpalette'"!="" local col_op = 3   // <-- Uses Color palette
			else                    local col_op = 4   // <-- Uses default "system" colors
		}
		
		if `col_op'==3 {
			local cnt: word count `lvlby'
			colorpalette_parser `colorpalette'
			colorpalette `r(clp)' nograph n(`cnt')
			local cpcolor  `"`r(p)'"'
		}
		
		local cnt
		foreach i of local lvlby {
			local cnt = `cnt' +1 	
			
			if `col_op'==1 local mycolor `=`color'[`cnt']'
			if `col_op'==2 local mycolor:word `cnt' of `color'
			if `col_op'==3 local mycolor:word `cnt' of `cpcolor'
			if `col_op'==4 local mycolor
			
			local pscatter `pscatter' ///
					(line `varlist' if `over'==`i', ///
					color( "`mycolor'" ) ///
					`connect' `cmissing' `lpattern' `lwidth' `lcolor' ///
					`lalign' `lstyle'   `sort')
		}
 
			
		 ** Then just Scatter, but...One more component, legend. Default Legend off
		 if "`alegend'"=="" & `"`legend'"' == ""   local mylegend legend(off)
		 if "`alegend'"=="" & `"`legend'"' != ""   local mylegend legend(`legend')
		 if "`alegend'"!="" {
		 	local cn 
		 	foreach i of local lvlby {
					local cn = `cn'+1
					local slg: label (`over') `i', `strict'
					local mylegend `mylegend' `cn' "`slg'"
				}
			local mylegend legend(order(`mylegend') `legend')	
		 }
		** the figure 
		
		two `pscatter', `options' by(`by') `mylegend'
	}
end 

