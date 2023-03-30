*** This is used to obtained the predicted vallues for all components of interest.
*** Potentially increase Efficiency by differentiating between factors that 
*** have explanatory variables, vs those that Dont
capture program drop mbitobit_p
program define mbitobit_p
    version 11
 
    syntax newvarname [if] [in] , [ xb1 yc1 pr1 ys1     /// moments respect to person 1
									xb2 yc2 pr2 ys2     /// moments respect to person 2
									rho sd1 sd2			/// rho & std.dev.
									ush1 ush2 tt  	    /// moments respect to both people
									yc1_1 pr1_1 ys1_1      /// Moments condition on spouse y>0
									yc2_1 pr2_1 ys2_1      /// Moments condition on spouse y>0
									yc1_0 pr1_0 ys1_0      /// Moments condition on spouse y<0
									yc2_0 pr2_0 ys2_0      /// Moments condition on spouse y<0
									p11 p10 p01 p00       /// Prob that Both work, one works the other doesnt, and on working 
									ush1_11 ush2_11tt_11  /// Equivalent to above but if BOTH working
									sim EQuation(string)  /// This last option is for Simulations. It will simulate data based on the model estimations  EQ will be a generic one
									]
    /*
	xb`i' is just the linear latent prediction
	yc`i' is E(xb`i'|xb`i'>=0) Expected value of the Prediction 
	         Conditional on it being Possitive but unconditional respect to partners decision
	pr`i' is P(xb`i'>=0) Probability of the latent to be Possitive
	         but unconditional respect to partners decision
	ys`i' is E(xb`i'|xb`i'>=0)*P(xb`i'>=0)+0*P(xb`i'<0)
			 Expected value of the Prediction, given that some may have possitive hours and some may not. 
	         but unconditional respect to partners decision
	rho sd1 sd2	are related to other moments of the regression 
	ush`i'   Predicts the expected share of hours of Person 1, with respect to total hours they both do
	         This uses overall unconditional expectations.  
			 ush1=100*E(ys`i') /
			      (E(ys2)+E(ys1))
			 Mutiplied by 100 for interprettion purposes.	  
	tt       Predicts Total Expeced hours (unconditional on decisions) 	E(ys2)+E(ys1))
	The unconditional predictions can be consider as: what would be the average Share if we pick a household at random. 
	********************
	Because we do have information about 2 persons, we also have the conditional moments
	yc`i'_`j' means Moment YC(YS or PR) for person i conditional on person "j" either engaged (1) or not engaged (0)
	
	Since we are on this, we could also create Conditionals on Possitive.
	For example, If husband not working, then USH will be ZERO for husband 100 for Wife.
	But we can construct:
	p11 p10 p01 p00 Probability of Both working, one does the other does not, and non works.
	tt_11            Total time if Both engaged.
	ush1_11 ush2_11  Shares Assuming Both work.
	*/
	
    marksample touse, novarlist
	
    local nopts : word count `xb1'  `yc1'  `pr1'  `ys1'     /// 
						 	 `xb2'  `yc2'  `pr2'  `ys2'     /// 
							 `rho'  `sd1'  `sd2'			/// 
							 `ush1' `ush2' `tt'             /// 
							 `yc1_1' `pr1_1' `ys1_1'        /// 
							 `yc2_1' `pr2_1' `ys2_1'        /// 
							 `yc1_0' `pr1_0' `ys1_0'        /// 
							 `yc2_0' `pr2_0' `ys2_0'        ///
							 `p11'   `p10' `p01' `p00'      ///
							 `ush1_11' `ush2_11' `tt_11'  `sim'  `equation'          

									
    if `nopts' >1 {
        display in red "{err}only one statistic may be specified"
    }
 
    if `nopts' == 0 {
        local xb1 xb1		
 
    }
	
	tempvar _xb1 _xb2 _lns1 _lns2 _arho
	local _rho	 (tanh(`_arho'))
	local _sd1   (exp(`_lns1'))
	local _sd2   (exp(`_lns2'))
	local _pr1   (normal(`_xb1'/`_sd1'))
	local _pr2   (normal(`_xb2'/`_sd2'))
	local _mill1 (normalden(`_xb1'/`_sd1')/normal(`_xb1'/`_sd1'))
	local _mill2 (normalden(`_xb2'/`_sd2')/normal(`_xb2'/`_sd2'))
	local _yc1   (`_xb1'+`_sd1'*`_mill1')
	local _yc2   (`_xb2'+`_sd2'*`_mill2')
	local _ys1   (`_xb1'+`_sd1'*`_mill1')*`_pr1'
	local _ys2   (`_xb2'+`_sd2'*`_mill2')*`_pr2'
	local _tt    (`_ys1'+`_ys2')
	local _ush1  (100*`_ys1'/(`_ys1'+`_ys2'))
	local _ush2  (100*`_ys2'/(`_ys1'+`_ys2'))
	*** aux variables
	local l1	 (-`_xb1'/`_sd1')
	local l2	 (-`_xb2'/`_sd2')
	local c      ((1-`_rho'^2)^(-.5))
	local _p11   (binormal(-`l1',-`l2', `_rho'))
	local _p01   (binormal( `l1',-`l2',-`_rho'))
	local _p10   (binormal(-`l1', `l2',-`_rho'))
	local _p00   (binormal(-`l1',-`l2', `_rho'))
	
	local _yc11 ((normalden(`l1')*(1-normal((`l2'-`_rho'*`l1')*`c'))+`_rho'*normalden(`l2')*(1-normal((`l1'-`l2'*`_rho')*`c')))/`_p11')
	local _yc21 ((normalden(`l2')*(1-normal((`l1'-`_rho'*`l2')*`c'))+`_rho'*normalden(`l1')*(1-normal((`l2'-`l1'*`_rho')*`c')))/`_p11')
	local _yc10 ((normalden(`l1')*(  normal((`l2'-`_rho'*`l1')*`c'))-`_rho'*normalden(`l2')*(1-normal((`l1'-`l2'*`_rho')*`c')))/`_p10')
	local _yc20 ((normalden(`l2')*(  normal((`l1'-`_rho'*`l2')*`c'))-`_rho'*normalden(`l1')*(1-normal((`l2'-`l1'*`_rho')*`c')))/`_p01')
	
	*** From here on we have the Conditional Moments. 
	local _yc1_1 (`_xb1'+`_sd1'*`_yc11')
	local _yc1_0 (`_xb1'+`_sd1'*`_yc10')
	local _yc2_1 (`_xb2'+`_sd2'*`_yc21')
	local _yc2_0 (`_xb2'+`_sd2'*`_yc20')
	
	local _pr1_1 (`_p11'/   `_pr2')
	local _pr1_0 (`_p10'/(1-`_pr2'))
	local _pr2_1 (`_p11'/   `_pr1')
	local _pr2_0 (`_p01'/(1-`_pr1'))
	
	local _ys1_1 (`_yc1_1'*`_pr1_1')
	local _ys1_0 (`_yc1_0'*`_pr1_0')
	local _ys2_1 (`_yc2_1'*`_pr2_1')
	local _ys2_0 (`_yc2_0'*`_pr2_0')

	local _prt   (1-`_p00')
	local _sdt   (sqrt(`_sd1'^2+`_sd2'^2+2*`_rho'*`_sd1'*`_sd2'))
	local _millt (normalden((`_xb1'+`_xb2')/`_sdt')/normal((`_xb1'+`_xb2')/`_sdt'))
	local _yct   (`_xb1'+`_xb2'+`_sdt'*`_millt')
	local _yst   (`_yct'*`_prt')
	
	
	
	qui {
	    *** Depends on itself only
		if "`equation'"!="" {
		    	_predict `typlist' `varlist' if `touse' , eq(`equation')
		}
		else if "`xb1'" != "" {
			_predict `typlist' `varlist' if `touse' , eq(#1)
			label var `varlist' "xb for eq1"
		}
		else if "`pr1'`yc1'`ys1'" != "" {
 		    _predict double `_xb1' , eq(#1)
			_predict double `_lns1', eq(lns1)
			gen `typlist' `varlist' = `_`pr1'`yc1'`ys1'' if `touse'
		}
		*** Depends on itself only
		else if "`xb2'" != "" {
			_predict `typlist' `varlist' if `touse' , eq(#2)
			label var `varlist' "xb for eq2"
		}
		else if "`pr2'`yc2'`ys2'" != "" { 
 		    _predict double `_xb2' , eq(#2)
			_predict double `_lns2', eq(lns2)
			gen `typlist' `varlist' = `_`pr2'`yc2'`ys2'' if `touse'
		}
		else if "`rho'"!= "" {
			_predict double `_arho', eq(arho)
			gen `typlist' `varlist' = `_rho'      		 if `touse'
		}
		else if "`sd1'"!= "" {
			_predict double `_lns1', eq(lns1)
			gen `typlist' `varlist' = `_sd1'      		 if `touse'
		}
		else if "`sd2'"!= "" {
			_predict double `_lns2', eq(lns2)
			gen `typlist' `varlist' = `_sd2'      		 if `touse'
		}
		
		*** Depends on joint only
		else if "`ush1'`ush2'`tt'" != "" {
 			_predict double `_xb1' , eq(#1)
			_predict double `_xb2' , eq(#2)
			_predict double `_lns1', eq(lns1)
			_predict double `_lns2', eq(lns2)
			gen `typlist' `varlist' = `_`ush1'`ush2'`tt'' if `touse'
		}

		else if "`yc1_1'`yc1_0'`yc2_1'`yc2_0'" != "" {
			_predict double `_xb1' , eq(#1)
			_predict double `_xb2' , eq(#2)
			_predict double `_lns1', eq(lns1)
			_predict double `_lns2', eq(lns2)
			_predict double `_arho', eq(arho)
			gen `typlist' `varlist' = (`_`yc1_1'`yc1_0'`yc2_1'`yc2_0'') if `touse'
		}
		else if "`pr1_1'`pr1_0'`pr2_1'`pr2_0'" != "" {
			_predict double `_xb1' , eq(#1)
			_predict double `_xb2' , eq(#2)
			_predict double `_lns1', eq(lns1)
			_predict double `_lns2', eq(lns2)
			_predict double `_arho', eq(arho)
			gen `typlist' `varlist' = (`_`pr1_1'`pr1_0'`pr2_1'`pr2_0'') if `touse'
		}
		else if "`ys1_1'`ys1_0'`ys2_1'`ys2_0'" != "" {
			_predict double `_xb1' , eq(#1)
			_predict double `_xb2' , eq(#2)
			_predict double `_lns1', eq(lns1)
			_predict double `_lns2', eq(lns2)
			_predict double `_arho', eq(arho)
			gen `typlist' `varlist' = (`_`ys1_1'`ys1_0'`ys2_1'`ys2_0'') if `touse'
		}
		else if "`ush1_11'`ush2_11'`tt_11'" != "" {
			_predict double `_xb1' , eq(#1)
			_predict double `_xb2' , eq(#2)
			_predict double `_lns1', eq(lns1)
			_predict double `_lns2', eq(lns2)
			_predict double `_arho', eq(arho)
			gen `typlist' `varlist' = `_`ush1'`ush2'`tt'' if `touse'
		}
		else if "`ush1_11'`ush2_11'`tt_11'" != "" {
		    /// I may leave this undocumented. 
			/// The meain reason is... other options 
			/// tt=ys1_1+yc2
			/// tt=ys2_1+yc1
			_predict double `_xb1' , eq(#1)
			_predict double `_xb2' , eq(#2)
			_predict double `_lns1', eq(lns1)
			_predict double `_lns2', eq(lns2)
			_predict double `_arho', eq(arho)
			tempvar __yc1_1 __yc2_1
			gen   double `__yc1_1' = `_yc1_1' if `touse'
			gen   double `__yc2_1' = `_yc2_1' if `touse'
			local _tt_11   (`__yc1_1'+`__yc1_2')
			local _ush1_11 (100*`__yc1'/(`__yc1'+`__yc2'))
			local _ush2_11 (100*`__yc2'/(`__yc1'+`__yc2'))
			gen `typlist' `varlist' = `_`ush1_11'`ush2_11'`tt_11'' if `touse'
		}	
        else if "`p11'`p10'`p01'`p00'" != "" {
		    /// I may leave this undocumented. 
			/// The meain reason is... other options 
			/// tt=ys1_1+yc2
			/// tt=ys2_1+yc1
			_predict double `_xb1' , eq(#1)
			_predict double `_xb2' , eq(#2)
			_predict double `_lns1', eq(lns1)
			_predict double `_lns2', eq(lns2)
			_predict double `_arho', eq(arho)
			gen `typlist' `varlist' = `_`p11'`p10'`p01'`p00'' if `touse'
		}
		else if "`sim'"!="" {
		    *this section basically simulates the data.
			local ls1:word 1 of `e(depvar)'
			local ls2:word 2 of `e(depvar)'
			
			_predict double `_xb1' , eq(#1)
			_predict double `_xb2' , eq(#2)
			_predict double `_lns1', eq(lns1)
			_predict double `_lns2', eq(lns2)
			_predict double `_arho', eq(arho)
			
			gen `typlist' `varlist'_`ls1' = rnormal(`_xb1',exp(`_lns1'))
			gen `typlist' `varlist'_`ls2' = `_xb2'+`_rho'*`_sd2'/`_sd1'*(`varlist'_`ls1'-`_xb1')+rnormal()*`_sd2'*sqrt(1-`_rho'^2)
			replace `varlist'_`ls1'=0 if `varlist'_`ls1'<0
			replace `varlist'_`ls2'=0 if `varlist'_`ls2'<0
			label var `varlist'_`ls1' "Simulated `ls1'"
			label var `varlist'_`ls2' "Simulated `ls2'"
		}
						
			
	}
	** labeling all variables
	     if "`xb1'`xb2'"    !="" label var `varlist' "latent xb"
	else if "`pr1'`pr2'"    !="" label var `varlist' "p(y>=0)"
	else if "`pr1'`pr2'"    !="" label var `varlist' "p(y>=0)"
	else if "`rho'"  	    !="" label var `varlist' "rho"
	else if "`sd1'`sd2'"    !="" label var `varlist' "sigma_i"
	else if "`pr1_1'`pr2_1'"!="" label var `varlist' "p(yi>=0|yj>=0)"
	else if "`pr1_0'`pr2_0'"!="" label var `varlist' "p(yi>=0|yj<0) "
	else if "`yc1'`yc2'"    !="" label var `varlist' "E(y|y>=0)"
	else if "`ys1'`ys2'"    !="" label var `varlist' "E(y)=E(y|y>=0)*p(y>=0)"
	else if "`ush1'`ush2'"  !="" label var `varlist' "100*E(yi)/(E(yi)+E(yj))"
	else if "`tt'"          !="" label var `varlist' "E(yi)+E(yj)"
	else if "`yc1_1'`yc2_1'"!="" label var `varlist' "E(yi|yi>=0,yj>=0)"
	else if "`yc1_0'`yc2_0'"!="" label var `varlist' "E(yi|yi>=0,yj< 0)"
	else if "`ys1_1'`ys2_1'"!="" label var `varlist' "E(yi|yj>=0)=E(yi|yi>=0,yj>=0)*p(yi>=0|yj>=0)"
	else if "`ys1_0'`ys2_0'"!="" label var `varlist' "E(yi|yj< 0)=E(yi|yi>=0,yj< 0)*p(yi>=0|yj< 0)"
	else if "`p00'"         !="" label var `varlist' "p(y1<0 ,y2<0)"          
	else if "`p01'"         !="" label var `varlist' "p(y1<0 ,y2>=0)"          
	else if "`p10'"         !="" label var `varlist' "p(y1>=0,y2<0)"          
	else if "`p11'"         !="" label var `varlist' "p(y1>=0,y2>=0)"
end

 
