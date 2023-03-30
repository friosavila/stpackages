*! v1.4 works with Stata 10 or above?
* v1.3 Fixes gap0
* v1.2 Fixes rangeasis. No longer needed
* v1.1 Wages by Race. Fixes kden
* v1 Wages by Race
*capture program drop joy_plot
*capture program drop _rangevar

program _rangevar, sortpreserve rclass
	syntax varlist, [radj(real 0.0) nobs(real 0.0) rvar(string) offset(real 0.0)   range(numlist)]
	
		if "`rangeasis'"=="" {
			** S1: Readjust range
			sum `varlist', meanonly
			local vmin  = r(min)-(r(max)-r(min))*`radj'
			local vmin2 = r(min)-(r(max)-r(min))*(`radj')+`offset'
			local vmax2 = r(max)+(r(max)-r(min))*(`radj')+`offset'
			*display in w "`vmin':`vmin2'"
			local vmax = r(max)+(r(max)-r(min))*`radj'
			** Verify range
			if  "`range'"!="" {
				numlist "`range'", sort
				local range `r(numlist)'

				local rmin:word 1 of `range'
				local rmax:word 2 of `range'
				local vmin=`rmin'
				local vmax=`rmax'
				local vmin2=`rmin'+`offset'
				local vmax2=`rmax'+`offset'
			} 
			** S2: Create the Range So Kdensities can be ploted			
			range `rvar' `vmin' `vmax' `nobs'
			if "`:var label `varlist''"!="" label var `rvar' "`:var label `varlist''"
			else label var `rvar' `varlist'	
			format `:format `varlist'' `rvar'
		}
 
 
	return local vmin =`vmin'
	return local vmin2=`vmin2'
	return local vmax =`vmax'
	return local vmax2 =`vmax2'
end

program _over, rclass
	syntax [anything], gen(string)
	
	if "`anything'"=="" {
		qui:gen byte `gen'=1
	}
	else {
		capture confirm numeric var `anything'
		if _rc!=0 {
				*tempvar nb
				encode `anything', gen(`gen')
				
		}
		else {
			clonevar `gen'=`anything'
		}
	}
end

program joy_plot
	if `c(stata_version)'>=16 {
		joy_plot_frame `0'
	}
	if `c(stata_version)'<16 {
		qui:joy_plot_old `0'
	}
end 

program joy_plot_frame

	syntax varname [if] [in] [aw/], [over(varname) ///
	radj(real 0)   /// Range Adjustment. How much to add or substract to the top bottom.
	range(numlist min=2 max=2) ///
	offset(real 0) /// to move text
	dadj(real 1)   /// Adjustment to density. Baseline. 1/grps
	bwadj(numlist >=0 <=1)  /// Adj on BW 0 uses average, 1 uses individual bw's
	bwadj2(real 1)  /// Adj on BW 0 uses average, 1 uses individual bw's
	kernel(string)  ///
	nobs(int 200)   ///
	color(string asis)   /// only colorlist
	colorpalette(string asis) /// Uses Benjann's Colors with all the options. 
	strict notext textopt(string) ///
	 gap0 alegend iqr ///
    fcolor(passthru)        ///  fill color and opacity
    fintensity(passthru) 	///  fill intensity
    lcolor(passthru)        ///  outline color and opacity
    lwidth(passthru)     	///  thickness of outline
    lpattern(passthru) 		///  outline pattern (solid, dashed, etc.)
    lalign(passthru) 		///   outline alignment (inside, outside, center)
    lstyle(passthru) 		///
    violin right addplot(string asis) *]     //  overall look of outline
   
	/*
	[ alegend legend(string) color(string) colorpalette(string) by(string) ///
										msymbol(passthru) msize(passthru) ///
										msangle(passthru) mfcolor(passthru) mlcolor(passthru) ///
										mlwidth(passthru) mlalign(passthru) jitter(passthru) jitterseed(passthru) *]*/
										
	marksample touse
	markout `touse' `varlist' `over' `exp', strok
	tempname frame
	frame put `varlist' `over' `exp'  if `touse', into(`frame') 
	
	qui:frame `frame': make_joy `0'
	
end





program joy_plot_old
	syntax varname [if] [in] [aw/], [over(varname) ///
	radj(real 0)   /// Range Adjustment. How much to add or substract to the top bottom.
	range(numlist min=2 max=2) ///
	offset(real 0) /// to move text
	dadj(real 1)   /// Adjustment to density. Baseline. 1/grps
	bwadj(numlist >=0 <=1)  /// Adj on BW 0 uses average, 1 uses individual bw's
	bwadj2(real 1)  /// Adj on BW 0 uses average, 1 uses individual bw's
	kernel(string)  ///
	nobs(int 200)   ///
	color(string asis)   /// only colorlist
	colorpalette(string asis) /// Uses Benjann's Colors with all the options. 
	strict notext textopt(string) ///
	 gap0 alegend iqr ///
    fcolor(passthru)        ///  fill color and opacity
    fintensity(passthru) 	///  fill intensity
    lcolor(passthru)        ///  outline color and opacity
    lwidth(passthru)     	///  thickness of outline
    lpattern(passthru) 		///  outline pattern (solid, dashed, etc.)
    lalign(passthru) 		///   outline alignment (inside, outside, center)
    lstyle(passthru) 		///
    violin right addplot(string asis) *]     //  overall look of outline
										
	marksample touse
	markout `touse' `varlist' `over' `exp', strok
	
	
	preserve
		keep `varlist' `over' `exp'  `touse'
		keep if `touse'
		make_joy `x0'
	restore
	
end


program make_joy
	syntax varname [if] [in] [aw/], [over(varname) ///
	radj(real 0)   /// Range Adjustment. How much to add or substract to the top bottom.
	range(numlist min=2 max=2) ///
	offset(real 0) /// to move text
	dadj(real 1)   /// Adjustment to density. Baseline. 1/grps
	bwadj(numlist >=0 <=1)  /// Adj on BW 0 uses average, 1 uses individual bw's
	bwadj2(real 1)  /// Adj on BW 0 uses average, 1 uses individual bw's
	kernel(string)  ///
	nobs(int 200)   ///
	color(string asis)   /// only colorlist
	colorpalette(string asis) /// Uses Benjann's Colors with all the options. 
	strict notext textopt(string) ///
	 gap0 alegend iqr ///
    fcolor(passthru)        ///  fill color and opacity
    fintensity(passthru) 	///  fill intensity
    lcolor(passthru)        ///  outline color and opacity
    lwidth(passthru)     	///  thickness of outline
    lpattern(passthru) 		///  outline pattern (solid, dashed, etc.)
    lalign(passthru) 		///   outline alignment (inside, outside, center)
    lstyle(passthru) 		///
    violin right addplot(string asis) *]     //  overall look of outline
   
   	if "`kernel'"=="" {
		local kernel gaussian
		local x0 `x0' kernel(`kernel')
	}
	if "`bwadj'"==""  {
		local bwadj=0
		local x0 `x0' bwadj(`bwadj')
	}
** make variable numeric with labels
		tempvar nb
 		_over `over', gen(`nb')
		local over `nb'
		
		** Create Rage var
		tempname rvar
 		_rangevar `varlist', radj(`radj') nobs(`nobs') rvar(`rvar') offset(`offset') range(`range')  
		local vmin = r(vmin)
		local vmin2 = r(vmin2)
		local vmax = r(vmax)
		local vmax2 = r(vmax2)
		
		** To account for Weights
		if "`exp'"=="" local wgtx
		if "`exp'"!="" local wgtx [aw=`exp']
		
		
		******************************************************************************************************************
		** S3: First pass BWs	
		levelsof `over', local(lvl)
		local bwmean = 0
		local cn     = 0
		** S4 Pass over ALL possible values
		foreach i of local lvl {
			local cn = `cn'+1
			kdensity `varlist' if `over'==`i'  `wgtx', kernel(`kernel')   nograph
			local bw`cn' = r(bwidth)			
			if `bwmean'==0 local bwmean = r(bwidth)
			else local bwmean = `bwmean'*(`cn'-1)/`cn'+r(bwidth)/`cn'
		}
		** And Recalculate
		local cn     = 0
		foreach i of local lvl {
			local cn = `cn'+1
			local bw`cn' =`bwadj2'*(`bwadj'*`bw`cn''+(1-`bwadj')*`bwmean')
		}
		
		** s5: get initial Densities
		*****************************************************************************************************************
		local cn     = 0
		local fmax   = 0
		** First get densities and find the MAX
		foreach i of local lvl {
			local cn     = `cn'+1
			tempvar f`cn'
 			kdensity `varlist' if `over'==`i'   `wgtx' , gen(`f`cn'') kernel(`kernel') at(`rvar') bw(`bw`cn'') nograph
			qui:sum `f`cn''
			if r(max)>`fmax' local fmax = r(max)
		}
		if "`gap0'"=="" local gp=1
		else     {
			local fmax=1
			local gp=0 
		}
		local vm 1
		if "`violin'"!="" {
			local vm -1
			local gp 1
		}
		
		*****************************************************************************************************************
		** s5: Rescale Densities
		** Then Rescale densities. Either for stacked or violin
		
		local cnt = `cn'
		local cn = 0
		foreach i of local lvl {
			local cn     = `cn'+1
			if "`gap0'"=="" qui: replace `f`cn''=(`f`cn''/`fmax') * `dadj'/`cnt' + 1/`cnt'*(`cnt'-`cn')*`gp'*`vm'
			if "`gap0'"!="" qui: replace `f`cn''=(`f`cn''/`fmax')                
			tempvar f0`cn'
			gen `f0`cn'' = 1/`cnt' * (`cnt'-`cn') * `gp' * `vm'    if `rvar'!=.
		}
		
		if "`violin'"!="" {
			*local cnt = `cn'
			local cn = 0
			foreach i of local lvl {
				local cn     = `cn'+1
				local f0 = `f0`cn''[1]
				local fvio `fvio' `f0'
				qui: replace `f0`cn''=`f0'-0.5*(`f`cn''-`f0')
				qui: replace `f`cn'' =`f0'+0.5*(`f`cn''-`f0')				
			}
		}
		****************************
		** IQR
		if "`iqr'"!="" {
			local cn     = 0			
			foreach i of local lvl {
				local cn     = `cn'+1
				tempvar prng`cn' pt`cn' p0`cn'
				qui:pctile `prng`cn''=`varlist' if `over'==`i'   `wgtx', n(4) 
				kdensity `varlist' if `over'==`i'   `wgtx' , gen(`pt`cn'') ///
															  kernel(`kernel') at(`prng`cn'') bw(`bw`cn'') nograph
 
				replace `pt`cn''=(`pt`cn''/`fmax')*`dadj'/`cnt'+1/`cnt'*(`cnt'-`cn')*`gp'*`vm'	in 1/3
				gen `p0`cn''=1/`cnt'*(`cnt'-`cn')*`gp'*`vm'	in 1/3
				
			}
			** If violin	
			if "`violin'"!="" {
				local cnt = `cn'
				local cn = 0
				foreach i of local lvl {
					local cn     = `cn'+1
					local f0 = `p0`cn''[1]
					qui: replace `p0`cn'' =`f0'-0.5*(`pt`cn''-`f0')
					qui: replace `pt`cn'' =`f0'+0.5*(`pt`cn''-`f0')				
				}
			}			
		}

		****************************
		
		** keep essentials
		keep if `rvar'!=.
		
		*******************************************************************************************
		** Text to identify What something is.
		** 1 Not valid if violin or gap0
		if "`text'"=="" & "`violin'"=="" & "`gap0'"=="" {
			local cn = 0
			foreach i of local lvl {
				local cn     = `cn'+1
				local lbl: label (`over') `i', `strict'
				if "`right'"=="" local totext `totext' `=`f0`cn''+0.5/`cnt'' `vmin2'  `"`lbl'"'
				else             local totext `totext' `=`f0`cn''+0.5/`cnt'' `vmax2'  `"`lbl'"'
			}
		}	
		else if "`violin'"!="" /*& "`gap0'"=="" & "`text'"==""*/ {
			local cn = 0
			local vtotext
			foreach i of local lvl {
				local cn     = `cn'+1
				local lbl: label (`over') `i', `strict'
				*local vl : word  `cn' `fvio'
				local vl = 1/`cnt'*(`cnt'-`cn')*`vm'
				local vtotext `vtotext'  `vl' "`lbl'"
			}
			local xlabvio xlabel(`vtotext')
			local horizontal horizontal
		}
		
		** Auto Legend
		if "`alegend'"!="" {
			local cn = 1
			if "`iqr'"!="" local uno 1
			foreach i of local lvl {				
				local lbl: label (`over') `i', `strict'
				local aleg `aleg' `cn' `"`lbl'"'
				local cn     = `cn'+1+0`uno' 
			}
		}
		** colors
		local wcp: word count `colorpalette'
		if `wcp'>0 {
			if strpos( `"`colorpalette'"' , ",") == 0 local colorpalette `"`colorpalette' , nograph n(`cnt')"'
			else local colorpalette `" `colorpalette'  nograph n(`cnt')"' 		
			colorpalette `colorpalette'
			** Putting all together
			local cn = 0 
			foreach i of local lvl {
				local cn = `cn'+1
				local ll:word `cn' of `r(p)'
				if "`iqr'"!="" local iqrline (rspike `pt`cn'' `p0`cn'' `prng`cn'', color(`"`ll'"') lwidth(.3) `horizontal')
				
				local joy `joy' (rarea `f`cn'' `f0`cn'' `rvar', color(`"`ll'"') ///
								`fcolor' `fintensity' `lcolor' `lwidth' `lpattern' `lalign' `lstyle' `horizontal')  `iqrline'
			}
		}
		else if `"`color'"'!="" {
			local cn = 0 
			
			foreach i of local lvl {
				local cn = `cn'+1
				if `cn'<=`:word count `color'' 	local ll:word `cn' of `color'
				
				if "`iqr'"!="" local iqrline (rspike `pt`cn'' `p0`cn'' `prng`cn'', lwidth(.3) color(`"`ll'"') `horizontal')
				local joy `joy' (rarea `f`cn'' `f0`cn'' `rvar',  `lcolor' `lwidth' color(`"`ll'"') ///
								`fcolor' `fintensity' `lcolor' `lwidth' `lpattern' `lalign' `lstyle' `horizontal')  `iqrline'
			}
		}
		else {
				local cn = 0 
				foreach i of local lvl {
				local cn = `cn'+1
		
				if "`iqr'"!="" local iqrline (rspike `pt`cn'' `p0`cn'' `prng`cn'', lwidth(.3) pstyle(p`cn') `horizontal')
				local joy `joy' (rarea `f`cn'' `f0`cn'' `rvar',  ///
								`fcolor' `fintensity' `lcolor' `lwidth' `lpattern' `lalign' `lstyle' ///
								 pstyle(p`cn') `horizontal')  `iqrline'
			}			
		}
		***************************************************************************************************************
		if "`alegend'"!="" local leg   legend(order(`aleg'))
		else if strpos( "`options'" , "legend")==0 local leg legend(off)
		else local leg
 		if "`gap0'"!="" | "`violin'"!="" 	local ylabx 
		else local ylabx ylabel("")
		
		two `joy' (`addplot'), ///
			text(`totext' , `textopt') ///
			`options' `leg' `ylabx' `xlabvio'

end
