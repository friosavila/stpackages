capture program drop skdensity
program skdensity, 
     syntax varname [if] [in] [iw fw aw],  [SRANGE1(numlist min=2 max=2 sort)] ///
                                           [SRANGE2(numlist min=2 max=2 sort)] /// 
                                           [SRANGE3(numlist min=2 max=2 sort)] ///
                                           [SRANGE4(numlist min=2 max=2 sort)] ///
                                           [SRANGE5(numlist min=2 max=2 sort)] ///
                                           [range(numlist min=2 max=2 sort) n(int 0) * ]
     display "`srange1'"
     tempvar yvar xvar
     if `n'==0 local n = 250
     if "`range'"=="" {
         sum `varlist' `if', meanonly
         local rmin=r(min)
         local rmax=r(max)
         local range `rmin' `rmax'
     }
     /*tempvar rangevar
     range `rangevar' `range' `n'
     local k = `n'
     foreach i in `srange1' `srange2' `srange3' `srange4' `srange5' {
         local k = `k'+1
         replace `rangevar'=`i' in `k'
     }
     list `rangevar' if `rangevar'!=., sep(0)*/
     
     twoway__kdensity_gen `varlist' `if' `in' [`weight'`exp'], ///
        `options' generate(`yvar' `xvar' )   ///
        range(`range') n(`n')

 
     forvalues j = 1/5 {
         if "`srange`j''"!="" {
             tokenize "`srange`j''"
             local toshade  `toshade' (area `yvar' `xvar' if inrange(`xvar',`1',`2') )
        }
     }
     
     // plot
     two (line `yvar' `xvar') `toshade'
     
end