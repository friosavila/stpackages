*** Project. Generalized CV for Varying coefficient models
** change all globals into locals
** NOW IN MATA 
** 2.1 This will try to make the Optimization within Mata. May be more efficient
** last change was to modify with a flag for ealy ending
mata:mata clear
capture program drop vc_bwmt
program vc_bwmt, rclass  sortpreserve
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
	**# Defining 3 levels of Samples 1. Sample to work
	marksample touse
	markout `touse' `varlist' `vcoeff' 
	** Legacy
	if "`sample'"!="" {
	   qui:	replace `touse'=0 if `sample'==0 
	}
	** Sample 3 Sample based on Trimsample (for CV calculation)
	tempvar touse3
	qui:gen `touse3'=1
	if "`trimsample'"!="" {
		qui:replace `touse3'=`trimsample'*`touse'
	}
		
	*local varx `varx'
    local full_x `vcoeff'
	*verifying if knots its a sensible number
	numlist "`knots'", integer range(>=-2)
	
	**# This counts how many values vcoeff has
	
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
	
	**# And this defines groups to be used.
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
	
	** sample level 3 . Only 1 observation per parx
	tempvar touse2
	qui:bysort  `touse' `par_x':gen byte `touse2'=(_n==1)*(`touse'==1)
	
	
	**# Undocumented for weights
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
		 if	"`kernel'"=="gaussian" 	local k = 1
	else if "`kernel'"=="epan" 		local k = 2
	else if "`kernel'"=="epan2" 	local k = 3 
	else if "`kernel'"=="biweight"  local k = 4
	else if "`kernel'"=="cosine"    local k = 5
	else if "`kernel'"=="cosine2"   local k = 6
	else if "`kernel'"=="parzen"    local k = 7
	else if "`kernel'"=="rectan"    local k = 8
	else if "`kernel'"=="trian"     local k = 9
	else if "`kernel'"=="logistic"  local k = 10
	else if "`kernel'"=="tricube"   local k = 11
	else if "`kernel'"=="triweight" local k = 12
	else {
		display "Kernel function `kernel' not allowed"
		exit 1
	}
	
	**# Initial bandwidth based on lpoly
	if `bwi'==-1 {
		lpoly `y' `full_x' if `touse', nograph kernel(`kernel') degree(1)
		** Initial BW adjusts for number of parameters in the explanatory variable. Better adjustments can be found.
		** in principle more explanatory variables require a larger bandwidth
		local num : word count `varx'
		local bw1=(1+ln(`num'+1))*r(bwidth)
    }
	else {
		local bw1=`bwi'
	}
	local bwi=`bw1'
	**# Here is the new code for CV
	*1 call on Mata
	local fvarx=	"`full_x' `varx' c.`full_x'#c.(`varx')"
	
	tempname bwmatrix cvbw
	
	mata:main_cvreg("`y'","`fvarx'","`full_x'","`par_x'","`touse'", "`touse2'", "`touse3'", `bwi' , `k',"`bwmatrix'","`cvbw'")
				
	** Opt
	matrix cvbw = `cvbw'
	global opbw_=`bwmatrix'[1,1]
	global kernel_="`kernel'"	
	global vcoeff_="`vcoeff'"	
	display "Bandwidth stored in global \$opbw_"
	display "Kernel function stored in global \$kernel_"	
	display "VC variable name stored in global \$vcoeff_"		
		if "`plot'"!="" {
			tempname _cv 
			svmat cvbw, name(`_cv') 
			scatter `_cv'2 `_cv'1 , xtitle("bandwidth") ytitle("CV criteria") legend(off) xline($opbw_)
		}
	matrix colname 	`cvbw'=  bw cv
	*macro drop y par_x varx full_x sweight 

	return scalar bandwidth=`bw1'
	return scalar cv_criteria=`bwmatrix'[1,2]
	return local kernel="`kernel'"
	return matrix bwcv_trace=cvbw
	*capture mata:mata drop x y 
end


** touse  Sample
** touse2 small sample only those needed.
** touse3 trim sample
mata:

void main_cvreg(string scalar depvar, 
				string scalar indepvar, 
				string scalar fcsvar,
				string scalar pcsvar, 
				string scalar touse , touse2, touse3, 
				real   scalar bwi,
				real   scalar k,
				string scalar bwm, cvbwm ) 
	{
		real matrix y,x ,fvc,pvc,vc,trim
		y=st_data(.,depvar,touse)
		x=st_data(.,indepvar,touse)
		x=x,J(rows(x),1,1)
		fvc= st_data(., fcsvar,touse)
		pvc= st_data(., pcsvar,touse)
		vc = st_data(., pcsvar,touse2)
	   trim= st_data(., touse3,touse)
 	
		pointer matrix fdata
		fdata=(&y,&x,&fvc,&pvc,&vc,&k,&trim)
		// From here I can do similar evaluation as I did Before. Slow...but effective
		// 1st store matrix with results
		 
		real scalar bw0, bw1, bw2, cbw
		real scalar cv0, cv1, cv2, ccv
		real matrix cvbw	
		real scalar df, ddf
		real scalar chg,  dch,  pch, iter
		real scalar flag_imp, cntl, flagbw
		/// bws
			bw0=bwi*.99
		cbw=bw1=bwi
			bw2=bwi*1.01
		///cvs
		
			cv0=log( mean (cv_looerr(fdata,bw0):^2 ) )
		ccv=cv1=log( mean (cv_looerr(fdata,bw1):^2 ) )
			cv2=log( mean (cv_looerr(fdata,bw2):^2 ) )
 
			
		//matrix with all cvbw
 
		cvbw = (bw0,cv0)\ (bw1,cv1) \(bw2,cv2)
		// init iter
		iter=0
 
		/// First Print out
		printf("Iteration %f BW:  %10.7f CV: %10.7g \n",iter, bw1 , cv1)
		
		/// Derivatives (numerical)
			df =(cv2-cv0)/(bw2-bw0)
			ddf=(cv2-2*cv1+cv0)/(bw2-bw1)^2
			//df1=(cv2-cv1)/(bw2-bw1)
			//df2=(cv1-cv0)/(bw1-bw0)
		/// Improvement 
			chg=-df/abs(ddf)
			
		/// This is to estimate bw0 and bw2.  	
			dch=min( (0.01*bw1, abs(chg)) )
		
			pch=1
		// Here we have the loop for improvements
 
		iter++
	    for(flagbw=0 ;( abs(pch)>.0001 & flagbw==0 ) ;iter++) {
			// verify its not negative
				if ((bw1+chg)<0) 	chg=-0.5*bw1
			// 1. Change BW so there is an improvment
				for(cntl=flag_imp=0; (flag_imp==0 & cntl<5) ; cntl++) {
					bw1=cbw+chg
					cv1=log( mean (cv_looerr(fdata,bw1):^2 ) )
					cvbw = cvbw \ (bw1,cv1)
					
					if (cv1<ccv) flag_imp=1
					else {
						chg=0.5*chg
						dch=min((0.01*cbw,abs(chg)))
						bw1=cbw+chg
					}				
				}
			//relative change	
				pch = chg/bw1
			// Update new bw
				bw2=bw1+dch
				bw0=bw1-dch
				cv0=log( mean (cv_looerr(fdata,bw0):^2 ))
				cv2=log( mean (cv_looerr(fdata,bw2):^2 ))	
			// add to matrix	
				cvbw = cvbw \ (bw0,cv0)\ (bw2,cv2)
			// update old cbw ccv
				cbw=bw1
				ccv=cv1
			// calculate derivatives, and changes
				df =(cv2-cv0)/(bw2-bw0)
				ddf=(cv2-2*cv1+cv0)/(bw2-bw1)^2
				chg=-df/abs(ddf)
				dch=min( (0.01*bw1, abs(chg)) )
				if (bwi*100<bw1) {
					flagbw=1
					printf("BW too large")
				}
			// printing iterations	
			printf("Iteration %f BW:  %10.7f CV: %10.7g \n",iter, bw1 , cv1)	
		}
		
		st_matrix(bwm,(bw1,cv1))
		st_matrix(cvbwm,cvbw)
	}

///////////////////////////////////////////////////////////////////////	
// Evaluator Didnt work
	void cv_eval(todo, bw, fdata, cv, g, H) {
 		ss = mean( (cv_looerr(fdata,exp(bw))):^2 )
     }	
 
// fcsvar Full vcoeff variable 
// pcsvar partial vcoeff variable Subset to go over
real matrix cv_looerr(pointer vector fdata, 
						real scalar bw)
	{
		///string scalar depvar, string scalar indepvar, 
		///		string scalar fcsvar, string scalar pcsvar, 
		///		string scalar touse , string scalar touse2, 
		///		real scalar bw, string scalar krn
		
		pointer scalar y,x ,fvc,pvc,vc
		y=fdata[1]
		x=fdata[2]
		//x=x,J(rows(x),1,1)
		fvc= fdata[3]
		pvc= fdata[4]
		vc = fdata[5]
	
		// which kernel
		// bw 
		k = *fdata[6]

		// may only need 
		real matrix loerr , loerr2, z
		loerr =J(rows(*y),1,0)
		loerr2=J(rows(*y),1,0)
		// 
		for(i=1;i<=rows(*vc);i++) {
			/// point of reference
			z=( (*fvc) :- ( (*vc)[i] ) ):/bw
			
			/// kernel weight
 			w=kweight( &z , 1)
 
			/// elements of the OLS
			ixwx=invsym(quadcross(*x, w,*x))
			xwy=quadcross(*x,w,*y)
			/// leverage Stat
			lrv=quadrowsum(( (*x)*ixwx ):* ((*x):*w))
			/// This info is to be stored
			yhat=(*x)*(ixwx*xwy)
			loerr=((*y)-yhat):/((lrv:*-1):+1) 
			loerr2=loerr2+loerr:*((*pvc):==((*vc)[i]))
		}
		return(loerr2)
	}

	 
	real matrix kweight(pointer scalar z,real scalar k)
	{
		if (k==1) {
			kz=normalden((*z)):/normalden(0)
		}
		else if (k==2) {
			kz=(-0.2*((*z):^2):+1):*(abs((*z)):<(5^.5))
		}
		else if (k==3) {
			kz= (-(*z):^2:+1):*(abs((*z)):<1)
		}
		else if (k==4) {
			kz=(-(*z):^2:+1):^2:*(abs((*z)):<1)
		}
		else if (k==5) {
			kz=(cos(2*pi()*(*z)):+1):/2:*(abs((*z)):<0.5)
		}
		else if (k==6) {
			kz=cos(pi()/2*(*z)):*(abs((*z)):<1)
		}
		else if (k==7) {
			kz=((-6*(*z):^2+6*abs((*z)):^3):+1):*(abs((*z)):<=0.5)+(-abs((*z)):+1):^3:*2:*((abs((*z)):>0.5):*(abs((*z)):<=1))
		}
		else if (k==8) {
			kz=abs((*z)):<=1
		}
		else if (k==9) {
			kz=(-abs((*z)):+1):*(abs((*z)):<=1)
		}
		else if (k==10) {
			kz=(exp((*z))+exp((*z):*-1):+2):^-1:*4
		}
		else if (k==11) {
			kz=(-abs((*z)):^3:+1):^3:*(abs((*z)):<1)
		}
		else if (k==12) {
			kz=(-abs((*z)):^2:+1):^3:*(abs((*z)):<1)
		}
		return(kz)
	}

end 

 
