

*** local r
tempvar wtmin  
tempvar flag aux
gen `flag'=0
*bysort g:
bysort strata:egen `aux'=sd(survey)
replace `flag'=1 if `aux'==0
gen long __id = _n
** store some data
  
 
drop if `flag'==1
tempvar sflag
gen byte `sflag'=-1
tempvar ix
bysort strata survey (pscore): gen double `ix'=_n

gen nsurvey=1-survey
mata:xs1=st_data(.,"strata survey w __id pscore","survey")
mata:xs0=st_data(.,"strata survey w __id pscore","nsurvey")

*** Need to adjust for Strata: Sort by Strata, do i need survey?
*** 
mata: 
    i=1
	j=1
	ii=0
	nx1=rows(xs1)
	nx0=rows(xs0)
	xxs1=J(nx0+nx1,5,0)
	xxs0=J(nx0+nx1,5,0)
	
	while (i<=nx1 & j<=nx0) {
		ii++
		wmin = rowmin((xs1[i,3],xs0[j,3]))
		 
		// store with split data
		xxs1[ii,]=xs1[i,1..2],wmin,xs1[i,4],xs0[j,4]
		xxs0[ii,]=xs0[j,1..2],wmin,xs0[j,4],xs1[i,4]
		// take min out
		xs1[i,]=xs1[i,1..2],xs1[i,3]-wmin,xs1[i,4..5]
		xs0[j,]=xs0[j,1..2],xs0[j,3]-wmin,xs0[j,4..5]
 
		if (xs1[i,3]==0) i++
		if (xs0[j,3]==0) j++
	}
	
	//xxs0=xxs0[(1::ii),]
	xxs1=xxs1[(1::ii),]
	///\
	mata:x=xxs1[(1::ii),]\xxs1[(1::ii),(1,2,3,5,4)]
end

mata: 


	if (i<=nx1) xs1=xs1[(i::nx1),]
	else xs1=J(0,5,0)
	if (j<=nx0) xs0=xs0[(j::nx0),]
	else xs0=J(0,5,0)
 
	mata:colsum(xs1)
	mata:colsum(xs0)
		
end
tab survey [w=w]
 