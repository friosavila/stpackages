import delimited "https://raw.githubusercontent.com/tidyverse/ggplot2/master/data-raw/mpg.csv", clear

  egen total = group(cty hwy)
  bysort total: egen count = count(total)

  * Using loop to write and store the plotting commands and syntax by class
  
  twoway  (scatter hwy cty [aw = count], mcolor(%60) mlwidth(0) msize(1) legend(off)) ///
    (lfit hwy cty), legend(off) name(main, replace) ytitle("Highway MPG") xtitle("City MPG") ///
    graphregion(margin(t=-5))
  twoway  (histogram cty, yscale(off) xscale(off) ylabel(, nogrid) xlabel(, nogrid) bin(30)), name(cty_hist, replace) graphregion(margin(l=16)) fysize(15)
  twoway  (histogram hwy, horizontal yscale(off) xscale(off) ylabel(, nogrid) xlabel(, nogrid) bin(30)), name(hwy_hist, replace) graphregion(margin(b=15 t=-5)) fxsize(20)
  
  graph  combine cty_hist main hwy_hist, hole(2) commonscheme scheme(white_tableau)   ///
    title("{bf}Marginal Histogram - Scatter Count plot", size(2.75) pos(11)) subtitle("mpg: Highway vs. City Mileage", size(2.5) pos(11))  
	
program drop 	sim_marhist
program sim_marhist
	syntax varlist(max=2 min=2) [aw ] [if] [in], [SCATTER_options(string asis) ///
						 HISTOGRAM_options(string asis) *	///<- Rest will be two way option
						 ] 
	gettoken x1 x2:varlist	
	marksample touse
	qui {
		tempname main his1 his2
		scatter `x2' `x1' [`weight'`exp'] if `touse', ///
		graphregion(margin(t=-5)) name(`main') nodraw ///
		`scatter_options'
		if "`weight'"!="" local w2 fw
		histogram `x1' [`w2'`exp'] if `touse', yscale(off) xscale(off) ylabel(, nogrid) xlabel(, nogrid) ///
		`histogram_options' graphregion(margin(l=16)) fysize(15) name(`his1') nodraw
		histogram `x2' [`w2'`exp'] if `touse', yscale(off) xscale(off) ylabel(, nogrid) xlabel(, nogrid) ///
		`histogram_options' graphregion(margin(b=15 t=-5)) fxsize(15) name(`his2') nodraw horizontal
		graph  combine `his1' `main' `his2', hole(2) `options'
	}					 
end	
program drop sim_markden
program sim_markden
	syntax varlist(max=2 min=2) [aw ] [if] [in], [SCATTER_options(string asis) ///
						 KDENSITY_options(string asis) AREA_options(string asis) *	///<- Rest will be two way option
						 ] 
	gettoken x1 x2:varlist	
	marksample touse
	qui {
		tempname main his1 his2
		scatter `x2' `x1' [`weight'`exp'] if `touse', ///
		graphregion(margin(t=-5)) name(`main') nodraw ///
		`scatter_options'
		if "`weight'"!="" local w2 fw
		tempvar xx1 xx2 dd1 dd2
		kdensity `x1' [`weight'`exp'] if `touse', nodraw `kdensity_options' generate(`xx1' `dd1')
		kdensity `x2' [`weight'`exp'] if `touse', nodraw `kdensity_options' generate(`xx2' `dd2')
		
		two area `dd1' `xx1', yscale(off) xscale(off) ylabel(, nogrid) xlabel(, nogrid) ///
		 graphregion(margin(l=16)) fysize(15) name(`his1') nodraw `area_options'
		two area `dd2' `xx2' , yscale(off) xscale(off) ylabel(, nogrid) xlabel(, nogrid) ///
		  graphregion(margin(b=15 t=-5)) fxsize(15)name(`his2') nodraw horizontal `area_options' 
		graph  combine `his1' `main' `his2', hole(2) `options'
	}					 
end	

sim_marhist hwy cty [aw=count], title("{bf}Marginal Histogram - Scatter Count plot", size(2.75) pos(11)) subtitle("mpg: Highway vs. City Mileage", size(2.5) pos(11)) scatter( ytitle("Highway MPG") xtitle("City MPG") mfcolor(%50) )

*** Correlogram
sysuse auto, clear
corr_gram price mpg trunk weight length turn foreign , aspect(1)

program drop corr_gram
program corr_gram
	syntax varlist [aw iw fw] [if] [in], [*] [colorpalette(string asis) sizeadj(real 3) msymbol(passthru)] 
	marksample touse
	//s1 corr
	qui:corr `varlist' [`weight'`exp'] if `touse'
	tempname mycorr 
	matrix `mycorr' = r(C)
	local cols = colsof(`mycorr')
	// get names -> may be mnames
	forvalues i = 1/`cols' {
		if `i'<`cols' {
			local lby `lby' `i' "`:word `i' of `varlist''"
		}
		if `i'>1 {
			local lbx `lbx' `i' "`:word `i' of `varlist''"
		}
	}
	
	// make correlogram
	if "`colorpalette'"=="" local colorpalette red white blue
	colorpalette `colorpalette', n(9) nograph
	local mlcol  "`r(p)'"
	
	forvalues j = 1/`=`cols'-1' {
		forvalues i = `=`j'+1'/`cols' {
			corr_class, val(`=`mycorr'[`i',`j']')
			local size =`s(sclass)'*`sizeadj'
			local color `r(p`s(cclass)')'
			local toscatter `toscatter' ///
				(scatteri `j' `i' "`:display %3.2f `mycorr'[`j',`i']'", ///
				mlabposition(0) msize(`size') color("`color'") `msymbol')
		}	
	}
	two `toscatter', xlabel(  `lbx'   ) ///
				     ylabel( `lby'  ) legend(off) ///
					 xtitle("") ytitle("") ///
					 xscale(range(1.5 `=`cols'+.5')) ///
					 yscale(range(0.5 `=`cols'-.5')) `options'
end
 program corr_class, sclass
	syntax, [val(real 0.0)]
	if inrange(`val',-1,-7/9) local cc = 1
	else if inrange(`val',-7/9,-5/9) local cc = 2
	else if inrange(`val',-5/9,-3/9) local cc = 3
	else if inrange(`val',-3/9,-1/9) local cc = 4
	else if inrange(`val',-1/9,1/9) local cc = 5
	else if inrange(`val',1/9,3/9) local cc = 6
	else if inrange(`val',3/9,5/9) local cc = 7
	else if inrange(`val',5/9,7/9) local cc = 8
	else if inrange(`val',7/9,1) local cc = 9
	sreturn local cclass = `cc'
	sreturn local sclass = abs(`cc'-5)+1
end
