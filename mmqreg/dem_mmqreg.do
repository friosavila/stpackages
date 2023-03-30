use c:\data\oaxaca, clear
keep if lnwage!=.
global y lnwage
global x  exper educ tenure female
gmm ($y - {b:$x _cons}) ///
	(abs($y - {b:})-{g:$x _cons}), instruments($x) winitial(identity) onestep
	
mata:
y = st_data(.,"$y")	
x = st_data(.,"$x"),J(rows(y),1,1)
b = invsym(cross(x,x))*cross(x,y)
e = y - x*b
n = rows(y)
if1 = (x:*e)*n*invsym(cross(x,x))

g = invsym(cross(x,x))*cross(x,abs(e))
ee = abs(e) - x*g
xg=x*g
n = rows(y)
nxx = cross(x,x)/n
nxex = quadcross(x,sign(e),x)/n
** exact
if2 = ((x:*ee):-if1*nxex )*invsym(nxx)
** Approximation
if2b = ((x:*ee))*invsym(nxx):-if1*mean(sign(e)) 
** 
ee2=2*e:*((e:>0):-mean(e:>0))
if2c = ((x:*ee2))*invsym(nxx)
end

gmm ($y - {b:$x _cons}) ///
	(ee2-{g:$x _cons}) ///
	(normal( ({q}*{g:}+{b:} - $y ) /.1  )-.75 ), ///
	instruments(1:$x) instruments(2:$x) winitial(identity) onestep from(j)
	
gmm ($y - {b:$x _cons}) ///
	(ee2-{g:$x _cons}) ///
	(normal( ({q}- ($y-{b:})/{g:}  ) /.1  )-.75 ), ///
		instruments(1:$x) instruments(2:$x) winitial(identity) onestep from(j)
		
* TWo approaches. Both could be true asymptotically, but not exact in smaller samples.
1. estimate q directly
2. estimate q indirectly via q_xy		
	
	
gmm ( normal( ({q}- ($y- mb )/mg )/.1 ) -.75	)

gmm ( normal( ({q}*mg+mb - $y )/.1 ) -.75	)
** how to show   IF2b = IF2c

mata:sqrt(cross(if2,if2)/n/n)
mata:sqrt(cross(if2b,if2b)/n/n)
mata:sqrt(cross(if2c,if2c)/n/n)

mata:cross(if2c,if2c):/cross(if2b,if2b)