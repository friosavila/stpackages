* v1.1 FRA version for spline for F_ABLE. Adds replace
*! v1  FRA 10/22/2020 First version for spline for F_ABLE
*                    This command creates splines, of any degree, given percentiles, or knots.
 
*capture program drop f_spline
program f_spline
	syntax [anything(equalok everything)], [version] *
	if "`version'"!="" | "`0'"=="" {
		addr scalar version = 1.1
		display "version:" scalar(r(version))
		exit
	}
	else f_spline_wk `0'
end

program f_spline_wk , 
	syntax anything(id="newvarname")=/exp [if] [in] , ///
					[ weight(varname) /// declares weghiths for some cases
					NPctile(numlist >=1) /// uses Number of percentiles. for example 3 would use the 33th 66th 
					KPctile(numlist >0 <100 sort) /// Declares which percentiles for example 20th 90th
					NKnots(numlist >=1 int) /// knots declare equidistance knots if data is between 0-100, 1 knot would be 50, 2 would be 33 66, etc
					Knots(numlist sort) /// This deckares which points to use the breakdowns 
					Degree(numlist >=1 int) /// this indicates the degree of polynomials.
					replace ] 
	
	if "`npctile'`kpctile'`nknots'`knots'"=="" {
		display in red "Spline option needed"
		error 1
	}
	
	local cnt = ("`npctile'"!="") + ("`kpctile'"!="")+ ("`nknots'"!="")+ ("`knots'"!="")
	if `cnt'>1 {
		display in red "Only one Spline option allowed"
		error 1
	}
	** check for knots
	if "`knots'"!="" {
		qui:sum `exp' `if' `in'
		capture:qui:numlist "`knots'",range(>`r(min)' <`r(max)')
		if _rc == 125 {
			display in red "Knots elements are outside the range of `exp'"
			error 1
		}
	}
	** check for weight
	if "`weight'"=="" {
		local weight = 1
	}
	** check for degree
	if "`degree'"=="" {
		local degree 1
	}
	
	
	if "`npctile'" !="" {
	    _pctile `exp' `if' `in' [aw=`weight'], n(`=`npctile'+1')
		local i=1
		while "`r(r`i')'"!="" {
			local mlist `mlist' `r(r`i')'			
			local i=`i'+1
		}
	}
	
	else if "`kpctile'" !="" {
		_pctile `exp' `if' `in' [aw=`weight'], p(`kpctile')
		local i=1
		while "`r(r`i')'"!="" {
			local mlist `mlist' `r(r`i')'			
			local i=`i'+1
		}
	}
	
	else if "`nknots'" !="" {
		qui:sum `exp' `if' `in',
		local rmax=r(max)
		local rmin=r(min)
		local dd=(`rmax'-`rmin')/(`nknots'+1)
		
		forvalues i = `=`rmin'+`dd'' (`dd') `=`rmax'-epsfloat()' {
			local mlist `mlist' `i'
		}
	}
	
	else if "`knots'" !="" {
		numlist "`knots'", sort
		local mlist `r(numlist)'
	}
	
	** Degree
	local vcnt =1
	forvalues i = 2/ `degree' {
		local vcnt=`vcnt'+1 
		if "`replace'"!="" capture drop `anything'`vcnt'
		fgen `anything'`vcnt'=`exp'^`i'
	}
	foreach i of local mlist {
		local vcnt=`vcnt'+1 
		if "`replace'"!="" capture drop `anything'`vcnt'
		fgen `anything'`vcnt'=max(`exp'-`i',0)^`degree'
	}
end

program addr, rclass
	return `0'
end 
 