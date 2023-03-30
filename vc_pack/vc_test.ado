** This version implements the Loops In MATA!!
capture program drop vc_test
program vc_test, rclass sortpreserve
syntax varlist(numeric fv) [if] [in], [ vcoeff(varname) bw(real -1) seed(str) ///
									knots(real -1) km(real 1) vcoeff_par(varname) kernel(str) wbsrep(real 50) degree(real 0) ]
 
	tokenize `varlist'
	local y `1'
	//get the rest of the vars
	macro shift
	local varx `*'
	if "`seed'"!="" set seed `seed'
	** Defines Sample, Works with and in addition to IF
	marksample touse
	markout `touse' `sample' `varlist' `vcoeff' 
	sort `touse'
	** 
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
		egen `_kn'=vbin(`vcoeff') if `touse', knot(`knots') km(`km')
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
	
	numlist "`degree'", int range(>=0 <4)
	numlist "`wbsrep'", int range(>=1)
	if `degree'==0      local xdepvar `varx' c.`full_x' 
	else if `degree'==1 local xdepvar `varx' c.(`varx')#c.`full_x' c.`full_x' 
	else if `degree'==2 local xdepvar `varx' c.(`varx')#(c.`full_x'##c.`full_x') c.`full_x'##c.`full_x'
	else if `degree'==3 local xdepvar `varx' c.(`varx')#(c.`full_x'##c.`full_x'##c.`full_x') c.`full_x'##c.`full_x'##c.`full_x'
	
	******** Basic test: Against 3 types of polynomials.
	tempvar res_p res_vc
	
	******** No interaction
	
	qui:reg `y' `xdepvar'    if `touse'==1
	
	qui:predict double `res_p',res
	
	******** VC_coeff
	qui:vc_predict `y' `varx' if `touse'==1, vcoeff(`full_x') vcoeff_par(`par_x') bw(`bw')  kernel(`kernel') res(`res_vc') nstat
	******** Estimation Test
	tempname M t
	qui:matrix accum `M'    = `res_p' `res_vc' 
	matrix `t'=vecdiag(`M')
	
	*** Here we will do the "Wild bootstrap"

	*local bsmax=(40*(`wbsrep')-1)
	tempvar y_p bwres_p  bwres_vc
	tempname mata_t aux_t
	mata:`mata_t'= st_matrix("`t'")
	display "Estimating J statistic CI using `wbsrep' Reps"
	display "----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5"
	forvalues i=1/`wbsrep' {
		*small mata program to run regressions? or just here
		local cnt=`cnt'+1
		if `cnt'<50 display _c "."
		else {
		local cnt=0
		display _c "." _n
		}
		
		capture drop `y_p' `bwres_p' `bwres_vc'
		qui:egen double `y_p'=wberr(`y'), err(`res_p')	
		qui:reg `y_p' `varx' `xdepvar' if `touse'==1
		qui:predict double `bwres_p',res
		******** VC_coeff
		qui:vc_predict `y_p' `varx' if `touse'==1, vcoeff(`full_x') vcoeff_par(`par_x') bw(`bw') kernel(`kernel') res(`bwres_vc') nstat
		qui:matrix accum `M'    = `bwres_p' `bwres_vc' 
		matrix `M'=vecdiag(`M')
		mata:`mata_t'= `mata_t'\st_matrix("`M'")
	}
	local p975=ceil(`wbsrep'*.975)
	local p950=ceil(`wbsrep'*.950)
	local p900=ceil(`wbsrep'*.900)
 
	mata:`mata_t'=(`mata_t'[,1]-`mata_t'[,2]):/`mata_t'[,2]
 	mata:`aux_t'=sort(`mata_t'[2..rows(`mata_t'),],1)
	mata:`aux_t'=`mata_t'[1], `aux_t'[`p900'],`aux_t'[`p950'],`aux_t'[`p975']
	mata:st_matrix("`mata_t'",`aux_t')
 	*** To display CV. For now lets just GET CV and save it in the other site
	ereturn clear
	mata:mata drop `mata_t' `aux_t'
	display  _n as text "Specification test." 
	if      `degree'==0 display as text "H0: y=x*b0+g*z+e"
	else if `degree'==1 display as text  "H0: y=x*b0+g*z+(z*x)*b1+e"
	else if `degree'==2 display as text  "H0: y=x*b0+g*z+(z*x)*b1+(z^2*x)*b2+e"
	else if `degree'==3 display as text  "H0: y=x*b0+g*z+(z*x)*b1+(z^2*x)*b2+(z^3*x)*b3+e"
	display as text  "H1: y=x*b(z)+e"
	display as text  "J-Statistic      :" as result %6.5f `mata_t'[1,1]
	display as text  "Critical Values" 
	display as text  "90th   Percentile:" as result %6.5f `mata_t'[1,2] 
	display as text  "95th   Percentile:" as result %6.5f `mata_t'[1,3] 
	display as text  "97.5th Percentile:" as result %6.5f `mata_t'[1,4] 
end

/*
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
  	
void cvreg2(string scalar nloerr,string scalar nlev,string scalar nyhat, string scalar nobs) 
{
	external y,x,fvc,bw, pvc, vc
	external krn
	// which kernel?
 
	if (krn=="gaussian") k=1
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
	
	n    = rows(y)
	yhat2=J(rows(y),1,0)	
	loerr2=J(rows(y),1,0)
	lev2=J(rows(y),1,0)	
	nnobs=J(rows(y),1,0)	
 	for(i=1;i<=rows(vc);i++) {
 		z=(fvc:-vc[i]):/bw
	    w=kweight(z,k)
		ixwx=invsym(quadcross(x,w,x))
		xwy=quadcross(x,w,y)
		wx=sqrt(w):*x
		lrv=quadrowsum(wx*ixwx:*wx)
		yhat=x*ixwx*xwy
		loerr=(y-yhat):/((lrv:*-1):+1) 
		loerr=loerr:*(loerr:!=.)
		lev2 =lev2+lrv:*(pvc:==vc[i])
		yhat2 =yhat2+yhat:*(pvc:==vc[i])
		loerr2=loerr2+loerr:*(pvc:==vc[i])
		nnobs=nnobs+(J(rows(y),1,0):+quadsum(w)):*(pvc:==vc[i])
	}
	stata("sum z1")
 	st_addvar("double",nloerr)
	st_store((1,n),nloerr,loerr2)
	st_addvar("double",nlev)
	st_store((1,n),nlev,lev2)
	st_addvar("double",nyhat)
	st_store((1,n),nyhat,yhat2)
	st_addvar("double",nobs)
	st_store((1,n),nobs,nnobs)
	stata("sum z1")
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

 */
