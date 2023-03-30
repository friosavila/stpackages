** cleaner version for NEWMMQREG
 webuse nlswork, clear
 
gen one = 1
global y ln_wage
global x2 age grade collgrad south union tenure 
global x $x2 one
reg $y $x2 
keep if e(sample) ==1
** First NO FE just plain data
mata:
y   = st_data(.,"$y")
x   = st_data(.,"$x")
n = rows(y)
end

mata:
// OLS:location
xx  =quadcross(x,x)
xy  =quadcross(x,y)
ixx =invsym(xx)
b   =ixx*xy
e   =y-x*b
xb= x*b

end
mata:
// scale
ae  =abs(e)
xae = quadcross(x,ae)
g   =ixx*xae
ee  =ae - x*g 
xg = x*g 
end

mata:
// Influence Functions:
// g1 =  E(x(y-xb)) =E(h(b))
// g2 =  E(x(|y-xb|-xg))
// g11=  E(x'x)
// IF1=g11^-1 *h(b) = E(x'x)*x(y-xb)
nxx = xx/n
if1 = (x:*e)*invsym(nxx)
end

mata:
// IF2 = g22^-1 *( h(b,g) - g21 * if1)
// g21 = E()
g21 = (cross(x,sign(e),x))/n
if2 = ((x:*ee):-if1*g21')*invsym(nxx) 
if2b = ((x:*ee)*invsym(nxx):-if1*mean(sign(e))) 
// asymptotically (cross(x,sign(e),x))/n~mean(sign(e))*cross(x,x)
end


// IF for eq1 is easy
mata:cross(if1,if1)/n^2
// IF for eq2 is not that easy. Depends on assumptions. Mainly IID. In theory, XeX=XX'mean(e)
mata:sqrt(cross(if2,if2)/n^2)
mata:sqrt(cross(if2b,if2b)/n^2)

/// IFS for Qpart
/// G33^-1 = 1/f
/// G33^-1 = 1/f

mata:
qv =-.0183806
se = (y :- xb):/xg
f=normalden((qv:-se)/0.14)/.14
g33=-mean(f)

g31=mean(f:*x:/xg)
g32=mean(f:*se:*x:/xg)
mata:g1 = mean(f:*x:/xg)
mata:g2 = mean(f:*se:*x:/xg)
/// ifa = 1/mf* ((t:-F) -(g1*if1)'-(g2*if2)') 
mata:if3= 1/g33*(normal((qv:-se)/0.14):-.5:+if1*g31':+if2*g32')
mata:sqrt(cross(if3,if3)/n^2)
end


// uses NUmerical and analytical derivatives. Analytical is faster
gmm ($y-{b:$x2 _cons }) (abs($y-{b:})-{g:$x2 _cons }), ///
instruments($x2) winitial(identity) onestep 
gmm ($y-{b:$x2 _cons }) ///
    (abs($y-{b:})-{g:$x2 _cons }) ///
	(normal(({q}-(($y-{b:})/{g:}))/0.14) -0.5), ///
	instruments(1:$x2) instruments(2:$x2) winitial(identity) onestep ///
	derivative(1/b=-1) ///
	derivative(2/g=-1) derivative(2/b=-sign($y-{b:})) ///
	derivative(3/q=normalden({q}-(($y-{b:})/{g:}))/0.14 ) ///
	derivative(3/b=normalden({q}-(($y-{b:})/{g:}))/0.14 * 1/{g:}) ///
	derivative(3/g=normalden({q}-(($y-{b:})/{g:}))/0.14 * (($y-{b:})/{g:})*1/{g:}) from(kk)

/*

-------------+----------------------------------------------------------------
b            |
         age |   .0024962   .0004909     5.08   0.000      .001534    .0034585
       grade |    .067016   .0019518    34.34   0.000     .0631905    .0708415
    collgrad |   .0641492   .0117178     5.47   0.000     .0411828    .0871156
       south |  -.1372369   .0057774   -23.75   0.000    -.1485604   -.1259134
       union |   .1302201   .0066784    19.50   0.000     .1171306    .1433095
      tenure |   .0301348   .0007534    40.00   0.000     .0286581    .0316115
       _cons |   .7166881   .0271665    26.38   0.000     .6634428    .7699333
-------------+----------------------------------------------------------------
g            |
         age |   .0062579    .000327    19.13   0.000     .0056169    .0068989
       grade |   .0039256   .0013017     3.02   0.003     .0013743    .0064769
    collgrad |   .0109575   .0075803     1.45   0.148    -.0038996    .0258145
       south |  -.0155972    .003816    -4.09   0.000    -.0230764    -.008118
       union |   -.009016   .0043927    -2.05   0.040    -.0176255   -.0004064
      tenure |  -.0042242    .000488    -8.66   0.000    -.0051807   -.0032678
       _cons |   .0642559   .0180834     3.55   0.000     .0288131    .0996986
-------------+----------------------------------------------------------------
          /q |  -.0184673   .0081872    -2.26   0.024    -.0345138   -.0024207
------------------------------------------------------------------------------

*/	
mata:se=e:/xg
** 0.14
** .1733370315
mata:1.3643*((1/(4*pi()))^.1)*n^(-1/5)*min((sd(se),(mm_quantile(se,1,0.75)-mm_quantile(se,1,0.25))/(invnormal(.75)-invnormal(.25))))
end

getmata e
getmata xg 
gen se = e/xg
qreg se, q(10)
gmm (normal(({q=0}-se)/.14)-0.50), onestep
mata:q10=st_matrix("e(b)")
mata:b10=0.3
mata:t = 0.80

** First we need normal
** OK This replicates MMQEG pero solo locally
mata:
	se=e:/xg
	q_y_h=(q10:-se):/b10
	F = normal(q_y_h)
	f = normalden(q_y_h)/b10
	mf=mean(f)
	i3=1/mean(f)*(F:-t)
	g1 = mean(f:*x:/xg)
	g2 = mean(f:*se:*x:/xg)
	g11 = mean(x:/xg) 
	g22 = mean(se:*x:/xg) 
	ifa = 1/mf* ((t:-F) -(g1*if1)'-(g2*if2)') 
	ifc = (t:-(q10:>se))/mean(f)-if1'*mean(x:/xg)'-if2'*mean(q10*x:/xg)'
end
 mata:ifx = if1',if2',ifa

 mata:sqrt(cross((ifa,ifc),(ifa,ifc))/(rows(ifa):^2))
 mata:sqrt(cross(ifc,ifc)/(rows(ifa):^2))
  mata:cross(ifx,ifx)/(rows(ifa):^2)

          /q05 |  -1.406862   .0779897   -18.04   0.000    -1.559719   -1.254005
          /q10 |  -1.214004   .0557442   -21.78   0.000    -1.323261   -1.104748
          /q25 |  -.8705325   .0251138   -34.66   0.000    -.9197547   -.8213102
          /q70 |   .3294349   .2160921     1.52   0.127    -.0940978    .7529676		  
		  /q80 |   1.119604   .1696117     6.60   0.000     .7871714    1.452037
		  /q90 |   1.834954   .1918442     9.56   0.000     1.458947    2.210962
gmm (eq1:price-           {b0:_cons mpg foreign}) ///
    (eq2:abs(price-{b0:})-{g0:_cons mpg foreign}) ///
	(normal(({q}-(price-{b0:})/{g0:})/0.3)-0.8), ///
	instruments(eq1: mpg foreign) ///
	instruments(eq2: mpg foreign) winit(identity ) onestep from(gm)

program drop yyy
	program yyy
capture drop res ares sres gm
reg price mpg foreign
predict res, res
gen ares=abs(res)
reg ares mpg foreign
predict gm
gen sres=res/gm
*gmm (normal(({q=0}-sres)/.3)-$q), onestep
qreg sres, q($q)
end	
global q 0.90
bootstrap, reps(200):yyy
	
 use c:\data\oaxaca, clear	
 drop if lnwage==.
 gen one =1
global y lnwage 
global x educ exper tenure female one
global xx educ exper tenure female  

mata:
y   = st_data(.,"$y")
x   = st_data(.,"$x")
xx  =quadcross(x,x)
xy  =quadcross(x,y)
ixx =invsym(xx)
b   =ixx*xy
e   =y-x*b
xb= x*b
ae  =abs(e)
xae = quadcross(x,ae)
g   =ixx*xae
ee  =ae - x*g 
xg = x*g 
n = rows(y)
nxx = xx/n
xex = quadcross(x,sign(e),x)
nxex = xex/n
if1 = invsym(nxx)*(x:*e)'
if2 = invsym(nxx)*((x:*ee)' :- nxex*invsym(nxx)*(x:*e)')
// IF3 for QREG 
end

getmata e
getmata xg 
gen se = e/xg
drop iq??
egen iq10 = rifvar(se), q3(10) bw(0.07)
egen iq25 = rifvar(se), q3(25) bw(0.07)
egen iq50 = rifvar(se), q3(50) bw(0.07)
egen iq75 = rifvar(se), q3(75) bw(0.07)
egen iq90 = rifvar(se), q3(90) bw(0.07)

mata
iq10x = st_data(.,"iq10") 
iq25x = st_data(.,"iq25") 
iq50x = st_data(.,"iq50") 
iq75x = st_data(.,"iq75") 
iq90x = st_data(.,"iq90") 
iq10=iq10x:-mean(iq10x)
iq25=iq25x:-mean(iq25x)
iq50=iq50x:-mean(iq50x)
iq75=iq75x:-mean(iq75x)
iq90=iq90x:-mean(iq90x)
end

mata:iqx =iq10 - if1'*mean(x:/xg)'	    +((e:*if2')*mean(x:/xg)')
mata:iqy =iq25 - if1'*mean(x:/xg)'	    +((e:*if2')*mean(x:/xg)')
mata:iqz =iq50 - if1'*mean(x:/xg)'	    +((e:*if2')*mean(x:/xg)')
mata:iqw =iq75 - if1'*mean(x:/xg)'	    +((e:*if2')*mean(x:/xg)')
mata:iqa =iq90 - if1'*mean(x:/xg)'	    +((e:*if2')*mean(x:/xg)')

mata:(mean(iqx:^2)/rows(iqx)):^.5
mata:(mean(iqy:^2)/rows(iqx)):^.5
mata:(mean(iqz:^2)/rows(iqx)):^.5
mata:(mean(iqw:^2)/rows(iqx)):^.5
mata:(mean(iqa:^2)/rows(iqx)):^.5
** Need to rework the IFs for Q. 
mata:mean(iq75x)
gmm (eq1:$y-           {b0:_cons $xx}) ///
    (eq2:abs($y-{b0:})-{g0:_cons $xx}) ///
	(normal(({q1}-(($y-{b0:})/{g0:}))/0.07)-0.10) ///
	(normal(({q2}-(($y-{b0:})/{g0:}))/0.07)-0.25) ///
	(normal(({q3}-(($y-{b0:})/{g0:}))/0.07)-0.50) ///
	(normal(({q4}-(($y-{b0:})/{g0:}))/0.07)-0.75) ///
	(normal(({q5}-(($y-{b0:})/{g0:}))/0.07)-0.90), ///, ///
	instruments(eq1: educ exper tenure female) ///
	instruments(eq2: educ exper tenure female) winit(identity ) onestep  from(gm) 

program drop xxx
program xxx
capture drop res
capture drop hh
capture drop sres
capture drop ares
reg $y $x
predict res, res
gen ares = abs(res)
reg ares $x
predict hh
gen sres = res/hh
rifhdreg sres , rif(q3($q) bw(0.07))
end

global q = 75
bootstrap, nodots reps(500): xxx

mata:sd(x*g)
gmm (eq1:price-           {b0:_cons mpg foreign}) ///
    (eq2:abs(price-{b0:})-{g0:_cons mpg foreign}) ///
	(normal( ({q=1}-((price-{b0:})/({g0:})))/0.3)-0.9), ///
	instruments(eq1: mpg foreign) ///
	instruments(eq2: mpg foreign) winit(identity ) onestep from(gm)
	
gmm (eq1:price-           {b0:_cons mpg foreign}) ///
    (eq2:{b0:}-{g0}), ///
	instruments(eq1:                     mpg foreign) winit(identity ) onestep 	

mata:74*((mean(y):-x*b):
mata:cross(iff1,iff1)/74/74
end	
iff1*mean(x)'
:-x*g
mata:ii=(mean(y):-x*b)+iff1*mean(x)'
mata:iii=(y:-mean(y))
mata:(cross(ii,ii)/74/74)^.5

       price |   6.165257   .3428719      5.481914    6.848599

mata: lif=(x:*ee:+((x:*e)*ixx)*cross(x,abs(e),x))*ixx

local res  (lnwage-{b0:})/{g0:}

gmm (eq1: lnwage - {b0: educ exper tenure _cons} ) ///
	(eq2: abs(lnwage-{b0:}) - {g0: educ exper tenure _cons} )  ///
	, instruments(eq1: educ exper tenure) instruments(eq2: educ exper tenure)  ///
	onestep winitial(identity)  
	
gmm (eq1: lnwage - {b0: educ exper tenure _cons} ) ///
	(eq2: abs(lnwage-{b0:}) - {g0: educ exper tenure _cons} ) ///
	(normal( ({q}-((lnwage-{b0:})/({g0:})))/0.07)-0.1) ///
	, instruments(eq1: educ exper tenure) instruments(eq2: educ exper tenure)  ///
	onestep winitial(identity)  from(bb) tracelevel(value)

------------------------------------------------------------------------------
             |               Robust
             | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
b0           |
        educ |   .0869863    .006028    14.43   0.000     .0751716    .0988009
       exper |   .0112688    .001468     7.68   0.000     .0083916    .0141461
      tenure |   .0083675   .0017199     4.87   0.000     .0049965    .0117385
       _cons |   2.140049   .0799261    26.78   0.000     1.983397    2.296701
-------------+----------------------------------------------------------------
g0           |
        educ |  -.0134403   .0038272    -3.51   0.000    -.0209413   -.0059392
       exper |  -.0055458   .0010468    -5.30   0.000    -.0075976    -.003494
      tenure |   .0028627   .0011683     2.45   0.014     .0005729    .0051525
       _cons |   .5254016   .0521331    10.08   0.000     .4232226    .6275805
-------------+----------------------------------------------------------------
          /q |  -2.498325   .0833547   -29.97   0.000    -2.661697   -2.334953
------------------------------------------------------------------------------

gmm (normal( ({q:educ exper _cons}-lnwage)/0.07)-0.01), instruments(educ exper )
	
global x 	educ exper tenure female age
gmm (normal(({q:$x _cons}-lnwage)/0.07)-0.01), instrument($x)
matrix bb=e(b)
forvalues  i = 1/99 {
	local j = `i'/100
qui:gmm (normal(({q:$x _cons}-lnwage)/0.02)-`j'), instrument($x) from(bb)
matrix  kk =r(table)
matrix bb=e(b)
matrix bcc=nullmat(bcc)\e(b)
display `i'
} 

replace price = price / 1000
replace mpg = mpg/10
global x mpg foreign
gmm (normal(({q:$x _cons}-lnwage)/0.06)-0.01), instrument($x) onestep 
matrix bb=e(b)
forvalues  i = 1/99 {
	local j = `i'/100
qui:gmm (normal(({q:$x _cons}-price)/0.06)-`j'), instrument($x) from(bb)
matrix  kk =r(table)
matrix bb=e(b)
matrix bbs=kk["b",....],kk["ll",....],kk["ul",....]
matrix bcc=nullmat(bcc)\bbs
display `i'
} 



forvalues  i = 1/99 {
	local j = `i'/100
	qui:qrprocess price mpg foreign, q(`j')
	matrix r=r(table)
	matrix b=r[]
	display `i'
} 

svmat bcy

gmm (eq1:normal(({q1:$x _cons}-lnwage)/0.07)-.10)  ///
(eq2:normal(({q2:$x _cons}-lnwage)/0.07)-.90) , ///
				instrument($x) winitial(identity) onestep from(b12)

				
sysuse auto
replace price = price /1000
replace mpg = mpg/10
gmm (normal(({q:$x _cons}-price)/0.6)-0.9), instrument($x) onestep from(bb)				