frause oaxaca, clear
drop if lnwage==.

mata
y = st_data(.,"lnwage"); n=rows(y)
x = st_data(.,"educ exper tenure female"),J(n,1,1); k =cols(x)

//beta 

xx = cross(x,x); ixx = invsym(xx); xy = cross(x,y)
beta = ixx * xy

// errors

e = y:-x*beta
end

** This is what you do with asymptotic theory:
** First lets get the IF
mata 
 iff = (x:*e)*ixx*n
 vcv = cross(iff,iff)/n^2
 //sd 
 sd = sqrt(diagonal(vcv))
end
 * you can compare this with  Reg, robust
mata:sd

// Now the **Wboot done in CSDID:

mata
// need a place to store ALL betas
beta = J(999,k,.)
for(i=1;i<=999;i++){
    beta[i,]=mean(iff:*rnormal(n,k,0,1))
}
// This is the Equivalent to the bootstrapped coefficients
// Also i could have used a different noise "v". But normal is just easiest to program

// Get SE using the Interquartile difference
iqrs=J(1,k,.)
for(i=1;i<=k;i++){
    ///999 is the Nrows in Beta
    aux=sort(beta,i)
    q25=ceil((999+1)*.25)
	q75=ceil((999+1)*.75)
    // Thse are the SE reported in CSDID when wboot is used
    iqrs[,i]=(aux[q75,i]-aux[q25,i]):/(invnormal(.75)-invnormal(.25) )
}

// Get the t-stats based on Beta and IQRS

tstat = beta:/iqrs

// This is important. To get the Uniform CI, you need to first the the distribution of the "largest absolute tstat". 
// the Absolute part makes this symetric

largest_tstat = rowmax(abs(tstat))

// Finally the Critical is based by looking at the t-stat in this vector that is in the 95th possition
_sort(largest_tstat ,1)
largest_tstat[ceil((999+1)*.95)]
// CIs are constructed using this largest tstat
end


