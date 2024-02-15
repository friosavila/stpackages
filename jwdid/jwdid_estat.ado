*! v1.5 FRA. Fix Bug with Continuous treatment
*!           adds PTA test   
* v1.42 FRA. flexible PLOT
* v1.41 FRA. Changes | fpr &
* v1.4 FRA. Allows for treatment to be continuous. With ASIS
* v1.37 FRA. Adds Over for Simple aggregations: Will allow for other aggregations at will
* v1.35 FRA. adds method to mlogit
* v1.34 FRA. Small changes on Other
* v1.33 FRA. Changes output (not AT anymore)
* Also allows for "other" as condition
* v1.32 FRA. Prepares for did_plot
* v1.31 FRA. Prepares for jwdid_plot
* v1.3 FRA. Corrects Never
* v1.2 FRA. some beutification
* v1.1 FRA. Adds margins event with labels
* v1 8/5/2022 FRA. Adds margins the right way

program define addr, rclass
		return add
        return `0'
end

program define adde, eclass
		ereturn `0'
end

program define jwdid_estat, sortpreserve   
	version 14
    syntax anything, [* PLOT PLOT1(string asis)]
        if "`e(cmd)'" != "jwdid" {
                error 301
        }
		
		if "`e(cmd2)'"!="" adde local cmd  `e(cmd2)'
        gettoken key rest : 0, parse(", ")
		
		tempname last
		qui:est sto `last'
		capture noisily {
			if inlist("`key'","simple","group","calendar","event","plot") {				
				jwdid_`key'  `rest'
				addr local cmd  estat, 
				addr local cmd2 jwdid, 
				if "`key'"!="plot" & ( "`plot'"!="" | `"`plot1'"'!="") {
					jwdid_plot, `plot1'
				} 

			}
			else {
				display in red "Option `key' not recognized"
					error 199
			}			
		}
		if _rc!=0 {
			qui:est restore `last'
		}
		adde local cmd jwdid
end

program define jwdid_simple, rclass
		syntax, [* post estore(str) esave(str) replace over(varname) asis PLOT PLOT1(string asis)]
		//tempvar aux
		//qui:bysort `e(ivar)':egen `aux'=min(`e(tvar)') if e(sample)
		capture:est store `lastreg'	
		tempname lastreg
		capture:qui:est store `lastreg'   
		tempvar etr
		if "`over'"!="" qui: gen `etr'=`over' if !inlist(`over',0,.) & __etr__==1
		else local etr 
		if "`asis'"=="" {
			qui:margins  ,  subpop(if __etr__==1) at(__tr__=(0 1)) ///
					noestimcheck contrast(atcontrast(r)) ///
					`options' post over(`etr')
		}
		else {
			qui:margins  ,  subpop(if __etr__==1) at(__tr__=0) at((asobserved) __tr__) ///
					noestimcheck contrast(atcontrast(r)) ///
					`options' post over(`etr')
		}
		tempname table b V			
		matrix `table' = r(table)
		matrix `b' = e(b)
		matrix `V' = e(V)

		local nm:colnames `b'
		local nm = subinstr("`nm'","r2vs1._at@","",.)

		if `"`over'"'!="" qui:levelsof `etr'  , local(ol)
		
		if `:word count `ol''>1 {
			foreach i of local ol {
				local snm `snm' simple`i'
			}	
		}
		else local snm simple	
		
		matrix colname `b' = `snm'
		matrix colname `V' = `snm'
		matrix rowname `V' = `snm'
		tempname bb VV
		matrix `bb' = `b'
		matrix `VV' = `V'
		adde repost b=`bb' V=`VV', rename

		ereturn display
		
		if "`estore'"!="" est store `estore'
		if "`esave'"!="" est save `estore', `replace'
		if "`post'"=="" qui:est restore `lastreg'
		
		return matrix table = `table'
		return matrix b = `b'
		return matrix V = `V'
		return local cmd jwdid_estat
		return local agg simple
end

program define jwdid_group, rclass
		syntax, [* post estore(str) esave(str) replace  other(varname) asis PLOT PLOT1(string asis)]
		tempvar aux
		qui:bysort `e(gvar)' `e(ivar)':egen `aux'=min(`e(tvar)') if e(sample)
		
		capture:est store `lastreg'	
		tempname lastreg
		capture:qui:est store `lastreg'  
		
		
		capture drop __group__
		qui:clonevar __group__ =  `e(gvar)' if __etr__==1 & `aux'<`e(gvar)'
		if "`other'"!="" {
			*replace __group__=. if inlist(`other',0,.)
			local otherif "& !inlist(`other',0,.)"
		}
		if "`asis'"=="" {
			qui:margins , subpop(if __etr__==1 `otherif') at(__tr__=(0 1)) ///
				  over(__group__) noestimcheck contrast(atcontrast(r)) ///
				  `options'  post
		}
		else {
			qui:margins  ,  subpop(if __etr__==1 `otherif') at(__tr__=0) at((asobserved) __tr__) ///
					over(__group__) noestimcheck contrast(atcontrast(r)) ///
				  `options'  post
		}
		
 
		tempname table b V			
		matrix `table' = r(table)
		matrix `b' = e(b)
		matrix `V' = e(V)

		local nm:colnames `b'
		local nm = subinstr("`nm'","r2vs1._at@","",.)

		matrix colname `b' = `nm'
		matrix colname `V' = `nm'
		matrix rowname `V' = `nm'
		tempname bb VV
		matrix `bb' = `b'
		matrix `VV' = `V'
		adde repost b=`bb' V=`VV', rename

		ereturn display
		
		if "`estore'"!="" est store `estore'
		if "`esave'"!="" est save `estore', `replace'
		if "`post'"=="" qui:est restore `lastreg'
		
		return matrix table = `table'
		return matrix b = `b'
		return matrix V = `V'
		return local agg group
		return local cmd jwdid_estat
		capture drop __group__
end

program define jwdid_calendar, rclass
	syntax, [* post estore(str) esave(str) replace  other(varname) PLOT PLOT1(string asis)]
		capture drop __calendar__
		tempvar aux
		qui:bysort `e(gvar)' `e(ivar)':egen `aux'=min(`e(tvar)') if e(sample)
		qui:clonevar __calendar__ =  `e(tvar)' if __etr__==1 & `aux'<`e(gvar)'
		
		capture:est store `lastreg'	
		tempname lastreg
		capture:qui:est store `lastreg'  
		
		if "`other'"!="" {
			*replace __group__=. if inlist(`other',0,.)
			local otherif "& !inlist(`other',0,.)"
		}
		if "`asis'"=="" {
			qui:margins , subpop(if __etr__==1 `otherif') at(__tr__=(0 1)) ///
				  over(__calendar__) noestimcheck contrast(atcontrast(r)) ///
				  `options'  post
		}
		else {
			qui:margins  ,  subpop(if __etr__==1 `otherif') at(__tr__=0) at((asobserved) __tr__) ///
					over(__calendar__) noestimcheck contrast(atcontrast(r)) ///
				  `options'  post
		}
		
		tempname table b V			
		matrix `table' = r(table)
		matrix `b' = e(b)
		matrix `V' = e(V)

		local nm:colnames `b'
		local nm = subinstr("`nm'","r2vs1._at@","",.)

		matrix colname `b' = `nm'
		matrix colname `V' = `nm'
		matrix rowname `V' = `nm'
		tempname bb VV
		matrix `bb' = `b'
		matrix `VV' = `V'
		adde repost b=`bb' V=`VV', rename

		ereturn display
		
		
		if "`estore'"!="" est store `estore'
		if "`esave'"!="" est save `estore', `replace'
		if "`post'"=="" qui:est restore `lastreg'
		
		return matrix table = `table'
		return matrix b = `b'
		return matrix V = `V'
		return local agg calendar
		return local cmd jwdid_estat
		capture drop __calendar__
end

program define jwdid_event, rclass
	syntax, [post estore(str) esave(str) replace  other(varname) PLOT PLOT1(string asis) asis * pretrend ]
		capture drop __event__
		tempvar aux
		qui:bysort `e(gvar)' `e(ivar)':egen `aux'=min(`e(tvar)') if e(sample)
		qui:sum `e(tvar)' if e(sample), meanonly
		qui:gen __event__ = `e(tvar)'-`e(gvar)' if `e(gvar)'!=0 & e(sample) 
		
		capture:est store `lastreg'	
		tempname lastreg
		capture:qui:est store `lastreg'  
		if "`other'"!="" {
			*replace __group__=. if inlist(`other',0,.)
			local otherif "& !inlist(`other',0,.)"
		}
		*qui:replace __event__ =__event__ - 1 if  __event__ <0
		if "`e(type)'"=="notyet" {

				if "`asis'"=="" {
					qui:margins , subpop(if __etr__==1 `otherif') at(__tr__=(0 1)) ///
						  over(__event__) noestimcheck contrast(atcontrast(r)) ///
						  `options'  post
				}
				else {
					qui:margins  ,  subpop(if __etr__==1 `otherif') at(__tr__=0) at((asobserved) __tr__) ///
							over(__event__) noestimcheck contrast(atcontrast(r)) ///
						  `options'  post
				}
 
		}
		else if "`e(type)'"=="never" {
            local nvr = "on"
			capture drop __event2__
			qui:sum __event__, meanonly
			local rmin = r(min)
			qui:replace __event__=1+__event__-r(min)
			qui:levelsof __event__, local(lv)
			foreach i of local lv {
				label define __event__ `i' "`=-1+`i'+`rmin''", modify
			}
			label values __event__ __event__

			if "`asis'"=="" {
				qui:margins , subpop(if __tr__!=0 `otherif') at(__tr__=(0 1)) ///
					  over(__event__) noestimcheck contrast(atcontrast(r)) ///
					  `options'  post
			}
			else {
				qui:margins  ,  subpop(if __tr__!=0 `otherif') at(__tr__=0) at((asobserved) __tr__) ///
						over(__event__) noestimcheck contrast(atcontrast(r)) ///
					  `options'  post
			}
 
		}
		
		
		tempname table b V			
		matrix `table' = r(table)
		matrix `b' = e(b)
		matrix `V' = e(V)

				local nm:colnames `b'
		local nm = subinstr("`nm'","r2vs1._at@","",.)

		matrix colname `b' = `nm'
		matrix colname `V' = `nm'
		matrix rowname `V' = `nm'
		tempname bb VV
		matrix `bb' = `b'
		matrix `VV' = `V'
		adde repost b=`bb' V=`VV', rename

		ereturn display
		
        *** PTA
        
        if "`pretrend'"!="" & "`nvr'"=="on" {
            qui:levelsof __event__, local(lv)
			foreach i of local lv {
				if `=-1+`i'+`rmin''<-1 local totest `totest' `i'.__event__ 
			}
            test `totest'
        }
        
		if "`estore'"!="" est store `estore'
		if "`esave'"!="" est save `estore', `replace'
		if "`post'"=="" qui:est restore `lastreg'
		
		return matrix table = `table'
		return matrix b = `b'
		return matrix V = `V'
		return local agg event
		return local cmd jwdid_estat
		*capture drop __event__
end
