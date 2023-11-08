frause  oaxaca, clear
gen rr=runiform()<.5
gen cns = 1
drop if lnwage==.
gen id = 
mata:
   y = st_data(.,"lnwage")
   x = st_data(.,"educ exper tenure female cns")
   r = st_data(.,"rr")
   id= range(1,rows(y),1)
   et= y:-x*invsym(cross(x,x))*cross(x,y)
   ifft = invsym(cross(x,x)) * (x:*et)'
   bt=invsym(cross(x,x)) * (x*y)
   b1=invsym(cross(select(x,r),select(x,r)))*cross(select(x,r),select(y,r))
   b2=invsym(cross(select(x,1:-r),select(x,1:-r)))*cross(select(x,1:-r),select(y,1:-r))
   e1= select(y,r):-select(x,r)*invsym(cross(select(x,r),select(x,r)))*cross(select(x,r),select(y,r))
   e2= select(y,1:-r):-select(x,1:-r)*invsym(cross(select(x,1:-r),select(x,1:-r)))*cross(select(x,1:-r),select(y,1:-r))
   iff1 = invsym(cross(select(x,r),select(x,r))) * (select(x,r):*e1)'
   iff2 = invsym(cross(select(x,1:-r),select(x,1:-r))) * (select(x,1:-r):*e2)'
   iff1=iff1'
   iff2=iff2'
   iffx1=iffx2=J(1434,5,.)
   iffx1[select(id,r),]=iff1
   iffx2[select(id,1:-r),]=iff2
   iffx1= editmissing(iffx1,0):*(rows(iffx1):/colnonmissing(iffx1))
   iffx2= editmissing(iffx2,0):*(rows(iffx2):/colnonmissing(iffx2))
   mean(r)
   iifx=2*ifft:-(iffx1*mean(r):+iffx2*(1:-mean(r)))
   
end