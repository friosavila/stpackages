** For bootstrap VCREG
** Now incorporates option for Selection 
** This version has MATA application. Faster but Need to check out if matrices stay or not.
capture program drop vc_bsreg
program vc_bsreg, eclass sortpreserve
    if replay() {
        display_vc
        exit
    }
syntax varlist(numeric fv) [if] [in] ,   /// required. respecify the vcoeff model. May change it to this isnt necessary anymore.
								[ vcoeff(varname) selmethod(str) /// This is to obtain the selection term. Very simple application rightnow. We introduce the whole regression. Will be left as undocumented.
								bw(real -1)  kernel(str)   /// selects the kernel function of interest and bandwidth
								k(integer -1) klist(string)  /// BW can be directly applied or using the vcbw optimal, K and klist indicate # points of reference, or give a list
								bsw(varname) savemat /// old options for future work 
								cluster(varname) reps(integer 50) pci(real 95) seed(str) strata(varname)  /// All this are the bootstrap options. seed for replication and pci for selecting confidence interval
								skf(real 1)   /// this will be the Shrinkage factor. The idea: use BW* for main regression, and Smaller for Bootstrap. Undersmoothing for the estimation of Standard errors.
								] 
** Parsing data
** The idea is to use vc reg for each poin in the klist or K groups so 
marksample touse
markout `touse' `vcoeff'  `cluster' `strata'

tokenize `varlist'
local y `1'
//get the rest of the vars
macro shift
local varx `*'
*** checking for vcoeff
if "`vcoeff'"=="" & "$vcoeff_"=="" {
	   display "Need to define vcoeff. variable for varying coefficients"
	   exit
}

if "`vcoeff'"=="" & "$vcoeff_"!="" {
		local vcoeff $vcoeff_
}
*** Definiition of NM groups
    numlist `skf', range(>0)
 	if `k'==-1 {
	   if "`klist'"=="" {
	   display "Need to define number of groups or list the points of reference"
	   error 1
	   }
	}

	if `k'!=-1 {
	   if "`klist'"!="" {
	   display "you cannot define both number of groups and list of points"
	   exit
	   }
	}
	
	if "$kernel_"!="" & "`kernel'"=="" {
		local kernel "$kernel_"
	}
	
	if "$opbw_"!="" & `bw'==-1 {
		local bw $opbw_
	}
	
    ** Checking for Kernel
	if "`kernel'"=="" {
	local kernel "gaussian"
	}
	
    if 	"`kernel'"!="gaussian" & /// 
		"`kernel'"!="biweight" & /// 
		"`kernel'"!="cosine" & /// 
		"`kernel'"!="epan" & /// 
		"`kernel'"!="epan2" & /// 
		"`kernel'"!="parzen" & /// 
		"`kernel'"!="trian" & ///  
		"`kernel'"!="rectan"  {
	display "Kernel function `kernel' not allowed"
	exit 1
	}
**** Checking for system Seed
   if "`seed'"=="" {
		local seed=c(seed)
   }

*** Groups are created. based on Number of groups of interest, or numlist. I think i should change this. After all the Extreams are too extream in most cases.
    tempvar grps
	if `k'!=-1 & "`klist'"=="" {
		qui:sum `vcoeff' if `touse'==1,d
		local max=r(p99)
		local min=r(p1)
		local del=(`max'-`min')/(`k'-1)
	    
	   ** identifies the limits and stores them into grps
	   qui:numlist "`min'(`del')`max'"
	   qui:gen double `grps'=.
	   foreach i in `r(numlist)' {
	      local nt=`nt'+1
		  qui:  replace `grps'=`i' in `nt'
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
	  * qui:sum `vcoeff'
	  * local max=r(max)
	  * local min=r(min)
	   qui:levelsof `grps', local(grps2)
	  
	   qui:replace `grps'=.
	   local s=0
	   foreach jk of local grps2 {
		*   if `jk'>=`min'*0.99 & `jk'<=`max'*1.01 {
			 local s=`s'+1
			 qui:replace `grps'=`jk' in `s'
		*   }
	   }
 
      capture matrix drop _bts
	  capture matrix drop _bsd
	 ** Basic information getting into the regression
      display as text "Estimating SVCM over `s' point(s) of reference" 
	  display as text "Smoothing variable: " as result " `vcoeff'" 
	  display as text "Kernel function   : " as result " `kernel'" 
	  display as text "Bandwidth         : " as result %6.5f `bw'
	  display as text "Shrinkage         : " as result %6.5g `skf'
	  display as text "vce               : " as result "Bootstrap" 
 
	  
	 qui:levelsof `grps', local(flist)
  	  	  display "Bootstrap outputs for each regression will be saved separately" 
		  display "Coefficients and standard errors will be saved in e(betas) e(std)"
		  display "Percentile confidence intervals are saved in e(ll) e(ul)"
	 if `s'==1 {
		local bws=`bw'*`skf'
		qui:vc_reg `varlist' if `touse', vcoeff(`vcoeff') selmethod(`selmethod') bw(`bw')  klist(`flist') kernel(`kernel')
		tempname bopt
		matrix `bopt'=e(b)
	     bootstrap, cluster(`cluster') reps(`reps') seed(`seed') strata(`strata')  level(`pci') notable noheader: vc_reg `varlist' if `touse', vcoeff(`vcoeff') selmethod(`selmethod') bw(`bws')  klist(`flist') kernel(`kernel')  
		tempname b_`s' V_`s'
		matrix `b_`s''= `bopt'
		matrix `V_`s''= e(V)
		local df_m=e(rank)
		local kobs=e(kobs)
		local por=`flist'
		tempname ll ul 
		matrix `ll'=e(ci_percentile)
		matrix `ul'=`ll'[2,....]
		matrix `ll'=`ll'[1,....]
		local cilevel=e(level)
		local N_reps=e(N_reps)
		
	  }  
	
	 if `s'>1 {
		display "Estimating models:"
		local kobs=0
		tempvar _bts_ _bsd_ ul ll xx
		 forvalues kn =1/`s' {
		 display _continue .
		 ***This section is to get point estimates
				local bws=`bw'*`skf'
				qui:vc_reg `varlist' if `touse', vcoeff(`vcoeff') selmethod(`selmethod') bw(`bw')  klist(`flist') kernel(`kernel')
				tempname bopt
				matrix `bopt'=e(b)
		 ***		
		 		local flist=`grps'[`kn']
				qui:bootstrap, cluster(`cluster') reps(`reps') seed(`seed') strata(`strata')  level(`pci') : vc_reg `varlist' if `touse', vcoeff(`vcoeff') selmethod(`selmethod') bw(`bws')  klist(`flist')  kernel(`kernel')
				tempname b_`kn' V_`kn'
				matrix `b_`kn''= `bopt'
				matrix `V_`kn''= e(V)
				tempname rt aux
				matrix `rt'=r(table)
				matrix `aux'=`grps'[`kn']
				matrix colname `aux'=`vcoeff'
				matrix `_bts_'=nullmat(`_bts_')\[`aux',e(b)]
				matrix `_bsd_'=nullmat(`_bsd_')\[`aux',`rt'[2,....]] 
				local  kobs=`kobs'+e(kobs)
				matrix `xx'=e(ci_percentile)
				matrix `ul'=nullmat(`ul')\[`aux',`xx'[2,....]]
				matrix `ll'=nullmat(`ll')\[`aux',`xx'[1,....]]
			 }
	  }	   
		   
**** FOR DISPLAY and ECLASS properties
	if `s'==1 {
		*ereturn post b_1 V_1 , esample(`touse') depname(`y') dof(`df_m')
 		ereturn repost b=`b_1'
		ereturn local grphok="no"
		ereturn local vcoeff="`vcoeff'"
		ereturn local idepvar="`varx'"
		ereturn scalar kobs=`kobs'
		ereturn scalar N=round(`kobs',0.01)
		ereturn local cmd="vc_bsreg"
		ereturn local cmdline="vc_bsreg `0'"
		ereturn local title="local linear regression"
		ereturn local kernel ="`kernel'"
		ereturn local vce="bootstrap"
		ereturn scalar bw=`bw'
		ereturn scalar pofr=`por'
		ereturn local model="Varying Coefficients"
		ereturn scalar cilevel=`cilevel'
		ereturn scalar N_reps=`N_reps'
		local wtype "iweight"
		local wexp "`e(wexp)'"
        local vcetype "`e(vcetype)'"
		display_vc
 	}
			
	if `s'>1 {
		ereturn post		
	    * we may choose to NOT save results
		*if "`savemat'"!='' {
	         forvalues kn =1/`s' {
	 		     ereturn matrix b`kn'  `b_`kn''
	 		     ereturn matrix V`kn'  `V_`kn''
			 }
		*	}
		ereturn local npofr=`s'
		ereturn matrix betas `_bts_'
		ereturn matrix std `_bsd_'
		ereturn matrix ll `ll'
		ereturn matrix ul `ul'
		ereturn local vcoeff="`vcoeff'"
		ereturn local idepvar="`varx'"
		ereturn scalar ekobs=`kobs'/`s'
		ereturn local cmd="vc_bsreg"
		ereturn local cmdline="vc_bsreg `0'"
		ereturn local title="local linear regression"
		ereturn local kernel ="`kernel'"
		ereturn scalar bw=`bw'
		ereturn local grphok="ok"
		ereturn local depvar="`y'"
        ereturn local model="Varying Coefficients"
	    capture drop _delta_
	    capture drop _kwgt_
	    capture drop _mill_

	}

	*capture matrix drop aux rt 
	*capture matrix drop xx 

end

*capture program drop display_vc 
program display_vc
   if "`e(cmd)'"=="vc_bsreg" & `e(npofr)'==1 ereturn display    
   else if "`e(cmd)'"=="vc_bsreg" & `e(npofr)'>1 display in red "More than 1 equation estimated. Nothing to report"
   else display in red "Last estimates not found"
end
