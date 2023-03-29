cscript cert4.do

quietly {
cls
set obs 1000
set seed 111
generate id = _n 
generate first_treat =    runiformint(2000,2001)  // runiformint(2000,2004) //
replace first_treat  = 0 if runiform()>.7
expand 4  // expand 7  
bysort id: generate time = _n + 1998
gen touse2 = .
generate double y = rnormal()
replace  y = . if runiform()>.95
generate double x = runiform()
generate double touse = y !=.
}

*************************************************************
********************** No regressors ************************ 
*************************************************************

preserve
keep if inlist(first_treat,0,2000) & inlist(time,1999,2000)
local xvar //x
drdid y `xvar', time(time) tr(first_treat) reg 
matrix A = e(b), e(V)
drdid y `xvar', time(time) tr(first_treat) reg gmm
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', time(time) tr(first_treat) dripw 
matrix A = e(b), e(V)
drdid y `xvar', time(time) tr(first_treat) dripw gmm  
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', time(time) tr(first_treat) drimp
matrix A = e(b), e(V)
drdid y `xvar', time(time) tr(first_treat) drimp gmm  
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', time(time) tr(first_treat) ipw 
matrix A = e(b), e(V)
drdid y `xvar', time(time) tr(first_treat) ipw gmm 
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', time(time) tr(first_treat) stdipw 
matrix A = e(b)[1,1], e(V)[1,1]
drdid y `xvar', time(time) tr(first_treat) stdipw gmm
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', time(time) tr(first_treat) ipwra 
matrix A = e(b)[1,1], e(V)[1,1]
rcof "noi drdid y `xvar', time(time) tr(first_treat) ipwra gmm"==198
restore 


preserve
keep if inlist(first_treat,0,2000) & inlist(time,1999,2001)
local xvar // x
drdid y `xvar', time(time) tr(first_treat) reg 
matrix A = e(b), e(V)
drdid y `xvar', time(time) tr(first_treat) reg gmm
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', time(time) tr(first_treat) dripw 
matrix A = e(b), e(V)
drdid y `xvar', time(time) tr(first_treat) dripw gmm   
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', time(time) tr(first_treat) drimp
matrix A = e(b), e(V)
drdid y `xvar', time(time) tr(first_treat) drimp gmm 
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', time(time) tr(first_treat) ipw 
matrix A = e(b), e(V)
drdid y `xvar', time(time) tr(first_treat) ipw gmm 
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', time(time) tr(first_treat) stdipw 
matrix A = e(b), e(V)
drdid y `xvar', time(time) tr(first_treat) stdipw gmm 
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', time(time) tr(first_treat) ipwra 
matrix B = e(b)[1,1], e(V)[1,1]
rcof "noi drdid y `xvar', time(time) tr(first_treat) ipwra gmm"==198 
restore 

*************************************************************
*********************** Regresssors ************************* 
*************************************************************

preserve
keep if inlist(first_treat,0,2000) & inlist(time,1999,2000)
local xvar x
drdid y `xvar', time(time) tr(first_treat) reg 
matrix A = e(b), e(V)
drdid y `xvar', time(time) tr(first_treat) reg gmm
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8

// !! Numerical differences 
/*
drdid y `xvar', time(time) tr(first_treat) dripw 
matrix A = e(b), e(V)
drdid y `xvar', time(time) tr(first_treat) dripw gmm  
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
*/
drdid y `xvar', time(time) tr(first_treat) drimp
matrix A = e(b), e(V)
drdid y `xvar', time(time) tr(first_treat) drimp gmm  
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8

drdid y `xvar', time(time) tr(first_treat) ipw 
matrix A = e(b), e(V)
drdid y `xvar', time(time) tr(first_treat) ipw gmm 
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', time(time) tr(first_treat) stdipw 
matrix A = e(b), e(V)
drdid y `xvar', time(time) tr(first_treat) stdipw gmm 
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', time(time) tr(first_treat) ipwra 
matrix A = e(b)[1,1], e(V)[1,1]
rcof "noi drdid y `xvar', time(time) tr(first_treat) ipwra gmm"==198
restore 


preserve
keep if inlist(first_treat,0,2000) & inlist(time,1999,2001)
local xvar x
drdid y `xvar', time(time) tr(first_treat) reg 
matrix A = e(b), e(V)
drdid y `xvar', time(time) tr(first_treat) reg gmm
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
/*
!! Numerical differences 
drdid y `xvar', time(time) tr(first_treat) dripw 
matrix A = e(b), e(V)
drdid y `xvar', time(time) tr(first_treat) dripw gmm   
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
*/
drdid y `xvar', time(time) tr(first_treat) drimp
matrix A = e(b), e(V)
drdid y `xvar', time(time) tr(first_treat) drimp gmm 
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8

drdid y `xvar', time(time) tr(first_treat) ipw 
matrix A = e(b), e(V)
drdid y `xvar', time(time) tr(first_treat) ipw gmm 
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', time(time) tr(first_treat) stdipw 
matrix A = e(b), e(V)
drdid y `xvar', time(time) tr(first_treat) stdipw gmm 
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
drdid y `xvar', time(time) tr(first_treat) ipwra 
matrix A = e(b)[1,1], e(V)[1,1]
rcof "noi drdid y `xvar', time(time) tr(first_treat) ipwra gmm"==198
matrix B = e(b)[1,1], e(V)[1,1]
assert mreldif(A,B)<1E-8
restore 
