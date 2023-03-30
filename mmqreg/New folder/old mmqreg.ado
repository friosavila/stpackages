*! v1.01 MMQREG by Fernando Rios-Avila
** Corrects issue with VCOV matrix. Due to numerical precision it may give an error. Now it :forces the symetry using makesymmetric()
** v1.0 MMQREG by Fernando Rios-Avila
** Thanks to Joao Santos Silva for conversations and clarifications about the methodology
** this program is an adaptation of xtqreg that would
** in theory, allow for the estimator when no fixed effects exist,
** and when Multiple fixed effects exist
** While doing this two typos from MM mata paper were found.
** 1 for the estimation of SIGMA model two E(V^2) should be E((V-1)^2)
** 2 W= x1+x2+x3*v but should be x1+x2+x3

capture program drop mynlist
program mynlist,rclass
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

capture program drop mmqreg
program mmqreg, eclass 

 if replay() {
	if "`e(cmd)'"=="mmqreg" {
	   display as text "MM-qreg Estimator"
		if "`absorb'"!="" display as text "Absorbed Variables: " as result "`absorb'"
		ereturn display  
		exit
	}
	else {
	    display in red "Last estimattions not found"
		exit
	}
 }

	syntax varlist(fv) [in] [if] [aw pw iw fw],  /// Standard syntax
								[Absorb(varlist) /// Indicates what to "absorb"
								 Quantile(str)   /// Which quintile to use. may allow for dups
								denopt(str)	x	 /// this will allow alternative definitions of quantiles. default: qreg  qv2: pctile  qv3: interpolation empirical
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
	  else mmqreg2 `0'
	display as text "MM-qreg Estimator"
	if "`absorb'"!="" display as text "Absorbed Variables: " as result "`absorb'"
	ereturn display  
end

capture program drop mmqreg1
program mmqreg1, eclass
	syntax varlist(fv) [in] [if] [aw pw iw fw], [Quantile(str)  denopt(str) x]
	** start with sample checks
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
				_n "Consider using a different model specification"
		qui:replace `ares_hat'=abs(`ares_hat')		
	}
	** generate standardized residuals. Send St_res to Mata
	qui:gen double `st_res'=`res'/`ares_hat'
	tempname qval qth fden	
	** and get the "quantile". Here we obtain all qth qval and fden
	foreach q in `quantile' {	
		*if "`weights'"=="pweight" local wgt iw 
		*else local wgt `weights'
		if "`denopt'"!="" local denopt=",`denopt'"
		qui:qreg `st_res' if `touse' [`wgt'`exp'], q(`q') vce(iid `denopt') 
		local denmethod `e(denmethod)' 
		local bwmethod `e(bwmethod)' 
		matrix `qval'=nullmat(`qval'),`e(q_v)'
		matrix `fden'=nullmat(`fden'),`e(f_r)'
		matrix `qth' =nullmat(`qth') ,`e(q)'
	}
 
	** name of all variables for equation
	local bnm: colnames `sfb'
	** we need a constant.
	tempvar cns
	qui:gen byte `cns'=1
	** this code does all the rest. 
	mata:mmqreg_vce1`x'("`y'","`xvar' `cns'","`lfb'","`sfb'", ///
					 "`qval'","`qth'","`fden'", "`touse'")
	* After the mata code is run, I get vq bq
	* but need extra info. eq name and betas
	* This should capture all EQ names
	local eqnm="location "*colsof(`sfb')+"scale "*colsof(`sfb')
	foreach q in `quantile' {
	    local strq=subinstr("`q'",".","_",.)
		local eqnm="`eqnm'"+"qtile_`strq' "*colsof(`sfb')
	}
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
	ereturn post __bq __vq, esample(`touse') buildfvinfo findomitted 
	ereturn local cmd "mmqreg"
	ereturn local cmd_line "mmqreg `0'"
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
	** need to create the "display " function and also create mmqreg_p. 
	* may not be needed for most Marginal effects
	 
	
end

capture program drop mmqreg2
program mmqreg2, eclass
	syntax varlist(fv) [in] [if] [aw pw iw fw], [Quantile(str) Absorb(varlist) denopt(str) x]
	** start with sample checks
	capture drop _i_* ___zero___
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
	** variable definitions: dependent and independent
	** here I can add the new set of variables
	qui:myhdfe `varlist' if `touse' [`weight'`exp'], abs(`absorb')
	local df_a= `r(df_a)'
    ** name of all variables for equation
	local bnm `r(fullvar)'  
	gettoken gfn bnm:bnm
	local acxvar `r(finvar)'
	qui:gen byte ___zero___=0
	
	tokenize `acxvar'
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
	
	qui:myhdfe `ares' if `touse' [`weight'`exp'], abs(`absorb')
	** estimation of scale 
	tempvar ares_hat st_res
	qui:reg _i_`ares' `xvar' if `touse' [`weight'`exp']
	tempname sfb sfV
	matrix `sfb'=e(b)
	qui:predict double `ares_hat', res
	qui:replace `ares_hat'=`ares'-`ares_hat'
	qui:sum `ares_hat' if `touse'
	** if scale is negative, Stop
	if `r(min)'<=0 {
	    display in red "WARNING: some fitted values of the scale function are negative" ///
				_n "Consider using a different model specification"
		qui:replace `ares_hat'=abs(`ares_hat')		
	}
	** generate standardized residuals. Send St_res to Mata
	qui:gen double `st_res'=`res'/`ares_hat'
	tempname qval qth fden	
	** and get the "quantile". Here we obtain all qth qval and fden
	foreach q in `quantile' {	
		*if "`weights'"=="pweight" local wgt iw 
		*else local wgt `weights'
		if "`denopt'"!="" local denopt=",`denopt'"
		qui:qreg `st_res' if `touse' [`wgt'`exp'], q(`q') vce(iid `denopt') 
		local denmethod `e(denmethod)' 
		local bwmethod `e(bwmethod)' 
		matrix `qval'=nullmat(`qval'),`e(q_v)'
		matrix `fden'=nullmat(`fden'),`e(f_r)'
		matrix `qth' =nullmat(`qth') ,`e(q)'
	}

	** we need a constant.
	tempvar cns
	qui:gen byte `cns'=1
	** this code does all the rest. 
 
	mata:mmqreg_vce2`x'("`y'","`xvar' `cns'","`st_res'","`ares_hat'","`lfb'","`sfb'", ///
					 "`qval'","`qth'","`fden'", `df_a', "`touse'")
	* After the mata code is run, I get vq bq
	* but need extra info. eq name and betas
	* This should capture all EQ names
	local eqnm="location "*colsof(`sfb')+"scale "*colsof(`sfb')
	foreach q in `quantile' {
	    local strq=subinstr("`q'",".","_",.)
		local eqnm="`eqnm'"+"qtile_`strq' "*colsof(`sfb')
	}
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
	ereturn post __bq __vq, esample(`touse') buildfvinfo findomitted 
	ereturn local cmd "mmqreg"
	ereturn local cmd_line "mmqreg `0'"
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
	** need to create the "display " function and also create mmqreg_p. 
	* may not be needed for most Marginal effects

	drop _i_* ___zero___
end

**** This program creates the demean recentered statistics.
capture program drop myhdfe
program myhdfe, rclass
syntax varlist(fv) [if] [in] [aw], abs(varlist)
* step 1. Get list of variables
	marksample touse
	ms_fvstrip `varlist' if `touse', expand dropomit
	local fullxv  `r(fullvarlist)'
	local parxv   `r(varlist)'
	hdfe `varlist' if `touse' [`weight'`exp'], abs(`abs') gen(_i_) keepsingletons 
	local df_a `e(df_a)'
	local actxv   `r(varlist)'
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
			sum _i_`3' if `touse', meanonly
			if r(max)<epsfloat() {
				qui:replace _i_`3'=0
			}
			else {
			    sum `1' if `touse', meanonly
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
mata clear
void mmqreg_vce1x(string scalar yvar_, string scalar xvar_,	
				 string scalar beta_,  string scalar gama_,
				 string scalar qval_,  string scalar qth_, 
				 string scalar fden_,  string scalar touse) {
real matrix xvar, yvar
		real vector beta, gama , betaq
		real vector qval, qth, fden
		real matrix u_hat, u, v, w  
		real matrix qxx, iqxx, xi, xi2, omg 
		real scalar us1,  n, nobs, i, qs, k 
		real matrix vcvq
		
		xvar =st_data(.,xvar_ ,touse)
		yvar =st_data(.,yvar_ ,touse)
		
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
		u=(yvar-xvar*beta):/(xvar*gama)
		v=2*u:*((u:>=0):-mean(u:>=0)):-1
		u_hat=xvar*gama
	
		// other elements common 

		// elements that do not depend on w
		qxx=cross(xvar,xvar)
		n=(nobs-(k-diag0cnt(qxx)))
	   iqxx=invsym(qxx/n)
		
		// E(U_s) E(U_s^2)
		us1=mean(u_hat)
		
		// Betas and VCOV for first and second
		//vcvb=eu2*iqxx*pxx*iqxx/rows(x)
		//vcvg=ev2*iqxx*pxx*iqxx/rows(x)
		// This residual changes by quantile
		w=J(nobs,qs,0)
 		for(i=1;i<=qs;i++) {
			w[.,i]=1/fden[i]*(qth[i]:-((u:+qval[i]):<=0))-(u:+qth[i])
		}	
		
		// Xi and Omg
		xi=J(qs,1,1)#iqxx,qval'#iqxx,I(qs)#(1/us1*gama)  
		xi2=( iqxx    , J(k,k+qs,0)      )  \ ///
			( J(k,k,0), iqxx , J(k,qs,0) )  \ xi 
		//xi =( iqxx    , qval[1]*iqxx , 1/us1*gama, J(k,1,0) ) \ ///
		//		( iqxx    , qval[2]*iqxx , J(k,1,0), 1/us1*gama)

 		omg = quadcross((xvar:*u_hat:*u,xvar:*u_hat:*v,u_hat:*w),(xvar:*u_hat:*u,xvar:*u_hat:*v,u_hat:*w))/n	

		//omg=( eu2*pxx  , euv*pxx  , euw1*px   , euw2*px \  ///
		//	  euv*pxx  , ev2*pxx  , evw1*px   , evw2*px \  ///  
		//	  px'*euw1 , px'*evw1 , ew1_2*us2 , ew1w2*us2 \  ///  
		//	  px'*euw2 , px'*evw2 , ew1w2*us2 , ew2_2*us2 )
		// create all 
		betaq=beta', gama'
		for(i=1;i<=qs;i++) {
			betaq=betaq,(beta+gama*qval[i])'
		}
 	
		vcvq = xi2*omg*xi2'/n
			//bq="b"+strofreal(i)
			//vq="v"+strofreal(i)
		st_matrix("__bq",betaq)
		st_matrix("__vq",makesymmetric(vcvq) )	
		//}		 
}

void mmqreg_vce1(string scalar yvar_, string scalar xvar_,	
				 string scalar beta_,  string scalar gama_,
				 string scalar qval_,  string scalar qth_, 
				 string scalar fden_,  string scalar touse) {
		real matrix xvar, yvar
		real vector beta, gama , betaq
		real vector qval, qth, fden
		real matrix u_hat, u, v, w,  euv, euw , evw, ew2
		real matrix px, pxx , qxx, iqxx, xi, xi2, omg 
		real scalar us1, us2, n,nobs , i, qs, k, eu2, ev2
		real matrix vcvq
		xvar=1
		yvar=1
		// first load data
		st_view(xvar,.,xvar_,touse)
		st_view(yvar,.,yvar_,touse)
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
		u=(yvar-xvar*beta):/(xvar*gama)
		v=2*u:*((u:>=0):-mean(u:>=0)):-1
		u_hat=xvar*gama
	
		// other elements common 
		eu2=mean(u:^2)
		ev2=mean(v:^2)
		euv=mean(u:*v)
		// elements that do not depend on w
		qxx=cross(xvar,xvar)
		n=(nobs-(k-diag0cnt(qxx)))
	   iqxx=invsym(qxx/n)
	   
		pxx=cross(xvar,u_hat:^2,xvar)/n
		px =cross(xvar,u_hat:^2)/n
	
		// E(U_s) E(U_s^2)
		us1=mean(u_hat)
		us2=mean(u_hat:^2)
		
		// Betas and VCOV for first and second
		//vcvb=eu2*iqxx*pxx*iqxx/rows(x)
		//vcvg=ev2*iqxx*pxx*iqxx/rows(x)
		// This residual changes by quantile
		w=J(nobs,qs,0)

		for(i=1;i<=qs;i++) {
			w[.,i]=1/fden[i]*(qth[i]:-((u:+qval[i]):<=0))-(u:+qth[i])
		}	
		
		euw=cross(u,w)/n
		evw=cross(v,w)/n
		ew2=cross(w,w)/n
		
		// Xi and Omg
		xi=J(qs,1,1)#iqxx,qval'#iqxx,I(qs)#(1/us1*gama)  
		xi2=( iqxx    , J(k,k+qs,0)      )  \ ///
			( J(k,k,0), iqxx , J(k,qs,0) )  \ xi 
		//xi =( iqxx    , qval[1]*iqxx , 1/us1*gama, J(k,1,0) ) \ ///
		//		( iqxx    , qval[2]*iqxx , J(k,1,0), 1/us1*gama)
 
		omg=(eu2*pxx, euv*pxx , euw#px \  ///
             euv*pxx, ev2*pxx , evw#px \   ///  
	        (euw#px)', (evw#px)', us2*ew2)
 	
		//omg=( eu2*pxx  , euv*pxx  , euw1*px   , euw2*px \  ///
		//	  euv*pxx  , ev2*pxx  , evw1*px   , evw2*px \  ///  
		//	  px'*euw1 , px'*evw1 , ew1_2*us2 , ew1w2*us2 \  ///  
		//	  px'*euw2 , px'*evw2 , ew1w2*us2 , ew2_2*us2 )
		// create all 
		betaq=beta', gama'
		for(i=1;i<=qs;i++) {
			betaq=betaq,(beta+gama*qval[i])'
		}
 	
		vcvq = xi2*omg*xi2'/n
			//bq="b"+strofreal(i)
			//vq="v"+strofreal(i)
		st_matrix("__bq",betaq)
		st_matrix("__vq",makesymmetric(vcvq) )	
		//}
}
 
void mmqreg_vce2(string scalar yvar_, string scalar xvar_,	
				  string scalar u_   , string scalar u_hat_, 
				  string scalar beta_,  string scalar gama_,
				  string scalar qval_,  string scalar qth_, 
				  string scalar fden_, real scalar df_a, string scalar touse) {
		real matrix xvar, yvar
		real vector beta, gama , betaq
		real vector qval, qth, fden
		real matrix u_hat, u, v, w,  euv, euw , evw, ew2
		real matrix px, pxx , qxx, iqxx, xi, xi2, omg 
		real scalar us1, us2, n, nobs , i, qs, k, eu2, ev2
		real matrix vcvq
		xvar=1
		yvar=1
		u=1
		u_hat=1
		
		// first load data. y may not be needed
		st_view(xvar ,.,xvar_ ,touse)
		st_view(yvar ,.,yvar_ ,touse)
		st_view(u    ,.,u_    ,touse)
		st_view(u_hat,.,u_hat_,touse)
		
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
		
		v=2*u:*((u:>=0):-mean(u:>=0)):-1
		
		// other elements common 
		eu2=mean(u:^2)
		ev2=mean(v:^2)
		euv=mean(u:*v)
		// elements that do not depend on w
		qxx=cross(xvar,xvar)
		n=(nobs-(k-diag0cnt(qxx)+df_a-1))
	   iqxx=invsym(qxx/n)
	   
		pxx=cross(xvar,u_hat:^2,xvar)/n
		px =cross(xvar,u_hat:^2)/n
	
		// E(U_s) E(U_s^2)
		us1=mean(u_hat)
		us2=mean(u_hat:^2)
		
		// Betas and VCOV for first and second
		//vcvb=eu2*iqxx*pxx*iqxx/rows(x)
		//vcvg=ev2*iqxx*pxx*iqxx/rows(x)
		// This residual changes by quantile
		w=J(nobs,qs,0)

		for(i=1;i<=qs;i++) {
			w[.,i]=1/fden[i]*(qth[i]:-((u:+qval[i]):<=0))-(u:+qth[i])
		}	
		
		euw=cross(u,w)/n
		evw=cross(v,w)/n
		ew2=cross(w,w)/n
		
		// Xi and Omg
		xi=J(qs,1,1)#iqxx,qval'#iqxx,I(qs)#(1/us1*gama)  
		xi2=( iqxx    , J(k,k+qs,0)      )  \ ///
			( J(k,k,0), iqxx , J(k,qs,0) )  \ xi 
		//xi =( iqxx    , qval[1]*iqxx , 1/us1*gama, J(k,1,0) ) \ ///
		//		( iqxx    , qval[2]*iqxx , J(k,1,0), 1/us1*gama)
 
		omg=(eu2*pxx, euv*pxx , euw#px \  ///
             euv*pxx, ev2*pxx , evw#px \   ///  
	        (euw#px)', (evw#px)', us2*ew2)
 	
		// create all 
		betaq=beta', gama'
		for(i=1;i<=qs;i++) {
			betaq=betaq,(beta+gama*qval[i])'
		}
 	
		vcvq = xi2*omg*xi2'/n
			//bq="b"+strofreal(i)
			//vq="v"+strofreal(i)
		st_matrix("__bq",betaq)
		st_matrix("__vq",makesymmetric(vcvq) )	
		//}
}
  
void mmqreg_vce2x(string scalar yvar_, string scalar xvar_,	
				  string scalar u_   , string scalar u_hat_, 
				  string scalar beta_,  string scalar gama_,
				  string scalar qval_,  string scalar qth_, 
				  string scalar fden_, real scalar df_a, string scalar touse) {
		real matrix xvar, yvar
		real vector beta, gama , betaq
		real vector qval, qth, fden
		real matrix u_hat, u, v, w  
		real matrix qxx, iqxx, xi, xi2, omg 
		real scalar us1, n,nobs, i, qs, k
		real matrix vcvq
		
		xvar =st_data(.,xvar_ ,touse)
		yvar =st_data(.,yvar_ ,touse)
		u    =st_data(.,u_    ,touse)
		u_hat=st_data(.,u_hat_,touse)
		
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
		
		v=2*u:*((u:>=0):-mean(u:>=0)):-1

		// elements that do not depend on w
		qxx=cross(xvar,xvar)
		n=(nobs-(k-diag0cnt(qxx)+df_a-1))
		
	   iqxx=invsym(qxx/n)
 
		// E(U_s) E(U_s^2)
		us1=mean(u_hat)
		
		// Betas and VCOV for first and second
		//vcvb=eu2*iqxx*pxx*iqxx/rows(x)
		//vcvg=ev2*iqxx*pxx*iqxx/rows(x)
		// This residual changes by quantile
		w=J(nobs,qs,0)

		for(i=1;i<=qs;i++) {
			w[.,i]=1/fden[i]*(qth[i]:-((u:+qval[i]):<=0))-(u:+qth[i])
		}	
		
		// Xi and Omg
		xi=J(qs,1,1)#iqxx,qval'#iqxx,I(qs)#(1/us1*gama)  
		xi2=( iqxx    , J(k,k+qs,0)      )  \ ///
			( J(k,k,0), iqxx , J(k,qs,0) )  \ xi 
		//xi =( iqxx    , qval[1]*iqxx , 1/us1*gama, J(k,1,0) ) \ ///
		//		( iqxx    , qval[2]*iqxx , J(k,1,0), 1/us1*gama)
		omg = cross((xvar:*u_hat:*u,xvar:*u_hat:*v,u_hat:*w),(xvar:*u_hat:*u,xvar:*u_hat:*v,u_hat:*w))/n	
 
		// create all 
		betaq=beta', gama'
		for(i=1;i<=qs;i++) {
			betaq=betaq,(beta+gama*qval[i])'
		}
		vcvq = xi2*omg*xi2'/n
			//bq="b"+strofreal(i)
			//vq="v"+strofreal(i)
		st_matrix("__bq",betaq)
		st_matrix("__vq",makesymmetric(vcvq) )	
		//}
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
