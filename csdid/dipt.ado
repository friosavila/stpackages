**program drop dipt
program dipt, eclass

syntax varlist(fv ts) [if] [iw pw fw], [cluster(passthru) from(passthru)] 

// ML
gettoken y xvar:varlist
marksample touse

mlexp (`y'*{xb:`xvar' _cons}-(`y'==0)*exp({xb:}))  ///
					if `touse' [`exp'`weight'],  ///
					 derivative(/xb=`y'-(`y'==0)*exp({xb:})) ///
                     `from'
                     
end                     

program dipt0, eclass

syntax varlist(fv ts) [if] [iw pw fw], [cluster(passthru) *] 

// ML
gettoken y xvar:varlist
marksample touse

mlexp ({xb:`xvar' _cons}-(`y'==0)*exp({xb:}))  ///
					if `touse' [`exp'`weight'],  ///
					 derivative(/xb=1-(`y'==0)*exp({xb:})) ///
                     `options'
                     
end 

program dipt1, eclass

syntax varlist(fv ts) [if] [iw pw fw], [cluster(passthru) *] 

// ML
gettoken y xvar:varlist
marksample touse

mlexp ({xb:`xvar' _cons}-(`y'==1)*exp({xb:}))  ///
					if `touse' [`exp'`weight'],  ///
					 derivative(/xb=1-(`y'==1)*exp({xb:})) ///
                     `options'
                     
end 