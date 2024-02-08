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
			nodots level(int 95)  force * parallel parallel_cluster(int 2) ///
			Quantile(numlist >0 <100) ]
				
	if "`quantile'"=="" local quantile = 50
			
	if "`parallel'"=="" {
		capture noisily bootstrap, reps(`reps') strata(`strata') seed(`seed') `bca' `ties' ///
					noheader notable ///
				    cluster(`cluster') idcluster(`idcluster') `dots' level(`level') `force': ///
					canayqreg `anything', `options' bs q(`quantile')
		if _rc==0 {
		    display "Canay (2021) Qregression with FE" _n ///
			    "Quantile: `e(quantile)'"			
			bootstrap
		}	
		ereturn local bscmd bs
	}	
	else {
		parallel initialize `parallel_cluster'
				
		qui: parallel bs, reps(`reps') strata(`strata') seed(`seed') `bca' `ties' ///
				    cluster(`cluster') idcluster(`idcluster') `dots' level(`level') `force': ///
					canayqreg `anything', `options' bs q(`quantile')
					
		if _rc==0 {
		    display "Canay (2021) Qregression with FE" _n ///
					"Quantile: `quantile'"			
			parallel bs
		}	
		ereturn local bscmd parallelbs
	}
		   
	ereturn local cmd     bscanayqreg
	ereturn local quantile `quantile'      
	ereturn local cmdline bscanayqreg `0'
	
end

program results, eclass
        if "`e(cmd)'"=="bscanayqreg" & "`e(bscmd)'"=="bs" {
			display "Canay (2021) Qregression with FE"
			bootstrap
		}
		else if "`e(cmd)'"=="bscanayqreg" & "`e(bscmd)'"=="parallelbs" {
			display "Canay (2021) Qregression with FE"
			parallel bs
		}
		else {
			display in red "last estimates not found"
			error 301
		}
end
