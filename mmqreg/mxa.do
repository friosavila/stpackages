frause oaxaca, clear
drop if lnwage == .
gen r = runiform()<.5
capture program drop bot
program bot, eclass

reg lnwage educ exper tenure female age 
matrix b=e(b)
reg lnwage educ exper tenure female age if r==0
matrix b1=e(b)
reg lnwage educ exper tenure female age if r==1
matrix b2=e(b)
matrix b1 = 2*b - 0.5*(b1+b2)
matrix coleq b = org
matrix coleq b1 = jkc
matrix b=b,b1
ereturn post b
end

bootstrap, reps(100):bot

gmm (lnwage-{betaf:educ exper tenure female age _cons}) ///
    ((lnwage-{beta0:educ exper tenure female age _cons})*(r)) ///
    ((lnwage-{beta1:educ exper tenure female age _cons})*(!r)), ///
    instruments(educ exper tenure female age ) winitial(identity)

    gen cns = 1
mata
   r=st_data(.,"r")
   y =st_data(.,"lnwage")
   x =st_data(.,"educ exper tenure female age cns")
   id=range(1,1434,1)
   y0=select(y,!r)
   y1=select(y,r)
   x0=select(x,!r)
   x1=select(x,r)
   b= invsym(cross(x,x))*cross(x,y)
   b0=invsym(cross(x0,x0))*cross(x0,y0)
   b1=invsym(cross(x1,x1))*cross(x1,y1)
   e = y:-x*b
   e0 = y0:-x0*b0
   e1 = y1:-x1*b1
   iff =rows(id)*(invsym(cross(x,x))*(x:*e)')'
   iff0=sum(!r)*(invsym(cross(x0,x0))*(x0:*e0)')'
   iff1=sum(r)*(invsym(cross(x1,x1))*(x1:*e1)')'   
   iff = iff:+b'
   iff0 = iff0:+b0'
   iff1 = iff1:+b1'
   id0 = select(id,!r)
   id1 = select(id,r)
end    

getmata iff*=iff
gen i=_n
getmata iff1*=iff1, id(i=id1)
getmata iff0*=iff0, id(i=id0)

csdid_rif iff*
lincom 2*iff1-0.5*(iff11+iff01)

mata:
    ift = 2*iff
    p = mean(r)
    ift[id0,] = iff0
    ift[id1,] = iff1
    ift = 2*iff-ift
end

