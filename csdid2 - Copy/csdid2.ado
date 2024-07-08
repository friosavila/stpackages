*! v1.3 Allows for Reg2 and drimp2: hdidregress compatible
*! v1.21 Allows for treatvar
*! v1.2  Allows for Anticipation
*! v1.13 Cluster Corrections for RCS and RC
*! v1.12 Adds Option for CSname
*! v1.11 Corrects For missing in cluster
*! v1.1 adds Rolling
*! v1 Wrapper for CSDID2-Mata version

program csdid2, sortpreserve eclass
        version 14
        ///version checker
        syntax [anything(everything)] [iw aw pw], [* version estat ///
                                                    save clear load replace plot csname(name)]
        if "`save'`clear'`load'`replace'"!="" {
            
            exit
        }
        
        if "`estat'"!="" {
            csdid2_estat `anything', `options'
            exit
        }

        if "`plot'"!="" {
            csdid2_plot, `options'
            exit
        }
        
        if  "`version'"!="" {
            display "version: 1"
            addr scalar version = 1
            exit
        }
        
        ///Replay
        
        if replay() {
                if `"`e(cmd)'"' != "csdid2" { 
                        error 301
                }
                else {
                        Display `0'
                }
                exit
        }
        if runiform()<.001 {
                easter_egg
        }
        
        csdid_r `0'

end

program define easter_egg
        display "This Easter Egg is Broken, but try not to get lost"
end


 mata
    
    void balance(string scalar ivar,
                 string scalar tvar,
                 string scalar touse){
        real matrix i, t
        real scalar ntt, ni, nt, max
        st_view(i=.,.,ivar,touse)
        st_view(t=.,.,tvar,touse)
        ntt=rows(i)
        ni=rows(uniqrows(i))
        nt=rows(uniqrows(t))
        max = max(uniqrows((i,t),1)[,3])
        if (max>1) {
            _error(451, "repeated time values within panel")
        }
        if ( (ni*nt) > ntt) {
            stata(`"display in red "Panel is not balanced""')
            stata(`"display in red "Will use observations with Pair balanced (observed at t0 and t1)""')
        }
 
    }
end

program _gcsgvar, sortpreserve
    syntax newvarname =/exp [if] [in], tvar(varname) ivar(varname)
    local exp = subinstr("`exp'","(","",.)
    local exp = subinstr("`exp'",")","",.)
    tempvar touse
    qui:gen byte `touse'=0
    qui:replace `touse'=1 `if' `in'
    qui:replace `touse'=0 if `tvar'==. | `ivar'==. | `exp'==.
    tempvar vals
    sum `exp' if `touse' , meanonly
    local lmin=r(min)
    local lmax=r(max)
    
    if `lmin'<0 | `lmax'>1 {
            display in r "`exp' can only have values between 0 and 1"
            error 4444
    }
    qui: {
        tempvar aux auxd
        qui: gen byte `auxd'=`exp'>0 if `exp'!=.
        bysort `touse' `ivar' `auxd':egen `aux'=min(`tvar')
        replace `aux'=0 if `exp'==0
        by     `touse' `ivar':egen `varlist'=max(`aux')
        replace `varlist'=. if `exp'==. | !`touse'
    }
    label var `varlist' "Group Variable based on `exp'"
end
 program csdid_r, sortpreserve eclass
    syntax varlist(fv ) [if] [in] [aw pw iw/],                 /// Basic syntax  allows for weights
                            [Ivar(varname numeric) group(varname)]         ///
                            [TIme(varname numeric)]          ///
                            [Tvar(varname numeric)]          ///
                            [Gvar(varname numeric) trtvar(varname)]          /// 
                            [cluster(varname numeric)         /// 
                            notyet                             /// att_gt basic option. May prepare others as Post estimation
                            method(str)                      ///
                             long long2                        /// to allow for "long gaps"
                             asinr                            /// For pretreatment
                             agg(string)                    /// type of aggregation
                             rolljw                            /// Rolling Regression Estimator
                             csname(name)                    /// To change name to csobj
                             short                             /// for compatability
                             antici(int 0)                  /// anticipation
                            ]  
    ** Checking if Setup
     local issetup:char _dta[csdid2]
    if "`issetup'"=="csdid2" {
        local tvar:char _dta[tvar]
        local gvar:char _dta[gvar]
        local ivar:char _dta[ivar]
    }
     ** Marking Sample        
    if "`csname'"=="" local csname csdid
    marksample touse
    ** First determine outcome and xvars
    gettoken y xvar:varlist
    ** Is time set?
    if "`time'`tvar'"=="" {
        display in red "Option tvar() or time() is required"
        error 198
    }
    else {
        // Tvar will superseed time
        if "`tvar'"=="" local tvar `time'
    }    
    ** is gvar or trtvar set?
    if "`gvar'`trtvar'"=="" {
        display in red "option gvar/trtvar() required"
        error 198
    }
    else if "`trtvar'"!="" & "`gvar'"!="" {
        display as error "You can only specify gvar or trtvar. Not both"        
        error 198
    }
    else if "`trtvar'"!="" {
        capture drop __gvar
        if "`ivar'`group'"=="" display "You need to specifcy {it: ivar()} for panel or {it: group()} for Repeated Crossection"
        else {
            if "`ivar'"!="" local iivar "`ivar'"
            else  local iivar "`group'"
            
        }
        qui:_gcsgvar __gvar=`trtvar', tvar(`tvar') ivar(`iivar') 
        local gvar __gvar
    }
    *** OLD for SHORT
    if "`short'"=="" {
        local long long
        display "Producing Long Gaps by default"
    }    
    else {
        local long
    }
    
    
    markout `touse' `ivar' `tvar' `gvar' `y' `xvar' `cluster'
    local wvar `exp'

    ** Aggregation
    if "`agg'"!="" & inlist("`agg'","simple","attgt","event","calendar","group") {
        if "`agg'"=="simple" local aggtype 2
        if "`agg'"=="attgt"  local aggtype 1
        if "`agg'"=="event"  local aggtype 5
        if "`agg'"=="calendar" local aggtype 4
        if "`agg'"=="group"    local aggtype 3 
    }

    ** Verifying basics
    if "`method'"=="" {
        local method dripw
        if "`xvar'"=="" {
            local method reg
        }
    }
    else if !inlist("`method'","drimp","dripw","reg","reg2","drimp2","stdipw") {
        display in red "Method `method' not allowed"
        error 1
    }
    ** What method is being used
    display "Using method `method'"
    
    ** Always Treated Excluded
    qui: sum `touse', meanonly
    local pre_mean `r(mean)'
    sum `tvar' if `touse', meanonly    
    qui:replace `touse'=0 if `gvar'<`r(min)' & `gvar'>0
    
    qui: sum `touse', meanonly
    local post_mean `r(mean)'
    
    if `pre_mean'!=`post_mean' display "Always Treated units have been excluded"
        
    ** is gvar nested iwthing county
    if "`ivar'"!="" {
        _xtreg_chk_cl2 `gvar' `ivar' `touse'
    }
    ** is cluster correct?
    if "`cluster'"!="" {
        if "`ivar'"!="" _xtreg_chk_cl2 `cluster' `ivar' `touse'
        ** else _xtreg_chk_cl2  `gvar' `cluster' `touse'
    }
    ** Is a balanced panel?
    if "`ivar'"!="" {
        mata:balance("`ivar'","`tvar'","`touse'")    
    }
    *** Here we SETUP CSDID
    // Create the Mata Object
    local cvar `cluster'
                    mata:`csname'=csdid()
                    mata:`csname'.setup_yvar("`y'"    ,"`touse'")
                    mata:`csname'.setup_tvar("`tvar'" ,"`touse'")
                    mata:`csname'.setup_gvar("`gvar'" ,"`touse'")
    if "`xvar'"!="" mata:`csname'.setup_xvar("`xvar'" ,"`touse'")
    if "`ivar'"!="" mata:`csname'.setup_ivar("`ivar'" ,"`touse'")
    if "`wvar'"!="" mata:`csname'.setup_wvar("`wvar'" ,"`touse'")    
    if "`cvar'"!="" mata:`csname'.setup_cvar("`cvar'" ,"`touse'")    
    ** Setup as panel or rc
    mata:`csname'.csdid_setup()
    ** 
    ** For Anticipation
    mata:`csname'.antici=`antici'
     
    ** Rolling Regression
    if "`rolljw'"!="" mata:`csname'.rolljw = 1
    
    // Type_est  1 dripw 2 drimp 3 stipw 4 reg 
    // not_yet   0 Never 1 Notyet
    // shrt      1 short 0 long
    // asinr     0 stata 1 R
        
         if "`method'"=="dripw"  local type_est=1
    else if "`method'"=="drimp"  local type_est=2
    else if "`method'"=="stdipw" local type_est=3
    else if "`method'"=="reg"    local type_est=4
    else if "`method'"=="reg2"   local type_est=5
    else if "`method'"=="drimp2" local type_est=6

    
    
    local ntyet = 0
    if "`tyet'"!=""  local ntyet = 1
    local shrt = 1
    
    if "`long'"!=""  local shrt  = 0
    local asr= 0
    if "`asinr'"!="" local asr   = 1
    // Setup CSDID Type of estimation. Allowing Reg2 and Drimp2
    mata:`csname'.csdid_type(`type_est',`ntyet',`shrt',`asr')    
    // Get all GTs 
    mata:`csname'.gtvar()
    // Estimate Model
    mata:`csname'.csdid()
    // Done 
    ereturn clear
    ereturn local cmd         csdid2
    ereturn local cmdline     csdid2 `0'    
    ereturn local estat_cmd csdid2_estat    
    ereturn local method     `method'
    ereturn local asinr      `asinr'        
    
    if "`aggtype'"!="" {
        mata:csdidstat=csdid_estat()
        mata:csdidstat.init()
        mata:csdidstat.test_type=`aggtype'
        mata:csdidstat.atts_asym(`csname')
        ereturn post _bb _vv
        ereturn local vcetype Robust
        ereturn local cmd         csdid2
        ereturn local cmdline     csdid2 `0'    
        ereturn local estat_cmd csdid2_estat    
        ereturn local method     `method'
        ereturn local asinr     `asinr'    
        if "`cvar'"!="" ereturn local cluster `cvar'
        Display
    }
    

    if `ntyet'==1 ereturn  local cntrl "Not yet treated"
    else          ereturn  local cntrl "Never treated"
    if `shrt'==1  ereturn  local base  "Varying Base"
    else          ereturn  local base  "Base Universal"        
end

program define _S_Me_thod, sclass
        if ("`e(method)'"=="drimp") {
                local tmodel "inverse probability tilting"
                local omodel "weighted least squares"
        }
        if ("`e(method)'"=="dripw") {
                local tmodel "inverse probability"
                local omodel "least squares"
        }
        if ("`e(method)'"=="reg") {
                local tmodel "none"
                local omodel "regression adjustment"
        }
        if ("`e(method)'"=="reg2") {
                local tmodel "none"
                local omodel "regression adjustment: RC2"
        }
        if ("`e(method)'"=="drimp2") {
                local tmodel "inverse probability tilting"
                local omodel "WLS: From RC2 reg2"
        }
        if ("`e(method)'"=="stdipw") {
                local tmodel "stabilized inverse probability"
                local omodel "weighted mean"
        }
        sreturn local omodel "`omodel'"
        sreturn local tmodel "`tmodel'"
end

program define Display
                syntax [, bmatrix(passthru) vmatrix(passthru) *]
                
        _get_diopts diopts rest, `options'
        local myopts `bmatrix' `vmatrix'        
                if ("`rest'"!="") {
                                display in red "option {bf:`rest'} not allowed"
                                exit 198
                }
                 _S_Me_thod
                 local omodel "`s(omodel)'"
                local tmodel "`s(tmodel)'"
                
                if ("`e(method)'"!="all") {
                        _coef_table_header, title(Difference-in-difference with Multiple Time Periods) 
                        noi display as text "Outcome model  : {res:`omodel'}"
                        noi display as text "Treatment model: {res:`tmodel'}"
                }
                
                if ("`e(vcetype)'"=="WBoot") {
                    if "`e(clustvar)'"!="" {                        
                        display as text "(Std. err. adjusted for" ///
                        as result %9.0gc e(N_clust) ///
                        as text " clusters in " as result e(clustvar) as text ")"
                    }
                    csdid_table, `diopts'
                }
                else {
                    _coef_table,  `diopts' `myopts'
                }
                
 
end
    
