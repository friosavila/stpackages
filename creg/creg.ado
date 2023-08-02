

// =============================================================================
//  John de New : Centered Regression           Version: Jan 5, 2022
//
//  This ado contains info from an old fvhds97.ado by John de New
//  It adds 2 major components: (a) a self written margins functionality
//								(b) all of the Rios-Avila/de New extension
//
// 	All of the Rios-Avila/de New extension is joint work: Rios-Avila/de New
//  Please cite the mentioned papers, HDS97 and RADN22
//
//   Haisken-DeNew, J.P. and Schmidt C.M. (1997):
//   "Interindustry and Interregion Wage Differentials:
//   Mechanics and Interpretation," Review of Economics
//   and Statistics, 79(3), 516-521. REStat Reprint
//
//   Rios-Avila, Fernando and de New, John P. (2022):
//   "Marginal Unit Interpretation of Unconditional Quantile 
//   Regression and Recentered Influence Functions 
//   using Centered Regression", mimeo
//
//   Contact:	johnhd@unimelb.edu.au
// 				friosavi@levy.org
//
// =============================================================================

// 20220722: Fixed weights so that P weights are replaced as A weights for "sum" command

capture program drop _creg

capture program drop _crmarginals
capture program drop _fvhds97
capture program drop _radn


syntax [, eval]


capture program drop creg
program define creg, eclass

	syntax [, eval radn divbycons pp(integer 1) eststub(string)]
	
	
	_crsyntax
	
	// if pweights used, force aweights for sum
	// Fernando 2022_07_22
	local  postwt="`e(wtype)'"
	local  wt="`e(wtype)'"
	local  we="`e(wexp)'"

	if "`wt'"!="" & regexm("`wt'","p") {
		local wt aw
	}	
	
	if "`postwt'"!="" {
		local postwgt=`"[`postwt'`we']"'
	}
		if "`wt'"!="" {
		local sumwgt=`"[`wt'`we']"'
	}
	di "sum: `sumwgt'"
	di "post: `postwgt'"
	

	if "`eststub'"!="" {
		local peststub eststub(`eststub')
	}
	
	
	if "`eval'"!="" | "`radn'" !="" {
		
		matrix `eststub'_b_orig=e(b)
		matrix `eststub'_v_orig=e(V)
		ereturn matrix `eststub'_b_orig =`eststub'_b_orig, copy
		ereturn matrix `eststub'_v_orig =`eststub'_v_orig, copy			
		
		_crmarginals,		`eval' 	 `peststub' 
		_fvhds97, 			`eval'   `peststub'
		if "`radn'"!="" {
			if `pp'!=1 {
				local ppp pp(`pp')
			}
			_radn,				`eval' `ppp' `divbycons'
		}
		estimates store `eststub'_radn
		
				
		matrix `eststub'_b_creg=e(b)
		matrix `eststub'_v_creg=e(V)
		ereturn matrix `eststub'_b_creg=`eststub'_b_creg, copy
		ereturn matrix `eststub'_v_creg=`eststub'_v_creg, copy
		qui gen byte esample=e(sample)
		
		ereturn post `eststub'_b_creg `eststub'_v_creg `postwgt', noclear depname(`depvar') findomitted esample(esample)
		estimates store `eststub'_creg
		
		
		
	}
	else {
		_fvhds97banner_radn
		qui estimates restore `eststub'_creg
		ereturn display
	}
	
	
	
	

end


capture program drop _crsyntax
program define _crsyntax , eclass 

	local cmd=e(cmdline)
	
	local t1=regexm(`"`cmd'"', "[a-zA-Z0-9|\_]+\#[a-zA-Z0-9|\_]+")
	
	
	
	if `t1'==1 {
		
		di 
		di as error "ERROR:   <creg> cant handle {bf:single} hash (#) operators in regression command line."
		di          "         You must use {bf:double} hash ## in regression for any interactions."
		di
		di          "Cmdline: `cmd'"
		di
		error 198
		exit
	}

	local t2=regexm(`"`cmd'"', "c\.[a-zA-Z0-9|\_]+\#\#c\.[a-zA-Z0-9|\_]+")
	local t3=regexm(`"`cmd'"', "c\.c\_[a-zA-Z0-9|\_]+\#\#c\.c\_[a-zA-Z0-9|\_]+")

	if `t2'==1 & `t3'==0 {
		di 
		di as error "ERROR:   <creg> cant handle polynomials (squares, cubes) of {bf:uncentered} variables."
		di          "         You must center the variable first using Ben Jann's <center> package."
		di         `"         The centererd varname must start with "c_". For example:"'
		di 		   `"         . center age         // this creates a new var "c_age""'
		di 			"         . reg wage c.c_age##c.c_age"
		di 			"         Using c.age only currently does not work"
		di
		di          "Cmdline: `cmd'"
		di
		error 198
		exit
	}

	
	

end


// =======================================================================================================
// =======================================================================================================
// =======================================================================================================


capture program drop _crmarginals
program define _crmarginals , eclass 


syntax [, eval eststub(string)]

if "`eval'"!="" {
	
	capture matrix drop outmean
	

	
	// if pweights used, force aweights for sum
	// Fernando 2022_07_22
	local  postwt="`e(wtype)'"
	local  wt="`e(wtype)'"
	local  we="`e(wexp)'"

	if "`wt'"!="" & regexm("`wt'","p") {
		local wt aw
	}	
	
	if "`postwt'"!="" {
		local postwgt=`"[`postwt'`we']"'
		//di "`sumwgt'"
	}
		if "`wt'"!="" {
		local sumwgt=`"[`wt'`we']"'
		//di "`sumwgt'"
	}
	di "sum: `sumwgt'"
	di "post: `postwgt'"
	
	
	local cmd=e(cmd)
	local depvarname=e(depvar)
	capture drop esample
	qui gen byte esample=e(sample)


	matrix b=e(b)
	matrix v=e(V)
	matrix vorig=e(V)
	
	local n0: colnames b
	//matrix list b
	//di "`n0'"
	scalar nc=colsof(b)
	//di "nc:" nc


	// get main terms
	local mainl
	foreach v of local n0 {
		local t1=regexm("`v'","\#") 
		local t2=regexm("`v'","b\.") 
		
//		if `t1'==0 & `t2'==0 {
		if `t1'==0  {
			//di "`v'"
			local mainl `mainl' `v'
		}
	}


	local wcmt: word count `mainl'
	//di "wcmt `wcmt'"

	scalar wcmt=`wcmt'

	matrix W=J(wcmt,nc,0)
	matrix colnames W = `n0'
	matrix rownames W = `mainl'
	//matrix list W


	// foreach main term, get own unconditional mean
	local x1=0
	foreach m of local mainl {	
		if "`m'"!="_cons" {
			local x1=`x1'+1
			qui sum `m'  `sumwgt' if e(sample)
			scalar mn=r(mean)
			matrix mn=mn
			matrix colnames mn=`m'
			if `x1'==1 {
				matrix outmean=mn
			}
			else {
				matrix outmean=outmean,mn
			}
			local mn=r(mean)
			local u0=subinstr("`m'",".","_",1)
			local mn_`u0' `mn'
			//di "`m' : mn_`u0':  `mn_`u0''"
		}
	}
	local mn__cons 1




	// foreach main term, get associated terms
	local mm=0
	foreach m of local mainl {	
		
		//di "-------------------------------------------------"
		//di "main: `m'"
		local mm=`mm'+1
		scalar mms=`mm'
		
		local vv=0
		foreach v of local n0 {
			//di "v: `v'"
			local vv=`vv'+1
			scalar vvs=`vv'
			
			//local t3=regexm("`v'","`m'")
			
			// Check to see if exact component is there
			local tu5=subinstr("`v'","#"," ",.)
			local tu6: list posof "`m'" in tu5
			local tu7: list posof "c.`m'" in tu5
			
//			if `t3'!=0 {
			if `tu6'!=0 | `tu7'!=0 {
			
				local tt4=regexr("`v'","((`m')+\#)+","")			
				local tt4=regexr("`tt4'","(\#(`m')+)+","")			
				//di "`m' found in `v' at posn `vv' :: `tt4'"
				

				//local tt4a=regexm("`v'","^c\.c\_")
				//di "check  : `tt4a' : `v' : `m'"
				// & !regexm("`v'","^c\.c\_")
				
				//  & !regexm("`v'","^c\.c\_")
		

		
				if "`tt4'"!="" & "`tt4'"!="`m'" & !regexm("`v'","co\.`m'") & !regexm("`tt4'","[0-9]+.`m'") {
					
					//local tt5=subinstr("`tt4'","c.","",1)
					local tt5 `tt4'
					
					// This checks for a c.#i. interaction
					// sum -only- the i. portion, throw away c. portion
					local ts5=regexm("`tt4'", "c\.")
					if `ts5'==1 {
						local tt5=regexr("`tt4'", "\#c\.`m'","")						
					}
					
					
					//di "TT4|5: `tt4' | `tt5'"
				
					
					//local tt5=subinstr("`tt5'",".","_",1)
					//di "tt5: `tt5'"
						qui sum `tt5'  `sumwgt' if e(sample)
						local tt6=r(mean)
						
						local uu:  colfullnames mn
						local mn1: list posof "`tt5'" in uu
						if `mn1'==0 {						
							scalar mn=r(mean)
							matrix mn=mn
							matrix colnames mn= `tt5'
							matrix outmean=outmean,mn
						}
				
					//di "mean (`m') is `tt6'"
					local cp1=W[mms,vvs]
					//if `cp1'==0 {
						matrix W[mms,vvs]=`tt6'
					//}
					//else {
					//	matrix W[mms,vvs]= W[mms,vvs]* `tt6'						
					//}
				
				}
				// This drops the quadratic term in centered variable (zero weight)
			//	else if regexm("`v'","c\.c\_")==1 {
					//di "zero"
					//matrix W[mms,vvs]=0					
			//	}
				else {
					//di "one"
					matrix W[mms,vvs]=1
				}
				//di
			}
		}
	}
	
	matrix list W
	matrix list b
	matrix list v

	// =================================================================================
	// adjusting constant for variables 
	

	matrix 		step3=I(nc)	
	
	local ncon _cons
	local n00: list n0 - ncon

	di
	di 		" centering " _continue
	
	local 		zz=0
	foreach 	v of local n00 {
		di 		" | `v'" _continue
		local 	zz=`zz'+1
		qui sum `v' `sumwgt' if e(sample)
		scalar 	cme=r(mean)
		scalar  zzs=`zz'
		matrix 	step3[nc,zzs]=cme	
	}
	di

	//matrix list b
	//matrix list step3

	matrix b  = step3 * b' 
	matrix b=b'
	matrix v = step3 * v
	matrix v = v * step3'
	
	// =================================================================================

	matrix b2=W*b'
	matrix b2=b2'
	//matrix list b2

	matrix v2=W*v*W'
	//matrix list v2

	//matrix list v2
	//matrix list vorig

	
	

	matrix `eststub'_b_margins=b2
	matrix `eststub'_v_margins=v2
	ereturn matrix `eststub'_b_margins =`eststub'_b_margins, copy
	ereturn matrix `eststub'_v_margins =`eststub'_v_margins, copy

	ereturn local cmd crmarginals
	ereturn matrix margmeans  = outmean, copy
	
	
	ereturn post b2 v2 `postwgt', noclear  depname(`depvar') findomitted esample(esample)
	
	qui estimates store `eststub'_crmarg
	
	di
	di "{dlgtab 0 2:Center Marginals}" 
	di
	
	ereturn display

}
else {
	di
	di "{dlgtab 0 2:Center Marginals}" 
	di
	ereturn display
}

end






capture program drop _fvhds97banner
program define _fvhds97banner

	display " "
	display " Restricted Least Squares for Dummy Variable Sets (Stata Factor Variables)" 
	display " "
	display " Authors     "  `": {browse "mailto:johnhd@unimelb.edu":Prof Dr John P. de New} and {browse "mailto:Christoph.Schmidt@rwi-essen.de":Prof Dr Christoph M. Schmidt}"'
	display "               Version: 22 Dec 2021 "  
	display ""
	display " Citation    "  ": Haisken-DeNew, J.P. and Schmidt C.M. (1997):"
	display "               " _char(034) "Interindustry and Interregion Wage Differentials:"
	display "               Mechanics and Interpretation," _char(034) " Review of Economics
	display "               and Statistics, 79(3), 516-521. "  `"{browse "https://www.mitpressjournals.org/doi/pdf/10.1162/rest.1997.79.3.516":REStat Reprint}"'
	display " "	

end


// =============================================================================

capture program drop _fvhds97footer
program define _fvhds97footer


di ""
di " Sampling-Error-Corrected Standard Deviation of Differentials"
di " Joint test of all coefficients in dummy variable set = 0, Prob > F = p"

di in green "{dup 21:{c -}}{c TT}{dup 56:{c -}}"
foreach x in `e(allfactors)'  {

        di in green %20s ("`x'")  _continue
        di _col(22) "{c |}  "  _continue
        di in yellow %-14.6f (`e(`x'_sd)') _continue

        di in green "F(`e(`x'_df)',`e(`x'_dfr)') = " in yellow %-10.2f (`e(`x'_f)') in green _col(64) " p=" in yellow %-7.4f (`e(`x'_p)') in green ""


}
di in green "{dup 21:{c -}}{c BT}{dup 56:{c -}}"

end



// =============================================================================

capture program drop _fvhds97
program define _fvhds97 , eclass 


version 11

syntax [anything] [, eval eststub(string) ]


/*
capture local hds97=`e(hds97)'
if "`hds97'"=="1" {
	local cmd `e(cmd)'
	fvhds97banner
	`cmd'
	fvhds97footer
	
	exit
}
*/

if "`eval'"!="" {

	// check for weights used in the regression
	// will want to use same weights for dummy means


	matrix margmeans=e(margmeans)	
	
	// if pweights used, force aweights for sum
	// Fernando 2022_07_22
	local  postwt="`e(wtype)'"
	local  wt="`e(wtype)'"
	local  we="`e(wexp)'"

	if "`wt'"!="" & regexm("`wt'","p") {
		local wt aw
	}	
	
	if "`postwt'"!="" {
		local postwgt=`"[`postwt'`we']"'
		//di "`sumwgt'"
	}
		if "`wt'"!="" {
		local sumwgt=`"[`wt'`we']"'
		//di "`sumwgt'"
	}
	di "sum: `sumwgt'"
	di "post: `postwgt'"
	


	local dv `e(depvar)'
	local n=e(N)



	local n = _result(1)
	matrix   b = e(b)
	scalar cc=colsof(b)

	matrix vc = e(V)

	//di cc
	matrix mega=I(cc)
	//matrix list mega
	matrix megam=J(1,cc,0)


	local bnames : colnames b
	local c: word count `bnames'
	// di "bnames: `bnames'"

	local allv
	foreach v of local bnames {
		local vv=regexr("`v'","b\.",".")
		local vvv=regexr("`vv'","^[0-9]+\.","")
		local allv `allv' `vvv'
	}
	local allv: list sort allv
	local allv: list uniq allv
	//di "unique vars: `allv'"

	local cexists: list posof "_cons" in allv

	local vnames

	local allfactors

	local base
	foreach v of local allv {

		if "`v'"=="_cons" {
			continue
		}

		//di
		//di "`v'"
		local z1=0
		local allhits
		foreach vv of local bnames {
			//di "vv:`vv'"
			local z1=`z1'+1
			local hit=regexm("`vv'","\.`v'")
			if `hit'==1 {
				local allhits `allhits' `z1'
				local `v'vars ``v'vars'  `vv'
			}
		}
		//di "cols: `allhits'"
		
		
		
		if "`allhits'"!="" {
			

			/* ========== F-test statistics: groupwise significance ======================= */
			quietly test ``v'vars'

			local f_`v'		= r(F)
			local df_`v'	= r(df) 
			local dfr_`v'	= r(df_r) 
			local p_`v'		= r(p)
			
			ereturn scalar `v'_f	 = `f_`v''		
			ereturn scalar `v'_df	 = `df_`v''		
			ereturn scalar `v'_dfr	 = `dfr_`v''		
			ereturn scalar `v'_p	 = `p_`v''		
			
			
			local allfactors `allfactors' `v'
			
			local cnt: word count `allhits'
			local cb: word 1 of `allhits'
			local ce: word `cnt' of `allhits'

			scalar scb=`cb'
			scalar sce=`ce'
			scalar scn=`cnt'
			

			local `v'allhits `allhits'
			local `v'beg `cb'
			local `v'end `ce'
			local `v'cnt `cnt'
			
			
			//di  "`v'allhits: ``v'allhits'"

			
			
			// create the means vector
			local f=0
			foreach h of local allhits {

				local f=`f'+1
				local v3: word `h' of `bnames'
				//di "var: `v3'"

				local vvv1=regexm("`v3'","^[0-9]+[b]+\.`v'")
				
				local vvv2=regexm("`v3'","^[0-9]+\.`v'")
				if `vvv1'==1|`vvv2==1' {
					local vvv2=regexr("`v3'","[b]+\.",".")
					// ensure using same weights as in regression and 
					// also same sample for calculating weights
					qui sum `vvv2' `sumwgt' if e(sample)
					scalar me=r(mean)

					if `vvv1'==1 {
						local base `base' `h' 
					}	
				}
				else {
					scalar me=1
				}
				if `f'==1 {
					matrix mtot=me
				}
				else {
					matrix mtot=mtot, me
				}

			}
			
			
			// create the weighting matrix
			//matrix list mtot
			matrix mref = J(scn,1,1)
			//matrix list mref
			matrix mref = mref * mtot
			//matrix list mref
			matrix mref1 = I(scn)
			//matrix list mref1
			matrix wmat = mref1-mref
			//matrix list wmat
			
			// inject sub weighting matrix into mega weighting matrix
			matrix mega[scb,scb]=wmat
			// inject sub weights into full weights vector
			matrix megam[1,scb]=mtot	
			
		}

	}	

	// inject mean of 1 for constant into last element of mean vector
	matrix megam[1,cc]=1	

	// now put the group means back into the constant
	matrix step2=I(cc)
	/*
	foreach v of local base {
		matrix step2[`v',cc]=-1
	}
	*/

	//matrix list step2
	//di
	//di
	//di "base: `base'"

	// now have full weighting matrix
	matrix wmat=mega

	//matrix wmat[`base',scb]=`basemean'
	//matrix wmat[scb,`base']=`basemean'
	


	// weight the beta vector: pre and post multiply
	matrix bhds  = wmat * b' 
	if `cexists'>0 {
		matrix bhds  = bhds' * step2
	}
	else {
		matrix bhds  = bhds' 
	}

	// remove the base indicator
	/*
	local bnames1 `bnames'
	loca bnames
	foreach bn of local bnames1 {
		local bn=regexr("`bn'","b\.",".")
		local bnames `bnames' `bn'
		//di "`bn'"
	}
	//di "`bnames'"
	*/
*/
	// add variable names to the beta vector
	matrix colnames bhds = `bnames'


	// pre and post multiply the VC with the weighting matrix
	// pre and post multiply that with the linear combination of putting set means back into constant

	
	if `cexists'>0 {
//		matrix vchds = step2' * wmat * vc
//		matrix vchds = vchds * wmat' * step2
		matrix vchds = wmat * vc
		matrix vchds = vchds * wmat'
	}
	else {
		matrix vchds = wmat * vc
		matrix vchds = vchds * wmat'
	}


	// add variable names to the VC matrix
	matrix colnames vchds = `bnames'
	matrix rownames vchds = `bnames'

	ereturn scalar hds97=1 
	local cmd `e(cmd)'
	local depvar `e(depvar)'

	matrix bhds1=bhds
	matrix vchds1=vchds

	//ereturn matrix b=bhds 
	//ereturn matrix vc=vchds 



	local all_sd
	foreach v of local allfactors {

	//		di "`v'"
	//		local `v'allhits `allhits'
	//		local `v'beg `cb'
	//		local `v'end `ce'
	//		local `v'cnt `cnt'
			

			matrix bhds1   = bhds[1,``v'beg'..``v'end']
			matrix vchds1  = vchds[``v'beg'..``v'end',``v'beg'..``v'end']
			matrix mtot1   = megam[1,``v'beg'..``v'end']
			
			matrix bhds2   = diag(bhds1) 
			matrix bd2a    = mtot1 * bhds2
			matrix bd2     = bd2a  * bhds1'
			matrix vchds1  = vecdiag(vchds1)
			matrix vchds2  = mtot1 * vchds1'
			matrix wsbeta  = bd2 - vchds2
			scalar wsbetas = trace(wsbeta)
			scalar wsbetas = sqrt(wsbetas)


			local  wsbetas_`v' = 0
			local  wsbetas_`v' = wsbetas
			if "`wsbetas_`v''"=="." {
			  local wsbetas_`v' 0.0000000000
			}	
			//di "wsbetas_`v': `wsbetas_`v''"
			
			local all_sd `all_sd' `v'_sd
		
			ereturn scalar `v'_sd = `wsbetas_`v''
	}

	local all_sd: list sort all_sd
	local allfactors: list sort allfactors

	//ereturn local allfactors = "`allfactors'"
	//ereturn local all_sd     = "`all_sd'"


	ereturn local allfactors `allfactors'
	ereturn local all_sd     `all_sd'


	//matrix bhds1=bhds
	//matrix vchds1=vchds

	//matrix b=bhds1
	//matrix V=vchds1

	//matrix post b V, depname(`dv') obs(`n')
	
	

	matrix `eststub'_b_hds97=bhds
	matrix `eststub'_v_hds97=vchds
	ereturn matrix `eststub'_b_hds97 =`eststub'_b_hds97, copy
	ereturn matrix `eststub'_v_hds97 =`eststub'_v_hds97, copy	
	
	ereturn matrix margmeans  = margmeans, copy
	
	ereturn repost b=bhds V=vchds `postwgt' ,  findomitted 
	estimates store `eststub'_hds97

}
	
	di
	di
	di "{dlgtab 0 2:Dummies now Deviations from Weighted Average}" 
	di

	_fvhds97banner
	ereturn display
	_fvhds97footer


	


end


	


capture program drop _fvhds97banner_radn
program define _fvhds97banner_radn

syntax [, divbycons]


		display " "
		display " "
		display " Idea        : Interpreting RIFreg regressions: RIF = v(F) + IF " 
		display " "
		display " Authors     "  `": {browse "mailto:friosavi@levy.org":Dr Fernando Rios-Avila} and {browse "mailto:johnhd@unimelb.edu":Prof Dr John P. de New}"'
		display "               Version: 22 Dec 2021 "  
		display ""
		display " Citation    "  ": Fernando Rios-Avila, and de New, J.P. (2021):"
		display "               " _char(034) `"Interpreting RIFreg regressions", mimeo."'
		display ""
		display "             "  ": Haisken-DeNew, J.P. and Schmidt C.M. (1997):"
		display "               " _char(034) "Interindustry and Interregion Wage Differentials:"
		display "               Mechanics and Interpretation," _char(034) " Review of Economics
		display "               and Statistics, 79(3), 516-521. "  `"{browse "https://www.mitpressjournals.org/doi/pdf/10.1162/rest.1997.79.3.516":REStat Reprint}"'
		display ""
		display " Interpret   "  ": Dummy:      a `e(radn_pp)' percentage-point increase in dummy share"
		display "             "  "  Continuous: a 1 unit increase in centered variable"
		display "             "  "  Constant:   functional statistic, unconditional mean of LHS"
	if "`divbycons'" !="" {

		display "             "  "  RHS coeffs: all are divided by _b[_cons] via nlcom."
		
	}
 display ""

end


// =======================================================================================================
// =======================================================================================================
// =======================================================================================================


capture program drop _radn
program define _radn , eclass 


version 11

syntax [anything] [, eval pp(integer 1) radn eststub(string) divbycons ]



if "`eval'"!="" {





// =============================================================================
//	Deal with "radn"
//	Part 1: Make adjustments for 1 unit (contin) and 1*`pp' percentage point (dummy)
// =============================================================================


	matrix margmeans=e(margmeans)


	// if pweights used, force aweights for sum
	// Fernando 2022_07_22
	local  postwt="`e(wtype)'"
	local  wt="`e(wtype)'"
	local  we="`e(wexp)'"

	if "`wt'"!="" & regexm("`wt'","p") {
		local wt aw
	}	
	
	if "`postwt'"!="" {
		local postwgt=`"[`postwt'`we']"'
		//di "`sumwgt'"
	}
		if "`wt'"!="" {
		local sumwgt=`"[`wt'`we']"'
		//di "`sumwgt'"
	}
	di "sum: `sumwgt'"
	di "post: `postwgt'"
	
	
	
	
	

	matrix bme=e(b)
	matrix vme=e(V)
	local  bnames : colnames bme
	
	capture drop esample
	gen esample=e(sample)

	// di "bnames: `bnames'"
	
	// create the means vector
	local f=0
	foreach h of local bnames {

		local f=`f'+1
		//di "var: `v3'"

		// identify dummy coefficients
		local vvv1=regexm("`h'","^[0-9]+[b]+[n]*\.")
		local vvv2=regexm("`h'","^[0-9]+\.")

		if `vvv1'==1|`vvv2==1' {
			local vvv2=regexr("`h'","[b]+[n]*\.",".")
			
			
			foreach fin of local fint {
				local vvv2=regexr("`vvv2'","\.`fin'\_",".")
			}
			
			// ensure using same weights as in regression and 
			// also same sample for calculating weights
				
			
			//di "qui sum `vvv2' `sumwgt' if e(sample)"
			qui sum `vvv2' `sumwgt' if e(sample)
			scalar me=r(mean)
			//di "sum  `vvv2' "
			//di %15.12f me
			
			// fernando: 1 minus share
//			scalar me0=100*(1-me)
//			scalar me1=1/me0
//			scalar me1=me1*`pp'

			scalar me1=1/((1-me)*100)
			scalar me1=me1*`pp'


		}
		else {
			//di "no dummy"
			scalar me1=1
		}
		
	//	di
	//	di "`h'"
	//	di me
	//	di me1
		
		if `f'==1 {
			matrix mradn=me1

		}
		else {
			matrix mradn=mradn, me1
		}

	}


	//di "bnames: `bnames'"
	//matrix list bme

	//matrix list bme
	
	matrix mradn = diag(mradn)
	matrix bradn = mradn * bme' 
	matrix bradn = bradn'
	
	//matrix list bradn

	matrix vradn = mradn * vme * mradn'
	
	local bnames=subinstr("`bnames'","bn.",".",.)	
	
	matrix colnames mradn = `bnames'
	matrix colnames bradn = `bnames'
	matrix colnames vradn = `bnames'
	matrix rownames vradn = `bnames'	
	
	matrix factradn=vecdiag(mradn)
	//matrix list factradn
	
	ereturn matrix factradn=factradn, copy
	
	
	// Now need to divide be _b[_cons]
	// must do this with nlcom

	//matrix list bradn

	if "`divbycons'" !="" {
	
	
		// =============================================================================
		//	Deal with "radn"
		//	Part 2: Divide all coeffs by _b[_cons] except _cons using NLCOM
		// =============================================================================

		
		matrix b=bradn
		matrix v=vradn
		
		
		ereturn post bradn vradn, noclear depname(`depvar') findomitted esample(esample)


		gen esample=e(sample)
		matrix factradn=e(factradn)

		matrix colnames b = `bnames'
		matrix colnames v = `bnames'
		matrix rownames v = `bnames'



		
		// collect all nlcom components
		// must rename rox col names do deal with leading 0's etc on dummies
		local nam: colnames b
		local namc _cons
		local con=_b[_cons]
		local nam: list nam - namc
		local nlc
		foreach na of local nam {
			local na2=regexr("`na'","b\.",".")
			local na3=regexr("`na2'","\.","_")
			local na3 _`na3'
			local nlc `nlc' (`na3':_b[`na']/_b[_cons])
		}
	//	local nlc `nlc' (_cons:_b[_cons]/1)
		local nlc `nlc' (_cons:_b[_cons])
		
		// add back _cons to name vector
		local nam `nam' _cons
		
		//di "nlc: `nlc'"
		

		// NOTE: capture output as r() and NOT e()
		// inject orig row and col names back into b, V
		qui nlcom `nlc'
		matrix nlb=r(b)
		matrix nlv=r(V)
		matrix colnames nlb = `nam'
		matrix colnames nlv = `nam'
		matrix rownames nlv = `nam'
		
		//matrix list nlb
		
		ereturn matrix factradn=factradn, copy
		ereturn local radn_pp =`pp'

		
		matrix `eststub'_b_radn=nlb
		matrix `eststub'_v_radn=nlv
		ereturn matrix `eststub'_b_radn=`eststub'_b_radn, copy
		ereturn matrix `eststub'_v_radn=`eststub'_v_radn, copy

	//	ereturn local divcon=1
	//	ereturn repost b=nlb V=nlv , findomitted
		ereturn post nlb nlv `postwgt', noclear  depname(`depvar') findomitted esample(esample)
		
		di
		di
		di "{dlgtab 0 2:Simulation +`pp'%-point and +1 unit Continuous; Divide by Constant}" 

		
	}
	else {
		matrix `eststub'_b_radn=bradn
		matrix `eststub'_v_radn=vradn
		ereturn matrix `eststub'_b_radn=`eststub'_b_radn, copy
		ereturn matrix `eststub'_v_radn=`eststub'_v_radn, copy
		ereturn matrix margmeans  = margmeans, copy
			
		ereturn post bradn vradn `postwgt', noclear  depname(`depvar') findomitted esample(esample)
		
		di
		di
		di "{dlgtab 0 2:Simulation `pp' %-point and 1 unit Continuous}" 
	}
	
	

		
	estimates store `eststub'_radn

	_fvhds97banner_radn,	 `divbycons'
	
	
	
	
	ereturn display

	// di "Estimates: {stata estimates replay `eststub'_orig:`eststub'_orig} | {stata estimates replay `eststub'_hds97:`eststub'_hds97} | {stata _cregd, estimates(`eststub'_hds97me):`eststub'_hds97me} | {stata _cregd, estimates(`eststub'_radn):`eststub'_radn}"

//	local estrg `estrg' | {stata _cregd, estimates(`eststub'_radn):`eststub'_radn}
//	di " `estrg'"

}
	
	


//estimates dir

end


