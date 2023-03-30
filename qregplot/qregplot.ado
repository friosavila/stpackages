*! version 1.22  (Marcj 2023) Small changes to SIVQR weights, Ifs and ins
* version 1.21  (Feb 2023) Adds smqreg and sivqr
* version 1.2  (Dec 2022) Options for Other Range plots
* version 1.1  (APR 2022) Adds new options and default
* version 1.05  (Feb 2022) adds Name
* version 1.04  (August 2021) Modify stripper
* version 1.03  (April 2021) when requesting Constant, Only constant will comeup
* version 1.02  (March 2021) More Bug with Weights.
* version 1.01  (Feb 2021) Bug with Weights.
* version 1.0  (Feb 2021) By Fernando Rios-Avila
* Inspired  by grqreg (Pedro Azevedo)
* This is an attempt to "update" grqreg by allowing for factor notation,
* providing more flexibility in how plots are generated. (and how are options used)
* and allowing the command to be used after other commands including mmqreg, qrprocess and rifhdreg (for uqreg)


** This little piece of code "prevents"  loosing all!
program define qregplot, rclass
	syntax [varlist( fv default=none)], [*]
	local crnst  `c(rngstate)'
	tempname lastreg
	capture:est store `lastreg'
	capture noisily grqreg_x `0'
	if _rc !=0 {
		display in red "If the above message is not useful, please contact me at friosa@gmail.com"
	}
	if runiform()<.001 {
		display "{p}This is just for fun. My wife suggested calling this program " /// 
		"the Noranator, because of my dog Morkie Nora. Also if you are reading this, it means you are lucky," ///
		"only 0.1% of people using this program will see this message/Easter Egg {p_end}"
	}
	qui:est restore `lastreg'
	set rngstate `crnst' 
end

program define grqreg_x, rclass
	
	if c(stata_version) >= 11  {
    syntax [varlist( fv default=none)]             ///
        [,                          ///
        Quantile(string asis)            /// defines list of quantiles 
        cons                        /// Indicates to plot constant
        ols olsopt(string asis)          /// If one wants OLS results
        RAopt(string asis) 				///	Options for RArea plot
		LNopt(string asis)               /// Options for Line
		grcopt(string asis)              /// Options for GRcombine plot
		TWOpt(string asis) 				/// Options for two way plot
		seed(string asis)			    /// If one uses bsreg
		savemat							/// If one wants to save the results as matrices in r()
		estore(string asis)				/// If one wants to save the results in e() (est store)
		esave(string asis)				/// If one wants to save the results as str (est save)
		from(string asis)				/// if you have stored coefficients
		label					    	/// 
		labelopt(string asis) *    		///
		MTITLEs(passthru)  ]
		/// Mtitles, when wanting to add titles to all other options
		*name(passthru)              ///
		*        ]
	}
	if c(stata_version) < 11  {
		display in red "You need at least Stata 11.0 to run this command"
		error 9
	}
	
	*** Does your system has it???
	
	qui:capture which ftools
	if _rc==111 {
			display in red "Community-contributed command " as result "ftools" in red "is needed"
			display as text "You can install it using {stata ssc install ftools}"
			error 111
	}
		
	if "`from'"!="" {
	    ** idea.. if we can do from memory, we save time and money!!
		est restore `from'
		if "`e(cmd)'"=="qregplot" {
			if "`varlist'"!="" {
				ms_fvstrip `varlist', expand dropomit
				local vlist `r(varlist)'
				is_vlist_in_xlist, vlist(`vlist') xlist(`e(xlist)')
			}
			qrgraph ,  `cons'  `e(ols)' raopt(`raopt') lnopt(`lnopt') grcopt(`grcopt')  twopt(`twopt') ///
							matrixlist(e(qq) e(bs) e(ll) e(ul)) matrixols(e(bso) e(llo) e(ulo)) ///
							vlist(`vlist') xlist(`e(xlist)') `label' labelopt(`labelopt') `options' `mtitles'
		}		
		
		exit
	}
		
	if !inlist("`e(cmd)'","qreg","bsqreg","mmqreg","rifhdreg","qrprocess","sqreg") & ///
		!inlist("`e(cmd)'","bsrifhdreg","qreg2","xtqreg","ivqreg2","smqreg","sivqr")	{
	    display in red "This command can only be used after -qreg- ,-bsqreg-, -sqreg-, -mmqreg- or -rifhdreg- " _n ///
						"-bsrifhdreg-, -qreg2-, -qrprocess-, -xtqreg-, -ivqreg2-, `smqreg' " _n
						"If you have suggestions for adding other -quantile/type- regressions, contact me at friosa@gmail.com"
		error 10
	}
	/*else {
	    tempname lastreg
	    estimates store `lastreg'
	}*/
	
	** Gathering information
	** Get command line
	if "`quantile'"!="" {
		mynlist "`quantile'"
		local qlist `r(numlist)'
	}
	else {
	    mynlist "10(5)90"
		local qlist `r(numlist)'
	}
	
	if inlist("`e(cmd)'","qreg","bsqreg","mmqreg","qrprocess") | ///
	   inlist("`e(cmd)'","qreg2","xtqreg","ivqreg2" ) {
	    local xvars `=subinstr("`e(cmdline)'","`e(cmd)'","",1)'
	 	qui:qreg_stripper `xvars'
		** estimate all variables
		local cmd  `e(cmd)'
		local xvar `r(xvar)'
		local yvar `r(yvar)'
		local qnt  `r(qnt)'
		local oth  `r(oth)'
		local ifin `r(ifin)'
		local wgt  `r(wgt)'
		
	}
	** Modify so it can also capture instruments...
	if inlist("`e(cmd)'","smqreg") {
	    local xvars `=subinstr("`e(cmdline)'","`e(cmd)'","",1)'
	 	qui:qreg_stripper `xvars'
		** estimate all variables
		local cmd  `e(cmd)'
		local xvar `r(xvar)'
		local yvar `r(yvar)'
		local qnt  `r(qnt)'
		local oth  `r(oth)'
		local ifin `r(ifin)'
		local wgt  `r(wgt)'
		
	}
	if inlist("`e(cmd)'","sivqr") {
	    ** estimate all variables
		local cmd  `e(cmd)'
		local xvar `e(exogr)'
		local evar `e(instd)'
		local yvar `e(depvar)'
		local zvar `e(insts)'
		local qnt  `e(q)'
		local oth  `e(oth)'
		local ifin `e(ifin)'
		local wgt  [`e(wtype)'`e(wexp)']

		
	}
	if inlist("`e(cmd)'","sqreg") { 
		tempname aux2
	    local xvars `=subinstr("`e(cmdline)'","`e(cmd)'","",1)'
		qui:ereturn display
		matrix `aux2'=r(table)
	    qui:sqreg_stripper `xvars'
		local cmd  `e(cmd)'
		local xvar `r(xvar)'
		local yvar `r(yvar)'
		local ifin `r(ifin)'
		local wgt  `r(wgt)'		
		local n_q `e(n_q)' 
		local eqnames `e(eqnames)'
		forvalues iq=1/`n_q' {
		    local q_s `q_s' `e(q`iq')'
		}	
	}
	if inlist("`e(cmd)'","rifhdreg","bsrifhdreg") {
		
	    local xvars `=subinstr("`e(cmdline)'","`e(cmd)'","",1)'
	    qui:rifhdreg_stripper `xvars'
		local cmd  `e(cmd)'
		local xvar `r(xvar)'
		local yvar `r(yvar)'
		local qnt  `r(q)'
		local qopt `r(qopt)'
		local oth  `r(oth)'
		local ifin `r(ifin)'
		local wgt  `r(wgt)'
	
	}
 
	
	
	** verify variables in list exist.
	ms_fvstrip `xvar' `evar', expand dropomit
	local xlist `r(varlist)'
		
	if "`varlist'"!="" {
		ms_fvstrip `varlist', expand dropomit
		local vlist `r(varlist)'
		is_vlist_in_xlist, vlist(`vlist') xlist(`xlist')
	}
	
	** check if bsqreg
	
	** estimate all qreg
	tempvar aux bs   ll  ul qq
	tempvar     bso  llo ulo  
	if "`ols'"!="" {
	    tempname olsaux
		qui:regress `yvar' `xvar' `ifin' `wgt',  `olsopt'
		matrix `olsaux'=r(table)
	}
	**********************************************************
	if inlist("`cmd'","rifhdreg","bsrifhdreg") {
		foreach q of local qlist {
			qui:`cmd' `yvar' `xvar' `ifin' `wgt',  `oth' rif(q(`q' `qopt')) 
			matrix `aux'=r(table)
			matrix `qq'=nullmat(`qq') \ `q' 
			matrix `bs'=nullmat(`bs') \ `aux'["b" ,"`qtc':"]
			matrix `ll'=nullmat(`ll') \ `aux'["ll","`qtc':"]
			matrix `ul'=nullmat(`ul') \ `aux'["ul","`qtc':"]
			if "`ols'"!="" {
				matrix `bso'=nullmat(`bso') \ `olsaux'["b" ,":"]
				matrix `llo'=nullmat(`llo') \ `olsaux'["ll",":"]
				matrix `ulo'=nullmat(`ulo') \ `olsaux'["ul",":"]
			}
		}
	}
	*************************************************
	if "`cmd'"=="mmqreg" {
	    local qtc "qtile"
	}
	
	if inlist("`cmd'","qreg","bsqreg","mmqreg") {
	    foreach q of local qlist {
			if "`cmd'"=="bsqreg" {
				if "`seed'"!="" set seed `seed'		
			}
			qui:`cmd' `yvar' `xvar' `ifin' `wgt',  `oth' q(`q')
			matrix `aux'=r(table)
			matrix `qq'=nullmat(`qq') \ `q' 
			matrix `bs'=nullmat(`bs') \ `aux'["b" ,"`qtc':"]
			matrix `ll'=nullmat(`ll') \ `aux'["ll","`qtc':"]
			matrix `ul'=nullmat(`ul') \ `aux'["ul","`qtc':"]
			if "`ols'"!="" {
				matrix `bso'=nullmat(`bso') \ `olsaux'["b" ,":"]
				matrix `llo'=nullmat(`llo') \ `olsaux'["ll",":"]
				matrix `ulo'=nullmat(`ulo') \ `olsaux'["ul",":"]
			}
		}
	}
	******************************************
	if inlist("`cmd'","qrprocess","qreg2","xtqreg","ivqreg2") {
	    foreach q of local qlist {
		    local qrq = `q'/100
			
 			qui:`cmd' `yvar' `xvar' `ifin' `wgt',  `oth' q(`qrq')
			qui:ereturn display
			matrix `aux'=r(table)
			matrix coleq `aux'=""
			matrix `qq'=nullmat(`qq') \ `q' 
			matrix `bs'=nullmat(`bs') \ `aux'["b" ,"`qtc':"]
			matrix `ll'=nullmat(`ll') \ `aux'["ll","`qtc':"]
			matrix `ul'=nullmat(`ul') \ `aux'["ul","`qtc':"]
			if "`ols'"!="" {
				matrix `bso'=nullmat(`bso') \ `olsaux'["b" ,":"]
				matrix `llo'=nullmat(`llo') \ `olsaux'["ll",":"]
				matrix `ulo'=nullmat(`ulo') \ `olsaux'["ul",":"]
			}
		}
	}
	******************************************
	if inlist("`cmd'","smqreg") {
		local bw0 = `e(bw)'		
		tempname binit
		foreach q of local qlist {
			local cnt = `cnt'+1
			if `cnt'==1 qui:qreg `yvar' `xvar' `ifin' `wgt',  q(`q') 
			matrix `binit' = e(b)
		    qui:`cmd' `yvar' `xvar' `ifin' `wgt',  `oth' q(`q') bw(`bw0') from(`binit')
			*qui:`cmd' `yvar' `xvar' `ifin' `wgt',  `oth' q(`q') bw(`bw0') 
			matrix `binit' = e(b)
			
			qui:ereturn display
			matrix `aux'=r(table)
			matrix coleq `aux'=""
			matrix `qq'=nullmat(`qq') \ `q' 
			matrix `bs'=nullmat(`bs') \ `aux'["b" ,"`qtc':"]
			matrix `ll'=nullmat(`ll') \ `aux'["ll","`qtc':"]
			matrix `ul'=nullmat(`ul') \ `aux'["ul","`qtc':"]
			if "`ols'"!="" {
				matrix `bso'=nullmat(`bso') \ `olsaux'["b" ,":"]
				matrix `llo'=nullmat(`llo') \ `olsaux'["ll",":"]
				matrix `ulo'=nullmat(`ulo') \ `olsaux'["ul",":"]
			}
		}
	}
	
	if inlist("`cmd'","sivqr") {
		tempname binit
		matrix `binit' =e(b)
		
	    foreach q of local qlist {
			local cnt = `cnt'+1
		    local qrq = `q'/100			
			
			if "`evar'"!="" qui:sivqr `yvar' `xvar' (`evar' = `zvar') `ifin' `wgt',  `oth' q(`qrq') init("`binit'")		
			else            qui:sivqr `yvar' `xvar'                   `ifin' `wgt',  `oth' q(`qrq') init("`binit'")		
			matrix `binit' =e(b)
			qui:ereturn display
			matrix `aux'=r(table)
			matrix coleq `aux'=""
			matrix `qq'=nullmat(`qq') \ `q' 
			matrix `bs'=nullmat(`bs') \ `aux'["b" ,"`qtc':"]
			matrix `ll'=nullmat(`ll') \ `aux'["ll","`qtc':"]
			matrix `ul'=nullmat(`ul') \ `aux'["ul","`qtc':"]
			if "`ols'"!="" {
				matrix `bso'=nullmat(`bso') \ `olsaux'["b" ,":"]
				matrix `llo'=nullmat(`llo') \ `olsaux'["ll",":"]
				matrix `ulo'=nullmat(`ulo') \ `olsaux'["ul",":"]
			}
		}
	}
	****
	if inlist("`cmd'","sqreg") {
	    forvalues iq = 1/`n_q' {
		    local q:word `iq' of `q_s'
			local q=`q'*100
			local qtc:word `iq' of `eqnames'
			matrix `qq'=nullmat(`qq') \ `q' 
			matrix `bs'=nullmat(`bs') \ `aux2'["b" ,"`qtc':"]
			matrix `ll'=nullmat(`ll') \ `aux2'["ll","`qtc':"]
			matrix `ul'=nullmat(`ul') \ `aux2'["ul","`qtc':"]
			if "`ols'"!="" {
				matrix `bso'=nullmat(`bso') \ `olsaux'["b" ,":"]
				matrix `llo'=nullmat(`llo') \ `olsaux'["ll",":"]
				matrix `ulo'=nullmat(`ulo') \ `olsaux'["ul",":"]
			}
		}
	}
	******************************************
	qrgraph ,  `cons'  `ols' raopt(`raopt') ///
			   lnopt(`lnopt') grcopt(`grcopt') ///
			   twopt(`twopt') ///
	   			matrixlist(`qq' `bs' `ll' `ul') ///
				matrixols( `bso' `llo' `ulo') ///
				xlist(`xlist') vlist(`vlist') ///
				`label' labelopt(`labelopt') `options' `mtitles'
	 
	
 	if "`estore'"!="" {
	    estore, qq(`qq') bs(`bs') ll(`ll') ul(`ul') xlist(`xlist') ///
				bso(`bso') llo(`llo') ulo(`ulo') `ols' cmdqreg(`cmd')
		est store `estore'
	}
	
	if "`esave'"!="" {
	    estore, qq(`qq') bs(`bs') ll(`ll') ul(`ul') xlist(`xlist') ///
		        bso(`bso') llo(`llo') ulo(`ulo') `ols' cmdqreg(`cmd')
		est save `esave'
	}
	
	
end

program define estore, eclass
	syntax, xlist(string) qq(string) bs(string) ll(string) ul(string) cmdqreg(string) ///
		    [bso(string) llo(string) ulo(string)  ols]
	tempname b
	matrix `b'=1
	ereturn post `b'
	ereturn local cmd qregplot
	ereturn local cmdqreg `cmdqreg'
	ereturn local xlist `xlist'
	ereturn matrix qq `qq'
	ereturn matrix bs `bs'
	ereturn matrix ll `ll'
	ereturn matrix ul `ul'
	if "`ols'"!="" {
	    ereturn matrix bso `bso'
		ereturn matrix llo `llo'
		ereturn matrix ulo `ulo'
	    ereturn local ols ols
	}
	
end

program define mynlist,rclass
        syntax anything, 
        numlist `anything',  range(>0 <100) sort
        loca j scalar(_pi)
        foreach i in  `r(numlist)' {
                if `i'!=`j' {
                    local numlist `numlist' `i'
                } 
                local j=`i'
        }
        return local numlist `numlist'
end

program define is_vlist_in_xlist
syntax , vlist(str) xlist(str)
	foreach i of local vlist {
	    local flag=0
	    foreach j of local xlist {
		    if "`i'"=="`j'" {
			    local flag=1
			}
		}
		if `flag' == 0 {
		    display in red "Error, variable `i' not found in varlist"
			error 1
		}
	}
end 

program define qreg_stripper, rclass
	syntax anything [if] [in] [aw iw pw fw], [Quantile(string)] *
	gettoken yvar xvar:anything  
	*local xvar `=subinstr("`anything'","`e(depvar)'","",1)' 
	*local yvar `e(depvar)'
	local qnt  `quantile'
	local oth  `options'
	local ifin `if' `in'
	if "`weight'`exp'"!="" local wgt  [`weight'`exp']
	return local xvar `xvar'
	return local yvar `yvar'
	return local oth  `oth'
	return local ifin `ifin'
	return local wgt `wgt'
end

program define rifhdreg_stripper, rclass
	syntax anything [if] [in] [aw iw pw fw], rif(str)  [*]
	gettoken yvar xvar:anything  
	*local xvar `=subinstr("`anything'","`e(depvar)'","",1)' 
	*local yvar `e(depvar)'
	local oth  `options'
	local ifin `if' `in'
	if "`weight'`exp'"!="" local wgt [`weight'`exp']
	local rif  `rif'
	rif_stripper, `rif'
	
	return local xvar `xvar'
	return local yvar `yvar'
	return local oth  `oth'
	return local ifin `ifin'
	return local wgt `wgt'
	return local q    `r(q)'
	return local qopt `r(oth)'
end

program define rif_stripper, rclass
	syntax , q(numlist) [*]
	return local q    `q'
	return local oth  `options'
end

program define sqreg_stripper, rclass
	syntax anything [if] [in] [aw iw pw fw], [*]
	
	gettoken yvar xvar:anything  
	*local xvar `=subinstr("`anything'","`e(depvar)'","",1)' 
	*local yvar `e(depvar)'
	local ifin `if' `in'
	if "`weight'`exp'"!="" local wgt  [`weight'`exp']
	
	return local xvar `xvar'
	return local yvar `yvar'
	return local ifin `ifin'
	return local wgt `wgt'
end

program define short_local, rclass
	syntax, llocal(string asis) [maxlength(integer 20) lines(integer 1)]
	local lng = length("`llocal'")
	
	local dlt2 = round(`lng'/`lines')
	local dlt = max(`maxlength',`dlt2')
	/*if "`maxlength'"!="" {
		local dlt `maxlength'
	}
	if "`lines'"!="" {
		local dlt = round(`lng'/`lines')
	}*/
	scalar out=""
	local cnt =1
	local low =1
	while ((`low')<=`lng') {		
		local cnt=`cnt'+1
		local dlt0 = `dlt'
		while (substr("`llocal'",`low'+`dlt0',1)!=" ") & ((`low'+`dlt0')<= `lng') {
			local dlt0=`dlt0'+1
		}
		*display substr("`llocal'",`low',`dlt0')
		local aux =strtrim(substr("`llocal'",`low',`dlt0'))
		local out "`out' "`aux'""
		local low =`low'+`dlt0'+1
	}
	forvalues x=`cnt'/`lines' {
		local out "`out' "  ""
	}
	
	local out ""`out'
	return local out `out'""
end

program define label_var_lab, rclass
	syntax, var(string asis) [label]
	local dot = strpos("`var'",".")
	local b_dot = substr("`var'",1,`=`dot'-1')
	local a_dot = substr("`var'",`=`dot'+1',.)
	** Option 1: Value label
	
	if "`label'"!="" {
		capture:local lout1:variable label `a_dot'
		if "`lout1'"!="" & _rc==0 {
			if "`b_dot'"!="" {
				capture:local lout2:label (`a_dot') `b_dot'
				local lout1 "`lout1': `lout2'"
			}
			else {
				local lout1 "`lout1'"
			}
		}
		else if "`lout1'"=="" & _rc==0 {
			capture:local lout2:label (`a_dot') `b_dot', strict
			if "`lout2'"=="" & _rc==0 {
				local lout1 "`a_dot':`b_dot'"
			}
			else if "`lout2'"!="" {
				local lout1 `lout2'
			}
		}
		else if "`lout1'"=="" | _rc!=0 {
			local lout1 `var'
		}
	}
	else local lout1 `var'
	*********************************
	
	if "`lout1'"=="" {
			local lout1 `var'
		}
	** Option 2: Variable label
 return local labout `lout1'
end

program raopt_default, rclass
	syntax, [pstyle(passthru) fintensity(passthru) lwidth(passthru) *]
	if `"`pstyle'"'     == "" local pstyle pstyle(p1)
	if `"`fintensity'"' == "" local fintensity fintensity(30)
	if `"`lwidth'"'     == "" local lwidth lwidth(none)
	return local ropt `pstyle' `fintensity' `lwidth' `options'
end

program lnopt_default, rclass
	syntax, [pstyle(passthru) lwidth(passthru)  *] 
	if `"`pstyle'"'     == "" local pstyle pstyle(p1)
	if `"`lwidth'"'     == "" local lwidth lwidth(0.3)
	return local ropt `pstyle' `lwidth' `options'
end

program reg_default, rclass
	syntax, [margin(string asis) * ]
	if `"`margin'"'=="" local margin margin(vsmall)
 
	return local ropt `margin' `options'
end

program twopt_default, rclass
	syntax, [graphregion(string asis) plotregion(string asis) * ]
	reg_default, `graphregion'
	local graphregion graphregion(`r(ropt)')
	reg_default, `plotregion'
	local plotregion plotregion(`r(ropt)')
	return local ropt `plotregion'  `graphregion' `options'
end


program define qrgraph,
*[varlist( fv default=none)]             
	syntax ///
			, matrixlist(str) matrixols(str) xlist(string)  ///
			[ vlist(string) cons  ols raopt(str asis ) lnopt(str asis ) ///
			   grcopt(str asis )	twopt(str asis ) ///
			   mtitles(str asis)    ///
			   rplot(string) ///
			   label labelopt(str asis )   *]
			
if "`rplot'"=="" local rplot rarea				
	/*
			qrgraph `varlist',  from(`from') `cons'  `e(ols)' raopt(`raopt') lnopt(`lnopt') grcopt(`grcopt')  twopt(`twopt') ///
							matrixlist(e(qq) e(bs) e(ll) e(ul)) matrixols(e(bso) e(llo) e(ulo)) xlist(`e(xlist)')
	*/
	tokenize `matrixlist'		
	tempname qq bs ll ul bso llo ulo 
	matrix `qq'=`1'
	matrix `bs'=`2'
	matrix `ll'=`3'
	matrix `ul'=`4'
	* drop colname
	matrix coleq `qq'=""
	matrix coleq `bs'=""
	matrix coleq `ll'=""
	matrix coleq `ul'=""
	
	if "`ols'"!="" {
	    tokenize `matrixols'		
		matrix `bso'=`1'
		matrix `llo'=`2'
		matrix `ulo'=`3'
	}
	
	/*if "`varlist'"!="" {
 		ms_fvstrip `varlist', expand dropomit
		local vlist `r(varlist)'
		is_vlist_in_xlist, vlist(`vlist') xlist(`xlist')
	}*/
	
	local cnt =0
	if "`vlist'"=="" & "`cons'"=="" {
	    local vlist `xlist'
	}    
 
 ********
 *** Default options
	raopt_default, `raopt'
	local raopt `r(ropt)'
	lnopt_default, `lnopt'
	local lnopt `r(ropt)'
	
	twopt_default, `twopt'
	local twopt `r(ropt)'
	
	*ms_fvstrip `fxvar', expand dropomit
	*local vlist `r(varlist)'
	
	if "`cons'"!= "" {
	   local vlist `vlist' _cons
	}
	************************************
	 
    local gcnt: word count `vlist'
 	tempname sols sbs
	
	local nmtitle:word count `mtitles'
	
	foreach v of local vlist {
		local cnt = `cnt' + 1
		matrix `sbs' = `qq',`bs'[....,"`qtc':`v'"],`ll'[....,"`qtc':`v'"],`ul'[....,"`qtc':`v'"]
		svmat `sbs'
		** if OLS is requested
		if "`ols'"!="" {
			matrix `sols'=`bso'[....,"`v'"],`llo'[....,"`v'"],`ulo'[....,"`v'"]
			svmat `sols'
			local olsci (line `sols'1 `sols'2 `sols'3 `sbs'1, lpattern(solid - -) lcolor(black gs5 gs5) )
 
		}
		** label variables
		
		if `cnt' > `nmtitle' {
			local vlab
			label_var_lab , var(`v') `label'
			local vlab `r(labout)'
			if "`v'"=="_cons" local vlab Intercept
			short_local, llocal(`vlab') `labelopt'
			local vlab "`r(out)'"
		}
		else {
			local vlabx:word `cnt' of `mtitles'
			if "`vlabx'"==" " {
				display "here"
				label_var_lab , var(`v') `label'
				local vlabx `r(labout)'
			}
			short_local, llocal(`vlabx') `labelopt'
			local vlab "`r(out)'"
		}
		
		****		
		label var `sbs'1 "Quantile"
		tempname m`cnt'
		
		if `gcnt'>1 {

			twoway  (`rplot' `sbs'3 `sbs'4 `sbs'1 , `raopt' ) || ///
				   (line `sbs'2 `sbs'1, lp(solid) `lnopt') `olsci' , ///
				   name(`m`cnt'', replace) legend(off) nodraw ///
				   title(`vlab') `twopt' 
			local grcmb	 `grcmb' `m`cnt''
		}
		else {
		
		    twoway  (`rplot' `sbs'3 `sbs'4 `sbs'1 , `raopt' ) || ///
				   (line `sbs'2 `sbs'1, lp(solid) `lnopt') `olsci' , ///
				   legend(off)   ///
				   title(`vlab') `twopt'  `options'
		}
		qui:drop `sbs'*	   
		capture drop `sols'*
	}
	
	if `gcnt'>1 {
 		graph combine `grcmb', `grcopt'  `options'
		graph drop `grcmb'
	}
	
	/*capture:est restore `lastreg'*/
	
end

