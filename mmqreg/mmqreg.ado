*! v3 Mth Bug
 

** verifies nlist using own rules
program define mynlist,rclass
	syntax anything, 
	numlist `anything',  range(>0 <100) sort
	mata:tk = tokens("`r(numlist)'")'
	mata:tk = invtokens(uniqrows(tk)')
	mata:st_local("num",tk)
	mata: mata drop tk
	numlist "`num'",  range(>0 <100) sort
	return local numlist `r(numlist)'
end

** Main program calling on mmqreg
program define mmqreg , eclass 

if replay() {
	if !missing("`e(old)'") mmqreg_old `0'
	else { 
		if "`e(cmd)'"=="mmqreg" {
			// Display options allows to get right Outcome
			display_mmqreg `0'
			exit
		}
		else {
			display in red "Last estimations not found"
			error 301
		}
	}
 }

syntax varlist(fv) [ pw ] [in] [if]  ,  /// Standard syntax: Only allows for PW
			[Absorb(varlist) /// Indicates what to "absorb"
			 Quantile(str)   /// Which quintile to use. may allow for dups
			denopt(str)      /// this will allow alternative definitions of quantiles. 
							 /// default: qreg  qv2: pctile  qv3: interpolation empirical
			robust	 		 /// No longer Hidden
			cluster(varname) /// 
			dfadj            /// Degrees of freedom adjustment K + FE -1
			nowarning LS     ///
			level(passthru)  ///
			nose   old         *  /// assume default is NOLS, 
			 ]

if !missing("`old'") {
	mmqreg_old `0'
	exit
}	
	** verify one is "Absorbing". When Absorbing, use reghdfe
	if "`absorb'"!="" {
		qui:capture which hdfe
		if _rc==111 {
			display in red "Absorb Option requires community-contributed command " as result "hdfe"
			display as text "You can install it using {stata ssc install hdfe}"
			exit 111
		}
		qui:capture which ftools
		if _rc==111 {
			display in red "Absorb Option requires community-contributed command " as result "ftools"
			display as text "You can install it using {stata ssc install ftools}"
			exit 111
		}
	}
	
	**** from here we capture dep and indep
    ** Notes for extension: Weights. How are the different moments affected by weights?
	** How to incorporate clusters?
	** Idea Still break in 2 groups FE and No FE
		mmqregx `0'
	  
	  display_mmqreg, `robust' `cluster' `gls' `wboot' `level'
	  // level 
end

program adde, eclass
	ereturn `0'
end

program define display_mmqreg
	syntax, [* robust cluster(varname) gls dfadj level(passthru)]
	display as text "MM-qreg Estimator"
	display as text "Number of obs = " as result "`=e(N)'"
	if "`absorb'"!="" display as text "Absorbed Variables: " as result "`absorb'"
	if rowsof(e(qth))==1 {
	    local qqq=det(e(qth))*100
		display as text "Quantile:" as result %3.2g `qqq'
		}
	if "`dfadj'"!="" local b b	
	if "`robust'`cluster'`gls'`dfadj'"=="" {
		** nothing here
	}	
	else if "`robust'"!="" {
		tempname V
		matrix `V' = e(vcv1`b')
		adde repost V = `V'
		adde local vce       "robust"
		adde local vcetype   "robust"		
		
 	}
	else if "`cluster'"!="" {
		tempname V 
		matrix `V' = e(vcv2`b')
		adde repost V = `V' 
		adde local vce       "cluster"
		adde local vcetype   "robust"
 	} 
	else if "gls"!="" {
		tempname V 
		matrix `V' = e(vcv0`b')
		adde repost V = `V' 
		adde local vce       "gls"
		adde local vcetype   "gls"
 
 	}
	ereturn display, `level'
end

program define mmqreg_nose, eclass sortpreserve
	qui:syntax varlist(fv) [in] [if] [ pw ], ///
		[Quantile(str) Absorb(varlist) cluster(varname) denopt(str) dfadj robust nowarning LS nose]
	** start with sample checks
	capture drop _i_* 
	capture drop ___zero___
	marksample touse
	markout `touse' `varlist' `absorb' `cluster'
	** sort qtile. No need because its Checked before
 	if "`quantile'"=="" local quantile 50
	capture mynlist "`quantile'" 
	if _rc==125 {
		display in red "Quantile must be larger than 0 and smaller than 100"
		exit 125
	}
	local quantile  `r(numlist)'
	
	** type of STD Robust
	
	
	** variable definitions: dependent and independent
	** here I can add the new set of variables
	** ! Need to modified so there is no problem with long variables. 

		** 
 	if "`absorb'"=="" {
		tokenize `varlist'
		local y `1'
		macro shift
		local xvar `*'
		** When no FE 
		qui:reg `y' `xvar' if `touse' [`weight'`exp']
		tempname beta
		matrix `beta'=e(b)
		local bname: colnames `beta'
		local df_a= 0
		** predict residual. 
		tempvar res ares
		qui:predict double `res' , res
		qui:gen     double `ares'=abs(`res')
		** estimation of scale 
		tempvar ares_hat st_res
		qui:reg `ares' `xvar' if `touse' [`weight'`exp']
		tempname gamma 
		matrix `gamma'=e(b)
		qui:predict double `ares_hat', xb
	
	}
	if "`absorb'"!="" {

		qui:myhdfe `varlist' if `touse' [`weight'`exp'], abs(`absorb')
		local df_a= `r(df_a)'
		    ** name of all variables for equation
		local bname `r(fullvar)'  
		gettoken gfn bname:bname
		local acxvar `r(finvar)'
		qui:gen byte ___zero___=0
		
		tokenize `acxvar'
		local y `1'
		macro shift
		local xvar `*'
		 
		** estimation of location effect. Necesary. Leave weights but not for now.
		qui:reg `y' `xvar' if `touse' [`weight'`exp']
		tempname beta
		matrix `beta'=e(b)
		** predict residual. 
		tempvar res ares
		qui:predict double `res' , res
		qui:gen     double `ares'=abs(`res')
		qui:myhdfe `ares' if `touse' [`weight'`exp'], abs(`absorb')
 
		local df_a= `r(df_a)'
		** estimation of scale 
		tempvar ares_hat st_res
		qui:reg _i_`ares' `xvar' if `touse' [`weight'`exp']
		tempname gamma 
		matrix `gamma'=e(b)
		qui:predict double `ares_hat', res
		** Idea y = xb + fe + error -> xb+fe=y-err <-- needed for Ahat
		qui:replace `ares_hat'=`ares'-`ares_hat'
		qui:sum `ares_hat' if `touse', meanonly
		** if scale is negative, Stop? for now will continue
		** generate standardized residuals. Send St_res to Mata

	}

end
 
program define mmqregx, eclass sortpreserve
	qui:syntax varlist(fv) [in] [if] [ pw ], ///
		[Quantile(str) Absorb(varlist) cluster(varname) denopt(str) dfadj robust nowarning LS nose]
	** start with sample checks
	capture drop _i_* 
	capture drop ___zero___
	marksample touse
	markout `touse' `varlist' `absorb' `cluster'
	** sort qtile. No need because its Checked before
 	if "`quantile'"=="" local quantile 50
	capture mynlist "`quantile'" 
	if _rc==125 {
		display in red "Quantile must be larger than 0 and smaller than 100"
		exit 125
	}
	local quantile  `r(numlist)'
	
	** type of STD Robust
	
	
	** variable definitions: dependent and independent
	** here I can add the new set of variables
	** ! Need to modified so there is no problem with long variables. 

		** 
 	if "`absorb'"=="" {
		tokenize `varlist'
		local y `1'
		macro shift
		local xvar `*'
		** When no FE 
		qui:reg `y' `xvar' if `touse' [`weight'`exp']
		tempname beta
		matrix `beta'=e(b)
		local bname: colnames `beta'
		local df_a= 0
		** predict residual. 
		tempvar res ares
		qui:predict double `res' , res
		qui:gen     double `ares'=abs(`res')
		** estimation of scale 
		tempvar ares_hat st_res
		qui:reg `ares' `xvar' if `touse' [`weight'`exp']
		tempname gamma 
		matrix `gamma'=e(b)
		qui:predict double `ares_hat', xb
		** Idea y = xb + fe + error -> xb+fe=y-err <-- needed for Ahat
 		qui:sum `ares_hat' if `touse', meanonly
		** if scale is negative, Stop? for now will continue
		** generate standardized residuals. Send St_res to Mata
	}
	if "`absorb'"!="" {

		qui:myhdfe `varlist' if `touse' [`weight'`exp'], abs(`absorb')
		local df_a= `r(df_a)'
		    ** name of all variables for equation
		local bname `r(fullvar)'  
		gettoken gfn bname:bname
		local acxvar `r(finvar)'
		qui:gen byte ___zero___=0
		
		tokenize `acxvar'
		local y `1'
		macro shift
		local xvar `*'
		 
		** estimation of location effect. Necesary. Leave weights but not for now.
		qui:reg `y' `xvar' if `touse' [`weight'`exp']
		tempname beta
		matrix `beta'=e(b)
		** predict residual. 
		tempvar res ares
		qui:predict double `res' , res
		qui:gen     double `ares'=abs(`res')
		qui:myhdfe `ares' if `touse' [`weight'`exp'], abs(`absorb')
 
		local df_a= `r(df_a)'
		** estimation of scale 
		tempvar ares_hat st_res
		qui:reg _i_`ares' `xvar' if `touse' [`weight'`exp']
		tempname gamma 
		matrix `gamma'=e(b)
		qui:predict double `ares_hat', res
		** Idea y = xb + fe + error -> xb+fe=y-err <-- needed for Ahat
		qui:replace `ares_hat'=`ares'-`ares_hat'
		qui:sum `ares_hat' if `touse', meanonly
		** if scale is negative, Stop? for now will continue
		** generate standardized residuals. Send St_res to Mata

	}
	 	 
	if `r(min)'<=0 & "`warning'"=="" {
		qui:count  if `touse'	& `ares_hat'<0
		display  "WARNING: some fitted values of the scale function are negative" ///
				_n "Consider using a different model specification" ///
				_n "`r(N)' Observations have negative predicted Scale values"
				* "The command will proceed using the Absolute value of these observations"
		*qui:replace `ares_hat'=abs(`ares_hat')		
	}
	*** Qvakues	
	qui:gen double `st_res'=`res'/`ares_hat'
	tempname qval qth fden	
	** and get the "quantile". Here we obtain all qth qval and fden
	foreach q in `quantile' {	
		if "`denopt'"!="" local denopt=",`denopt'"
		if "`weight'"!="" local wgt2 iw
		qui:qreg `st_res' if `touse' [`wgt2'`exp'], q(`q') vce(iid `denopt') 
		local denmethod `e(denmethod)' 
		local bwmethod `e(bwmethod)' 
		matrix `qval'=nullmat(`qval'),_b[_cons]
		matrix `fden'=nullmat(`fden'),`e(f_r)'
		matrix `qth' =nullmat(`qth') ,`e(q)'
	}
	
	*** MATA
	mata:mmqreg=mmqreg()
	mata:mmqreg.clust=0
	mata:mmqreg.ls=0
	if "`ls'"!=""       mata:mmqreg.ls=1
	mata:mmqreg.wvar=1
	mata:mmqreg.beta     = st_matrix("`beta'" )
	mata:mmqreg.gamma    = st_matrix("`gamma'")
	mata:mmqreg.qth		 = st_matrix("`qth'"  ) 
	mata:mmqreg.qval	 = st_matrix("`qval'" )
	if !missing("`se'") {
		** load Data
		mata:mmqreg.part_est()
		*** Always needed

	}
	else {
		if "`cluster'"!=""  {
			sort `cluster'
			mata:mmqreg.clust=1
			mata:mmqreg.cvar = st_data(.,"`cluster'","`touse'") 
		}
		mata:mmqreg.yvar     = st_data(.,"`y'","`touse'") 
		mata:mmqreg.xvar     = st_data(.,"`xvar'","`touse'"), J(rows(mmqreg.yvar),1,1)
			

		
		***
		mata:mmqreg.uvar     = st_data(.,"`res'"      ,"`touse'")
		mata:mmqreg.xvargamma= st_data(.,"`ares_hat'","`touse'") 
		if "`exp'"!=""      {
			local exp2       = subinstr("`exp'","=","",.)
			mata:mmqreg.wvar = st_data(.,"`exp2'"      ,"`touse'")
		}
		

		mata:mmqreg.fden 	 = st_matrix("`fden'" )
		mata:mmqreg.df_adj   = `df_a'

		*** Now qw so
		mata:mmqreg.full_est()
 
	}
	* After the mata code is run, I get vq bq
	* but need extra info. eq name and betas
	* This should capture all EQ names
	if "`ls'"!="" local eqnmls="location "*colsof(`beta')+"scale "*colsof(`beta')
	
	local nmb:word count `quantile'
	** EQ names
	if `nmb'>1 {
		foreach q in `quantile' {
			local strq=subinstr("`q'",".","_",.)
			local eqnmlsq ="`eqnmlsq' "+"q`strq' "*colsof(`beta')
			local eqqnm   ="`eqqnm' "  +"q`strq' "
		}
	}
	else {
		local eqnmlsq="qtile "*colsof(`beta')
	}

	** for qreg
	if "`ls'"!="" local bnm2="`bname' "*(2+colsof(`qval'))
	else          local bnm2="`bname' "*(colsof(`qval'))
	 ** 
	local mmqr_name = "`bnm2' "
	local mmqr_eqnm = "`eqnmls' "+ "`eqnmlsq' "
	** for LS
	local LS_name = "`bname' "*2 + "`eqqnm' "
	local LS_eqnm = "`eqnmls' "  + "`qtile'"
 	
	 
	matrix colname __bq = `mmqr_name'
	matrix coleq   __bq = `mmqr_eqnm'
	matrix colname __blsq = `LS_name'
	matrix coleq   __blsq = `LS_eqnm'
	
	if missing("`se'") {
		foreach i in 0 1 0b 1b   {
			  matrix colname __vcv`i' = `mmqr_name'
			  matrix coleq   __vcv`i' = `mmqr_eqnm'
			  matrix rowname __vcv`i' = `mmqr_name'
			  matrix roweq   __vcv`i' = `mmqr_eqnm'
			  matrix colname __vce`i' = `LS_name'
			  matrix coleq   __vce`i' = `LS_eqnm'
			  matrix rowname __vce`i' = `LS_name'
			  matrix roweq   __vce`i' = `LS_eqnm'
		}
		if "`cluster'"!="" {
			 foreach i in  2 2b {
				 matrix colname __vcv`i' = `mmqr_name'
				 matrix coleq   __vcv`i' = `mmqr_eqnm'
				 matrix rowname __vcv`i' = `mmqr_name'
				 matrix roweq   __vcv`i' = `mmqr_eqnm'	
				 matrix colname __vce`i' = `LS_name'
				 matrix coleq   __vce`i' = `LS_eqnm'
				 matrix rowname __vce`i' = `LS_name'
				 matrix roweq   __vce`i' = `LS_eqnm'
			 }
		}
	}
	** and post them
	tempname bb 
	if "`dfadj'"!="" local b b
	if missing("`se'") {
		tempname vv
		if "`robust'`cluster'" == "" matrix `vv' = __vcv0`b'
		else if "`robust'" != ""     matrix `vv' = __vcv1`b'
		else if "`cluster'" != ""    matrix `vv' = __vcv2`b'
	}
	
	
	ereturn post __bq `vv' , esample(`touse') buildfvinfo findomitted  obs( `=scalar(__nobs)' )
	
	ereturn local cmd 		"mmqreg"
	ereturn local cmdline 	"mmqreg `0'"
	*ereturn local predict  "mmqreg_p"
	ereturn local vce       "gls"
	ereturn local vcetype   "gls"
	if "`robust'`cluster'"!="" {
		ereturn local vcetype  "Robust"
		ereturn local vce "cluster"
		if "`cluster'"!="" {
    		ereturn local vce "cluster"
			ereturn scalar N_clust =scalar(__n_clust)
			ereturn local clustvar "`cluster'"
		}
	}
 
	ereturn matrix qth `qth'
	ereturn matrix qval `qval'
	ereturn matrix fden `fden'
	ereturn local fevlist `absorb'
	
	local 1:word 1 of `varlist'
	ereturn local depvar `1'
	ereturn	local denmethod `denmethod' 
	ereturn	local bwmethod `bwmethod' 
	
	if "`dfadj'"!= "" {
		ereturn scalar df_r = scalar(__df_r)
	}
	
	if missing("`se'") {
		foreach i in 0 1 0b 1b   {
			 ereturn matrix vcv`i' = __vcv`i' 
		}
		if "`cluster'"!="" {
			 foreach i in 2 2b   {
				  ereturn matrix vcv`i' = __vcv`i' 
			 }
		}
	}
	** Extra
	ereturn matrix blsq = __blsq
	
	capture drop _i_* ___zero___
	mata mata drop mmqreg
end

**** This program creates the demean recentered statistics.

program define myhdfe, rclass
syntax varlist(fv) [if] [in] [aw pw iw fw], ABSorb(varlist)
* step 1. Get list of variables
	if "`weight'"=="pweight" local weight aweight

	marksample touse
	ms_fvstrip `varlist' if `touse', expand dropomit
	local fullxv  `r(fullvarlist)'
	local parxv   `r(varlist)'
	hdfe `varlist' if `touse' [`weight'`exp'], abs(`absorb') gen(_i_)   keepsingletons
	local df_a `e(df_a)'
	local actxv   `r(varlist)'
	markout `touse' _i_*
	* ___zero___=0
	local wcnt=wordcount("`fullxv'")
	local ii=1
	forvalues i=1/`wcnt' {
		local 1:word `i'  of `fullxv'
		local 2:word `ii' of `parxv'
		local 3:word `ii' of `actxv'
		if "`1'"=="`2'" {
			local fvarxv `fvarxv' _i_`3'
			local ii=`ii'+1
			if "`weight'`exp'"!="" sum `1' if `touse' [`weight'`exp'], meanonly
			**fail safe. if a variable is too small im assuming zero
			sum _i_`3' if `touse' , meanonly
			if r(max)<epsfloat() {
				qui:replace _i_`3'=0
			}
			else {
			    sum `1' if `touse' [`weight'`exp'], meanonly
			    replace _i_`3'=_i_`3'+r(mean)
			}
		}
		else {
			local fvarxv `fvarxv' ___zero___
		}
	}
	return local finvar `fvarxv' 
	return local fullvar `fullxv' _cons
	return scalar df_a= `df_a' 
end


mata
class mmqreg {
	// yvar, xvar, cvar, wvar
	real matrix yvar 
	real matrix xvar 
	real matrix uvar 
	real matrix xvargamma
	real matrix cvar 
	real matrix wvar
	
	real matrix qth
	real matrix qval
	real matrix fden
	
	real matrix beta, betaq, betalsq
	real matrix gamma
	real scalar nobs, k, qk, ls, n_clust, df_adj
	real scalar type, clust,nn
	real matrix qxx, iqxx
	real matrix vvar
	real matrix iff, if1, if2, if3
	void        setup()
	real matrix vce0, vce0b, vcv0, vcv0b 
	real matrix vce1, vce1b, vcv1, vcv1b
	real matrix vce2, vce2b, vcv2, vcv2b
	real matrix        vce0()
	real matrix        vce1()
	real matrix        vce2()
	void        post()
	void 	    betas_vcv()
	void        full_est()
	void        part_est()
}

///  assume data loaded in do-file
///  load data, set parameters
///  wgt = 1

/// setup2 for FE Setup1 No fe
void mmqreg::full_est(){
	 setup()
	 betas_vcv()
	 post()
}

void mmqreg::part_est(){
	real scalar i
	nobs = rows(yvar)
	k    = cols(beta)
	qk   = cols(qval)
	
 	betalsq = beta, gamma
	  
	if (ls==1) 	betaq = betalsq
	else betaq = J(1,0,.)
	
	betalsq = beta, gamma, qval
 
	// All Qregs
	for(i=1;i<=qk;i++) {
		betaq = betaq , (beta+gamma*qval[i])
	}
	
	st_matrix("__bq",betaq)
	st_matrix("__blsq",betalsq)
	st_numscalar("__nobs", nobs)
}

void mmqreg::setup() {
	real scalar i
	real matrix xvargamma_bar
	nobs = rows(yvar)
	k    = cols(beta)
	qk   = cols(qval)
	// uvar 
	if (rows(wvar)>1) {
		wvar = wvar:/mean(wvar)
		qxx  = cross(xvar,wvar,xvar); iqxx = invsym(qxx)
		xvargamma_bar = mean(xvargamma,wvar)
		vvar = 2*uvar :* ((uvar:>=0) :- mean(uvar:>=0,wvar)) 
	}
	else {
		qxx     = cross(xvar,xvar); iqxx = invsym(qxx)
		xvargamma_bar = mean(xvargamma)
		vvar = 2*uvar :* ((uvar:>=0) :- mean(uvar:>=0     )) 
	}
	//
	
	if1  = nobs*(xvar:* uvar              )*iqxx 
	if2  = nobs*(xvar:*(vvar :- xvargamma))*iqxx 
	if3  = J(nobs,qk,.)
	for(i=1;i<=qk;i++) {
		if3 [.,i] = 1/fden[i] * (qth[i] :- ( (qval[i]*xvargamma :- uvar ) :>= 0)) :- 
					 uvar :/ xvargamma_bar   :-  qval[i] * (vvar:-xvargamma):/xvargamma_bar
	}
 	if (rows(wvar)>1) {
		iff = (if1,if2,if3):*wvar
	}
	else {
		iff = (if1,if2,if3)
	}
	
}
 real matrix mmqreg::vce0(){
	real matrix suvw, su , sv, sw
	real matrix omgs, omg, Qxx, Pxx , us2
	su    = uvar:/xvargamma
	sv    = vvar:/xvargamma:-1
	sw    = if3 :/xvargamma
	suvw  = (su,sv,sw)
 	if (rows(wvar)>1) {
		omgs  = cross(suvw,wvar,suvw):/nobs 
		// (x'x)^-1 * (x'xg)
		Qxx   = if1:/su  
		Pxx   = cross(Qxx,wvar,xvargamma)
		Qxx   = cross(Qxx,wvar,Qxx)
		us2   = cross(xvargamma,wvar,xvargamma)
	}
	else {
		omgs  = cross(suvw,suvw):/nobs
		Qxx   = if1:/su
		Pxx   = cross(Qxx,xvargamma)
		Qxx   = cross(Qxx,Qxx)
		us2   = cross(xvargamma,xvargamma)
	} 

	omg = 1/(nobs^2) *( omgs[1..2,1..2]         #Qxx , omgs[1..2,3..rows(omgs)]         # Pxx \
	                    omgs[3..rows(omgs),1..2]#Pxx', omgs[3..rows(omgs),3..rows(omgs)]# us2 )
	return(omg)					
}
 real matrix mmqreg::vce1(){
	if (rows(wvar)>1) {
		return(quadcross(iff,wvar,iff)/nobs^2)
	}
	else {
		return(quadcross(iff,iff)/nobs^2)
	} 
	
}

real matrix mmqreg::vce2(){
	real matrix info , iffs
	info  = panelsetup(cvar,1)
	// For now save it on itself iff -> iff
	if (rows(wvar)>1) {
		iffs  = panelsum(iff,wvar,info)
		return(quadcross(iffs,iffs)/nobs^2)
	}
	else {
		iffs  = panelsum(iff,info)
		return(quadcross(iffs,iffs)/nobs^2)
	} 
	
}
  
void mmqreg::betas_vcv(){
	// qreg coef
	// IF 
	real scalar i
	real matrix xi2
 	betalsq = beta, gamma
	  
	if (ls==1) {
		xi2 = ( I(k)    , J(k,k+qk,0)      )  \ ///
		      ( J(k,k,0), I(k) , J(k,qk,0) )  \ ///
		        J(qk,1,1)#I(k) , qval'#I(k) , I(qk) # (gamma') 
		betaq = betalsq
	}
	else {
		xi2   = J(qk,1,1)#I(k) , qval'#I(k) , I(qk) # (gamma')  
		betaq = J(1,0,.)
	}
 	 betalsq = beta, gamma, qval
 
	// All Qregs
	for(i=1;i<=qk;i++) {
		betaq = betaq , (beta+gamma*qval[i])
	}
 	//adj factors
	nn = nobs - (k-diag0cnt(qxx)) - df_adj 
 	// no_adj
	vce0 = makesymmetric(vce0())
	vce1 = makesymmetric(vce1())
 
	vcv0 = makesymmetric(xi2 * vce0 * xi2')
	vcv1 = makesymmetric(xi2 * vce1 * xi2')
	
	if (clust==1) {
		vce2 = makesymmetric(vce2())
		vcv2 = makesymmetric(xi2 * vce2 * xi2' )
		n_clust=rows(uniqrows(cvar))
	}
	
	// with_adj 	
	vcv0b     = vcv0 * (nobs / nn )
	vcv1b     = vcv1 * (nobs / nn )
	vce0b     = vce0 * (nobs / nn )      
	vce1b     = vce1 * (nobs / nn )
	if (clust==1) {
		vce2b = vce2 * (nobs-1)/nn * (n_clust/(n_clust-1))
		vcv2b = vcv2 * (nobs-1)/nn * (n_clust/(n_clust-1))
	}
	
}
  


void mmqreg::post(){
	st_matrix("__bq",betaq)
	st_matrix("__blsq",betalsq)
	st_matrix("__vcv0",vcv0)	
	st_matrix("__vce0",vce0)
	st_matrix("__vcv1",vcv1)
	st_matrix("__vce1",vce1)
	st_matrix("__vcv0b",vcv0b)	
	st_matrix("__vce0b",vce0b)
	st_matrix("__vcv1b",vcv1b)
	st_matrix("__vce1b",vce1b)
	if (clust==1) {
		st_matrix("__vcv2",vcv2)
		st_matrix("__vce2",vce2)
		st_matrix("__vcv2b",vcv2b)
		st_matrix("__vce2b",vce2b)
		st_numscalar("__n_clust", n_clust)

	}
	st_numscalar("__df_r", nn)
	st_numscalar("__nobs", nobs)
}
end
