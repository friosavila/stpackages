* v1.2.1  CRE Improvements on Options Keep drop
* v1.2.0  CRE Correlated RE model. Allows for two word commands and long vars
* v1.1.1  CRE Correlated RE model. Allows for Fracreg
* v1.1  CRE Correlated RE model. Drops unnecessary Means
* does not work with "complex" heckman, because that requires different variables. 

* requires reghdfe
*capture program drop cre
*capture program drop myhdmean
*capture program drop cre_opt
program define cre, properties(prefix)
	set prefix cre
	gettoken first second : 0, parse(":")
	if "`first'"==":" {
		`second' 
	}
	else {
		cre_opt `first'
		local felist `r(felist)'
		local prefix `r(prefix)'
		local keep   `r(keep)'
		local replace `r(replace)'
		local keepsingletons `r(keepsingletons)'
        local hdfe    `r(hdfe)'
		local exclude `r(exclude)'
		local compact  `r(compact)'
		
		gettoken other cmd0 : second, parse(" :")

		** Improvement for ANY comd
		gettoken cmd 0: cmd0
		
		local nx 1
		while `nx' {
			syntax anything [if] [in] [aw iw fw pw], [*]
			capture _iv_parse `0'
			if _rc!=0 {
				gettoken cmd2 0: 0	
				local cmd `cmd' `cmd2'
			}
			else local nx 0
		}
		 
		local x `s(exog)'   `s(inst)' `s(endog)' 
		local y `s(lhs)' 
		marksample touse
		markout `touse' `felist' `x'  `y'
 		***
  
		myhdmean `x' if `touse' [`weight'`exp'], ///
            abs(`felist') prefix(`prefix') `compact' `keepsingletons' `replace' ///
            hdfe(`hdfe') exclude(`exclude')
            
		local vlist `r(vlist)'
		`cmd' `anything' `vlist'  `if' `in' [`weight'`exp'], `options'
        adde local m_list `vlist'
		if "`keep'"==""{
			drop `vlist'
		}
		
	}
end

program cre_opt, rclass
	syntax , abs(varlist) [drop prefix(name) compact dropsingletons replace hdfe(string asis) exclude(string asis)]
	if "`prefix'"=="" local prefix m
	return local felist `abs'
	return local prefix `prefix'
    if "`drop'"=="" return local keep   keep
    if "`dropsingletons'"=="" return local keepsingletons   keepsingletons
    
	return local compact    `compact'
	return local replace    `replace'
    return local hdfe       `hdfe'
    return local exclude    `exclude'
end 

program myhdmean, rclass
	syntax anything [if] [aw iw pw fw], abs(varlist) prefix(name) ///
        [compact  keepsingletons replace hdfe(string asis) exclude(string asis)]
	
	ms_fvstrip `anything' `if', expand dropomit
	local vvlist `r(varlist)'
    if "`exclude'"!="" {
        ms_fvstrip `exclude' `if', expand 
        local evlist `r(varlist)'
    }
    ** check if vvlist is not in evlist
    foreach i of local vvlist {
        local is_in = 1
        foreach j of local evlist {
            if "`i'"=="`j'" local is_in = 0
        }
        if `is_in'==1 {
            local v2list `v2list' `i'
        }
    }
    
	** First check and create
	foreach i of local v2list {
    
		local icnt = `icnt'+1
		capture confirm variable `i'
		if _rc!=0 {
			 local vn = strtoname("`i'")
			if length("`vn'")>30 	local vn _v`icnt'
            capture drop `vn'
			gen double `vn'=`i'
			label var `vn' "`i'"
			local dropvlist `dropvlist' `vn'
		
		}
		else local vn `i'
		
		local vflist `vflist' `vn'
	}
	***
	
	if "`compact'"=="" {
		foreach i in `vflist' {
			local vplist
			local cnt
			local fex
			foreach j of varlist `abs' {
				local cnt=`cnt'+1
				capture drop `prefix'`cnt'_`i'
				local fex    `fex'    `prefix'`cnt'_`i'=`j'
				local vplist `vplist' `prefix'`cnt'_`i'
			}
			qui:reghdfe `i' `if'  [`weight'`exp'], abs(`fex')  `keepsingletons' resid verbose(-1) `hdfe'
			label var `prefix'`cnt'_`i' "`:variable label `i''"
			qui:sum _reghdfe_resid, meanonly
			if abs(`r(max)'-`r(min)')>epsfloat() local vlist `vlist' `vplist'
			else  local dropvlist `dropvlist' `vplist'
		}
		
		local vflist `vlist'
		local vlist
		foreach i in `vflist' {
			sum `i', meanonly
			if abs(`r(max)'-`r(min)')>epsfloat() local vlist `vlist' `i'
			else local dropvlist `dropvlist' `i'
		}
		
		return local vlist  `vlist'
	}
	else {
		foreach i in  `vflist' {
			local cnt
			local fex
			local vplist
			capture drop `prefix'`cnt'_`i'
			qui:reghdfe `i' `if'  [`weight'`exp'], abs(`abs') resid `keepsingletons' verbose(-1) `hdfe'
			qui:sum _reghdfe_resid, meanonly
			if abs(`r(max)'-`r(min)')>epsfloat() {
				qui:gen double `prefix'`cnt'_`i'=`i'-_reghdfe_resid-_cons
				local vlist `vlist' `prefix'`cnt'_`i'
			}
 			qui:drop _reghdfe_resid			
		}
		
		/*local vflist `vlist'
		local vlist
		foreach i in `vflist' {
			sum `i', meanonly
			if abs(`r(max)'-`r(min)')>epsfloat() local vlist `vlist' `i'
			else local dropvlist `dropvlist' `i'
		}*/
		return local vlist   `vlist'
	}
	*display in w "`dropvlist'"
	if "`dropvlist'"!="" drop `dropvlist'
	qui:capture:drop _reghdfe_resid	
end

program adde, eclass
	ereturn `0'
end
*cre,   abs( age isco) :reg lnwage educ exper tenure  [w=wt]
*reghdfe lnwage educ exper tenure  [w=wt], abs(age isco)
