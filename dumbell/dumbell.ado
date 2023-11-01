capture program drop dumbel
program dumbel
	syntax varname [if] [in] [iw aw fw/], [by(varname) over(varname)] [stat(str)]
	marksample touse
	
	markout `touse' `by' `over' `exp'
	tempvar toframe
	frame put `varlist' `by' `over' `exp' if `touse', into(`toframe')
	if "`exp'"!="" local exp =`exp'
	
	frame `toframe': {
		if "`stat'"=="" local stat mean
		collapse (`stat') `varlist' [`weight'`exp'], by(`by' `over') fast
		
		reshape wide `varlist' , i(`by') j(`over')
		sum
		two (pcspike `by' `varlist'1 `by' `varlist'3, lwidth(1)) ///
			(scatter `by' `varlist'1, msize(2)) ///
			(scatter `by' `varlist'2, msize(2)) (scatter `by' `varlist'3, msize(2)) 
			
	}
end