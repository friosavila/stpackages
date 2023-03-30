*! v1.15 white background flexible
*! v1.12 Adds White and black as background.
*! v1.11 Fixes gap0. and adds line
*! v1.1 Fixes Stack. To show total numbers not adjusted ones
*! v1 Ridgeline Plot 4/11/2022 FRA
* Need to create submodules!
* Like joyplot but for lines. Together lines. area lines.? Stack area?
* stream
*capture program drop ridge_line
*capture program drop _rangevar
*program drop _all

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

program _rangevar, sortpreserve rclass
	syntax varlist, [radj(real 0.0) nobs(real 0.0) rvar(string) offset(real 0.0) range(numlist) rangeasis]
			** S1: Readjust range
			sum `varlist', meanonly
			local vmin  = r(min)-(r(max)-r(min))*`radj'
			local vmin2 = r(min)-(r(max)-r(min))*(`radj')+`offset'
			local vmax2 = r(max)+(r(max)-r(min))*(`radj')+`offset'
			*display in w "`vmin':`vmin2'"
			local vmax = r(max)+(r(max)-r(min))*`radj'
			
		if "`rangeasis'"=="" {

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
		
		else {
			qui:gen double `rvar'=.
			mata: rangeasis("`varlist'","`rvar'") 
			if "`:var label `varlist''"!="" label var `rvar' "`:var label `varlist''"
			else label var `rvar' `varlist'	
			format `:format `varlist'' `rvar'
		}
 
	return local vmin =`vmin'
	return local vmin2=`vmin2'
	return local vmax =`vmax'
	return local vmax2 =`vmax2'
end


program _rangevar2, sortpreserve rclass
	syntax varlist, [radj(real 0.0) nobs(real 0.0) rvar(string) offset(real 0.0) range(numlist) rangeasis ]
	
	** always
	sum `varlist', meanonly
	local vmin  = r(min)-(r(max)-r(min))*`radj'
	local vmin2 = r(min)-(r(max)-r(min))*(`radj')+`offset'
	local vmax2 = r(max)+(r(max)-r(min))*(`radj')+`offset'
	local vmax = r(max)+(r(max)-r(min))*`radj'
	
		if "`rangeasis'"=="" {
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
		else {
			qui:gen double `rvar'=.
			mata: rangeasis("`varlist'","`rvar'") 
			if "`:var label `varlist''"!="" label var `rvar' "`:var label `varlist''"
			else label var `rvar' `varlist'	
			format `:format `varlist'' `rvar'
		}
end

mata:
void rangeasis(string scalar var, rvar){
	real matrix  original, small
	original=st_data(.,"rvar")
	small   =uniqrows(original)
	original=J(rows(original),1,.)
	original[1..rows(small),1]=small
	st_store(.,rvar,original)
	///mata:st_store(.,1,"h",(1::1647))
}
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

program ridgeline_plot

	if `c(stata_version)'<16 {
		display "You need Stata 16 or higher to use this command"
		error 9
	}
	syntax varlist(min=2 max=2) [if] [in] [iw/], over(varname) [ ///
	radj(real 0)   /// Range Adjustment. How much to add or substract to the top bottom.
	range(numlist min=2 max=2) ///
	offset(real 0) /// to move text
	dadj(real 1)   /// Adjustment to height. Baseline. 1/grps
	badj(real 0)   /// Adjustment to base. Default 0
	bwadj(numlist >=0 <=1)  /// Adj on BW 0 uses average, 1 uses individual bw's
	bwadj2(real 0.2)  /// Adj on BW 0.1
	BWadj3(numlist >0 )  /// bw for all
	kernel(string)  ///
	degree(int 0)   ///
	nobs(int 200)   /// 
	color(string asis)   /// only colorlist
	colorpalette(string asis) /// Uses Benjann's Colors with all the options. 
	strict notext right  textopt(string) ///
	gap0 alegend line white black ///
    fcolor(passthru)        ///  fill color and opacity
    fintensity(passthru) 	///  fill intensity
    lcolor(passthru)        ///  outline color and opacity
    lwidth(passthru)     	///  thickness of outline
    lpattern(passthru) 		///  outline pattern (solid, dashed, etc.)
    lalign(passthru) 		///   outline alignment (inside, outside, center)
    lstyle(passthru) 		///
    stack stack100 rangeasis ///
	STREAM  STREAM1(numlist max=1 >0)  half   ///  Stack, Stack graph, Stream(to move things)
	NORMalize sum asis	/// asis. use data as given; sum to get sums of data; norm
	addplot(string asis) * default]     //  overall look of outline
   
	*** Get sample										
	marksample touse
	markout `touse' `varlist' `over' `exp', strok
	** Basic way of doing this. Triangular
	if "`kernel'"=="" local kernel tri
	if "`bwadj'"=="" local bwadj=0
	if "`stream'`stream1'"!="" & "`stack'`stack100'"=="" local stack stack
	if "`black'"!="" local black gs1
	
	tempname frame
	frame put `varlist' `over' `exp'  if `touse', into(`frame') 
	
	qui:frame `frame': {
			
		** make variable numeric with labels
		tempvar nb
 		_over `over', gen(`nb')
		local over `nb'
		
		**Rename variables so I can work with them
		tempname rvar
		
		if "`exp'"!="" ren (`varlist' `over' `exp') (yvar_ xvar_ over_ wgt)  
		else {
			ren (`varlist' `over' ) (yvar_ xvar_ over_ )  
			qui:gen byte wgt=1
		}
		** Continue or Modify data
		bysort over_ xvar_:gen n=_N
		sum n, meanonly
		** Pesos solo para sacar sumas o means
		** If more than 1 observation. then collapse
		if `r(max)'>1 & "`sum'"!="" {
			collapse (sum) yvar_ [iw=wgt], by(over_ xvar_)	fast
			gen byte wgt=1
			}
			
		** Get Range
		_rangevar xvar_, radj(`radj') nobs(`nobs') rvar(rvar) offset(`offset') range(`range')  
		local vmin = r(vmin)
		local vmin2 = r(vmin2)
		local vmax = r(vmax)
		local vmax2 = r(vmax2)
		** get totals
				
		******************************************************************************************************************
		** S3: First pass BWs	
		levelsof over_, local(lvl)

		if "`bwadj3'"=="" {

			local bwmean = 0
			local cn     = 0
			** S4 Pass over ALL possible values
			foreach i of local lvl {
				local cn = `cn'+1
				lpoly yvar_ xvar_ if over_==`i' [aw=wgt]  , kernel(`kernel')   nograph degree(`degree')
				local bw`cn' = r(bwidth)			
				if `bwmean'==0 local bwmean = r(bwidth)
				else local bwmean = `bwmean'*(`cn'-1)/`cn'+r(bwidth)/`cn'
			}
			
		** And Recalculate. Between individual and average
			local cn     = 0
			foreach i of local lvl {
				local cn = `cn'+1
				local bw`cn' =`bwadj2'*(`bwadj'*`bw`cn''+(1-`bwadj')*`bwmean')
			}
		}

		if "`bwadj3'"!="" {
			local cn     = 0
		
			foreach i of local lvl {
				*display in w "`bwadj3'"
				local cn = `cn'+1
				local bw`cn' =`bwadj3'
			}
		}
	
		** s5: get initial smooth
		*****************************************************************************************************************
		local cn     = 0
		local fmax   = 0
		
		** First get densities and find the MAX
		foreach i of local lvl {
			local cn     = `cn'+1
			tempvar f`cn'
 			lpoly yvar_ xvar_ if over_==`i' [aw=wgt] , gen(`f`cn'') kernel(`kernel') at(rvar) bw(`bw`cn'') nograph degree(`degree')
			replace `f`cn''=0 if `f`cn''<0 
			qui:sum `f`cn'', meanonly		
			if r(max)>`fmax' local fmax = r(max)	

		}

		if "`stack'`stack100'`stream'`stream1'"!="" local fmax=1
		if "`gap0'"=="" local gp=1
		else     {
			local fmax=1
			local gp=0 
		}
		local vm 1

		** only what is needed
		keep if rvar!=.
		
		******************************************************************************************************************* s5: Rescale Densities if necessary
		
		if "`normalize'"!="" {
 			foreach i of local lvl {
				local cnx     = `cnx'+1
				sum  `f`cnx'', meanonly
				replace `f`cnx''=`f`cnx''/r(max)

			}
			local fmax=1
		}
		
		local cnt = `cn'
		local cn = 0
		*** if any of this, then no need to adjust height
		if "`stack'`stack100'`stream'`stream1'"=="" {
			foreach i of local lvl {
				local cn     = `cn'+1
				if "`gap0'"=="" qui: replace `f`cn''=(`f`cn''/`fmax') * `dadj'/`cnt' + 1/`cnt'*(`cnt'-`cn')*`gp'
				if "`gap0'"!="" qui: replace `f`cn''=(`f`cn''/`fmax') 
				tempvar f0`cn'
				gen `f0`cn'' = 1/`cnt' * (`cnt'-`cn') * `gp'        if rvar!=.
			}
		}
		
	
		** s6: Rescale Densities if necessary by graphtype
		****************************
		if "`stack'"!="" {
			local cn 0
			tempvar f00 f0 f01
			gen `f00'=0
			gen `f01'=0
			gen `f0'=0
			foreach i of local lvl {
				local cn_1   = `cn'
				local cn     = `cn'+1
				
				if `cn'>1 {
					qui: replace `f`cn''=`f`cn_1''+`f`cn'' 
					tempvar f0`cn'
					gen `f0`cn'' =`f`cn_1''         if rvar!=.
				} 
			}
		}
		else if "`stack100'"!=""{
			local cn 0
			foreach i of local lvl {
				local cn     = `cn'+1
				local tvlist  `tvlist' `f`cn''
			}
			tempvar total
			egen `total'=rowtotal(`tvlist')
			
			local cn 0
			foreach i of local lvl {
				local cn     = `cn'+1
				replace `f`cn''=`f`cn''/`total'*100
			}

			local cn 0
			tempvar f00 f01 f0
			gen `f00'=0
			gen `f01'=0
			gen `f0'=0
			foreach i of local lvl {
				local cn_1   = `cn'
				local cn     = `cn'+1
				if `cn'>1 {
					qui: replace `f`cn''=`f`cn_1'' +`f`cn''  
					tempvar f0`cn'
					gen `f0`cn'' =`f`cn_1''         if rvar!=.
				}
			}

		}
		tempvar x
		qui:gen `x'=.
		
		if "`stream'`stream1'"!=""{
			if "`stream'"!="" {
				replace `x'=`f`cnt''*.5
				local cn
				foreach i of local lvl {
					local cn = `cn'+1
					replace `f`cn''=`f`cn''-`x'
					replace `f0`cn''=`f0`cn''-`x'
				}	
			}
			if "`stream1'"!="" {
				local cn
				local cnt2 = min(`stream1',`cnt')
				local cnt3 = `cnt2'-1
				if "`half'"=="" 	replace `x'=`f`cnt2''
				if "`half'"!="" 	replace `x'=`f`cnt3''+0.5*(`f`cnt2''-`f`cnt3'')
				foreach i of local lvl {
					local cn = `cn'+1
					replace `f`cn''=`f`cn''-`x'
					replace `f0`cn''=`f0`cn''-`x'					
				}			
			}
		}
		
		
		*******************************************************************************************
		** Text to identify What something is.
		** 1 Not valid if violin or gap0
		if "`text'"=="" & "`gap0'"=="" & "`stack'`stack100'`stream'`stream1'"=="" {
			local cn = 0
			foreach i of local lvl {
				local cn     = `cn'+1
				local lbl: label (over_) `i', `strict'
				if "`right'"=="" local totext `totext' `=`f0`cn''+0.5/`cnt'' `vmin2'  `"`lbl'"'
				else             local totext `totext' `=`f0`cn''+0.5/`cnt'' `vmax2'  `"`lbl'"'
			}
		}	
		** how to write text?
		
		** Auto Legend
		if "`white'`black'"!="" local wb=1
		if "`alegend'"!="" {
			local cn = 1+0`wb'
			
			foreach i of local lvl {				
				local lbl: label (over_) `i', `strict'
				local aleg `aleg' `cn' `"`lbl'"'
				local cn     = `cn'+1+0`wb'
			}
		}
		** colors
		if "`white'`black'"!="" {
			qui:graphquery	color plotregion, default(white)		
			local wbk `r(query)'
		}
		local wcp: word count `colorpalette'
		if `wcp'>0 {
			
			if strpos( `"`colorpalette'"' , ",") == 0 local colorpalette `"`colorpalette' , nograph n(`cnt')"'
			else local colorpalette `"`colorpalette'  nograph n(`cnt')"' 		
			colorpalette `colorpalette'
			** Putting all together
			local cn = 0 
			foreach i of local lvl {
				local cn = `cn'+1
				local ll:word `cn' of `r(p)'

				if "`white'`black'"!="" {					
					local joy `joy' (rarea `f`cn'' `f0`cn'' rvar, color("`wbk'") ///
					fintensity(100) lwidth(none) `horizontal')
				}
				if "`line'"=="" local joy `joy' (rarea `f`cn'' `f0`cn'' rvar, color(`"`ll'"') ///
								`fcolor' `fintensity' `lcolor' `lwidth' `lpattern' `lalign' `lstyle' `horizontal')  
				if "`line'"!="" local joy `joy' (line  `f`cn''  rvar, color(`"`ll'"') ///
								`fcolor' `fintensity' `lcolor' `lwidth' `lpattern' `lalign' `lstyle' `horizontal')  				
				  								
			}
		}
		else if `"`color'"'!="" {
			local cn = 0 
			
			foreach i of local lvl {
				local cn = `cn'+1
				if `cn'<=`:word count `color'' 	local ll:word `cn' of `color'
				if "`white'`black'"!="" {
 					
					local joy `joy' (rarea `f`cn'' `f0`cn'' rvar, color("`wbk'") ///
					fintensity(100) lwidth(none) `horizontal')
				}
				if "`line'"==""  local joy `joy' (rarea `f`cn'' `f0`cn'' rvar,  `lcolor' `lwidth' color(`"`ll'"') ///
								`fcolor' `fintensity' `lcolor' `lwidth' `lpattern' `lalign' `lstyle' `horizontal')  
				if "`line'"!=""  local joy `joy' (line `f`cn''  rvar,  `lcolor' `lwidth' color(`"`ll'"') ///
								`fcolor' `fintensity' `lcolor' `lwidth' `lpattern' `lalign' `lstyle' `horizontal') 
				/*if "`white'`black'"!="" local joy `joy' (rarea `f`cn'' `f0`cn'' rvar, color(`white'`black') ///
								fintensity(100) lwidth(none) `horizontal')  */				
			}
		}
		else {
				local cn = 0 
				local cn2 = 0
				foreach i of local lvl {
				local cn = `cn'+1
				local cn2 = `cn2'+1
				if `cn2'>15 local cn2 = 1
				if "`white'`black'"!="" {
 									
					local joy `joy' (rarea `f`cn'' `f0`cn'' rvar, color("`wbk'") ///
					fintensity(100) lwidth(none) `horizontal')
				}
				if "`line'"=="" local joy `joy' (rarea `f`cn'' `f0`cn'' rvar,  ///
								`fcolor' `fintensity' `lcolor' `lwidth' `lpattern' `lalign' `lstyle'  pstyle(p`cn2') `horizontal') 
				if "`line'"!="" local joy `joy' (line  `f`cn''  rvar,  ///
								`fcolor' `fintensity' `lcolor' `lwidth' `lpattern' `lalign' `lstyle'  pstyle(p`cn2') `horizontal') 	
				/*if "`white'`black'"!="" local joy `joy' (rarea `f`cn'' `f0`cn'' rvar, color(`white'`black') ///
								fintensity(100) lwidth(none) `horizontal') */								
			}			
		}
		***************************************************************************************************************
		if "`alegend'"!="" local leg   legend(order(`aleg'))
		else if strpos( "`options'" , "legend")==0 local leg legend(off)
		else local leg
 		if "`gap0'"!="" | "`stack'`stack100'`stream'`stream1'"!=""  local ylabx 
		else local ylabx ylabel("")
		
		two `joy' (`addplot'), ///
			text(`totext' , `textopt') ///
			`options' `leg' `ylabx' `xlabvio' 

	}
	
	
end