cscript cert2.do

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
drdid y `xvar', ivar(id) time(time) tr(first_treat) reg 
matrix A = e(b), e(V)
drdid y `xvar', ivar(id) time(time) tr(first_treat) reg gmm
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', ivar(id) time(time) tr(first_treat) dripw 
matrix A = e(b), e(V)
drdid y `xvar', ivar(id) time(time) tr(first_treat) dripw gmm  
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', ivar(id) time(time) tr(first_treat) drimp
matrix A = e(b), e(V)
drdid y `xvar', ivar(id) time(time) tr(first_treat) drimp gmm  
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', ivar(id) time(time) tr(first_treat) ipw 
matrix A = e(b), e(V)
drdid y `xvar', ivar(id) time(time) tr(first_treat) ipw gmm 
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', ivar(id) time(time) tr(first_treat) stdipw 
matrix A = e(b), e(V)
drdid y `xvar', ivar(id) time(time) tr(first_treat) stdipw gmm 
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', ivar(id) time(time) tr(first_treat) ipwra 
matrix A = e(b), e(V)
cap noi drdid y `xvar', ivar(id) time(time) tr(first_treat) ipwra gmm 
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
restore 


preserve
keep if inlist(first_treat,0,2000) & inlist(time,1999,2001)
local xvar x
drdid y `xvar', ivar(id) time(time) tr(first_treat) reg 
matrix A = e(b), e(V)
drdid y `xvar', ivar(id) time(time) tr(first_treat) reg gmm
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', ivar(id) time(time) tr(first_treat) dripw 
matrix A = e(b), e(V)
drdid y `xvar', ivar(id) time(time) tr(first_treat) dripw gmm   
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', ivar(id) time(time) tr(first_treat) drimp
matrix A = e(b), e(V)
drdid y `xvar', ivar(id) time(time) tr(first_treat) drimp gmm 
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', ivar(id) time(time) tr(first_treat) ipw 
matrix A = e(b), e(V)
drdid y `xvar', ivar(id) time(time) tr(first_treat) ipw gmm 
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', ivar(id) time(time) tr(first_treat) stdipw 
matrix A = e(b), e(V)
drdid y `xvar', ivar(id) time(time) tr(first_treat) stdipw gmm 
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', ivar(id) time(time) tr(first_treat) ipwra 
matrix A = e(b), e(V)
drdid y `xvar', ivar(id) time(time) tr(first_treat) ipwra gmm 
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
restore 

**************************************************************
************************ No Regressors ***********************
**************************************************************

local xvar 
preserve
keep if inlist(first_treat,0,2000) & inlist(time,1999,2000)
drdid y `xvar', ivar(id) time(time) tr(first_treat) reg 
matrix A = e(b), e(V)
drdid y `xvar', ivar(id) time(time) tr(first_treat) reg gmm
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', ivar(id) time(time) tr(first_treat) dripw 
matrix A = e(b), e(V)
drdid y `xvar', ivar(id) time(time) tr(first_treat) dripw gmm  
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', ivar(id) time(time) tr(first_treat) drimp
matrix A = e(b), e(V)
drdid y `xvar', ivar(id) time(time) tr(first_treat) drimp gmm  
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', ivar(id) time(time) tr(first_treat) ipw 
matrix A = e(b), e(V)
drdid y `xvar', ivar(id) time(time) tr(first_treat) ipw gmm 
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', ivar(id) time(time) tr(first_treat) stdipw 
matrix A = e(b), e(V)
drdid y `xvar', ivar(id) time(time) tr(first_treat) stdipw gmm 
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', ivar(id) time(time) tr(first_treat) ipwra 
matrix A = e(b), e(V)
cap noi drdid y `xvar', ivar(id) time(time) tr(first_treat) ipwra gmm 
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
restore 

preserve
keep if inlist(first_treat,0,2000) & inlist(time,1999,2001)
drdid y `xvar', ivar(id) time(time) tr(first_treat) reg 
matrix A = e(b), e(V)
drdid y `xvar', ivar(id) time(time) tr(first_treat) reg gmm
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', ivar(id) time(time) tr(first_treat) dripw 
matrix A = e(b), e(V)
drdid y `xvar', ivar(id) time(time) tr(first_treat) dripw gmm   
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', ivar(id) time(time) tr(first_treat) drimp
matrix A = e(b), e(V)
drdid y `xvar', ivar(id) time(time) tr(first_treat) drimp gmm 
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', ivar(id) time(time) tr(first_treat) ipw 
matrix A = e(b), e(V)
drdid y `xvar', ivar(id) time(time) tr(first_treat) ipw gmm 
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', ivar(id) time(time) tr(first_treat) stdipw 
matrix A = e(b), e(V)
drdid y `xvar', ivar(id) time(time) tr(first_treat) stdipw gmm 
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', ivar(id) time(time) tr(first_treat) ipwra 
matrix A = e(b), e(V)
drdid y `xvar', ivar(id) time(time) tr(first_treat) ipwra gmm 
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
restore 