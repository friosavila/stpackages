*! v1.1 July 7 RIFmean FRA. Correts weights
* v1 512021 RIFmean FRA
** THis is a small wrapper for mean command to allow for the use of RIF functions

program rifmean, eclass 
    if replay() {
	    if "`e(cmd)'"=="rifmean" {
		    ereturn local cmd mean
			mean
			ereturn local cmd rifmean
			local vlist `e(vlist)'
			foreach i of local vlist {
				display "`i': `:variable label `i''" 
			}
		}	
        exit
    } 
syntax varname [if] [in] [aw fw iw pw  ] , [* over(varname) rif(string) scale(real 1) ] 
	marksample touse
	markout `touse' `over'
	local exp2 = regexr("`exp'", "=", "")
	 
	local rifrest `rif'
	** This Loops over all possible rifs
	capture drop rif_`varlist'_*
	while "`rifrest'"!="" {
		tokenize "`rifrest'", parse(",")
		local word `1'
		if "`word'"!="," {
			local cnt=`cnt'+1
			qui:egen double rif_`varlist'_`cnt'=rifvar(`varlist') if `touse', ///
				weight(`exp2') seed(`iseed') by(`over') `word'
			qui:replace rif_`varlist'_`cnt'=rif_`varlist'_`cnt'*`scale'
			local vlist `vlist' rif_`varlist'_`cnt'
		}
		macro shift
		local rifrest `*'
		
	}
	
	/*foreach i of varlist `varlist' {
	    capture drop _rif_`i'
		qui:egen double _rif_`i'=rifvar(`i') if `touse', by(`over') `rif' weight(`exp2')
		qui:replace _rif_`i'=_rif_`i'*`scale'
		
	}*/
	
	mean `vlist' [`weight'`exp'] `if' `in', `options' over(`over')
	foreach i of local vlist {
	    display "`i': `:variable label `i''" 
	}
	ereturn local vlist `vlist'
	ereturn local cmd rifmean
	ereturn local cmdline rifmean `0'
end
