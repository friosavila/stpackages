gen female 
foreach i in lnwage exper tenure educ {
    drop m`i'
   sum `i'
   local ll = r(mean)
   bysort age:egen m`i'=mean(`i')
   replace m`i'=`i'-m`i'+`ll'
}

reghdfe lnwage exper tenure educ, abs(age)
reg mlnwage mexper mtenure meduc

mata:mx=st_data(.,"mexper mtenure meduc one")
mata:x=st_data(.,"exper tenure educ one")
mata:invsym(cross(mx,mx))
** UQREG doesnt work, but
gmm (normal(({q}-lnwage)/0.08)-0.5) ///
	(normalden(lnwage-{q},0,0.08)-{f}) ///
    ({q}-(0.1-normal(({q}-lnwage)/0.08))/{f} - {b0: educ _cons}) , instrument(2: educ)  onestep ///
	winitial(identity)  from(/q=3.401642 /f=1.037847 b0:educ=0.0614575 b0:_cons=2.697)
matrix l0=e(b)

** Location Scale QREG via GMM
global y lnwage 
global x educ exper tenure
gmm ( $y - {b0:$x _cons} ) ///
	(normal(({q:$x _cons}-($y-{b0:}))/0.07)-0.05), instruments($x) ///
	winitial(identity)
matrix k=e(b)
gmm ( $y - {b0:$x _cons} ) ///
	(normal(({q:$x _cons}-($y-{b0:}))/0.07)-0.5), instruments($x) ///
	winitial(identity) from(k) vce(cluster age)
	
xlincom (_b[b0:educ]+_b[q:educ])	(_b[b0:exper]+_b[q:exper]) ///
		(_b[b0:tenure]+_b[q:tenure]) (_b[b0:_cons]+_b[q:_cons])		

gmm (normal(({q:$x _cons}-($y))/0.07)-0.01), instruments($x) ///
	winitial(identity) vce(cluster age)
matrix k =e(b)	
	
forvalues i = 1/99 {
    local j  = `i'/100
qui:gmm (normal(({q:$x _cons}-($y))/0.1)-`j'), instruments($x) ///
	winitial(identity) vce(cluster age) from(k)
matrix b10=nullmat(b10)	\e(b)
qui:gmm (normal(({q:$x _cons}-($y))/0.07)-`j'), instruments($x) ///
	winitial(identity) vce(cluster age) from(k)
matrix b07=nullmat(b07)	\e(b)	
qui:gmm (normal(({q:$x _cons}-($y))/0.04)-`j'), instruments($x) ///
	winitial(identity) vce(cluster age) from(k)
matrix b04=nullmat(b04)	\e(b)    
matrix k = e(b)
display `i'
}	
	
qreg $y $x	, q(95)
qrprocess $y $x	, q(.95) vce( cluster age)