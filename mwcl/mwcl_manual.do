sysuse auto, clear
foreach i in price mpg headroom trunk weight length turn displacement gear_ratio {
	center `i', inplace s
}
gen r1 = runiformint(1,5)
gen r2 = runiformint(1,5)
gen one=1
sort r1 r2
egen gr1=group(r1 r2)
mata
	y  = st_data(.,"price")
	x  = st_data(.,"mpg headroom one")
	xx = cross(x,x)
	ixx= invsym(xx)
	xy = cross(x,y)
	b  = ixx*xy
	e  = y:-x*b
	vcv0= cross(e,e)/74 * ixx
	diagonal(vcv0):^.5
end	
** robust
eregress price mpg headroom, vce(robust)	
mata
	r1 = st_data(.,"r1")
	i1 = I(74)
	for(i=1;i<=74;i++){
		for(j=1;j<=74;j++){
			i1[i,j]=r1[i]==r1[j]
		}
	}
	ee=e*e'
	vcv1=ixx * (x'*(ee:*I(74))*x) * ixx 
	diagonal(vcv1):^.5

end	

eregress price mpg headroom, vce(robust)
gmm (price - {b0:mpg headroom _cons}), instruments(mpg headroom)	
mata
	ee=e*e'
	vcv1=ixx * (x'*(ee:*I(74))*x) * ixx 
	vcv1b=ixx * cross(x,e:^2,x) * ixx 
	diagonal(vcv1):^.5
	diagonal(vcv1b):^.5
end	

gmm (price - {b0:mpg headroom _cons}), instruments(mpg headroom) vce(cluster r1)	

mata
	r1 = st_data(.,"r1")
	i1 = I(74)
	for(i=1;i<=74;i++){
		for(j=1;j<=74;j++){
			i1[i,j]=r1[i]==r1[j]
		}
	}
	ee=e*e'
	vcv2=ixx * (x'*(ee:*i1)*x) * ixx 
 	diagonal(vcv2):^.5
end	

gmm (price - {b0:mpg headroom _cons}), instruments(mpg headroom) vce(cluster r2)	
 
mata
	r2 = st_data(.,"r2")
	i2 = I(74)
	for(i=1;i<=74;i++){
		for(j=1;j<=74;j++){
			i2[i,j]=r2[i]==r2[j]
		}
	}
	ee=e*e'
	vcv3=ixx * (x'*(ee:*i2)*x) * ixx 
 	diagonal(vcv3):^.5
end	

mata
	gr1 = st_data(.,"gr1")
	i4 = I(74)
	for(i=1;i<=74;i++){
		for(j=1;j<=74;j++){
			i4[i,j]=gr1[i]==gr1[j]
		}
	}
	vcv4=ixx * (x'*(ee:*i4)*x) * ixx 
 	diagonal(vcv4):^.5
end

mata
	vcv2:+vcv3:-vcv4
end
 
mata
	i3=(i1:+i2):>0
	vcv5=ixx * (x'*(ee:*i3)*x) * ixx 
 	diagonal(vcv5):^.5
end

mata
 	diagonal(vcv2:+vcv3:-vcv4):^.5
 	diagonal(vcv5):^.5
end


 