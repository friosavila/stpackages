** Need to make Colors easier.
** and Separate Colros for RBAR from RAREA

*! v1.32 by FRA fix wide and adds update
* v1.31 by FRA fix for varabbref
* v1.3 by FRA adds more control and transform data
* v1.2 by FRA Adjusts Labels
* v1.11 by FRA Sorts
* v1.1 by FRA allows Extra Adjustment
* v1.01 by FRA allows for NO coordinates
* Think about Floor adjustment
/*capture program drop encode2
capture program drop sankey_plot
capture program drop easter_egg
capture mata:mata drop encode2()
capture program drop get_coordinates
capture program drop adjust_coordinates
capture program drop colorpalette_parser
capture program drop label_adjust
capture program drop change_names
capture program drop extra_adj
capture program drop sankey_i2
capture program drop sankey_wide
capture mata mata  drop sdlong()*/

program sankey_plot
	syntax anything(everything), [* wide tight update]
	varabbrev  {
		if `c(stata_version)'<16 {
			display "You need Stata 16 or higher to use this command"
			error 9
		}
		
		if "`update'"!="" {
			ssc install sankey_plot, replace
			capture:program drop sankey_plot
		}
		if "`wide'"!="" {
			sankey_wide `anything', `tight' `options'
		}
		else {		
			sankey_i2 `anything', `options'	 
		}
		
	}
	if runiform()<0.001 {
		easter_egg
	}
end



program sankey_wide
	syntax varlist (min=2) [if] [in],  [width(varname) tight  ///
										newframe(name) drop *]
	if "`newframe'"=="" tempname newframe
	capture frame `drop' `newframe'
	*display "`varlist' `width'  `label0' `label1' `if' `in'"
	frame put `varlist' `width'  `label0' `label1' `if' `in', into(`newframe')
		qui:frame `newframe':{
		if "`width'"=="" {
			tempname width
			gen byte `width'=1
		}
 		foreach i in `varlist' {
			local cnt = `cnt'+1
			** is numeric
			capture confirm  numeric var `i'
			if _rc!=0 {
				clonevar xx`cnt'=`i'				
			}
			else {
				if "`:variable label `i''"!="" {
					decode `i', gen(xx`cnt')
				}
				else {
					tostring `i', gen(xx`cnt')
				}
			}		
			local vlist  `vlist' xx`cnt'
		}
 		
		 
		*qui:recast str100 `vlist'
		local fcnt=`cnt'-1
		gen __id=_n
		expand `fcnt'
		bysort __id:gen _x0=_n
		gen _x1=_x0+1
		gen touse=_x0==1
		*local vlist var1 var2 var3 
		foreach  i in `vlist'  {
			local v1 `v2' `i'
			if `:word count `v1''==2 {
				local v2 `i'
				local cnt = `cnt'+1
				local fvlist `fvlist' `v1' 
			}
			else local v2 `i'
		}
		sort _x0 __id
		mata:sdlong("`fvlist'","touse")
		ren xx1 _y0
		ren xx2 _y1
		qui:compress
		if "`tight'"!="" {
			tempvar wt
			bysort _x0 _x1 _y0 _y1:egen `wt'=sum(`width')
			replace `width'=`wt'
			keep _x0 _x1 _y0 _y1 `width' 
			duplicates drop
		}
		keep _x0 _x1 _y0 _y1 `width' 
		sankey_i2 _x0 _y0 _x1 _y1 , width0(`width') `options' extra adjust 
	}
end

mata:

void sdlong(string scalar fvlist,touse){
	string matrix a, a1, a2
	real matrix sel
	a=st_sdata(.,fvlist,touse)
	sel=J(1,cols(a)/2,(1,0))
	a1=vec(select(a,sel))
	sel=J(1,cols(a)/2,(0,1))
	a2=vec(select(a,sel))
	//*a1,a2
	st_sstore(.,tokens(fvlist)[(1,2)],(a1,a2))

}
end



program encode2
	syntax varlist, prefix(name)
	foreach i in `varlist' {
		qui:gen `prefix'`i'=.
		if "`lbvlist'"=="" local lbvlist `prefix'`i'
		local nvlist `nvlist' `prefix'`i'
	}
	mata:encode2("`varlist'","`nvlist'")
	label values `nvlist' `lbvlist'
end

mata:
 
void encode2(string scalar vlist, nvlist) {
	string matrix a, b
	real matrix d
	real scalar i
	a=st_sdata(.,vlist)
	b=uniqrows(vec(a))
	
	d=J(rows(a),cols(a),0)
	for(i=1;i<=rows(b);i++) {
		d=d:+i*(a:==b[i])
	}
	st_store(.,tokens(nvlist),d)
	
	st_vlmodify(tokens(nvlist)[1], (1::rows(b)), b)
	
}
end

program get_coordinates, rclass
	syntax , [n(int 1)]
	** This just Gets pair of coordinates at `n'
	** Also Gets the Upper and lower widths 
	** Returns them as locals
	/*
	-----\_
wd0        \
	----\   \
	     \   \---
		  \  
		   \       wd1
		    \----
	
	*/
	
 
	
	return local x0 = x0_[`n']
	return local y0 = y0_[`n']
	return local x1 = x1_[`n']
	return local y1 = y1_[`n']
	
	return local wd0 = w0_[`n']
	return local wd1 = w1_[`n']
	
end

program adjust_coordinates, sortpreserve
	syntax [if]
	*sum `width0' `width1'
	tempvar sort
	gen `sort' = _n
	tempvar yy0 yy1
	clonevar `yy0' = y0_ `if'
	clonevar `yy1' = y1_ `if'
	tempvar tw0 tw1
	** Total width by group
	bysort `yy0' x0_ (`yy1' `sort' ):egen `tw0'=sum(w0_) `if'
	bysort `yy1' x1_ (`yy0' `sort' ):egen `tw1'=sum(w1_) `if'
	** Ajdust coordinates so that Y0 and Y1 are centered
	*sort `yy0' `yy1'
 	bysort `yy0' x0_ (`yy1'  `sort' ): replace y0_=y0_-`tw0'*.5+sum(w0_)-w0_/2 `if'
	bysort `yy1' x1_ (`yy0'  `sort' ): replace y1_=y1_-`tw1'*.5+sum(w1_)-w1_/2 `if'

end

program colorpalette_parser, rclass
	syntax [anything(everything)], [nograph * n(string asis) opacity(passthru)]
	return local clp   = `"`anything', `options'"'
	return local clpop = `"`anything', `options' `opacity'"'
end

program easter_egg
	display in w "{p}Surprised!, you have been selected to see this message!" ///
				  "Which means you are lucky!. {p_end}"  ///
				  "{p}Well, perhaps lucky is too much of a stretch, since this is" ///
				  " just me, rumbling around on this secret message. Nevertheless" ///
				  "If you see this, and makes you laugh, send me a message or post it on twitter!{p_end}" ///
				  "This message has been brought to you by me. F.R.A"				  
end

program label_adjust, 
	syntax , [ adjust colorpalette(str asis)]
	
	qui: sum y0_, meanonly
	local ymax = r(max)
	qui: sum y1_, meanonly
	local ymax = max(r(max),`ymax')
	** FLIPS Y axis
	qui:replace y0_=1+`ymax'-y0_
	qui:replace y1_=1+`ymax'-y1_
	
 
	** This is for linking
	tempvar id t
	gen `id'=_n
	
	** This Decides if we ADJUST with SUM weights or max weight
	if "`adjust'"!="" {
		tempvar ww0 ww1
		bysort x0_ y0_:egen `ww0'=sum(w0_)
		bysort x1_ y1_:egen `ww1'=sum(w1_)
	}
	else {
		tempvar ww0 ww1
		bysort x0_ y0_:egen `ww0'=max(w0_)
		bysort x1_ y1_:egen `ww1'=max(w1_)
	}	
	***
 	
	expand 2
	bysort `id':gen `t'=_n
	sort `id' `t'
	by `id':replace x0_    =x1_[1] if `t'==2
	by `id':replace y0_    =y1_[1] if `t'==2
	by `id':replace oy0_    =oy1_[1] if `t'==2
	by `id':replace `ww0'   =`ww1'[1] if `t'==2
 
	** fixes labels if different
	by `id':replace lb0_=lb1_[1] if `t'==2
	
	** What does this do? This is what is used to "adjust colors of bars"
	tempvar w12
	bysort x0_ y0_:egen `w12'=max(`ww0')
	** This Keeps Original data plus The one for x1 y1 last
	tempvar flag2
	bysort x0_ y0_ (`t'):gen `flag2'=_n==1
	keep if `t'==1 | `flag2'==1

	
	sort `t' _sort
	tempname fr2
	gen _id=_n
 
	frame  put x0_ y0_ oy0_ `w12' lb0_ col_ ps_ `t', into(`fr2')
	
	frame `fr2':{
		** Necessary for smaller dataset
		gen x_or_ =x0_
		gen y0_max_=y0_+`w12'*.5
		gen y0_min_=y0_-`w12'*.5
		gen y0_cnt_=y0_
		
		*duplicates drop Manual way
		tempvar nn
 		bysort x0_ y0_cnt_:gen `nn'=_n
		keep if `nn'==1
		gen lb0b_=lb0_
		** Id for FR2
		gen _id=_n
		** Counts number of Uique groups
		count 
		local kN = r(N)
		qui:sum x0_, meanonly
		count if x0_<`r(max)'
		local oN = r(N)
		** Necessary. If no color selected, Colorpalette should fill it in.
		** 1 per type
		
		qui:count if ps_!="" | col_!=""
		if `r(N)'==0 {
			gen colb_=""
			gen colo_=""
			gen psb_ =""
**# Bookmark #1: Check		 

			if `"`colorpalette'"'!="" {
				colorpalette_parser `colorpalette'
				colorpalette `r(clp)' nograph n(`oN')
				local cnt=0
				forvalues i = 1/`kN' {
					local cnt=`cnt'+1
					if `cnt'>`oN' local cnt =1
					replace colb_=`""`r(p`cnt')'""' in `i'
				}
				colorpalette_parser `colorpalette'
				colorpalette `r(clpop)' nograph n(`oN')
				local cnt=0
				forvalues i = 1/`kN' {
					local cnt=`cnt'+1
					if `cnt'>`oN' local cnt =1
					replace colo_=`""`r(p`cnt')'""' in `i'
				}
			}		
			else {
				forvalues i = 1/`kN' {
					local cnt=`cnt'+1
					if `cnt'>`oN' | `cnt'>15 local cnt=1
					replace psb_="p`cnt'" in `i'
				}
			}
			replace col_=colb_
			replace ps_=psb_
		}
		else {
			capture: gen psb_=ps_
			capture: gen colb_=col_	
			capture: gen colo_=col_
		}
		
		drop y0_
		tempname fr3
		*list col_ colb_ psb_
		*gen lb0b_=lb0_
		frame put x0_ oy0_ y0_cnt_ psb_ colb_ colo_ lb0b_, into(`fr3')
		*frame `fr3'	:list
	}
	
	frlink 1:1 _id , frame(`fr2')
	frget x_or_ y0_max_ y0_min_ y0_cnt_ colb_ psb_ lb0b_ , from(`fr2')
	
	sort `t' `id'
	capture confirm frame `fr3'
	
	if _rc==0 {
		frlink m:1 x0_ oy0_, frame(`fr3')
		frget colx_=colo_ psx_=psb_, from(`fr3')
		qui:count if col_!=""
		if `r(N)'==0  replace col_ = colx_
		qui:count if ps_!=""
		if `r(N)'==0  replace ps_ = psx_
	}
	qui:gen _or = `t'==1
	sort _id
	*noisily list x0_ y0_ x1_ y1_ col_ 
	*list x0_ y0_ x1_ y1_ col_ 
	*display "asdasd"
	
end

 
*!! Breakdown into smaller dataset
* 1 for the plots 1 for scatter and names.

program change_names
	syntax, [xy(varlist) color(varname) pstyle(varname) w0(varname) w1(varname) lb0(varname) lb1(varname) ]
	
		gettoken x0 rest:xy
		gettoken y0 rest:rest
		gettoken x1 rest:rest
		gettoken y1 rest:rest
		ren `x0' x0_
		ren `x1' x1_
		ren `y0' y0_
		ren `y1' y1_
		** Are variables numeric?
		local labflag=0
		capture:confirm numeric variable y0_ y1_
		if _rc!=0 {
			ren y0_ lb0_
			ren y1_ lb1_
			encode2 lb0_ lb1_, prefix(x)
			ren xlb0_ y0_
			ren xlb1_ y1_
			local labflag = 1
		}
		
		gen oy0_=y0_
		gen oy1_=y1_
		if "`color'"!=""  ren `color'  col_
		else gen col_=""
		if "`pstyle'"!="" ren `pstyle' ps_
		else gen ps_=""
		if "`w0'"!=""     ren `w0'     w0_
		else gen w0_=0.01
		if "`w1'"!=""     ren `w1'     w1_
		else gen w1_=w0
		if `labflag'==0 {
			if "`lb0'"!=""    ren `lb0'    lb0_
			else gen lb0_=""
			if "`lb1'"!=""    ren `lb1'    lb1_
			else gen lb1_=""
		}
end

program extra_adj
	syntax, gap(numlist >0)
	tempname new
	frame put  x0_ y0_ x1_ y1_ w0_ w1_, into(`new')
	frame `new': {
		tempvar aux1 aux0
		bysort x0_ :egen `aux0'=sum(w0_)
		bysort x1_ :egen `aux1'=sum(w1_)
		sum `aux0', meanonly
		local auxmax=r(max)
		sum `aux1', meanonly
		local auxmax=max(`=r(max)',`auxmax')
		
		local delta = `auxmax'*`gap'
		bysort x0_ y0_:egen t0=sum(w0_)
		bysort x1_ y1_:egen t1=sum(w1_)
		gen id=_n
		
		expand 2
		bysort id:gen t=_n
		sort id t
		by id:replace x0_=x1_[1] if t==2
		by id:replace y0_=y1_[1] if t==2
		by id:replace t0=t1[1] if t==2
		bysort x0_ y0_:egen t00=max(t0)
		
		keep y0_ x0_ t00
		duplicates drop 
		*replace tt0=tt0+`delta'	
		bysort x0_ (y0_):gen tt0=sum(t00+`delta')
		*new Y0
		gen ny0_=tt0-0.5*t00
		by x0:egen mm=max(tt0) 
		sum tt0
		local max=`r(max)'
		replace ny0_=ny0_+0.5*(`max'-mm)
		gen x1_=x0_
		gen y1_=y0_
		gen ny1_= ny0_
	}

	frlink m:1 x0_ y0_, frame(`new')
	frget ny0_, from(`new')
	drop `new'
	frlink m:1 x1_ y1_, frame(`new')
	frget ny1_, from(`new')
	replace y0_ = ny0_ 
	replace y1_ = ny1_ 
	
end
		
program sankey_i2
syntax varlist [if],  [width0(varname) width1(varname) sharp(real 7) ///
				 color(varname) pstyle(varname) * adjust ///
				 label0(varname) label1(varname)  gap(real 0.01) ///
				 noline nobar extra colorpalette(passthru) fillcolor(str asis) ///
				 newframe(string) bwidth(real 0.025) bheight(numlist >0 max=1) bcolor(string asis) blcolor(string asis) blwidth(string asis) ///
				 labangle(real 0) labpos(string asis) labsize(string asis) labcolor(string asis) labgap(string asis) xaxis(passthru)]  
	
	if "`newframe'"=="" tempname newframe
	local nn = _N
	frame put `varlist' `color' `pstyle' `width0' `width1' `label0' `label1' `if' , into(`newframe')
	frame `newframe': {
		** Changes names and adds W's if missing
		gen _sort = _n
		qui:change_names, xy(`varlist') color(`color') pstyle(`pstyle') w0(`width0') w1(`width1') lb0(`label0') lb1(`label1')

		local sort sort
		if "`extra'"!="" 	qui:extra_adj , gap(`gap')
		
		qui:label_adjust  ,  `adjust' `colorpalette'
		
		local nn2 = _N
				
		*drop if _or==0
		if "`adjust'"!="" qui:adjust_coordinates if _or==1 
		
		** Create Variables for Labels and Spikes
		gsort -_or _sort _id
		*list `varlist' _or `sort'
		tempvar x y
		 
		qui:range `x' 0 1 `=ceil(35/5*`sharp')'
		gen `y'=normal((`x'-.5)*`sharp')
		qui sum `y', meanonly
		qui: replace `y'=(`y'-`r(min)')/(`r(max)'-`r(min)')
		
		** From ... to
		*** Plot Links
		forvalues j = 1/`nn' {
				
				qui:get_coordinates   ,  n(`j')
				local x0 = r(x0)
				local y0 = r(y0)
				local x1 = r(x1)
				local y1 = r(y1)
				local wd0 = r(wd0)
				local wd1 = r(wd1)
				 
				local col = col_[`j']
				if "`fillcolor'"!="" local col  `fillcolor'
				local pst  =  ps_[`j']
				if "`line'"!="" local lcl lwidth(none)
			    *display "qui:gen yy0_`j' = y0_ + `y' * (y1_-y0_) - `wd0'/2-0.5*(`wd1'-`wd0')*`y'"    
				qui:gen yy0_`j' = `y0' + `y' * (`y1'-`y0') - `wd0'/2-0.5*(`wd1'-`wd0')*`y'
				qui:gen yy1_`j' = `y0' + `y' * (`y1'-`y0') + `wd0'/2+0.5*(`wd1'-`wd0')*`y'
				qui:gen xx_`j'  = `x0' + `x' * (`x1'-`x0') 
				*scatter  yy0_`j' yy1_`j' xx_`j' 
				*display `"(rarea yy0_`j' yy1_`j' xx_`j', color(`col') pstyle(`pst') `lcl' fintensity(100))"'
				local toplot `toplot' (rarea yy0_`j' yy1_`j' xx_`j', color(`col') pstyle(`pst') `lcl' fintensity(100))		
				 
		}
		** plot bars
		qui:count if x_or_!=.
		local rbn = r(N)
		*list colb_
		if "`bar'"=="" {
			if "`bheight'"!="" {
					tempvar bhm
					qui:egen `bhm'=max(y0_max_- y0_min_)
					qui:replace y0_min_ =y0_cnt-`bheight'*`bhm'
					qui:replace y0_max_ =y0_cnt+`bheight'*`bhm'
				}
			local col
			forvalues j=1/`rbn'	{
				
				local col = colb_[`j']
				local pst =  psb_[`j']
				if `"`bcolor'"'!="" local col = `"`bcolor'"'
				
				local rrbarr `rrbarr' (rbar y0_min_ y0_max_ x_or_ in `j' , barwidth(`bwidth') color(`col') pstyle(`pst') fintensity(100) lcolor(`blcolor') lwidth(`blwidth') )
			}
		}
		** plot labels
		*display `"`rrbarr'"'
		qui:count if lb0_!=""
		if `r(N)'!=0 {
			qui sum x_or_
			local xmax=r(max)
			forvalues j=1/`rbn'	{
					local pos 3
					if `=x_or_[`j']'==`xmax' local pos 9
					if "`labpos'"!="" local pos `labpos'
					local totext `totext' `=y0_cnt[`j']'  `=x_or_[`j']' (`pos') "`=lb0b_[`j']'"
				}
				
			local totext (scatteri `totext', msymbol(none) mlabangle(`labangle') mlabsize(`labsize') mlabcolor(`labcolor') mlabgap(`labgap') `xaxis')
		}
		*display `"`rrbarr'"'
		two `toplot' `rrbarr' `totext'  , `options' ylabel("") legend(off)
		 
	}
	
end
 
 

