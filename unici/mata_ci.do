/*
mata
real matrix drawnorm(real scalar n, real matrix b,V){
     return(b:+invnormal(uniform(n,cols(V)))*cholesky(V)')
}
end
*/
mata
b=st_matrix("b")
V=st_matrix("V")
b2=b[,3..9]
V2=V[3..9,3..9]
end

mata
x=drawnorm(1000,b2:*0,V2):/(diagonal(V2)':^.5)
x=rowmax(abs(x))
_sort(x,1)
x[950,1]
end
 