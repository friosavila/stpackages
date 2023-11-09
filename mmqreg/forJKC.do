frause  oaxaca, clear
gen rr=runiform()<.5
gen cns = 1
drop if lnwage==.
gen id = _n
mata:
   y = st_data(.,"lnwage")
   x = st_data(.,"educ exper tenure female cns")
   r = st_data(.,"rr")
   id= range(1,rows(y),1)
   et= y:-x*invsym(cross(x,x))*cross(x,y)
   ifft = invsym(cross(x,x)) * (x:*et)'
   ifft=ifft'
   bt=invsym(cross(x,x)) * cross(x,y)
   b1=invsym(cross(select(x,r),select(x,r)))*cross(select(x,r),select(y,r))
   b2=invsym(cross(select(x,1:-r),select(x,1:-r)))*cross(select(x,1:-r),select(y,1:-r))
   e1= select(y,r):-select(x,r)*invsym(cross(select(x,r),select(x,r)))*cross(select(x,r),select(y,r))
   e2= select(y,1:-r):-select(x,1:-r)*invsym(cross(select(x,1:-r),select(x,1:-r)))*cross(select(x,1:-r),select(y,1:-r))
   iff1 = invsym(cross(select(x,r),select(x,r))) * (select(x,r):*e1)'
   iff2 = invsym(cross(select(x,1:-r),select(x,1:-r))) * (select(x,1:-r):*e2)'
   iff1=iff1'
   iff2=iff2'
   ixxx=iffx1=iffx2=J(1434,5,.)
   iffx1[select(id,r),]=iff1
   iffx2[select(id,1:-r),]=iff2
   ixxx[select(id,r),]=iff1
   ixxx[select(id,!r),]=iff2
   iffx1= editmissing(iffx1,0):*(rows(iffx1):/colnonmissing(iffx1))
   iffx2= editmissing(iffx2,0):*(rows(iffx2):/colnonmissing(iffx2))
   mean(r)
   iifx=2*ifft:-(iffx1*mean(r):+iffx2*(1:-mean(r)))
   iifxx=2*ifft:-ixxx
end

mata:sqrt(cross(ifft,ifft))
mata:sqrt(cross(iifx,iifx))

program simx, eclass
capture drop rn
gen rn = runiform()<.5
reg lnwage educ exper tenure female 
matrix b1=e(b)
reg lnwage educ exper tenure female if rn==0
matrix b2=e(b)
reg lnwage educ exper tenure female if rn==1
matrix b3=e(b)
matrix bb=2*b1-0.5*(b2+b3)
matrix coleq b1 = bo
matrix coleq bb = bc
matrix b=b1,bb
ereturn post b
end

bootstrap, rep(1000): simx