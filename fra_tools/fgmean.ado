** THis is a small wrapper for mean command to allow for the use of gen functions but not factor variables
** requires Stata 15

 program fgmean, eclass
syntax anything [if] [in] [aw fw iw  ] , [,* over(varname)] 
	** First Expand anything
	marksample touse
	
	*fvexpand `anything'
	*local bl `r(varlist)'
	* creates a variables for all expanded data
 	
	foreach i of local anything {
		local cnt=`cnt'+1
		tempvar aux`cnt'
		*display "`i'"
		qui:gen double `aux`cnt''=`i'
		label var `aux`cnt'' "`i'"
		local nm `nm' `i'
		local meannm `meannm' `aux`cnt''
		qui:replace `touse'=0 if `aux`cnt''==.
	}
	 
	qui:mean `meannm' [`weight'`exp'] if `touse', `options' over(`over')
	if "`over'"!="" {
		qui:levelsof `over' if `touse', local(ovl)
		foreach i of local bl {
			foreach k of local ovl {
			local nsm `nsm' `i'
			}
		}
		matrix b=e(b)
		matrix V=e(V)
		matrix coleq b=`nsm' 
		matrix coleq V=`nsm'  
		matrix roweq V=`nsm'  
		*matrix list b
		*matrix list V
	}
	else {
		matrix b=e(b)
		matrix V=e(V)
		matrix colname b=`nm' 
		matrix colname V=`nm'  
		matrix rowname V=`nm'  
		*matrix list b
		*matrix list V
	}
	ereturn repost  b=b  V=V, rename
	*ereturn matrix b=b, copy
	*ereturn matrix V=V, copy
	ereturn display
end
