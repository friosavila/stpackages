** NEW PROGRAM : Variable Transformation
** Assume that you have to variables X and Y, such that y=f(x) and x=g(y) so that f^-1=g and viceversa
** This may still work as long as y=f(x) even if f^-1 does not exist.
** So I need 3 pieces of Data. All data X all data Y, and the points in x i want to transform into y
** This program will provide me with local cubic approximation of the number i need. It may not be EXACT 
** Specially at boundaries, but it should be Good enough for most purposes
** The new revision will be to do this using a local linear aproximation. Between the lowest and highest at boundaries

capture program drop vt_xtoy
program vt_xtoy, rclass sortpreserve
syntax , yvar(varname) xvar(varname) xlist(str) [tol(real 0.1) round(real 0.0)]
 qui {
	*First verify numlist
	** verify correlation
	numlist "`xlist'", sort
	local xxlist `r(numlist)'
	
	tempvar n nns
	gen `n'=_n
	bysort `xvar':gen `nns'=_n
	* Then obtain a simple summary of the original vcoef. That to obtain something about the Standard error
	qui:sum `xvar' if `nns'==1
	local sd=r(sd)
	tempvar dx
	gen double `dx'=0
	foreach k of local xxlist {
	         sum `yvar' if `xvar'<`k'+epsfloat()
		   local ymin=r(max)
		     sum `xvar' if `xvar'<`k'+epsfloat()
		   local xmin=r(max)
		     sum `yvar' if `xvar'>`k'-epsfloat()
		   local ymax=r(min)
		    sum `xvar' if `xvar'>`k'-epsfloat()
		   local xmax=r(min)
		   if (`xmax'-`xmin')==0  local x=`ymin'
		   else local x=`ymin'+(`ymax'-`ymin')*(`k'-`xmin')/(`xmax'-`xmin')
		   if "`round'"!="" {
		    local x=round(`x',`round')
		   }
		   local ylist `ylist'  `x'
	   }
	noisily display "`ylist' "
	return local ylist `ylist'
	}
end			
