*** example for CQR UQR AND QTE
clear
set obs 100000
set seed 1
drawnorm u1 u2, corr(1 0.5 1) cstorage(lower)
gen  x = normal(u1)*5
gen  z = u2>0.5

gen u3=rnormal()
gen y = 1+x+2*z+u3*(1+0.5*x - z)
replace z=0
gen y0 = 1+x+2*z+u3*(1+0.5*x - z)
replace z=1
gen y1 = 1+x+2*z+u3*(1+0.5*x - z)
replace z = u2>0.5

pctile qy0 = y0, n(100)
pctile qy1 = y1, n(100)
gen dq = qy1-qy0
gen qq= _n if _n<100
scatter dq qq

reg z x, 
predict zres, res

rifhdreg y x z, over(z) rif(q(10)) rwlogit(x)
 qregplot z, q(1/99)
addplot : scatter dq qq

keep in 1/1000
gen y10 = 1+x+2*z+invnormal(0.10)*(1+0.5*x - z)
gen y90 = 1+x+2*z+invnormal(0.90)*(1+0.5*x - z)

two scatter y x if z==1, msize(small) || ///
	scatter y x if z==0, msize(small) , ///
	legend(order(1 "z==1" 2 "z==0"))  ///
	title("Simulated data with heterogeneity") ///
	xsize(15) ysize(10)
	
** CQR

two (scatter y x if z==1, msize(small) color(%30) ) || ///
	(scatter y x if z==0, msize(small) color(%30) ) || ///
	(line    y10 x if z==1, sort pstyle(p1line))       || ///
	(line    y90 x if z==1, sort pstyle(p1line))       || ///
	(line    y10 x if z==0, sort pstyle(p2line))     || ///
	(line    y90 x if z==0, sort pstyle(p2line))    , ///
	legend(order(1 "z==1" 2 "z==0") )	///
	title("What Qreg does") ytitle(y) ///
	xsize(15) ysize(10)
** UQR 
gen y2 = 1+(x+1)+2*z+u3*(1+0.5*(x+1) - z)
gen y3 = 1+(x)+2*(u2>0.3)+u3*(1+0.5*(x) - (u2>0.3))

kdensity y , gen(fy) at(y)
kdensity y2 , gen(fy2) at(y2)

two line fy y, sort	|| line fy2 y2, sort 	|| ///
	pcarrowi 0.0863 0.4254 0.06795 0.898 , pstyle(p3line)     || /// 
	pcarrowi .05046 7.9801   0.0432 9.4928 , pstyle(p4line)   || ///
		pci .02 0.4254  0.02 0.898  .02 7.9801  0.02 9.4928 , ///
	legend(order(1 "y|F(x,z)" 2 "y|F(x+1,z)" 3 "chng in 10q" 4 "chng in 90q" )	) ///
	title("What UQreg does") ytitle("f(y)") xtitle("y")  xsize(15) ysize(10)
	
two kdensity y	|| kdensity y3	                    , ///
	legend(order(1 "y|F(x,z)" 2 "y|F(x,z+20%)"))	///
	title("What UQreg does") ytitle("f(y)") xtitle("y")  xsize(15) ysize(10)

** UQT
gen y0 = 1+x+2*0+u3*(1+0.5*x - 0)
gen y1 = 1+x+2*1+u3*(1+0.5*x - 1)

kdensity y0 , gen(fy0) at(y0)
kdensity y1 , gen(fy1) at(y1)
sort y0 
replace p=_n/_N
list y0 fy0 p if  inrange(p,0.0975,0.1025) | inrange(p,0.895,0.905)

sort y1 
replace p=_n/_N
list y1 fy1 p if  inrange(p,0.0975,0.1025) | inrange(p,0.895,0.905)
 	
 	
two (kdensity y0 , pstyle(p1line) 	) || ///
	(kdensity y1 , pstyle(p2line)  ) || ///
	pcarrowi 0.1095 0.3970  0.193  3.2217 ,pstyle(p3line)     || /// 
	pcarrowi .03776 7.6819  0.0563 8.3722 , pstyle(p4line)   || ///
	pci .02 0.3970  0.02 3.2217  .02 7.6819  0.02 8.3722 , ///
	legend(order(1 "y|F(x,z=0)" 2 "y|F(x,z=1)"  3 "chng in 10q" 4 "chng in 90q"))	///
	title("What QTE does") ytitle("f(y)") xtitle("y")  xsize(15) ysize(10)