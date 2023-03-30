*! v1 FM - FRA . Histogram with Scatter
* Combining histograms with scatter, and fitline
* Next? Adapt this to either multiple groups
* or using kdensities.

	/*capture program drop sim_marhist 
	capture program drop hist_default
	capture program drop gr_default
	capture program drop fit_parser*/
	
	
	****************************************************************************
	* Sets Defaults for Graph region
	program gr_default, rclass
		syntax, [vertical horizontal Margin(string asis) *]
		
		     if "`margin'" == "" & "`horizontal'" != "" local gr_default `options'
		else if "`margin'" == "" & "`vertical'"   != "" local gr_default `options'
		else if "`margin'" != "" {
			local gr_default margin(`margin') `options'
		}		
		return local gr_default `gr_default' 
		
	end
	
	** format parser
	program format_parser, rclass
		syntax varlist [if]
		gettoken x1 x2:varlist
		
		sum `x1' `if' , meanonly
		local l1 = `r(min)'-(`r(max)'-`r(min)')*.02
		local l2 = `r(max)'+(`r(max)'-`r(min)')*.02
		local yrange range(`l1' `l2')
		* format ylabel
		local x1d=(`r(max)'-`r(min)')/2
		local x1d= max(0,ceil(log10(1/`x1d'+0.0001)))
		
		local x1h=(max(abs(`r(max)'),abs(`r(min)')) )
		local x1h= max(1,ceil(log10(`x1h'+0.0001)))
		local x1h=`x1h'+`x1d'
		
		sum `x2' `if'  , meanonly
		local l1 = `r(min)'-(`r(max)'-`r(min)')*.02
		local l2 = `r(max)'+(`r(max)'-`r(min)')*.02
		local xrange range(`l1' `l2')
 
		local x2d=(`r(max)'-`r(min)')/2
			
		local x2d= max(0,ceil(abs(log10(`x2d')+0.0001)))
			
		local x2h=(max(abs(`r(max)'),abs(`r(min)')) )
		local x2h= max(1,ceil(abs(log10(`x2h')+0.0001)))
		local x2h=`x2h'+`x2d'
		return local fmt1 %`x1h'.`x1d'f
		return local fmt2 %`x2h'.`x2d'f
		return local fmt1x %0`x1h'.`x1d'f
		return local fmt2x %0`x2h'.`x2d'f
		return local xrange `xrange'
		return local yrange `yrange' 
		
	end
	****************************************************************************
	* Setting histogram defaults 
	
	program hist_default, rclass
		syntax, [vertical horizontal  ///
				 graphregion(string asis) ///
				 fysize(string asis) fxsize(string asis)  *]
				
		local default_options
		gr_default, `horizontal' `vertical' `graphregion'
		local default_options graphregion(`r(gr_default)')
		
		if "`vertical'" != "" {
			if "`fxsize'" == "" local default_options `default_options' fxsize(15)
			else local default_options `default_options' fxsize(`fxsize')
		}		
		else if "`horizontal'" != "" {
			if "`fysize'" == "" local default_options `default_options' fysize(15)
			else local default_options `default_options' fysize(`fxsize')
		}
		
		local default_options `default_options' `options'
		return local default_options `default_options' 

	end
	
	**********
	** FIT Parser
	**********
	
	program fit_parser, rclass
        syntax [anything] [aw fw pw iw ], [* fcolor(passthru) lcolor(passthru) pstyle(passthru)]
        if "`anything'"=="" exit
        
        if inlist("`anything'","lfitci","qfitci","fpfitci","lpolyci") {
                return local fitval =2
        }
        else if inlist("`anything'","lfit","qfit","fpfit","lpoly","lowess") {
                return local fitval =1
        }
        else {
                display in red "Not a valid {cmd:fit} option. One can only use lfit qfit fpfit or lpoly (with CI options)"
                error 99
        }
        
        if `"`fcolor'"'=="" & `c(stata_version)'<=14 local fcolor fcolor(*.50)
        if `"`fcolor'"'=="" & `c(stata_version)'>14  local fcolor fcolor(%50)
        
        if `"`lcolor'"'=="" local lcolor lcolor(*1.1)
		if `"`pstyle'"'=="" local pstyle pstyle(p1)
 
        local wgt=subinstr("`exp'","=","",1)
        return local  fitcmd  `anything'
        return local  fitopt  `options' `fcolor' `lcolor' `pstyle'
        return local  fitwgt  `wgt'
        return local  fitewgt [`weight'`exp']

	end

	****************************************************************************
	* Marginal histogram
	* First variable input is Y axis while second is for X axis
	
	program myparser, sclass
		syntax, [*]
		sreturn clear
		local op `options'
		local true 1
		while `true' {
			gettoken i op:op,   bind
			gettoken ii x:i , parse("(")
			if "`i'"=="" {
				local true 0
				break
			}
			else {
				if strlen("`i'")==strlen("`ii'") sreturn local `ii' __self__		
				else {
					smyparser `ii', `i'
					sreturn local `ii' `s(xxxopt)'	
				}
				local listopt `listopt' `ii'
			}	
		}
		sreturn local xxxopt
		sreturn local opt_list `listopt'
		sreturn local org_list `options'
	end
	 program smyparser, sclass
		syntax namelist, [*]
		local nm `namelist' 
		syntax namelist, `nm'(str asis)
		sreturn local xxxopt ``nm''
	end
 

	
	program scatter_parse, rclass
		syntax , [ xtitle(string asis) ytitle(string asis)   *]
		return local xtitle `xtitle'
		return local ytitle `ytitle'
		return local rest   `options'
	end
	
	program sim_marhist, rclass
	syntax varlist(max=2 min=2) [aw iw fw ] [if] [in] ///
	[, ///
			SCATTER_options(string asis) ///
			TWOWAY_options(string asis) ///
			HISTogram_options(string asis) ///
			VHISTogram_options(string asis) ///
			HHISTogram_options(string asis) ///
			fit(str asis) ///
			xtitle(string asis) ///
			ytitle(string asis) ///
			scheme(passthru) * /// <- Rest will be two way option
			] 

	gettoken x1 x2:varlist 
	marksample touse
	

	qui {
		** CrossCheck. Cant mix histogram with vhistogram hhistogram
		if "`vhistogram_options'`hhistogram_options'" != "" & ///
			"`histogram_options'" != "" { 
			display in red "Error. You cannot combine histogram option with vhistogram or hhistogram"
			error 123
		}
		
		tempname main his1 his2
		
		* If no y and x title provided then use variable labels
		if missing("`ytitle'") local ytitle "`: variable label `x1''"
		if missing("`xtitle'") local xtitle "`: variable label `x2''"
		
		** format range and 
		format_parser `x1' `x2' if `touse'
        local fmt1 `r(fmt1)'
		local fmt2 `r(fmt2)'
		local fmt1x `r(fmt1x)'
		local fmt2x `r(fmt2x)'
		local xrange `r(xrange)'
		local yrange `r(yrange)'
		
		* Fit parser
		** check fit options
		fit_parser `fit'
		local fitcmd `r(fitcmd)'
		local fitval `r(fitval)'
		local fitwgt `r(fitewgt)'
			
		/*
		ylabel(`ylabel', format(`fmt1') ) ///
			xlabel(`xlabel', format(`fmt2') ) ///
			yscale(`yscale' `yrange' ) ///
			xscale(`xscale' `xrange' ) ///
	    */
		
		if !missing(`"`fit'"') local tofit `fitcmd' `x1' `x2' if `touse' `fitwgt', `fitopt'
		
			twoway 	(scatter `x1' `x2' [`weight'`exp'] if `touse', `scatter_options' ) ///
					(`tofit') 		, ///
			legend(off) `twoway_options' ///
			xscale( `xrange') yscale( `yrange') ///
			xlabel(, format(`fmt2')) ///
			ylabel(, format(`fmt1')) ///
			name(`main') nodraw `scheme'
		/*
		ytitle(`ytitle', width(50)) ///
			xtitle(`xtitle', width(20)) ///
		*/
		
		* Histograms - Horizontal(X-axis) & vertical (Y-axis)
		
		if "`weight'" != "" local w2 fw
		hist_default , horizontal `histogram_options' `hhistogram_options'
		histogram 	`x2' [`w2'`exp'] if `touse', /// <- Main Histogram
					xscale( off `xrange'  ) yscale(noline ) ///
					xlabel(  , nogrid labcolor(%0) tlcolor(%0) ) ///
					ylabel( ,  nogrid labcolor(%0) tlcolor(%0) format(`fmt2x') )  ///
					ytitle(`ytitle') ytitle(, color(%0)) ///
					`r(default_options)'  /// <- this may need changing, so peope can choose Different widths.
					name(`his1') nodraw `scheme'
			
		hist_default , vertical `histogram_options' `vhistogram_options'	
		histogram 	`x1' [`w2'`exp'] if `touse', ///
					yscale(off  `yrange') xscale(noline  ) ///
					ylabel( , nogrid labcolor(%0) tlcolor(%0) ) ///
					xlabel(, nogrid labcolor(%0) tlcolor(%0) format(`fmt1x'))  ///
					xtitle(`xtitle')   ///
					xtitle(, color(%00)) ///
					`r(default_options)' ///
					name(`his2') nodraw horizontal  `scheme'
		
		* Combining the plots
		graph  combine `his1' `main' `his2', hole(2) imargin(0 0 0 0) `options'   `scheme'  
	} 
	return local cmd sim_marhist
	return local cmdline sim_marhist `0'
	end 
 