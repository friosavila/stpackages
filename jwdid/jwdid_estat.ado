*! v1.32 FRA. Prepares for did_plot
*! v1.31 FRA. Prepares for jwdid_plot
* v1.3 FRA. Corrects Never
* v1.2 FRA. some beutification
* v1.1 FRA. Adds margins event with labels
* v1 8/5/2022 FRA. Adds margins the right way
program define addr, rclass
		return add
        return `0'
end

program jwdid_estat, sortpreserve   
	version 14
    syntax anything, [* ]
        if "`e(cmd)'" != "jwdid" {
                error 301
        }
        gettoken key rest : 0, parse(", ")
        if inlist("`key'","simple","group","calendar","event","all") {
			
			jwdid_`key'  `rest'
			addr local cmd  estat, 
			addr local cmd2 jwdid, 
        }
		else {
			display in red "Option `key' not recognized"
				error 199
		}

end

program jwdid_simple, rclass
		syntax, [* post estore(str) esave(str) replace]
		//tempvar aux
		//qui:bysort `e(ivar)':egen `aux'=min(`e(tvar)') if e(sample)
		capture:est store `lastreg'	
		tempname lastreg
		capture:qui:est store `lastreg'   

		
		qui:margins  ,  subpop(if __etr__==1) at(__tr__=(0 1)) ///
					noestimcheck contrast(atcontrast(r)) `options' post
		tempname table b V			
		matrix `table' = r(table)
		matrix `b' = e(b)
		matrix `V' = e(V)
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

program jwdid_group, rclass
		syntax, [* post estore(str) esave(str) replace]
		tempvar aux
		qui:bysort `e(gvar)' `e(ivar)':egen `aux'=min(`e(tvar)') if e(sample)
		
		capture:est store `lastreg'	
		tempname lastreg
		capture:qui:est store `lastreg'  
		
		
		capture drop __group__
		qui:clonevar __group__ =  `e(gvar)' if __etr__==1 & `aux'<`e(gvar)'
		qui:margins , subpop(if __etr__==1) at(__tr__=(0 1)) ///
				  over(__group__) noestimcheck contrast(atcontrast(r)) `options'  post
		tempname table b V			
		matrix `table' = r(table)
		matrix `b' = e(b)
		matrix `V' = e(V)
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

program jwdid_calendar, rclass
syntax, [* post estore(str) esave(str) replace]
		capture drop __calendar__
		tempvar aux
		qui:bysort `e(gvar)' `e(ivar)':egen `aux'=min(`e(tvar)') if e(sample)
		qui:clonevar __calendar__ =  `e(tvar)' if __etr__==1 & `aux'<`e(gvar)'
		
		capture:est store `lastreg'	
		tempname lastreg
		capture:qui:est store `lastreg'  
		
		qui:margins , subpop(if __etr__==1) at(__tr__=(0 1)) ///
				over(__calendar__) noestimcheck contrast(atcontrast(r)) `options' post
		tempname table b V			
		matrix `table' = r(table)
		matrix `b' = e(b)
		matrix `V' = e(V)
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

program jwdid_event, rclass
syntax, [* post estore(str) esave(str) replace]
		capture drop __event__
		tempvar aux
		qui:bysort `e(gvar)' `e(ivar)':egen `aux'=min(`e(tvar)') if e(sample)
		qui:sum `e(tvar)' if e(sample), meanonly
		qui:gen __event__ =  `e(tvar)'-`e(gvar)' if `e(gvar)'!=0 & e(sample) 
		
		capture:est store `lastreg'	
		tempname lastreg
		capture:qui:est store `lastreg'  
		
		*qui:replace __event__ =__event__ - 1 if  __event__ <0
		if "`e(type)'"=="notyet" {
			qui:margins , subpop(if __etr__==1) at(__tr__=(0 1)) ///
				over(__event__) noestimcheck contrast(atcontrast(r)) `options' post
		}
		else if "`e(type)'"=="never" {
			capture drop __event2__
			qui:sum __event__, meanonly
			local rmin = r(min)
			qui:replace __event__=__event__-r(min)
			qui:levelsof __event__, local(lv)
			foreach i of local lv {
				label define __event__ `i' "`=`i'+`rmin''", modify
			}
			label values __event__ __event__
			qui:margins , subpop(if __tr__==1) at(__tr__=(0 1)) ///
				over(__event__) noestimcheck contrast(atcontrast(r)) `options' post
		}
		
		
		tempname table b V			
		matrix `table' = r(table)
		matrix `b' = e(b)
		matrix `V' = e(V)
		ereturn display
		
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
