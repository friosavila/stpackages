frause oaxaca, clear
drop if lnwage==.
reg lnwage  
predict res, res
gen ares=abs(res)
reg ares  
predict hares
gen one = 1
gen sres = res/hares
qreg sres, q(10)
mata:
	y = st_data(.,"lnwage")
	x = st_data(.," one")
	xx = cross(x,x)
	ixx= invsym(xx)
	xy = cross(x,y)
	b  = ixx * xy
	e  = y:-x*b
	ae = abs(e)
	xae = cross(x,ae)
	g  = ixx * xae
	v  = ae:-x*g
	fr =.0941260747906892
	qr =-1.366260647773743
	qv = 0.1
	n  =rows(x)
	xg=x*g
	xb=x*b
	vv=2*v:*((v:>0):-mean((v:>0)))
end

mata:
	if1 = n * (x:*e) * ixx 
	if2 = n * (x:*v) * ixx :- if1 * mean(sign(e))
	if3 = 1/fr * (qv :- ((e:/xg):<qr)) :- 
			e/mean(xg)  :- 
			qv*vv*mean(xb)/mean(xg)
	iff = if1,if2,if3
	diagonal(cross(iff,iff)/1434^2):^.5
end


Quantile:  10
------------------------------------------------------------------------------
             |               Robust
      lnwage | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
location     |
       _cons |   3.357604   .0140186   239.51   0.000     3.330128     3.38508
-------------+----------------------------------------------------------------
scale        |
       _cons |   .3658845    .010712    34.16   0.000     .3448893    .3868796
-------------+----------------------------------------------------------------
qtile        |
       _cons |   2.857711   .0308522    92.63   0.000     2.797242     2.91818
------------------------------------------------------------------------------
--
