*! v1.0 April 2020 Fernando Rios-Avila 
* GH survival model estimator for repeated crossection data
*capture program drop ghsurv
*capture program drop results_ghsurv
program ghsurv, eclass sortpreserve
    if replay() {
		if "`e(cmd)'"=="ghsurv"   results_ghsurv
		else {
			display "last estimates not found"
			exit 301
		}
        exit
		
    }
syntax varlist(fv) [if] [in] [aw pw iw fw], [method(str) gap(varname) alpha(varlist fv) cluster(varname) ///
											 BASElevels ALLBASElevels	* ] 
	marksample touse
	markout    `touse' `gap' `cluster'
	*gettoken y x:`varlist'
	** mlmodel here
	local method=strtrim("`method'")
	if "`method'"=="" local method logit
	if "`method'"!="logit" &  "`method'"!="probit"  & "`method'"!="cloglog"  {
	    display in red "Method `method' does not exist" 
		exit 1
	}
	*** expand and generate 
	if "`cluster'"=="" local cluster _id
	ml model lf gh`method' (_y01 `gap'=`varlist') (alpha:=`alpha') if `touse' [`weight'`exp'], maximize `options' cluster(`cluster')
	display in w "`vsquish' `emptycells' `baselevels' `allbaselevels' `nofvlabel'"
	results_ghsurv,  `baselevels' `allbaselevels' 
	ereturn local cmd ghsurv
	ereturn local cmdline ghsurv `0'
	ereturn local title "Guel-Hu regression"
	ereturn local method `method'
	ereturn local predict ghsurv_p
end

program results_ghsurv, 
	syntax , [baselevels allbaselevels]
	display _n as text "Guell-Hu regression" _n "Survival model with pooled cross-section data"
	display _col(60) as text  "N obs:     " as result e(N)
	display _col(60) as text  "N clusters:" as result e(N_clust)
	ereturn display,  `baselevels' `allbaselevels' 
end
