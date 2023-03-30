capture program drop match_fer
program define match_fer
local r=`1'

*keep cell* id* newid hhseq*  wgt* donor  
capture drop wgtmin
gen flag=1
bysort cell`r':egen sdx=sd(donor)
replace flag=0 if sdx==0

preserve 
keep if cell`r'==. | flag==0
save noused_0, replace
restore

keep if cell`r'!=.
keep if flag==1

gen sflag=-1
bysort cell`r' donor (id`r'): gen ix=_n

/**/
capture drop wtmin
bysort cell`r' ix:egen wgtmin=min(wgt1) if ix==1 & flag==1
expand 2 if ix==1 & flag==1
capture drop t
bysort id:gen t=_n

replace wgt1=wgtmin      if t==2 & ix==1
replace wgt1=wgt1-wgtmin if t==1 & ix==1
drop if wgt1==0

replace  flag=0 if t==2 & ix==1 &  flag==1
replace sflag=0 if t==2 & ix==1 & sflag==-1
capture drop ix

bysort flag cell`r' donor (id`r'): gen ix=_n
*edit cell0 id0 donor wgt1 ix wgtmin ix sflag if cell0==860
capture drop xx
bysort cell`r':egen xx=sd(donor)
replace flag=0 if xx==0 | xx==.

preserve 
keep if flag==0
sort cell`r' donor
by cell`r' :gen x=_N
keep if x==2 & xx!=0 
save mchx0, replace
restore

preserve 
keep if flag==0
sort cell`r' donor
by cell`r':gen x=_N
keep if x==1 | xx==0 | xx==.
save umchx0, replace
restore
drop if flag==0

bysort cell`r':gen NN=_N
sum NN
local cmax=r(max)
drop NN
*******************************************************************
display "trim `cmax'"
local i=1
while  `cmax'!=0 {
display "trim `i'"
qui {
capture drop wgtmin
bysort cell`r' ix:egen wgtmin=min(wgt1) if ix==1 & flag==1
expand 2 if ix==1 & flag==1
capture drop t
bysort id flag:gen t=_n

replace wgt1=wgtmin if t==2 & ix==1 & flag==1
replace wgt1=wgt1-wgtmin if t==1 & ix==1 & flag==1
drop if wgt1==0

replace flag=0 if t==2 & ix==1 & flag==1
replace sflag=`i' if t==2 & ix==1 & sflag==-1
capture drop ix
bysort flag cell`r' donor (id`r'): gen ix=_n


************************
capture drop xx
bysort cell`r':egen xx=sd(donor)
replace flag=0 if xx==0 | xx==.
 
***********************
preserve 
keep if flag==0
sort cell`r' donor
by cell`r':gen x=_N
keep if x==2 & xx!=0 
save mchx`i', replace
restore

preserve 
keep if flag==0
sort cell`r' donor
by cell`r' :gen x=_N
keep if x==1 | xx==0 | xx==.
save umchx`i', replace
restore
drop if flag==0
if _N==0 {
  local mx=`i'
  local cmax=0
}
local i=`i'+1
}
}



clear
forvalues i =0/`mx' {

append using mchx`i'
rm mchx`i'.dta
}
*save match_rX`r', replace
replace newid=newid[_n+1] if newid==.
drop if hhseq==.
keep hhseq newid wgt1 cell`r'
save match_r`r', replace
 
use noused_0, clear
forvalues i=0/`mx' {
append using umchx`i', 
rm umchx`i'.dta
}

local rr=`r'+1
* round 1
save r`rr', replace

* round 1
end 


