*program radial_i

** get initial
capture program drop radial_i
program radial_i
	syntax anything , [ type(int 1) ///
					 nobs(int 50) ///
					 BASE BASE1(str asis) ///
					  nblanks(numlist >=0 integer max=1) ///
					  lmax(numlist >=0 max=1) ///
					  mtitle(string asis) ///
                      textsize(string asis) ///
					  legopt(string asis) * ]
					  * Overbar for titles

** get basic coordinates
	numlist "`anything'", range(>0)
	local lval `r(numlist)'
	
	preserve
	clear
	*local type 1
	if "`base'"!="" & `"`base1'"'=="" local base1 gs15
	
	local i0  0`nblanks'
	local lmax `lmax'  

	if `type'==2 range r 0 (2*_pi)   `nobs'  //<-- full circle
	if `type'==1 range r 0 (1.5*_pi) `nobs'  //<== 3/4 
	qui:replace r=-r
	*tempvar overbar 
	*gen `overbar'=runiformint(1,10)
	** Input What values

	** input max

	** altmax
	if "`lmax'" == "" {
		foreach i of local lval {
			if "`lmax'"=="" local lmax =`i'
			else local lmax = max(`lmax',`i')
		}
		local torn= ceil(log10(`lmax'+1))-2
		if `torn'==0 local torn =1

		local lmax= ceil(`lmax'/(10^`torn'))*(10^`torn')
	}
	** if less than 100, Round up 10, other roundup 10^-1

	foreach i of local lval {
		local lvals `lvals' `=`i'/`lmax''
	}
	local lval `lvals'
	*** counting how many groups will be plotted
	local nn:word count `lval'

	*** Number of Blank lines (to cover center)

	local inch =  1.2/(`nn'+`i0')
	*** Determine Radious

		local i =`i0'
		foreach ii in `lval' {
			local i = `i'+1 // <-- pointer in graph
			local j = `j'+1  // <-- pointer on var
			** Starts from i0+1 (See up)
			local r `=(2*`i'-1)/(2*(`nn'+`i0'))'
			** x  y  marks value bar
			** x0 y0 marks value for GREY. <- Optional
			gen x_`j'  =`r'*cos(r*`ii'+0.5*_pi)
			gen y_`j'  =`r'*sin(r*`ii'+0.5*_pi)
			gen x_0`j'=`r'*cos(r+0.5*_pi)
			gen y_0`j'=`r'*sin(r+0.5*_pi)
		}
		
	*** GREY bars	
		if "`base'`base1'"!="" {
			if "`base1'"=="" local base1 gs14
			local i 
			local nb
			foreach ii in `lval' {
				local i = `i' +1
				local nb= `nb'+1
				local toline `toline' (line y_0`i' x_0`i', lwidth(`inch'in) color("`base1'"))
			}	
		} 
	** Actual bars
		local i
		local j
		foreach ii in `lval' {
			local i = `i'+1		
			local j = `j'+1		
			** grstyle
			if `j'>15 local j=1
			qui:graphquery color p`j'
			local mycolor `r(query)'
			local toline2 `toline2'  (line y_`i' x_`i', lwidth(`inch'in) color("`mycolor'"))
		} 	

	** Labels if type 2	
	if `type'==1 {
		local i
		** Many options. 1 using label. Adds nothing
		** label with numbers. Add Avg at 1 decimal?
		** label with numbers. how to add meaning? (hrs?)
		foreach ii in `lval' {
			local i = `i'+1		
			local mylabel:word `i' of `mtitle'
			*local mylabel:label (`overbar') `i', strict
			** Always on the left and on top. Consider adding Totals. Where to get Label?
			local tosct `tosct'  `=y_`i'[1]' 0 (9) `"`mylabel'"'
		}
	}
		
	***	use legend instead of label. Option 1
	if `type'==2 {
		local i `=`nb'+1'
		** Many options. 1 using label. Adds nothing
		** label with numbers. Add Avg at 1 decimal?
		** label with numbers. how to add meaning? (hrs?)
		foreach ii in `lval' {
			local i = `i'+1	
			local mi = `mi'+1
			local mylabel:word `mi' of `mtitle'
			** Always on the left and on top. Consider adding Totals. Where to get Label?
			local mylegend   `i' `"`mylabel'"' `mylegend'
 
		}

	}	

	*** Points
	if `type'==2 {
		** need 4 points
		local p1:display %5.1g `=`lmax'/4'
		local p2:display %5.1g `=`lmax'/4*2'
		local p3:display %5.1g `=`lmax'/4*3'
		local p4:display %5.1g `=`lmax'/4*4'
	}

	if `type'==1 {
		** need 3 points
		local p1:display %5.1g `=`lmax'/3'
		local p2:display %5.1g `=`lmax'/3*2'
		local p3:display %5.1g `=`lmax'/3*3'
	}

	** Plot lines

	if `type'==2 {
		range e 0 (2*_pi) 9
		local r1 `=(2*`i0')/(2*(`nn'+`i0'))'
		forvalues i = 1/8 {
			local todraw `todraw' `=`r1'*cos(e[`i'])' `=`r1'*sin(e[`i'])' `=cos(e[`i'])' `=sin(e[`i'])'
		}
	}
	if `type'==1 {
		range e 0 (1.5*_pi) 7
		local r1 `=(2*`i0')/(2*(`nn'+`i0'))'
		forvalues i = 1/7 {
			local todraw `todraw' `=`r1'*cos(e[`i'])' `=`r1'*sin(e[`i'])' `=cos(e[`i'])' `=sin(e[`i'])'
		}
	}

	if `type'==2 {
		two `toline' (pci `todraw', lwidth(0.1) pstyle(p1) lcolor(*1.5)) `toline2' ///
		(scatteri 0    1.0  (3) "`p1'" ///
				 -1.0  0     (6) "`p2'" ///
				  0   -1.0  (9) "`p3'" ///
				  1.0  0     (12) "`p4'", mlabsize(`textsize') msymbol(none) ) 	 , ///
		yscale(range(-1.1 1.1)) xscale(range(-1.1 1.1)) aspect(1)  ///
		xlabel("") ylabel("") legend(order(`mylegend') `legopt' ) `options' ///
		
	}

	if `type'==1 {
		two `toline' (pci `todraw', lwidth(0.1) pstyle(p1) lcolor(*1.5)) `toline2' ///
		 (scatteri `tosct', `sctopt' msymbol(none) `legopt' ) ///
			(scatteri 1    0  (12) "0" ///
				  0    1.0  (3) "`p1'" ///
				 -1.0  0     (6) "`p2'" ///
				  0   -1.0  (9) "`p3'" , mlabsize(`textsize') msymbol(none)) ,  ///
		yscale(range(-1 1)) xscale(range(-1 1)) aspect(1)   ///
		xlabel("") ylabel("")  `options' legend(off) 
	}

	restore
end
	
	
	