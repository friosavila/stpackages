*! version 2.61 April 2020 Fernando Rios-Avila
* Minor ineficiencies fixed. Sort when not needed.
* consider adjusting pvar so is fixed by income level? It may be more important when wages are involved.
* version 2.6 September 2019 Fernando Rios-Avila
* Adds options q2 iqr2 iqratio2. This allow for IF=0 when y=q(p)
* version 2.5 July 2019 Fernando Rios-Avila
* Add option for userwritten RIF
* version 2.4 March 2019 Fernando Rios-Avila
* minor changes on how UQR RIfs are saved
* Needs improvement in code for faster calculations in large datasets
* Add Sortseed to have replicable results. Important for rank dependent indices with ties, and for share variables that depend on percentile not quantile.
* Using percentile, depending on "weights" the SHARE may change because of the marginal individual. 
* version 2.3 March 2019 Fernando Rios-Avila
* All indices have been tested for by option, and simulations for covariances
* version 2.2 March 2019 Fernando Rios-Avila
* This version cleans up some of the references and adds on last RIFS
* version 2.1 Feb 2019 Fernando Rios-Avila
* This version does most RIF's in the literature except for the propoor growth elasticities. 
* version 2.0 Jan 2019 
* This version adds the RIFS from RIF-I-O to the program
* Still by able
* version 1.0 Dec 2018
* This file is used to create RIF variables for various distributional statistics
* Their output (constrained on the correct sample) can be used to obtain results similar to
* RIFREG from Firpo Fortin Lemieux.
* Here, the variables are created across groups.
* the RIF gini was taken from RIF reg code. 
* Quantiles, var and mean are taken from FFL(2018) (decomposition using RIFS)
* Poverty is based on Essama-Nssah, B. and Lambert, P. J. (2012),
* Entropy and Atkinson indices are constructed based on Cowell, F. A. and Flachaire, E. (2007),
* other statistics from Gawain Heckley RIFIREG  HEckley Gerdthan and Kjellson
* Others from 
* Needs some Flags to avoid "noncompatible" options.
* Potential to add other methods

** Future Versions Cowel 2015
** Mean Deviation
** Pietra index
** Perhaps Half variance 
** Sen Sorrocks inequality

** ucs mcs
*capture program drop _grifvar
program define _grifvar_old, sortpreserve
	version 8
	* Syntax sextion. Indicates what can be used and what cannot
	syntax newvarname =/exp [if] [in] ,  					///
	[, weight(varname) BY(varlist) 							/// This are options for allowing for sample weights and BY groups
	gini mean var cvar std q(str) iqr(str) kernel(str) bw(str)	/// Thes are options for basic RIFS See FFL(2018) Kernel and bw are optional.
	iqratio(str) ginismall q2(str) iqr2(str) iqratio2(str)	/// This comes from Choe Van Kerm 2018, im also adding q2, as a better alternative than q when there are ties.
	glor(str) lor(str) ucs(str) iqsr(str) mcs(str)			/// This will contain the options from Essama-NssahLambert Lorenz Glorenz and IQRS (me?)
	pov(str) pline(str) watts(str) sen(str) tip(str) 		/// This will contain the options from Essama-NssahLambert  
	entropy(str) atkin(str) logvar   						/// This are RIFS from Cowell Flachaire (2007) There are other couple from Cowell 2015 
	agini giniold											/// This are RIFS from HEckley Gerdthan and Kjellson Only one that is rank independent
	acindex(str) cindex(str) 								/// This are RIFS from HEckley Gerdthan and Kjellson which are Rank Dependent
	eindex(str) arcindex(str) srindex(str) windex(str) ub(str) lb(str) hvarp hvarn seed(str) /// This are RIFS from Heckley Gerdthan and Kjellson  which are Rank Dependent and with additional information
	rifown(str) rifopt(str)]  
															/// hvarp and hvarn are semivariances or half variances implement by LOO
															/// ginismall better GINI for small samples undocumented
	** Data cleaning before syntax
	* This cleans the "exp" from paranthesis or spaces. Just handy
	local exp = regexr("`exp'", "\(", "")
	local exp = regexr("`exp'", "\)", "")
	local exp = regexr("`exp'", " ", "")
	
	tempvar touse 
	quietly {
		gen byte `touse'=0
		replace  `touse'=1 `if' `in' 
		if "`weight'"!="" {
			replace `touse'=0 if `weight'==.
		}
		if "`by'"!="" {
			replace `touse'=0 if `by'==.
		}
	   replace `touse'=0 if `exp'==.
	** This checks how many options have been selected	Only 1 option is allowed
	local d=("`gini'"!="")+("`ginismall'"!="")+("`mean'"!="")+("`var'"!="")+("`std'"!="")+("`cvar'"!="")+("`q'"!="")+("`q2'"!="")+("`iqr'"!="")+("`iqr2'"!="")+("`iqratio'"!="")+ ///
	        ("`glor'"!="")+("`lor'"!="")+("`ucs'"!="")+("`iqsr'"!="")+("`mcs'"!="")+("`pov'"!="")+("`entropy'"!="")+("`atkin'"!="")+ /// 
			("`agini'"!="")+("`acindex'"!="")+("`cindex'"!="")+("`eindex'"!="")+("`logvar'"!="")+("`giniold'"!="")+ ///
			("`watts'"!="")+("`sen'"!="")+("`tip'"!="")+("`arcindex'"!="")+("`srindex'"!="")+("`windex'"!="")+("`rifown'"!="")
	
	if `d'>1  {
	display in red "Only one option allowed"
	exit
	}
	if `d'==0 {
	display in red "Need to specify at least one option"
	}
	local fweight=1
	if "`weight'"=="" {
	   local weight=1
	   local fweight=0
	}
	
	if "`by'"=="" {
	  tempvar by
	  gen byte `by'=1
	}
	
	local sysseed=c(seed)
	
	if "`seed'"!="" {
		tempvar sortseed
		set seed `seed'
		qui:gen double `sortseed'=rnormal()
	}
	*noisily sum `sortseed'
	
	** This section will Test if the options are correctly specified. Right now only checks for poverty
	if "`pov'"!="" {
	   if "`pline'"=="" {
	   display "Requires to specify a poverty line (value or variable)"
	   exit
	   }
	}
	** RIF of Mean its the variable itself. Default option.
	if ("`mean'"!="") {
	* uses default mean
	 qui:gen `typlist' `varlist'=`exp' if `touse'
	 label var `varlist' "RIF for Mean of `exp'"
	}
	** RIF of variance
	if "`var'"!="" {
		** First need to sort data and get weighted mean by group.
		sort `touse' `by'   `sortseed'
		tempvar mx
		qui: by `touse' `by': gen double `mx' = sum(`exp'*`weight')/sum(`weight') if `touse'
		qui: by `touse' `by': gen `typlist' `varlist' = (`exp'-`mx'[_N])^2       if `touse'
		label var `varlist' "RIF for Var of `exp'"
	}
	** RIF of quantile
	if "`q'"!="" {
	  numlist "`q'", min(1) max(1)  range(>0 <100)
	  sort `touse' `by'  `sortseed'
	  levelsof `by' if `touse', local(nby)
	  tempvar qvar fqvar
	   qui:gen `typlist' `varlist'=.
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
		_pctile `exp' [aw=`weight'] if float(`by')==float(`k') & `touse'==1, p(`q')
		gen `qvar'=r(r1) in 1 
		* If bw is declared, then estimate density at qvar using BW and Kernel
		if "`bw'"!="" {
			kdensity `exp' [aw=`weight'] if float(`by')==float(`k') & `touse'==1 , nograph kernel(`kernel') at(`qvar') gen(`fqvar') bw(`bw')
		}
		
		else {
			* Using sivermans plug in. If no BW is selected
			qui:sum `exp' [aw=`weight'] if float(`by')==float(`k') &  `touse',d
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
			kdensity `exp' [aw=`weight'] if float(`by')==float(`k') & `touse'==1 , nograph kernel(`kernel') at(`qvar') gen(`fqvar') bw(`bw')
		}
		* This is how FFL define the RIF. 
		replace `varlist'=`qvar'[1]+(`q'/100-(`exp'<`qvar'[1]))/`fqvar'[1] if float(`by')==float(`k') & `touse'==1   
		* I can define it slighly different. If qvar==qvar_th, then there should be nochanges
		* in the Quantile. Exactly at the quantile should have no effect on the RIF of that quantile
		* replace `varlist'=`qvar'[1]  if float(`by')==float(`k') & float(`exp')==float(`qvar'[1]) & `touse'==1
		* However, if they have no effect on the sample quantile, they may affect the Population quantile
		* I will consider adding a predictive option "qden" so that the quantile can obtained from the smooth values
	 }
	 local bbw=round(`bw',0.00001)
  	 label var `varlist' "RIF for q(`q') with kernel(`kernel') of `exp' with bw `bbw'" 
	}
	
		** RIF of quantile2 for ties
	if "`q2'"!="" {
	  numlist "`q2'", min(1) max(1)  range(>0 <100)
	  sort `touse' `by'   `sortseed'
	  levelsof `by' if `touse', local(nby)
	  tempvar qvar fqvar
	   qui:gen `typlist' `varlist'=.
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
		_pctile `exp' [aw=`weight'] if float(`by')==float(`k') & `touse'==1, p(`q2')
		gen `qvar'=r(r1) in 1 
		* If bw is declared, then estimate density at qvar using BW and Kernel
		if "`bw'"!="" {
			kdensity `exp' [aw=`weight'] if float(`by')==float(`k') & `touse'==1 , nograph kernel(`kernel') at(`qvar') gen(`fqvar') bw(`bw')
		}
		
		else {
			* Using sivermans plug in. If no BW is selected
			qui:sum `exp' [aw=`weight'] if float(`by')==float(`k') &  `touse',d
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
			kdensity `exp' [aw=`weight'] if float(`by')==float(`k') & `touse'==1 , nograph kernel(`kernel') at(`qvar') gen(`fqvar') bw(`bw')
		}
		* This is how FFL define the RIF. 
		replace `varlist'=`qvar'[1]+(`q2'/100-(`exp'<`qvar'[1]))/`fqvar'[1] if float(`by')==float(`k') & `touse'==1   
		replace `varlist'=`qvar'[1] if float(`by')==float(`k') & `touse'==1  &  (float(`exp')==float(`qvar'[1]))
		 
		* I can define it slighly different. If qvar==qvar_th, then there should be nochanges
		* in the Quantile. Exactly at the quantile should have no effect on the RIF of that quantile
		* replace `varlist'=`qvar'[1]  if float(`by')==float(`k') & float(`exp')==float(`qvar'[1]) & `touse'==1
		* However, if they have no effect on the sample quantile, they may affect the Population quantile
		* I will consider adding a predictive option "qden" so that the quantile can obtained from the smooth values
	 }
	 local bbw=round(`bw',0.00001)
  	 label var `varlist' "RIF for q2(`q2') with kernel(`kernel') of `exp' with bw `bbw'" 
	}
	

	 
	** RIF for interquantile difference
	if "`iqr'"!="" {
	  sort `touse' `by'  `sortseed'
	  tempvar qvar fqvar
	  tempvar qlow qhigh
	  qui: capture drop `varlist'
	  qui:gen `typlist' `varlist'=.
	  qui:gen `typlist' `qlow'=.
	  qui:gen `typlist' `qhigh'=.
	  
	  if "`kernel'"=="" {
		local kernel="gaussian"
	  }
 	  if "`bw'"!="" {
		numlist "`bw'", min(1) max(1) range(>0)
	  }
	  
	  levelsof `by' if `touse', local(nby)
	  numlist "`iqr'", min(2) max(2) sort range(>0 <100)
	  local i0:word 1 of `r(numlist)'
	  local i1:word 2 of `r(numlist)'
	  *foreach i in  `r(numlist)' {
	  ** Same process as with q, but for 2 points 
	  local bwo="`bw'"
	    foreach k of local nby {
	    ** For now we will just use Gaussian, but open to change.
			qui:capture drop `qvar'  `fqvar'
			_pctile `exp' [aw=`weight'] if float(`by')==float(`k') & `touse', p(`i0'  `i1')
			qui:gen `qvar'=r(r1) in 1 
			qui:replace `qvar'=r(r2) in 2
			if "`bwo'"!="" {
				kdensity `exp' [aw=`weight'] if float(`by')==float(`k') & `touse'==1 , nograph kernel(`kernel') at(`qvar') gen(`fqvar') bw(`bw')
			}
			
			else {
				* Using sivermans plug in. Same BW for both points
				qui:sum `exp' [aw=`weight'] if float(`by')==float(`k') & `touse'==1,d
				local sd=r(sd)
				local intqr=(r(p75)-r(p25))/1.349
				local Nobs=r(N)
				local ss=min(`sd',`intqr')
				*noisily display "sd:`sd' intqr:`intqr' nobs: `Nobs' ss:`ss'"
				if "`kernel'"=="gaussian" 	local d=(1/(4*_pi))^.1
				if "`kernel'"=="epan"   	local d=(3/(5*sqrt(5)))^(1/5)
				if "`kernel'"=="epan2" 		local d=15^.2
				if "`kernel'"=="biweight"  	local d=35^.2
				if "`kernel'"=="cosine" 	local d=(6/(1/6-1/_pi^2)^2)^.2
				if "`kernel'"=="parze" 		local d=2*(151/35)^.2
				if "`kernel'"=="rectan" 	local d=(9/2)^.2
				if "`kernel'"=="triangle" 		local d=24^.2
				if "`kernel'"=="triweight" 	local d=(9450/143)^.2
				*silverman bw
				local bw=1.3643*`d'*`Nobs'^-.2*`ss'
 				kdensity `exp' [aw=`weight'] if float(`by')==float(`k') & `touse'==1 , nograph kernel(`kernel') at(`qvar') gen(`fqvar') bw(`bw')
			}
			
			* see above for discussion on the commented step.
			qui:replace `qlow' =`qvar'[1]+(`i0'/100-(`exp'<`qvar'[1]))/`fqvar'[1]  if float(`by')==float(`k') & `touse'==1   
			*qui:replace `qlow'=`qvar'[1] 										    if float(`by')==float(`k') & float(`exp')==float(`qvar'[1]) & `touse'==1  
			qui:replace `qhigh' =`qvar'[2]+(`i1'/100-(`exp'<`qvar'[2]))/`fqvar'[2] if float(`by')==float(`k') & `touse'==1   
			*qui:replace `qhigh'=`qvar'[2] 									 	    if float(`by')==float(`k') & float(`exp')==float(`qvar'[2]) & `touse'==1  
		}	  
	 * For Replacing IF for IQR 
	   qui:replace  `varlist'=`qhigh'-`qlow' if `touse'  
       local bbw=round(`bw',0.00001)
	   label var `varlist' "RIF for Interquantile difference(`i1' `i0') of `exp' with bw `bbw'"
	 }
	*** like IQR but allows for ties
	if "`iqr2'"!="" {
	  sort `touse' `by'   `sortseed'
	  tempvar qvar fqvar
	  tempvar qlow qhigh
	  qui: capture drop `varlist'
	  qui:gen `typlist' `varlist'=.
	  qui:gen `typlist' `qlow'=.
	  qui:gen `typlist' `qhigh'=.
	  
	  if "`kernel'"=="" {
		local kernel="gaussian"
	  }
 	  if "`bw'"!="" {
		numlist "`bw'", min(1) max(1) range(>0)
	  }
	  
	  levelsof `by' if `touse', local(nby)
	  numlist "`iqr2'", min(2) max(2) sort range(>0 <100)
	  local i0:word 1 of `r(numlist)'
	  local i1:word 2 of `r(numlist)'
	  *foreach i in  `r(numlist)' {
	  ** Same process as with q, but for 2 points 
	  local bwo="`bw'"
	    foreach k of local nby {
	    ** For now we will just use Gaussian, but open to change.
			qui:capture drop `qvar'  `fqvar'
			_pctile `exp' [aw=`weight'] if float(`by')==float(`k') & `touse', p(`i0'  `i1')
			qui:gen `qvar'=r(r1) in 1 
			qui:replace `qvar'=r(r2) in 2
			if "`bwo'"!="" {
				kdensity `exp' [aw=`weight'] if float(`by')==float(`k') & `touse'==1 , nograph kernel(`kernel') at(`qvar') gen(`fqvar') bw(`bw')
			}
			
			else {
				* Using sivermans plug in. Same BW for both points
				qui:sum `exp' [aw=`weight'] if float(`by')==float(`k') & `touse'==1,d
				local sd=r(sd)
				local intqr=(r(p75)-r(p25))/1.349
				local Nobs=r(N)
				local ss=min(`sd',`intqr')
				*noisily display "sd:`sd' intqr:`intqr' nobs: `Nobs' ss:`ss'"
				if "`kernel'"=="gaussian" 	local d=(1/(4*_pi))^.1
				if "`kernel'"=="epan"   	local d=(3/(5*sqrt(5)))^(1/5)
				if "`kernel'"=="epan2" 		local d=15^.2
				if "`kernel'"=="biweight"  	local d=35^.2
				if "`kernel'"=="cosine" 	local d=(6/(1/6-1/_pi^2)^2)^.2
				if "`kernel'"=="parze" 		local d=2*(151/35)^.2
				if "`kernel'"=="rectan" 	local d=(9/2)^.2
				if "`kernel'"=="triangle" 		local d=24^.2
				if "`kernel'"=="triweight" 	local d=(9450/143)^.2
				*silverman bw
				local bw=1.3643*`d'*`Nobs'^-.2*`ss'
 				kdensity `exp' [aw=`weight'] if float(`by')==float(`k') & `touse'==1 , nograph kernel(`kernel') at(`qvar') gen(`fqvar') bw(`bw')
			}
			
			* see above for discussion on the commented step.
			qui:replace `qlow' =`qvar'[1]+(`i0'/100-(`exp'<`qvar'[1]))/`fqvar'[1]  if float(`by')==float(`k') & `touse'==1   
			qui:replace `qlow'=`qvar'[1] 										   if float(`by')==float(`k') & float(`exp')==float(`qvar'[1]) & `touse'==1  
			qui:replace `qhigh' =`qvar'[2]+(`i1'/100-(`exp'<`qvar'[2]))/`fqvar'[2] if float(`by')==float(`k') & `touse'==1   
			qui:replace `qhigh'=`qvar'[2] 									 	   if float(`by')==float(`k') & float(`exp')==float(`qvar'[2]) & `touse'==1  
		}	  
	 * For Replacing IF for IQR 
	   qui:replace  `varlist'=`qhigh'-`qlow' if `touse'  
       local bbw=round(`bw',0.00001)
	   label var `varlist' "RIF for Interquantile difference(`i1' `i0') of `exp' with bw `bbw'"
	 }
	 

	** RIF of Gini. Last done in FFL 2018. Follows RIFREG code
	/*if "`gini'"=="gini"  {
		 sort `touse' `by' `exp' 
		  qui{
			  *Get totals first
				tempvar glp rnk vcv ggini rf
			  *_prank au1 au2 au3, svar(price) mvar(mpg) tvar(touse)
				_prank `glp' `rnk' `vcv' , svar(`exp') mvar(`exp') tvar(`touse') byvar(`by')
				by `touse' `by':gen double `ggini'=2/`glp'[_N]*`vcv'[_N]           if `touse'
				*by `touse' `by':gen `typlist' `varlist' =`ggini'
				by `touse' `by':gen double `rf' = sum(`glp'*(`rnk'-`rnk'[_n-1]))
				by `touse' `by':gen `typlist' `varlist' =(2/`glp'[_N]*`rf'[_N])*`exp'/`glp'[_N]+2/`glp'[_N]*(`exp'*(`rnk'-1)-`glp') +1 if `touse'

			  *gen pd0 = `rnk'
			  *1-2*`glp'/`glp'[_N]+`exp'*(1-`ggini'-2*(1-`rnk'))/`glp'[_N] if `touse'
			  *by `touse' `by':gen `typlist' `varlist' =(2/`mns'*`rf')*`exp'/`mns'+2/`mns'*(`exp'*(`pvar'-1)-`glp') +1 if `touse'
			  * At some point add :SMALL correction
			  label var `varlist' "RIF for gini of `exp'"
		  }
	 }  */
	 
	if "`gini'"!=""  {
     levelsof `by' if `touse', local(nby)
	 sort `touse' `by' `exp' `sortseed'
	  qui{
      *Get totals first
	  tempvar cum_wt mns cumwy tot_wt pvar padj mns glp rfvar rf ggini
	  tempvar rfx
	  by `touse' `by':gen double `cum_wt'=sum(`weight') 
	  by `touse' `by':gen double `tot_wt'=`cum_wt'[_N]
	  by `touse' `by':gen double `pvar' = `cum_wt'/`tot_wt'   
	  by `touse' `by':gen double `glp'=sum(`exp'*`weight'/`tot_wt')
	  by `touse' `by':gen double `mns'=`glp'[_N]
	  gen double `rfvar'=.
	  by `touse' `by':integ `glp' `pvar', gen(`rfvar') replace
	  by `touse' `by':gen double `rf' =  `rfvar'[_N]
	  by `touse' `by':gen double `ggini'=1-2/`mns'*`rf'            if `touse'
      by `touse' `by':gen `typlist' `varlist' =(2/`mns'*`rf')*`exp'/`mns'+2/`mns'*(`exp'*(`pvar'-1)-`glp') +1 if `touse'
	  * At some point add :SMALL correction
	  label var `varlist' "RIF for gini of `exp'"
      }
	 } 
	 *** This is another variance of GINI. Should give similar results. It creates an adjustment on F(y)
	 *** currently not used
	 if "`ginismall'"=="ginismall"  {
      levelsof `by' if `touse', local(nby)
	  sort `touse' `by' `exp' `sortseed'
	  qui{
      *Get totals first
	  tempvar cum_wt mns cumwy tot_wt pvar mns glp covpx ggini padj
	  tempvar rfx
	  by `touse' `by':gen double `cum_wt'=sum(`weight') 
	  by `touse' `by':gen double `tot_wt'=`cum_wt'[_N]
	  by `touse' `by':gen double `pvar' = `cum_wt'/`tot_wt'   
	  by `touse' `by':gen double `padj' = max(0,`pvar'[_n-1])+((`pvar'-max(0,`pvar'[_n-1]))/2)
	  *egen t1=sum((ix1-4.525895)*(padj-0.5)*(w)/73)
	  gen pd1 = `padj'
	  by `touse' `by':gen double `glp'=sum(`exp'*`weight'/`tot_wt')
	  by `touse' `by':gen double `mns'=`glp'[_N]
	  by `touse' `by':gen double `covpx'=sum((`exp'-`mns')*(`padj'-0.5)*`weight'/`tot_wt')
	  by `touse' `by':gen double `ggini'=2/`mns'*`covpx'[_N]
 	  if `fweight'==1 {
	      by `touse' `by':gen `typlist' `varlist' =1-2*`glp'/`mns'+`exp'*(1-`ggini'-2*(1-`padj'))/`mns' if `touse'
	  }
	  else {
	      by `touse' `by':gen `typlist' `varlist' =1-2*`glp'/`mns'+`exp'*(1-`ggini'-2*(1-`pvar'))/`mns' if `touse'
	  }
	  
	  *by `touse' `by':gen `typlist' `varlist' =1-2*`glp'/`mns'+`exp'*(1-`ggini'-2*(1-`pvar'))/`mns'	  
      label var `varlist' "RIF for gini of `exp'"
      }
	 } 
	 
    ** Coefficient of variation. From Firpo and Pinto(2016)	. I ll set it here because its kind of the baby from FFL
	if "`cvar'"!="" {
	  qui {
  	  sort `touse' `by' `exp' `sortseed'
	  tempvar cum_wt mns mnssq cumwy tot_wt icvar
	  by `touse' `by':gen double `cum_wt'=sum(`weight') 
	  by `touse' `by':gen double `tot_wt'=`cum_wt'[_N]
	  by `touse' `by':gen double `mns'=sum(`exp'*`weight'/`tot_wt')
	  by `touse' `by':replace    `mns'=`mns'[_N]
	  by `touse' `by':gen double `mnssq'=sum(`exp'^2*`weight'/`tot_wt')
	  by `touse' `by':replace    `mnssq'=`mnssq'[_N]
	  *** CV
	  *** RIF
  	  by `touse' `by':gen `typlist' `varlist' =(`mnssq'-`mns'^2)^0.5/`mns'+1/2*((`exp'-`mns')^2-(`mnssq'-`mns'^2))/(`mns'*(`mnssq'-`mns'^2)^.5)-(`exp'-`mns')*(`mnssq'-`mns'^2)^.5/(`mns'^2) if `touse'
      label var `varlist' "RIF for coefficient of variation of `exp'"
	 }
	}
	
	*** standard deviation RIF. Based on CVAR
	if "`std'"!="" {
	  qui {
  	  sort `touse' `by' `exp' `sortseed'
	  tempvar cum_wt mns mnssq cumwy tot_wt icvar
	  by `touse' `by':gen double `cum_wt'=sum(`weight') 
	  by `touse' `by':gen double `tot_wt'=`cum_wt'[_N]
	  by `touse' `by':gen double `mns'=sum(`exp'*`weight'/`tot_wt')
	  by `touse' `by':replace    `mns'=`mns'[_N]
	  by `touse' `by':gen double `mnssq'=sum(`exp'^2*`weight'/`tot_wt')
	  by `touse' `by':replace    `mnssq'=`mnssq'[_N]
	  *** CV
	  *** RIF
  	  by `touse' `by':gen `typlist' `varlist' =(`mnssq'-`mns'^2)^0.5+1/2*((`exp'-`mns')^2-(`mnssq'-`mns'^2))/((`mnssq'-`mns'^2)^.5)  if `touse'
      label var `varlist' "RIF for Standard deviation of `exp'"
	 }
	}
		
	********************************************************************************************************* 
	** This one is from Choe Van Kerm
	** Interquartile Ratio 
	if "`iqratio'"!="" {
	  sort `touse' `by'   `sortseed'
	  tempvar qvar fqvar
	  tempvar qlow qhigh
	  qui: capture drop `varlist'
	  qui:gen `typlist' `varlist'=.
	  qui:gen `typlist' `qlow'=.
	  qui:gen `typlist' `qhigh'=.
	  if "`kernel'"=="" {
		local kernel="gaussian"
	  }
 	  if "`bw'"!="" {
		numlist "`bw'", min(1) max(1) range(>0)
	  }
	  levelsof `by' if `touse', local(nby)
	  numlist "`iqratio'", min(2) max(2) sort range(>0 <100)
	  local i0:word 1 of `r(numlist)'
	  local i1:word 2 of `r(numlist)'
	  ** original bwo
  	  local bwo="`bw'"

	  *foreach i in  `r(numlist)' {
	  ** Same process as with q, but for 2 points 
	    foreach k of local nby {
	    ** For now we will just use Gaussian, but open to change.
			qui:capture drop `qvar'  `fqvar'
			_pctile `exp' [aw=`weight'] if float(`by')==float(`k') & `touse', p(`i0'  `i1')
			qui:gen `qvar'=r(r1) in 1 
			qui:replace `qvar'=r(r2) in 2
			if "`bwo'"!="" {
				kdensity `exp' [aw=`weight'] if float(`by')==float(`k') & `touse'==1 , nograph kernel(`kernel') at(`qvar') gen(`fqvar') bw(`bw')
			}
			else {
				* Using sivermans plug in. Same BW for both points
				qui:sum `exp' [aw=`weight'] if float(`by')==float(`k') & `touse'==1,d
				local sd=r(sd)
				local intqr=(r(p75)-r(p25))/1.349
				local Nobs=r(N)
				local ss=min(`sd',`intqr')
				if "`kernel'"=="gaussian" 	local d=(1/(4*_pi))^.1
				if "`kernel'"=="epan"   	local d=(3/(5*sqrt(5)))^(1/5)
				if "`kernel'"=="epan2" 		local d=15^.2
				if "`kernel'"=="biweight"  	local d=35^.2
				if "`kernel'"=="cosine" 	local d=(6/(1/6-1/_pi^2)^2)^.2
				if "`kernel'"=="parze" 		local d=2*(151/35)^.2
				if "`kernel'"=="rectan" 	local d=(9/2)^.2
				if "`kernel'"=="triangle"   local d=24^.2
				if "`kernel'"=="triweight" 	local d=(9450/143)^.2
				*silverman bw
				local bw=1.3643*`d'*`Nobs'^-.2*`ss'
 				kdensity `exp' [aw=`weight'] if float(`by')==float(`k') & `touse'==1 , nograph kernel(`kernel') at(`qvar') gen(`fqvar') bw(`bw')
			}
			* see above for discussion on the commented step.
			qui:replace `qlow' =(`i0'/100-(`exp'<`qvar'[1]))/`fqvar'[1]  if float(`by')==float(`k') & `touse'==1   
			*qui:replace `qlow'=`qvar'[1] 										    if float(`by')==float(`k') & float(`exp')==float(`qvar'[1]) & `touse'==1  
			qui:replace `qhigh' =(`i1'/100-(`exp'<`qvar'[2]))/`fqvar'[2] if float(`by')==float(`k') & `touse'==1   
			*qui:replace `qhigh'=`qvar'[2] 									 	    if float(`by')==float(`k') & float(`exp')==float(`qvar'[2]) & `touse'==1  
			qui:replace  `varlist'=`qvar'[2]/`qvar'[1]+1/`qvar'[1]*(`qhigh'-`qvar'[2]/`qvar'[1]*`qlow') if float(`by')==float(`k') & `touse'==1
		}	  
	 * For Replacing IF for iqratio 
	    *** Formula is IQR
	    label var `varlist' "RIF for Inter quantile ratio(`i1' `i0') of `exp'"
	 }
	 
	*iqratio2 for ties at q(p)
	if "`iqratio2'"!="" {
	  sort `touse' `by'   `sortseed'
	  tempvar qvar fqvar
	  tempvar qlow qhigh
	  qui: capture drop `varlist'
	  qui:gen `typlist' `varlist'=.
	  qui:gen `typlist' `qlow'=.
	  qui:gen `typlist' `qhigh'=.
	  if "`kernel'"=="" {
		local kernel="gaussian"
	  }
 	  if "`bw'"!="" {
		numlist "`bw'", min(1) max(1) range(>0)
	  }
	  levelsof `by' if `touse', local(nby)
	  numlist "`iqratio2'", min(2) max(2) sort range(>0 <100)
	  local i0:word 1 of `r(numlist)'
	  local i1:word 2 of `r(numlist)'
	  ** original bwo
  	  local bwo="`bw'"

	  *foreach i in  `r(numlist)' {
	  ** Same process as with q, but for 2 points 
	    foreach k of local nby {
	    ** For now we will just use Gaussian, but open to change.
			qui:capture drop `qvar'  `fqvar'
			_pctile `exp' [aw=`weight'] if float(`by')==float(`k') & `touse', p(`i0'  `i1')
			qui:gen `qvar'=r(r1) in 1 
			qui:replace `qvar'=r(r2) in 2
			if "`bwo'"!="" {
				kdensity `exp' [aw=`weight'] if float(`by')==float(`k') & `touse'==1 , nograph kernel(`kernel') at(`qvar') gen(`fqvar') bw(`bw')
			}
			else {
				* Using sivermans plug in. Same BW for both points
				qui:sum `exp' [aw=`weight'] if float(`by')==float(`k') & `touse'==1,d
				local sd=r(sd)
				local intqr=(r(p75)-r(p25))/1.349
				local Nobs=r(N)
				local ss=min(`sd',`intqr')
				if "`kernel'"=="gaussian" 	local d=(1/(4*_pi))^.1
				if "`kernel'"=="epan"   	local d=(3/(5*sqrt(5)))^(1/5)
				if "`kernel'"=="epan2" 		local d=15^.2
				if "`kernel'"=="biweight"  	local d=35^.2
				if "`kernel'"=="cosine" 	local d=(6/(1/6-1/_pi^2)^2)^.2
				if "`kernel'"=="parze" 		local d=2*(151/35)^.2
				if "`kernel'"=="rectan" 	local d=(9/2)^.2
				if "`kernel'"=="triangle" 		local d=24^.2
				if "`kernel'"=="triweight" 	local d=(9450/143)^.2
				*silverman bw
				local bw=1.3643*`d'*`Nobs'^-.2*`ss'
 				kdensity `exp' [aw=`weight'] if float(`by')==float(`k') & `touse'==1 , nograph kernel(`kernel') at(`qvar') gen(`fqvar') bw(`bw')
			}
			* see above for discussion on the commented step.
			qui:replace `qlow' =(`i0'/100-(`exp'<`qvar'[1]))/`fqvar'[1]  if float(`by')==float(`k') & `touse'==1   
			qui:replace `qlow'=`qvar'[1] 										    if float(`by')==float(`k') & float(`exp')==float(`qvar'[1]) & `touse'==1  
			qui:replace `qhigh' =(`i1'/100-(`exp'<`qvar'[2]))/`fqvar'[2] if float(`by')==float(`k') & `touse'==1   
			qui:replace `qhigh'=`qvar'[2] 									 	    if float(`by')==float(`k') & float(`exp')==float(`qvar'[2]) & `touse'==1  
			qui:replace  `varlist'=`qvar'[2]/`qvar'[1]+1/`qvar'[1]*(`qhigh'-`qvar'[2]/`qvar'[1]*`qlow') if float(`by')==float(`k') & `touse'==1
		}	  
	 * For Replacing IF for iqratio 
	    *** Formula is IQR
	    label var `varlist' "RIF for Inter quantile ratio(`i1' `i0') of `exp'"
	 }
	*********************************************************************************************************
	** From here on it follows ESSANNA Lambert 
	** RIF for Glorenz  
	 if "`glor'"!="" {
	 *technically for glor=100 we get th mean, which reverts to the default case i think.
		numlist "`glor'", min(1) max(1)  range(>0 <100)
		levelsof `by' if `touse', local(nby)
		sort `touse' `by' `exp' `sortseed'
		tempvar qvar
		qui:gen `typlist' `varlist'=.
		foreach k of local nby {
	    	qui:capture drop `qvar'   
			_pctile `exp' [aw=`weight'] if float(`by')==float(`k') & `touse', p(`glor')
		    qui:gen `qvar'=r(r1) in 1 
		 ** need qntl done above and glp? Lets assume not for now.
		   	replace `varlist'=`exp'-(1-`glor'/100)*`qvar'[1] if float(`by')==float(`k') & `exp'<`qvar'[1]  & `touse'
		    replace `varlist'= `glor'/100*`qvar'[1]          if float(`by')==float(`k') & `exp'>=`qvar'[1] & `touse'
		}
		 
		label var `varlist' "RIF for Glorenz ordinate at p(`glor') of `exp'"
	}
	** RIF lorenz 
	** Im erasing the _n-1 for the lorenz Cant remember why i put it there to begin with
    if "`lor'"!="" {
       numlist "`lor'", min(1) max(1)  range(>0 <100)
	   local lorp=`lor'/100
       levelsof `by' if `touse', local(nby)
	   sort `touse' `by' `exp' `sortseed'
	   tempvar qvar cum_wt glp lpc mu lpcp
	   qui:gen `typlist' `varlist'=.
       by `touse' `by':gen double `cum_wt'=sum(`weight') 
	   by `touse' `by':gen double `glp'=sum(`exp'*`weight'/`cum_wt'[_N])
  	   by `touse' `by':gen double `mu'=`glp'[_N]

	   ** lorenz Truncated
	   by `touse' `by':gen double `lpc'=sum(`exp'/`glp'[_N]*`weight'/`cum_wt'[_N]*((`cum_wt'[_n]/`cum_wt'[_N])<=`lorp'))
	   by `touse' `by':gen double `lpcp'=`lpc'[_N]
	   foreach k of local nby {
	    	qui:capture drop `qvar'   
			_pctile `exp' [aw=`weight'] if float(`by')==float(`k') & `touse', p(`lor')
		    qui:gen `qvar'=r(r1) in 1 
			*sum `exp' [aw=`weight'] if float(`by')==float(`k') & `touse',meanonly
		 ** need qntl done above and glp? Lets assume not for now.
		   	replace `varlist'=(`exp'-(1-`lorp')*`qvar'[1])/`mu'+`lpcp'*(1-`exp'/`mu') if float(`by')==float(`k') & `exp'<`qvar'[1]  & `touse'				
		    replace `varlist'=          (`lorp'*`qvar'[1])/`mu'+`lpcp'*(1-`exp'/`mu') if float(`by')==float(`k') & `exp'>=`qvar'[1] & `touse'
		}
		label var `varlist' "RIF for Lorenz ordinate at p(`lor') of `exp'"
	}
	
	** RIF 1-lorenz. Upper lorenz?
    if "`ucs'"!="" {
       numlist "`ucs'", min(1) max(1)  range(>0 <100)
	   local lorp=`ucs'/100
       levelsof `by' if `touse', local(nby)
	   sort `touse' `by' `exp' `sortseed'
	   tempvar qvar cum_wt glp lpc mu lpcp
	   qui:gen `typlist' `varlist'=.
       by `touse' `by':gen double `cum_wt'=sum(`weight') 
	   by `touse' `by':gen double `glp'=sum(`exp'*`weight'/`cum_wt'[_N])
  	   by `touse' `by':gen double `mu'=`glp'[_N]

	   ** lorenz Truncated
	   by `touse' `by':gen double `lpc'=sum(`exp'/`glp'[_N]*`weight'/`cum_wt'[_N]*((`cum_wt'[_n]/`cum_wt'[_N])<=`lorp'))
	   by `touse' `by':gen double `lpcp'=`lpc'[_N]
	   foreach k of local nby {
	    	qui:capture drop `qvar'   
			_pctile `exp' [aw=`weight'] if float(`by')==float(`k') & `touse', p(`ucs')
		    qui:gen `qvar'=r(r1) in 1 
			*sum `exp' [aw=`weight'] if float(`by')==float(`k') & `touse',meanonly
		 ** need qntl done above and glp? Lets assume not for now.
		   	replace `varlist'=(`exp'-(1-`lorp')*`qvar'[1])/`mu'+`lpcp'*(1-`exp'/`mu') if float(`by')==float(`k') & `exp'<`qvar'[1]  & `touse'				
		    replace `varlist'=          (`lorp'*`qvar'[1])/`mu'+`lpcp'*(1-`exp'/`mu') if float(`by')==float(`k') & `exp'>=`qvar'[1] & `touse'
			replace `varlist'=1-`varlist' if float(`by')==float(`k')  & `touse'
		}
		label var `varlist' "RIF for Upper class share: 1-Lorenz ordinate at p(`ucs') of `exp'"
	}
	
	
	** RIF iqrs
	
	if "`iqsr'"!="" {
	  sort `touse' `by' `exp' `sortseed'
	  tempvar qvar fqvar
	  tempvar qlow qhigh
	  **gens new var
	  qui:gen `typlist' `varlist'=.
	  qui:gen `typlist' `qlow'=.
	  qui:gen `typlist' `qhigh'=.
	  levelsof `by' if `touse', local(nby)
	  numlist "`iqsr'", min(2) max(2) sort range(>0 <100)
	  local i0:word 1 of `r(numlist)'
	  local i1:word 2 of `r(numlist)'
	  * Rescaling
	  local i0p=`i0'/100
	  local i1p=`i1'/100
	  tempvar cum_wt glp lpc0 lpc1 mu
      by `touse' `by':gen double `cum_wt'=sum(`weight') 
	  by `touse' `by':gen double `glp'=sum(`exp'*`weight'/`cum_wt'[_N])
	  by `touse' `by':gen double `mu'=`glp'[_N]
	  ** lorenz Truncated
	  tempvar lpc0 lpc1	lpc0p lpc1p	
  	  by `touse' `by':gen double `lpc0'=sum(`exp'/`glp'[_N]*`weight'/`cum_wt'[_N]*((`cum_wt'[_n]/`cum_wt'[_N])<=`i0p'))
	  by `touse' `by':gen double `lpc0p'=`lpc0'[_N]
	  by `touse' `by':gen double `lpc1'=sum(`exp'/`glp'[_N]*`weight'/`cum_wt'[_N]*((`cum_wt'[_n]/`cum_wt'[_N])<=`i1p'))
	  by `touse' `by':gen double `lpc1p'=`lpc1'[_N]
	  ** Same process as for lorenz, but for 2
 	  foreach k of local nby {
	    	qui:capture drop `qvar'   
			_pctile `exp' [aw=`weight'] if float(`by')==float(`k') & `touse', p(`i0' `i1')
		    qui:gen double `qvar'=r(r1) in 1 
			qui:replace    `qvar'=r(r2) in 2
			*sum `exp' [aw=`weight'] if float(`by')==float(`k') & `touse',meanonly
			** This are the IF's
			** Try to clean the code a bit
		   	replace `qlow' =(`exp'-(1-`i0p')*`qvar'[1])/`mu'+`lpc0p'*(-`exp'/`mu') if float(`by')==float(`k') & `exp'<`qvar'[1]  & `touse'				
		    replace `qlow' =         (`i0p' *`qvar'[1])/`mu'+`lpc0p'*(-`exp'/`mu') if float(`by')==float(`k') & `exp'>=`qvar'[1] & `touse'
			replace `qhigh'=(`exp'-(1-`i1p')*`qvar'[2])/`mu'+`lpc1p'*(-`exp'/`mu') if float(`by')==float(`k') & `exp'<`qvar'[2]  & `touse'				
		    replace `qhigh'=         (`i1p' *`qvar'[2])/`mu'+`lpc1p'*(-`exp'/`mu') if float(`by')==float(`k') & `exp'>=`qvar'[2] & `touse'
	  }
	  *noisily display (1-`lpc1'[_N])/`lpc0'[_N]  "   " `lpc0'[_N] "   " `lpc1'[_N]
	  qui:replace `varlist'=(1-`lpc1p')/`lpc0p'+1/`lpc0p'*(-`qhigh'-(1-`lpc1p')/`lpc0p'*`qlow')
	  label var `varlist' "RIF for IQSR p(`i0' `i1') of `exp'"
	}
	 
	********************************
	** MIddle class share
	if "`mcs'"!="" {
	  sort `touse' `by' `exp' `sortseed'
	  tempvar qvar fqvar
	  tempvar qlow qhigh
	  **gens new var
	  qui:gen `typlist' `varlist'=.
	  qui:gen `typlist' `qlow'=.
	  qui:gen `typlist' `qhigh'=.
	  levelsof `by' if `touse', local(nby)
	  numlist "`mcs'", min(2) max(2) sort range(>0 <100)
	  local i0:word 1 of `r(numlist)'
	  local i1:word 2 of `r(numlist)'
	  * Rescaling
	  local i0p=`i0'/100
	  local i1p=`i1'/100
	  tempvar cum_wt glp lpc0 lpc1 mu
      by `touse' `by':gen double `cum_wt'=sum(`weight') 
	  by `touse' `by':gen double `glp'=sum(`exp'*`weight'/`cum_wt'[_N])
	  by `touse' `by':gen double `mu'=`glp'[_N]
	  ** lorenz Truncated
	  tempvar lpc0 lpc1	lpc0p lpc1p	
  	  by `touse' `by':gen double `lpc0'=sum(`exp'/`glp'[_N]*`weight'/`cum_wt'[_N]*((`cum_wt'[_n]/`cum_wt'[_N])<=`i0p'))
	  by `touse' `by':gen double `lpc0p'=`lpc0'[_N]
	  by `touse' `by':gen double `lpc1'=sum(`exp'/`glp'[_N]*`weight'/`cum_wt'[_N]*((`cum_wt'[_n]/`cum_wt'[_N])<=`i1p'))
	  by `touse' `by':gen double `lpc1p'=`lpc1'[_N]
	  ** Same process as for lorenz, but for 2
 	  foreach k of local nby {
	    	qui:capture drop `qvar'   
			_pctile `exp' [aw=`weight'] if float(`by')==float(`k') & `touse', p(`i0' `i1')
		    qui:gen double `qvar'=r(r1) in 1 
			qui:replace    `qvar'=r(r2) in 2
			*sum `exp' [aw=`weight'] if float(`by')==float(`k') & `touse',meanonly
			** This are the IF's
			** Try to clean the code a bit
		   	replace `qlow' =(`exp'-(1-`i0p')*`qvar'[1])/`mu'+`lpc0p'*(-`exp'/`mu') if float(`by')==float(`k') & `exp'<`qvar'[1]  & `touse'				
		    replace `qlow' =         (`i0p' *`qvar'[1])/`mu'+`lpc0p'*(-`exp'/`mu') if float(`by')==float(`k') & `exp'>=`qvar'[1] & `touse'
			replace `qhigh'=(`exp'-(1-`i1p')*`qvar'[2])/`mu'+`lpc1p'*(-`exp'/`mu') if float(`by')==float(`k') & `exp'<`qvar'[2]  & `touse'				
		    replace `qhigh'=         (`i1p' *`qvar'[2])/`mu'+`lpc1p'*(-`exp'/`mu') if float(`by')==float(`k') & `exp'>=`qvar'[2] & `touse'
	  }
	  *noisily display (1-`lpc1'[_N])/`lpc0'[_N]  "   " `lpc0'[_N] "   " `lpc1'[_N]
	  qui:replace `varlist'=(`lpc1p'-`lpc0p')+(`qhigh'-`qlow')
	    label var `varlist' "RIF for Middle class share at p(`i0' `i1') of `exp'"
	}
	******************************
	
	
	**RIF poverty. Flexible to admit any value for pov (0 headcount 1 poverty gap 2 poverty severity)
	** can also use either a fixed poverty line or a variable poverty line
    if "`pov'"!="" & "`pline'"!="" {
       numlist "`pov'", min(1) max(1)  range(>=0 )
		replace `touse'=. if `pline'==.
	   ** pov provides degree of sensitivity. pline the poverty line	   
 	   gen `typlist' `varlist'=.
	   * This estimates the standardized/censored income distribution
	   tempvar incz
	   gen double `incz'=(`pline'>`exp')*(`pline'-`exp')/`pline' if `touse'
	   if `pov'==0 {
	    qui:replace `varlist'=(`pline'>`exp') if   `touse'
	   }
	   else {
	    qui:replace `varlist'=`incz'^`pov'
	   }
	   label var `varlist' "RIF for FGT poverty with alpha=`pov' and pline:`pline' of `exp'"
	}	
	*****
	* Other ESSAMMA indices
	* watts poverty index can be used with different poverty measures. So assume for now its either a variable or number
	if "`watts'"!="" {
	     sort `touse' `by'   `sortseed'
	     by `touse' `by':gen `typlist' `varlist'=ln(`watts'/`exp')*(`watts'>=`exp')
	}
	* Sen index
	if "`sen'"!="" {
		sort `touse' `by' `exp' `sortseed'
	    tempvar cum_wt tot_wt pvar cums isen glp
 	    by `touse' `by':gen double `cum_wt'=sum(`weight') 
		by `touse' `by':gen double `tot_wt'=`cum_wt'[_N]
		by `touse' `by':gen double `pvar' = sum(`weight'/`tot_wt'*(`exp'<=`sen')) 
		
		*we will use sample data for this
		* check if we can interpolate Pvar[N] when poverty line is far from the upper poor limit
 		by `touse' `by':gen double `cums' =sum((`sen'-`exp')*(`pvar'[_N]-`pvar')*(`sen'>=`exp')*`weight'/`tot_wt')
		by `touse' `by':gen double `glp' =sum(`exp'*(`sen'>=`exp')*`weight'/`tot_wt')
		
		by `touse' `by':gen double `isen'=2/(`sen'*`pvar'[_N])*`cums'[_N]
		tempvar fzfy intfzfy
		*by `touse' `by':gen double `fzfy'=`pvar'[_N]-`pvar'
		*gen double `intfzfy'=.
        *by `touse' `by':integ `fzfy' `exp', gen(`intfzfy') replace
		** THE RIF
		by `touse' `by':gen `typlist' `varlist'=2/(`sen'*`pvar'[_N])*(`sen'*`pvar'[_N]-1/2*`sen'*`isen'-`exp'*`pvar'[_N]+`exp'*`pvar'-`glp')
 
		*2-		1/`pvar'[_N]*`isen'-2/(`sen'*`pvar'[_N])*`intfzfy'  if `exp'<=`sen'
		by `touse' `by':replace  `varlist'=0 if `exp'>`sen'
	   label var `varlist' "RIF for Sen poverty index of `exp'"

	}
	*TIP curves for poverty line z at ordinate p
	*tip(p) pov()
	if "`tip'"!="" {
		*assuming excludes 0 - 100
       numlist "`tip'", min(1) max(1)  range(>0 <100)
	    sort `touse' `by' `exp' `sortseed'
	   if "`pline'"=="" {
	     noisily display "Requires to specify a poverty line using pline() option"
	     exit
	   }

	   numlist "`pline'", min(1) max(1)  range(>0)
	    tempvar cum_wt tot_wt pvar cums ptile aptile itip 
 	    by `touse' `by':gen double `cum_wt'=sum(`weight') 
		by `touse' `by':gen double `tot_wt'=`cum_wt'[_N]
		by `touse' `by':gen double `pvar' = sum(`weight'/`tot_wt'*(`exp'<=`pline')) 
		
		* TIP pth quantile by group:
		by `touse' `by':gen double `aptile' =`exp' if (`cum_wt'/`tot_wt')>=`tip'/100
		by `touse' `by':egen double `ptile' =min(`aptile')
		* TIP ordinate
		by `touse' `by':gen double `itip' =sum(((`pvar'[_N])<=(`tip'/100))*(`pline'>=`exp')*(`pline'-`exp')*`weight'/`tot_wt')
		* THE RIF
		by `touse' `by':gen `typlist' `varlist'=(`pline'-`exp')									if `exp'<=`pline' & `pline'<=`ptile'
		by `touse' `by':replace 	  `varlist'=0							 		        	if `exp'> `pline' & `pline'<=`ptile'
		by `touse' `by':replace 	  `varlist'=`tip'/100*`pline'+(1-`tip'/100)*`ptile'-`exp'	if `exp'<=`ptile' & `pline'>`ptile'
		by `touse' `by':replace 	  `varlist'=`tip'/100*(`pline'-`ptile') 					if `exp'>`ptile'  & `pline'>`ptile'
	}
	** Pro poorness statistics seem not to be adequate here. It requires to estimate growth by quantiles, and not clear how is that done.
	*************************************************************************************************************
	*************************************************************************************************************
	** From here on we follow Cawley Flechaire 2007
	**Entropy Index
	if "`entropy'"!="" {
       numlist "`entropy'", min(1) max(1)  
	   sort `touse' `by' `exp' `sortseed'
	   ** there could be 3 cases ENT=0 =1 =something else
	   if `entropy'==0 {
	   * first entropy: Mean Log deviation 
	      tempvar v mu cum_wt e0
          by `touse' `by':gen double `cum_wt'=sum(`weight') 
          by `touse' `by':gen double `v'=sum(log(`exp')*`weight'/`cum_wt'[_N])      
		  by `touse' `by':gen double `mu'=sum(`exp'*`weight'/`cum_wt'[_N])      
          by `touse' `by':gen double `e0'=log(`mu'[_N])-`v'[_N] 
		  by `touse' `by':gen `typlist' `varlist'=`e0'-(log(`exp')-`v'[_N])+1/`mu'[_N]*(`exp'-`mu'[_N]) if `touse'
		  label var `varlist' "RIF for Entropy alpha=0 of `exp'"
	   }
	   else if `entropy'==1 {
	   **Theil Index
         tempvar v mu cum_wt e1
		  by `touse' `by':gen double `cum_wt'=sum(`weight') 
          by `touse' `by':gen double `v'=sum(log(`exp')*`exp'*`weight'/`cum_wt'[_N])      
		  by `touse' `by':gen double `mu'=sum(`exp'*`weight'/`cum_wt'[_N])      
          by `touse' `by':gen double `e1'=`v'[_N]/`mu'[_N]-log(`mu'[_N]) 
		  by `touse' `by':gen `typlist' `varlist'=`e1'+1/`mu'[_N]*(`exp'*log(`exp')-`v'[_N])-(`v'[_N]+`mu'[_N])/(`mu'[_N]^2)*(`exp'-`mu'[_N])  if `touse' 
		  label var `varlist' "RIF for Entropy alpha=1 of `exp'"

	   }
	   else if `entropy'!=1  & `entropy'!=0 {
	   ** All other Entropy cases
	   tempvar v mu cum_wt ea
		  by `touse' `by':gen double `cum_wt'=sum(`weight') 
          by `touse' `by':gen double `v'=sum((`exp'^`entropy')*`weight'/`cum_wt'[_N])      
		  by `touse' `by':gen double `mu'=sum(`exp'*`weight'/`cum_wt'[_N])      
          by `touse' `by':gen double `ea'=1/(`entropy'*(`entropy'-1))*(`v'[_N]/`mu'[_N]^`entropy'-1) 
		  by `touse' `by':gen `typlist' `varlist'=`ea'+(`exp'^`entropy'-`v'[_N])/(`entropy'*(`entropy'-1)*`mu'[_N]^`entropy')-`v'[_N]/((`entropy'-1)*`mu'[_N]^(`entropy'+1))*(`exp'-`mu'[_N])
		  label var `varlist' "RIF for Entropy alpha=`entropy' of `exp'"
	  }
	}
	*** Atkinson
	if "`atkin'"!="" {
       numlist "`atkin'", min(1) max(1) range(>0) 
	   sort `touse' `by' `exp' `sortseed'
	
	if `atkin'==1  {
	   ** Special ATKINSON case
	   tempvar v mu cum_wt a1
		  by `touse' `by':gen double `cum_wt'=sum(`weight') 
          by `touse' `by':gen double `v'=sum(log(`exp')*`weight'/`cum_wt'[_N])      
		  by `touse' `by':gen double `mu'=sum(`exp'*`weight'/`cum_wt'[_N])      
          by `touse' `by':gen double `a1'=1-exp(`v'[_N])/`mu'[_N]
		  by `touse' `by':gen `typlist' `varlist'=`a1'-exp(`v'[_N])/`mu'[_N]*(log(`exp')-`v'[_N])+(`exp'-`mu'[_N])*exp(`v'[_N])/`mu'[_N]^2 if `touse' 
		  label var `varlist' "RIF for Atkinson e=`atkin' of `exp'"
		  }
	if `atkin'!=1 {
	   ** All other cases cases
	     tempvar v mu cum_wt ax
		  by `touse' `by':gen double `cum_wt'=sum(`weight') 
          by `touse' `by':gen double `v'=sum(`exp'^(1-`atkin')*`weight'/`cum_wt'[_N])      
		  by `touse' `by':gen double `mu'=sum(`exp'*`weight'/`cum_wt'[_N])      
          by `touse' `by':gen double `ax'=1-`v'[_N]^(1/(1-`atkin'))/`mu'[_N]
          by `touse' `by':gen `typlist' `varlist'=`ax'+(`atkin'/(1-`atkin')+`exp'/`mu'[_N])*(1-`ax')-((1-`ax')^`atkin'*`exp'^(1-`atkin'))/((1-`atkin')*`mu'[_N]^(1-`atkin'))		  if `touse' 
		  *by `touse' `by':gen `typlist' `varlist'=`ax'+(`v'[_N]^(`atkin'/(1-`atkin')))/((`atkin'-1)*`mu'[_N])*(`exp'^(1-`atkin')-`v'[_N])+ ///
		  *                (`v'[_N]^(1/(1-`atkin')))/(`mu'[_N]^2)*(`exp'-`mu'[_N]) if `touse' 
	   label var `varlist' "RIF for Atkinson e=`atkin' of `exp'"
	   }
	}
	*** Logaritmic variance
	if "`logvar'"!="" {
       sort `touse' `by' `sortseed'
	   ** First important stuff 
	     tempvar v1 v2 mu cum_wt lgvr
          by `touse' `by':gen double `cum_wt'=sum(`weight') 
          by `touse' `by':gen double `v1'=sum(log(`exp')^2*`weight'/`cum_wt'[_N])
		  by `touse' `by':gen double `v2'=sum(log(`exp')*`weight'/`cum_wt'[_N])      
		  by `touse' `by':gen double `mu'=sum(`exp'*`weight'/`cum_wt'[_N])
          by `touse' `by':gen double `lgvr'=`v1'[_N]-2*`v2'[_N]*log(`mu'[_N])+log(`mu'[_N])^2
		  by `touse' `by':gen `typlist' `varlist'=`lgvr' +(log(`exp')^2-`v1'[_N])-2*log(`mu'[_N])*(log(`exp')-`v2'[_N])-2/`mu'[_N]*(`v2'[_N]-log(`mu'[_N]))*(`exp'-`mu'[_N]) if `touse'
		  *noisily sum `lgvr' `varlist'

		  label var `varlist' "RIF for logvariance of `exp'"
		  *log variance is different from variance of logs
	   }
	************************************************************************************
	************************************************************************************
	* From here we get the indices added by Heckley Gerdthan and Kjellson
	*** Absolute Gini
	if "`agini'"!="" {
     levelsof `by' if `touse', local(nby)
 	  sort `touse' `by' `exp' `sortseed'
	  qui{
		  *Get totals first
		  tempvar cum_wt mns cumwy tot_wt pvar mns glp rfvar rf aggini
		  tempvar covfx 
		  by `touse' `by':gen double `cum_wt'=sum(`weight') 
		  by `touse' `by':gen double `tot_wt'=`cum_wt'[_N]
		  by `touse' `by':gen double `pvar' = `cum_wt'/`tot_wt'   
		  by `touse' `by':gen double `glp'=sum(`exp'*`weight'/`tot_wt')
		  by `touse' `by':gen double `mns'=`glp'[_N]
		  gen double `covfx'=.
		  foreach k of local nby {
            corr `pvar' `exp' if `touse' & float(`by')==float(`k'), cov
			replace `covfx'=r(cov_12)  if `touse' & float(`by')==float(`k')
		  }
		  
		  by `touse' `by':gen double `aggini'=2*`covfx' if `touse'
		  by `touse' `by':gen `typlist' `varlist' =-`aggini'+(-`exp'+`mns')+2*(`exp'*(`pvar')-`glp') if `touse'
		  label var `varlist' "RIF for Abs gini of `exp'"
      }
	}
	*** Absolute Concentration index
	if "`acindex'"!="" {
     levelsof `by' if `touse', local(nby)
	  ** Need to be careful. Abs concentration index is "random" if there are Ties respect to rank variable
	  ** In this version im sorting by rank and exp. This may improve some results but gives higher index than sorting by rank only
 	  sort `touse' `by' `acindex'  `sortseed'
	  qui{
		  *Get totals first
		  tempvar cum_wt mns   tot_wt pvar mns glp rfvar rf accindex ifaccindex
		  tempvar covfx 
		  by `touse' `by':gen double `cum_wt'=sum(`weight') 
		  by `touse' `by':gen double `tot_wt'=`cum_wt'[_N]
		  by `touse' `by':gen double `pvar' = `cum_wt'/`tot_wt'   
		  by `touse' `by':gen double `glp'=sum(`exp'*`weight'/`tot_wt')
		  by `touse' `by':gen double `mns'=`glp'[_N]
		  gen double `covfx'=.
		  foreach k of local nby {
            corr `pvar' `exp' if `touse' & float(`by')==float(`k'), cov
			replace `covfx'=r(cov_12)  if `touse' & float(`by')==float(`k')
		  }		  
		  by `touse' `by':gen double `accindex'=2*`covfx' if `touse'
		  by `touse' `by':gen double `ifaccindex'=-2*`accindex'+(-`exp'+`mns')+2*(`exp'*(`pvar')-`glp') if `touse'
		  by `touse' `by':gen `typlist' `varlist' =`accindex'+`ifaccindex' if `touse'
		  label var `varlist' "RIF for Abs concentration of `exp'"
      }
	}
	***   Concentration index (Standard)
	if "`cindex'"!="" {
     levelsof `by' if `touse', local(nby)
	  ** Need to be careful. concentration index is "random" if there are Ties respect to rank variable
	  ** In this version im sorting first by exp then rank
	  ** This means there will ALLWAYS be some level of random component on the index.
	  ** 
	  sort `touse' `by' `cindex' `sortseed'
	  
	  qui{
		  *Get totals first
		  tempvar cum_wt mns  sumw sumwp tot_wt pvar padj mns glp rfvar rfx rf ccindex
		  tempvar covfx 
		  by `touse' `by':gen double `cum_wt'=sum(`weight') 
		  by `touse' `by':gen double `tot_wt'=`cum_wt'[_N]
		  by `touse' `by':gen double `pvar' = `cum_wt'/`tot_wt'   
		  by `touse' `by':gen double `glp'=sum(`exp'*`weight'/`tot_wt')
		  by `touse' `by':gen double `mns'=`glp'[_N]
		 
		  gen double `rfvar'=.
	  	  by `touse' `by':integ `glp' `pvar', gen(`rfvar') replace
		  
		  by `touse' `by':gen double `rf' =  `rfvar'[_N]
		  by `touse' `by':gen double `ccindex'=1-2/`mns'*`rf'            if `touse'
		  by `touse' `by':gen `typlist' `varlist' =(2/`mns'*`rf')*`exp'/`mns'+2/`mns'*(`exp'*(`pvar'-1)-`glp') +1 if `touse'
		  label var `varlist' "RIF for Concentration index of `exp'"
      }
	}

*********************************
	** eindex specifies the Erreygers index
	** Its a rescaling of the Concentration index. Rescale by min max. BUt here min max are indicated beforehand. Theoretical vs actual 
	** min max. IE wages have a theoretical min of 0 but say an observed min if 2.1
	
	if "`eindex'"!="" {
	  levelsof `by' if `touse', local(nby)
	  if "`ub'"=="" | "`lb'"=="" {
	  noisily display "This index requires to specify upper -ub()- and lower bounds -lb()-"
	  exit
	  }
	  ** Need to be careful. Abs concentration index is "random" if there are Ties respect to rank variable
	  ** In this version im sorting by rank and exp. This may improve some results but gives higher index than sorting by rank only
 	  sort `touse' `by' `eindex'  `sortseed'
	  qui{
		  *Get totals first
		  tempvar cum_wt mns   tot_wt pvar mns glp rfvar rf eccindex accindex ifaccindex
		  tempvar covfx 
		  by `touse' `by':gen double `cum_wt'=sum(`weight') 
		  by `touse' `by':gen double `tot_wt'=`cum_wt'[_N]
		  by `touse' `by':gen double `pvar' = `cum_wt'/`tot_wt'   
		  by `touse' `by':gen double `glp'=sum(`exp'*`weight'/`tot_wt')
		  by `touse' `by':gen double `mns'=`glp'[_N]
		  gen double `covfx'=.
		  foreach k of local nby {
            corr `pvar' `exp' if `touse' & float(`by')==float(`k'), cov
			replace `covfx'=r(cov_12)  if `touse' & float(`by')==float(`k')
		  }
		  by `touse' `by':gen double `accindex'=2*`covfx' if `touse'
		  by `touse' `by':gen double `ifaccindex'=-2*`accindex'+(-`exp'+`mns')+2*(`exp'*(`pvar')-`glp') if `touse'
		    
	    by `touse' `by':gen double `eccindex'=4/(`ub'-`lb')*`accindex' if `touse'
	    by `touse' `by':gen `typlist' `varlist' =(4/(`ub'-`lb'))*(`accindex'+`ifaccindex') if `touse'
	    label var `varlist' "RIF for Erreygers index of `exp'"
	  }
	}
*********************************************************************
*********************************************************************
*********************************************************************
*********************************************************************
	** Attainment Relative Concentration Index
	*NEEDS TO BE REVISED
		if "`arcindex'"!="" {
	  levelsof `by' if `touse', local(nby)
 	  if  "`lb'"=="" {
		  noisily display "This index requires to specify lower bounds -lb()-"
		  exit
	  }
	  ** Need to be careful. Abs concentration index is "random" if there are Ties respect to rank variable
	  ** In this version im sorting by rank and exp. This may improve some results but gives higher index than sorting by rank only
 	  sort `touse' `by' `arcindex'  `sortseed'
	  qui{
		  *Get totals first
		  tempvar cum_wt mns   tot_wt pvar mns glp rfvar rf arccindex accindex ifaccindex
		  tempvar covfx 
		  by `touse' `by':gen double `cum_wt'=sum(`weight') 
		  by `touse' `by':gen double `tot_wt'=`cum_wt'[_N]
		  by `touse' `by':gen double `pvar' = `cum_wt'/`tot_wt'   
		  by `touse' `by':gen double `glp'=sum(`exp'*`weight'/`tot_wt')
		  by `touse' `by':gen double `mns'=`glp'[_N]
		  gen double `covfx'=.
		  foreach k of local nby {
            corr `pvar' `exp' if `touse' & float(`by')==float(`k'), cov
			replace `covfx'=r(cov_12)  if `touse' & float(`by')==float(`k')
		  }
		  by `touse' `by':gen double `accindex'=2*`covfx' if `touse'
		  by `touse' `by':gen double `ifaccindex'=-2*`accindex'+(-`exp'+`mns')+2*(`exp'*(`pvar')-`glp') if `touse'
		  by `touse' `by':gen double `arccindex'=1/(`mns'-`lb')*`accindex' if `touse'
 		  by `touse' `by':gen `typlist' `varlist' =1/(`mns'-`lb')*(`accindex'+`ifaccindex')-`accindex'*(`exp'-`mns')/(`mns'-`lb')^2  if `touse'
		  label var `varlist' "RIF for Attainment Relative Concentration of `exp'" 
       }
	  }
	
	** Shortfall relative concentration index
 	if "`srindex'"!="" {
	  levelsof `by' if `touse', local(nby)
	   	  if  "`ub'"==""  {
		  noisily display "This index requires to specify upper bound -ub()- "
		  exit
	  }
	  ** Need to be careful. Abs concentration index is "random" if there are Ties respect to rank variable
	  ** In this version im sorting by rank and exp. This may improve some results but gives higher index than sorting by rank only
 	  sort `touse' `by' `srindex'  `sortseed'
	  qui{
		  *Get totals first
		  tempvar cum_wt mns   tot_wt pvar mns glp rfvar rf srcindex accindex ifaccindex
			tempvar covfx 
		  by `touse' `by':gen double `cum_wt'=sum(`weight') 
		  by `touse' `by':gen double `tot_wt'=`cum_wt'[_N]
		  by `touse' `by':gen double `pvar' = `cum_wt'/`tot_wt'   
		  by `touse' `by':gen double `glp'=sum(`exp'*`weight'/`tot_wt')
		  by `touse' `by':gen double `mns'=`glp'[_N]
		  gen double `covfx'=.
		  foreach k of local nby {
            corr `pvar' `exp' if `touse' & float(`by')==float(`k'), cov
			replace `covfx'=r(cov_12)  if `touse' & float(`by')==float(`k')
		  }		  
		  by `touse' `by':gen double `accindex'=2*`covfx' if `touse'
		  by `touse' `by':gen double `ifaccindex'=-2*`accindex'+(-`exp'+`mns')+2*(`exp'*(`pvar')-`glp') if `touse'
		  by `touse' `by':gen `typlist' `varlist' =1/(`ub'-`mns')*(`accindex'+`ifaccindex')-(`mns'-`exp')/((`ub'-`mns')^2)*`accindex' if `touse'
		  label var `varlist' "RIF for Shortfall relative concentration index of `exp'"
       }
	}
	** Wagstaff index
		*NEEDS TO BE REVISED

   if "`windex'"!="" {
	  levelsof `by' if `touse', local(nby)
	  if  "`ub'"=="" | "`lb'"==""  {
		  noisily display "This index requires to specify upper bound -ub()- and lower bound -lb()-"
		  exit
	  }
	  ** Need to be careful. Abs concentration index is "random" if there are Ties respect to rank variable
	  ** In this version im sorting by rank and exp. This may improve some results but gives higher index than sorting by rank only
 	  sort `touse' `by' `windex'  `sortseed'
	qui{
		  *Get totals first
		  tempvar cum_wt mns   tot_wt pvar mns glp rfvar rf wcindex accindex ifaccindex
		  tempvar covfx 
		  by `touse' `by':gen double `cum_wt'=sum(`weight') 
		  by `touse' `by':gen double `tot_wt'=`cum_wt'[_N]
		  by `touse' `by':gen double `pvar' = `cum_wt'/`tot_wt'   
		  by `touse' `by':gen double `glp'=sum(`exp'*`weight'/`tot_wt')
		  by `touse' `by':gen double `mns'=`glp'[_N]
		  gen double `covfx'=.
		  foreach k of local nby {
            corr `pvar' `exp' if `touse' & float(`by')==float(`k'), cov
			replace `covfx'=r(cov_12)  if `touse' & float(`by')==float(`k')
		  }
		  by `touse' `by':gen double `accindex'=2*`covfx' if `touse'
		  by `touse' `by':gen double `ifaccindex'=-2*`accindex'+(-`exp'+`mns')+2*(`exp'*(`pvar')-`glp') if `touse'
		  by `touse' `by':gen double `wcindex'=(`ub'-`lb')/((`ub'-`mns')*(`mns'-`lb'))*`accindex' if `touse'
		  tempvar z2 z3
		  by `touse' `by':gen double `z2' 	= ((`ub'+`lb'-2*`mns')*(`exp' - `mns')) if `touse'
		  by `touse' `by':gen double `z3'	= ((`ub'-`mns')*(`mns'-`lb')) if `touse'
		  by `touse' `by':gen `typlist' `varlist' =(`ub'-`lb')/((`ub'-`mns')*(`mns'-`lb'))*(`accindex'+`ifaccindex')-((`ub'-`lb')*`z2'/(`z3'*`z3'))*`accindex' if `touse'
		  *by `touse' `by':gen `typlist' `varlist'=`accindex'+`ifaccindex'
		  label var `varlist' "RIF for Wagstaff index of `exp'"
       }
	  }
	   
	
*********************** Not ready yet.
** Alternative rifown rifown
if "`rifown'"!="" {
		** Alternative User written RIFS"
		sort `touse' `by' `exp' `sortseed'
		by `touse' `by':egen `typlist' `varlist'=`rifown'(`exp'), weight(`weight') `rifopt'
	}
 
  }
  
  set seed `sysseed'
 end

 
 *capture program drop _prank
capture program drop _prank
program define _prank
	syntax newvarlist , svar(varname) mvar(varname) [ byvar(varname) wvar(varname) tvar(varname) ]  
	local v1 :word 1 of `varlist'
	local v2 :word 2 of `varlist'
	local v3 :word 3 of `varlist'
	// Sort by, touse, main var and sort variable
	sort `tvar' `byvar' `svar' `wvar'
	if "`wvar'"=="" {
	    local wvar2=1
	}
	else {
	    local wvar2 `wvar'
	}
	tempvar sumw awgt nn g
	by `tvar' `byvar':gen double `sumw'=sum(`wvar2'/_N)
	by `tvar' `byvar':gen double `awgt'=`wvar2'/`sumw'[_N]
	by `tvar' `byvar':replace    `sumw'=sum(`awgt')
	by `tvar' `byvar':gen double `nn'=`sumw'[_N]
	by `tvar' `byvar':gen double `v1'=sum(`mvar'*`awgt'/`nn')
	by `tvar' `byvar' `svar' :gen double `v2'=0.5*(`sumw'[_N]+`sumw'[1]-`awgt'[1])/`nn'
    by `tvar' `byvar':gen double `v3'=sum((`mvar'-`v1'[_N])*(`v2'-0.5)*`awgt'/`nn')
end