*! v1. FRA 
program define clrreturn, rclass
        exit
end

program define adde, eclass
        ereturn `0'
end

program define addr, rclass
		return add
        return `0'
end

program define adds, sclass
        sreturn `0'
end

 program define csdid2_estat, sortpreserve    
	version 14
		syntax anything, [* plot]
        capture mata:csdid
		if _rc!=0   error 301
 		gettoken key rest : 0, parse(", ")
		
		if inlist("`key'","attgt","simple","pretrend","group","calendar","event","cevent") {
			csdid_do `key' `rest'
			addr local cmd  estat
			addr local cmd2 csdid2
			if "`plot'"!="" csdid2_plot ,  ktype(`ktype') `options'
		}
		else if inlist("`key'","plot") {
			csdid2_plot, `options'
		}
		else {
		    display in red "Option `key' not recognized"
			error 199
		}
		
end

 program define csdid_do, rclass
	syntax namelist(min=1 max=1 ), [ estore(name) ///
					esave(name) replace ///
					post level(int 95)  ///
					WBOOT				///
					WBOOT1(str)			///
					reps(integer 999) 	///
					rseed(string) 		///
					wbtype(string)		///
					rgroup(numlist)     ///
					rcalendar(numlist) /// 
					revent(numlist)    ///
					REBALance(numlist)    /// <-- restricts groups and event, unless event is used too
					max_mem(real 1)  plot  * ]
	
	// confirm csdid exists and if csdidstat=csdid_estat()
	local key `namelist'
	capture mata:csdidstat
	if _rc!=0 mata:csdidstat=csdid_estat()
	
	// check Keys
	
	if "`key'"=="pretrend" local ktype = 0
	if "`key'"=="attgt"    local ktype = 1
	if "`key'"=="simple"   local ktype = 2
	if "`key'"=="group"    local ktype = 3
	if "`key'"=="calendar" local ktype = 4
	if "`key'"=="event"    local ktype = 5 
	if "`key'"=="cevent"   local ktype = 6
	
	/// initialize
	if "`rseed'"!="" set seed `rseed'
	
	mata: csdidstat.cilevel = `level'/100
	mata: csdidstat.bwtype  = 1      
	mata: csdidstat.reps    = `reps'
	mata: csdidstat.max_mem = `max_mem'
	mata: csdidstat.range.selgvar = J(0,0,.)
	mata: csdidstat.range.seltvar = J(0,0,.)
	mata: csdidstat.range.selevent= J(0,0,.)
	mata: csdidstat.range.selbal  = J(0,0,.)
	
	/// Check if we have to make sample selection
	
	if "`rgroup'"!="" {
		 numlist "`rgroup'", int
		 mata:csdidstat.range.selgvar=csdidstat.rtokens("`r(numlist)'")
	}
	if "`rcalendar'"!="" {
		 numlist "`rcalendar'", int
		 mata:csdidstat.range.seltvar=csdidstat.rtokens("`r(numlist)'")
	}
	if "`revent'"!="" {
		 numlist "`revent'", int
		 mata:csdidstat.range.selevent=csdidstat.rtokens("`r(numlist)'")
	}
	if "`rebalance'"!="" {
		 
		 numlist "`rebalance'", int
		 
		 mata:csdidstat.range.selbal=csdidstat.rtokens("`r(numlist)'")
	}	
	if `ktype'>0 		mata: csdidstat.test_type  = `ktype'      
	else {
		mata: csdidstat.pretrend(csdid)
		display "Pre-trend test"
		display "H0: All ATTGT=g for all T<G"
		display "chi2(`r(df)') = " %10.4f scalar(chi2_)
		display "p-value  = " %10.4f scalar(pchi2_)	
		return   scalar chi2  = scalar(chi2_)
		return   scalar pchi2 = scalar(pchi2_)	
		return   scalar df    = scalar(df_)	
		exit
	}
	
	if "`wboot'`wboot1'"=="" {
		mata:csdidstat.atts_asym(csdid)
		
		capture:est store `lastreg'	
		ereturn clear
		return matrix b = _bb, copy
		return matrix V = _vv, copy
		
		adde post _bb _vv
		adde local cmd 	   csdid2
		adde local estat_cmd csdid2_estat	
		//syntax namelist(min=1 max=1 ), [*]
		adde local cmdline estat  `0'
		adde local agg     `key'
		adde local aggt     `ktype'
 		
		if "`estore'"!="" est store `estore'
		if "`esave'" !="" est save  `esave', `replace'
		_coef_table, level(`level')
		matrix rtb=r(table)
		
		if "`post'"=="" qui:capture:est restore `lastreg'

		return matrix table = rtb, copy
		return local agg  `key'
		
	}
	else {
		mata:csdidstat.atts_wboot(csdid)
		
		capture:est store `lastreg'	
		ereturn clear
		return matrix table = _table, copy
 		tempname bb
		matrix `bb' = _table[1,....]
		return matrix b = `bb', copy
		adde post `bb'
		adde matrix table1 = _table, copy
		adde local vcetype WBoot
		adde local cmd 	   csdid2
		adde local estat_cmd csdid2_estat
		
		//syntax namelist(min=1 max=1 ), [*]
		adde local cmdline estat `0'
		adde local agg     `key'
		
		csdid_tablex, `diopts' level(`level')	
		display "WildBootstrap Standard errors"	_n ///
				"with `reps' Repetitions"
		tempname	rtb 	
		matrix `rtb' = r(table)
	
		if "`post'"=="" capture:qui:est restore `lastreg'
		return matrix table = `rtb', copy
		return local agg  `key'
		
	}

	return local cmd csdid2_estat
		
	*if "`plot'"!="" {	    
	*    csdid2_plot ,  ktype(`ktype') `options'
	*}
	*capture matrix drop rtb 
end
 
program define  tsvmat2, return
        syntax anything, name(string)
        version 7
		 
        local nx = rowsof(matrix(`anything'))
        local nc = colsof(matrix(`anything'))
        ***************************************
        // here is where the safegards will be done.
        if _N<`nx' {
            display as result "Expanding observations to `nx'"
                set obs `nx'
        }
        // here we create all variables
        foreach i in `name' {
			local j = `j'+1
			qui:gen `type' `i'=matrix(`anything'[_n,`j'])			
        }
        // here is where they are renamed.

end


program define csdid_tablex, rclass 
	syntax [, level(int `c(level)') noci cformat(string) sformat(string) *]

	_get_diopts diopts rest, `options'

	local cf %9.0g  
	local pf %5.3f
	local sf %7.2f

	if ("`cformat'"!="") {
			local cf `cformat'
	}
	if ("`sformat'"!="") {
			local sf `sformat'
	}
***hack to get max
 tempname tablex
 matrix `tablex' = _table'
 local namelist : colname `tablex'
 local wdt=0
 foreach i of local namelist {
 	if length("`i'")>`wdt' local wdt = length("`i'")+3
 }
 if `wdt'<15 local wdt = 12
***
        tempname mytab b se z t  ll ul cimat rtab
        .`mytab' = ._tab.new, col(6) lmargin(0)
        .`mytab'.width    `wdt'   |12    12     8         12    12
        .`mytab'.titlefmt  .     .     .   %6s       %24s     .
        .`mytab'.pad       .     2     1     0          3     3
        .`mytab'.numfmt    . %9.0g %9.0g %7.2f    %9.0g %9.0g

		
		local stat t 
		
        local namelist : rowname `tablex'		
        local eqlist : roweq `tablex'
        local k : word count `namelist'
		local knew = `k'
		matrix `rtab' = J(9, `k', .)
		matrix `cimat'= `tablex'
		* pvalue
		matrix rownames `rtab' = b se t p ll ul df crit eform
		matrix colnames `rtab' = `namelist'
		forvalues i = 1/`k' {
		    local kxc: word `i' of `eqlist'
			if ("`kxc'"=="wgt") {
				local knew = `knew' -1
			}
			matrix `rtab'[1,`i'] = `cimat'[`i',1]
			matrix `rtab'[2,`i'] = `cimat'[`i',2]
			matrix `rtab'[3,`i'] = `cimat'[`i',3]
			matrix `rtab'[5,`i'] = `cimat'[`i',4]
			matrix `rtab'[6,`i'] = `cimat'[`i',5]
			matrix `rtab'[8,`i'] = `cimat'[`i',6]
		}
        .`mytab'.sep, top
        if `:word count `e(depvar)'' == 1 {
                local depvar "`e(depvar)'"
        }
        .`mytab'.titles "`depvar'"                      /// 1
                        " Coefficient"                  /// 2
                        "Std. err."                     /// 3
                        "`stat'"                        /// 4   "P>|`stat'|"                    /// 5
                        "[`level'% conf. interval]" ""  //  6 7
		
        forvalues i = 1/`knew' {
                local name : word `i' of `namelist'
                local eq   : word `i' of `eqlist'
                if ("`eq'" != "_") {
                        if "`eq'" != "`eq0'" {
                                .`mytab'.sep
                                local eq0 `"`eq'"'
                                .`mytab'.strcolor result  .  .  .  .    .
                                .`mytab'.strfmt    %-12s  .  .  .  .    .
                                .`mytab'.row      "`eq'" "" "" "" ""  ""
                                .`mytab'.strcolor   text  .  .  .  .    .
                                .`mytab'.strfmt     %12s  .  .  .  .    .
                        }
                        local beq "[`eq']"
                }
                else if `i' == 1 {
                        local eq
                        .`mytab'.sep
                }
				
                scalar `b' = `cimat'[`i',1]
				scalar `se' = `cimat'[`i',2]
				scalar `t' = `cimat'[`i',3]
				scalar `ll'   = `cimat'[`i',4]
				scalar `ul'   = `cimat'[`i',5]
                .`mytab'.row    "`name'"                ///
                                `b'         ///
                                `se'        ///
                                `t'                     /// `p'  ///
                                `ll' `ul'
        }
        .`mytab'.sep, bottom
		return matrix table = `rtab'
end
