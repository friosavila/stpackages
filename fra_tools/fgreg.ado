** THis is a small wrapper for regress command to allow for the use of gen functions but not factor variables
** requires Stata 15

capture program drop fgreg
program fgreg, eclass
syntax anything [if] [in] [aw fw iw  ] , [,* ] 
	** First Expand anything
	marksample touse
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
	local 00 `0' 
	qui:reg `meannm' [`weight'`exp'] if `touse', `options'  
	
	tokenize `nm'
	local y `1'
	macro shift
	local rest `*'
	
	macro shift
	matrix b=e(b)
	matrix V=e(V)
	matrix colname b=`rest' _cons
	matrix colname V=`rest' _cons 
	matrix roweq V=`rest' _cons
	 
	ereturn repost  b=b  V=V, rename
	ereturn local depvar="`y'"
	ereturn local cmdline="fgreg `00'"
	reg
end
