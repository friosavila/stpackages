*!1.1 FRA Make it so varabbrev doesnt break the program 
capture program drop vc_graph
program vc_graph, sortpreserve
syntax [varlist(numeric fv default=none)], [ci(real 95) constant delta  xvar(varname) ///
                                            graph(str) ///
											rarea ///
											ci_off  ///
											pci  ///
											tol(real 0.1)  ///
											addgraph(str)  ///
											over(str) /// This to make 2 graphs
											]
** addgraph a simple cheating way to add another figure
	if "`e(cmd)'"!="vc_reg" & "`e(cmd)'"!="vc_bsreg" & "`e(cmd)'"!="vc_preg" {
		display in red ("Last estimates not found or not a vc_reg, vc_preg nor vc_bsreg command")
		exit 
	}
	if "`e(grphok)'"!="ok" {
		display in red ("2 of more estimates needed to prepare graphs")
		exit 
	}
	if `ci'>=100 |  `ci'<=0 {
	    display in red ("Confidence interval should be above 0% and below 100% ")
		exit 
	}
	if "`pci'"!="" & ("`ci'"!="95" | e(cmd)!="vc_bsreg") {
		display in red ("Percentile Intervals can only be used with vc_bsreg and cant be combined with ci")
		exit
	}
	
 	if ("`varlist'"=="" | "`varlist'"=="`e(vcoeff)'") &  "`constant'"=="" {
	   display "Need to specify -varlist- or the option -constant-"
	   exit
	   }

	*for selection graph type   
	local gtype="rcap"
	if "`rarea'"!="" {
	local gtype="rarea"
	}
	
	if "`delta'"!="" {
	local delta="#c._delta_"
	local tdelta="{stSymbol:D}z * "
	}
	
	if "`varlist'"!="" {
 	fvexpand `varlist'
 	local vlist= r(varlist)
		
		foreach i of local vlist  {
		   _ms_parse_parts `i'
		   if "`i'"!="`e(vcoeff)'" {
				if r(omit)!=1 local nvlist `nvlist' `i'
		   }
		}
		local vlist `nvlist'
	}
	
	if "`constant'"!="" & "`varlist'"!="" {
	local vlist `vlist' _cons
	}
	if "`constant'"!="" & "`varlist'"=="" {
	local vlist="_cons"
	}
	tempname betas std ul ll
 	matrix `betas'=e(betas)
	matrix `std'=e(std)
	matrix `ul'=e(ul)
	matrix `ll'=e(ll)
 	*** this obtains the x axis, Defined by the varying coefficient model.
		tempname vcx mvcx
		matrix `mvcx'=`betas'[....,"`e(vcoeff)'"]
		local rvcx=rowsof(`mvcx')
		svmat `mvcx', names(`vcx')
		local vcoeff="`e(vcoeff)'"
		
	** for true CI
		local ci2=(100-(100-`ci')/2)/100
		* label for Vcoeff"
		local lbl : variable label `vcoeff'
		if "`lbl'"=="" {
		local lbl="`vcoeff'"
		}
	* 
			tempname org	
		** If one wants to transform the Vcoeff to another variable this option is used
		if "`xvar'"!="" & "`xvar'"!="`vcoeff'" {
	     qui:levelsof `vcx'1, local(vcxlist)
		 qui:vt_xtoy, yvar(`xvar')  xvar(`vcoeff')  xlist(`vcxlist')
         foreach k in `r(ylist)' {
		  local kk=`kk'+1
		  qui:replace `vcx'1=`k' in `kk'
			}

			local lbl : variable label `xvar'
			if "`lbl'"=="" {
			local lbl="`xvar'"
			}  
			*qui:est restore `org'
		}
 
	if "`graph'"=="" {
	local graph grph 
	}
    
	*** This section should do the graphs
    tempname mxvar
	foreach x of local vlist {
     tempname xm  
	   local dtax="`x'`delta'"
	   if "`delta'"!="" & "`x'"=="_cons" {
	      local dtax="_delta_"
	   }
	   if "`pci'"=="" {
	      matrix `mxvar'=`betas'[....,"`dtax'"],`betas'[....,"`dtax'"]-invnormal(`ci2')*`std'[....,"`dtax'"],`betas'[....,"`dtax'"]+invnormal(`ci2')*`std'[....,"`dtax'"]
 	   }
	   if "`pci'"!="" {
	   local p Percentile
	      matrix `mxvar'=`betas'[....,"`dtax'"],`ll'[....,"`dtax'"],`ul'[....,"`dtax'"]
 	   }
	   
	   {
	   local cnt=`cnt'+1
	   tempname xm  
	   svmat `mxvar', names(`xm' )
	   *** here is the graph
	   if "`delta'"=="" local ytl "{&beta}(z)"
	   else local ytl "{&part}{&beta}(z)/{&part}z"
/////////////////////	   
	   if "`over'"== "" {
	   	   if "`ci_off'"=="" {
		       if "`addgraph'"!="" {
				   twoway (`gtype' `xm'2 `xm'3 `vcx'1, sort) (line `xm'1 `vcx'1, sort) (`addgraph'), ///
				   xtitle("`lbl'") ytitle(`ytl') legend(order(1 "`ci'% `p' Confidence Interval")) ///
				   title("Varying Coefficients of `tdelta'`x'") name(`graph'`cnt', replace)
			   }
			   else {
				   twoway (`gtype' `xm'2 `xm'3 `vcx'1, sort) (line `xm'1 `vcx'1, sort) , ///
				   xtitle("`lbl'") ytitle(`ytl') legend(order(1 "`ci'% `p' Confidence Interval")) ///
				   title("Varying Coefficients of `tdelta'`x'") name(`graph'`cnt', replace)
			   }
		   }
		   if "`ci_off'"=="ci_off" {
		   	   if "`addgraph'"!="" {
				   twoway line (`xm'1 `vcx'1, sort) (`addgraph'), ///
				   xtitle("`lbl'") ytitle(`ytl') legend(off) ///
				   title("Varying Coefficients of `tdelta'`x'") name(`graph'`cnt', replace)
			   }
			   else {
				   twoway (line `xm'1 `vcx'1, sort) , ///
				   xtitle("`lbl'") ytitle(`ytl') legend(order(1 "`ci'% `p' Confidence Interval")) ///
				   title("Varying Coefficients of `tdelta'`x'") name(`graph'`cnt', replace)
			   }
		   }
		}
		/// check how to get better colors
		if "`over'"!="" {
		    twoway (`gtype' `xm'2 `xm'3 `vcx'1 if `vcx'1<`over', sort) (line `xm'1 `vcx'1 if `vcx'1<`over', sort) ///
					(`gtype' `xm'2 `xm'3 `vcx'1 if `vcx'1>=`over', sort) (line `xm'1 `vcx'1 if `vcx'1>=`over', sort), ///
				 			   xtitle("`lbl'") ytitle(`ytl') legend(order(1 "`ci'% `p' Confidence Interval")) ///
				   title("Varying Coefficients of `tdelta'`x'") name(`graph'`cnt', replace)
		} 
		
////////////////////////		
   }
}

	*capture matrix drop betas std  
	*capture matrix drop ul ll
	capture drop `vcx'1
	capture drop `xm'
	*capture matrix drop vcx  xvar 
	 
end
 