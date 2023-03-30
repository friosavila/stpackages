// John de New johnhd@unimelb.edu.au

// Web-use this file and then store locally
//webuse grunfeld, clear
//save grunfeld, replace

use grunfeld, clear


compress
xtset


// LHS variable
qui sum invest
local rifmean=r(mean)

// "center" command from Ben Jann
// Jann, B. (2004). center: Stata module to center (or standardize) variables. Available from 
// http://ideas.repec.org/c/boc/bocode/s444102.html.
// These are the continuous variables and are now centered c_*
center mvalue kstock
global cont c_mvalue c_kstock

// (1) regression with fvhds97
reg invest  $cont b2.company i.time, robust
fvhds97
estadd 	scalar time 	`e(time_sd)'
estadd 	scalar company 	`e(company_sd)'
//estadd 	scalar RIFmean 	`rifmean'
eststo reg

// (2) regression using rifhdreg with fvhds97: 1 percentage point
rifhdreg invest  $cont  b2.company i.time, rif(mean)  robust
fvhds97, pp(1)
estadd 	scalar time 	`e(time_sd)'
estadd 	scalar company 	`e(company_sd)'
estadd 	scalar RIFmean 	`e(rifmean)'
eststo rifhdreg1

// (3) regression using rifhdreg with fvhds97: 10 percentage points
rifhdreg invest  $cont  b2.company i.time, rif(mean)  robust
fvhds97, pp(10)
estadd 	scalar time 	`e(time_sd)'
estadd 	scalar company 	`e(company_sd)'
estadd 	scalar RIFmean 	`e(rifmean)'
eststo rifhdreg10

esttab  reg rifhdreg1 rifhdreg10, cells(b(star fmt(%9.3f)) se(par)) stats(RIFmean time_sd company_sd r2_a N   , fmt(%12.5g) ) mtitles("reg" "rifhdreg1" "rifhdreg10" )
