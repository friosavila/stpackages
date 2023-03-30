*! version 4.1  Modified by Fernando Rios to allow FV. To be distribtued with oaxaca_rif only
* This is entirely based on Ben Jann oaxaca command. the modification simply allow using Stata16 capabilities to use FV notation
* version 4.0.5  24aug2011  Ben Jann

program define fvoaxaca, byable(recall) properties(svyj svyb)
    version 16
    if replay() {
        Display `0'
        exit
    }

    *local version : di "version " string(_caller()) ":"
    syntax [anything] [if] [in] [fw aw pw iw] [ , ///
        SVY SVY2(str asis) vce(str) cluster(passthru) Robust noSE * ]

    marksample touse, novarlist zeroweight

    if `"`svy2'"'!="" {
        Parsesvyopt `svy2'
        local svy svy
    }
    if "`svy'"!="" {
        if _by() {
            di as err "svy may not be combined with by"
            exit 190
        }
        local i 0
        foreach opt in vce cluster weight robust {
            local optnm: word `++i' of "vce()" "cluster()" "weights" "robust"
            if `"``opt''"'!="" {
                di as err "`optnm' not allowed with svy"
                exit 198
            }
        }
        if `"`svy_type'"'=="" {
            qui svyset
            local svy_type "`r(vce)'"
        }
        if inlist(`"`svy_type'"',"brr","jackknife") {
            local se "nose"
            svy `svy_type', `svy_opts': ///
                oaxaca `anything' if `touse', `se' `options'
            exit
        }
    }
    if `"`vce'"'!="" {
        Parsevceopt `vce'
        if inlist(`"`vce_type'"',"bootstrap","jackknife") {
            local se "nose"
            `vce_type', `vce_opts': ///
                oaxaca `anything' if `touse' [`weight'`exp'], `se' `options'
            exit
        }
    }
    OAXACA `anything' if `touse' [`weight'`exp'], ///
        `svy' svy2(`svy2') vce(`vce') `cluster' `robust' `se' `options'
end

program Parsesvyopt
    syntax [anything] [, * ]
    local len = strlen(`"`anything'"')
    if `"`anything'"'==substr("jackknife",1,max(4,`len')) local anything "jackknife"
    c_local svy_type `"`anything'"'
    c_local svy_opts `"`options'"'
end

program Parsevceopt
    syntax [anything] [, * ]
    local len = strlen(`"`anything'"')
    if `"`anything'"'==substr("jackknife",1,max(4,`len'))      local anything "jackknife"
    else if `"`anything'"'==substr("bootstrap",1,max(4,`len')) local anything "bootstrap"
    c_local vce_type `"`anything'"'
    c_local vce_opts `"`options'"'
end

prog Display, eclass
    syntax [, level(passthru) eform xb noLEgend ]
    if e(cmd)!="oaxaca" {
        error 301
    }
    if "`eform'"!="" {
        local eform "eform(exp(b))"
        tempname b
        mat `b' = e(b)
        local coln: colnames `b'
        local newcoln: subinstr local coln "_cons" "__cons", word count(local cons)
        if `cons' {
            mat coln `b' = `newcoln'
            ereturn repost b = `b', rename
        }
    }

    _coef_table_header
    if `"`e(prefix)'"'=="" {
        local col 51
        local space ""
        local fmt 10
    }
    else {
        local col 49
        local space "   "
        local fmt 9
    }
    di as txt _col(`col') "Model           `space'= " as res %`fmt's e(model)
    di as txt "Group 1: `e(by)' = " as res e(group_1) ///
       as txt _col(`col') "N of obs 1      `space'= " as res %`fmt'.0g e(N_1)
    di as txt "Group 2: `e(by)' = " as res e(group_2) ///
       as txt _col(`col') "N of obs 2      `space'= " as res %`fmt'.0g e(N_2)
    di ""

    eret display, `level' `eform'
    if "`eform'"!="" {
        if `cons' {
            mat `b' = e(b)
            mat coln `b' = `coln'
            ereturn repost b = `b', rename
        }
    }
    if "`legend'"=="" {
        Display_legend
    }
    if `"`e(adjust)'"'!="" {
        di as txt "(adjusted by `e(adjust)')"
    }
    if `"`xb'"'!="" {
        Display_b0, `level'
    }
end

prog Display_legend
    foreach line in `e(legend)' {
        local i 0
        local piece: piece `++i' 78 of `"`line'"'
        di as txt `"`piece'"'
        while (1) {
            local piece: piece `++i' 76 of `"`line'"'
            if `"`piece'"'=="" continue, break
            di as txt `"  `piece'"'
        }
    }
end

prog Display_b0
    syntax [, Level(passthru)]
    tempname hcurrent b
    mat `b' = e(b0)
    capt confirm matrix e(V0)
    if _rc==0 {
        tempname V
        mat `V' = e(V0)
    }
    _est hold `hcurrent', restore estsystem
    di _n "Coefficients (b) and means (x)"
    eret post `b' `V'
    eret display, `level'
end

program define OAXACA
    version 16
    syntax anything(id="varlist") [if] [in] [fw aw pw iw] , ///
        By(varname) [ swap                                  ///
        LINear logit probit                                 ///
        nolinfast /// undocumented: avoid shortcuts for linear decomposition
        THREEfold THREEfold2(str)                           ///
        Weights(numlist) split                              ///
        Pooled Pooled2(str asis)                            ///
        Omega Omega2(str asis)                              ///
        REFerence(name)                                     ///
        Adjust(passthru) noDetail                           ///
        Detail2(passthru) CATegorical(passthru)  /// old syntax
        nocheck    /// undocumented: skip checks for dummy sets
        x1(passthru) x2(passthru)                           ///
        FIXed FIXed2(string)                                ///
        SVY SVY2(str asis)                                  ///
        vce(str) CLuster(passthru) Robust noSE              ///
        NOSUEST SUEST SUEST2(name)                          ///
        MODEL1(str asis) MODEL2(str asis)                   ///
        relax NOIsily                                       ///
        Noisily2 /// undocumented: display results from -suest- and -mean-
        eform xb noLEgend Level(passthru)                   ///
        * ]

// Options: model type
    if "`linear'`logit'`probit'"=="" local linear linear  // default
    if "`linear'"!="" local cmd regress
    local cmd `cmd' `logit' `probit'
    if `:list sizeof cmd'>1 {
        di as err "only one of linear, logit, and probit allowed"
        exit 198
    }
    if "`cmd'"!="regress" | "`linfast'"!="" {
        if `"`x1'`x2'"'!="" {
            di as err "x1()/x2() not allowed in this context"
            exit 198
        }
    }

// Options: decomposition type
    if `"`pooled2'"'!="" local pooled pooled
    if `"`omega2'"'!=""  local omega omega
    if `"`threefold2'"'!="" {
        if `"`threefold2'"'!=substr("reverse",1,max(1,strlen(`"`threefold2'"'))) {
            di as err "threefold() invalid"
            exit 198
        }
        local threefold threefold
        local threefold2 reverse
    }
    if  ("`threefold'"!="") + (`"`weights'"'!="") + (`"`pooled'"'!="") ///
        + (`"`omega'"'!="") + (`"`reference'"'!="") >1 {
        di as err "only one of threefold, weight(), pooled, omega, and reference() allowed"
        exit 198
    }
    if `"`threefold'`weights'`pooled'`omega'`reference'"'=="" local threefold threefold
    if "`pooled'"!="" {
        local model3 `"`pooled2'"'
    }
    else if "`omega'"!="" {
        local model3 `"`omega2'"'
    }
    local nmodels = 2 + (`"`pooled'`omega'"'!="")
    forv i=1/`nmodels' {
        Parsemodelopt cmd`i' `model`i''
        if `"`cmd`i''"'=="" local cmd`i' "`cmd'"
    }

// Options: suest, vce, svy
    if "`noisily'`noisily2'"=="" local qui quietly
    local se = "`se'"==""
    if `"`fixed2'"'!="" local fixed
    if `"`vce'"'==substr("robust",1,max(1,strlen(`"`vce'"'))) {
        local regvce "vce(robust)"
        local vce
    }
    if "`robust'"!="" local regvce "vce(robust)"
    if `"`suest2'"'!="" local suest suest
    if "`nosuest'"!="" & "`suest'"!="" {
        di as err "suest and nosuest not both allowed"
        exit 198
    }
    if `"`reference'`pooled'`omega'`svy'`cluster'"'!="" {
        local suest "suest"
    }
    if `"`vce'"'!="" {
        VCE_iscluster `vce'
        if `vce_iscluster' local suest "suest"
        local vce `"vce(`vce')"'
    }
    if `se'==0 | "`nosuest'"!="" {
        local suest
    }
    local suest = cond("`suest'"!="",1,0)
    local regweight "`weight'"
    if "`weight'"=="pweight" & `suest'  local regweight "iweight"
    if `suest'                          local regvce  // disable robust
    if "`svy'"!="" {
        capt Parsesvyopt2 `svy2'
        if _rc {
            di as err "invalid svy() option"
            exit 198
        }
        capt Parsesvysubpop `svy_subpop'
        if _rc {
            di as err "invalid subpop() option"
            exit 198
        }
        //=> svy `svy_vcetype', subpop(`svy_subpop') `svy_opts': ...
    }

// Expand varlist (generate xvars and vgroups)
    gettoken depvar rest: anything
    if `"`depvar'"'=="" {
        di as err "too few variables specified"
        exit 198
    }
    local xvars
    local vars
    local vgroups
    local normalize
    local space
    local i 0
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
    local dups: list dups vars
    if `"`dups'"'!="" {
        di as err "invalid varlist; duplicate varnames not allowed"
        exit 198
    }
    if `"`normalize'"'=="" & `"`categorical'"'!="" { // old syntax: parse categorical()
        ParseCategorical, vars(`vars') xvars(`xvars') `categorical'
    }
    foreach group of local normalize { // make sure interaction terms are in model
        gettoken cons: group
        if "`cons'"=="_cons" continue
        if `: list cons in vars'==0 {
            local vars `vars' `cons'
            local xvars `xvars' `cons'
        }
    }
    local vars: subinstr local vars "_cons" "", word
    local xvars: subinstr local xvars "_cons" "", word
    local vars: subinstr local vars "_offset" "", word
    local xvars: subinstr local xvars "_offset" "", word
    if `"`vgroups'"'=="" & `"`detail2'"'!="" {  // old syntax: parse detail2()
        if "`detail'"!="" {
            di as err "nodetail and detail() not both allowed"
            exit 198
        }
        ParseDetail, `detail2'
    }
    if "`detail'"!="" local vgroups

// Mark sample and determine groups
    marksample touse, zeroweight novarlist
    if "`svy'"!="" {
        svymarkout `touse'
    }
    qui levelsof `by' if `touse', local(groups)
    if `: list sizeof groups'>2 {
        di as err "more than 2 groups found, only 2 groups allowed"
        exit 420
    }
    if "`swap'"=="" {
        gettoken group1 group2: groups, quotes
        gettoken group2: group2, quotes
    }
    else {
        gettoken group2 group1: groups, quotes
        gettoken group1: group1, quotes
    }

// Estimate group models
    local haserrmsg 0
    local robreg = (`suest'==0 & `se')
    tempvar touse1 touse2 subpop1 subpop2
    forv g=1/2 {
        `qui' di as txt _n "Model for group `g'"
        local mlbl`g' "model `g'"
        if "`svy'"!="" {
            `qui' svy `svy_vcetype', subpop(`svy_subpop' & `by'==`group`g'') `svy_opts': ///
             `cmd`g'' `depvar' `xvars' `cmd`g'rhs' if `touse', ///
             `options' `cmd`g'opts'
        }
        else {
            `qui' `cmd`g'' `depvar' `xvars' `cmd`g'rhs' if `touse' & `by'==`group`g'' ///
                [`regweight'`exp'], `regvce' `options' `cmd`g'opts'
        }
        CheckCoefs "`mlbl`g''" "`xvars'"
        if r(err) local haserrmsg 1
        local offset`g' `e(offset)'
    // determine sample
        qui gen byte `touse`g'' = e(sample)==1
        Marksubpop `e(subpop)', g(`subpop`g'')
        qui replace `subpop`g'' = 0 if `touse`g''==0
        if "`svy'"=="" {
            qui replace `touse`g'' = 0 if `subpop`g''==0
        }
        if "`e(cmd)'"=="heckman" | "`e(cmd)'"=="heckprob" {
            local depvar: word 1 of `e(depvar)'
            qui replace `subpop`g'' = 0 if `depvar'>=.
            if "`svy'"=="" {
                qui replace `touse`g'' = 0 if `depvar'>=.
            }
            local depvar_s: word 2 of `e(depvar)'
            if "`depvar_s'"!="" {
                qui replace `subpop`g'' = 0 if `depvar_s'==0
                if "`svy'"=="" {
                    qui replace `touse`g'' = 0 if `depvar_s'==0
                }
            }
        }
    // store model
        if `"`cmd`g'sto'"'!="" {
            est sto `cmd`g'sto'
            di as txt "(`mlbl`g'' saved as " ///
             "{stata estimates replay `cmd`g'sto':`cmd`g'sto'})"
        }
        else if `suest' {
            tempname cmd`g'sto
            est sto `cmd`g'sto'
        }
    // if no suest: collect results
        if `suest'==0 {
            tempname b`g'
            mat `b`g'' = e(b)
            local firsteq: coleq `b`g'', q
            local firsteq: word 1 of `firsteq'
            mat `b`g'' = `b`g''[1,"`firsteq':"]
            local eqlab = "b`g'"
            mat coleq `b`g'' = "`eqlab'"
            if `se' {
                tempname V`g'
                mat `V`g'' = e(V)
                mat `V`g'' = `V`g''["`firsteq':","`firsteq':"]
                mat coleq `V`g'' = "`eqlab'"
                mat roweq `V`g'' = "`eqlab'"
                if "`e(vce)'"!="robust" local robreg 0
            }
        }
    }
    qui replace `touse' = 0 if `touse1'==0 & `touse2'==0

// Estimate pooled model or restore reference model
    local g 2
    if `"`reference'`pooled'`omega'"'!="" {
        local ++g
        if `"`reference'"'!="" {
            local mlbl`g' "reference model"
            qui estimates restore `reference'
        }
        else {
            `qui' di as txt _n "Pooled model"
            local mlbl`g' "pooled model"
            if `"`pooled'"'!="" local includeby `"`by'"'
            if "`svy'"!="" {
                `qui' svy `svy_vcetype', subpop(`svy_subpop') `svy_opts': ///
                `cmd3' `depvar' `xvars' `cmd3rhs' `includeby' if `touse', ///
                `options' `cmd3opts'
            }
            else {
                `qui' `cmd3' `depvar' `xvars' `cmd3rhs' `includeby' if `touse' ///
                    [`regweight'`exp'], `regvce' `options' `cmd3opts'
            }
            CheckCoefs "`mlbl`g''" "`xvars'"
            if r(err) local haserrmsg 1
        // store model
            if `"`cmd`g'sto'"'!="" {
                est sto `cmd`g'sto'
                di as txt "(`mlbl`g'' saved as " ///
                "{stata estimates replay `cmd3sto':`cmd3sto'})"
            }
            else if `suest' {
                tempname cmd`g'sto
                est sto `cmd`g'sto'
            }
        }
        local offset`g' `e(offset)'
    // if no suest: collect results
        if `suest'==0 {
            tempname b3
            mat `b`g'' = e(b)  // note: `g' = 3
            local firsteq: coleq `b`g'', q
            local firsteq: word 1 of `firsteq'
            mat `b`g'' = `b`g''[1,"`firsteq':"]
            local eqlab = "b_ref"
            mat coleq `b`g'' = "`eqlab'"
            if `se' {
                tempname V`g'
                mat `V`g'' = e(V)
                mat `V`g'' = `V`g''["`firsteq':","`firsteq':"]
                mat coleq `V`g'' = "`eqlab'"
                mat roweq `V`g'' = "`eqlab'"
                if "`e(vce)'"!="robust" local robreg 0
            }
        }
    }

// Error in case of estimations problems
    if "`relax'"=="" & `haserrmsg' {
        di as err "dropped coefficients or zero variances encountered"
        if "`qui'"!="" {
            di as err "specify -noisily- to view model estimation output"
        }
        di as err "specify -relax- to ingnore"
        exit 499
    }

// Compile joint coefficients vector and variance matrix
    if "`noisily2'"=="" local qui quietly
    if `robreg' {
        local e_vce     "robust"
        local e_vcetype "Robust"
    }
    tempname b
    if `se' tempname V
    if `suest' {
        `qui' suest `cmd1sto' `cmd2sto' `cmd3sto' `reference', `svy' `vce' `cluster'
        if `"`suest2'"'!="" {
            est sto `suest2'
            di as txt "(suest results saved as " ///
                "{stata estimates replay `suest2':`suest2'})"
        }
        mat `b' = e(b)
        mat `V' = e(V)
        local e_vce     "`e(vce)'"
        local e_vcetype "`e(vcetype)'"
        ExtractFirstEqs "b1 b2 b_ref" `b' `V'
    }
    else {
        mat `b' = `b1', `b2'
        mat drop `b1' `b2'
        if `se' {
            mat `V' = `V1'
            MatAppendDiag `V' `V2'
            mat drop `V1' `V2'
        }
        if `g'==3 {
            mat `b' = `b', `b3'
            mat drop `b3'
            if `se' {
                MatAppendDiag `V' `V3'
                mat drop `V3'
            }
        }
    }

// Add offsets
    local offset `offset1' `offset2' `offset3'
    local offset: list uniq offset
    if `:list sizeof offset'>1 {
        di as err "models have different offsets; only one offset term allowed"
        exit 499
    }
    if `"`offset'"'!="" {
        tempvar voffset
        qui gen double `voffset' = `offset'
        mata: oaxaca_addoffset()
    }

// Insert missing coefs
    local dropped `xvars'
    forv i = 1/`g' {
        tempname tmp
        local eq: word `i' of b1 b2 b_ref
        mat `tmp' = `b'[1,"`eq':"]
        local coefs`i': colnames `tmp'
        mat drop `tmp'
        local dropped: list dropped - coefs`i'
    }
    //local xvars: list xvars - dropped // keep dropped because of normalize()
    //local vars: list vars - dropped
    local coefs: list xvars | coefs1
    local coefs: list coefs | coefs2
    forv i = 1/`g' {
        local coefs`i': list coefs - coefs`i'
        local offset`i': list coefs`i' & voffset
        local coefs`i': list coefs`i' - voffset
        if "`coefs`i''"!="" {
            di as txt "(`coefs`i'' missing in `mlbl`i''; assumed zero)"
        }
        if "`offset`i''"!="" {
            di as txt "(offset missing in `mlbl`i''; assumed zero)"
        }
    }
    local coefs: list vars | coefs
    local ncoefs: list sizeof coefs
    local cons = `: list posof "_cons" in coefs'
    if `cons' & (`cons'!=`ncoefs') {    // put _cons last
        local coefs: subinstr local coefs "_cons" "", word
        local coefs `coefs' _cons
    }
    if "`offset'"!="" {                 // put offset last
        local coefs: subinstr local coefs "`voffset'" "", word
        local coefs `coefs' `voffset'
    }
    mata: oaxaca_insertmissingcoefs()

// Add constant if needed and update coeflist
    if `cons' {
        tempname xcons
        qui gen byte `xcons' = 1
        local xvars: subinstr local coefs "_cons" "`xcons'", word all
    }
    else {
        local xvars `"`coefs'"'
    }
    if `"`offset'"'!="" {
        local coefs: subinstr local coefs "`voffset'" "_offset", word all
    }

// Normalize dummy groups (deviation contrast transform)
    if `"`normalize'"'!="" {
        mata: oaxaca_normalize()
        di as txt "(normalized: " _c
        local comma
        local space
        foreach group of local normalize {
            gettoken tmp group: group
            local group `group'
            if "`tmp'"!="_cons" {
                local group "`group' # `tmp'"
            }
            local normalized `"`normalized'`space'"`group'""'
            local space " "
            di "`comma'`group'" _c
            local comma ", "
        }
        di ")"
    }

// Create reference model from weights()
    if `"`weights'"'!="" {
        mata: oaxaca_add_b_ref()
    }

// Compute means
    tempname x Vx
    if `suest' {
        tempname grpvar
        gen byte `grpvar'= 0
        qui replace `grpvar' = 1 if `subpop1'
        capt assert (`grpvar'==0) if `subpop2'
        if _rc {
            error "overlapping samples (groups not distinct)"
            exit 498
        }
        qui replace `grpvar' = 2 if `subpop2'
        if "`svy'"=="" {
            `qui' mean `xvars' if `touse' [`weight'`exp'], ///
                over(`grpvar') `vce' `cluster'
            if e(N_clust)<. {
                local e_N_clust = e(N_clust)
                local e_clustvar "`e(clustvar)'"
            }
        }
        else {
            `qui' svy `svy_type', ///
                subpop(`svy_subpop' & (`subpop1' | `subpop2')) `svy_opts' : ///
                    mean `xvars' if `touse', over(`grpvar')
            local e_prefix "`e(prefix)'"
            local e_N_strata = e(N_strata)
            local e_N_psu = e(N_psu)
            local e_N_pop = e(N_pop)
            local e_df_r = e(df_r)
        }
        if "`e(vce)'"!="analytic" & "`e(vce)'"!="" {
            local e_vce     "`e(vce)'"
            local e_vcetype "`e(vcetype)'"
        }
        local e_wtype "`e(wtype)'"
        local e_wexp `"`e(wexp)'"'
        mat `x' = e(b)
        mat `Vx' = e(V)
        local N1 = el(e(_N),1,1)
        local N2 = el(e(_N),1,2)
        if `cons' {
            local coleq: coleq `x'
            local coleq: subinstr local coleq "`xcons'" "_cons", word all
            mat coleq `x' = `coleq'
            mat coleq `Vx' = `coleq'
            mat roweq `Vx' = `coleq'
        }
        mata: oaxaca_reorderxandVx()
    }
    else {
        tempname xtmp Vxtmp
        local tmp
        forv i = 1/2 {
            if "`svy'"=="" {
                `qui' mean `xvars' if `touse' & `touse`i'' [`weight'`exp'], `vce' `cluster'
            }
            else {
                `qui' svy `svy_type', subpop(`svy_subpop' & `subpop`i'') `svy_opts' : ///
                    mean `xvars' if `touse' & `touse`i''
            }
            mat `x`tmp'' = e(b)
            local N`i' = el(e(_N),1,1)
            local e_wtype "`e(wtype)'"
            local e_wexp `"`e(wexp)'"'
            if `cons' {
                local coln: colnames `x`tmp''
                local coln: subinstr local coln "`xcons'" "_cons", word
                mat coln `x`tmp'' = `coln'
            }
            mat coleq `x`tmp'' = "x`i'"
            if `se' {
                mat `Vx`tmp'' = e(V)
                if `cons' {
                    mat coln `Vx`tmp'' = `coln'
                    mat rown `Vx`tmp'' = `coln'
                }
                mat coleq `Vx`tmp'' = "x`i'"
                mat roweq `Vx`tmp'' = "x`i'"
            }
            local tmp tmp
        }
        mat `x' = `x', `xtmp'
        mat drop `xtmp'
        if `se' {
            MatAppendDiag `Vx' `Vxtmp'
            mat drop `Vxtmp'
        }
    }
    if `"`x1'`x2'"'!="" {
        SetXvals `x' `Vx', se(`se') `x1' `x2'
    }
    mat `b' = `b', `x'
    mat drop `x'
    if `se' {
        if "`fixed'"!="" {
            mat `Vx' = `Vx'*0
            local fixedopt "fixed"
        }
        else if `"`fixed2'"'!=""{
            local fixedx
            foreach var of local fixed2 {
                capt fvunab temp: `var'
                if _rc {
                    local temp "`var'"
                }
                local temp: list temp & coefs
                if `"`temp'"'=="" {
                    di as err `"`var' not found"'
                    exit 111
                }
                local fixedx: list fixedx | temp
            }
            if `"`fixedx'"'!="" {
                mata: oaxaca_setfixedXtozero(0)
                local fixedopt "fixed(`fixedx')"
            }
        }
        MatAppendDiag `V' `Vx'
        mat drop `Vx'
    }

// Parse adjust() => returns locals adjust and coefsadj
    Parseadjust, `adjust' coefs(`coefs')

// Compute decomposition
    tempname b0
    matrix rename `b' `b0'
    if `se' {
        tempname V0
        matrix rename `V' `V0'
    }
    if `"`e_wexp'"'!="" {
        tempname w
        qui gen double `w' `e_wexp'
    }
    mata: oaxaca()

// Post results and display
    if `"`threefold2'"'!="" local threefold threefold(`threefold2')
    PostResults `b' `V', b0(`b0') v0(`V0') esample(`touse') ///
        depname(`depvar') by(`by') group1(`group1') group2(`group2') ///
        model(`linear'`logit'`probit') threefold(`threefold') ///
        refcoefs(`pooled'`omega'`reference') weights(`weights') ///
        adjust(`adjust') normalized(`normalized') ///
        legend(`vgroups') n1(`N1') n2(`N2')  ///
        suest(`suest') fixed(`fixedopt') wtype(`e_wtype') wexp(`e_wexp') ///
        vce(`e_vce') vcetype(`e_vcetype') n_clust(`e_N_clust') ///
        clustvar(`e_clustvar') prefix(`e_prefix') n_strata(`e_N_strata') ///
        n_psu(`e_N_psu') n_pop(`e_N_pop') df_r(`e_df_r')

    Display, `level' `eform' `xb' `legend'
end

program PostResults, eclass
    syntax anything [, b0(str) v0(str) esample(str) ///
        depname(str) by(str) group1(str asis) group2(str asis) ///
        model(str) threefold(str) refcoefs(str) weights(str) adjust(str) ///
        normalized(str asis) legend(str asis) n1(str) n2(str) ///
        suest(str) fixed(str) wtype(str) wexp(str asis) ///
        vce(str) vcetype(str) n_clust(str) ///
        clustvar(str) prefix(str) n_strata(str) ///
        n_psu(str) n_pop(str) df_r(str) ]
    qui count if `esample'
    if `"`depname'"'!="" {
        local depvar `"`depname'"'
        local depname `"depname(`depname')"'
    }
    eret post `anything', esample(`esample') obs(`r(N)') `depname'
    foreach opt in prefix clustvar vcetype vce wexp wtype  {
        eret local `opt' `"``opt''"'
    }
    if `suest' eret local suest suest
    foreach opt in fixed adjust normalized legend threefold ///
        refcoefs weights model depvar {
        eret local `opt' `"``opt''"'
    }
    eret local group_2 `"`group2'"'
    eret local group_1 `"`group1'"'
    eret local by `"`by'"'
    eret local title "Blinder-Oaxaca decomposition"
    eret local cmd "oaxaca"
    if "`n1'`n2'"!="" {
        eret scalar N_1 = `n1'
        eret scalar N_2 = `n2'
    }
    foreach opt in N_clust N_strata N_psu N_pop df_r {
        local optt = lower("`opt'")
        if `"``optt''"'!="" {
            eret scalar `opt' = ``optt''
        }
    }
    eret mat b0 = `b0'
    if "`v0'"!="" {
        eret mat V0 = `v0'
    }
end

program Parsemodelopt
    gettoken cmd 0 : 0
    capt syntax [anything] [, ADDrhs(str asis) STOre(name) * ]
    if _rc {
        local 0 `", `0'"'                           // undocumented
        syntax [, ADDrhs(str asis) STOre(name) * ]
    }
    c_local `cmd'     `"`anything'"'
    c_local `cmd'rhs  `"`addrhs'"'
    c_local `cmd'sto  `"`store'"'
    c_local `cmd'opts `"`options'"'
end

program Parsesvyopt2
    syntax [anything] [, SUBpop(str asis) * ]
    c_local svy_type    `"`anything'"'
    c_local svy_opts    `"`options'"'
    c_local svy_subpop  `"`subpop'"'
end

program Parsesvysubpop
    syntax [varname(default=none)] [if/]
    if `"`if'"'!="" {
        local iff `"(`if') & "'
    }
    if "`varlist'"!="" {
        local iff `"`varlist' & `iff'"'
    }
    c_local svy_subpop `"if `iff'1"'
end

program VCE_iscluster
    syntax [anything] [, * ]
    local vce_type: word 1 of `anything'
    local iscluster 0
    if `"`vce_type'"'==substr("cluster",1,max(2,strlen(`"`vce_type'"'))) local iscluster 1
    c_local vce_iscluster `iscluster'
end

prog Marksubpop
    syntax [varname(default=none)] [if], g(name)
    marksample touse
    if "`varlist'"!="" {
        qui replace `touse' = 0 if `varlist'==0
    }
    rename `touse' `g'
end

program ParseVar, rclass
    capt ParseVarCheckNormalize, `0'
    if _rc==0 {
        gettoken dummies hash: normalize, parse("#")
        gettoken hash cons: hash, parse("#")
        if `"`hash'"'!="" {
            fvunab cons: `cons', max(1) name(#)
        }
        else local cons "_cons"
        foreach v of local dummies {
            if substr(`"`v'"',1,2)=="b." {
                if `"`base'"'!="" {
                    di as err `"`v' not allowed"'
                    exit 198
                }
                local v = substr(`"`v'"',3,.)
                fvunab v: `v'
                gettoken base: v
            }
            else {
                fvunab v: `v'
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
    capt fvunab res: `0'
    if _rc {
        local res
        foreach v of local 0 {
            capt fvunab res_i: `v'
            if _rc {
                capt confirm name `v'
                if _rc fvunab res_i: `v' //=> error
                local res `res' `v'
            }
            else {
                local res `res' `res_i'
            }
        }
    }
    c_local `lname' `res'
end

program ParseCategorical
    syntax [ , VARs0(str) xvars(str) categorical(str) ]
    gettoken 1 groups: categorical, parse(",")
    local vars `vars0'
    local cvars
    while `"`1'"'!="" {
        gettoken 1 cons: 1, parse("(")
        fvunab 1: `1'
        if `"`1'"'=="" | `"`:list cvars & 1'"'!="" {
            di as err "invalid categorical() option"
            exit 198
        }
        local tmp: list vars0 & 1
        if `"`tmp'"'=="" {
            local vars `vars' `1'
            gettoken base tmp: 1  // first is base
            local xvars `xvars' `tmp'
        }
        else {
            local tmp: list 1 - vars0
            local n: list sizeof tmp
            if `n'==0 {
                gettoken base: 1  // first is base
                local xvars: list xvars - base
            }
            else /*if `n'>0*/ {
                gettoken base: tmp  // first is base
                local tmp: list 1 & vars0
                gettoken first tmp: tmp
                local vars: list vars - tmp
                local xvars: list xvars - tmp
                local vars: subinstr local vars "`first'" "`1'", word
                local tmp: list 1 - base
                local xvars: subinstr local xvars "`first'" "`tmp'", word
            }
        }
        if "`cons'"!="" {
            fvunab cons: `cons'
        }
        else local cons "_cons"
        local cvars `cvars' `1'
        local normalize `"`normalize'"`cons' `1'" "'
        gettoken 1 groups: groups, parse(",") // get rid of comma
        gettoken 1 groups: groups, parse(",")
    }
    c_local xvars `xvars'
    c_local vars `vars'
    c_local normalize `"`normalize'"'
end

program ParseDetail
    syntax [, Detail2(str) ]
    local space
    while (1) {
        if `"`detail2'"'=="" continue, break
        gettoken group detail2 : detail2, parse(",")
        gettoken gname vars : group, parse("=:")
        local gname `gname'
        gettoken trash vars: vars, parse("=:")
        if `"`gname'"'=="" | `"`vars'"'=="" {
            di as err "invalid detail() option"
            exit 198
        }
        Unab vars: `vars'
        local vgroups `"`vgroups'`space'"`gname': `vars'""'
        local space " "
        gettoken group detail2 : detail2, parse(",") // get rid of comma
    }
    c_local vgroups `"`vgroups'"'
end

prog CheckCoefs, rclass
    args label xvars
    tempname b
    mat `b' = e(b)
    local firsteq: coleq `b', q
    local firsteq: word 1 of `firsteq'
    mat `b' = `b'[1,"`firsteq':"]
    local coefs: colnames `b'
    local notfound : list xvars - coefs
    if "`notfound'"!="" {
        di as txt "(`notfound' dropped from `label')"
    }
    mata: st_local("zero", strofreal(anyof(diagonal(st_matrix("e(V)")), 0)))
    if `zero' {
        di as txt "(`label' has zero variance coefficients)"
    }
    return scalar err = ("`notfound'"!="" | `zero')
end

prog ExtractFirstEqs
    args eqlab b V
    local i 0
    foreach nm in `e(names)' {
        local ++i
        local suffix: word 1 of `e(eqnames`i')'
        if `"`suffix'"'!="_" {
            local nm `"`nm'_`suffix'"'
        }
        local oldeqs `"`oldeqs'`space'`nm'"'
        local neweqs `"`neweqs'`space'`:word `i' of `eqlab''"'
        local space " "
    }
    mata: oaxaca_extracteqs()
end

prog MatAppendDiag
    args A D
    tempname B C
    mat `B' = `D'[1,1...] \ J(rowsof(`A'),colsof(`D'),0) // preserve colnames
    mat `B' = `B'[2...,1...]
    mat `C' = `D'[1...,1], J(rowsof(`D'),colsof(`A'),0) // preserve rownames
    mat `C' = `C'[1...,2...]
    mat `A' = (`A', `B') \ (`C', `D')
end

program Parseadjust
    syntax [, adjust(str) coefs(str) ]
    Unab adjust: `adjust'
    local notfound: list adjust - coefs
    if `"`notfound'"'!="" {
        di as err `"adjust(): `notfound' not found in models"'
        exit 111
    }
    c_local adjust `"`adjust'"'
    c_local coefsadj: list coefs - adjust
end

prog SetXvals
    syntax anything, se(str) [ x1(str) x2(str) ]
    gettoken x Vx : anything
    gettoken Vx : Vx
    tempname tmp
    local fixedx
    forv i = 1/2 {
        if `"`x`i''"'=="" continue
        mat `tmp' = `x'[1,"x`i':"]
        local coefs: colnames `tmp'
        while (1) {
            if `"`x`i''"'=="" continue, break
            gettoken var x`i' : x`i', parse(" =,")
            if `"`var'"'=="," {
                gettoken var x`i' : x`i', parse(" =")
            }
            gettoken val x`i' : x`i', parse(" =,")
            if `"`val'"'=="=" {
                gettoken val x`i' : x`i', parse(" ,")
            }
            capt confirm number `val'
            if _rc | `"`var'"'=="" {
                di as err "invalid x`i'() option"
                exit 198
            }
            capt fvunab trash : `var'
            if _rc {
                local trash `"`var'"'
            }
            local vars: list coefs & trash
            if `"`vars'"'=="" {
                di as err `"x`i'(): `var' not found"'
                exit 111
            }
            local coefs: list coefs - vars
            foreach v of local vars {
                mat `x'[1,colnumb(`x',`"x`i':`v'"')] = `val'
                local fixedx `"`fixedx' `"x`i':`v'"'"'
            }
        }
    }
    if `se' {
        mata: oaxaca_setfixedXtozero(1)
    }
end

set matastrict on
version 16
mata:

void oaxaca_extracteqs()
{
    real scalar         r, i, j, match
    real rowvector      b
    real colvector      p
    real matrix         V
    string rowvector    old, newi
    string matrix       stripe

    b = st_matrix(st_local("b"))
    V = st_matrix(st_local("V"))
    old = tokens(st_local("oldeqs"))
    newi = tokens(st_local("neweqs"))
    stripe = st_matrixcolstripe(st_local("b"))
    r = 0
    j = 1
    match = 0
    for (i=1; i<=rows(stripe); i++) {
        if (stripe[i,1]==old[j]) {
            r++
            match = 1
        }
        else if (match) {
            j++
            i--
            match = 0
        }
        if (j>length(old)) break
    }
    p = J(r,1,.)
    r = 0
    j = 1
    for (i=1; i<=rows(stripe); i++) {
        if (stripe[i,1]==old[j]) {
            p[++r] = i
            match = 1
            stripe[i,1] = newi[j]
        }
        else if (match) {
            j++
            i--
            match = 0
        }
        if (j>length(old)) break
    }
    b = b[,p]
    V = V[p,p]
    stripe = stripe[p,]
    st_matrix(st_local("b"), b)
    st_matrixcolstripe(st_local("b"), stripe)
    st_matrix(st_local("V"), V)
    st_matrixcolstripe(st_local("V"), stripe)
    st_matrixrowstripe(st_local("V"), stripe)
}

void oaxaca_addoffset()
{
    real scalar         i, se
    real rowvector      b
    real colvector      p
    real matrix         V
    string scalar       offset, voffset
    string colvector    eqs
    string matrix       stripe

    b       = st_matrix(st_local("b"))
    stripe  = st_matrixcolstripe(st_local("b"))
    eqs     = uniqrows(stripe[.,1])
    voffset = st_local("voffset")
    if ((se = (st_local("se")=="1"))) V = st_matrix(st_local("V"))
    for (i=1; i<=rows(eqs); i++) {
        offset = st_local("offset" + strofreal(i))
        if (offset!="") {
            p = oaxaca_which(stripe[,1]:==eqs[i])
            p = p[rows(p)]
            oaxaca_rowinsert(stripe, (eqs[i], voffset), p)
            oaxaca_colinsert(b, 1, p)
            if (se) {
                oaxaca_rowinsert(V, J(1,cols(V),0), p)
                oaxaca_colinsert(V, J(rows(V),1,0), p)
            }
        }
    }
    st_matrix(st_local("b"), b)
    st_matrixcolstripe(st_local("b"), stripe)
    if (se) {
        st_matrix(st_local("V"), V)
        st_matrixcolstripe(st_local("V"), stripe)
        st_matrixrowstripe(st_local("V"), stripe)
    }
}

void oaxaca_rowinsert(transmorphic matrix X,
    transmorphic rowvector r, real scalar p)
{
    if (p<=0)            X = r \ X
    else if (p>=rows(X)) X = X \ r
    else                 X = X[|1,1 \ p,.|] \ r \ X[|p+1,1 \ .,.|]
}

void oaxaca_colinsert(transmorphic matrix X,
    transmorphic colvector c, real scalar p)
{
    if (p<=0)            X = c , X
    else if (p>=cols(X)) X = X , c
    else                 X = X[|1,1 \ .,p|] , c , X[|1,p+1 \ .,.|]
}

void oaxaca_insertmissingcoefs()
{
    real scalar         i, j, k, ncoef, neq
    real colvector      p, pnew, r
    real rowvector      b
    real matrix         V, Vnew
    string colvector    coefs
    string colvector    eqs
    string matrix       stripe

    coefs = tokens(st_local("coefs"))'
    ncoef = rows(coefs)
    stripe = st_matrixcolstripe(st_local("b"))
    eqs = uniqrows(stripe[,1])
    neq = rows(eqs)
    p = J(neq*ncoef,1,.)
    k = 0
    for (i=1; i<=neq; i++) {
        for (j=1; j<=ncoef; j++) {
            k++
            r = oaxaca_which(stripe[,1]:==eqs[i] :& stripe[,2]:==coefs[j])
            if (rows(r)<1) continue
            p[k] = r  // assuming only one match
        }
    }
    pnew = oaxaca_which(p:<.)
    p = select(p, p:<.)
    b = J(1, neq*ncoef, 0)
    b[pnew'] = st_matrix(st_local("b"))[p']
    stripe = J(neq*ncoef,2,"")
    for (i=1; i<=neq; i++) {
        stripe[|(i-1)*ncoef+1,1 \ (i-1)*ncoef+ncoef,2 |] =
            J(ncoef,1,eqs[i]), coefs
    }
    st_matrix(st_local("b"), b)
    st_matrixcolstripe(st_local("b"), stripe)
    if (st_local("se")=="1") {
        V = st_matrix(st_local("V"))
        Vnew = J(rows(V),neq*ncoef,0)
        Vnew[,pnew] = V[,p]
        V = J(neq*ncoef,neq*ncoef,0)
        V[pnew,] = Vnew[p,]
        st_matrix(st_local("V"), V)
        st_matrixcolstripe(st_local("V"), stripe)
        st_matrixrowstripe(st_local("V"), stripe)
    }
}

void oaxaca_normalize()
{
    real scalar         i, j, k, neq, ncoef, se, check, pcons, err
    real rowvector      b
    real colvector      p
    real matrix         V, D, X
    string rowvector    norm, normi
    string matrix       stripe

    check   = (st_local("check")=="")
    b       = st_matrix(st_local("b"))
    stripe  = st_matrixcolstripe(st_local("b"))
    norm    = tokens(st_local("normalize"))
    neq     = rows(uniqrows(stripe[,1]))
    ncoef   = rows(stripe)/neq
    stripe  = stripe[|1,2 \ ncoef,2|] // coefs from pick first eq
    se      = (st_local("se")=="1")
    if (se) V = st_matrix(st_local("V"))
    D = diag(J(1,ncoef,1))
    for (i=1; i<=cols(norm); i++) {
        normi = tokens(norm[i]) // first element is cons
        pcons[1] = oaxaca_which(stripe:==normi[1]) // assuming exactly one match
        k     = cols(normi) - 1
        p     = J(k, 1, .)
        for (j=1; j<=k; j++) {
            p[j] = oaxaca_which(stripe:==normi[j+1]) // assuming exactly one match
        }
        D[p, pcons] = D[p, pcons] :+ (1/k)
        D[p, p']    = D[p, p'] :- (1/k)
        if (check) {
            for (j=1; j<=2; j++) {
                st_view(X, ., normi[|2 \ k+1|], st_local("subpop" + strofreal(j)))
                err = (normi[1]=="_cons" ? any(rowsum(X):!=1) :
                    mreldif(rowsum(X),st_data(., normi[1],
                        st_local("subpop" + strofreal(j))))>1e-7)
                if (err) _error(3498, "inconsistent dummy set: " +
                        oaxaca_invtokens(normi[|2 \ k+1|]))
            }
        }
    }
    if (neq==3) D = blockdiag(D, blockdiag(D, D))
    else        D = blockdiag(D, D)
    b = b * D
    if (se) V = D' * V * D
    st_replacematrix(st_local("b"), b)
    if (se) st_replacematrix(st_local("V"), V)
}

string scalar oaxaca_invtokens(string vector In, | string scalar del0)
{
    string scalar Out, del
    real scalar i

    del = (args()<2 ? " " : del0)
    Out = ""
    for (i=1; i<=length(In); i++) {
        Out = Out + (i>1 ? del : "") + In[i]
    }
    return(Out)
}

void oaxaca_add_b_ref()
{
    real rowvector b
    real matrix    V, G
    real scalar    k
    real rowvector wgt
    string matrix  cstripe

    wgt = strtoreal(tokens(st_local("weights")))
    b = st_matrix(st_local("b"))
    cstripe = st_matrixcolstripe(st_local("b"))
    k = cols(b) / 2
    cstripe = cstripe \ (J(k, 1, "b_ref") , cstripe[|1,2 \ k,2|])
    wgt = oaxaca_rowvecrep(wgt, k)

    G = diag(J(1, cols(b), 1)) , (diag(wgt) \ diag(1:-wgt))
    b = b * G
    st_matrix(st_local("b"), b)
    st_matrixcolstripe(st_local("b"), cstripe)
    if (st_local("se")=="1") {
        V = st_matrix(st_local("V"))
        V = G' * V * G
        st_matrix(st_local("V"), V)
        st_matrixcolstripe(st_local("V"), cstripe)
        st_matrixrowstripe(st_local("V"), cstripe)
    }
}

real rowvector oaxaca_rowvecrep(real rowvector x, real scalar l)
{       // note: l is total length (not number of repetitions)
        real scalar         i, c, m
        transmorphic vector res

        if (l<=0) return(J(1,0,.))
        c = cols(x)
        m = ceil(l/c)
        res = J(1, c*m, .)
        for (i=1; i<=m; i++) {
            res[|(i-1)*c+1 \ i*c|] = x
        }
        return(res[|1 \ l|])
}

void oaxaca_reorderxandVx()
{
    real scalar         k
    real rowvector      b
    real colvector      p
    real matrix         V
    string matrix       coefs, stripe
    "here"
    b = st_matrix(st_local("x"))
    coefs = st_matrixcolstripe(st_local("x"))
	"here2"
    k = length(b)
    p = range(1, k-1, 2) \ range(2, k, 2)
    b = b[p]
    stripe = ("x":+coefs[p,2]), coefs[p,1]
	"here3"
	 st_matrix(st_local("x"), b)
	 b
    st_matrixcolstripe(st_local("x"), stripe)
	stripe
	"here4"
    if (st_local("se")=="1") {
        V = st_matrix(st_local("Vx"))
        V = V[p,p]
        st_matrix(st_local("Vx"), V)
		"here5"
        st_matrixcolstripe(st_local("Vx"), stripe)
        st_matrixrowstripe(st_local("Vx"), stripe)
    }
}

void oaxaca_setfixedXtozero(real scalar eq)
{
    real scalar         r, i
    real colvector      p, tmp
    real matrix         V
    string colvector    fixed
    string matrix       stripe

    V = st_matrix(st_local("Vx"))
    fixed = tokens(st_local("fixedx"))'
    if (eq) {
        stripe = st_matrixcolstripe(st_local("Vx"))
        stripe = stripe[,1] :+ ":" :+ stripe[,2]
    }
    else stripe = st_matrixcolstripe(st_local("Vx"))[,2]
    r = 0
    for (i=1;i<=length(fixed);i++) {
        r = r + length(oaxaca_which(stripe:==fixed[i]))
    }
    p = J(r,1,.)
    r = 1
    for (i=1;i<=length(fixed);i++) {
        tmp = oaxaca_which(stripe:==fixed[i])
        p[|r \ r+length(tmp)-1|] = tmp
        r = r + length(tmp)
    }
    V[p,] = V[p,]*0
    V[,p] = V[,p]*0
    st_replacematrix(st_local("Vx"),V)
}

void oaxaca()
{
    real scalar         i, j, se, k, lm, adjust, split, tf, detail
    real rowvector      b, b1, b2, B, x1, x2, keep, p
    real colvector      x1b1, x1b1o, x2b2, x2b2o, x1B, x2B, wgt1, wgt2
    real scalar         Fx1b1, Fx1b1o, Fx2b2, Fx2b2o, Fx1B, Fx2B
    real scalar         fx1b1, fx1b1o, fx2b2, fx2b2o, fx1B, fx2B
    real rowvector      fx1b1x, fx1b1xo, fx2b2x, fx2b2xo, fx1Bx, fx2Bx
    real matrix         X1, X2, V0, V, G, D, WE, dWE, WEn, WU, dWU, WUn, WI, dWI, WIn
    real scalar         WEd, WUd, WId
    string scalar       lblWE, lblWU, lblWI, vgrps
    string matrix       cstripe
    string rowvector    coefs, coefs0
    pointer scalar      F, f

    // model
    lm = 0
    if (st_local("cmd")=="regress") {
        if (st_local("linfast")=="") lm = 1
        F = &oaxaca_identity()
        f = &oaxaca_identityden()
    }
    else if (st_local("cmd")=="probit") {
        F = &oaxaca_normal()
        f = &oaxaca_normalden()
    }
    else /*if (st_local("cmd")=="logit")*/ {
        F = &oaxaca_logistic()
        f = &oaxaca_logisticden()
    }

    // collect stuff from Stata
    se      = (st_local("se")=="1")
    tf      = (st_local("threefold")!="") + (st_local("threefold2")!="")
    split   = (st_local("split")!="")
    detail  = (st_local("detail")=="")
    if (detail) vgrps = st_local("vgroups")
    coefs   = tokens(st_local("coefsadj"))
    coefs0  = tokens(st_local("coefs"))
    adjust  = (coefs!=coefs0)
    if (st_local("e_wexp")!="" & lm==0) {
        wgt1 = st_data(., st_local("w"), st_local("subpop1"))
        wgt2 = st_data(., st_local("w"), st_local("subpop2"))
    }
    else {
        wgt1 = wgt2 = 1
    }
    k = cols(coefs0)
    b1 = st_matrix(st_local("b0"))[|1 \ k|]
    b2 = st_matrix(st_local("b0"))[|k+1 \ 2*k|]
    B  = tf==0 ? st_matrix(st_local("b0"))[|2*k+1 \ 3*k|] : (tf==1 ? b2 : b1)
    i = 2 + (tf==0)
    x1 = st_matrix(st_local("b0"))[|i*k+1 \ (i+1)*k|]
    x2 = st_matrix(st_local("b0"))[|(i+1)*k+1 \ (i+2)*k|]
    if (lm) {
        X1 = x1; X2 = x2
    }
    else {
        st_view(X1, ., tokens(st_local("xvars")), st_local("subpop1"))
        st_view(X2, ., tokens(st_local("xvars")), st_local("subpop2"))
    }
    if (se) {
        V0 = st_matrix(st_local("V0"))
    }
    p = J(1, cols(coefs0), 1)
    if (adjust) {
        for (i=1; i<=k; i++) {
            p[i] = anyof(coefs, coefs0[i])
        }
    }

    // compute decomposition
    // - mean predictions and derivatives
    if (adjust) {
        x1b1o = X1 * b1'
        x2b2o = X2 * b2'
        Fx1b1o = mean((*F)(x1b1o), wgt1)
        Fx2b2o = mean((*F)(x2b2o), wgt2)
    }
    x1b1 = X1 * (b1 :* p)'
    x2b2 = X2 * (b2 :* p)'
    x1B  = X1 * ((tf ? b2 : B) :* p)'
    x2B  = X2 * ((tf ? b1 : B) :* p)'
    Fx1b1 = mean((*F)(x1b1), wgt1)
    Fx2b2 = mean((*F)(x2b2), wgt2)
    Fx1B  = mean((*F)(x1B), wgt1)
    Fx2B  = mean((*F)(x2B), wgt2)

    // - compute decomposition components
    if (detail) {
        //   o  W explained
        WEn = (x1 - x2) :* B :* p
        WEd = sum(WEn)^(1-lm)
        WEd = (WEd==0 ? WEd : 1/WEd)
        WE  = WEn * WEd
        if (adjust) WE  = select(WE, p)
        //   o  W unexplained 1 / coefficients
        if (tf==0 & split==0) WUn = (x1 :* (b1 - B) + x2 :* (B - b2)) :* p
        else if (split)       WUn = x1 :* (b1 - B) :* p
        else if (tf==1)       WUn = x2 :* (b1 - b2) :* p
        else /*if (tf==2)*/   WUn = x1 :* (b1 - b2) :* p
        WUd = sum(WUn)^(1-lm)
        WUd = (WUd==0 ? WUd : 1/WUd)
        WU  = WUn * WUd
        if (adjust) WU = select(WU, p)
        //   o  W unexplained 2 / interaction
        if (tf | split) {
            if (split)          WIn = x2 :* (B - b2) :* p
            else if (tf==1)     WIn = (x1 - x2) :* (b1 - b2) :* p
            else /*if (tf==2)*/ WIn = (x1 - x2) :* (b2 - b1) :* p
            WId = sum(WIn)^(1-lm)
            WId = (WId==0 ? WId : 1/WId)
            WI  = WIn * WId
            if (adjust) WI = select(WI, p)
        }
    }
    b = J(1, 0, .)
    if (adjust) b = b, Fx1b1o, Fx2b2o, Fx1b1o - Fx2b2o
    b = b, Fx1b1, Fx2b2, Fx1b1 - Fx2b2
    if (tf==0)            b = b, (Fx1B - Fx2B)
    else if (tf==1)       b = b, (Fx1B - Fx2b2)
    else /*if (tf==2)*/   b = b, (Fx1b1 - Fx2B)
    if (tf==0 & split==0) b = b, (Fx1b1-Fx1B)+(Fx2B-Fx2b2)
    else if (split)       b = b, (Fx1b1-Fx1B), (Fx2B-Fx2b2)
    else if (tf==1)       b = b, (Fx2B-Fx2b2), (Fx1b1 - Fx1B - Fx2B + Fx2b2)
    else /*if (tf==2)*/   b = b, (Fx1b1-Fx1B), (Fx1B - Fx1b1 - Fx2b2 + Fx2B)
    if (detail) {
        j = 4 + 3*adjust
        b = b, (WE * b[j]^(1-lm)), (WU * b[j+1]^(1-lm))
        if (split | tf)       b = b, (WI * b[j+2]^(1-lm))
    }

    // - variances: G*V0*G'
    if (se) {
        // derivatives
        if (adjust) {
            fx1b1o = mean((*f)(x1b1o), wgt1)
            fx2b2o = mean((*f)(x2b2o), wgt2)
            fx1b1xo = mean((*f)(x1b1o) :* X1, wgt1)
            fx2b2xo = mean((*f)(x2b2o) :* X2, wgt2)
        }
        fx1b1  = mean((*f)(x1b1), wgt1)
        fx2b2  = mean((*f)(x2b2), wgt2)
        fx1B   = mean((*f)(x1B), wgt1)
        fx2B   = mean((*f)(x2B), wgt2)
        fx1b1x = mean((*f)(x1b1) :* X1 :* p, wgt1)
        fx2b2x = mean((*f)(x2b2) :* X2 :* p, wgt2)
        fx1Bx  = mean((*f)(x1B) :* X1 :* p, wgt1)
        fx2Bx  = mean((*f)(x2B) :* X2 :* p, wgt2)
        // gradient matrix
        if (detail) {
            if (tf==0) dWE = J(k,k,0), J(k,k,0),
                diag((x1 - x2) * WEd) - (1-lm) * (WEn' * ((x1 - x2):*p)) * WEd^2,
                diag(B * WEd) - (1-lm) * (WEn' * (B:*p)) * WEd^2,
                diag(-B * WEd) - (1-lm) * (WEn' * (-B:*p)) * WEd^2
            else if (tf==1) dWE = J(k,k,0),
                diag((x1 - x2) * WEd) - (1-lm) * (WEn' * ((x1 - x2):*p)) * WEd^2,
                diag(b2 * WEd) - (1-lm) * (WEn' * (b2:*p)) * WEd^2,
                diag(-b2 * WEd) - (1-lm) * (WEn' * (-b2:*p)) * WEd^2
            else /*if (tf==2)*/ dWE =
                diag((x1 - x2) * WEd) - (1-lm) * (WEn' * ((x1 - x2):*p)) * WEd^2, J(k,k,0),
                diag(b1 * WEd) - (1-lm) * (WEn' * (b1:*p)) * WEd^2,
                diag(-b1 * WEd) - (1-lm) * (WEn' * (-b1:*p)) * WEd^2
            dWE = select(dWE, p')
            if (tf==0 & split==0) dWU =
                diag(x1 * WUd) - (1-lm) * (WUn' * (x1:*p)) * WUd^2,
                diag(-x2 * WUd) - (1-lm) * (WUn' * (-x2:*p)) * WUd^2,
                diag((-x1+x2) * WUd) - (1-lm) * (WUn' * ((-x1+x2):*p)) * WUd^2,
                diag((b1 - B) * WUd) - (1-lm) * (WUn' * ((b1 - B):*p)) * WUd^2,
                diag((B - b2) * WUd) - (1-lm) * (WUn' * ((B - b2):*p)) * WUd^2
            else if (split)       dWU =
                diag(x1 * WUd) - (1-lm) * (WUn' * (x1:*p)) * WUd^2, J(k,k,0),
                diag((-x1) * WUd) - (1-lm) * (WUn' * ((-x1):*p)) * WUd^2,
                diag((b1 - B) * WUd) - (1-lm) * (WUn' * ((b1 - B):*p)) * WUd^2, J(k,k,0)
            else if (tf==1)       dWU =
                diag(x2 * WUd) - (1-lm) * (WUn' * (x2:*p)) * WUd^2,
                diag((-x2) * WUd) - (1-lm) * (WUn' * ((-x2):*p)) * WUd^2, J(k,k,0),
                diag((b1 - b2) * WUd) - (1-lm) * (WUn' * ((b1 - b2):*p)) * WUd^2
            else /*if (tf==2)*/   dWU =
                diag(x1 * WUd) - (1-lm) * (WUn' * (x1:*p)) * WUd^2,
                diag((-x1) * WUd) - (1-lm) * (WUn' * ((-x1):*p)) * WUd^2,
                diag((b1 - b2) * WUd) - (1-lm) * (WUn' * ((b1 - b2):*p)) * WUd^2, J(k,k,0)
            dWU = select(dWU, p')
            if (tf | split) {
                if (split)          dWI =
                    J(k,k,0), diag(-x2 * WId) - (1-lm) * (WIn' * (-x2:*p)) * WId^2,
                    diag((x2) * WId) - (1-lm) * (WIn' * ((x2):*p)) * WId^2, J(k,k,0),
                    diag((B - b2) * WId) - (1-lm) * (WIn' * ((B - b2):*p)) * WId^2
                else if (tf==1)     dWI =
                    diag((x1 - x2) * WId) - (1-lm) * (WIn' * ((x1 - x2):*p)) * WId^2,
                    diag((x2 - x1) * WId) - (1-lm) * (WIn' * ((x2 - x1):*p)) * WId^2,
                    diag((b1 - b2) * WId) - (1-lm) * (WIn' * ((b1 - b2):*p)) * WId^2,
                    diag((b2 - b1) * WId) - (1-lm) * (WIn' * ((b2 - b1):*p)) * WId^2
                else /*if (tf==2)*/ dWI =
                    diag((x2 - x1) * WId) - (1-lm) * (WIn' * ((x2 - x1):*p)) * WId^2,
                    diag((x1 - x2) * WId) - (1-lm) * (WIn' * ((x1 - x2):*p)) * WId^2,
                    diag((b2 - b1) * WId) - (1-lm) * (WIn' * ((b2 - b1):*p)) * WId^2,
                    diag((b1 - b2) * WId) - (1-lm) * (WIn' * ((b1 - b2):*p)) * WId^2
                dWI = select(dWI, p')
            }
        }
        G = J(cols(b), rows(V0)+(k*(tf!=0)), .)
        i = 0
        if (adjust) {
            G[++i,.] = fx1b1xo,   J(1,k,0), J(1,k,0), fx1b1o:*b1, J(1,k,0)
            G[++i,.] = J(1,k,0),   fx2b2xo, J(1,k,0), J(1,k,0),   fx2b2o:*b2
            G[++i,.] = fx1b1xo,   -fx2b2xo, J(1,k,0), fx1b1o:*b1, -fx2b2o:*b2
        }
        G[++i,.] = fx1b1x,   J(1,k,0), J(1,k,0), fx1b1:*b1:*p, J(1,k,0)
        G[++i,.] = J(1,k,0),   fx2b2x, J(1,k,0), J(1,k,0),     fx2b2:*b2:*p
        G[++i,.] = fx1b1x,    -fx2b2x, J(1,k,0), fx1b1:*b1:*p, -fx2b2:*b2:*p
        if (tf==0) G[++i,.] = J(1,k,0), J(1,k,0), fx1Bx-fx2Bx, fx1B:*B:*p, -fx2B:*B:*p
        else {
            G = G[|1,1 \ .,2*k|], G[|1,3*k+1 \ .,.|]
            if (tf==1)
                G[++i,.] = J(1,k,0), fx1Bx-fx2b2x, fx1B:*b2:*p, -fx2b2:*b2:*p
            else /*if (tf==2)*/
                G[++i,.] = fx1b1x-fx2Bx, J(1,k,0), fx1b1:*b1:*p, -fx2B:*b1:*p
        }
        if (tf==0 & split==0)
            G[++i,.] = fx1b1x, -fx2b2x, -fx1Bx+fx2Bx, (fx1b1:*b1-fx1B:*B):*p,
                (fx2B:*B-fx2b2:*b2):*p
        else if (split) {
            G[++i,.] = fx1b1x  , J(1,k,0), -fx1Bx, (fx1b1:*b1-fx1B:*B):*p, J(1,k,0)
            G[++i,.] = J(1,k,0), -fx2b2x,   fx2Bx,  J(1,k,0), (fx2B:*B-fx2b2:*b2):*p
        }
        else if (tf==1) {
            G[++i,.] = fx2Bx, -fx2b2x, J(1,k,0), (fx2B:*b1-fx2b2:*b2):*p
            G[++i,.] = fx1b1x-fx2Bx, fx2b2x-fx1Bx, (fx1b1:*b1-fx1B:*b2):*p,
                (fx2b2:*b2-fx2B:*b1):*p
                //(Fx1b1 - Fx1B - Fx2B + Fx2b2)
        }
        else /*if (tf==2)*/ {
            G[++i,.] = fx1b1x, -fx1Bx, (fx1b1:*b1-fx1B:*b2):*p, J(1,k,0)
            G[++i,.] = fx2Bx-fx1b1x, fx1Bx-fx2b2x, (fx1B:*b2-fx1b1:*b1):*p,
                (fx2B:*b1-fx2b2:*b2):*p
        }
        if (detail) {
            j = 4 + 3*adjust
            G[|i+1,1 \ i+cols(WE),.|] = dWE :* b[j]^(1-lm) + (1-lm) * WE' * G[j,.]
            if (tf==0 & split==0) G[|i+1+cols(WE),1 \ .,.|] =
                dWU :* b[j+1]^(1-lm) + WU' * (1-lm) * G[j+1,.]
            else                  G[|i+1+cols(WE),1 \ .,.|] =
                (dWU :* b[j+1]^(1-lm) + WU' * (1-lm) * G[j+1,.]) \
                (dWI :* b[j+2]^(1-lm) + WI' * (1-lm) * G[j+2,.])
        }
        V = G * V0 * G'
    }

    // collapse into vgroups
    if (vgrps!="") {
        D = oaxaca_vgroups(coefs, vgrps) // modifies coefs
        if (split==0 & tf==0)
            D = blockdiag(diag(J(5+adjust*3,1,1)), blockdiag(D, D))
        else
            D = blockdiag(diag(J(6+adjust*3,1,1)), blockdiag(D, blockdiag(D, D)))
        b = b * D
        if (se) {
            V = D' * V * D
        }
        st_local("vgroups", vgrps)
    }

    // build colstripe and return
    lblWE = tf ? "endowments" : "explained"
    lblWU = tf ? "coefficients" : (split ? "unexplained1" : "unexplained")
    lblWI = tf ? "interaction" : "unexplained2"
    if (adjust) cstripe =
        (J(3,1,"overall") , ("group_1", "group_2", "difference")') \
        (J(5,1,"adjusted"), ("group_1", "group_2", "difference", lblWE, lblWU)')
    else cstripe =
        (J(5,1,"overall") , ("group_1", "group_2", "difference", lblWE, lblWU)')
    if (split | tf) cstripe = cstripe \ (cstripe[rows(cstripe),1], lblWI)
    if (detail) {
        cstripe = ( cstripe
            \ (J(cols(coefs), 1, lblWE), coefs')
            \ (J(cols(coefs), 1, lblWU), coefs') )
        if (split | tf) cstripe = cstripe \ (J(cols(coefs), 1, lblWI), coefs')
        keep = ((cstripe[,1]:!=lblWE :& cstripe[,1]:!="interaction")  :| cstripe[,2]:!="_cons")
        keep = ((cstripe[,1]:!=lblWU :& cstripe[,1]:!=lblWI) :| cstripe[,2]:!="_offset") :&
                keep:==1
        keep = b':!=0 :| keep:==1
        if (!all(keep)) {
            cstripe = select(cstripe, keep)
            b = select(b, keep')
            if (se) {
                V = select(V, keep')
                V = select(V, keep)
            }
        }
    }
    st_matrix(st_local("b"), b)
    st_matrixcolstripe(st_local("b"), cstripe)
    if (se) {
        st_matrix(st_local("V"), V)
        st_matrixcolstripe(st_local("V"), cstripe)
        st_matrixrowstripe(st_local("V"), cstripe)
    }
}

real matrix oaxaca_vgroups(
    string rowvector coefs,
    string scalar vgrps)
{
    real scalar      i, j, p, p1
    real colvector   keep
    real matrix      D
    string scalar    gname
    string rowvector groups, group, stripe

    groups = tokens(vgrps)
    stripe = coefs
    D = diag(J(1, cols(coefs), 1))
    keep = J(1, cols(D), 1)
    for (i=1; i<=cols(groups); i++) {
        gname = substr(groups[i], 1, strpos(groups[i], ":")-1)
        group = tokens(substr(groups[i], strpos(groups[i], ":")+1, .))
        p1 = 0
        for (j=1; j<=cols(group); j++) {
            p = oaxaca_which(coefs:==group[j]) // assuming one match (or none)
            if (length(p)<1) {
                display("{txt}("+gname+": "+group[j]+" not found)")
                group[j] = ""
                continue
            }
            if (p1==0) {
                p1 = p
                stripe[p1] = gname
            }
            else {
                D[p, p1] = 1
                keep[p] = 0
            }
        }
        group = select(group, group:!="")
        if (length(group)<1) groups[i] = ""
        else groups[i] = gname + ": " + oaxaca_invtokens(group)
    }
    groups = select(groups, groups:!="")
    vgrps = `"""' + oaxaca_invtokens(select(groups, groups:!=""), `"" ""') + `"""'
    coefs = select(stripe, keep)
    return(select(D, keep))
}

real matrix oaxaca_which(real vector I)
{
        if (cols(I)!=1) return(select(1..cols(I), I))
        else return(select(1::rows(I), I))
}

real matrix oaxaca_logistic(real matrix Z) return(1:/(1:+exp(-1*Z)))
real matrix oaxaca_logisticden(real matrix Z) return(exp(Z):/(1:+exp(Z)):^2)

real matrix oaxaca_normal(real matrix Z) return(normal(Z))
real matrix oaxaca_normalden(real matrix Z) return(normalden(Z))

real matrix oaxaca_identity(real matrix Z) return(Z)
real matrix oaxaca_identityden(real matrix Z) return(J(rows(Z), cols(Z), 1))

end
