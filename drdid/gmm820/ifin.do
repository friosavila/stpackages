cscript ifin.do 

quietly {
cls
set obs 1000
set seed 111
generate id = _n 
generate first_treat =    runiformint(2000,2001)  
replace first_treat  = 0 if runiform()>.7
expand 4  // expand 7  
bysort id: generate time = _n + 1998
gen touse2 = .
generate double y = rnormal()
replace  y = . if runiform()>.95
generate double x = runiform()
generate double touse = y !=.
}

**************************************************************
************************** Regressors ************************
**************************************************************

preserve
keep if inlist(first_treat,0,2000) & inlist(time,1999,2000)
local xvar x
drdid y `xvar', ivar(id) time(time) tr(first_treat) reg gmm
matrix B1 = e(b)[1,1], e(V)[1,1]
drdid y `xvar', ivar(id) time(time) tr(first_treat) dripw gmm  
matrix B2 = e(b)[1,1], e(V)[1,1]
drdid y `xvar', ivar(id) time(time) tr(first_treat) drimp gmm  
matrix B3 = e(b)[1,1], e(V)[1,1]
drdid y `xvar', ivar(id) time(time) tr(first_treat) ipw gmm 
matrix B4 = e(b)[1,1], e(V)[1,1]
drdid y `xvar', ivar(id) time(time) tr(first_treat) stdipw gmm 
matrix B5 = e(b)[1,1], e(V)[1,1]
cap noi drdid y `xvar', ivar(id) time(time) tr(first_treat) ipwra gmm 
matrix B6 = e(b)[1,1], e(V)[1,1]
restore 

local if if inlist(first_treat,0,2000) & inlist(time,1999,2000)
local xvar x
drdid y `xvar' `if', ivar(id) time(time) tr(first_treat) reg gmm
matrix A1 = e(b)[1,1], e(V)[1,1]
drdid y `xvar' `if', ivar(id) time(time) tr(first_treat) dripw gmm  
matrix A2 = e(b)[1,1], e(V)[1,1]
drdid y `xvar' `if', ivar(id) time(time) tr(first_treat) drimp gmm  
matrix A3 = e(b)[1,1], e(V)[1,1]
drdid y `xvar' `if', ivar(id) time(time) tr(first_treat) ipw gmm 
matrix A4 = e(b)[1,1], e(V)[1,1]
drdid y `xvar' `if', ivar(id) time(time) tr(first_treat) stdipw gmm 
matrix A5 = e(b)[1,1], e(V)[1,1]
cap noi drdid y `xvar' `if', ivar(id) time(time) tr(first_treat) ipwra gmm 
matrix A6 = e(b)[1,1], e(V)[1,1]

assert mreldif(A1,B1) <1E-10
assert mreldif(A2,B2) <1E-10
assert mreldif(A3,B3) <1E-10
assert mreldif(A4,B4) <1E-10
assert mreldif(A5,B5) <1E-10
assert mreldif(A6,B6) <1E-10
