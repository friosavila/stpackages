clear
set seed 1
set obs 100000

gen survey=runiform()>1/2
gen strata1=int(runiform()*10000)
gen strata2=1
gen weight=ceil((1)*runiform()*10)

tab survey [w=w]
*tab survey strata1 [w=w]
 
gen pscore=runiform()

gen hid1=_n if survey ==0
gen hid2=_n if survey ==1
 
ssmatch2, id1(hid1) id2(hid2) survey(survey) weight(weight) strata(strata1 strata2) pscore(pscore pscore)
	
	