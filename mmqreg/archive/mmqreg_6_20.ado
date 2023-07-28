*! v2.21 keep singletons
*! v2.2  Simultaneous Q's for model simple
* v2.1  Corrects Bug Clustered SE and DF
* v2  Corrects Bug and Speeds up Clustered SE
* v1.8 adds Obs
* v1.7 corrects e(cmd_line) to cmdline and problems with "program drop"
* v1.6 Small improvements estimation efficiencies. I also allow for WEIGHTS!
* v1.5 August 2020 MMQREG by Fernando Rios-Avila
* Bug for simmultanous MMQREG fixed
* v1.4 Julu 2020 MMQREG by Fernando Rios-Avila
* Some efficiency improvement for clustered standard errors
* v1.3 June 2020 MMQREG by Fernando Rios-Avila
* In addition to DFadj also provides Z stats. 
* Most likely definite version. Next will be more aestetics in terms of what to report. 
* v1.2 June 2020 MMQREG by Fernando Rios-Avila
* Correct a typo for generation of W. It also gives the option for cluster and robust standard errors
* that can be adjusted for degrees of freedom.
* v1.1 May 2020 MMQREG by Fernando Rios-Avila
** Corrects issue with VCOV matrix. Due to numerical precision it may give an error. Now it :forces the symetry using makesymmetric()
** Perhaps Drops Singletons...
** it does allow for clustered stadnard errors
** Also, this version will drop singletons. They do nothing and make things work for the second step 
** v1.0 MMQREG by Fernando Rios-Avila
** Thanks to Joao Santos Silva for conversations and clarifications about the methodology
** this program is an adaptation of xtqreg that would
** in theory, allow for the estimator when no fixed effects exist,
** and when Multiple fixed effects exist
** While doing this 1 typo from MM paper was found.
** 1 for the estimation of SIGMA model two E(V^2) should be E((V-1)^2)


/*
capture program drop mynlist
capture program drop mmqreg 
capture program drop display_mmqreg
capture program drop mmqreg1
capture program drop mmqreg2
capture program drop myhdfe
*/

program define mynlist,rclass
	syntax anything, 
	numlist `anything',  range(>0 <100) sort
	loca j scalar(_pi)
	foreach i in  `r(numlist)' {
		if `i'!=`j' {
		    local numlist `numlist' `i'
		} 
		local j=`i'
	}
	return local numlist `numlist'
end


program define mmqreg , eclass 

 if replay() {
	if "`e(cmd)'"=="mmqreg" {
	    display_mmqreg
		exit
	}
	else {
	    display in red "Last estimations not found"
		error 301
	}
 }

	syntax varlist(fv) [ pw aw iw fw] [in] [if]  ,  /// Standard syntax
								[Absorb(varlist) /// Indicates what to "absorb"
								 Quantile(str)   /// Which quintile to use. may allow for dups
								denopt(str)      /// this will allow alternative definitions of quantiles. default: qreg  qv2: pctile  qv3: interpolation empirical
								robust	 		 /// hidden option. Alternative method for Standard errors
								cluster(varname) /// hidden
								dfadj            /// Degrees of freedom adjustment 
								 ]
	// x is a hidden option. It technically estimates omega using the larger version of the matrix
	// It will also gets the data using st_data rather than views

	** verify one is "Absorbing". When Absorbing, use reghdfe
	if "`absorb'"!="" {
		/*qui:capture which reghdfe
		if _rc==111 {
			display in red "Absorb Option requires community-contributed command " as result "reghdfe"
			display as text "You can install it using {stata ssc install reghdfe}"
			exit 111
		}*/
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
	  if "`absorb'"=="" mmqreg1 `0'
	  else 			    mmqreg2 `0'
	  display_mmqreg
end


program define display_mmqreg
	display as text "MM-qreg Estimator"
	display as text "Number of obs = " as result "`=e(N)'"
	if "`absorb'"!="" display as text "Absorbed Variables: " as result "`absorb'"
	if rowsof(e(qth))==1 {
	    local qqq=det(e(qth))*100
		display as text "Quantile:" as result %3.2g `qqq'
		}
	ereturn display  
end

program define mmqreg1, eclass sortpreserve
	qui:syntax varlist(fv) [in] [if] [ pw aw iw fw], [Quantile(str)  denopt(str) robust cluster(varname) dfadj]
	** start with sample checks
	capture drop ___zero___
	marksample touse
	markout `touse' `varlist' `absorb'
	** sort qtile. No need because its Checked before
 	if "`quantile'"=="" local quantile 50
	capture mynlist "`quantile'" 
	if _rc==125 {
		display in red "Quantile must be larger than 0 and smaller than 100"
		exit 125
	}
	local quantile  `r(numlist)'
	
	** Robust
	if "`robust'"!="" & "`cluster'"=="" local x x
	
	if "`exp'"!="" {
		tempvar mwgt 
		qui:gen double `mwgt'`exp'
		qui:sum `mwgt' if `touse', meanonly
		qui:replace `mwgt'=`mwgt'/r(mean)
		local exp "=`mwgt'"
	}
	else {
		tempvar mwgt 
		gen byte `mwgt' =1
	}
	
	** variable definitions: dependent and independent
    tokenize `varlist'
    local y `1'
    macro shift
    local xvar `*'
	
	** estimation of location effect. Necesary. Leave weights but not for now.
	qui:reg `y' `xvar' if `touse' [`weight'`exp']
	tempname lfb
	matrix `lfb'=e(b)
	** predict residual. Transformation not needed here
	tempvar res ares
	qui:predict double `res' , res
	qui:gen     double `ares'=abs(`res')
	** estimation of scale 
	tempvar ares_hat st_res
	qui:reg `ares' `xvar' if `touse' [`weight'`exp']
	tempname sfb sfV
	matrix `sfb'=e(b)
	qui:predict double `ares_hat' 
	qui:sum `ares_hat' if `touse'
	** if scale is negtive, Stop
	if `r(min)'<=0 {
	    display in red "WARNING: some fitted values of the scale function are negative" ///
				_n "Consider using a different model specification" ///
				_n "The command will proceed using the Absolute value of these observations"
		qui:replace `ares_hat'=abs(`ares_hat')		
	}
	** generate standardized residuals. Send St_res to Mata
	qui:gen double `st_res'=`res'/`ares_hat'
	tempname qval qth fden	
	** and get the "quantile". Here we obtain all qth qval and fden
	foreach q in `quantile' {	
		if "`denopt'"!="" local denopt=",`denopt'"
		qui:qreg `st_res' if `touse' [iw=`mwgt'], q(`q') vce(iid `denopt') 
		local denmethod `e(denmethod)' 
		local bwmethod `e(bwmethod)' 
		matrix `qval'=nullmat(`qval'),_b[_cons]
		matrix `fden'=nullmat(`fden'),`e(f_r)'
		matrix `qth' =nullmat(`qth') ,`e(q)'
	}
 
	** name of all variables for equation
	local bnm: colnames `sfb'
	** we need a constant.
	tempvar cns
	qui:gen byte `cns'=1
	** this code does all the rest. 
	if "`cluster'"=="" {
	mata:mmqreg_vce1`x'("`y'","`xvar' `cns'","`lfb'","`sfb'", ///
					 "`qval'","`qth'","`fden'", "`touse'","`dfadj'","`mwgt'")
	}
	else {
		sort `cluster'
		mata:mmqreg_vce1c("`y'","`xvar' `cns'","`lfb'","`sfb'", ///
					 "`qval'","`qth'","`fden'","`cluster'", "`touse'","`dfadj'","`mwgt'")
	}
	* After the mata code is run, I get vq bq
	* but need extra info. eq name and betas
	* This should capture all EQ names
	local eqnm="location "*colsof(`sfb')+"scale "*colsof(`sfb')
	* this should see how many quantiles are there
	local nmb:word count `quantile'
	
	if `nmb'>1 {
		foreach q in `quantile' {
			local strq=subinstr("`q'",".","_",.)
			local eqnm="`eqnm'"+"qtile_`strq' "*colsof(`sfb')
		}
	}
	
	else local eqnm="`eqnm'"+"qtile "*colsof(`sfb')
	
	** and this the names
	local bnm2="`bnm' "*(2+colsof(`qval'))
	** name all coefficients and other
	matrix colname __vq = `bnm2'
	matrix rowname __vq = `bnm2'
	matrix colname __bq = `bnm2'
	
	matrix coleq __vq = `eqnm'
	matrix roweq __vq = `eqnm'
	matrix coleq __bq = `eqnm'
	** and post them
	sum `touse', meanonly
	local nobs=r(sum)
		** clust obs
	if "`cluster'"!="" {
		tempvar vals
		qui:bys `touse' `cluster': gen byte `vals' = (_n == 1)*`touse'
		su `vals' , meanonly
		local N_clust = `r(sum)'
	}	
	
	ereturn post __bq __vq, esample(`touse') buildfvinfo findomitted  obs(`nobs')
	ereturn local cmd "mmqreg"
	ereturn local cmdline "mmqreg `0'"
	*ereturn local predict  "mmqreg_p"
	ereturn local vce "mmvce"
	ereturn matrix qth `qth'
	ereturn matrix qval `qval'
	ereturn matrix fden `fden'
	ereturn local fevlist `absorb'
	local 1:word 1 of `varlist'
	ereturn local depvar `1'
	ereturn	local denmethod `denmethod' 
	ereturn	local bwmethod `bwmethod' 
	
	if "`robust'`cluster'"!="" {
		ereturn local vcetype  "Robust"
		if "`cluster'"!="" {
    		ereturn local vce "cluster"
			ereturn scalar N_clust =`N_clust'
			ereturn local clustvar "`cluster'"
		}
	}
	
	if "`dfadj'"!= "" {
		ereturn scalar df_r = scalar(df_r)
	}

end


program define mmqreg2, eclass sortpreserve
	qui:syntax varlist(fv) [in] [if] [aw pw iw fw], [Quantile(str) Absorb(varlist) cluster(varname) denopt(str) dfadj robust]
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
	
	** Robust
	if "`robust'"!="" & "`cluster'"=="" local x x
	
	if "`exp'"!="" {
		tempvar mwgt 
		gen double `mwgt'`exp'
		qui:sum `mwgt' if `touse', meanonly
		qui:replace `mwgt'=`mwgt'/r(mean)
		local exp "=`mwgt'"
	}
	else {
		tempvar mwgt 
		gen byte `mwgt' =1
	}
	
	
	** variable definitions: dependent and independent
	** here I can add the new set of variables
	qui:myhdfe `varlist' if `touse' [`weight'`exp'], abs(`absorb')
	local df_a= `r(df_a)'
	** updates touse to drop singletons
	
    ** name of all variables for equation
	local bnm `r(fullvar)'  
	gettoken gfn bnm:bnm
	local acxvar `r(finvar)'
	qui:gen byte ___zero___=0
	
	tokenize `acxvar'
    local y `1'
    macro shift
    local xvar `*'
	
	markout `touse'  `y'
	** estimation of location effect. Necesary. Leave weights but not for now.
	qui:reg `y' `xvar' if `touse' [`weight'`exp']
	tempname lfb
	matrix `lfb'=e(b)
	** predict residual. Transformation not needed here
	tempvar res ares
	qui:predict double `res' , res
	qui:gen     double `ares'=abs(`res')
	
	qui:myhdfe `ares' if `touse' [`weight'`exp'], abs(`absorb')
	** estimation of scale 
	tempvar ares_hat st_res
	qui:reg _i_`ares' `xvar' if `touse' [`weight'`exp']
	tempname sfb sfV
	matrix `sfb'=e(b)
	qui:predict double `ares_hat', res
	qui:replace `ares_hat'=`ares'-`ares_hat'
	qui:sum `ares_hat' if `touse'
	** if scale is negative, Stop? for now will continue
	if `r(min)'<=0 {
	    display in red "WARNING: some fitted values of the scale function are negative" ///
				_n "Consider using a different model specification" ///
				_n "The command will proceed using the Absolute value of these observations"
		qui:replace `ares_hat'=abs(`ares_hat')		
	}
	** generate standardized residuals. Send St_res to Mata
	qui:gen double `st_res'=`res'/`ares_hat'
	tempname qval qth fden	
	** and get the "quantile". Here we obtain all qth qval and fden
	foreach q in `quantile' {	
		if "`denopt'"!="" local denopt=",`denopt'"
		qui:qreg `st_res' if `touse' [iw=`mwgt'], q(`q') vce(iid `denopt') 
		local denmethod `e(denmethod)' 
		local bwmethod `e(bwmethod)' 
		matrix `qval'=nullmat(`qval'),_b[_cons]
		matrix `fden'=nullmat(`fden'),`e(f_r)'
		matrix `qth' =nullmat(`qth') ,`e(q)'
	}

	** we need a constant.
	tempvar cns
	qui:gen byte `cns'=1
	** this code does all the rest. 
	if "`cluster'"=="" {
		mata:mmqreg_vce2`x'("`y'","`xvar' `cns'","`st_res'","`ares_hat'","`lfb'","`sfb'", ///
					 "`qval'","`qth'","`fden'", `df_a', "`touse'","`dfadj'","`mwgt'")
	}
	else {
	    sort `cluster'
	    mata:mmqreg_vce2c("`y'","`xvar' `cns'","`st_res'","`ares_hat'","`lfb'","`sfb'", ///
					 "`qval'","`qth'","`fden'", "`cluster'", `df_a', "`touse'","`dfadj'","`mwgt'")
	}
	* After the mata code is run, I get vq bq
	* but need extra info. eq name and betas
	* This should capture all EQ names
	local eqnm="location "*colsof(`sfb')+"scale "*colsof(`sfb')

	* this should see how many quantiles are there
	local nmb:word count `quantile'
	
	if `nmb'>1 {
		foreach q in `quantile' {
			local strq=subinstr("`q'",".","_",.)
			local eqnm="`eqnm'"+"qtile_`strq' "*colsof(`sfb')
		}
	}
	else local eqnm="`eqnm'"+"qtile "*colsof(`sfb')

	** and this the names
	local bnm2="`bnm' "*(2+colsof(`qval'))
	** name all coefficients and other
	matrix colname __vq = `bnm2'
	matrix rowname __vq = `bnm2'
	matrix colname __bq = `bnm2'
	matrix coleq __vq = `eqnm'
	matrix roweq __vq = `eqnm'
	matrix coleq __bq = `eqnm'
	** and post them
	sum `touse', meanonly
	local nobs=r(sum)
	** clust obs
	if "`cluster'"!="" {
		tempvar vals
		qui:bys `touse' `cluster': gen byte `vals' = (_n == 1)*`touse'
		su `vals' , meanonly
		local N_clust = `r(sum)'
	}		
	ereturn post __bq __vq, esample(`touse') buildfvinfo findomitted  obs(`nobs')
	
	ereturn local cmd "mmqreg"
	ereturn local cmdline "mmqreg `0'"
	*ereturn local predict  "mmqreg_p"
	ereturn local vce "mm-vce"
	ereturn matrix qth `qth'
	ereturn matrix qval `qval'
	ereturn matrix fden `fden'
	ereturn local fevlist `absorb'
	local 1:word 1 of `varlist'
	ereturn local depvar `1'
	ereturn	local denmethod `denmethod' 
	ereturn	local bwmethod `bwmethod' 
	
	if "`robust'`cluster'"!="" {
		ereturn local vcetype  "Robust"
		if "`cluster'"!="" {
    		ereturn local vce "cluster"
			ereturn scalar N_clust =`N_clust'
			ereturn local clustvar "`cluster'"
		}
	}
	
	** need to create the "display " function and also create mmqreg_p. 
	* may not be needed for most Marginal effects
	if "`dfadj'"!= "" {
		ereturn scalar df_r = scalar(df_r)
	}
	drop _i_* ___zero___
end

**** This program creates the demean recentered statistics.

program define myhdfe, rclass
syntax varlist(fv) [if] [in] [aw pw iw fw], abs(varlist)
* step 1. Get list of variables
	marksample touse
	ms_fvstrip `varlist' if `touse', expand dropomit
	local fullxv  `r(fullvarlist)'
	local parxv   `r(varlist)'
	hdfe `varlist' if `touse' [`weight'`exp'], abs(`abs') gen(_i_)   keepsingletons
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


mata:
 
void mmqreg_vce1x(string scalar yvar_,  string scalar xvar_,	
			 	  string scalar beta_,  string scalar gama_,
				  string scalar qval_,  string scalar qth_, 
				  string scalar fden_,  string scalar touse,  
				  string scalar dfadj,  string scalar wgt_ ) {
		real matrix xvar, yvar, wgt
		real vector beta, gama , betaq
		real vector qval, qth, fden
		real matrix u_hat, u, v, w  
		real matrix qxx, iqxx, xi, xi2, omg 
		real scalar us1, nobs, i, qs, k , nn
		real matrix vcvq
		real matrix omgx
		st_view(xvar =.,.,xvar_ ,touse)
		st_view(yvar =.,.,yvar_ ,touse)
		wgt=st_data(.,wgt_  ,touse)
		wgt=wgt:/mean(wgt)
		//wgt=wgt:/mean(wgt)
		// first load data
		beta = st_matrix(beta_)'
		gama = st_matrix(gama_)'
		// N obs k rows
		nobs = rows(xvar)
		k    = cols(xvar)
		// fden qth qval
		qval = st_matrix(qval_)
		qth  = st_matrix(qth_)
		fden = st_matrix(fden_)
		qs  =cols(qth)
		// std residuals : residuals and fitted values will be obtained with reghdfe		
		// Change this to abs
		u_hat=abs(xvar*gama)
		u    = (yvar-xvar*beta):/u_hat
		v    = 2*u:*((u:>=0):-mean(u:>=0,wgt)):-1
		
		// other elements common 
		// elements that do not depend on w
		 qxx = quadcross(xvar,wgt,xvar)
	    iqxx = invsym(qxx)
		
		// E(U_s) E(U_s^2)
		us1 = mean(u_hat,wgt)
		
		// Betas and VCOV for first and second
		// This residual changes by quantile
		
		w=J(nobs,qs,0)
		
 		for(i=1;i<=qs;i++) {
			
			w[.,i]= ( 1/fden[i]*(qth[i]:-((u:-qval[i]):<=0)) - (u:+(qval[i]*v)) ) :/  (us1 * nobs)
			
		}	
		
		// Xi and Omg
		
		xi2=( iqxx    , J(k,k+qs,0)      )  \ ///
			( J(k,k,0), iqxx , J(k,qs,0) )  \ ///
			J(qs,1,1)#iqxx , qval'#iqxx , I(qs) # (gama)  

		real matrix xvar_uhat, omg_x
		xvar_uhat = xvar:*u_hat
		omg_x     =(xvar_uhat:*u,xvar_uhat:*v,u_hat:*w):*wgt
		omg       =quadcross(omg_x,omg_x)	

		betaq=beta', gama'
		for(i=1;i<=qs;i++) {
			betaq=betaq,(beta+gama*qval[i])'
		}
		if (dfadj!="") {
			nn=nobs-(k-diag0cnt(qxx))
		}
		else {
			nn=nobs
		}
		//n=(nobs-(k-diag0cnt(qxx)))
		vcvq = xi2*omg*xi2'*(nobs/nn)

		st_matrix("__bq",betaq)
		st_matrix("__vq",makesymmetric(vcvq) )	
		st_numscalar("df_r", nn)
		//}		 
}

void mmqreg_vce1c(string scalar yvar_, string scalar xvar_,	
				 string scalar beta_,  string scalar gama_,
				 string scalar qval_,  string scalar qth_, 
				 string scalar fden_, string scalar cvar_,  
				 string scalar touse,  string scalar dfadj, string scalar wgt_) {
		real matrix xvar, yvar, wgt
		real vector beta, gama , betaq
		real vector qval, qth, fden, cvar
		real matrix u_hat, u, v, w  
		real matrix qxx, iqxx, xi, xi2, omg 
		real scalar us1,    nobs, i, qs, k ,nn
		real matrix vcvq
		
		st_view(xvar =.,.,xvar_ ,touse)
		st_view(yvar =.,.,yvar_ ,touse)
		st_view(cvar =.,.,cvar_ ,touse)
		wgt = st_data(.,wgt_  ,touse)
		wgt=wgt:/mean(wgt)		//wgt=wgt:/mean(wgt)
		// first load data
		
		beta=st_matrix(beta_)'
		gama=st_matrix(gama_)'
		// N obs k rows
		nobs=rows(xvar)
		k=cols(xvar)
		// fden qth qval
		qval=st_matrix(qval_)
		qth =st_matrix(qth_)
		fden=st_matrix(fden_)
		qs=cols(qth)
		// std residuals : residuals and fitted values will be obtained with reghdfe		
		// Change this to abs
		u_hat=abs(xvar*gama)
		u    = (yvar-xvar*beta):/u_hat
		v    = 2*u:*((u:>=0):-mean(u:>=0,wgt)):-1
		
		// other elements common 
		// elements that do not depend on w
		 qxx = quadcross(xvar,wgt,xvar)
	    iqxx = invsym(qxx)
		
		// E(U_s) E(U_s^2)
		us1 = mean(u_hat,wgt)
		
		// Betas and VCOV for first and second
		// This residual changes by quantile
		
		w=J(nobs,qs,0)
		
 		for(i=1;i<=qs;i++) {
			
			w[.,i]= ( 1/fden[i]*(qth[i]:-((u:-qval[i]):<=0)) - (u:+(qval[i]*v)) ) :/  (us1 * nobs)
			
		}	
		
		// Xi and Omg
		
		xi2=( iqxx    , J(k,k+qs,0)      )  \ ///
			( J(k,k,0), iqxx , J(k,qs,0) )  \ ///
			J(qs,1,1)#iqxx , qval'#iqxx , I(qs) # (gama)  

		real matrix xvar_uhat, omg_x, omg_xx
		xvar_uhat = xvar:*u_hat
		omg_x     =(xvar_uhat:*u,xvar_uhat:*v,u_hat:*w):*wgt
		
		real matrix info 
		real scalar nc 
	    
		info = panelsetup(cvar, 1)
		nc   = rows(info)
		omg_xx 	  =panelsum(omg_x,info)
		 
        omg  =cross(omg_xx,omg_xx)
			
        real scalar ncone
		ncone=0
		betaq=beta', gama'
		for(i=1;i<=qs;i++) {
			betaq=betaq,(beta+gama*qval[i])'
		}
 
		if (dfadj!="") {
			nn=nobs-(k-diag0cnt(qxx))
			ncone=1
		}
		else {
			nn=nobs-1
		}
		
		//n=(nobs-(k-diag0cnt(qxx)))
		vcvq = xi2*omg*xi2'*(nobs-1)/nn*(nc/(nc-ncone))
 
		st_matrix("__bq",betaq)
		st_matrix("__vq",makesymmetric(vcvq) )	
		st_numscalar("df_r", nn)
		//}		 
}
/// this will be another "hidden" option that will try to obtained clustered standard errors.
 
// This is for the basic no FE noRobust
void mmqreg_vce1(string scalar yvar_, string scalar xvar_,	
				 string scalar beta_,  string scalar gama_,
				 string scalar qval_,  string scalar qth_, 
				 string scalar fden_,  string scalar touse,  
				 string scalar dfadj, string scalar wgt_ ) {
		real matrix xvar, yvar, wgt
		real vector beta, gama , betaq
		real vector qval, qth, fden
		real matrix u_hat, u, v, w,  euv, euw , evw, ew2
		real matrix px, pxx , qxx, iqxx, xi, xi2, omg 
		real scalar us1, us2, nn,nobs , i, qs, k, eu2, ev2
		real matrix vcvq
		
		// first load data
		st_view(xvar=.,.,xvar_,touse)
		st_view(yvar=.,.,yvar_,touse)
		wgt =st_data( ., wgt_,touse)
		wgt = wgt:/mean(wgt)
		//wgt=wgt:/mean(wgt)
		beta=st_matrix(beta_)'
		gama=st_matrix(gama_)'
		// N obs k rows
		nobs=rows(xvar)
		k   =cols(xvar)
		// fden qth qval
		qval=st_matrix(qval_)
		qth =st_matrix(qth_)
		fden=st_matrix(fden_)
		qs=cols(qth)
		// std residuals : residuals and fitted values will be obtained with reghdfe		
		
		// Residuals
		// Change this to abs
		u_hat=abs(xvar*gama)
		// Std Residual First regression   y = xb + u * sigma
		u    =(yvar-xvar*beta):/(u_hat)
		// Std Residual Second regression  abs(u * sigma) = xg + RR 
		// Std Residual Second regression  abs(u * sigma) - xg = RR    || 1/xg
		// This just makes a change from Abs(X) = 2*X(...)
		// Std Residual Second regression  abs(u * sigma)/xg - 1 = V
		v    = 2*u:*((u:>=0):-mean(u:>=0,wgt)):-1
		
	    // The idea here is S2=i(X'X) (X * e^2 * X )    i(X'X)
		// The idea here is S2=i(X'X) * (X * ( u * sigma )^2 * X ) *  i(X'X)
		// The idea here is S2= E(u^2) * i(X'X) * (X * (sigma )^2 * X ) *  i(X'X)
		// other elements common 
		eu2=mean(u:^2,wgt)
		ev2=mean(v:^2,wgt)
		euv=mean(u:*v,wgt)
		// elements that do not depend on w
		
		qxx   = quadcross(xvar,wgt,xvar)
		iqxx  = invsym(qxx)	
		pxx   = quadcross(xvar,wgt:*(u_hat:^2),xvar)
		px    = quadcross(xvar,wgt:*u_hat:^2)
	
		// E(U_s) E(U_s^2)
		us1 = mean(u_hat,wgt)
		us2 = quadcross(u_hat,wgt,u_hat)
		
		w=J(nobs,qs,0)

		for(i=1;i<=qs;i++) {
			w[.,i]=(1/fden[i]*(qth[i]:-((u:-qval[i]):<=0))-(u:+(qval[i]*(v)))):/(us1*nobs)
		}	
		
		euw=mean(u:*w,wgt)
		evw=mean(v:*w,wgt)
		ew2=cross(w,wgt,w)/nobs
		 
		
		// Xi and Omg
		//xi=J(qs,1,1)#iqxx,qval'#iqxx,I(qs)#(gama)  
		xi2=( iqxx    , J(k,k+qs,0)      )  \ ///
			( J(k,k,0), iqxx , J(k,qs,0) )  \ ///
			J(qs,1,1)#iqxx,qval'#iqxx,I(qs)#(gama)
			
 		omg=(eu2*pxx , euv*pxx  , euw#px \  ///
             euv*pxx , ev2*pxx  , evw#px \   ///  
	        (euw#px)', (evw#px)', ew2*us2)
 	
		betaq=beta', gama'
		for(i=1;i<=qs;i++) {
			betaq=betaq,(beta+gama*qval[i])'
		}
 		if (dfadj!="") {
			nn=nobs-(k-diag0cnt(qxx))			   
		}
		else {
			nn=nobs
		}
		vcvq = xi2*omg*xi2'*nobs/nn
		
		st_matrix("__bq",betaq)
		st_matrix("__vq",makesymmetric(vcvq) )	
		st_numscalar("df_r", nn)
}
 
void mmqreg_vce2(string scalar yvar_, string scalar xvar_,	
				  string scalar u_   , string scalar u_hat_, 
				  string scalar beta_,  string scalar gama_,
				  string scalar qval_,  string scalar qth_, 
				  string scalar fden_, real scalar df_a, 
				  string scalar touse,  string scalar dfadj ,  string scalar wgt_ ) {
		real matrix xvar, yvar, wgt
		real vector beta, gama , betaq
		real vector qval, qth, fden
		real matrix u_hat, u, v, w,  euv, euw , evw, ew2
		real matrix px, pxx , qxx, iqxx, xi, xi2, omg 
		real scalar us1, us2, nn, nobs , i, qs, k, eu2, ev2
		real matrix vcvq
				
		// first load data. y may not be needed
		st_view(xvar=. ,.,xvar_ ,touse)
		st_view(yvar=. ,.,yvar_ ,touse)
 		st_view(u=.    ,.,u_    ,touse)
		st_view(u_hat=.,.,u_hat_,touse)
		// Change this to abs
		u_hat=abs(u_hat)
		
		wgt = st_data(.,wgt_  ,touse)
		wgt=wgt:/mean(wgt)
		
		beta=st_matrix(beta_)'
		gama=st_matrix(gama_)'
		// N obs k rows
		nobs=rows(xvar)
		k=cols(xvar)
		// fden qth qval
		qval=st_matrix(qval_)
		qth =st_matrix(qth_)
		fden=st_matrix(fden_)
	
		qs=cols(qth)
		// std residuals : residuals and fitted values will be obtained with reghdfe		
		
		v=2*u:*((u:>=0):-mean(u:>=0,wgt)):-1
		
		// other elements common 
		eu2=mean(u:^2,wgt)
		ev2=mean(v:^2,wgt)
		euv=mean(u:*v,wgt)
		// elements that do not depend on w
		qxx=quadcross(xvar,wgt,xvar)
		
	   iqxx=invsym(qxx)
	   
		//pxx=quadcross(xvar,wgt,u_hat:^2,xvar)/nobs
		//px =quadcross(xvar,wgt,u_hat:^2)/nobs

		pxx=quadcross(xvar,wgt:*(u_hat:^2),xvar)
		px =quadcross(xvar,wgt:*(u_hat:^2))
		
		// E(U_s) E(U_s^2)
		us1=mean(u_hat,wgt)
		us2=quadcross(u_hat:^2,wgt)
		
		// Betas and VCOV for first and second
		//vcvb=eu2*iqxx*pxx*iqxx/rows(x)
		//vcvg=ev2*iqxx*pxx*iqxx/rows(x)
		// This residual changes by quantile
		w=J(nobs,qs,0)

		for(i=1;i<=qs;i++) {
			w[.,i]=(1/fden[i]*(qth[i]:-((u:-qval[i]):<=0))-(u:+(qval[i]*v))):/(us1*nobs)
		}	
		
		euw=mean(u:*w,wgt)
		evw=mean(v:*w,wgt)
		ew2=cross(w,wgt,w)/nobs
		
		// Xi and Omg
		// xi=J(qs,1,1)#iqxx,qval'#iqxx,I(qs)#( gama)  
		xi2=( iqxx    , J(k,k+qs,0)      )  \ ///
			( J(k,k,0), iqxx , J(k,qs,0) )  \ ///
			J(qs,1,1)#iqxx,qval'#iqxx,I(qs)#( gama) 
		
		omg=(eu2*pxx , euv*pxx  , euw#px \  ///
             euv*pxx , ev2*pxx  , evw#px \   ///  
	        (euw#px)', (evw#px)', ew2*us2)
 	
		// create all 
		betaq=beta', gama'
		for(i=1;i<=qs;i++) {
			betaq=betaq,(beta+gama*qval[i])'
		}
 	
		if (dfadj!="") {
			nn=(nobs-(k-diag0cnt(qxx)+df_a-1))
		}
		else {
			nn=nobs
		}
 
		vcvq = xi2*omg*xi2'*nobs/nn
			//bq="b"+strofreal(i)
			//vq="v"+strofreal(i)
		st_matrix("__bq",betaq)
		st_matrix("__vq",makesymmetric(vcvq) )	
		st_numscalar("df_r", nn)
		//}
}
  
void mmqreg_vce2x(string scalar yvar_, string scalar xvar_,	
				  string scalar u_   , string scalar u_hat_, 
				  string scalar beta_,  string scalar gama_,
				  string scalar qval_,  string scalar qth_, 
				  string scalar fden_, real scalar df_a,
				  string scalar touse,  string scalar dfadj ,  string scalar wgt_ ) {
		real matrix xvar, yvar,wgt
		real vector beta, gama , betaq
		real vector qval, qth, fden
		real matrix u_hat, u, v, w  
		real matrix qxx, iqxx, xi, xi2, omg 
		real scalar us1, nn,nobs, i, qs, k
		real matrix vcvq
		real matrix omgx

		st_view(xvar =.,.,xvar_ ,touse)
		st_view(yvar =.,.,yvar_ ,touse)
 		st_view(u    =.,.,u_  ,touse)
		st_view(u_hat=.,.,u_hat_  ,touse)
		u_hat=abs(u_hat)
		
		wgt = st_data(.,wgt_  ,touse)
		wgt=wgt:/mean(wgt)
		// first load data. y may not be needed
		
		beta=st_matrix(beta_)'
		gama=st_matrix(gama_)'
		// N obs k rows
		nobs=rows(xvar)
		k=cols(xvar)
		// fden qth qval
		qval=st_matrix(qval_)
		qth =st_matrix(qth_)
		fden=st_matrix(fden_)
	
		qs=cols(qth)
		// std residuals : residuals and fitted values will be obtained with reghdfe		
		
		v = 2*u:*((u:>=0):-mean(u:>=0,wgt)):-1

		// elements that do not depend on w
		qxx=quadcross(xvar,wgt,xvar)
	   iqxx=invsym(qxx)
 
		// E(U_s) E(U_s^2)
		us1=mean(u_hat,wgt)

		// Betas and VCOV for first and second
		//vcvb=eu2*iqxx*pxx*iqxx/rows(x)
		//vcvg=ev2*iqxx*pxx*iqxx/rows(x)
		// This residual changes by quantile
		w=J(nobs,qs,0)

		for(i=1;i<=qs;i++) {
			//w[.,i]=1/fden[i]*(qth[i]:-((u:+qval[i]):<=0))-(u:+qth[i])
			w[.,i]=(1/fden[i]*(qth[i]:-((u:-qval[i]):<=0))-(u:+(qval[i]*v))):/(us1*nobs)
		}	
		
		// Xi and Omg
		xi =J(qs,1,1)#iqxx,qval'#iqxx,I(qs)#(gama)  
		xi2=( iqxx    , J(k,k+qs,0)      )  \ ///
			( J(k,k,0), iqxx , J(k,qs,0) )  \ xi 
		real matrix xvar_uhat 
		xvar_uhat = xvar:*u_hat
		omgx=(xvar_uhat:*u,xvar_uhat:*v,u_hat:*w)
 		omg =quadcross(omgx,wgt:^2,omgx)	
		
		// create all 
		betaq=beta', gama'
		for(i=1;i<=qs;i++) {
			betaq=betaq,(beta+gama*qval[i])'
		}
		
		if (dfadj!="") {
			nn=(nobs-(k-diag0cnt(qxx)+df_a-1)) 
		}
		else {
			nn=nobs
		}
		vcvq = xi2*omg*xi2'*nobs/nn

		st_matrix("__bq",betaq)
		st_matrix("__vq",makesymmetric(vcvq) )	
		st_numscalar("df_r", nn)
		//}
}

void mmqreg_vce2c(string scalar yvar_, string scalar xvar_,	
				  string scalar u_   , string scalar u_hat_, 
				  string scalar beta_,  string scalar gama_,
				  string scalar qval_,  string scalar qth_, 
				  string scalar fden_, string scalar cvar_, 
				  real scalar df_a, string scalar touse,  
				  string scalar dfadj ,  string scalar wgt_ ) {
		real matrix xvar, yvar, cvar, wgt
		real vector beta, gama , betaq
		real vector qval, qth, fden
		real matrix u_hat, u, v, w  
		real matrix qxx, iqxx, xi, xi2, omg 
		real scalar us1, nn,nobs, i, qs, k
		real matrix vcvq
		
		st_view(xvar =.,.,xvar_ ,touse)
		st_view(yvar =.,.,yvar_ ,touse)
		st_view(cvar =.,.,cvar_ ,touse)
		st_view(u    =.,.,u_  ,touse)
		st_view(u_hat=.,.,u_hat_  ,touse)
		u_hat=abs(u_hat)
		wgt = st_data(.,wgt_  ,touse)
		wgt=wgt:/mean(wgt)
		
		// first load data. y may not be needed
		
		beta=st_matrix(beta_)'
		gama=st_matrix(gama_)'
		// N obs k rows
		nobs=rows(xvar)
		k=cols(xvar)
		// fden qth qval
		qval=st_matrix(qval_)
		qth =st_matrix(qth_)
		fden=st_matrix(fden_)
	
		qs=cols(qth)
		// std residuals : residuals and fitted values will be obtained with reghdfe		
		
		v=2*u:*((u:>=0):-mean(u:>=0,wgt)):-1

		// elements that do not depend on w
		qxx=quadcross(xvar,wgt,xvar)
		//n=(nobs-(k-diag0cnt(qxx)+df_a-1))
		
	   iqxx=invsym(qxx)
 
		// E(U_s) E(U_s^2)
		us1=mean(u_hat,wgt)
		
		// Betas and VCOV for first and second
		//vcvb=eu2*iqxx*pxx*iqxx/rows(x)
		//vcvg=ev2*iqxx*pxx*iqxx/rows(x)
		// This residual changes by quantile
		w=J(nobs,qs,0)

		for(i=1;i<=qs;i++) {
			//w[.,i]=1/fden[i]*(qth[i]:-((u:+qval[i]):<=0))-(u:+qth[i])
			w[.,i]=(1/fden[i]*(qth[i]:-((u:-qval[i]):<=0))-(u:+(qval[i]*v))):/(us1*nobs)
		}	
		
		// Xi and Omg
		
		xi2=( iqxx    , J(k,k+qs,0)      )  \ ///
			( J(k,k,0), iqxx , J(k,qs,0) )  \ ///
			J(qs,1,1)#iqxx,qval'#iqxx,I(qs)#( gama)
 
		real matrix xvar_uhat, omg_x, omg_xx
		xvar_uhat = xvar:*u_hat
		omg_x     =(xvar_uhat:*u,xvar_uhat:*v,u_hat:*w):*wgt
		
		real matrix info 
		real scalar nc 
	    
		info = panelsetup(cvar, 1)
		nc   = rows(info)
		omg_xx 	  =panelsum(omg_x,info)
		 
        omg  =cross(omg_xx,omg_xx)
		
		// create all 
		betaq=beta', gama'
		for(i=1;i<=qs;i++) {
			betaq=betaq,(beta+gama*qval[i])'
		}
		
		real scalar ncone
		ncone=0
		
		if (dfadj!="") {
			nn=nobs-(k-diag0cnt(qxx)+df_a-1)
			ncone=1
		}
		else {
			nn=nobs-1
		}
		
		vcvq = xi2*omg*xi2'*(nobs-1)/nn*(nc/(nc-ncone))

		st_matrix("__bq",betaq)
		st_matrix("__vq",makesymmetric(vcvq) )	
		st_numscalar("df_r",nn)

}
end

/*
//  Notes for myself 
syntax
mmqreg depvar indepvar, q(any number >0 <100) abs(varlist)

** this is to keep essentials
ms_fvstrip c.mpg##i.foreign, expand dropomit
** creates variables as needed
hdfe c.mpg##i.foreign, abs(abs) gen(__new)
** myhdfe creates and drop some stuff from hdfe
*/
