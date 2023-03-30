*! v1 Feb 2021 by Fernando Rios Avila
* This version will just be a wrapper around RIFHDREG to more easily allow for bootstrap.
*capture program drop bsrifhdreg
*capture program drop results

program define bsrifhdreg, eclass

    if replay() {
		results
        exit
    }
	
	syntax anything(everything) , [Reps(int 50) STRata(varlist) seed(string) ///
			bca TIEs  cluster(varname) idcluster(string) ///
			nodots level(int 95)  force *]
	
	bootstrap, reps(`reps') strata(`strata') seed(`seed') `bca' `ties' ///
			   cluster(`cluster') idcluster(`idcluster') `dots' level(`level') `force': ///
			   rifhdreg `anything', `options'
	ereturn local cmd bsrifhdreg
	ereturn local cmdline bsrifhdreg `0'
end

program results, eclass
        if "`e(cmd)'"=="bsrifhdreg" & "`e(cmdx)'"=="" {
			ereturn local cmd ="regress"
			regress 
			display "Distributional Statistic: `e(rif)'"
			display "Sample Mean	RIF `e(rif)' : "  in ye %7.5g e(rifmean)
		}
		else if "`e(cmd)'"=="bsrifhdreg" & "`e(cmdx)'"=="rifhdreg2"  {
			ereturn local cmd ="reghdfe"
			reghdfe
			ereturn local cmd="bsrifhdreg"
			display "Distributional Statistic: `e(rif)'"
			display "Sample Mean	RIF `e(rif)' : "  in ye %7.5g e(rifmean)
		}
		else {
			display in red "last estimates not found"
			error 301
		}
end