*!v1.01 Fix Bug with predict
** This will estimate the model only for OLS, no endogenous data, 
** using Externally defined residuals
capture program drop vc_preg
program vc_preg, eclass sortpreserve
    if replay() {
        display_vc
        exit
    }
syntax varlist(numeric fv) [if] [in] , ///
									 [vcoeff(varname) /// This is now taken from the globals.
									 bw(real-1) kernel(str) /// this is to select kernel details. Also taken from Globals
									 k(integer -1) klist(string) /// This indicates the models to be estimated either number of (K) or a list of values (klist)
									 bsw(varname) /// For foture work and Bootstrap
									 robust hc2 hc3 cluster(varname) /// various options for Standard errors. Default its weighted OLS 
									 knots(real -1) km(real 1) ///
									 err(str) lev(str) ]  
									  /// The idea would be to use err or lvrg to get correctes standard errors This will be "more" correct
** I will leave selmethod as undocumented for now.
** Parsing data
capture drop _delta_
capture drop _mill_
tokenize `varlist'
local y `1'
//get the rest of the vars
macro shift
local varx `*'

	  
marksample touse
markout `touse' `vcoeff'  `cluster' `strata'

numlist "`knots'", integer range(>=-2)
	* THis counts how many values vcoeff has
	tempvar vals
    qui:bysort `touse' `vcoeff': gen byte `vals' = (_n == 1) * `touse'
	
	 sum `vals' if `touse', meanonly 
	local vcvls=r(sum)
	qui:sort `touse' `cluster' `vcoeff'
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
	}
	
*** checking for vcoeff
if "`vcoeff'"=="" & "$vcoeff_"=="" {
	   display "Need to define vcoeff. variable for varying coefficients"
	   exit
}

if "`vcoeff'"=="" & "$vcoeff_"!="" {
		local vcoeff $vcoeff_
}
 
*** if bsw This is an unused option to allow for WEIGHTS in the regression
    if "`bsw'"=="" {
	local bsw=1
	}
*** Definiition of NM groups
 	if `k'==-1 {
	   if "`klist'"=="" {
	   display "Need to define number of groups or list the points of reference"
	   exit
	   
	   }
	}

	if `k'!=-1 {
	   if "`klist'"!="" {
	   display "you cannot define both number of groups and list of points"
	   exit
	   }
	}
*** Checking for saved Kernel and OPBW	
	if "$kernel_"!="" & "`kernel'"=="" {
	local kernel "$kernel_"
	}
	
	if "$opbw_"!="" & `bw'==-1 {
	local bw $opbw_
	}
**** Checking of standard error VCE calling.
if (("`hc2'"!="")+("`hc3'"!="")+("`robust'"!=""))>1 {
	display in red "Only one option for allowed. Choose between Robust hc2 or hc3"
	exit
}

 
*** Definition of Kernel
	if "`kernel'"=="" {
	local kernel "gaussian"
	}
	
	if 	"`kernel'"!="gaussian" & /// 
		"`kernel'"!="biweight" & /// 
		"`kernel'"!="cosine" & /// 
		"`kernel'"!="epan" & /// 
		"`kernel'"!="epan2" & /// 
		"`kernel'"!="parzen" & /// 
		"`kernel'"!="trian"  & ///
		"`kernel'"!="rectan"  {
	display "Kernel function `kernel' not allowed"
	exit 1
	}
	
*** Groups are created. based on Number of groups of interest, or number 	
    tempvar grps
	if `k'!=-1 & "`klist'"=="" {
		qui:sum `vcoeff' if `touse'==1,d
		local max=r(p99)
		local min=r(p1)
		local del=(`max'-`min')/(`k'-1)
	    
	   ** identifies the limits and stores them into grps
	   numlist "`min'(`del')`max'"
	   qui:gen double `grps'=.
	   foreach i in `r(numlist)' {
	      local nt=`nt'+1
		  qui:replace `grps'=`i' in `nt'
	   }
	   *pctile `grps'=`vcoeff' if `touse', n(`k')
	}
   
	if `k'==-1 & "`klist'"!="" {
	   numlist "`klist'", sort
	   qui:gen double `grps'=.
	   local kklist `r(numlist)'
	   local s=0
 	   foreach jk in `kklist' {
		   local s=`s'+1
		   ** Stores the preselected limits into grps
		   qui:replace `grps'=`jk' in `s'
	   }
     }
	 
	   ** This last procedure is done to ensure we do not have repeated values or values outside of the range   
	   *qui:sum `vcoeff'
	   *local max=r(max)
	   *local min=r(min)
	   

 
	  capture matrix drop _bts
	  capture matrix drop _bsd
	  
	  	  
	  if "`robust'`hc2'`hc3'"=="" {
			local robust robust
			}
	  
	  
	  ** Basic information getting into the regression
	  display as text "Estimating SVCM over `s' point(s) of reference" 
	  display as text "Smoothing variable: " as result " `vcoeff'" 
	  display as text "Kernel function   : " as result " `kernel'" 
	  display as text "Bandwidth         : " as result %6.5f `bw'
	  display as text "vce               : " as result "`clst'`robust'`hc2'`hc3'" 
	  display as text "Estimating Full model" 
	 
	  if "`err'"=="" | ("`lev'"=="" & "`hc2'`hc3'"!="") {
		  	tempvar err_2 lev_2 
			qui:vc_predict `y' `varx' if `touse', vcoeff(`vcoeff') bw(`bw') res(`err_2') lvrg(`lev_2') kernel(`kernel') knots(`knots') km(`km')
			if "`err'"=="" local err `err_2'
			if "`lev'"=="" local lev `lev_2'
 	  }
	     
 	  	  
	   if "`selmethod'"!="" {
	     `selmethod' if `touse' 
		 predict double _mill_, score
		}
*		capture gen _mill_=0

		tempvar kwgt  
	  * This is the kwgt
      qui:gen double `kwgt'=.
	  qui:gen double _delta_=.	
	
	   qui:levelsof `grps', local(grps2)
	   qui:replace `grps'=.
	   local s=0
	   foreach jk of local grps2 {
			 local s=`s'+1
			 qui:replace `grps'=`jk' in `s'
	   }
	   
	  if `s'==1 {
 		capture drop _kwgt_
 		tempvar cns
		qui:gen byte `cns'=1
		local por=`grps'[1]
 		qui:egen double _kwgt_=kweight(`vcoeff'), bw(`bw') pofr(`por') kernel(`kernel')
		qui:replace _kwgt_=_kwgt_*`bsw'
 		qui:replace _delta_=`vcoeff'-`grps'[1]
 

        noisily:reg `y' `varx' _delta_ c.(`varx' )#c._delta_ [iw=_kwgt_] if `touse', cluster(`cluster') robust	`hc2' `hc3' notable
		
		local fvarx="`varx' _delta_ c.(`varx' )#c._delta_ `cns'"
		
		tempname b`s' V`s'
		
 		mata:vcreg("`y'","`fvarx'", "_kwgt_","`err'","`lev'","`cluster'","`touse'","`robust'`hc2'`hc3'","`V`s''") 

		matrix `b`s''= e(b)
		local bb:colnames e(b)
		matrix colname `V`s''=`bb'
		matrix rowname `V`s''=`bb'
		local pofr=`por'
		local df_m=e(df_m)
		qui:sum _kwgt_ if `touse', meanonly
		local kobs=r(sum)

		local wtype "iweight"
		local wexp "`e(wexp)'"
        local vcetype "`e(vcetype)'"
 	  } 
	   
	  if `s'>1 {
		  
		  tempvar cns
		  qui:gen byte `cns'=1
		  display as text "More than 1 point of reference specified" 
		  display as text "Results will not be saved in equation form but as matrices"
		  local kobs=0
		  tempname _bts _bsd
			forvalues kn =1/`s' {
				capture drop `kwgt' 
				local por=`grps'[`kn']
				qui:egen double `kwgt'=kweight(`vcoeff'), bw(`bw') pofr(`por') kernel(`kernel')
				qui:replace `kwgt'=`kwgt'*`bsw'
				qui:replace _delta_=`vcoeff'-`grps'[`kn']
				 
				qui:reg `y' `varx' _delta_ c.(`varx' )#c._delta_ [iw=`kwgt'] if `touse', cluster(`cluster') `robust' `hc2' `hc3'
				tempname b`kn' V`kn'
				local fvarx="`varx' _delta_ c.(`varx' )#c._delta_ `cns'"
				tempname b`kn' V`kn'
				mata:vcreg("`y'","`fvarx'", "`kwgt'","`err'","`lev'","`cluster'","`touse'","`robust'`hc2'`hc3'","`V`kn''") 
				matrix `b`kn''= e(b)
				local bb:colnames e(b)
				matrix colname `V`kn''=`bb'
				matrix rowname `V`kn''=`bb'
				local pofr`kn'=`por'
				tempname rt aux
				matrix `rt'=r(table)
				matrix `aux'=`grps'[`kn']
				matrix colname `aux'=`vcoeff'
				matrix `_bts'=nullmat(`_bts')\[`aux',e(b)]
				matrix `_bsd'=nullmat(`_bsd')\[`aux',`rt'[2,....]]
				qui:sum `kwgt' if `touse'
				local auxN=r(N)*r(mean)
				local kobs=`kobs'+`auxN'
				capture drop _kwgt_
			 }
		}
**** FOR DISPLAY and ECLASS properties		   
	if `s'==1 {
		ereturn post `b1' `V1' , esample(`touse') depname(`y') dof(`df_m')
		ereturn local npofr=`s'
		ereturn local grphok="no"
		ereturn local vcoeff="`vcoeff'"
		ereturn local idepvar="`varx'"
		ereturn scalar kobs=`kobs'
		ereturn scalar N=round(`kobs',0.01)
		ereturn local cmd="vc_preg"
		ereturn local cmdline="vc_preg `0'"
		ereturn local title="local linear regression"
		ereturn local kernel ="`kernel'"
		ereturn scalar bw=`bw'
		ereturn scalar pofr=`por'
		ereturn local wtype "`wtype'"
		ereturn local wexp "`wexp'"
        ereturn local vcetype "`e(vcetype)'"
		if "`robust'`cluster'"==""	ereturn local vce="ols"
		if "`robust'"!=""	ereturn local vce="robust"
		if "`cluster'"!=""	{
			ereturn local vce="robust"
			ereturn local clustervar=`cluster' 
		}
		ereturn local model="Varying Coefficients"
		display_vc
 	}
	
	if `s'>1 {   
		*ereturn clear
		ereturn post
		forvalues kn =1/`s' {
	 		ereturn	matrix b`kn'  `b`kn''
	 		ereturn	matrix V`kn'  `V`kn''
		}
		ereturn local npofr=`s'
		ereturn matrix betas `_bts'
		ereturn matrix std `_bsd'	
		ereturn local vcoeff="`vcoeff'"
		ereturn local idepvar="`varx'"
		ereturn scalar kobs=`kobs'/`s'
		ereturn local cmd="vc_preg"
		ereturn local cmdline="vc_preg `0'"
		ereturn local title="local linear regression"
		ereturn local kernel ="`kernel'"
		ereturn scalar bw=`bw'
		ereturn local grphok="ok"
		ereturn local depvar="`y'"
        ereturn local model="Varying Coefficients"
		capture drop _delta_ 
		capture drop _mill_
	}
    *mata:mata drop y x w rr
	*capture matrix drop aux rt

end
capture  program drop display_vc
program display_vc
   if "`e(cmd)'"=="vc_preg" & `e(npofr)'==1  ereturn display
   else if "`e(cmd)'"=="vc_preg" & `e(npofr)'>1 display in red "More than 1 equation estimated. Nothing to report"
   else display in red "Last estimates not found"
end

/*		mata:y=st_data(.,"`y'","`touse'")
		mata:x=st_data(.,"`varx' _delta_ c.(`varx' )#c._delta_ `cns'","`touse'")
		mata:w=st_data(.,"_kwgt_","`touse'")
		mata:rr=st_data(.,"`err'","`touse'")
		mata:lev=st_data(.,"`lev'","`touse'")
 		
		noisily:reg `y' `varx' _delta_ c.(`varx' )#c._delta_ [iw=_kwgt_] if `touse', cluster(`cluster') `robust'	vce(`hc2'`hc3') notable
		if "`robust'"!="" {
			mata: ixwx=invsym(cross(x,w,x))
			mata: V=rows(x)/(rows(x)-cols(x)+diag0cnt(ixwx))*ixwx*(cross(x:*w,(rr):^2,x:*w))*ixwx
		}
		else if "`hc2'"!="" {
			mata:lev_1=lev:*-1:+1
			mata: V=invsym(cross(x,w,x))*(cross(x:*w,((rr):^2):/(lev_1),x:*w))*invsym(cross(x,w,x))
		}
		else if "`hc3'"!="" {
			mata:lev_1=lev:*-1:+1
			mata: V=invsym(cross(x,w,x))*(cross(x:*w,(rr:/lev_1):^2,x:*w))*invsym(cross(x,w,x))
		}*/
		
mata:
void vcreg(string scalar depvar    , string scalar indepvar , string scalar kweight   ,  
		   string scalar residuals, string scalar leverage, string scalar clustervar,  
		   string scalar touse    , string scalar vcetype, string scalar vccv) 
{
	real matrix y, x, w,  ixwx, cltvar,xi, ei,tus, res, lev, rr_hc2, rr_hc3, vcv, clsvar, info
	real scalar n, k, m, nc
	y   =st_data(.,depvar,touse)
	x   =st_data(.,indepvar,touse)
	w   =st_data(.,kweight,touse)
	rr  =st_data(.,residuals,touse)
	lev =st_data(.,leverage,touse)
	ixwx=invsym(quadcross(x,w,x))
	n=rows(x)
	k=(cols(x)-diag0cnt(ixwx))
	
	if (clustervar!="") {
			cvar = st_data(., clustervar, touse)
			info = panelsetup(cvar, 1)
			nc   = rows(info)
			M    = J(k, k, 0)
			for(i=1; i<=nc; i++) {
				xi = panelsubmatrix(x,i,info)
				ei = panelsubmatrix(rr:*w,i,info)
				M  = M + quadcross(xi,ei)*quadcross(ei,xi)
				//quadcross(xi,ei:^2,xi)
			}
			vcv  = ((n-1)/(n-k))*(nc/(nc-1))*ixwx*M*ixwx
	}
	else if (vcetype=="robust") {
		vcv=n/(n-k)*ixwx*(quadcross(x,(rr:*w):^2,x))*ixwx
	}
	else if (vcetype=="hc2") {
		rr_hc2=rr:/(((lev:*-1):+1):^.5)
		vcv=ixwx*(quadcross(x,(rr_hc2:*w):^2,x))*ixwx
	}
	else if (vcetype=="hc3") {
		rr_hc3=rr:/((lev:*-1):+1)
		vcv=ixwx*(quadcross(x,(rr_hc3:*w):^2,x))*ixwx
	}
    st_matrix(vccv,vcv)
}
end	
