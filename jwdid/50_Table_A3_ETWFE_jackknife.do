******************************************************************************************************************************
******************************************************************************************************************************
***
*** Table A3: Robustness with regard to degree of heterogeneity of the ETWFE estimator and incidental parameter problems
*** ETWFE jackknife estimation
*** 
******************************************************************************************************************************
******************************************************************************************************************************


** global settings
local N_iter = 1000
local N_p = 4
local N_jiter = `N_iter'/`N_p'

** 0) open data set
use ${usr_data}\data_sdid_small, clear

******************************************************
*  1) Create pair ID and symmetric pair ID variables *
******************************************************

* generate 1000 jackknife samples
set seed 123456789
forval i=1(1)`N_jiter' {

	preserve
	
	keep exporter
	duplicates drop exporter, force
	gen randn = runiform()
	egen rank=rank(randn), unique
	keep if rank>=45
	keep exporter
	qui save ${usr_data}\Simulation\data_sdid_small_jackknife_exporter`i', replace
	rename exporter importer
	qui save ${usr_data}\Simulation\data_sdid_small_jackknife_importer`i', replace
	
	restore

}
	
* initialise matrices

mat B_main = J(1,1,.)
mat N_main = J(1,1,.)

mat index = J(`N_iter',1,.)
mat B_jack = J(`N_iter',1,.)
mat N_jack = J(`N_iter',1,.)
mat B = J(1,1,.)
mat SE = J(1,1,.)
mat loCI = J(1,1,.)
mat hiCI = J(1,1,.)

* open data set
use ${usr_data}\data_sdid_small, clear

* main estimation
qui jwdid_boot trade, ivar(id_ci_cj) tvar(year) gvar(FT_EU) method(ppmlhdfe) fe(idt_ci idt_cj brdr_time) boot

local names = e(xvar)
local dim_B : word count `names'
qui sum __hdfe6__ if xvarfe==0
local offset = `r(mean)'
local B_agg = 0
local total = 0
forval j=1(1)`dim_B' {
	local name : word `j' of `names'
	local temp = substr("`name'",2,4)
	local first_treat_3_temp = `temp'
	local hash_idx = strpos("`name'","#")
	local temp = substr("`name'",`hash_idx'+2,4)
	local year_temp =  `temp'
	qui sum __hdfe6__ if FT_EU==`first_treat_3_temp' & year==`year_temp'
	local total = `total'+`r(N)'
	if `r(N)'!=0 {
		if abs(`r(mean)')>10e-8 { 
			local B_agg = `B_agg' + (`r(mean)'-`offset')*`r(N)'
		}
	}
}
local B_agg = `B_agg'/`total'
local B_main = `B_agg'	
local N_main = e(N)


* run 1000 jackknife iterations
forval jiter=1(1)`N_jiter' {

	di "`jiter'"
		
	* open data set
	use ${usr_data}\data_sdid_small, clear	

	forval p=1(1)4 {

		preserve
		
		capture drop _merge_id_ci
		qui merge m:1 exporter using "${usr_data}\Simulation\data_sdid_small_jackknife_exporter`jiter'.dta"
		rename _merge _merge_id_ci
		capture drop _merge_id_cj
		qui merge m:1 importer using "${usr_data}\Simulation\data_sdid_small_jackknife_importer`jiter'.dta"
		rename _merge _merge_id_cj
		
		if `p'==1 {
			qui keep if _merge_id_ci==3
		}
		if `p'==2 {
			qui drop if _merge_id_ci==3
		}
		if `p'==3 {
			qui keep if _merge_id_cj==3
		}
		if `p'==4 {
			qui drop if _merge_id_cj==3
		}
		
		qui jwdid_boot trade, ivar(id_ci_cj) tvar(year) gvar(FT_EU) method(ppmlhdfe) fe(idt_ci idt_cj brdr_time) boot tol(1e-3)

		local names = e(xvar)
		local dim_B : word count `names'
		qui sum __hdfe6__ if xvarfe==0
		local offset = `r(mean)'
		local B_agg = 0
		local total = 0
		forval j=1(1)`dim_B' {
			local name : word `j' of `names'
			local temp = substr("`name'",2,4)
			local first_treat_3_temp = `temp'
			local hash_idx = strpos("`name'","#")
			local temp = substr("`name'",`hash_idx'+2,4)
			local year_temp =  `temp'
			qui sum __hdfe6__ if FT_EU==`first_treat_3_temp' & year==`year_temp'
			local total = `total'+`r(N)'
			if `r(N)'!=0 {
				if abs(`r(mean)')>10e-8 { 
					local B_agg = `B_agg' + (`r(mean)'-`offset')*`r(N)'
				}
			}
		}
		local B_agg = `B_agg'/`total'
		mat B_jack[(`jiter'-1)*`N_p'+`p',1] = `B_agg'	
		mat N_jack[(`jiter'-1)*`N_p'+`p',1] = e(N)
		mat index[(`jiter'-1)*`N_p'+`p',1] = (`jiter'-1)*`N_p'+`p'
		
		restore
			
	}	
	
	* 0) read matrices and macros into mata
	mata: B_jack=st_matrix("B_jack")
	mata: N_jack=st_matrix("N_jack")
	mata: NN_jack = strtoreal(st_local("N_jack"))
	mata: w_jack = N_jack/sum(N_jack)
	mata: B_main = strtoreal(st_local("B_main"))
	
	* 1) beta from Weidner & Zylkin (2021); SE from distribution of beta; CI from beta_debiased +- 1.96 SE
	mata: B = 2*B_main - mean(B_jack)
	mata: SE = sqrt(quadvariance(B_jack))
	mata: loCI = B - SE*1.96
	mata: hiCI = B + SE*1.96

	* 2) pass matrices and macros back to stata

	* @ 1)
	mata: st_local("B", strofreal(B))
	mata: st_local("SE", strofreal(SE))
	mata: st_local("loCI", strofreal(loCI))
	mata: st_local("hiCI", strofreal(hiCI))
	mat B[1,1] = `B'
	mat SE[1,1] = `SE'
	mat loCI[1,1] = `loCI'
	mat hiCI[1,1] = `hiCI'
	
	qui drop _all
	qui svmat B
	qui svmat SE
	qui svmat loCI
	qui svmat hiCI
	qui svmat B_jack
	qui svmat N_jack
	qui svmat index
	
	qui rename B1 B_ETWFE
	qui rename SE1 SE_ETWFE
	qui rename loCI1 loCI_ETWFE
	qui rename hiCI1 hiCI_ETWFE
	qui rename B_jack1 B_jack_ETWFE
	qui rename N_jack1 N_jack_ETWFE
	qui rename index1 index
	
	* save results file
	qui save ${usr_data}\Jackknife_SEs_random, replace

}
