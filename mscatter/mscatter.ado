*! v1.33  4/26/2022 by FRA: adds Lowess, and corrects weight
* v1.32  4/26/2022 by FRA: Fixes IF
* v1.31  4/26/2022 by FRA: Transparency fix
* v1.3  4/24/2022 by FRA: Adds FIT option.
* v1.2  4/21/2022 by FRA: Works with Stata < 16
* v1.1  4/11/2022 by FRA
** Scatter with across multiple groups

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

program mscatter
	* If nothing is done, all goes to 0
	*syntax anything(everything), [  * ] 
	if runiform()<0.001 {
		easter_egg
	}
	
	if runiform()<0.001 {
		if `c(stata_version)'>=16 {
			easter_egg2
		}		
	}
	mscatterx `0'
end

program easter_egg2 
	tempname mario
	frame create `mario'
	frame `mario':use https://friosavila.github.io/playingwithstata/rnd_dta/mario, clear
	frame `mario':mscatterx y x, over(cc10)  color(mc10) msize(1.3) msymbol(S) aspect(1)  title("Let me take care of it")  
	if _rc==0 sleep 2000
	
end

program mscatterx 
 	syntax varlist(max=2)   [if] [in] [aw fw iw /], [over(varname)] ///
				[ alegend legend(string asis) color(string asis) ///
				  fit(str asis)	 ///
				  colorpalette(string asis) by(string asis)  * ]
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

	** Check weights in fit
	fit_parser `fit'
	local fitwgt `r(fitwgt)'
	
	** markout only works with numeric	
	markout `touse' `varlist' `byvlist' `over' `exp', strok
	
	local myvlist `myvlist' `varlist' `byvlist' `over' `exp' `fitwgt'
	
	** Put into Frame
	if `c(stata_version)'>=16 {
		frame put `myvlist' if `touse', into(`new')
		syntax anything [aw] [if] [in], [*]
		frame `new':mscatter_do `anything' [`weight'`exp'], `options'
	}
	else {
		preserve
			qui:keep if `touse'
			keep `myvlist' 
			syntax anything [aw] [if] [in], [*]
			mscatter_do `anything' [`weight'`exp'], `options'
		restore
	}
	
	
end 

 
program fit_parser, rclass
	syntax [anything] [aw fw pw iw ], [* fcolor(passthru) lcolor(passthru)]
	if "`anything'"=="" exit
	
	if inlist("`anything'","lfitci","qfitci","fpfitci","lpolyci") {
		return local fitval =2
	}
	else if inlist("`anything'","lfit","qfit","fpfit","lpoly","lowess") {
		return local fitval =1
	}
	else {
		display in red "Not a valid {cmd:fit} option. One can only use lfit qfit fpfit or lowess lpoly (with CI options)"
		error 99
	}
	
	if `"`fcolor'"'=="" & `c(stata_version)'<=14 local fcolor fcolor(*.50)
	if `"`fcolor'"'=="" & `c(stata_version)'>14  local fcolor fcolor(%50)
	
	if `"`lcolor'"'=="" local lcolor lcolor(*1.1)
 
	local wgt=subinstr("`exp'","=","",1)
	return local  fitcmd  `anything'
	return local  fitopt  `options' `fcolor' `lcolor'
	return local  fitwgt  `wgt'
	return local  fitewgt [`weight'`exp']

end

 
**!! Consider adding a sample option. 

program mscatter_do 
 	syntax varlist(max=2)   [if] [in] [aw/], [over(varname)] [ alegend legend(string asis) color(string asis) colorpalette(string asis) by(str asis) ///
										msymbol(passthru) msize(passthru) fit(str asis) noscatter ///
										msangle(passthru) mfcolor(passthru) mlcolor(passthru) strict ///
										mlwidth(passthru) mlalign(passthru) jitter(passthru) jitterseed(passthru) * ]
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
		** check fit options
		fit_parser `fit'
		local fitcmd `r(fitcmd)'
		local fitopt `r(fitopt)'
		local fitval `r(fitval)'
		local fitwgt `r(fitewgt)'
		**Check Weight 
		capture confirm numeric var `over'
			if _rc!=0 {
				tempvar nover
				encode `over', gen(`nover')
				local over `nover'
			}
	
		if "`exp'"!="" local wexp [aw=`exp']
		
		if "`scatter'"!="" {
			tempvar fuse
			qui: gen byte `fuse'=.
			local tofuse & `fuse'!=.
		}	
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
			colorpalette `r(clpop)' nograph n(`cnt')
			local cpcolor  `"`r(p)'"'
		}
		
		local cnt=0
		local cnx=0
		foreach i of local lvlby {
			local cnt = `cnt' +1 	
			local cnx = `cnx'+1
			if `col_op'==1 {
				local mycolor `=`color'[`cnt']'
			}
			if `col_op'==2 {
				local wrd:word count `color'
				if `cnt'<=`wrd'	local mycolor:word `cnt' of `color'
				else  		    local mycolor:word `wrd' of `color'
			}
			if `col_op'==3 local mycolor:word `cnt' of `cpcolor'
			if `col_op'==4 {
				if `cnx'>15	 local cnx 1
				qui:graphquery color p`cnx'
				local mycolor `r(query)'
			}
			if "`fit'"!="" local fitplot (`fitcmd' `varlist' if `over'==`i' `fitwgt', `fitopt' color("`mycolor'") )
			local pscatter `pscatter' ///
					(scatter `varlist' `fitwgt' `wexp' if `over'==`i'  `tofuse', ///
					color( "`mycolor'" ) ///
					`msymbol' `msize' `msangle' `mfcolor' `mlcolor' ///
					`mlwidth' `mlalign' `jitter' `jitterseed') `fitplot'
		}
			
			
		 ** Then just Scatter, but...One more component, legend. Default Legend off
		 if "`alegend'"=="" & `"`legend'"' == ""   local mylegend legend(off)
		 if "`alegend'"=="" & `"`legend'"' != ""   local mylegend legend(`legend')
		 if "`alegend'"!="" {
		 	local cn =0
			
		 	foreach i of local lvlby {
					local cn = `cn'+1+0`fitval'
					local slg: label (`over') `i', `strict'
					local mylegend `mylegend' `cn' "`slg'"
					
				}
			local mylegend legend(order(`mylegend') `legend')	
		 }
		** the figure 
		global ll `pscatter'
		two `pscatter', `options' by(`by') `mylegend'
	}
end 

