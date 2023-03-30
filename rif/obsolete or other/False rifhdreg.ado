*! rifhdreg 2.6 July 2019 by Fernando Rios Avila
* Different way to allow for SVY. MOre effective. Only if No fixed effects.
* rifhdreg 2.5 July 2019 by Fernando Rios Avila
* Estimate a Multivalued Treatment effect
* rifhdreg 2.4 July 2019 by Fernando Rios Avila
* Making the program BYable
* rifhdreg 2.2 June 2019 by Fernando Rios Avila
* This version will incorporate ipw, for better control for differences in characteristics before running regressions
* The idea is based on Firpo (2017) and has already been implemented by Frolich for quantiles.
* So, this is the idea. add an option for the estimation of probit/logit model (like oaxaca), that is used to estimate IPW
* With this IPW, it would be possible to obtain either ATE  ATET ATEU. For now, we will use Robust stndard errors, but ideially i would aim to estimate them with GMM
* Im also addint SVY. This will work without the reweigthing (too complicated for now)
* The idea. svy is set. RIF estimated with svy weight. regression run with svy.
* rifhdreg 2.1 march 2019 by Fernando Rios Avila
* This version adds OVER. a kind of semi conditional RIF regression. 
* For now it Assumes the variable for over is a categorical variable, May play around with categorical Semi parametric
* This make the results similar to IVQTE, but still assuming exogeneity.
* rifhdreg 2.0 March 2019 by Fernando Rios Avila
* This program works with _grifvar from oaxaca_rif. 
* This is a wrapper that does the same as FFP rifreg but extends it to allow for multiple FE using reghdfe from Sergio Correira
* It also extends the use of RIF functions to other statistics. See help rifvar if installed
* it also uses some of the bivariate distribution indices as in rif-i-reg

* NOTE: try to allow for SVY in next update. 
* Easy solution. Capture weights, and add option svy. Seems to work.

*capture program drop rifhdreg
program rifhdreg, eclass sortpreserve byable(recall) properties(svyb svyr svyj)
    if replay() {
		results
        exit
    }
syntax anything [if] [in] [aw fw iw pw], rif(str)  [,* ] ///
	[retain(str)  replace  /// This is used to save the RIF, and replace if the variable already exists
	 abs(str)   	/// This calls on reghdfe. Absorbs all the variables declared
	 scale(real 1)  /// Changes the scale of the RIF. Useful for statistics like GINI and Lorenz ordinate, as they are measured between 0-1
	 iseed(str)     /// Using this, a random variable is created to "sort" data, and avoid (or reduce) the impact of ties, making the results replicable
	 over(varname)  /// Indicates to estimate the RIF over two groups. This is can be considered as a partially conditional model. (it is conditional on one variable only)
	 rwlogit(str)   rwprobit(str)  /// This two options are used to estimate the IPW. 
	 rwmlogit(str)  rwmprobit(str)  /// This two options are used to estimate the IPW. 
	 ate att atu  /// This indicates which estimator will be done. I would assume ate to be the default
	  ]
	  /// allows using SVY for regressions.svy  THis will be done within
 marksample touse
 markout   `touse' `anything' `abs' `rwprobit' `rwlobit' `over'  `rwmprobit' `rwmlobit'

qui {
    * y and x's
	tokenize `anything'
	local y `1'
	macro shift
	local rest `*'
	** check fgreg to change names of created variables
	tempvar rifvar
	local expx=regexr("`exp'","=","")
	if "`expx'"=="" local expx=1
	tempvar exp2
	gen double `exp2'=`expx'
	** We first need to see if the probit model needs to be estimated
	if (("`rwlogit'"!="")+("`rwprobit'"!="")+("`rwmlogit'"!="")+("`rwmprobit'"!=""))>1 {
	  noisily: display in red "Only one probability model can be set. Choose either logit, probit, mlogit or mprobit  for the first stage"
	  exit
	}
	
	*** Over should be a 0 1 variable.
	*if "`rwlogit'"=="" {	}
	
	if "`rwlogit'"!="" | "`rwprobit'"!="" {
	   if "`over'"=="" {
	     display in red "Over option required to define dependent variable in probit/logit"
	     exit
	   }
	   if (("`ate'"!="") + ("`att'"!="")+("`atu'"!=""))>1 {
	     noisily: display in red "Only one option allowed. Choose ate, att or atu" 
		 exit
	   }
	   if "`ate'`att'`atu'"=="" {
	    noisily: display "Neither ate att or atu were selected. Using default average treatment effect  ate"
		local ate ate
	   }
	 
	   tempvar dy
	   qui:egen `dy'=group(`over') if `touse'
	   qui:sum `dy' if `touse'
		if r(max)>2 {
		  noisily:display in red "More than 2 groups detected. Only 2 groups allowed for the estimator"
		  exit
		}
		qui:replace `dy'=`dy'==2
		
		if "`rwprobit'"!="" {
			qui:probit `dy' `rwprobit' [pw=`exp2'] if `touse'==1
			tempvar pr
			qui:predict double `pr', pr
			tempname b_rw v_rw
			matrix `b_rw'=e(b)
			matrix `v_rw'=e(V)
			local rwmodel="probit"
 		}
		if "`rwlogit'"!="" {
			qui:logit `dy' `rwlogit' [pw=`exp2'] if `touse'==1
			tempvar pr
			qui:predict double `pr', pr
			tempname b_rw v_rw
			matrix `b_rw'=e(b)
			matrix `v_rw'=e(V)
			local rwmodel="logit"
		}
		** here were do the IPW estimators
		tempvar ipw
		qui:gen double `ipw'=(`dy'==1)/`pr'+(`dy'==0)/(1-`pr')   if `touse'==1
	   if "`att'"!="" {
	       qui:replace `ipw'=`ipw'*`pr'
	   }
	   if "`atu'"!="" {
	       qui:replace `ipw'=`ipw'*(1-`pr')
	   }
	   * finally we adjust weights
	   replace `exp2'=`exp2'*`ipw'
	   local weight pw
	   local flag_ipw 1
	} 
	**********************************************************************************************
	* THis will do the multivalued treatment effect
	if "`rwmlogit'"!="" | "`rwmprobit'"!="" {
	   if "`over'"=="" {
	     display in red "Over option required to define dependent variable in mprobit/mlogit"
	     exit
	  }
	  if ("`atu'"!="") | ("`att'"!="") {
	     noisily: display in red "ATU or ATT cannot be specified" 
		 exit
	  }
	  	 
	  tempvar dy
	   	qui:egen `dy'=group(`over') if `touse'
		qui:sum `dy'
		local maxv=r(max)
		if "`rwmprobit'"!="" {
			qui:mprobit `dy' `rwmprobit' [pw=`exp2'] if `touse'==1
			forvalues i =1/`maxv' {
				tempvar pr`i'
				qui:predict double `pr`i'', pr eq(`i')
			}
			tempname b_rw v_rw
			matrix `b_rw'=e(b)
			matrix `v_rw'=e(V)
			local rwmodel="mprobit"
 		}
		if "`rwmlogit'"!="" {
			qui:mlogit `dy' `rwmlogit' [pw=`exp2'] if `touse'==1
			forvalues i =1/`maxv' {
				tempvar pr`i'
				qui:predict double `pr`i'', pr eq(`i')
			}
			tempname b_rw v_rw
			matrix `b_rw'=e(b)
			matrix `v_rw'=e(V)
			local rwmodel="mlogit"
		}
		** here were do the IPW estimators
		tempvar ipw
		qui:gen double `ipw'=0
		forvalues i =1/`maxv' {
			replace `ipw'=`ipw'+(`dy'==`i')*1/`pr`i''
		}		
		
 
	   * finally we adjust weights
	   replace `exp2'=`exp2'*`ipw'
	   local weight pw
	   local flag_ipw 1
	} 
	
	** just adds an over. For a more semiparametric, perhaps we can add a smoother parameter. 
	qui:egen double `rifvar'=rifvar(`y') if `touse', weight(`exp2') `rif' seed(`iseed') by(`over')
	** scale is used to rescale data to make it easier to read. May be important for share based statistics
	** and Gini
	* MAy also help with poverty indices, if the aim is to find an average gap not as percentage but in poverty line terms.
	qui:replace `rifvar'=`rifvar'*`scale'
	if "`retain'"!="" {
		if "`replace'"!="" {
			capture:gen double `retain'=`rifvar'
			capture:replace    `retain'=`rifvar'
			local vnm:variable label `rifvar'
			label var `retain' "`vnm'"
		}
		else {
			gen double `retain'=`rifvar'
			local vnm:variable label `rifvar'
			label var `retain' "`vnm'"
		}
	}
	
	** changing weight type at the end.

	qui sum `rifvar' [aw=`exp2'] if `touse'
	local rifmean=r(mean)
	if "`flag_ipw'"=="" {
		if "`abs'"=="" {
			qui:regress `rifvar' `rest' if `touse' [`weight'`exp'], `options'
			ereturn local depvar		`y'
			ereturn local cmd			rifhdreg
			ereturn local cmdline		rifhdreg `0'
			ereturn local predict 		rif_p
			ereturn local rif			`rif'
			*ereturn local rifwgt		`expx'
			ereturn local rifover		`over'
			ereturn scalar rifscale =	`scale'
			ereturn scalar rifmean  =	`rifmean'
		}
		else  {
			qui:reghdfe `rifvar' `rest' if `touse' [`weight'`exp'], `options' abs(`abs')
			ereturn local depvar		`y'
			ereturn local cmd			rifhdreg
			ereturn local cmdline		rifhdreg `0'
			ereturn local cmd2			rifhdreg2
			ereturn local rif			`rif'
			*ereturn local rifwgt		`expx'
			ereturn local rifover		`over'
			ereturn scalar rifscale =	`scale'			
			ereturn scalar rifmean  =	`rifmean'
		}
	}
	** For Reweighted Add some info about the model Like in oaxaca
	else {
		capture drop _wipw_
		gen double _wipw_=`exp2'
		label var _wipw_ "IPW estimated through rifhdreg "
		if "`abs'"=="" {
			qui:regress `rifvar' `rest' if `touse' [`weight'=_wipw_], `options'
			ereturn local depvar		`y'
			ereturn local cmd			rifhdreg
			ereturn local cmdline		rifhdreg `0'
			ereturn local rif			`rif'
			ereturn local rifwgt		_wipw_
			ereturn local rifover		`over'
			ereturn local rwmethod 		`rwmodel'
			ereturn local rifteff 		`ate'`att'`atu'
			ereturn scalar rifscale =	`scale'			
			ereturn scalar rifmean  =	`rifmean'
			ereturn matrix b_rw=		`b_rw'
			ereturn matrix V_rw=		`v_rw'
		}
		else  {
			qui: reghdfe `rifvar' `rest' if `touse' [`weight'=_wipw_], `options' abs(`abs')
			ereturn local depvar		`y'
			ereturn local cmd			rifhdreg
			ereturn local cmdline		rifhdreg `0'
			ereturn local cmd2			rifhdreg2
			ereturn local rifwgt 		_wipw_
			ereturn local rif			`rif'
			ereturn local rifover		`over'
			ereturn local rwmethod 		`rwmodel'
			ereturn local rifteff 		`ate'`att'`atu'
			ereturn scalar rifscale =	`scale'			
			ereturn scalar rifmean  =	`rifmean'
			ereturn matrix b_rw=		`b_rw'
			ereturn matrix V_rw=		`v_rw'
		}
	}	
  }

** display
	results
end



capture program drop results
program results, eclass
        if "`e(cmd)'"=="rifhdreg" & "`e(cmd2)'"=="" {
		reg 
		display "Distributional Statistic: `e(rif)'"
		display "Sample Mean	RIF `e(rif)' : "  in ye %7.5g e(rifmean)
		}
		else if "`e(cmd)'"=="rifhdreg" & "`e(cmd2)'"=="rifhdreg2"  {
		ereturn local cmd ="reghdfe"
		reghdfe
		ereturn local cmd="rifhdreg"
		display "Distributional Statistic: `e(rif)'"
		display "Sample Mean	RIF `e(rif)' : "  in ye %7.5g e(rifmean)
		}
		else display in red "last estimates not found"
end
