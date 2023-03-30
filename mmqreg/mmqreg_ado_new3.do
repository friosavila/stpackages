use c:\data\oaxaca,clear
drop if lnwage==.
global y lnwage
global x educ exper tenure female
gen one = 1


webuse nlswork, clear
 
gen one = 1
global y ln_wage
global x age grade collgrad south union tenure 

reg $y $x
keep if e(sample)

mata:
y   = st_data(.,"$y")
x   = st_data(.,"$x one")

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
//** STANDARD, Later FOR Demeaned
if1 = invsym(nxx)*(x:*e)'
if2 = invsym(nxx)*((x:*ee)' :- nxex * if1)
// IF3 for QREG 

end

getmata e
getmata xg 
gen se = e/xg
qreg se, q(50)
mata:b10=0.14
mata:t = 0.50
gmm (normal(({q=0}-se)/.14)-.5), onestep
mata:q10=st_matrix("e(b)")


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

 mata:sqrt(cross((ifa),(ifa))/(rows(ifa):^2))

 *** Aleternatives
 mata:
 xex = quadcross(x,sign(e),x)
 if1b = invsym(nxx)*(x:*e)'
 if2b = invsym(nxx)*(x:*ee)' :- mean(sign(e)) * if1b
 end
 mata:sqrt(cross(if2',if2') )
 mata:sqrt(cross(if2b',if2b') )

 mata:
 if2'*(mean(f:*se:*x:/xg))'
 if2'*(mean(f:*se)*mean(x:/xg))'
 if2'*(mean(f:*se)*mean(x):/mean(xg))'
 if2'*(mean(f:*se:/xg)*mean(x))'
end
if1 = invsym(nxx)*(x:*e)'
if2 = invsym(nxx)*((x:*ee)' :- nxex * if1)

mata: 
	
	g1 = mean(f:*x:/xg)
	g2 = mean(f:*se:*x:/xg)
	g11 = mean(x:/xg) 
	g22 = mean(se:*x:/xg) 
	ifa = 1/mf* (t:-F) - (g11*if1)'-(g2*if2)') 
	
if3alt=1/mf*(t:-F):-(e:/xg)-mean(f:*se)*(ee:/xg):-mean(sign(e)):*e:/xg
end 
 
global x educ exper tenure female age single
 
gmm (eq1:$y-           {b0:_cons $x}) ///
    (eq2:abs($y-{b0:})-{g0:_cons $x}), ///
	instruments(eq1: $x) ///
	instruments(eq2: $x) winit(identity ) onestep 
	matrix gm = e(b),1
gmm (eq1:$y-           {b:_cons $x}) ///
    (eq2:abs($y-{b:})-{g:_cons $x}) ///
	(normal(({q}-($y-{b:})/{g:})/0.14)-0.5), ///
	instruments(eq1: $x) ///
	instruments(eq2: $x) winit(identity ) onestep from(gm) 
nlcom (_b[b:educ]+_b[g:educ]*_b[/q])	///
      (_b[b:exper]+_b[g:exper]*_b[/q])	///
	  (_b[b:tenure]+_b[g:tenure]*_b[/q])	///
      (_b[b:female]+_b[g:female]*_b[/q])	///
      (_b[b:age]+_b[g:age]*_b[/q])	///
      (_b[b:single]+_b[g:single]*_b[/q])	
	  
** ESTa ESTA MAL, pero no se por que:
 gmm (eq1:$y-           {b:_cons $x}) ///
    (eq2:abs($y-{b:})-{g:_cons $x}) ///
	(normal(({q}-($y-{b:})/{g:})/0.14)-0.5), ///
	instruments(eq1: $x) ///
	instruments(eq2: $x) winit(identity ) onestep from(gm) ///
	derivative(1/b=-1) ///
	derivative(2/g=-1) derivative(2/b=-sign($y-{b:})) ///
	derivative(3/q=normalden({q}-(($y-{b:})/{g:}))/0.14 ) ///
	derivative(3/b=normalden({q}-(($y-{b:})/{g:}))/0.14 * 1/{g:}) ///
	derivative(3/g=normalden({q}-(($y-{b:})/{g:}))/0.14 * (($y-{b:})/{g:})*1/{g:})  
	
matrix gm = e(b)	
 
gmm (eq1:$y-           {b:_cons $x}) ///
    (eq2:abs($y-{b:})-{g:_cons $x}) ///
	(normal(({q}-($y-{b:})/{g:})/0.14)-0.5), ///
	instruments(eq1: $x) ///
	instruments(eq2: $x) winit(identity ) onestep from(gm) 
	
matrix gm = e(b) 	