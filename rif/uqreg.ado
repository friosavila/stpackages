
*! December 2019 Fernando Rios Avila
* This command would estimate ONLY UQR. but flexible because of LOGIT PROBIT SCOBIT CLOGLOG etc 
* lets make it so it already allows for multiple Qts? No. Since it uses suest, that cant be done i think.
* This will be a stand alone comand. I cant call for grif var
*capture program drop uqreg
program uqreg, eclass sortpreserve byable(recall) properties( svyb )
    if replay() {
		results_uqr
        exit
    }
syntax anything [if] [in] [aw fw iw pw], q(str)  [,* ] [bw(str) kernel(str) method(str) methodcmd(str) methodopt(str) Noisily nose]  
 marksample touse
 markout   `touse' `anything' `abs' `over'
 
qui {
	 
    * y and x's
	tokenize `anything'
	local y `1'
	macro shift
	local rest `*'
	** check fgreg to change names of created variables
	tempvar rifvar
	local exp2=regexr("`exp'","=","")
	if "`exp2'"=="" local exp2=1

	** just adds an over. For a more semiparametric, perhaps we can add a smoother parameter. 
	* CHECKING FOR METHOD
	if "`method'"=="" {
	noisily:display in red "No method selected. Need to choose some method for the UQr estimation, such as regress, logit, probit, scobit, cloglog"
	exit
	}
	**********************************************************************************************************************
	  numlist "`q'", min(1) max(1)  range(>0 <100)
	  sort `touse' `over' `sortseed'
	  if "`over'"!="" 		levelsof `over' if `touse', local(nby)
	  else {
	  tempvar over
	  gen byte `over'=1
	  levelsof `over' if `touse', local(nby)
	  }
	  tempvar qvar fqvar qvar2 fqvar2
	  qui:gen byte `qvar2'=.
	  qui:gen double `fqvar2'=.
	  if "`kernel'"=="" {
		local kernel="gaussian"
	  }
	  
 	  if "`bw'"!="" {
		numlist "`bw'", min(1) max(1) range(>0)
	  }
	  
	  foreach k of local nby {
	    ** For now we use Gaussian as default, but open to change.
		*display "`nby'"
		qui:capture drop `qvar'  `fqvar'
		*obtain the Quantiles of interest (sample quantile)
		*May change to be predicted quantile
		_pctile `y' [aw=`exp2'] if float(`over')==float(`k') & `touse'==1, p(`q')
		gen `qvar'=r(r1) in 1 
		replace `qvar2'=r(r1) if float(`over')==float(`k') & `touse'==1
		* If bw is declared, then estimate density at qvar using BW and Kernel
		if "`bw'"!="" {
			kdensity `y' [aw=`exp2'] if float(`over')==float(`k') & `touse'==1 , nograph kernel(`kernel') at(`qvar') gen(`fqvar') bw(`bw')
			replace `fqvar2'=`fqvar'[1] if float(`over')==float(`k') & `touse'==1
		}
		else {
			* Using sivermans plug in. If no BW is selected
			qui:sum `y' [aw=`exp2'] if float(`over')==float(`k') &  `touse',d
			local sd=r(sd)
			local intqr=(r(p75)-r(p25))/1.349
			local Nobs=r(N)
			local ss=min(`sd',`intqr')
			** Other Kernels can be accomodated but for now only this
			if "`kernel'"=="gaussian" 	local d=(1/(4*_pi))^.1
			if "`kernel'"=="epan"   	local d=(3/(5*sqrt(5)))^(1/5)
			if "`kernel'"=="epan2" 		local d=15^.2
			if "`kernel'"=="biweight"  	local d=35^.2
			if "`kernel'"=="cosine" 	local d=(6/(1/6-1/_pi^2)^2)^.2
			if "`kernel'"=="parzen"		local d=2*(151/35)^.2
			if "`kernel'"=="rectan" 	local d=(9/2)^.2
			if "`kernel'"=="triangle"	local d=24^.2
			if "`kernel'"=="triweight" 	local d=(9450/143)^.2
			*silverman bw
			local bw=1.3643*`d'*`Nobs'^-.2*`ss'
			*with BW we can again estimate f(x) using kdensity
			kdensity `y' [aw=`exp2'] if float(`over')==float(`over') & `touse'==1 , nograph kernel(`kernel') at(`qvar') gen(`fqvar') bw(`bw')
			replace `fqvar2'=`fqvar'[1] if float(`over')==float(`over') & `touse'==1

		}
		* This is how FFL define the RIF. 
		
		* I can define it slighly different. If qvar==qvar_th, then there should be nochanges
		* in the Quantile. Exactly at the quantile should have no effect on the RIF of that quantile
		* replace `varlist'=`qvar'[1]  if float(`by')==float(`k') & float(`exp')==float(`qvar'[1]) & `touse'==1
		* However, if they have no effect on the sample quantile, they may affect the Population quantile
		* I will consider adding a predictive option "qden" so that the quantile can obtained from the smooth values
  	   }
	
		gen byte `rifvar'=`y'>=`qvar2'
		qui:`noisily' `method' `rifvar' `rest' if `touse' [`weight'`exp'], `options' 
 		capture:margins, dydx(*) `se' expression(1/`fqvar2'*predict(pr)) post 
		if scalar(_rc)==198  capture:margins, dydx(*) `se' expression(1/`fqvar2'*predict(xb)) post 
		ereturn local depvar="RIF(`y')"
		ereturn local cmd="uqreg"
		ereturn local cmdline="uqreg `0'"
		ereturn local rif="q(`q')"
		ereturn local method="`method'"

  }
** display
	results_uqr
end

*capture program drop results_uqr
program results_uqr, eclass
        if "`e(cmd)'"=="uqreg"  {
			ereturn display
			display "Distributional Statistic: `e(rif)'"
		}
		else {
		    display in red "last estimates not found"
			error 301
		}	
end
