clear all
use c:\data\oaxaca, clear
drop if lnwage==.
global y lnwage
global x educ exper tenure female age single
gen one =1
qui:reg  $y $x,  
matrix list e(b)
matrix kk = e(b) 
matrix kk = kk,e(b)*0
gmm ( $y - {b:$x _cons}) ///
	( normal( ({g:$x _cons} - $y + {b:}) /0.15  )- 0.5), ///
	instruments($x) winitial(identity) from(kk) onestep

mata:
y  = st_data(.,"$y")	
x  = st_data(.,"$x one")
xx  =quadcross(x,x)
xy  =quadcross(x,y)
ixx =invsym(xx)
b   =ixx*xy
e   =y-x*b
xb= x*b
n = rows(y)
if1 = (x:*e)*invsym(xx/n)
sqrt(cross(if1,if1)/n:^2)
bw = 0.06
q  =  .0523441
f  = normalden((e:-q)/bw)/bw
g22= invsym(cross(x,f,x)/n)
if2= (normal((e:-q)/bw):-0.5 ):*x*g22 +if1
end

gmm (normal(({q}-res)/0.06)-0.9)

gmm ( normal( ({g:$x _cons} -res) /0.06  )- 0.5), ///
	instruments($x) winitial(identity)  onestep  


             | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
        educ |  -.0114036   .0043013    -2.65   0.008    -.0198341   -.0029731
       exper |  -.0031881    .001393    -2.29   0.022    -.0059184   -.0004579
      tenure |   .0004231   .0014414     0.29   0.769    -.0024019    .0032481
      female |   .0048403   .0185574     0.26   0.794    -.0315316    .0412121
         age |  -.0005748   .0015502    -0.37   0.711    -.0036132    .0024635
      single |   .0212836   .0188818     1.13   0.260    -.0157242    .0582913
       _cons |   .2284115    .057871     3.95   0.000     .1149863    .3418367
------------------------------------------------------------------------------

	