clear
set obs 1000
gen r=runiformint(1,3)
gen rr=rnormal()+r
sum rr
 
capture program drop mhistogram
program mhistogram
	syntax varname [iw fw / ] [if] [in], [over(varname) width(real 0) start(string asis) * ///
					 gap(real 0.0)]
	
	tempname hist
	marksample touse
	markout `touse' `over' `exp'
	
	frame put `varlist' `exp' `over' if `touse', into(`hist')
	
	frame `hist':{
		
		sum `varlist' [`weight'`exp'], meanonly 
		local rmin = r(min)
		local rmax = r(max)
		local rn   = r(N)
		local k    = min(sqrt(`rn'), 10*ln(`rn')/ln(`rn'))
		local bw   = (`rmax'-`rmin')/`k'
		if `width'==0 local width `bw'
		if "`start'"=="" local start `rmin'
		
		levelsof `over', local(oname)
		foreach i of local oname {
			local kc = `kc'+1
			twohistgen `varlist' [`weight'`exp'] if `over'==`i', `options' width(`width') start(`start') ///
						gen(h`kc' g`kc') 
			replace h`kc' = h`kc'+(`kc'-1)*`gap'
			local base`kc'=(`kc'-1)*`gap'
			if `gap'==0 & "`cum'"!="" {
				capture gen bsc = 0
				replace bsc = bsc + h`kc'
				replace h`kc' = bsc 
			}
			local tohist `tohist' (bar h`kc' g`kc' , pstyle(p`kc') barw(`width') base(`base`kc''))			
		}	
		if `gap'!=0 local ysoff ylabel("")
		two `tohist', `ysoff'
	}
end