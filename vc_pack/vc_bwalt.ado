*** Project. Generalized CV for Varying coefficient models
*** Latest change. Using Mata Speed things up atleast 50% This may be as fast as i can get it for now.
capture program drop vc_bwalt
program vc_bwalt, rclass sortpreserve
syntax  varlist(numeric fv) [if],  vcoeff(varname)  [ bwi(real -1) weight(varname) knots(real -1) km(real 1) sample(varname) trimsample(varname)  kernel(str)  plot]
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
	
	*global varx `varx'
    local full_x `vcoeff'
	*verifying if knots its a sensible number
	numlist "`knots'", integer range(>=-2)
	* THis counts how many values vcoeff has
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

	*if "`weight'"!="" {
	*	local sweight  `weight'
	*}
    if "`kernel'"=="" {
		local kernel="gaussian"
	}
	display "Kernel: `kernel'"
	
	if 	"`kernel'"!="gaussian" & /// 
		"`kernel'"!="biweight" & /// 
		"`kernel'"!="cosine" & /// 
		"`kernel'"!="epan" & /// 
		"`kernel'"!="epan2" & /// 
		"`kernel'"!="parzen" & /// 
		"`kernel'"!="trian" & ///
		"`kernel'"!="rectan" {
		display "Kernel function `kernel' not allowed"
		exit 1
	}
	
	tempvar sample2
	qui:gen `sample2'=1
	if "`trimsample'"!="" {
	qui:replace `sample2'=`trimsample'
	}
** Initial bandwidth based on lpoly
   if `bwi'==-1 {
	lpoly `y' `full_x' if `touse', nograph kernel(`kernel') degree(1)
	** Initial BW adjustes for number of parameters in the explanatory variable. Better adjustments can be found.
	local num : word count `varx'
	local bw1=(1+ln(`num'+1))*r(bwidth)
	local bw0=`bw1'*0.9
	local bw2=`bw1'*1.10
    }
	else {
	local bw1=`bwi'
	local bw0=`bw1'*0.99
	local bw2=`bw1'*1.01
	}
 ** This defines through what values we will be used for estimating the CV criteria This should adjust for TRIM factor
** if parx is equal to fullx then we use ALL values in fullx
** Best option to use Par_x which should have fewer levels than FUllx
	*qui: levelsof `par_x' if `touse'==1 & `sample2'==1, local(nparval)

	** We need a new variable CV
	** This variable will contain the Cross validation values 
	tempvar cv
	qui:gen double `cv'=.
	
	** Here is where the CV process begins
    ** The original program uses a NR approach to find optimal bandwidth
	** This will use something similar to the Nelder–Mead method. David Drukker indicates that is closer to a bysection.
	** May be slower (as convergence rate is somewhat fixed at 1/2^N. It would take about 9 iterations to find the optimal bandwidth within .1% 
	** To some extend this is the Zeno's Paradox. We will never Find the Optimum Bandwidth because there will always be a distance larger than zero between two candiate bandwiths.
	** Unlike the Zenos' paradox, the speed of convergence is not constant, the closer we are to the Optimum bandwith, the slower we move towards it
	
	preserve
	* Keep only observations that will be used for the analysis
	* Revise so we keep only variables required for the process
	* Should i keep this? It only adds time
		qui:keep if `touse'==1
		tempvar delta wgt err 
		
		tempvar constant
		gen byte `constant'=1
		*local fvarx 	"`full_x' `varx' c.`full_x'#c.(`varx') `constant'"
		*mata:y= st_data(., "`y'")
		*mata:x= st_data(., "`fvarx'")
		
		** initial CV for bandwidth. This are the 3 initial points of interest
		local k=0
		foreach bw in   `bw0' `bw1' `bw2' {
			** initialize cv to missing
			qui:capture drop  `cv'
			** Rotates trough all the values of interest in par_x
			qui:vc_predict  `y'   `varx', vcoeff(`full_x') vcoeff_par(`par_x') bw(`bw') looe(`cv') kernel(`kernel') nstat 
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
		display _c "Iteration: 0 BW:  " %10.7f `bw1'  " CV: " %10.7g `cv1'


		*** from here on we do the NM(RA) procedure This is my interpretation of the procedure.
		*local dbw=0.5*`bw0'
		local dcv=min(`cv2',`cv1',`cv0')
		local chg=1 
		local pchg=1
		local bwop=`bw1'
		local cvop=`cv1'
		* while abs(`dcv'-`cv1')>epsdouble() & abs(`chg')>epsdouble() {
		** Latest criteria If the proportional change of the BW is less than 0.01%
		** This is to be sure max and mins are used and Flag to avoid more than one criteria 
		local bwmin=0
		local bwmax=99999999
		local flag=0
		
		while abs(`pchg')>0.0001  { 
		
			local bwx0=`bwop'
			local cvx0=`cvop'
			local cc=`cc'+1
			local flag=0
			* This is to do a trace of the appropriate values
		   * display "`bwmin' `bw0' `bw1' `bw2' `bwmax'"
			*display "`cv0'  `cv1' `cv2' `flag'"
			** This section will have a lot of Ifs. 
			** That should take into account ALL possibilities 
			** The problem is how to make the first Step. It can be anything...
			* case one. CV is declining in BW \_
			if (`cv0'>=`cv1' &  `cv1'>`cv2' & `flag'==0) ///
			 | (`cv0'>`cv1' &  `cv1'>=`cv2' & `flag'==0) {
			      * This shows the PATH taken
				local p " Path: \_"
				display _c "`p'" _n 
				local flag=1
				local bwmin=`bw0'
				* This copies from NP to see the SIZE of the change
				local bwx=min(`bw2'*1.5,0.5*(`bw2'+`bwmax'))
				**
				qui:capture drop  `cv'
				qui:vc_predict `y'   `varx', vcoeff(`full_x') vcoeff_par(`par_x') bw(`bwx') looe(`cv') kernel(`kernel') nstat
				qui:replace `cv'=`cv'^2  
				sum `cv' [aw=`sweight'] if `touse'==1 & `sample2'==1, meanonly
				local  cvx=ln(r(mean))
				matrix  cvbw=nullmat(cvbw)\[`bwx',`cvx']
					
				local cv0=`cv1'
				local bw0=`bw1'
				
				local cv1=`cv2'
				local bw1=`bw2'
				
				local cv2=`cvx'
				local bw2=`bwx'
				
				if `cvx'<`cv1' {
				  local cvop=`cvx'
				  local bwop=`bwx'
				}
				else {
				  local cvop=`cv1'
				  local bwop=`bw1'
				}
				*matrix  cvbw=nullmat(cvbw)\[`bwx',`cvx']
			}
			
			* case one. CV is increasin in BW _/
			if (`cv0'<`cv1' &  `cv1'<=`cv2' & `flag'==0) | ///
			   (`cv0'<=`cv1' &  `cv1'<`cv2' & `flag'==0) {
			 
				local p " Path: _/"
				display _c "`p'" _n 
				local flag=1
				local bwmax=`bw2'
				local bwx=0.5*(`bw0'+`bwmin')
			  	local flag_imp=0
				
				qui:capture drop  `cv'
				qui:vc_predict `y'   `varx', vcoeff(`full_x') vcoeff_par(`par_x') bw(`bwx') looe(`cv') kernel(`kernel') nstat
				qui:replace `cv'=`cv'^2  
				sum `cv' [aw=`sweight'] if `touse'==1 & `sample2'==1, meanonly
				local  cvx=ln(r(mean))
				matrix  cvbw=nullmat(cvbw)\[`bwx',`cvx']
						
				local cv2=`cv1'
				local bw2=`bw1'
				
				local cv1=`cv0'
				local bw1=`bw0'
				
				local cv0=`cvx'
				local bw0=`bwx'
				
				if `cvx'<`cv1' {
				  local cvop=`cvx'
				  local bwop=`bwx'			  
				}
				else {
				  local cvop=`cv1'
				  local bwop=`bw1'   
				}
				*matrix  cvbw=nullmat(cvbw)\[`bwx',`cvx']
			}
	 
			*** CV is smaller at some point in between bw2 and bw0  \_/ 
			if (`cv0'>`cv1' &  `cv1'<=`cv2'& `flag'==0) | (`cv0'>=`cv1' &  `cv1'<`cv2'& `flag'==0)  {
				local p " Path: \_/"
				display _c "`p'" _n 
			*display as result "`bwmin' `bw0' `bw1' `bw2' `bwmax' "
			*display as result "`bwmin' `cv0' `cv1' `cv2' `bwmax' "
			** Derivatives to try a faster way once we are in the concave area. Important?
				local flag=1
				local bwmax=`bw2'
				local bwmin=`bw0'
 			
				local bwx1=(`bwmin'+`bw1')*.5
				local bwx2=(`bwmax'+`bw1')*.5
			
			  
				qui:capture drop  `cv'
				qui:vc_predict `y'   `varx', vcoeff(`full_x') vcoeff_par(`par_x') bw(`bwx1') looe(`cv') kernel(`kernel') nstat
				qui:replace `cv'=`cv'^2  
				qui:sum `cv' [aw=`sweight'] if `touse'==1 & `sample2'==1, meanonly
				local  cvx1=ln(r(mean))
				matrix  cvbw=nullmat(cvbw)\[`bwx1',`cvx1']
				
				
				if `cvx1'>`cv1' {
					qui:capture drop  `cv'
					qui:vc_predict `y'   `varx', vcoeff(`full_x') vcoeff_par(`par_x') bw(`bwx2') looe(`cv') kernel(`kernel') nstat
					qui:replace `cv'=`cv'^2  
					qui:sum `cv' [aw=`sweight'] if `touse'==1 & `sample2'==1, meanonly
					local  cvx2=ln(r(mean))
					matrix  cvbw=nullmat(cvbw)\[`bwx2',`cvx2']
				}
	 

				
				if `cvx1'<`cv1' {
				  local cv2=`cv1'
				  local bw2=`bw1'			  
				  local cv1=`cvx1'
				  local bw1=`bwx1'
				} 
				else if `cvx2'<`cv1' {
				  local cv0=`cv1'
				  local bw0=`bw1'
				  local cv1=`cvx2'
				  local bw1=`bwx2'
				} 
				else if `cvx1'>`cv1' & `cvx2'>`cv1'{
				  local cv0=`cvx1'
				  local bw0=`bwx1'
				  local cv2=`cvx2'
				  local bw2=`bwx2'

				}
				
				if `cv0'<`cv1' & `cv0'<`cv2' {
					local bwop=`bw0'
					local cvop=`cv0'
				}
				if `cv1'<`cv0' & `cv1'<`cv2' {
					local bwop=`bw1'
					local cvop=`cv1'
				}
				if `cv2'<`cv0' & `cv2'<`cv1' {
					local bwop=`bw2'
					local cvop=`cv2'
				}
				
 
				*display as result "`bwmin' `bw0' `bw1' `bw2' `bwmax' "
				*display as result "`bwmin' `cv0' `cv1' `cv2' `bwmax' "
			}
		  
			** If the function is not concave /\
			
			if `cv0'<`cv1' &  `cv1'>`cv2'  & `flag'==0 {
				local p "---"
				display _c " Path:`p'"
				display "we encounter a not concave point"
				display "Nearby CV values"
				display "CV0: `cv0' "
				display "CV1: `cv1' "
				display "CV2: `cv2' "
				display "revise matrix r(bwcv_trace) to see the solution candidates"
				local xit="xit"
			}
			
			if `cv0'==`cv1' &  `cv1'==`cv2'  & `flag'==0 {
				*display "here: --- "
				local xit="xit"
			}
			*******************************************
			display _c "Iteration: `cc' BW:  " %10.7f `bwop'  " CV: " %10.9g `cvop'

			*local pchg=(`bwx0'-`bwop')/(`bwx0'+`bwop')
			local pchg=(`bw2'-`bw0')/(`bw2'+`bw0')*2

			if "`xit'"=="xit" {
				local pchg=0
			}

		}
		*local cvchg=`dcv'-`cv1'
		*display as text "BW 1:`bw0'  " as result "2: `bw1'" as text "3: `bw2'" as result "Last Change: `chg'"
		*display as text "CV 1:`cv0'  " as result "2: `cv1'" as text "3: `cv2'" as result "Last Change: `cvchg'"
		*display "DF:`df' DDF:`ddf' Change:`chg' "
 	restore
global opbw_=`bwop'
global kernel_="`kernel'"	
global vcoeff_="`vcoeff'"	
display _n "Bandwidth stored in global \$opbw_"
display "Kernel function stored in global \$kernel_"	
display "VC variable name stored in global \$vcoeff_"	
*macro drop y par_x varx full_x sweight 
	if "`plot'"!="" {
		tempname _cv 
		svmat cvbw, name(`_cv') 
		scatter `_cv'2 `_cv'1 , xtitle("bandwidth") ytitle("CV criteria") legend(off) xline(`bwop')
	}
matrix colname 	cvbw=  bw cv
return matrix bwcv_trace=cvbw
return scalar bandwidth=`bwop'
return scalar cv_criteria=`cvop'
return local kernel="`kernel'"
*mata: mata drop x y 
 
end

 
