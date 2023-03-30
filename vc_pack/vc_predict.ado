** This version implements the Loops In MATA!!
** will try to estimate it with local mata matrix
mata:mata clear
capture program drop vc_predict
program vc_predict, rclass  sortpreserve
syntax varlist(numeric fv) [if] [in], [vcoeff(varname) bw(real -1) yhat(str) looe(str) res(str) lvrg(str) nobs(str) ///
					knots(real -1) km(real 1) vcoeff_par(varname) sample(varname)  kernel(str) stest nstat ]
 
	tokenize `varlist'
	local y `1'
	//get the rest of the vars
	macro shift
	local varx `*'

	* confirming IF the variables exist
    **
	foreach i in `yhat' `looe' `res' `lvr'  `nobs' {
		confirm new var `i'
	}
	** Defines Sample, Works with and in addition to IF
	marksample touse
	markout `touse' `sample' `varlist' `vcoeff' 
*	sort `touse'
	*********************************************
	** checking if vcoeff was defined or using "system"
	if "`vcoeff'"=="" & "$vcoeff_"=="" {
	   display "Need to define vcoeff. variable for varying coefficients"
	   exit
	}
	*** this uses system
	
	if "`vcoeff'"=="" & "$vcoeff_"!="" {
		local vcoeff $vcoeff_
    }
	local full_x `vcoeff'

    ** Defining the running variable. Or the Bins
	if `knots'>=0 {
		tempvar _kn
		qui:egen `_kn'=vbin(`vcoeff') if `touse', knot(`knots') km(`km')
		local par_x `_kn'
	}
	else {
		if "`vcoeff_par'"=="" {
		local par_x `vcoeff'
		}
		else {
		local par_x `vcoeff_par'
		}
	}
	
    ** For future applications that will incorporate Sampling Weights
	local sweight  1
	if "`weight'"!="" {
	local sweight  `weight'
	}

    ** Uses Kernel Saved in memory
	if "$kernel_"!="" & "`kernel'"=="" {
		local kernel "$kernel_"
	}
	if  "$kernel_"=="" & "`kernel'"=="" {
		local kernel gaussian
	}
	** as well as BW
	if "$opbw_"!="" & `bw'==-1 {
		local bw $opbw_
	}
		
	** 	tempvar err lvr
	** Here is where I will modify the data
	** First order it by parx and touse, and create a touse2
	tempvar touse2
	qui:replace `touse'=. if `touse'==0
	qui:bysort  `touse' `par_x':gen byte `touse2'=(_n==1)*(`touse'==1)
	qui:replace `touse'=0 if `touse'==.
	
	** for now we are assuming there are no collinearity problems	
	local fvarx=	"`full_x' `varx' c.`full_x'#c.(`varx')"
	** need to learn to put them as locals rather than globals
	tempvar Nobs looerr lev xb
	/*
	mata:y  = st_data(., "`y'","`touse'")
	mata:x  = st_data(., "`fvarx'","`touse'")
	mata:x  = x,J(rows(x),1,1)
	mata:fvc= st_data(., "`full_x'","`touse'")
	mata:pvc= st_data(., "`par_x'","`touse'")
	mata:vc = st_data(., "`par_x'","`touse2'")
	mata:bw = `bw'
	mata:krn= "`kernel'"
	** This does regression*/
	
	mata:cvreg2("`y'","`fvarx'","`full_x'","`par_x'","`touse'","`touse2'", ///
					`bw',"`kernel'","`looerr'","`lev'","`xb'","`Nobs'") 
 	
	
	** Final results
	/*this is where the code for within regressions will go*/
	*qui:mata:cvreg2("`looerr'","`lev'","`xb'","`Nobs'") 
    if "`nstat'"=="" {
		tempvar ssx
		qui:gen double `ssx'=(`y'-`xb')^2
		qui: sum `ssx' if `touse'==1  [aw=`sweight'],meanonly
		local ssr=r(sum)
		qui: sum `y' if `touse'==1  [aw=`sweight'],meanonly
		local mmn=r(mean)
		qui: replace `ssx'=(`y'-r(mean))^2
		qui: sum `ssx' if `touse'==1  [aw=`sweight'], meanonly
		local sst=r(sum)
		local r2a=1-`ssr'/`sst'
		*** r2b Henderson Parmeter 2015
		qui:replace `ssx'=(`y'-`mmn')*(`xb'-`mmn') if `touse'
		qui:sum `ssx' if `touse'==1  [aw=`sweight'], meanonly
		local r2n=r(sum)^2
		qui:replace `ssx'=(`xb'-`mmn')^2 if `touse'
		qui:sum `ssx' if `touse'==1  [aw=`sweight'], meanonly
		local sse=r(sum)
		local r2b=r(sum)^2/(`sst'*`sse')
		tempvar looerrcv
		qui:gen double `looerrcv'=`looerr'^2
		qui:sum `looerrcv' if `touse'==1  [aw=`sweight'], meanonly
		local cvv=log(r(mean))
		qui: sum `lev' if `touse'==1  [aw=`sweight'], meanonly
		** This is basically tr(S). We wil use HT1990 and use the approximation for tr(2S-S'S)
		local dof=1.25*r(sum)-0.5
		local dof2=`r(N)'-`dof'
		local dofm=r(sum)
		*** To display R2 of Model
		display as text "Smooth Varying coefficients model"
		display as text "Dep variable       : " as result "`y'"
		display as text "Indep variables    : " as result "`varx'" 
		display as text "Smoothing variable : " as result "`vcoeff'" 
		display as text "Kernel             : " as result "`kernel'" 
		if `knots'!=-2 & `knots'!=-1 {
		display as text "Bin specification  : " as result "knots(`knots') km(`km')"
		}
		display as text "Bandwidth          : " as result  %10.5f `bw'
		display as text "Log MSLOOER        : " as result  %10.5f `cvv'
		display as text "Dof residual       : " as result  %10.3f `dof2'
		display as text "Dof model          : " as result  %10.3f `dofm'
		display as text "SSR                : " as result  %10.3f `ssr' 
		display as text "SSE                : " as result  %10.3f `sse'
		display as text "SST                : " as result  %10.3f `sst'
		display as text "R2-1 1-SSR/SST     : " as result  %10.5f  `r2a'
		display as text "R2-2               : " as result  %10.5f  `r2b'
		qui:sum `Nobs' if `touse'
		local ekobs=r(mean)
		display as text "E(Kernel obs)      : " as result %10.3f `ekobs'
		
		*This only runs if nstat==""
		if "`stest'"!="" {
			display  _n
			display as text "Specification Test approximate F-statistic"
			display as text "H0: Parametric Model"
			display as text "H1: SVCM y=x*b(z)+e"
			
			display as text "Alternative parametric models:" 
			qui:reg `y' `varx' `full_x' [iw=`sweight'] if `touse'==1
			local N=e(N)
			local sm1= e(rss)
			local df1=e(df_m)
			local F1_stat=(`sm1'-`ssr')/`ssr'*((`N'-`dof')/(`dof'-`df1'))
			qui:reg `y' `varx' c.`full_x' c.(`varx')#c.`full_x'  [iw=`sweight'] if `touse'==1
			local sm2= e(rss)
			local df2=e(df_m)
			local F2_stat=(`sm2'-`ssr')/`ssr'*((`N'-`dof')/(`dof'-`df2'))
			qui:reg `y' `varx' c.`full_x'##c.`full_x' c.(`varx')#(c.`full_x'##c.`full_x')  [iw=`sweight'] if `touse'==1
			local sm3= e(rss)
			local df3=e(df_m)
			local F3_stat=(`sm3'-`ssr')/`ssr'*((`N'-`dof')/(`dof'-`df3'))
			qui:reg `y' `varx' c.`full_x'##c.`full_x'##c.`full_x' c.(`varx')#(c.`full_x'##c.`full_x'##c.`full_x')  [iw=`sweight'] if `touse'==1
			local sm4= e(rss)
			local df4=e(df_m)
			local F4_stat=(`sm4'-`ssr')/`ssr'*((`N'-`dof')/(`dof'-`df4'))
			display as text "Model 0 y=x*b0+g*z+e"
			display as result  "F-Stat: " %7.5f `F1_stat' " with pval " %6.5f Ftail(`dof'-`df1',`N'-`dof',`F1_stat')
			display as text "Model 1 y=x*b0+g*z+(z*x)b1+e"
			display as result  "F-Stat: " %7.5f `F2_stat' " with pval " %6.5f Ftail(`dof'-`df2',`N'-`dof',`F2_stat') 
			display as text "Model 2 y=x*b0+g*z+(z*x)*b1+(z^2*x)*b2+e"
			display as result  "F-Stat: " %7.5f `F3_stat' " with pval " %6.5f Ftail(`dof'-`df3',`N'-`dof',`F3_stat') 
			display as text "Model 3 y=x*b0+g*z+(z*x)*b1+(z^2*x)*b2+(z^3*x)*b3+e"
			display as result  "F-Stat: " %7.5f `F4_stat' " with pval " %6.5f Ftail(`dof'-`df4',`N'-`dof',`F4_stat')
			
			return scalar F1_stat=`F1_stat'
			return scalar pva_F1=Ftail(`dof'-`df1',`N'-`dof',`F1_stat')
			return scalar F2_stat=`F2_stat'
			return scalar pva_F2=Ftail(`dof'-`df2',`N'-`dof',`F2_stat')
			return scalar F3_stat=`F3_stat'
			return scalar pva_F3=Ftail(`dof'-`df3',`N'-`dof',`F3_stat')
			return scalar F4_stat=`F4_stat'
			return scalar pva_F4=Ftail(`dof'-`df4',`N'-`dof',`F4_stat')
		}
		
		return scalar mslooe=`cvv'
		return scalar dof_r=`dof2'
		return scalar dof_m=`dofm'
		return scalar ssr=`ssr'
		return scalar sse=`sse'
		return scalar sst=`sst'
		return scalar r2_1=`r2a'
		return scalar r2_2=`r2b'
 
	}
	*** To display CV. For now lets just GET CV and save it in the other site
*mata:mata drop x y  bw vc fvc pvc krn
if "`yhat'"!="" ren `xb' `yhat'
if "`looe'"!="" ren `looerr' `looe'
if "`lvrg'"!="" ren `lev' `lvrg'
if "`res'"!=""  gen `res'=`y'-`xb'
if "`nobs'"!=""  ren `Nobs' `nobs' 
display "`nobs'"
*** Return section Return all outputs!

end


mata:
void cvreg( string scalar nloerr,string scalar lev,string scalar xbhat) 
{
	external x,y,w
	n    = rows(y)
	ixwx=invsym(quadcross(x,w,x))
	xwy=quadcross(x,w,y)
	wx=sqrt(w):*x
	tr=rowsum(wx*ixwx:*wx)
	tr2=(tr:*-1):+1
	yhat=x*ixwx*xwy
	loerr=(y-yhat):/tr2 
	st_addvar("double",nloerr)
	st_store((1,n),nloerr,loerr)
	st_addvar("double",lev)
	st_store((1,n),lev,tr)
	st_addvar("double",xbhat)
	st_store((1,n),xbhat,yhat)
}
 
 
 
void cvreg2(string scalar depvar, string scalar indepvar, string scalar fcsvar,
		    string scalar pcsvar, string scalar touse   , string scalar touse2, 
			real scalar bw, string scalar krn,
			string scalar nloerr,string scalar nlev,string scalar nyhat, string scalar nobs) 
{
	real matrix y,x ,fvc,pvc,vc
	y=st_data(.,depvar,touse)
	x=st_data(.,indepvar,touse)
	x=x,J(rows(x),1,1)
	fvc= st_data(., fcsvar,touse)
	pvc= st_data(., pcsvar,touse)
	vc = st_data(., pcsvar,touse2)
	
	// external y,x,fvc,bw, pvc, vc
	// external krn
	// which kernel?
 
	if      (krn=="gaussian") k=1
	else if (krn=="epan") k=2
	else if (krn=="epan2") k=3
	else if (krn=="biweight") k=4
	else if (krn=="cosine") k=5
	else if (krn=="cosine2") k=6
	else if (krn=="parzen") k=7
	else if (krn=="rectan") k=8
	else if (krn=="trian") k=9
	else if (krn=="logistic") k=10
	else if (krn=="tricube") k=11
	else if (krn=="triweight") k=12

	n     = rows(y)
	yhat2 =J(rows(y),1,0)	
	loerr2=J(rows(y),1,0)
	lev2  =J(rows(y),1,0)	
	nnobs =J(rows(y),1,0)
	
 	for(i=1;i<=rows(vc);i++) {
	    /// point of reference
 		z=(fvc:-vc[i]):/bw
		
		/// kernel weight
	    w=kweight(z,1)
		/// elements of the OLS
		ixwx=invsym(quadcross(x,w,x))
		xwy=quadcross(x,w,y)
		/// leverage Stat
 		lrv=quadrowsum((x*ixwx):*(x:*w))
		/// This info is to be stored
		yhat=x*(ixwx*xwy)
		loerr=(y-yhat):/((lrv:*-1):+1) 
		lev2 =lev2+lrv:*(pvc:==vc[i])
		yhat2 =yhat2+yhat:*(pvc:==vc[i])
		loerr2=loerr2+loerr:*(pvc:==vc[i])
		nnobs=nnobs+(J(rows(y),1,0):+quadsum(w)):*(pvc:==vc[i])
	}
	
 	st_addvar("double",nloerr)
	st_store(.,nloerr,touse,loerr2)
	st_addvar("double",nlev)
	st_store(.,nlev,touse,lev2)
	st_addvar("double",nyhat)
	st_store(.,nyhat,touse,yhat2)
	st_addvar("double",nobs)
	st_store(.,nobs,touse,nnobs)
	
}

 
real matrix kweight(real matrix z,real scalar k)
{
	if (k==1) {
		kz=normalden(z):/normalden(0)
	}
	else if (k==2) {
		kz=(-0.2*(z:^2):+1):*(abs(z):<(5^.5))
	}
	else if (k==3) {
		kz= (-z:^2:+1):*(abs(z):<1)
	}
	else if (k==4) {
		kz=(-z:^2:+1):^2:*(abs(z):<1)
	}
	else if (k==5) {
		kz=(cos(2*pi()*z):+1):/2:*(abs(z):<0.5)
  	}
	else if (k==6) {
		kz=cos(pi()/2*z):*(abs(z):<1)
	}
	else if (k==7) {
		kz=((-6*z:^2+6*abs(z):^3):+1):*(abs(z):<=0.5)+(-abs(z):+1):^3:*2:*((abs(z):>0.5):*(abs(z):<=1))
	}
	else if (k==8) {
		kz=abs(z):<=1
	}
	else if (k==9) {
		kz=(-abs(z):+1):*(abs(z):<=1)
	}
	else if (k==10) {
		kz=(exp(z)+exp(z:*-1):+2):^-1:*4
	}
	else if (k==11) {
		kz=(-abs(z):^3:+1):^3:*(abs(z):<1)
	}
	else if (k==12) {
		kz=(-abs(z):^2:+1):^3:*(abs(z):<1)
	}
	return(kz)
}

end 

 
