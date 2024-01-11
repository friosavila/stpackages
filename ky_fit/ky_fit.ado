*! v2.5 2022-6 (fra): Adding LL 9. Model No missmatch but errors in admin data (noise)
* v2.4 2022-4-14 (fra): changing to Stata v14 and adding * for other options for ML not yet specified. Use with care.
* v2.3 2022-2-1 (fra): adding option iter
* v2.2 2020-12-28 (fra): adding option for weights
* v2.1 2020-07-15 (fra): Adds an option so it automatically creates ll when has not been declared. Delta is used for the same purposes
* v2.0 2020-07-15 (fra): Adds Option Repeat to all instances of the estimation. default will be repeat(0)
* 2020-07-14 (fra): This is a temp file: adds model 8. Like model 5 but with correlation between w_i and e_i
* 2020-07-12 (fra): Corrects for typo on model 7. arho_w=arho_w 
* 2020-07-11 (fra): Adds model 7. Correlation between w_i and e_i
* 2020-07-10b (fra): adds hidden macros with varlist in lpi_r lpi_s  lpi_w lpi_v
* 2020-07-10 (fra): Modified ereturn to include not only "model name" in method, but model number in e(model)
* 2020-07-09 (fra): Small bug on Model 4. Was not Copying initial values correctly.
* 2020-07-07b(fra): added Cluster option
* 2020-07-07 (fra): Bug corrected for "robust". Does not affect results, but called for "robust" estimation.
* 2020-04-29 (fra): Revised all LogL functions. Corrected LL for Extended model and adding one for 6th model.
* 2020-01-22 (fra): added option for covariates on all parameters. Baselevels and All base levels should work
* 2020-01-22 (spj): added fv functionality and baselevels allbaselevels options 
* 2020-12 (fra): original program code

program ky_fit, eclass
version 14
    if replay() {
		results_ky
        exit
    }

	 
syntax varlist(min=2 max=3 numeric) [if] [in] [aw iw fw pw], 	[model(int 1)   /// This indicate which one of the 6 models to be estimated. 
	mu_e(varlist fv ts) ln_sig_e(varlist fv ts) /// Mean and log(sigma) for true latent income e_i
	mu_n(varlist fv ts) ln_sig_n(varlist fv ts) /// Mean and log(sigma) for error that adds to RTM survey
	mu_w(varlist fv ts) ln_sig_w(varlist fv ts) /// Mean and log(sigma) for error additional contamination to RTM survey
	mu_t(varlist fv ts) ln_sig_t(varlist fv ts) /// Mean and log(sigma) for mismatched data
	mu_v(varlist fv ts) ln_sig_v(varlist fv ts) /// Mean and log(sigma) for error that adds to RTM Admin data
    arho_s(varlist fv ts) arho_r(varlist fv ts) /// This are the elements for RTM for "survey s" or "admin data r"
	arho_w(varlist fv ts) /// correlation between w and e
	lpi_r(varlist fv ts) /// Prob mismatch in r
	lpi_s(varlist fv ts) /// prob correctly reporting s 
	lpi_w(varlist fv ts) /// Prob added contamination in s 
	lpi_v(varlist fv ts) /// Prob RTM in r. Last options is for "reporting"
	from(string) ITERate(passthru)   /// Changed option init to from to be comparable to other ML stata commands
	CONSTraints(passthru)   /// adds constrains
	TECHnique(passthru) SEArch(passthru) /// Modifies Maximization technique, and allows for "searching on off"
	Repeat(int 0)                    /// Adds "repeat" option
	robust cluster(varname) trace         /// Allows for reporting Robust Standard errors and uses Trace
	BASElevels ALLBASElevels DIFFicult  /// may add other options as needed here
	delta(real 0) *	]
	* Parsing variables of interest. RR is for admin SS for survey and LL for cases we consider them to be "the same"
	local rr:word 1 of `varlist'
	local ss:word 2 of `varlist'
	local ll:word 3 of `varlist'
	** if ll was not declared...created one.
	if "`ll'"=="" {
		tempvar ll
		capture drop __ll__
		gen byte __ll__= abs(`rr'-`ss')<=`delta'
		local ll __ll__
		label var __ll__ "Completely labelled group with delta `delta' "
	}
	
	* marking sample
	marksample touse 
	markout `touse' `mu_e'     `mu_n'     `mu_w'     `mu_t'     `mu_v'  ///
					`ln_sig_e' `ln_sig_n' `ln_sig_w' `ln_sig_t' `ln_sig_v' ///
					`arho_s' `arho_r' `arho_w' `lpi_r' `lpi_s' `lpi_w' `lpi_v' 
				
	* Confirm Method. If not provided method=1 (int 1)
	capture numlist "`model'", min(1) max(1)  range(>=1 <=9)
	if _rc!=0 {
		display in red "Method selected not available. Please choose between 1 to 7"
		exit 999
	}
 	
	*** Estimation 	based on method
	if "`model'"=="1" {
    ** This will be the basic method
		if "`from'"!=""  {
			ml model lf ky_ll_1 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
								(mu_n:=`mu_n') 			///
								(ln_sig_e:=`ln_sig_e')  ///
								(ln_sig_n:=`ln_sig_n')  ///
								(arho_s:=`arho_s') 		///
								(lpi_s :=`lpi_s')  if `touse' [`weight'`exp'], ///
								 `technique' init(`from') ///
								`robust' cluster(`cluster') `trace' maximize  `constraint' ///
								`baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate' `options'
		}
		else {
		* If no initial values are provided. we get some basic initial values.
		   qui:sum `rr' if `touse'  
		   local r_mean=r(mean)
		   local r_sd=r(sd)
		   tempvar rf_sf
		   qui:gen double `rf_sf'=`rr'-`ss' if `touse'
		   qui:sum `rf_sf' if `touse' 
		   local lsn=log(r(sd))
		   local rs_mean=log(r(sd))
		   ml model lf ky_ll_1 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
								(mu_n:=`mu_n') ///
								(ln_sig_e:=`ln_sig_e') ///
								(ln_sig_n:=`ln_sig_n') ///
								(arho_s:=`arho_s')     ///
								(lpi_s:=`lpi_s')   if `touse' [`weight'`exp'] , ///
								`technique' init(mu_e:_cons=`r_mean' ln_sig_e:_cons=`r_sd' ///
								mu_n:_cons=`rs_mean' ln_sig_n:_cons=`lsn' ) ///
								`robust' cluster(`cluster') `trace'  maximize `constraint' ///
								 `baselevels' `allbaselevels' `difficult' `search' repeat(`repeat')  `iterate' `options'
		 }
	}
	/// Method 2
	else if "`model'"=="2" {
		if "`from'"!="" {
					ml model lf ky_ll_2 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
										(mu_n:=`mu_n') ///
										(mu_w:=`mu_w') ///
										(ln_sig_e:=`ln_sig_e') ///
										(ln_sig_n:=`ln_sig_n') ///
										(ln_sig_w:=`ln_sig_w') ///
										(arho_s:=`arho_s') ///
										(lpi_s:=`lpi_s')   ///
										(lpi_w:=`lpi_w')  if `touse' [`weight'`exp'], ///
										`technique' init(`from') ///
										`robust' cluster(`cluster') `trace'  maximize `constraint' ///
										`baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate' `options'
		}
		else {
			** if we do not have initial values, we need to estimate them.....other wise. hard to estimate.
			display as input "Estimating Basic model"
			** as before, first get the basic number
			sum `rr' if `touse' , meanonly
			local r_mean=r(mean)
			tempvar rf_sf
			qui:gen double `rf_sf'=`rr'-`ss' if `touse'
			qui:sum `rf_sf' if `touse' ,  
			local lsn=log(r(sd))
			local rs_mean=log(r(sd))
			ml model lf ky_ll_1 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
								(mu_n:=`mu_n') ///
								(ln_sig_e:=`ln_sig_e') ///
								(ln_sig_n:=`ln_sig_n') ///
								(arho_s:=`arho_s') ///
								(lpi_s:=`lpi_s')  if `touse' [`weight'`exp'], ///
								`technique' init(mu_e:_cons=`r_mean' ///
								mu_n:_cons=`rs_mean' ln_sig_n:_cons=`lsn' ) ///
								`robust' cluster(`cluster') `trace'  maximize `constraint' ///
								`baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate'
			tempname initb 
			matrix `initb'=e(b)
			tempname basic_b
			matrix `basic_b'=e(b)
			display as input "Estimating KY model with no mismatching: pi_r = 0"
			ml model lf ky_ll_2 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
								(mu_n:=`mu_n') ///
								(mu_w:=`mu_w') ///
								(ln_sig_e:=`ln_sig_e') ///
								(ln_sig_n:=`ln_sig_n') ///
								(ln_sig_w:=`ln_sig_w') ///
								(arho_s:=`arho_s') ///
								(lpi_s:=`lpi_s')   ///
								(lpi_w:=`lpi_w')  if `touse' [`weight'`exp'], ///
								`technique' init(`initb', skip) ///
								`robust' cluster(`cluster') `trace'  maximize `constraint' ///
								`baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate' `options'
			}

		}
		
	else if "`model'"=="3" {
		 ** This will be the basic method
		if "`from'"!="" {
			ml model lf ky_ll_3 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
								(mu_n:=`mu_n') ///
								(mu_t:=`mu_t') ///
								(ln_sig_e:=`ln_sig_e') ///
								(ln_sig_n:=`ln_sig_n') ///
								(ln_sig_t:=`ln_sig_t') ///
								(arho_s:=`arho_s') ///
								(lpi_r:=`lpi_r') ///
								(lpi_s:=`lpi_s') if `touse' [`weight'`exp'], ///
								`technique' init(`from') ///
								`robust' cluster(`cluster') `trace'  maximize `constraint'  ///
								`baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate' `options'
		}
		else {
			display as input "Estimating Basic KY model"
			qui:sum `rr' if `touse' , meanonly
			local r_mean=r(mean)
			tempvar rf_sf
			qui:gen double `rf_sf'=`rr'-`ss' if `touse'
			qui:sum `rf_sf' if `touse' ,  
			local lsn=log(r(sd))
			local rs_mean=log(r(sd))
		    ml model lf ky_ll_1 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
								(mu_n:=`mu_n') ///
								(ln_sig_e:=`ln_sig_e') ///
								(ln_sig_n:=`ln_sig_n') ///
								(arho_s:=`arho_s') ///
								(lpi_s:=`lpi_s')  if `touse' [`weight'`exp'], ///
								`technique' init(mu_e:_cons=`r_mean' ///
								mu_n:_cons=`rs_mean' ln_sig_n:_cons=`lsn' ) ///
								`robust' cluster(`cluster') `trace'  maximize `constraint' ///
								 `baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate'
			tempname initb
			matrix `initb'=e(b)
			tempname bmu_t
			matrix `bmu_t'=`r_mean'
			matrix coleq   `bmu_t'=mu_t
			matrix colname `bmu_t'=_cons
			matrix `initb'=`initb',`bmu_t'
			tempname basic_b
			matrix `basic_b'=e(b)

			display as input "Estimating KY model with no contamination: pi_w = 0"
		    ml model lf ky_ll_3 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
								(mu_n:=`mu_n') ///
								(mu_t:=`mu_t') ///
								(ln_sig_e:=`ln_sig_e') ///
								(ln_sig_n:=`ln_sig_n') ///
								(ln_sig_t:=`ln_sig_t') ///
								(arho_s:=`arho_s') ///
								(lpi_r:=`lpi_r') ///
								(lpi_s:=`lpi_s') if `touse' [`weight'`exp'], ///
								`technique' init(`initb') ///
								`robust' cluster(`cluster') `trace'  maximize `constraint'  ///
								`baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate' `options'
	      }

 }
******************************************************************************** 
    else if "`model'"=="4" {
		if "`from'"!="" {
			ml model lf ky_ll_4 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
								(mu_n:=`mu_n') ///
								(mu_w:=`mu_w') ///
								(mu_t:=`mu_t') ///
								(ln_sig_e:=`ln_sig_e') ///
								(ln_sig_n:=`ln_sig_n') ///
								(ln_sig_w:=`ln_sig_w') ///
								(ln_sig_t:=`ln_sig_t') ///
								(arho_s:=`arho_s') ///
								(lpi_r:=`lpi_r') ///
								(lpi_s:=`lpi_s') ///
								(lpi_w:=`lpi_w') if `touse' [`weight'`exp'], ///
								`technique' init(`from') ///
								`robust' cluster(`cluster') `trace' maximize `constraint' ///
								`baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate' `options'
		}
	 else {
		   display as input "Estimating Basic KY model"
		   sum `rr' if `touse'  , meanonly
		   local r_mean=r(mean)
		   tempvar rf_sf
		   qui:gen double `rf_sf'=`rr'-`ss' if `touse'
		   qui:sum `rf_sf' if `touse' ,  
		   local lsn=log(r(sd))
		   local rs_mean=log(r(sd))
		   ml model lf ky_ll_1 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
					(mu_n:=`mu_n') ///
					(ln_sig_e:=`ln_sig_e') ///
					(ln_sig_n:=`ln_sig_n') ///
					(arho_s:=`arho_s') ///
					(lpi_s:=`lpi_s')  if `touse' [`weight'`exp'], ///
					`technique' init(mu_e:_cons=`r_mean' ///
					mu_n:_cons=`rs_mean' ln_sig_n:_cons=`lsn' ) ///
					`robust' cluster(`cluster') `trace'  maximize `constraint' ///
					 `baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate'
		  tempname initb
		  matrix `initb'=e(b)
		  tempname bmu_t
		  matrix `bmu_t'=`r_mean'
		  matrix coleq   `bmu_t'=mu_t
		  matrix colname `bmu_t'=_cons
		  matrix `initb'=`initb',`bmu_t'
		  tempname basic_b
		  matrix `basic_b'=e(b)
		  
		  display as input "Estimating KY model with no contamination: pi_w = 0"
		  ml model lf ky_ll_3 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
							(mu_n:=`mu_n') ///
							(mu_t:=`mu_t') ///
							(ln_sig_e:=`ln_sig_e') ///
							(ln_sig_n:=`ln_sig_n') ///
							(ln_sig_t:=`ln_sig_t') ///
							(arho_s:=`arho_s') ///
							(lpi_r:=`lpi_r') ///
							(lpi_s:=`lpi_s') ///
							if `touse' [`weight'`exp'], ///
							`technique' init(`initb') ///
							`robust' cluster(`cluster') `trace'  maximize `constraint' ///
							`baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate'
		  matrix `initb'=e(b) 
		  tempname no_cont_b
		  matrix `no_cont_b'=e(b)
		  display as input "Estimating full KY full model with contamination and mismatch"
		  ml model lf ky_ll_4 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
								(mu_n:=`mu_n') ///
								(mu_w:=`mu_w') ///
								(mu_t:=`mu_t') ///
								(ln_sig_e:=`ln_sig_e') ///
								(ln_sig_n:=`ln_sig_n') ///
								(ln_sig_w:=`ln_sig_w') ///
								(ln_sig_t:=`ln_sig_t') ///
								(arho_s:=`arho_s') ///
								(lpi_r:=`lpi_r') ///
								(lpi_s:=`lpi_s') ///
								(lpi_w:=`lpi_w') if `touse' [`weight'`exp'], ///
								`technique' init(`initb',skip) ///
								`robust' cluster(`cluster') `trace' maximize `constraint' ///
								`baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate' `options'
					 
	      }

 }
******************************************************************************** 
    else if "`model'"=="5" {
		if "`from'"!="" {
	     display as input "Estimating Extended KY model - allows RTM in admin data"
		 ml model lf ky_ll_5 (mu_e:`rr' `ss' `ll' = `mu_e' ) (mu_n:=`mu_n')         (mu_w:=`mu_w') 	       (mu_t:=`mu_t')         (mu_v:=`mu_v') ///
						     (ln_sig_e:=`ln_sig_e')          (ln_sig_n:=`ln_sig_n') (ln_sig_w:=`ln_sig_w') (ln_sig_t:=`ln_sig_t') (ln_sig_v:=`ln_sig_v') ///
							 (arho_s:=`arho_s') (arho_r:=`arho_r') ///
							 (lpi_r:=`lpi_r') (lpi_s:=`lpi_s') (lpi_w:=`lpi_w') (lpi_v:=`lpi_v')  if `touse' [`weight'`exp'], ///
							 `technique' init(`from') ///
							 `robust' cluster(`cluster') `trace' maximize `constraint'  ///
							 `baselevels' `allbaselevels'   `difficult'	 `search' repeat(`repeat') 	`iterate' `options'
		}
	 else {
		   display as input "Estimating Basic KY model"
		   sum `rr' if `touse'  , meanonly
		   local r_mean=r(mean)
		   tempvar rf_sf
		   qui:gen double `rf_sf'=`rr'-`ss' if `touse'
		   qui:sum `rf_sf' if `touse'  ,  
		   local lsn=log(r(sd))
		   local rs_mean=log(r(sd))
		   ml model lf ky_ll_1 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
					(mu_n:=`mu_n') ///
					(ln_sig_e:=`ln_sig_e') ///
					(ln_sig_n:=`ln_sig_n') ///
					(arho_s:=`arho_s') ///
					(lpi_s:=`lpi_s')  if `touse' [`weight'`exp'], ///
					`technique' init(mu_e:_cons=`r_mean' ///
					mu_n:_cons=`rs_mean' ln_sig_n:_cons=`lsn' ) ///
					`robust' cluster(`cluster') `trace'  maximize `constraint' ///
					 `baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate'
		  tempname initb
		  matrix `initb'=e(b)
		  tempname bmu_t
		  matrix `bmu_t'=`r_mean'
		  matrix coleq   `bmu_t'=mu_t
		  matrix colname `bmu_t'=_cons
		  matrix `initb'=`initb',`bmu_t'
		  tempname basic_b
		  matrix `basic_b'=e(b)
		  
		  display as input "Estimating KY model with no contamination"
		  ml model lf ky_ll_3 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
							(mu_n:=`mu_n') ///
							(mu_t:=`mu_t') ///
							(ln_sig_e:=`ln_sig_e') ///
							(ln_sig_n:=`ln_sig_n') ///
							(ln_sig_t:=`ln_sig_t') ///
							(arho_s:=`arho_s') ///
							(lpi_r:=`lpi_r') ///
							(lpi_s:=`lpi_s') ///
							if `touse' [`weight'`exp'], ///
							`technique' init(`initb') ///
							`robust' cluster(`cluster') `trace'  maximize `constraint' ///
							`baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate'
		  matrix `initb'=e(b) 
		  tempname no_cont_b
		  matrix `no_cont_b'=e(b)
		  display as input "Estimating full KY full model with contamination and mismatch"
		  ml model lf ky_ll_4 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
								(mu_n:=`mu_n') ///
								(mu_w:=`mu_w') ///
								(mu_t:=`mu_t') ///
								(ln_sig_e:=`ln_sig_e') ///
								(ln_sig_n:=`ln_sig_n') ///
								(ln_sig_w:=`ln_sig_w') ///
								(ln_sig_t:=`ln_sig_t') ///
								(arho_s:=`arho_s') ///
								(lpi_r:=`lpi_r') ///
								(lpi_s:=`lpi_s') ///
								(lpi_w:=`lpi_w') if `touse' [`weight'`exp'], ///
								`technique' init(`initb',skip) ///
								`robust' cluster(`cluster') `trace' maximize `constraint' ///
								`baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate'
			
		  matrix `initb'=e(b) 
		  tempname full_b
		  matrix `full_b'=e(b)
		  tempname p6
		  matrix `p6'=9,0,-9
		  matrix colname `p6'=_cons
		  matrix coleq   `p6'=lpi_v mu_v ln_sig_v

		  display as input "Estimating Extended KY model - allows RTM error in admin data"
		  ml model lf ky_ll_5 (mu_e:`rr' `ss' `ll' = `mu_e' ) (mu_n:=`mu_n')         (mu_w:=`mu_w') 	       (mu_t:=`mu_t')         (mu_v:=`mu_v') ///
						     (ln_sig_e:=`ln_sig_e')           (ln_sig_n:=`ln_sig_n') (ln_sig_w:=`ln_sig_w')    (ln_sig_t:=`ln_sig_t') (ln_sig_v:=`ln_sig_v') ///
							 (arho_s:=`arho_s') (arho_r:=`arho_r') ///
							 (lpi_r:=`lpi_r') (lpi_s:=`lpi_s') (lpi_w:=`lpi_w') (lpi_v:=`lpi_v')  if `touse' [`weight'`exp'], ///
							 `technique' init(`initb' `p6') ///
							 `robust' cluster(`cluster') `trace' maximize `constraint'  ///
							 `baselevels' `allbaselevels'   `difficult'	 `search' repeat(`repeat') 	`iterate' `options'
		}				
    }
********************************************************************************	
 	else if "`model'"=="6" {
		if "`from'"!="" {
	     display as input "Estimating Modified Extended KY model RTM in both survey and Admin data"
		 ml model lf ky_ll_6 (mu_e:`rr' `ss' `ll' = `mu_e' ) (mu_n:=`mu_n')          (mu_t:=`mu_t')         (mu_v:=`mu_v') ///
						     (ln_sig_e:=`ln_sig_e')          (ln_sig_n:=`ln_sig_n')  (ln_sig_t:=`ln_sig_t') (ln_sig_v:=`ln_sig_v') ///
							 (arho_s:=`arho_s') (arho_r:=`arho_r') ///
							 (lpi_r:=`lpi_r') (lpi_s:=`lpi_s') (lpi_v:=`lpi_v')  if `touse' [`weight'`exp'], ///
							 `technique' init(`from') ///
							 `robust' cluster(`cluster') `trace' maximize `constraint'  ///
							 `baselevels' `allbaselevels'   `difficult'	 `search' repeat(`repeat') 	`iterate' `options'
		}
	 else {
		   display as input "Estimating Basic KY model"
		   sum `rr' if `touse' , meanonly
		   local r_mean=r(mean)
		   tempvar rf_sf
		   qui:gen double `rf_sf'=`rr'-`ss' if `touse'
		   qui:sum `rf_sf' if `touse'  ,  
		   local lsn=log(r(sd))
		   local rs_mean=log(r(sd))
		   ml model lf ky_ll_1 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
					(mu_n:=`mu_n') ///
					(ln_sig_e:=`ln_sig_e') ///
					(ln_sig_n:=`ln_sig_n') ///
					(arho_s:=`arho_s') ///
					(lpi_s:=`lpi_s')  if `touse' [`weight'`exp'], ///
					`technique' init(mu_e:_cons=`r_mean' ///
					mu_n:_cons=`rs_mean' ln_sig_n:_cons=`lsn' ) ///
					`robust' cluster(`cluster') `trace'  maximize `constraint' ///
					 `baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate'
		  tempname initb
		  matrix `initb'=e(b)
		  tempname bmu_t
		  matrix `bmu_t'=`r_mean'
		  matrix coleq   `bmu_t'=mu_t
		  matrix colname `bmu_t'=_cons
		  matrix `initb'=`initb',`bmu_t'
		  tempname basic_b
		  matrix `basic_b'=e(b)
		  
		  display as input "Estimating KY model with no contamination"
		  ml model lf ky_ll_3 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
							(mu_n:=`mu_n') ///
							(mu_t:=`mu_t') ///
							(ln_sig_e:=`ln_sig_e') ///
							(ln_sig_n:=`ln_sig_n') ///
							(ln_sig_t:=`ln_sig_t') ///
							(arho_s:=`arho_s') ///
							(lpi_r:=`lpi_r') ///
							(lpi_s:=`lpi_s') ///
							if `touse' [`weight'`exp'], ///
							`technique' init(`initb') ///
							`robust' cluster(`cluster') `trace'  maximize `constraint' ///
							`baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate'
		  matrix `initb'=e(b) 
		  tempname no_cont_b
		  matrix `no_cont_b'=e(b)
		 
		  tempname p6
		  matrix `p6'=9,0,-9
		  matrix colname `p6'=_cons
		  matrix coleq   `p6'=lpi_v mu_v ln_sig_v
		  
	     display as input "Estimating Modified Extended KY model RTM in both survey and Admin data"
		 ml model lf ky_ll_6 (mu_e:`rr' `ss' `ll' = `mu_e' ) (mu_n:=`mu_n')          (mu_t:=`mu_t')         (mu_v:=`mu_v') ///
						     (ln_sig_e:=`ln_sig_e')          (ln_sig_n:=`ln_sig_n')  (ln_sig_t:=`ln_sig_t') (ln_sig_v:=`ln_sig_v') ///
							 (arho_s:=`arho_s') (arho_r:=`arho_r') ///
							 (lpi_r:=`lpi_r') (lpi_s:=`lpi_s') (lpi_v:=`lpi_v')  if `touse' [`weight'`exp'], ///
							 `technique' init(`initb' `p6') ///
							 `robust' cluster(`cluster') `trace' maximize `constraint'  ///
							 `baselevels' `allbaselevels'   `difficult'	 `search' repeat(`repeat') 	`iterate' `options'
		}				
    }
	* Model 7: model 7 adds a correlation component between omega and eta
	else if "`model'"=="7" {
		if "`from'"!="" {
			ml model lf ky_ll_7 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
								(mu_n:=`mu_n') ///
								(mu_w:=`mu_w') ///
								(mu_t:=`mu_t') ///
								(ln_sig_e:=`ln_sig_e') ///
								(ln_sig_n:=`ln_sig_n') ///
								(ln_sig_w:=`ln_sig_w') ///
								(ln_sig_t:=`ln_sig_t') ///
								(arho_w:=`arho_w') /// This is the correlation between w_i and e_i
								(arho_s:=`arho_s') ///
								(lpi_r:=`lpi_r') ///
								(lpi_s:=`lpi_s') ///
								(lpi_w:=`lpi_w') if `touse' [`weight'`exp'], ///
								`technique' init(`from') ///
								`robust' cluster(`cluster') `trace' maximize `constraint' ///
								`baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate' `options'
		}
	 else {
		   display as input "Estimating Basic KY model"
		   sum `rr' if `touse'  , meanonly
		   local r_mean=r(mean)
		   tempvar rf_sf
		   qui:gen double `rf_sf'=`rr'-`ss' if `touse'
		   qui:sum `rf_sf' if `touse' ,  
		   local lsn=log(r(sd))
		   local rs_mean=log(r(sd))
		   ml model lf ky_ll_1 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
					(mu_n:=`mu_n') ///
					(ln_sig_e:=`ln_sig_e') ///
					(ln_sig_n:=`ln_sig_n') ///
					(arho_s:=`arho_s') ///
					(lpi_s:=`lpi_s')  if `touse' [`weight'`exp'], ///
					`technique' init(mu_e:_cons=`r_mean' ///
					mu_n:_cons=`rs_mean' ln_sig_n:_cons=`lsn' ) ///
					`robust' cluster(`cluster') `trace'  maximize `constraint' ///
					 `baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate'
		  tempname initb
		  matrix `initb'=e(b)
		  tempname bmu_t
		  matrix `bmu_t'=`r_mean'
		  matrix coleq   `bmu_t'=mu_t
		  matrix colname `bmu_t'=_cons
		  matrix `initb'=`initb',`bmu_t'
		  tempname basic_b
		  matrix `basic_b'=e(b)
		  
		  display as input "Estimating KY model with no contamination: pi_w = 0"
		  ml model lf ky_ll_3 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
							(mu_n:=`mu_n') ///
							(mu_t:=`mu_t') ///
							(ln_sig_e:=`ln_sig_e') ///
							(ln_sig_n:=`ln_sig_n') ///
							(ln_sig_t:=`ln_sig_t') ///
							(arho_s:=`arho_s') ///
							(lpi_r:=`lpi_r') ///
							(lpi_s:=`lpi_s') ///
							if `touse' [`weight'`exp'], ///
							`technique' init(`initb') ///
							`robust' cluster(`cluster') `trace'  maximize `constraint' ///
							`baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate'
		  matrix `initb'=e(b) 
		  tempname no_cont_b
		  matrix `no_cont_b'=e(b)
		  display as input "Estimating full KY full model with contamination and mismatch"
		  ml model lf ky_ll_4 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
								(mu_n:=`mu_n') ///
								(mu_w:=`mu_w') ///
								(mu_t:=`mu_t') ///
								(ln_sig_e:=`ln_sig_e') ///
								(ln_sig_n:=`ln_sig_n') ///
								(ln_sig_w:=`ln_sig_w') ///
								(ln_sig_t:=`ln_sig_t') ///
								(arho_s:=`arho_s') ///
								(lpi_r:=`lpi_r') ///
								(lpi_s:=`lpi_s') ///
								(lpi_w:=`lpi_w') if `touse' [`weight'`exp'], ///
								`technique' init(`initb',skip) ///
								`robust' cluster(`cluster') `trace' maximize `constraint' ///
								`baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate'
								
		  display as input "Estimating full KY full model with correlation between w_i and e_i"								
			matrix `initb'=e(b) 
			ml model lf ky_ll_7 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
								(mu_n:=`mu_n') ///
								(mu_w:=`mu_w') ///
								(mu_t:=`mu_t') ///
								(ln_sig_e:=`ln_sig_e') ///
								(ln_sig_n:=`ln_sig_n') ///
								(ln_sig_w:=`ln_sig_w') ///
								(ln_sig_t:=`ln_sig_t') ///
								(arho_w:=`arho_w') /// This is the correlation between w_i and e_i
								(arho_s:=`arho_s') ///
								(lpi_r:=`lpi_r') ///
								(lpi_s:=`lpi_s') ///
								(lpi_w:=`lpi_w') if `touse' [`weight'`exp'], ///
								`technique' init(`initb') ///
								`robust' cluster(`cluster') `trace' maximize `constraint' ///
								`baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') 	`iterate'		`options'
	      }
	}
	else if "`model'"=="8" {
		if "`from'"!="" {
		 display as input "Estimating Extended KY model - allows RTM in admin data with Corr(e_i,w_i)"
		 ml model lf ky_ll_8 (mu_e:`rr' `ss' `ll' = `mu_e' ) (mu_n:=`mu_n')         (mu_w:=`mu_w') 	       (mu_t:=`mu_t')         (mu_v:=`mu_v') ///
							 (ln_sig_e:=`ln_sig_e')          (ln_sig_n:=`ln_sig_n') (ln_sig_w:=`ln_sig_w') (ln_sig_t:=`ln_sig_t') (ln_sig_v:=`ln_sig_v') ///
							 (arho_s:=`arho_s') (arho_r:=`arho_r') (arho_w:=`arho_w') ///
							 (lpi_r:=`lpi_r') (lpi_s:=`lpi_s') (lpi_w:=`lpi_w') (lpi_v:=`lpi_v')  if `touse' [`weight'`exp'], ///
							 `technique' init(`from') ///
							 `robust' cluster(`cluster') `trace' maximize `constraint'  ///
							 `baselevels' `allbaselevels'   `difficult'	 `search' repeat(`repeat') 	`iterate' `options'
		}
		 else {
			   display as input "Estimating Basic KY model"
			   sum `rr' if `touse'  , meanonly
			   local r_mean=r(mean)
			   tempvar rf_sf
			   qui:gen double `rf_sf'=`rr'-`ss' if `touse'
			   qui:sum `rf_sf' if `touse'  ,  
			   local lsn=log(r(sd))
			   local rs_mean=log(r(sd))
			   ml model lf ky_ll_1 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
						(mu_n:=`mu_n') ///
						(ln_sig_e:=`ln_sig_e') ///
						(ln_sig_n:=`ln_sig_n') ///
						(arho_s:=`arho_s') ///
						(lpi_s:=`lpi_s')  if `touse' [`weight'`exp'], ///
						`technique' init(mu_e:_cons=`r_mean' ///
						mu_n:_cons=`rs_mean' ln_sig_n:_cons=`lsn' ) ///
						`robust' cluster(`cluster') `trace'  maximize `constraint' ///
						 `baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate'
			  tempname initb
			  matrix `initb'=e(b)
			  tempname bmu_t
			  matrix `bmu_t'=`r_mean'
			  matrix coleq   `bmu_t'=mu_t
			  matrix colname `bmu_t'=_cons
			  matrix `initb'=`initb',`bmu_t'
			  tempname basic_b
			  matrix `basic_b'=e(b)
			  
			  display as input "Estimating KY model with no contamination"
			  ml model lf ky_ll_3 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
								(mu_n:=`mu_n') ///
								(mu_t:=`mu_t') ///
								(ln_sig_e:=`ln_sig_e') ///
								(ln_sig_n:=`ln_sig_n') ///
								(ln_sig_t:=`ln_sig_t') ///
								(arho_s:=`arho_s') ///
								(lpi_r:=`lpi_r') ///
								(lpi_s:=`lpi_s') ///
								if `touse' [`weight'`exp'], ///
								`technique' init(`initb') ///
								`robust' cluster(`cluster') `trace'  maximize `constraint' ///
								`baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate'
			  matrix `initb'=e(b) 
			  tempname no_cont_b
			  matrix `no_cont_b'=e(b)
			  display as input "Estimating full KY full model with contamination and mismatch"
			  ml model lf ky_ll_4 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
									(mu_n:=`mu_n') ///
									(mu_w:=`mu_w') ///
									(mu_t:=`mu_t') ///
									(ln_sig_e:=`ln_sig_e') ///
									(ln_sig_n:=`ln_sig_n') ///
									(ln_sig_w:=`ln_sig_w') ///
									(ln_sig_t:=`ln_sig_t') ///
									(arho_s:=`arho_s') ///
									(lpi_r:=`lpi_r') ///
									(lpi_s:=`lpi_s') ///
									(lpi_w:=`lpi_w') if `touse' [`weight'`exp'], ///
									`technique' init(`initb',skip) ///
									`robust' cluster(`cluster') `trace' maximize `constraint' ///
									`baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate'
				
			  matrix `initb'=e(b) 
			  tempname full_b
			  matrix `full_b'=e(b)
			  tempname p6
			  matrix `p6'=9,0,-9
			  matrix colname `p6'=_cons
			  matrix coleq   `p6'=lpi_v mu_v ln_sig_v

			  display as input "Estimating Extended KY model - allows RTM error in admin data"
			  ml model lf ky_ll_5 (mu_e:`rr' `ss' `ll' = `mu_e' ) (mu_n:=`mu_n')         (mu_w:=`mu_w') 	       (mu_t:=`mu_t')         (mu_v:=`mu_v') ///
								 (ln_sig_e:=`ln_sig_e')           (ln_sig_n:=`ln_sig_n') (ln_sig_w:=`ln_sig_w')    (ln_sig_t:=`ln_sig_t') (ln_sig_v:=`ln_sig_v') ///
								 (arho_s:=`arho_s') (arho_r:=`arho_r') ///
								 (lpi_r:=`lpi_r') (lpi_s:=`lpi_s') (lpi_w:=`lpi_w') (lpi_v:=`lpi_v')  if `touse' [`weight'`exp'], ///
								 `technique' init(`initb' `p6') ///
								 `robust' cluster(`cluster') `trace' maximize `constraint'  ///
								 `baselevels' `allbaselevels'   `difficult'	 `search' repeat(`repeat') 	`iterate'
			  matrix `full_b'=e(b)
			  
			  display as input "Estimating Extended KY model - allows RTM error in admin data and Corr with w_i and e_i "
			  ml model lf ky_ll_8 (mu_e:`rr' `ss' `ll' = `mu_e' ) (mu_n:=`mu_n')         (mu_w:=`mu_w') 	       (mu_t:=`mu_t')         (mu_v:=`mu_v') ///
								 (ln_sig_e:=`ln_sig_e')           (ln_sig_n:=`ln_sig_n') (ln_sig_w:=`ln_sig_w')    (ln_sig_t:=`ln_sig_t') (ln_sig_v:=`ln_sig_v') ///
								 (arho_s:=`arho_s') 		      (arho_r:=`arho_r') 	 (arho_w:=`arho_w') ///
								 (lpi_r:=`lpi_r') (lpi_s:=`lpi_s') (lpi_w:=`lpi_w') (lpi_v:=`lpi_v')  if `touse' [`weight'`exp'], ///
								 `technique' init(`full_b') ///
								 `robust' cluster(`cluster') `trace' maximize `constraint'  ///
								 `baselevels' `allbaselevels'   `difficult'	 `search' repeat(`repeat') 	`iterate' `options'
			}				
		
 }
	else if "`model'"=="9" {
		if "`from'"!="" {
	     display as input "Estimating Extended KY model - without missmatching but errors"
		 ml model lf ky_ll_9 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
							 (mu_n:=`mu_n') ///
							 (mu_w:=`mu_w') ///
							 (mu_v:=`mu_v') ///
						     (ln_sig_e:=`ln_sig_e') ///
							 (ln_sig_n:=`ln_sig_n') ///
							 (ln_sig_w:=`ln_sig_w') ///
							 (ln_sig_v:=`ln_sig_v') ///
							 (arho_s:=`arho_s') (arho_r:=`arho_r') ///
							 (lpi_s:=`lpi_s') (lpi_w:=`lpi_w') (lpi_v:=`lpi_v')  if `touse' [`weight'`exp'], ///
							 `technique' init(`from') ///
							 `robust' cluster(`cluster') `trace' maximize `constraint'  ///
							 `baselevels' `allbaselevels'   `difficult'	 `search' ///
							 repeat(`repeat') 	`iterate' `options'
		}
	 else {
		   display as input "Estimating Basic KY model"
		   sum `rr' if `touse'  , meanonly
		   local r_mean=r(mean)
		   tempvar rf_sf
		   qui:gen double `rf_sf'=`rr'-`ss' if `touse'
		   qui:sum `rf_sf' if `touse'  ,  
		   local lsn=log(r(sd))
		   local rs_mean=log(r(sd))
		   ml model lf ky_ll_1 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
					(mu_n:=`mu_n') ///
					(ln_sig_e:=`ln_sig_e') ///
					(ln_sig_n:=`ln_sig_n') ///
					(arho_s:=`arho_s') ///
					(lpi_s:=`lpi_s')  if `touse' [`weight'`exp'], ///
					`technique' init(mu_e:_cons=`r_mean' ///
					mu_n:_cons=`rs_mean' ln_sig_n:_cons=`lsn' ) ///
					`robust' cluster(`cluster') `trace'  maximize `constraint' ///
					`baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate'
		  tempname initb
		  matrix `initb'=e(b)
		  tempname bmu_t
		  matrix `bmu_t'=`r_mean'
		  matrix coleq   `bmu_t'=mu_t
		  matrix colname `bmu_t'=_cons
		  matrix `initb'=`initb',`bmu_t'
		  tempname basic_b
		  matrix `basic_b'=e(b)
		  
			display as input "Estimating KY model with no mismatching: pi_r = 0"
			ml model lf ky_ll_2 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
								(mu_n:=`mu_n') ///
								(mu_w:=`mu_w') ///
								(ln_sig_e:=`ln_sig_e') ///
								(ln_sig_n:=`ln_sig_n') ///
								(ln_sig_w:=`ln_sig_w') ///
								(arho_s:=`arho_s') ///
								(lpi_s:=`lpi_s')   ///
								(lpi_w:=`lpi_w')  if `touse' [`weight'`exp'], ///
								`technique' init(`initb', skip) ///
								`robust' cluster(`cluster') `trace'  maximize `constraint' ///
								`baselevels' `allbaselevels' `difficult' `search' repeat(`repeat') `iterate' `options'
 		  matrix `initb'=e(b) 
		  tempname no_cont_b no_missm_b
		  matrix `no_missm_b'=e(b)
		  
          tempname p6
		  matrix `p6'=9,0,-9
		  matrix colname `p6'=_cons
		  matrix coleq   `p6'=lpi_v mu_v ln_sig_v
 		  display as input "Estimating Extended KY model - without missmatching"
		  ml model lf ky_ll_9 (mu_e:`rr' `ss' `ll' = `mu_e' ) ///
							  (mu_n:=`mu_n')     ///
							  (mu_w:=`mu_w') 	///
							  (mu_v:=`mu_v') ///
						     (ln_sig_e:=`ln_sig_e')     ///
							 (ln_sig_n:=`ln_sig_n') ///
							 (ln_sig_w:=`ln_sig_w')    ///
							 (ln_sig_v:=`ln_sig_v') ///
							 (arho_s:=`arho_s') (arho_r:=`arho_r') ///
							  (lpi_s:=`lpi_s') (lpi_w:=`lpi_w') (lpi_v:=`lpi_v')  if `touse' [`weight'`exp'], ///
							 `technique' init(`initb' `p6' ) ///
							 `robust' cluster(`cluster') `trace' maximize `constraint'  ///
							 `baselevels' `allbaselevels'   `difficult'	 `search' repeat(`repeat') 	`iterate' `options'
		}				
    }
********************************************************************************	
 	********************************
	if `model'==1 	   local mtd="Basic model"
	else if `model'==2 local mtd="No mismatching in admin data"
	else if `model'==3 local mtd="No contamination in survey data"
	else if `model'==4 local mtd="KY full model" 
	else if `model'==5 local mtd="Extended KY model" 
	else if `model'==6 local mtd="Modified Extended KY model" 
	else if `model'==7 local mtd="Modified full KY model" 
	else if `model'==8 local mtd="Modified Extended KY model" 
	else if `model'==9 local mtd="No missmatch but error in Admin data" 
********************************
** Additional outputs
	ereturn local cmd="ky_fit"
	ereturn local cmdline="ky_fit `0'"
	ereturn local method ="`mtd'"
	*ereturn local model  ="`model'"
	ereturn local estat_cmd "ky_estat"
	ereturn scalar method_c=`model'
	capture confirm matrix `basic_b'
	if _rc==0 ereturn matrix b_basic  `basic_b'
	capture confirm matrix `no_cont_b'
	if _rc==0 ereturn matrix b_nocont `no_cont_b'
	capture confirm matrix `full_b'
	if _rc==0 ereturn matrix b_full_b `full_b'
	ereturn local  predict "ky_p"
	foreach i in lpi_r lpi_s lpi_w lpi_v {
		ereturn hidden local `i' ``i'' 
	}
	ml display , `baselevels' `allbaselevels'
	
end

capture program drop results_ky
program results_ky
if "`e(cmd)'"=="ky_fit" {
	ml display `0'  
	}
else {
	display in red "last estimates not found"
    }
end
 
 
