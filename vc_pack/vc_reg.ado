** Now incorporates option for Selection !! AWESOME!!!
capture program drop vc_reg
program vc_reg, eclass sortpreserve
    if replay() {
        display_vc
        exit
    }
syntax varlist(numeric fv) [if] [in] , ///
									 [vcoeff(varname) /// This is now taken from the globals.
									 selmethod(str) /// THis will be left undocumented until I get "proof"
									 bw(real-1) kernel(str) /// this is to select kernel details. Also taken from Globals
									 k(integer -1) klist(string) /// This indicates the models to be estimated either number of (K) or a list of values (klist)
									 bsw(varname) /// For foture work and Bootstrap
									 robust cluster(varname)  hc2 hc3 ]  // various options for Standard errors. Default its weighted OLS
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
if (("`hc2'"!="")+("`hc3'"!="")+(("`cluster'"!="") | ("`robust'"!="")))>1 {
display in red "Only one option for robust standard errors is allowed"
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
	   
	   qui:levelsof `grps', local(grps2)
	   qui:replace `grps'=.
	   local s=0
	   foreach jk of local grps2 {
			 local s=`s'+1
			 qui:replace `grps'=`jk' in `s'
	   }
 
	  capture matrix drop _bts
	  capture matrix drop _bsd
	  
	  
  	  tempvar kwgt  
	  * This is the kwgt
      qui:gen double `kwgt'=.
	  qui:gen double _delta_=.
	  
	  if "`cluster'"!="" local clst "cluster(`cluster')"
	  if "`clst'`robust'`hc2'`hc3'"=="" {
			local robust robust
			}
	  ** Basic information getting into the regression
	  display as text "Estimating SVCM over `s' point(s) of reference" 
	  display as text "Smoothing variable: " as result " `vcoeff'" 
	  display as text "Kernel function   : " as result " `kernel'" 
	  display as text "Bandwidth         : " as result %6.5f `bw'
	  display as text "vce               : " as result "`clst'`robust'`hc2'`hc3'" 
	 
	   if "`selmethod'"!="" {
	     `selmethod' if `touse' 
		 predict double _mill_, score
		}
*		capture gen _mill_=0
		
	  if `s'==1 {
		capture drop `kwgt' 
		capture drop _kwgt_
		local por=`grps'[1]
		qui:egen double `kwgt'=kweight(`vcoeff'), bw(`bw') pofr(`por') kernel(`kernel')
		qui:replace `kwgt'=`kwgt'*`bsw'
		qui:gen double _kwgt_=`kwgt'
		qui:replace _delta_=`vcoeff'-`grps'[1]
		
		if "`selmethod'"!="" qui:reg `y' `varx' _mill_  _delta_ c.(`varx' _mill_)#c._delta_ [iw=`kwgt'] if `touse', cluster(`cluster') `robust'	 vce(`hc2'`hc3') 
		else reg `y' `varx' _delta_ c.(`varx' )#c._delta_ [iw=_kwgt_] if `touse', cluster(`cluster') `robust'	vce(`hc2'`hc3') 
		tempname b`s' V`s'
		matrix `b`s''= e(b)
		matrix `V`s''= e(V)
		local pofr=`por'
		local df_m=e(df_m)
		local df_r=e(df_r)
		qui:sum _kwgt_ if `touse', meanonly
		local kobs=r(sum)
		local wtype "iweight"
		local wexp "`e(wexp)'"
        local vcetype "`e(vcetype)'"
 	  } 
	   
	  if `s'>1 {
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
				
				if "`selmethod'"!="" qui:reg `y' `varx' _mill_  _delta_ c.(`varx' _mill_)#c._delta_ [iw=`kwgt'] if `touse', cluster(`cluster') `robust'	 vce(`hc2'`hc3')
				else qui:reg `y' `varx' _delta_ c.(`varx' )#c._delta_ [iw=`kwgt'] if `touse', cluster(`cluster') `robust'	vce(`hc2'`hc3')
				tempname b`kn' V`kn'
				*qui:reg `y' `varx' _mill_ _delta_ c._delta_#c.(`varx' _mill_) [iw=`kwgt'] if `touse', cluster(`cluster') `robust'
				matrix `b`kn''= e(b)
				matrix `V`kn''= e(V)
				
				local pofr`kn'=`por'
				tempname rt aux
				matrix `rt'=r(table)
				matrix `aux'=`grps'[`kn']
				matrix colname `aux'=`vcoeff'
				matrix `_bts'=nullmat(`_bts')\[`aux',e(b)]
				matrix `_bsd'=nullmat(`_bsd')\[`aux',`rt'[2,....]]
				qui:sum `kwgt' if `touse', meanonly
				*local auxN=r(N)*r(mean)
				local kobs=`kobs'+r(sum)
			 }
		}
**** FOR DISPLAY and ECLASS properties		   
	if `s'==1 {
 		ereturn post `b1' `V1' , esample(`touse') depname(`y') dof(`df_m')  buildfv
		ereturn local grphok="no"
		ereturn local vcoeff="`vcoeff'"
		ereturn local idepvar="`varx'"
		ereturn scalar npofr=`s'
		ereturn scalar kobs=`kobs'
		ereturn scalar N=round(`kobs',0.01)
		ereturn local cmd="vc_reg"
		ereturn local cmdline="vc_reg `0'"
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
		ereturn local model="Smooth Varying Coefficients model"
		*if "`table'"=="" display_vc
		
 	}
	
	if `s'>1 {   
		*ereturn clear
		ereturn post
		forvalues kn =1/`s' {
	 		ereturn	matrix b`kn'  `b`kn''
	 		ereturn	matrix V`kn'  `V`kn''
		}
		ereturn scalar npofr=`s'
		ereturn matrix betas `_bts'
		ereturn matrix std `_bsd'	
		ereturn local vcoeff="`vcoeff'"
		ereturn local idepvar="`varx'"
		*ereturn scalar kobs=`kobs'/`s'
		ereturn local cmd="vc_reg"
		ereturn local cmdline="vc_reg `0'"
		ereturn local title="local linear regression"
		ereturn local kernel ="`kernel'"
		ereturn scalar bw=`bw'
		ereturn local grphok="ok"
		ereturn local depvar="`y'"
        ereturn local model="Varying Coefficients"
		capture drop _delta_ 
		capture drop _mill_
	}
    
	*capture matrix drop aux rt

end

program display_vc, eclass
   if "`e(cmd)'"=="vc_reg" & `e(npofr)'==1  ereturn display
   else if "`e(cmd)'"=="vc_reg" & `e(npofr)'>1 display in red "More than 1 equation estimated. Nothing to report"
   else display in red "Last estimates not found"
end
