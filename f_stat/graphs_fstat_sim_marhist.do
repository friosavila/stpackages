
	capture program drop sim_marhist 
	capture program drop hist_default
	capture program drop gr_default
	// Sets Defaults for Gregion
	program gr_default, rclass
		syntax, [vertical horizontal Margin(string asis) *]
		
		     if "`margin'"=="" & "`horizontal'"!="" local gr_default margin(l=16) `options'
		else if "`margin'"=="" & "`vertical'"  !="" local gr_default margin(l=-5 b=15 t=-5) `options'
		else if "`margin'"!="" {
			local gr_default margin(`margin') `options'
		}		
		return local gr_default `gr_default' 
	end
	
	program hist_default, rclass
		syntax, [vertical horizontal  ///
				 graphregion(string asis) ///
				 fysize(string asis) fxsize(string asis)  *]
				
		local default_options
		gr_default, `horizontal' `vertical' `graphregion'
		local default_options graphregion(`r(gr_default)')
		
		if "`vertical'"!="" {
			if "`fxsize'"=="" local default_options `default_options' fxsize(15)
			else local default_options `default_options' fxsize(`fxsize')
		}		
		else if "`horizontal'"!="" {
			if "`fysize'"=="" local default_options `default_options' fysize(15)
			else local default_options `default_options' fysize(`fxsize')
		}
		local default_options `default_options' `options'
		return local default_options `default_options' 

	end
	* Marginal histogram
	program sim_marhist
	syntax varlist(max=2 min=2) [aw ] [if] [in], [SCATTER_options(string asis) ///
	HISTOGRAM_options(string asis) ///
	VHISTOGRAM_options(string asis) ///
	HHISTOGRAM_options(string asis) ///
	scheme(passthru) * /// <- Rest will be two way option
	] 

	gettoken x1 x2:varlist 
	marksample touse

	qui {
		** CrossCheck. Cant mix histogram with vhistogram hhistogram
		if "`VHISTOGRAM_options'`HHISTOGRAM_options'"!="" & ///
		"`HISTOGRAM_options'"!="" { 
			display in red "Error. You cannot combine Histogram options with vhistogram or hhistogram"
			error 123
		}
		
		tempname main his1 his2
		scatter `x2' `x1' [`weight'`exp'] if `touse', ///
		graphregion(margin(t=-5)) name(`main') nodraw ///
		`scatter_options'  `scheme'
		if "`weight'"!="" local w2 fw
		hist_default , horizontal `histogram_options' `hhistogram_options'
		histogram `x1' [`w2'`exp'] if `touse', /// <- Main Histogram
			yscale(off) xscale(off) ylabel(, nogrid) xlabel(, nogrid) ///
			`r(default_options)'  /// <- this may need changing, so peope can choose Different widths.
			name(`his1') nodraw `scheme'
			
		hist_default , vertical `histogram_options' `vhistogram_options'	
		histogram `x2' [`w2'`exp'] if `touse', ///
			yscale(off) xscale(off) ylabel(, nogrid) xlabel(, nogrid) ///
			`r(default_options)' ///
			name(`his2') nodraw horizontal  `scheme'
		
		graph  combine `his1' `main' `his2', hole(2) `options'   `scheme'
	} 

	end 

	// Simple structure for Scatter over
	program drop scatter_over
	program scatter_over
	syntax varlist(max=2 min=2) [aw ] [if] [in], [over(varlist) scheme(passthru)  ] 
	gettoken x1 x2:varlist 
	marksample touse
	markout `touse' `over'
	
	qui:levelsof `over', local(lover)
	local cnt:word count "`lover'"
	
	if `cnt'<=15 {
		foreach i of local lover {
			local jj = `jj'+1
			local toplot `toplot' (scatter `x1' `x2' if `over'==`i', pstyle(p`jj') )
		}
	}
	two `toplot'
	end 
 
	 program drop histogram_over
		program histogram_over
		syntax varlist(max=1 min=1) [aw ] [if] [in], [over(varlist) scheme(passthru)  ] 
		gettoken x1 x2:varlist 
		marksample touse
		markout `touse' `over'
		
		qui:levelsof `over', local(lover)
		local cnt:word count "`lover'"
		
	 
		sum `x1', meanonly
		local nn = ceil(log(r(N))*10/log(10))
		local minn = r(min)
		local maxn = r(max)
		local wd   = (`maxn'-`minn')/(`nn')
		
		if `cnt'<=15 {
			foreach i of local lover {
				local jj = `jj'+1
				local toplot `toplot' (histogram `x1' `x2' if `over'==`i', pstyle(p`jj') color(%50) width(`wd') start(`minn'))
			}
		}
		two `toplot'
		end 
	* Loading sysuse auto for testing
	sysuse auto, clear

	* Testing: 

	* Testing by using custom scheme
	sim_marhist price mpg, scheme(white_tableau)
		* -> The scheme is not being applied on the plot
		* -> Possible solution: need to add `options' to each scatter and histogram command?
		* -> Solution works but may possibly not work effectively
		*~-> We can add it as explicit option in the program definition. 
	
	* Testing by adding titles to plot
	sim_marhist price mpg, scheme(white_tableau) title("Testing out the command")
		* -> If we add `options' to each plot that duplicates titles 3 times
		* -> Works fine if we remove `options' from each scatter and histogram 
		*~-> Good call. "Options" should be only for the Combined graph
	
	* Testing to change scatterplot colors
	sim_marhist price mpg, scheme(white_tableau) scatter(mcolor(red)) ///
		hhistogram(color(yellow)) ///
		vhistogram(color(green))
		* -> Histogram color is applied to both plots. Maybe we can try and give option for different colors
		*~-> So that hcolor (for horizontal) and vcolor(for vertical?) perhaps options vhistogram and hhistogram. when applied to each color
		* -> Maybe also consider using different colors by groups on scatter as well by group?
		*~-> This isnt as straigh forward. We could first write an alternative histogram command. 
		*    -mhistogram- that plots Multiple histograms by group. Then use that instead of histogram.
		*    then, it can be combined with mscatter
		
	* Testing alignment of side plots
	  
		* -> I could be wrong here but maybe we need to slightly tweak the starting
		*	 point of the side plot to begin where from where scatter starts
		*~-> Agreed. This is tricky. Right now, margins for the subplots (histograms) are defined excplicity
		*    and trying to set a code to modify them within the program is not straight forward. (what values to use may depends on case to case.)
		*    try for example: webuse dui
		*    sim_marhist citations fines. 
		*    Figure is slighly off.
		
		* -> Maybe we can also reduce distance of side plot on Y-axis from the graph region
		* 	 to make it consistent with one appearing on the x-axis?
		*~-> This goes with the previous point. Choosing the right values may be tricky. Perhaps "Keep" what u use as default
		*    but allow for it to change.
