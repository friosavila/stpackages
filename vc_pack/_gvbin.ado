** version 1.0 Fernando Rios avila Dec 2018
*this function is used to "create a binned variable" from the original one.
*This can be used to make figures with vc_graph or construct on Binns for vc_bw
 

capture program drop _gvbin
program  _gvbin, sortpreserve
	syntax newvarname =/exp [if] [in] , knot(str) [km(real 1)]
	qui {
 		tempvar touse
 		gen byte `touse' =0
		replace `touse'= 1 `if' `in' 
		replace `touse'= 0 if `exp'==.
		numlist "`knot'", range(>=0) integer max(1) min(1)
		
		sum `exp' if `touse', meanonly
		local max=r(max)
		local min=r(min)
		local N=r(N)
		if `knot'==0 {
		   ** This selects the number of bins of equal size (just like stata)
		   local kb min(sqrt(`N'),10*ln(`N')/ln(10))
		   local kb round(`kb'*`km')
		   local del=(`max'-`min')/(`kb'+1)
		   local knt = `kb'
		}
		if `knot'>=1 {
		   local del=(`max'-`min')/(`knot'+1)
		   local knt = `knot'
		}
		
		tempvar aux
		gen double `aux'=.
 
		forvalues i =0/`knt' {
 			replace `aux'=`i'+1 if `exp'>=(`min'+`i'*`del')
		}
		*** here we start with the kernels
		gen `typlist' `varlist' =`min'+(`aux'-.5)*`del' if `touse'
	}
	
end
