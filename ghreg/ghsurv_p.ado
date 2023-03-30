*! v1.0 April 2020 Fernando Rios-Avila 
* This is to use with margins. 
program ghsurv_p, 
    syntax newvarname [if] [in] , [p_exit p_cont *]
	marksample touse, novarlist
	** We only predict probability, otherwise use ml_p default
	if "`p_exit'`p_cont'"=="" {
		ml_p `0' 
	}
	else {
	    if "`p_exit'"!= {
			 if "`e(method)'"=="logit"   predictnl `typlist' `varlist'=logistic(-xb(#1))    if `touse'
		else if "`e(method)'"=="probit"  predictnl `typlist' `varlist'=  normal(-xb(#1))    if `touse'
		else if "`e(method)'"=="cloglog" predictnl `typlist' `varlist'=invcloglog(-xb(#1)) if `touse'
		
		exit
		}
		if "`p_cont'"!= {
			 if "`e(method)'"=="logit"   predictnl `typlist' `varlist'=logistic(xb(#1))     if `touse'
		else if "`e(method)'"=="probit"  predictnl `typlist' `varlist'=  normal(xb(#1))     if `touse'
		else if "`e(method)'"=="cloglog" predictnl `typlist' `varlist'=1-invcloglog(-xb(#1)) if `touse'
		
		exit
		}
	}
end 