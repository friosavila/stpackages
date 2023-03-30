*!version 2.34 April  2020 Fernando Rios Avila
* added alert for Robust standard errors. 
* Note to myself: How to add info about Cluster? and allow for NO SE?
* version 2.33 April  2020 Fernando Rios Avila
* Eliminated  minor inneficiencies
* version 2.32 Feb  2020 Fernando Rios Avila
* Corrected small error with markout and parsing
* version 2.31 Feb  2020 Fernando Rios Avila
* Improvement in sample definition. Use markout rather than manual.
* version 2.3 November 2019 Fernando Rios Avila
* This version adds some programs from "oaxaca" to do parsing and avoid problems when using  noisily option
* version 2.2 July 2019  Author Fernando Rios Avila
* Added s2var To easily add deviation respect to the mean as another explanatory variable. May think about adding interactions too, but not for now
* also added back noisily to show all intermediate results
* version 2.1 April 2019  Author Fernando Rios Avila
*This version alows for the use of iseed. This helps to obtain replicable rank dependent indices.
* version 2.0 march 2019
* Allows to use the options Relax and noisily from oaxaca. May change to only allow for specific options, but will leave it like this for now
* added option for scale and retain.
* version 1.0 Jan 2019
* This is a program that can be used as a "mask" for Oaxaca, allowing to do RIF recomposition
* Various RIF decompositions are available. More than just RIFREG
* Correction to output table regarding Reweight error.
*capture program drop oaxaca_rif
program oaxaca_rif, eclass sortpreserve byable(recall)  properties( svyb )
    if replay() {
        display_ob
        exit
    }
   version 12.0
   syntax anything [if] [in] [aw fw iw pw] , by(varname) rif(string)  ///
						[ swp swap Weights(str) rwlogit(str) rwprobit(str) wgt(int -1) cluster(varname) ///
								relax Noisily scale(real 1.0) retain(str) replace iseed(str) s2var(varlist) nose]
   *iseed undocumented. The idea is to make some indices reproducible
	/*if c(stata_version)>=16 {
		local fv fv
		this is to try making it FV but problems with a bug
	}98*/
 
	
	tokenize `anything'
	local y `1'
	//get the rest of the vars
	macro shift
	local rest `*'
	
	final_parsing `rest'
	local rest2 `r(xvars)'
	*display in w "`rest2'"
	marksample touse
	markout `touse' `y' `rest2' `by' `cluster' `rwprobit'  `rwlogit' `s2var'
	
	****Here we identify GROUPs
	qui:levelsof `by' if `touse', local(idf)
	foreach i of local idf {
	   local nx=`nx'+1
	   local g`nx'=`i'
	   if `nx'>2 {
			display "More than 2 groups in `by' identified. Only 2 groups can be used"
			exit
	   }
	}
	
	** Get weights
    if "`weight'" == "" {
	 tempvar eweight
         gen `eweight' = 1.0
         local weight "aweight"
         local exp `eweight'
		 local erweight 1
     }
    else {
		local exp = regexr("`exp'", "= ", "")
	    local erweight `exp'
	 	}
	 
 
    //get the weight expression without '=' sign
    local exp_no_eq = regexr("`exp'", "=", "")
	*** This is to check if weights was called isntead of WGT
	if "`weights'"!="" {
	local wgt=`weights'
	local weights=""
	}
	*** This should check if cf is 0 or 1, or use the default 0
    
	if "`wgt'"=="-1" {
	display "No wgt specified. Using default 0"
	local wgt = "0"
	}
 
	if "`wgt'"!="0" & "`wgt'"!="1" {
	display "For Weighted Oaxaca, one can only use w=1 or w=0"
	exit 
	} 
	****
	if "`rwlogit'"!="" & "`rwprobit'"!="" {
	display "Only one probability model can be set. Choose either Logit or probit for the first stage"
	exit
	}
    ****
	if "`rwlogit'"=="" & "`rwprobit'"=="" {
	display "No Reweighted Strategy Choosen"
	local type="Standard"
	}
	else {
	local type="Reweighted"
	}
	***
	* checking for swap
	if "`swap'"!="" {
	    local swap=""
		local swp="swp"
	}
	
	** obtaining rivfar if retain
	    * this is "cheating" for creating the data			
	if "`retain'"!="" {
	tempvar rifretain
		qui:egen `rifretain'=rifvar(`y') if `touse', `rif' weight(`exp') by(`by')
		if "`replace'"!="" {
			capture:gen double `retain'=`rifretain'
			capture:replace    `retain'=`rifretain'
			local vnm:variable label `rifretain'
			label var `retain' "`vnm'"
		}
		else {
			gen double `retain'=`rifretain'
			local vnm:variable label `rifretain'
			label var `retain' "`vnm'"
		}
	}
	
	display "Estimating `type' RIF-OAXACA using RIF:`rif'"
	
	
	*** Option 1. Standard oaxaca
	if "`type'"=="Standard" {
	preserve
	    if "`swp'"!="" {
		replace `by'=-`by'
		 local gx=`g1'
		 local g1=`g2'
		 local g2=`gx'
		}
		************************************************************
 		tempvar rif_var
 		qui: egen `rif_var'=rifvar(`y') if `touse'==1, `rif' weight(`exp') by(`by') seed(`iseed')
		qui: replace `rif_var'=`rif_var'*`scale'
		 
		
		*** this is a new option s2var(str) The idea is to add the "variance" as another component to the decomposition.
		foreach i of local s2var {
			qui: egen _s2_`i'=rifvar(`i') if `touse'==1, var weight(`exp') by(`by') seed(`iseed')
			local re `re' _s2_`i'
		}
		
 		** simple way to create the noisily result
		if "`noisily'"!="" {
		  local cnt=0
		  qui:levelsof `by', local(grps)
		  foreach i of local grps {
		    local cnt=`cnt'+1
		    if `cnt'==1 display in w "RIF regression group 1"
			if `cnt'==2 display in w "RIF regression group 2"
			rifhdreg `y' `rest2' `re' [`weight'=`exp'] if `touse'==1 & `by'==`i',  robust cluster(`cluster') rif(`rif') iseed(`iseed')
			tempname bf`cnt'  Vf`cnt'
			matrix `bf`cnt''=e(b)
			matrix `Vf`cnt''=e(V)
		   }	
		}
		  
		*qui:reg `re' if `touse'==1
		qui:`fv'oaxaca `rif_var' `rest' `re' [`weight'=`exp'] if `touse'==1,   by(`by') w(`wgt') robust cluster(`cluster') `relax'  `se'
 		drop `rif_var'
		local lgd "" `e(legend)'  ""
		tempname b V
		matrix `b'=e(b)
		if "`se'"==""		matrix `V'=e(V)
		if `wgt'==0 {
			local gc = "x1*b2"
		}
		if `wgt'==1 {
			local gc = "x2*b1"
		}
		local N1=e(N_1)
		local N2=e(N_2)
		
		*************************************************************
	restore
	}
	
	if "`type'"=="Reweighted" {
	************************************************************
	preserve
		qui:keep if `touse'==1
		if "`swp'"!="" {
		 qui:replace `by'=-`by'
		 local gx=`g1'
		 local g1=`g2'
		 local g2=`gx'
		}
		** For this application, we need to duplicate One of the groups, to create the counterfactual.
		qui:levelsof `by' if `touse'==1, local(grps)
		tempvar dy
		qui:egen `dy'=group(`by') if `touse'
		qui:sum `dy' if `touse', meanonly
		***
		if r(max)>2 {
		  display "More than 2 groups detected. Only 2 groups allowed for reweighted OAXACA"
		  exit
		}
		qui:replace `dy'=`dy'==2
		
		** Here we do the probit/logit regression
		if "`rwprobit'"!="" {
			qui: `noisily' probit `dy' `rwprobit' [pw=`exp'] if `touse'==1
			tempvar pr
			qui:predict double `pr', pr
			tempname b_rw v_rw
			matrix `b_rw'=e(b)
			matrix `v_rw'=e(V)
			local rwmodel="probit"
		}
		if "`rwlogit'"!="" {
			qui: `noisily' logit `dy' `rwlogit' [pw=`exp'] if `touse'==1
			tempvar pr
			qui:predict double `pr', pr
			tempname b_rw v_rw
			matrix `b_rw'=e(b)
			matrix `v_rw'=e(V)
			local rwmodel="logit"
		}
		
		*** Here we will expand the data according to W and create new groups
		*** and create the IPW weights
				
		if `wgt'==0 {
		 * display "Counterfactual: group_2 reweighted to group_1 characteristics"
		  tempvar id id2 ord
		  qui:gen `id'=_n
		  qui:expand 2 if `dy'==1
		  qui:gen `id2'=_n
		  qui:gen byte `ord'=1+(`id'!=`id2')
		  tempvar ddy
		  qui:gen  byte   `ddy'=1 if `dy'==0
		  qui:replace `ddy'=3 if `dy'==1 
		  qui:replace `ddy'=2 if `dy'==1 & `ord'==1
		  
		  tempvar ipw
		  qui:gen double `ipw'=1 if `ddy'==1 |  `ddy'==3 
		  qui:replace `ipw'=(1-`pr')/`pr' if  `ddy'==2
 		  local gc="X2~>rw~>X1 or x1*b2"
		}
		
		if `wgt'==1 {
		 * display "Counterfactual: group_1 reweighted to group_2 characteristics"
		  tempvar id id2 ord
		  qui:gen `id'=_n
		  qui:expand 2 if `dy'==0
		  qui:gen `id2'=_n
		  qui:gen byte `ord'=1+(`id'!=`id2')
		  tempvar ddy
		  qui:gen  byte   `ddy'=1 if `dy'==0
		  qui:replace `ddy'=3 if `dy'==1
		  qui:replace `ddy'=2 if `dy'==0 & `ord'==1
		  tempvar ipw
		  qui:gen double `ipw'=1 if `ddy'==1 |  `ddy'==3 
		  qui: replace `ipw'=`pr'/(1-`pr') if `ddy'==2
 		  local gc="X1~>rw~>X2 or x2*b1"
		}
		
		/*qui:compress NOT NEEDED Just takes time*/ 
		** Here we create the RIFs using RIFreg for three groups. group 2 its the Counterfactual.
        tempvar rifvar
		tempvar wexp
		qui:gen double `wexp'=`exp'*`ipw'
 		qui:egen `rifvar'=rifvar(`y') if `touse', `rif' weight(`wexp') by(`ddy') seed(`iseed')
		
		** Rescaling
		if "`scale'"!="1"  qui:replace `rifvar'=`rifvar'*`scale'
		
        ** Here we do the actual OB decomposition: 
 	
		*** this is a new option s2var(str) The idea is to add the "variance" as another component to the decomposition.
		foreach i of local s2var {
			qui: egen _s2_`i'=rifvar(`i') if `touse'==1, var weight(`wexp') by(`ddy') seed(`iseed')
			local re `re' _s2_`i'
		}
			
		if "`cluster'"!="" 	local idcluster `cluster'
		else 				local idcluster `id'
		
		if "`noisily'"!="" {
		  local cnt=0
		  qui:levelsof `ddy', local(grps)
		  foreach i of local grps {
			local cnt=`cnt'+1
		    if `cnt'==1   display in w "RIF regression group 1"
			else if `cnt'==2   display in w "RIF regression counterfactual group"
			else if `cnt'==3   display in w "RIF regression group 2"
			rifhdreg `y' `rest2' `re' [`weight'=`exp'*`ipw'] if `touse'==1 & `ddy'==`i',  robust cluster(`cluster') rif(`rif') iseed(`iseed')
			tempname bf`cnt'  Vf`cnt'
			matrix `bf`cnt''=e(b)
			matrix `Vf`cnt''=e(V)
		   }	
		}
		** re is the created s2var
		qui:`fv'oaxaca `rifvar' `rest'  `re' [aw=`exp'*`ipw'] if `touse'==1 & (`ddy'==1 | `ddy'==3),   by(`ddy') w(`wgt') nodetail robust cluster(`idcluster')  `relax'   `se'
		tempname b0 v0 bb vb bx vx bc vc
        matrix `b0'=e(b)
        matrix `v0'=e(V)  
		if `wgt'==0 { 
		   ** Delta B
	 		qui:`fv'oaxaca `rifvar' `rest'  `re' [aw=`exp'*`ipw'] if `touse'==1 & inlist(`ddy',1,2),   by(`ddy') w(0) cluster(`idcluster')   `relax'   `se'
			matrix `bb'=e(b)
			matrix `vb'=e(V)
		   ** Delta x
			qui:`fv'oaxaca `rifvar' `rest'  `re' [aw=`exp'*`ipw'] if `touse'==1 & inlist(`ddy',2,3),   by(`ddy') w(0) cluster(`idcluster')   `relax'  `se'
			matrix `bx'=e(b)
			matrix `vx'=e(V)
			local lgd "" `e(legend)'  ""
			
			matrix `bc'=`bx'[1,1]
			matrix `vc'=`vx'[1,1]
			}
		if `wgt'==1 {
		   ** Delta X
			qui:`fv'oaxaca `rifvar' `rest'  `re' [aw=`exp'*`ipw'] if `touse'==1 & inlist(`ddy',1,2),   by(`ddy') w(1) cluster(`idcluster') `relax'   `se'
			matrix `bx'=e(b)
			matrix `vx'=e(V)
		   ** Delta B
			qui:`fv'oaxaca `rifvar' `rest'  `re' [aw=`exp'*`ipw'] if `touse'==1 & inlist(`ddy',2,3),   by(`ddy') w(1) cluster(`idcluster') `relax'   `se'
			matrix `bb'=e(b)
			matrix `vb'=e(V)
			local lgd `e(legend)'
			matrix `bc'=`bx'[1,2]
			matrix `vc'=`vx'[2,2]
			}
		qui:count if `touse'==1 & `ddy'==1  
		local N1=r(N)
		qui:count if `touse'==1 & `ddy'==2
		local NC=r(N)
		qui:count if `touse'==1 & `ddy'==3
		local N2=r(N)
		** This next section gets all the betas of interest
		** Aggregate Decomp
		
		matrix `b0'=`b0'[.,"overall:group_1"],`bc',`b0'[.,"overall:group_2"],`b0'[.,"overall:difference"]
		
        **Explained 
		tempname bx1 bx2 bx3
		matrix `bx1'=`bx'[.,"overall:"]
		matrix `bx2'=`bx'[.,"explained:"]
		matrix `bx3'=`bx'[.,"unexplained:"] 
		matrix coleq   `bx1'="Explained"
		matrix colname `bx1'=Group_1 Group_2 Total Pure_explained Specif_err
		matrix coleq   `bx2'="Pure_explained"
		matrix coleq   `bx3'="Specif_err"
		matrix `bx'=`bx1'[.,3...],`bx2',`bx3'
        *matrix drop bx1 bx2' bx3'
	
		**unexplained
		tempname bb1 bb2 bb3
		matrix `bb1'=`bb'[.,"overall:"]
		matrix `bb2'=`bb'[.,"explained:"]
		matrix `bb3'=`bb'[.,"unexplained:"] 
		matrix coleq   `bb1'="Unexplained"
		matrix colname `bb1'=Group_1 Group_2 Total  Reweight_err Pure_Unexplained
		matrix coleq   `bb3'="Pure_Unexplained"
		matrix coleq   `bb2'="Reweight_err"
		matrix `bb'=`bb1'[.,3...],`bb3',`bb2'
		*matrix drop bb1 bb3 bb2
		**Label VCOV to extract Total Explained and Total unexplained.
		*
		**Putting all together
		*For Beta0
		matrix `b0'=`b0',`bx'[.,"Explained:Total"],`bb'[.,"Unexplained:Total"] 
		matrix coleq `b0'=Overall
		matrix colname `b0'=Group_1 Group_c Group_2 Tdifference ToT_Explained ToT_Unexplained
		tempname b V
		matrix `b'=`b0',`bx',`bb'
		**now for V0
		
		** Flip at some point to make better sense

		local cb: colnames `b'
		local ceqb: coleq  `b'
		
		if "`se'"=="" {
			matrix `v0'=`v0'[.,"overall:group_1"],[0,0,0,0,0]',`v0'[.,"overall:group_2"],`v0'[.,"overall:difference"]
			matrix `v0'=`v0'["overall:group_1",.]\  [0,`vc',0,0] \ `v0'["overall:group_2",.] \ `v0'["overall:difference",.]
			matrix `vx'=`vx'[.,3..5], `vx'[.,"explained:"], `vx'[.,"unexplained:"]
			matrix `vx'=`vx'[3..5,.]\ `vx'["explained:",.]\ `vx'["unexplained:",.]

			matrix `vb'=`vb'[.,3..5], `vb'[.,"unexplained:"], `vb'[.,"explained:"]
			matrix `vb'=`vb'[3..5,.]\ `vb'["unexplained:",.]\ `vb'["explained:",.]

			matrix `v0'=[`v0',[0,0,0,0]'] \  ///
					   [[0,0,0,0],`vx'["overall:difference","overall:difference"]]
			matrix `v0'=[`v0',[0,0,0,0,0]'] \  ///
					   [[0,0,0,0,0],`vb'["overall:difference","overall:difference"]]

			local x2=colsof(`v0')
			local x1=colsof(`vx')		   
			matrix `V'=[`v0',J(`x2',`x1'*2,0)]  \ ///
					[J(`x1',`x2',0),`vx',J(`x1',`x1',0)]\  ///
					[ J(`x1',`x1'+`x2',0),`vb']
			matrix colname `V'=`cb'
			matrix coleq `V'=`ceqb'
			matrix rowname `V'=`cb'
			matrix roweq `V'=`ceqb'		
		}
		** returing results
		
	restore	

	*************************************************************
	}

    *display "is it not doing this"
	if "`se'"=="" 	ereturn post `b' `V', esample(`touse') depname(`y')
	else ereturn post `b' , esample(`touse') depname(`y')
	eret loc title "Blinder-Oaxaca RIF-decomposition"
	eret loc model "Blinder-Oaxaca RIF-decomposition"
    eret loc cmd    "oaxaca_rif"
	eret loc cmdline     "oaxaca_rif `0'"
    eret loc depvar  "`y'"
	eret loc by  "`by'"
	eret loc rifvarp "`rif'"
	eret scalar scale=`scale'
	eret loc dtype   "`type'"
	eret loc weights "`erweight'"
	eret loc g1 `g1'
	eret loc g2 `g2'
	eret loc gc `gc'
	eret loc N1 `N1'
	eret loc N2 `N2'
	eret loc NC `NC'	
	if "`e(dtype)'"=="Reweighted" {
	   if "`rwlogit'"!="" {
		  eret loc rwmodel "logit"
		  ereturn matrix b_logit=`b_rw'
		  ereturn matrix V_logit=`v_rw'
		}
	   else {
		  eret loc rwmodel "probit"
		  ereturn matrix b_probit=`b_rw'
		  ereturn matrix V_probit=`v_rw'
		}
		if "`noisily'"!="" {
		  ereturn matrix b_g1=`bf1'
		  ereturn matrix V_g1=`Vf1'
		  ereturn matrix b_gc=`bf2'
		  ereturn matrix V_gc=`Vf2'
		  ereturn matrix b_g2=`bf3'
		  ereturn matrix V_g2=`Vf3'
		}
	}
	else if "`noisily'"!="" {
		  ereturn matrix b_g1=`bf1'
		  ereturn matrix V_g1=`Vf1'
		  ereturn matrix b_g2=`bf2'
		  ereturn matrix V_g2=`Vf2'
		}
	*capture matrix drop v0 vb vx b0 bb bx vc bc xs bs xcx bcx xc xm bm
	ereturn local lgd `lgd'
	ereturn local vcetype  "Robust"
	display_ob
end

*capture program drop display_ob
program display_ob
if "`e(cmd)'"!="oaxaca_rif" {
	display "Previous results for oaxaca_rif not found"
	exit
   }
    di as txt "Model  : " as res e(model)
	di as txt "Type   : " as res e(dtype)
	di as txt "RIF    : " as res e(rifvarp)
	di as txt "Scale  : " as res e(scale)
    di as txt "Group 1: `e(by)' = " as res e(g1) as text _col(10) " x1*b1 " ///
       as txt _col(50) "N of obs 1      `space'= " as res %10.0g e(N1) 
	di as txt "Group c:" _col(10) "`e(gc)' "  ///
       as txt _col(50) "N of obs C      `space'= " as res %10.0g e(NC)
    di as txt "Group 2: `e(by)' = " as res e(g2) as text _col(10)  " x2*b2 " ///
       as txt _col(50) "N of obs 2      `space'= " as res %10.0g e(N2)
    di ""
ereturn display
Display_legend
end 

*capture program drop Display_legend
prog Display_legend
    foreach line in `e(lgd)' {
        local i 0
        local piece: piece `++i' 80 of `"`line'"'
        di as txt `"`line'"'
        while (1) {
            local piece: piece `++i' 76 of `"`line'"'
            if `"`piece'"'=="" continue, break
            di as txt `" `piece'"'
        }
    }
end


*** This part of the code was extracted from -Oaxaca-

program ParseVar, rclass
    capt ParseVarCheckNormalize, `0'
	if c(version)>=16 local fv fv
    if _rc==0 {
        gettoken dummies hash: normalize, parse("#")
        gettoken hash cons: hash, parse("#")
        if `"`hash'"'!="" {
            `fv'unab cons: `cons', max(1) name(#)
        }
        else local cons "_cons"
        foreach v of local dummies {
            if substr(`"`v'"',1,2)=="b." {
                if `"`base'"'!="" {
                    di as err `"`v' not allowed"'
                    exit 198
                }
                local v = substr(`"`v'"',3,.)
                `fv'unab v: `v'
                gettoken base: v
            }
            else {
                `fv'unab v: `v'
            }
            local vars `vars' `v'
        }
        if `"`base'"'=="" gettoken base: vars  // pick first
        local xvars: list vars - base
        ret local normalize `""`cons' `vars'" "'
    }
    else {
        Unab vars: `0'
        local xvars `vars'
    }
    ret local vars `vars'
    ret local xvars `xvars'
end
program ParseVarCheckNormalize
    syntax, Normalize(str)
    c_local normalize `"`normalize'"'
end


prog Unab
    // returns unabreviated variable names or text as typed if no variable
    gettoken lname 0 : 0, parse(":")
    gettoken junk 0 : 0, parse(":")
	if c(stata_version)>=16 local fv fv
    capt `fv'unab res: `0'
    if _rc {
        local res
        foreach v of local 0 {
            capt `fv'unab res_i: `v'
            if _rc {
                capt confirm name `v'
                if _rc `fv'unab res_i: `v' //=> error
                local res `res' `v'
            }
            else {
                local res `res' `res_i'
            }
        }
    }
    c_local `lname' `res'
end

program final_parsing , rclass
syntax anything
local rest `anything'
while (1) {
        if `"`rest'"'=="" continue, break
        gettoken group rest: rest, match(paren) bind
        if `"`paren'"'=="" {
            ParseVar `group'
            local xvars `xvars' `r(xvars)'
            local vars `vars' `r(vars)'
            local normalize `"`normalize'`r(normalize)'"'
        }
        else {
            gettoken gname gvars: group, parse(":")
            if `"`gvars'"'!="" {
                local gname `gname'
                gettoken colon gvars: gvars, parse(":")
            }
            else {
                local gvars `"`gname'"'
                local gname
            }
            local xvarsi
            local varsi
            gettoken var gvars : gvars, bind
            while (`"`var'"'!="") {
                ParseVar `var'
                local xvarsi `xvarsi' `r(xvars)'
                local varsi `varsi' `r(vars)'
                local normalize `"`normalize'`r(normalize)'"'
                gettoken var gvars : gvars, bind
            }
            if `"`gname'"'=="" {
                gettoken gname: varsi // first var gives name
            }
            local xvars `xvars' `xvarsi'
            local vars `vars' `varsi'
            local vgroups `"`vgroups'`space'"`gname': `varsi'""'
            local space " "
        }
    }
	return local xvars="`xvars'"
end	


