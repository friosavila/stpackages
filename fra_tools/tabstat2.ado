*! v0.2 Two ways to collect Results 
* v0.1 alt to tabstat

 program tabstat2, rclass
	syntax anything(everything) [aw iw fw] [if] [in], [save *] 
	tabstat `0'
	tempname smatrix smatrix2
	local j=1
	if "`save'"!="" {		
		while _rc==0 {
			matrix `smatrix' = nullmat(`smatrix'),r(Stat`j')
			matrix `smatrix2' = nullmat(`smatrix2')\r(Stat`j')
 
            local j=`j'+1
			capture confirm matrix r(Stat`j')
		}
	}
	return add
	return matrix tmatrix = `smatrix'
    return matrix tmatrix2 = `smatrix2'

end
