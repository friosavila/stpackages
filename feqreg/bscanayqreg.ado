*! v1 Feb 2024 by Fernando Rios Avila
* This version will just be a wrapper around Canayqreg to more easily allow for bootstrap.
*capture program drop bsrifhdreg
*capture program drop results

program define bscanayqreg, eclass

    if replay() {
		results
        exit
    }
	
	syntax anything(everything) , [Reps(int 50) STRata(varlist) seed(string) ///
			bca TIEs  cluster(varname) idcluster(string) ///
			nodots level(int 95)  force * ]

 	capture noisily bootstrap, reps(`reps') strata(`strata') seed(`seed') `bca' `ties' ///
				noheader notable ///
			   cluster(`cluster') idcluster(`idcluster') `dots' level(`level') `force': ///
			   canayqreg `anything', `options' bs
	if _rc==0 {
		display "Canay (2021) Qregression with FE" _n ///
		"Quantile: `e(quantile)'"
		
		bootstrap
	}		   
	ereturn local cmd     bscanayqreg
	ereturn local cmdline bscanayqreg `0'
 
end

program results, eclass
        if "`e(cmd)'"=="bscanayqreg"  {
			display "Canay (2021) Qregression with FE"
			bootstrap
		}
		else {
			display in red "last estimates not found"
			error 301
		}
end
