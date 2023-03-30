*** Project. Generalized CV for Varying coefficient models
** change all globals into locals
** NOW IN MATA
** last change was to modify with a flag for ealy ending
capture program drop vc_bw
program vc_bw, rclass  sortpreserve
 syntax  varlist(numeric fv) [if] [in],  vcoeff(varname)  [ bwi(real -1) weight(varname) knots(real -1) km(real 1) sample(varname) trimsample(varname)  kernel(str) plot ]
** varlist will contain the dependent variable and independent variables
** weight will have the survey weights if any
** full_x has the fully observed nonparametric data
** par_x gas the partial data (which is a less detailed variable compared to full_x only for speeding up calculations
** trim_sample to define if any segment of the data will not be used for CV but used in claculations
** sample defines what data will be used in estimation (and what will not) sample>trimsample
** This sets up base information
	tokenize `varlist'
	local y `1'
	//get the rest of the vars
	macro shift
	local varx `*'
		
	marksample touse
	markout `touse' `varlist' `vcoeff' 
	
	if "`sample'"!="" {
	   qui:	replace `touse'=0 if `sample'==0 
	}

	*local varx `varx'
    local full_x `vcoeff'
	*verifying if knots its a sensible number
	numlist "`knots'", integer range(>=-2)
	
	* This counts how many values vcoeff has
	tempvar vals
    qui:bysort `touse' `vcoeff': gen byte `vals' = (_n == 1) * `touse'
    sum `vals' if `touse', meanonly 
	local vcvls=r(sum)
	
	if `vcvls'>=500 & `knots'==-1 {
		display "the variable `vcoeff' has more than 500 distinct values, using option knots(0) km(2)"
		display "To force using all distinct values use knots(-2)"
		local knots=0
		local km=2
	}
	
	if `knots'==-1 | `knots'==-2 {
		local par_x `vcoeff'
	}
	else {
		tempvar _kn
		egen `_kn'=vbin(`vcoeff') if `touse', knot(`knots') km(`km')
		local par_x `_kn'
		** Get Number of Implicit knots and Implicit Bandwidth.
		if (`knots'==0) {
			sum `vcoeff' if `touse', meanonly
			local max=r(max)
			local min=r(min)
			local N=r(N)
			local _ikb=min(sqrt(`N'),10*ln(`N')/ln(10))
			local _ikb=round(`_ikb'*`km')
			local _ibw=(`max'-`min')/(`_ikb'+1)
			}
		else {
			sum `vcoeff' if `touse', meanonly
			local max=r(max)
			local min=r(min)
			local N=r(N)
			local _ikb=(`knots')
			local _ibw=(`max'-`min')/(`knots'+1)
			}
		display "Number of used Knots: `_ikb' "
		display "Implicit Bandwidth  :  " %6.5f `_ibw'  
	}

	local sweight  1
	* this is undocumented. PLanned for adding sample weights
	*if "`weight'"!="" {
	*	local sweight  `weight'
	*}
	*DEFAULT OPTION FOR Kernel
    if "`kernel'"=="" {
			local kernel="gaussian"
	}
	display "Kernel: `kernel'"
	** try adding th other options
	if 	"`kernel'"!="gaussian" & /// 
		"`kernel'"!="biweight" & /// 
		"`kernel'"!="cosine" & /// 
		"`kernel'"!="epan" & /// 
		"`kernel'"!="epan2" & /// 
		"`kernel'"!="parzen" & /// 
		"`kernel'"!="trian"  & ///
		"`kernel'"!="rectan" {
		display "Kernel function `kernel' not allowed"
		exit 1
	}
	
	tempvar sample2
	qui:gen `sample2'=1
	* This is to create a weight that has value of zero for some observations
	if "`trimsample'"!="" {
		qui:replace `sample2'=`trimsample'
	}
** Initial bandwidth based on lpoly
   if `bwi'==-1 {
		lpoly `y' `full_x' if `touse', nograph kernel(`kernel') degree(1)
		** Initial BW adjusts for number of parameters in the explanatory variable. Better adjustments can be found.
		** in principle more explanatory variables require a larger bandwidth
		local num : word count `varx'
		local bw1=(1+ln(`num'+1))*r(bwidth)
		local bw0=`bw1'*0.99
		local bw2=`bw1'*1.01 
    }
	else {
		local bw1=`bwi'
		local bw0=`bw1'*0.99
		local bw2=`bw1'*1.01 
	}
	local bwi=`bw1'
 ** This defines through what values we will be used for estimating the CV criteria This should adjust for TRIM factor
** if parx is equal to fullx then we use ALL values in fullx
** Best option to use Par_x which should have fewer levels than FUllx
	*qui: levelsof `par_x' if `touse'==1 & `sample2'==1, local(nparval)

	** We need a new variable CV
	** This variable will contain the Cross validation values 
	tempvar cv
	qui:gen double `cv'=.
	
	** Here is where the CV process begins
	
	preserve
	* Keep only observations that will be used for the analysis
	* Revise so we keep only variables required for the process, 
	* This may help making it faster
		qui:keep if `touse'==1
		tempvar delta wgt err 
		
		** initial CV for bandwidth. This are the 3 initial points of interest
		local k=0
		foreach bw in   `bw0' `bw1' `bw2' {
		** initialize cv to missing
			qui:capture drop  `cv'
			** Rotates trough all the values of interestet in par_x
			** This predict the LOOERR. Its a strip down version of the vc_predict
			qui:vc_predict `y'  `varx', vcoeff(`full_x') vcoeff_par(`par_x') bw(`bw') looe(`cv') kernel(`kernel') nstat
			qui:replace `cv'=`cv'^2  
			sum `cv' [aw=`sweight'] if `touse'==1 & `sample2'==1, meanonly
			** lets change the CV to log(RMSE)
			** This is the same criteria used in NPREGRESS
			local  cv`k'=ln(r(mean))
			local k=`k'+1
	   }

	   * We will create a matrix that has the results as needed
	   * But will only report the Middle point
		capture matrix drop cvbw
		matrix  cvbw=nullmat(cvbw)\[`bw0',`cv0']\[`bw1',`cv1']\[`bw2',`cv2'] 
		
		display as result "Iteration: 0 BW:  " %10.7f `bw1'  " CV: " %10.7g `cv1'

		*** from here on we do the NR procedure
		
		*local dcv=min(`cv2',`cv0')
		local chg=1 
		local pchg=1
		* while abs(`dcv'-`cv1')>epsdouble() & abs(`chg')>epsdouble() {
		** Latest criteria If the proportional change of the BW is less than 0.01%
		local flagbw=0
		** This measures the change in the Bandiwdth pchg
		while abs(`pchg')>0.0001 & `flagbw'!=1 {
			local cc=`cc'+1
			* last cv for "min point"
			local dcv=`cv1'
			local dbw=`bw1'

			** Approximations for derivatives i get the updated changes with this, and use it for the NR algorithm
			** See if its possible to adapt the BWALT here. THe idea. Once the MAX and MIN are known, we dont have to search beyond those points. 
			local df=(`cv2'-`cv0')/(`bw2'-`bw0')
			local ddf=(`cv2'-2*`cv1'+`cv0')/(`bw2'-`bw1')^2
			** This later change seems to work. 
			** Look if it ever fails. Come back to here
			local chg=-`df'/abs(`ddf')
			** auxiliar DF
			local df1=(`cv2'-`cv1')/(`bw2'-`bw1')
			local df2=(`cv1'-`cv0')/(`bw1'-`bw0')
			** This is to avoid overreaction. If the change is more than 50% of current BW, we use a 20% change. 
			** This could be improved. Look into adaptive step 
			 /* if abs(`chg')>0.5*`bw1' {
				local chg=0.5*`bw1'*sign(-`df'/`ddf')
			  }*/
			  ** And this to deal with non convex sets
			  ** NP process usually finds a flat point. This corrections help to ensure the point is minimizing the function.
				/*if `df'<0 & `df1'<0 & `df2'<0 {
					local chg=abs(`df'/`ddf')	 
				}
				if `df'>0 & `df1'>0 & `df2'>0 {
					local chg=-abs(`df'/`ddf')
				}*/
				if (`bw1'+`chg')<0 {
					local chg=-0.5*`bw1'
				}
			  *other option USe CHG to be between certain levels
			  
			** updating numbers BW, using above changes.
			* This dch is to update the auxiliary points. we use a 1% gap or the estimated change. Whichever is smaller. 

			** We will try implement an adaptive version of this algorithm
			** Following example, we will first verify that an improvement was made. If not, try again with half a step
			local flag_imp=0
			local dch=min(0.01*`bw1',abs(`chg'))
			local bw1=`bw1'+`chg'		
			tempvar ccvv
			** This basically rotates until an improvement has been found
			local cntloop=0
			while `flag_imp'==0 & `cntloop'<5{
				local cntloop=`cntloop'+1
				qui:capture drop  `cv'
				qui:capture drop  `ccvv'
				** Rotates trough all the values of interestet in par_x
				qui:vc_predict `y'   `varx', vcoeff(`full_x') vcoeff_par(`par_x') bw(`bw1') looe(`cv') kernel(`kernel') nstat
				qui:replace `cv'=`cv'^2  
				sum `cv' [aw=`sweight'] if `touse'==1 & `sample2'==1, meanonly
				** lets change the CV to RMSE
				local  cv1=ln(r(mean))
				matrix  cvbw=nullmat(cvbw)\[`bw1',`cv1']
				if `cv1'<=`dcv' {
					local flag_imp=1
				}
				else {
					local chg=0.5*`chg'
					local dch=min(0.01*`bw1',abs(`chg'))
					local bw1=`dbw'+`chg'			
				}				
			}
			* updating two points of reference
			local bw2=`bw1'+`dch'
			local bw0=`bw1'-`dch'
			* Restarting local. 
			local k=0
				* now restarting the 3 band CV. LEss efficient but more accurate
				* THe alternative was to use only 1 additional BW 
				foreach bw in   `bw0' `bw2' {
				** initialize cv to missing
					qui:capture drop  `cv'
					qui:capture drop  `ccvv'
					** Rotates trough all the values of interestet in par_x
					qui:vc_predict `y' `varx', vcoeff(`full_x') vcoeff_par(`par_x') bw(`bw') looe(`cv') kernel(`kernel') nstat
					qui:replace `cv'=`cv'^2 
					sum `cv' [aw=`sweight'] if `touse'==1 & `sample2'==1, meanonly
					** lets change the CV to RMSE
					local  cv`k'=ln(r(mean))
					local k=`k'+2
				}
				matrix  cvbw=nullmat(cvbw)\[`bw0',`cv0']\[`bw1',`cv1']\[`bw2',`cv2'] 
				local pchg=`chg'/`bw1'
				display as result "Iteration: `cc' BW:  " %10.7f `bw1'  " CV: " %10.7g `cv1'
				
			if `bwi'*100<`bw1' {
			local flagbw=1
			noisily:display "BW too large"
			}
		}
		*local cvchg=`dcv'-`cv1'
		*display as text "BW 1:`bw0'  " as result "2: `bw1'" as text "3: `bw2'" as result "Last Change: `chg'"
		*display as text "CV 1:`cv0'  " as result "2: `cv1'" as text "3: `cv2'" as result "Last Change: `cvchg'"
		*display "DF:`df' DDF:`ddf' Change:`chg' "
 	restore
	
global opbw_=`bw1'
global kernel_="`kernel'"	
global vcoeff_="`vcoeff'"	
display "Bandwidth stored in global \$opbw_"
display "Kernel function stored in global \$kernel_"	
display "VC variable name stored in global \$vcoeff_"		
	if "`plot'"!="" {
		tempname _cv 
		svmat cvbw, name(`_cv') 
		scatter `_cv'2 `_cv'1 , xtitle("bandwidth") ytitle("CV criteria") legend(off) xline(`bw1')
	}
matrix colname 	cvbw=  bw cv
*macro drop y par_x varx full_x sweight 

return scalar bandwidth=`bw1'
return scalar cv_criteria=`cv1'
return local kernel="`kernel'"
return matrix bwcv_trace=cvbw
*capture mata:mata drop x y 
end

