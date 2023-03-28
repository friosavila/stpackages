** THis is a small wrapper for mean command to allow for the use of gen functions but not factor variables
** requires Stata 15

capture program drop fghistogram
program fghistogram,  
syntax anything [if] [in] [aw fw iw ] , [,*] 
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
	 
	qui:histogram `meannm' if `touse' [`weight'`exp'], `options'  
	
end
