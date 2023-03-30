frause wage1, clear
gen id = _n
expand 99
bysort id:gen q=_n
gen wageh=.
gen wageh2=.
forvalues i =1/99 {
	drop2 wh
	qrprocess lwage educ exper tenure female if q==1, q(`=`i'/100')
	predict  wh
	replace 	wageh=wh if q==`i'
	replace 	wageh2=wh+_b[educ] if q==`i'
}


pctile q10 = wageh, n(100)
pctile q11 = wageh2 , n(100)
gen tq = _n
scatter q11 q10 tq if tq<100 , name(m1, replace)
keep q11 q10 tq 
keep if tq<100


frame put *, into(m1)
frause wage1, clear
gen id = _n
expand 2
bysort id:gen t=_n
replace educ = educ+1  if t==1
replace t=t==1

logit t educ exper tenure female 
predict pr
gen w = 1/pr*(1-pr)
sum educ exper tenure female  if t==0
sum educ exper tenure female  if t==1 [w=w]
two kdensity lwage if t==0 || kdensity lwage if t==0 [w=1/w]

pctile q10 = lwage, n(100)
pctile q11 = lwage [w=1/w], n(100)
gen tq = _n
scatter q11 q10 tq if tq<100
keep q11 q10 tq 
keep if tq<100
frame put *, into(m2)

frause wage1, clear

gen q10=.
gen q11=.
forvalues i = 1 / 99 {
	rifhdreg lwage educ exper tenure female , rif(q3(`i'))
	replace q10 = e(rifmean) in `i'
	replace q11 = q10 + _b[educ] in `i'
}
gen tq = _n
scatter q11 q10 tq if tq<100, name(m2, replace)
keep q11 q10 tq 
keep if tq<100
frame put *, into(m3)