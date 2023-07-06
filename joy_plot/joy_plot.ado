*! v1.54 Corrects xlabel for biviolin
* v1.53 Corrects xlabel for biviolin
* v1.52 Corrects if 
* v1.51 Refinements for Default Options
* v1.5 over and by
* v1.4 works with Stata 10 or above?
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
	syntax [anything], gen(string) var(varname)
	
	if "`anything'"=="" {
		qui:gen byte `gen'=1		
		local tolab:variable label `var'
		if `"`tolab'"'=="" local tolab `var'
		qui:label var `gen' `"`tolab'"'
		label define `gen' 1 `"`tolab'"'
		label values `gen' `gen'
		*display in w "`tolab'" 
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

program colorpalette_parser, rclass
	syntax [anything(everything)], [nograph * n(string asis) opacity(passthru)]
	return local clp   = `"`anything', `options'"'
	return local clpop = `"`anything', `options' `opacity'"'
end

/*program joy_plot
	if `c(stata_version)'>=16 {
		joy_plot_frame `0'
	}
	if `c(stata_version)'<16 {
		qui:joy_plot_old `0'
	}
end */

 

program joy_plot

	syntax varlist [if] [in] [aw/], [over(varname) by(varname) *]     //  overall look of outline
   
	/*
	[ alegend legend(string) color(string) colorpalette(string) by(string) ///
										msymbol(passthru) msize(passthru) ///
										msangle(passthru) mfcolor(passthru) mlcolor(passthru) ///
										mlwidth(passthru) mlalign(passthru) jitter(passthru) jitterseed(passthru) *]*/
	marksample touse
	** detect if
 
	fvexpand `varlist'
	local vars:word count `r(varlist)'
	if `vars'>1 & "`over'"!="" {
		display in red "over cannot be combined with multiple variables"
	}
	markout `touse' `varlist' `over' `by' `exp' , strok
	tempname frame
	
	if `c(stata_version)'>=16 {
		frame put `varlist' `over' `by' `exp'  if `touse', into(`frame') 
		syntax varlist [aw] [if] [in], [*]
		if "`by'"==""    qui:frame `frame': make_joy  `varlist' [`weight'`exp'], `options'
		if "`by'"!=""    qui:frame `frame': make_joy2 `varlist' [`weight'`exp'], `options'
	}
	if `c(stata_version)'<16 {
		preserve
			qui:keep `varlist' `over'  `by' `exp'  `touse'
			qui:keep if `touse'			
			syntax varlist [aw] [if] [in], [*]
			if "`by'"==""  qui: make_joy `varlist' [`weight'`exp'], `options'
			if "`by'"!=""  qui: make_joy2 `varlist' [`weight'`exp'], `options'
		restore
	}
	
end

program mypctile
	syntax varname [if] [in] [aw iw pw], [iqr(numlist) newvar(string)]  
	** STP 1. get all _pctile
	if "`iqr'"=="" local iqr 25 50 75
	
	qui:gen double `newvar'=.
	_pctile `varlist' `if' `in' [`weight'`exp'], percentiles(`iqr')
	local cn = 1
	while "`r(r`cn')'"!="" {
		qui:replace `newvar' = `r(r`cn')' in `cn'
		local cn=`cn'+1
	}
	
end
 
program mycolors, rclass
	syntax,   cn(numlist) cnx(numlist) [col_op(int 1) cclist(str asis)]
	if `col_op'==1 {
		local wrd:word count `cclist'
		if `cn'<=`wrd'	local mycolor:word `cn' of `cclist'
		else 			local mycolor:word `wrd' of `cclist'
		
	}
	if `col_op'==2 local mycolor:word `cn' of `cclist'
	if `col_op'==3 {
		if `cnx'>15	 local cnx 1
		qui:graphquery color p`cnx'
		local mycolor `r(query)'
	}
	return local mycolor `mycolor'
end

program text_default, rclass
	syntax , [* size(str asis) placement(str asis) right]
	if `"`size'"'=="" local size small
	if `"`place'"'=="" {
		local placement e
		if "`right'"!="" local placement w
	}
	return local textopt `options' size(`size') placement(`placement')
end

program make_joy
	syntax varlist [if] [in] [aw/], [over(varname) by(varname) ///
	radj(real 0)   /// Range Adjustment. How much to add or substract to the top bottom.
	range(numlist min=2 max=2) ///
	offset(real 0) /// to move text
	yoffset(real 0) /// Move text up down
	dadj(real 1)   /// Adjustment to density. Baseline. 1/grps
	bwadj(numlist >=0 <=1)  /// Adj on BW 0 uses average, 1 uses individual bw's
	bwadj2(real 1)  /// Adj on BW 0 uses average, 1 uses individual bw's
	BWadj3(real 0)  /// Adj on BW on all
	kernel(string)  ///
	Nobs(int 200)   ///
	color(string asis)   /// only colorlist
	IQRLWidth(real 0.3)  ///
	IQRLColor(str asis)  ///
	COLORPalette(string asis) /// Uses Benjann's Colors with all the options. 
	strict notext textopt(string) ///
	 gap0 alegend IQR IQR1(numlist >0 <100) ///
    FColor(passthru)        ///  fill color and opacity
    FIntensity(passthru) 	///  fill intensity
    LColor(passthru)        ///  outline color and opacity
    LWidth(passthru)     	///  thickness of outline
    LPattern(passthru) 		///  outline pattern (solid, dashed, etc.)
    LAlign(passthru) 		///   outline alignment (inside, outside, center)
    LSTYle(passthru) 		///	XLABel(passthru)        /// 
    violin right addplot(string asis) *]     //  overall look of outline
   
   	if "`kernel'"=="" 	local kernel gaussian
		
	if "`bwadj'"==""  local bwadj=0
		
** make variable numeric with labels
	** Expand for newvar
	fvexpand `varlist'
	local vars:word count `r(varlist)'
	if `vars'>1 {
		tempvar id over t fvar
		gen double `id'=_n
		expand `vars'
		bysort `id':gen `over'=_n
		gen double `fvar'=.
		foreach i of varlist `varlist' {
			local vcnt=`vcnt'+1
			replace `fvar'=`i' if `over'==`vcnt'
			local vn:variable label `i'
			if "`vn'"=="" local vn `i'
			local varlab `varlab' `vcnt' "`vn'"
		}
		label define varlab  `varlab' 
		label values `over' varlab
		label var `fvar' " "
		local varlist `fvar'
		
	}

		tempvar nb
 		_over `over', gen(`nb') var(`varlist')
		local over `nb'
		
		** Create Range var
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
		
		if `bwadj3'==0 {
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
		}
		else {
			local cn     = 0
			foreach i of local lvl {
					local cn = `cn'+1
					local bw`cn' =`bwadj3'				
			}
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
			qui:replace `f`cn''=0 if `f`cn''==. 
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
			*if "`gap0'"!="" qui: replace `f`cn''=(`f`cn'')                
			tempvar f0`cn'
			**zero
			gen `f0`cn'' = 1/`cnt' * (`cnt'-`cn') * `gp' * `vm'    if `rvar'!=.
		}
		
		if "`violin'"!="" {
			*local cnt = `cn'
			local cn = 0
			foreach i of local lvl {
				local cn     = `cn'+1
				local f0 = `f0`cn''[1]
				local fvio `fvio' `f0'
				qui: replace `f0`cn''=`f0'-0.5*(`f`cn''-`f0')-0.5/`cnt'
				qui: replace `f`cn'' =`f0'+0.5*(`f`cn''-`f0')-0.5/`cnt'				
				sum `f0`cn'' `f`cn''
			}
			
		}
		****************************
		** IQR
		if "`iqr'`iqr1'"!="" {
			local cn = 0			
			foreach i of local lvl {
				local cn     = `cn'+1
				tempvar prng`cn' pt`cn' p0`cn'
				qui:mypctile `varlist' if `over'==`i'   `wgtx', newvar(`prng`cn'') iqr(`iqr1')
				kdensity `varlist' if `over'==`i'   `wgtx' , gen(`pt`cn'') ///
															  kernel(`kernel') at(`prng`cn'') bw(`bw`cn'') nograph
				qui:replace `pt`cn''=0 if `pt`cn''==.
				replace `pt`cn''=(`pt`cn''/`fmax')*`dadj'/`cnt'+1/`cnt'*(`cnt'-`cn')*`gp'*`vm'	 
				gen `p0`cn''=1/`cnt'*(`cnt'-`cn')*`gp'*`vm'	 
				
			}
			** If violin	
			if "`violin'"!="" {
				local cnt = `cn'
				local cn = 0
				foreach i of local lvl {
					local cn     = `cn'+1
					local f0 = `p0`cn''[1]
					qui: replace `p0`cn'' =`f0'-0.5*(`pt`cn''-`f0') -0.5/`cnt'
					qui: replace `pt`cn'' =`f0'+0.5*(`pt`cn''-`f0')	-0.5/`cnt'			
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
				if "`right'"=="" local totext `totext' `=`f0`cn''+(0.5+`yoffset')/`cnt'' `vmin2'  `"`lbl'"'
				else             local totext `totext' `=`f0`cn''+(0.5+`yoffset')/`cnt'' `vmax2'  `"`lbl'"'
			}
		}	
		else if "`violin'"!=""  /*& "`gap0'"=="" & */ {
			local cn = 0
			local vtotext
			if  "`text'"=="" {
				foreach i of local lvl {
					local cn     = `cn'+1
					local lbl: label (`over') `i', `strict'
					*local vl : word  `cn' `fvio'
					local vl = 1/`cnt'*(`cnt'-`cn')*`vm'-0.5/`cnt'
					local vtotext `vtotext'  `vl' "`lbl'"
				}
			}
			local horizontal horizontal
			
		}
		local cnt =`cn'
		** Auto Legend
		if "`alegend'"!="" {
			local cn = 1
			if "`iqr'`iqr1'"!="" local uno 1
			foreach i of local lvl {				
				local lbl: label (`over') `i', `strict'
				local aleg `aleg' `cn' `"`lbl'"'
				local cn     = `cn'+1+0`uno' 
			}
		}
		** colors
		** Like with mscatter Create Color List 
				** Which color options:
				
		if `"`color'"'!="" local col_op = 1   // <--- provides colors by variable
		else {
			if "`colorpalette'"!="" local col_op = 2   // <-- Uses Color palette
			else                    local col_op = 3   // <-- Uses default "system" colors
		}
		
	 
		if `col_op'==2 {
			local cnt: word count `lvl'
			colorpalette_parser `colorpalette'
			colorpalette `r(clpop)' nograph n(`cnt')
			local cpcolor  `"`r(p)'"'
		}

		local cn=0
		local cnx=0
		foreach i of local lvl {
			local cn = `cn' +1 	
			local cnx = `cnx' +1 	
			mycolors, col_op(`col_op') cclist(`color'`cpcolor') cn(`cn') cnx(`cnx')
			local mycolor `r(mycolor)'
			
			if "`iqr'`iqr1'"!="" local iqrline (rspike `pt`cn'' `p0`cn'' `prng`cn'', color("`mycolor'") lcolor("`iqrlcolor'") lwidth(`iqrlwidth') `horizontal')
				
			local joy `joy' (rarea `f`cn'' `f0`cn'' `rvar', color("`mycolor'") ///
								`fcolor' `fintensity' `lcolor' `lwidth' `lpattern' `lalign' `lstyle' `horizontal')  `iqrline'
		}
		
		
 

		***************************************************************************************************************
		if "`alegend'"!="" local leg   legend(order(`aleg'))
		else if strpos( `"`options'"' , "legend")==0 local leg legend(off)
		else local leg
 		if "`gap0'"!="" | "`violin'"!="" 	local ylabx 
		else local ylabx ylabel("")
		*** text default
		text_default , `textopt' `right'
		local textopt `r(textopt)'
		xlabel_default, vio(`vtotext') `xlabel' `text' `options'
		local mxlabel `r(xlabel)'
		
		two `joy' (`addplot'), ///
			text(`totext' , `textopt') ///
			`options' `leg' `ylabx'  `mxlabel' 
end

** This maes the program not 15 friendly
mata:
	void gquery(string scalar scm, anything){
		string matrix any, sch, ssch
		ssch=cat(scm)
		any=stritrim(strtrim(tokens(anything)))
		real scalar i, fnd, nr
		nr=rows(ssch)
		fnd=1
		i=1
		while(fnd==1){			
			i++
			sch=stritrim(tokens(ssch[i,]))
			if (cols(sch)==3) {
				if (sch[1]==any[1] & sch[2]==any[2]) {		
					fnd=0
					st_local("toreturn",sch[3])
				}
			}
			if (i==nr) {
				fnd=0
			}
		}
	}
end

program graphquery, rclass
	syntax anything, [DEFAULT DEFAULT1(str asis) ]
	qui:findfile "scheme-`c(scheme)'.scheme"
	mata:gquery("`r(fn)'","`anything'") 
	if `"`toreturn'"'=="" & "`default'`default1'"!="" local toreturn `default'`default1'
	display "`anything':" `"`toreturn'"'
	
	return local query   `toreturn'
end

*** This will do the over and by
program make_joy2
	syntax varlist [if] [in] [aw/], [over(varname) by(varname) ///
	radj(real 0)   /// Range Adjustment. How much to add or substract to the top bottom.
	range(numlist min=2 max=2) ///
	offset(real 0) /// to move text
	yoffset(real 0) /// Move text up down
	dadj(real 1)   /// Adjustment to density. Baseline. 1/grps
	bwadj(numlist >=0 <=1)  /// Adj on BW 0 uses average, 1 uses individual bw's
	bwadj2(real 1)  /// Adj on BW 0 uses average, 1 uses individual bw's
	BWadj3(real 0)  /// Adj on BW on all
	kernel(string)  ///
	Nobs(int 200)   ///
	color(string asis)   /// only colorlist
	IQRLWidth(real 0.3)  ///
	IQRLColor(str asis)  ///
	COLORPalette(string asis) /// Uses Benjann's Colors with all the options. 
	strict notext textopt(string) ///
	 gap0 alegend IQR IQR1(numlist >0 <100) ///
    FColor(passthru)        ///  fill color and opacity
    FIntensity(passthru) 	///  fill intensity
    LColor(passthru)        ///  outline color and opacity
    LWidth(passthru)     	///  thickness of outline
    LPattern(passthru) 		///  outline pattern (solid, dashed, etc.)
    LAlign(passthru) 		///   outline alignment (inside, outside, center)
    LSTYle(passthru) 		///	XLABel(passthru)        /// 
    violin right addplot(string asis) *]     //  overall look of outline
	   
   	if "`kernel'"=="" 	local kernel gaussian
		
	if "`bwadj'"==""  local bwadj=0
	
	fvexpand `varlist'
	local vars:word count `r(varlist)'
	if `vars'>1 {
		tempvar id over t fvar
		gen double `id'=_n
		expand `vars'
		bysort `id':gen `over'=_n
		gen double `fvar'=.
		foreach i of varlist `varlist' {
			local vcnt=`vcnt'+1
			replace `fvar'=`i' if `over'==`vcnt'
			local vn:variable label `i'
			if "`vn'"=="" local vn `i'
			local varlab `varlab' `vcnt' "`vn'"
		}
		label define varlab  `varlab' 
		label values `over' varlab
		label var `fvar' " "
		local varlist `fvar'
		
	}
	
	tempvar nb
	_over `over', gen(`nb') var(`varlist')
	local over `nb'
	
	tempvar nb2
	_over `by', gen(`nb2') var(`varlist')
	local by `nb2'
	
	if "`violin'"!="" {
		tempvar nx
		bysort `by':gen `nx'=_n
		qui:count if `nx'==1
		if `r(N)'>2 {
			display in r "With violin, you can only use up to 2 groups"
			error 222
		}
	}
	
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
		levelsof `by'  , local(lvl2)
		
		if `bwadj3'==0 {
			local bwmean = 0
			local cn     = 0
			local ii     = 0
			** S4 Pass over ALL possible values
			foreach i of local lvl {
				local ii=`ii'+1
				local jj     = 0
				foreach j of local lvl2 {
					local cn = `cn'+1
					local jj=`jj'+1
					
					kdensity `varlist' if `over'==`i' & `by'==`j'  `wgtx', kernel(`kernel')   nograph
					local bw`ii'`jj' = r(bwidth)			
					if `r(bwidth)'==. local bw`ii'`jj'=`bwmean'

					if `cn'==1 local bwmean = r(bwidth)
					else local bwmean = `bwmean'*(`cn'-1)/`cn'+`bw`ii'`jj''/`cn'
					
				}
			}
			** And Recalculate
			local ii     = 0
			foreach i of local lvl {
				local ii=`ii'+1
				local jj     = 0
				foreach j of local lvl2 {
					local jj=`jj'+1
					local bw`ii'`jj' =`bwadj2'*(`bwadj'*`bw`ii'`jj''+(1-`bwadj')*`bwmean')
				}
			}
		}
		else {
			local ii     = 0
			local cn = 0
			foreach i of local lvl {
				local ii=`ii'+1
				local jj     = 0			
				foreach j of local lvl2 {
					local cn = `cn'+1
					local jj=`jj'+1
					local bw`ii'`jj' =`bwadj3'
				}
			}
		}
		
		local cnt = `cn'/2
		local cntt = `cn'
		** s5: get initial Densities
		*****************************************************************************************************************
		local ii     = 0
		
		local fmax   = 0
		** First get densities and find the MAX
		foreach i of local lvl {
			local ii=`ii'+1
			local jj     = 0
			foreach j of local lvl2 {
				local jj=`jj'+1
				tempvar f`ii'`jj'
				kdensity `varlist' if `over'==`i'  & `by'==`j' `wgtx' , gen(`f`ii'`jj'') kernel(`kernel') at(`rvar') bw(`bw`ii'`jj'') nograph
				qui:replace `f`ii'`jj''=0 if `f`ii'`jj''==.
				qui:sum `f`ii'`jj''
				if r(max)>`fmax' local fmax = r(max)
			}	
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
		** Here is where things NEED to be taken care of

		local cn = 0
		local ii     = 0
		foreach i of local lvl {
			local cn     = `cn'+1
			local ii     = `ii'+1
			local jj     = 0
			foreach j of local lvl2 {				
				local jj     = `jj'+1
				if "`gap0'"=="" qui: replace `f`ii'`jj''=(`f`ii'`jj''/`fmax') * `dadj'/`cnt' + 1/`cnt'*(`cnt'-`cn')*`gp'*`vm'
				tempvar f0`ii'`jj'
				**zero
				gen `f0`ii'`jj'' = 1/`cnt' * (`cnt'-`cn') * `gp' * `vm'    if `rvar'!=.
			}
		}
		
		**** But if Violin...
		
		if "`violin'"!="" {
			
			*local cnt = `cn'
			local cn = 0
			local flp = -1
			local ii     = 0
			foreach i of local lvl {
				local cn     = `cn'+1
				local ii     = `ii'+1
				local jj     = 0
				foreach j of local lvl2 {
					local jj     = `jj'+1
					local f0 = `f0`ii'`jj''[1]
					qui: replace `f`ii'`jj'' =`f0'+0.5*(`f`ii'`jj''-`f0')*`flp'			-0.5/`cnt'	
					qui: replace `f0`ii'`jj'' = `f0`ii'`jj''   -0.5/`cnt'	
					local flp = -`flp'
					
				}	
				local fvio `fvio' `f0'
				
			}
		}
		****************************
		** IQR
		if "`iqr'`iqr1'"!="" {
			local cn = 0	
			local ii     = 0
			foreach i of local lvl {
				local cn     = `cn'+1
				local ii     = `ii'+1
				local jj     = 0
				foreach j of local lvl2 {
					local jj     = `jj'+1
					tempvar prng`ii'`jj' pt`ii'`jj' p0`ii'`jj'
					*qui:pctile `prng`cn''=`varlist' if `over'==`i'   `wgtx', n(4) 
					qui:mypctile `varlist' if `over'==`i' & `by'==`j'  `wgtx', newvar(`prng`ii'`jj'') iqr(`iqr1')
					
					kdensity `varlist' if `over'==`i' & `by'==`j'  `wgtx' , gen(`pt`ii'`jj'') ///
																  kernel(`kernel') at(`prng`ii'`jj'') bw(`bw`ii'`jj'') nograph
					qui:replace `pt`ii'`jj''=0 if `pt`ii'`jj''==.
					replace `pt`ii'`jj''=(`pt`ii'`jj''/`fmax')*`dadj'/`cnt'+1/`cnt'*(`cnt'-`cn')*`gp'*`vm'	
					gen `p0`ii'`jj''=1/`cnt'*(`cnt'-`cn')*`gp'*`vm'	
				}
			}
			** If violin	
			if "`violin'"!="" {
				local flp = -1
				local ii     = 0
				foreach i of local lvl {
					local jj     = 0
					local ii = `ii'+1
					foreach j of local lvl2 {						
						local jj = `jj'+1
						local f0 = `p0`ii'`jj''[1]
						qui: replace `pt`ii'`jj'' =`f0'+0.5*(`pt`ii'`jj''-`f0')*`flp'	-0.5/`cnt'
						qui: replace `p0`ii'`jj''=`p0`ii'`jj''-0.5/`cnt'
						local flp = -`flp'
					}		
				}
			}
			***********
		}

		****************************
		
		** keep essentials
		keep if `rvar'!=.
		
		*******************************************************************************************
		** Text to identify What something is.
		** 1 Not valid if violin or gap0
		if "`text'"=="" & "`violin'"=="" & "`gap0'"=="" {
			local cn = 0
			local ii=0
			foreach i of local lvl {
				local ii=`ii'+1
				local lbl: label (`over') `i', `strict'
				if "`right'"=="" local totext `totext' `=`f0`ii'1'+(0.5+`yoffset')/`cnt'' `vmin2'  `"`lbl'"'
				else             local totext `totext' `=`f0`ii'1'+(0.5+`yoffset')/`cnt'' `vmax2'  `"`lbl'"'
			}
		}	
		else if "`violin'"!="" /*& "`gap0'"=="" & "`text'"==""*/ {
			local cn = 0
			local vtotext
			if  "`text'"=="" {
				foreach i of local lvl {
					local cn     = `cn'+1
					local lbl: label (`over') `i', `strict'
					*local vl : word  `cn' `fvio'
					local vl = 1/`cnt'*(`cnt'-`cn')*`vm'-0.5/`cnt'
					local vtotext `vtotext'  `vl' "`lbl'"
				}
			}
 
			local horizontal horizontal
		}
		*local cnt =`cn'
		** Auto Legend
		if "`alegend'"!="" {
			local cn = 1
			if "`iqr'`iqr1'"!="" local uno 1
			foreach j of local lvl2 {				
				local lbl: label (`by') `j', `strict'
				local aleg `aleg' `cn' `"`lbl'"'
				local cn     = `cn'+1+0`uno' 
			}
		}
		** colors
		** Like with mscatter Create Color List 
				** Which color options:
		if `"`color'"'!="" local col_op = 1   // <--- provides colors by variable
		else {
			if "`colorpalette'"!="" local col_op = 2   // <-- Uses Color palette
			else                    local col_op = 3   // <-- Uses default "system" colors
		}
		if `col_op'==2 {
			local cnt: word count `lvl2'
			colorpalette_parser `colorpalette'
			colorpalette `r(clpop)' nograph n(`cnt')
			local cpcolor  `"`r(p)'"'
		}
		
		local ii=0
		foreach i of local lvl {
			local ii=`ii'+1
			local jj=0
			local cn=0
			foreach j of local lvl2 {
				local jj = `jj'+1
				local cn = `cn' +1 					
				mycolors, col_op(`col_op') cclist(`color'`cpcolor') cn(`cn') cnx(`cn')
				local mycolor `r(mycolor)'
	
				if "`iqr'`iqr1'"!="" local iqrline (rspike `pt`ii'`jj'' `p0`ii'`jj'' `prng`ii'`jj'', ///
									 color("`mycolor'") lcolor("`iqrlcolor'") lwidth(`iqrlwidth') `horizontal')
					
				local joy `joy' (rarea `f`ii'`jj'' `f0`ii'`jj'' `rvar', color("`mycolor'") ///
									`fcolor' `fintensity' `lcolor' `lwidth' `lpattern' `lalign' `lstyle' `horizontal')  `iqrline'
			}						
		}
		
 

		***************************************************************************************************************
		if "`alegend'"!="" local leg   legend(order(`aleg'))
		else if strpos( `"`options'"' , "legend")==0 local leg legend(off)
		else local leg
 		if "`gap0'"!="" | "`violin'"!="" 	local ylabx 
		else local ylabx ylabel("")
		*** text default
		text_default , `textopt' `right'
		local textopt `r(textopt)'
		
		xlabel_default, vio(`vtotext') `options' `text'
		
		local mxlabel `r(xlabel)'
		
		two `joy' (`addplot'), ///
			text(`totext' , `textopt') ///
			`options' `leg' `ylabx' `mxlabel' 

end

program xlabel_default, rclass
	syntax , [vio(string asis) xlabel(str asis) * notext]
		
	if `"`xlabel'"'=="" {
		if `"`vio'"'=="" return local xlabel xlabel(, nogrid)
		else             return local xlabel xlabel(`vio', nogrid)
	}
	
	else return local xlabel xlabel(`xlabel')
	
end