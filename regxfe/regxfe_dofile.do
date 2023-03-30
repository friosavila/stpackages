set more off
use cps_sample, clear
set seed 101
gen wg=runiform()*50
set matsize 2000
* table 1:
regress lnwageh age union yrs_school sex i.yrm i.state i.ind i.occ
* table 2:
regxfe lnwageh age union yrs_school sex, fe(yrm state ind occ)	
* Figure 1:
preserve 
forvalues i=0/20 {
regxfe lnwageh age union yrs_school sex, fe(yrm state ind occ) maxiter(0) mg(3)
demean lnwageh age union yrs_school sex, fe(yrm state ind occ) mean replace maxiter(1)
matrix b1=nullmat(b1)\e(b)
}
restore
preserve
clear
matrix b2=b1[....,1..colsof(b1)-1]
svmat b2, names(col)
gen iteration=_n

scatter union iter, connect(l) title(union)
graph save g1, replace
scatter yrs_school iter, connect(l) title(yrs_school)
graph save g2, replace
scatter age iter, connect(l) title(age)
graph save g3, replace
scatter sex iter, connect(l) title(sex)
graph save g4, replace

graph combine g1.gph g2.gph g3.gph g4.gph, title(Parameters Convergence)
restore

* Appendix B
demean lnwageh age union , fe(yrm state ind occ) mean replace
demean union yrs_school sex , fe(yrm state ind occ) mean replace
gx yrm state ind occ 
local x=e(M)
regxfe lnwageh age union yrs_school sex, fe(yrm state ind occ) maxiter(0) mg(`x')

* Appendix C
reg lnwageh age union yrs_school sex i.yrm i.state i.ind i.occ [aw=wg] 
reg lnwageh age union yrs_school sex i.yrm i.state i.ind i.occ,	robust
reg  lnwageh age union yrs_school sex i.yrm i.state i.ind i.occ,	cluster(age)

regxfe lnwageh age union yrs_school sex [aw=wg], fe(yrm state ind occ)	 	
regxfe lnwageh age union yrs_school sex, fe(yrm state ind occ)	robust
regxfe lnwageh age union yrs_school sex, fe(yrm state ind occ)	cluster(age)
