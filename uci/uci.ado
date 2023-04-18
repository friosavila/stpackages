** Program for CUI 
program uci, rclass
	syntax, [reps(int 999) level(real 95) rseed(str) bmatrix(name) vmatrix(name)]
	if "`rseed'"!="" set seed `rseed'
	** step 1 Gather VCV and B
	if "`bmatrix'`vmatrix'"=="" {
		matrix b=e(b)
		matrix V=e(V)
	}
	else {
		matrix b=`bmatrix'
		matrix V=`vmatrix'
	}
	** Step 2 pass to mata
	mata: v=st_matrix("V")
	mata: se=diagonal(v)':^.5
	mata: n = `reps'
	mata: level = `level'/100
	mata: symeigensystem(v,evec=., eval=.)
	mata: eval=eval:*(eval:>0)
	mata: P= evec*diag(eval:^.5)
	mata: sb=rnormal(n,cols(v),0,1)*P'
	mata: t=rowmax(abs(sb:/se))
	mata: _sort(t,1)
	mata: nt=t[ceil(level*n)]
	mata: b=st_matrix("b")';se=se'
	mata: tb=b,se,b:/se,b:-nt:*se,b:+nt:*se
	mata: rwn=st_matrixcolstripe("b")
	mata: st_matrix("rtable2",tb)
	mata: st_matrixcolstripe("rtable2", (("","","","","")',("b","se","t","ll","lu")'))
	mata: st_matrixrowstripe("rtable2", rwn)
	mata: st_local("nt",strofreal(nt))
	mata mata drop v se n level sb t nt tb rwn
	mata mata drop P b eval evec
	display "Uniform Confidence Intervals based on Simulation"
	matrix list rtable2
	display "Repetitions:`reps'"
	display "Level:`level'"
	display "new T:`nt'"
	return matrix rtable2 = rtable2
	return local reps = `reps'
	return local level = `level'
	return local newt = `nt'
	return local rseed  `rseed'
end
/*
mata

real matrix drawnorm(scalar n, real matrix vcv ,| real matrix b ){
	real matrix P, evec, eval
	if (rank(vcv)==cols(vcv)) P=cholesky(vcv)
	else  {
		symeigensystem(vcv,evec, eval)
		eval=eval:*(eval:>0)
		P= evec*diag(eval:^.5)
	}
	P = P'
	return(rnormal(n,cols(vcv),0,1)*P)
}
end