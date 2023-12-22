mata
  mata drop powermatrix()
  matrix powermatrix( real matrix  inmat,  real scalar power){
		real matrix em, ev, out
		em=.
		ev=.
		
		eigensystem(inmat,em,ev)
 
		ev=ev:*(abs(ev):>2^-32)
		out=   (em*(diag(ev):^power)*pinv(em))
		 
		return(out)
	}
powermatrix(c,2)
 
end