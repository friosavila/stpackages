// =============================================================================
//  John de New : Restricted Least Squares for Dummy Vatiables
//  Version: May 30, 2020	Email: johnhd@unimelb.edu.au
// =============================================================================

capture program drop fvhds97banner
program define fvhds97banner

	display " "
	display " Restricted Least Squares for Dummy Variable Sets (Stata Factor Variables)" 
	display " "
	display " Authors     "  `": {browse "mailto:johnhd@unimelb.edu":Prof Dr John P. de New} and {browse "mailto:Christoph.Schmidt@rwi-essen.de":Prof Dr Christoph M. Schmidt}"'
	display "               Version: 30 May 2020 "  
	display ""
	display " Citation    "  ": Haisken-DeNew, J.P. and Schmidt C.M. (1997):"
	display "               " _char(034) "Interindustry and Interregion Wage Differentials:"
	display "               Mechanics and Interpretation," _char(034) " Review of Economics
	display "               and Statistics, 79(3), 516-521. "  `"{browse "https://www.mitpressjournals.org/doi/pdf/10.1162/rest.1997.79.3.516":REStat Reprint}"'
	display " "	

end


// =============================================================================

capture program drop fvhds97footer
program define fvhds97footer


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

capture program drop fvhds97
program define fvhds97 , eclass 


version 11

// syntax [anything], [pp(real 1)]
syntax , [pp(integer 100)]



capture local hds97=`e(hds97)'
if "`hds97'"=="1" {
	local cmd `e(cmd)'
	fvhds97banner
	`cmd'
	fvhds97footer
	
	exit
}


// check for weights used in the regression
// will want to use same weights for dummy means

local  wt="`e(wtype)'"
local  we="`e(wexp)'"

if "`wt'"!="" {
	local sumwgt=`"[`wt'`we']"'
	di "`sumwgt'"
}
/*
  e(wexp) : "= weight"
  e(wtype) : "iweight"
*/


local dv `e(depvar)'
local n=e(N)



local n = _result(1)
matrix   b = e(b)
scalar cc=colsof(b)

matrix vc = e(V)

//di cc
matrix mega=I(cc)
matrix megarest=I(cc)

//matrix list mega
matrix megam=J(1,cc,0)
matrix megamrest=J(1,cc,0)


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
				// fernando: 1 minus share
				scalar me0=100*(1-me)
				scalar me1=1/me0
				scalar me1=me1*`pp'

				if `vvv1'==1 {
					local base `base' `h' 
				}	
			}
			else {
				scalar me=1
			}
			if `f'==1 {
				matrix mtot=me
				// fernando
				matrix mtrest=me1
			}
			else {
				matrix mtot=mtot, me
				// fernando
				matrix mtrest=mtrest,me1
			}

		}
		
		
		// create the weighting matrix
		//matrix list mtot
		matrix mref = J(scn,1,1)
		//matrix list mref

		// fernando: 1-mean on diag
		matrix mtrest0=mtrest
		matrix mtrest = diag(mtrest)

		matrix mref = mref * mtot
		//matrix list mref
		matrix mref1 = I(scn)
		//matrix list mref1
		matrix wmat = mref1-mref
		//matrix list wmat
		
		// inject sub weighting matrix into mega weighting matrix
		matrix mega[scb,scb]=wmat
		// fernando
		matrix megarest[scb,scb]=mtrest
		// inject sub weights into full weights vector
		matrix megam[1,scb]=mtot	
		// fernando
		matrix megamrest[1,scb]=mtrest0	
		
	}

}	

// inject mean of 1 for constant into last element of mean vector
matrix megam[1,cc]=1	
matrix megamrest[1,cc]=1	

// now put the group means back into the constant
matrix step2=I(cc)
foreach v of local base {
	matrix step2[`v',cc]=-1
}

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


// add variable names to the beta vector
matrix colnames bhds = `bnames'


// pre and post multiply the VC with the weighting matrix
// pre and post multiply that with the linear combination of putting set means back into constant

if `cexists'>0 {
	matrix vchds = step2' * wmat * vc
	matrix vchds = vchds * wmat' * step2
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

estimates store _orig
ereturn repost b=bhds V=vchds 
estimates store _hds97

fvhds97banner
`cmd'
fvhds97footer
di "Estimates: {stata estimates replay _orig:_orig} | {stata estimates replay _hds97:_hds97}"


// fernando
if `pp'!=100 {

	matrix b=e(b)
	matrix v=e(V)

	matrix bradn= b * megarest 
	matrix vradn= megarest * v * megarest'
	
	// ereturn 
	ereturn matrix hds97_b = b
	ereturn matrix hds97_v = v
	ereturn matrix radn_`pp'pp = megarest
	ereturn scalar radn_pp = `pp'
	
	ereturn repost b=bradn V=vradn 
	estimates store _radn

		display " "
		display " "
		display " Interpreting RIFreg regressions: RIF = v(F) + IF " 
		display " "
		display " Authors     "  `": {browse "mailto:friosavi@levy.org":Dr Fernando Rios-Avila} and {browse "mailto:johnhd@unimelb.edu":Prof Dr John P. de New}"'
		display "               Version: 07 Oct 2021 "  
		display ""
		display " Citation    "  ": Fernando Rios-Avila, and de New, J.P. (2021):"
		display "               " _char(034) "Interpreting RIFreg regressions, mimeo. "
		display ""
		display " Interpret   "  ": Dummy:      a `pp' percentage-point increase in dummy share"
		display "             "  "  Continuous: a 1 unit increase in centered variable"
		display "             "  "  Constant:   functional statistic, after rifhdreg"
		display ""


	`cmd'
	
	di "Estimates: {stata estimates replay _orig:_orig} | {stata estimates replay _hds97:_hds97} | {stata estimates replay _radn:_radn}"

}

//estimates dir

end


	

	