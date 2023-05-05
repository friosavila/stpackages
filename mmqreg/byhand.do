frause oaxaca, clear
drop if lnwage==.
reg lnwage educ exper tenure
predict res, res
gen ares=abs(res)
reg ares educ exper tenure
predict hares
gen one = 1
gen sres = res/hares
qreg sres, q(10)
mata:
	y = st_data(.,"lnwage")
	x = st_data(.,"educ exper tenure one")
	xx = cross(x,x)
	ixx= invsym(xx)
	xy = cross(x,y)
	b  = ixx * xy
	e  = y:-x*b
	ae = abs(e)
	xae = cross(x,ae)
	g  = ixx * xae
	v  = ae:-x*g
	fr =.0777869956233676
	qr =-1.655017018318176
	qv = 0.1
	n  =rows(x)
	xg=x*g
	xb=x*b
end

mata:
	if1 = n * (x:*e) * ixx 
	if2 = n * (x:*v) * ixx :- if1 * mean(sign(e))
	if3 = 1/fr * (qv :- ((e:/xg):<qr)) 
	      :- mean(x)':/mean(xg)*if1 
		  :- mean(xb):/mean(xg):mean(x')*if2
end