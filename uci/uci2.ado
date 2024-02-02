** Program for CUI 
program uci, rclass
	syntax, [reps(int 999) level(real 95) rseed(str) bmatrix(name) vmatrix(name)]
	tempname b V
	if "`rseed'"!="" set seed `rseed'
	** step 1 Gather VCV and B
	if "`bmatrix'`vmatrix'"=="" {
		matrix `b'=e(b)
		matrix `V'=e(V)
	}
	else {
		matrix `b'=`bmatrix'
		matrix `V'=`vmatrix'
	}
	local level = `level'/100
	** Step 2 pass to mata
/*	mata: v=st_matrix("V")
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
	mata mata drop P b eval evec*/
	
	mata:uci_creator(`reps',`level',"`b'","`V'")
	display "Uniform Confidence Intervals based on Simulation"

	display "Repetitions:`reps'"
	display "Level:`level'"
	display "new T:`nt'"
	
	_coef_table, cimatrix(myci_) cititle(Uniform CI)
	
	addx local reps = `reps'
	addx local level = `level'
	addx local newt = `nt'
	addx local rseed  `rseed'
end

program addx, rclass
	return add
	return `0'
end 

mata
	// creates the UCI intervals
 	void uci_creator(real scalar n, level, string scalar ssb,sV){
		real matrix evec, eval, P, se, V,b
		V = st_matrix(sV)
		b = st_matrix(ssb)
		symeigensystem(V,evec=., eval=.)
		eval=eval:*(eval:>0)
		P= evec*diag(eval:^.5)
		se=diagonal(V)':^.5
		// Stores All values for matrices
		real matrix sb
		// Simulates coefficients under normality. Could we use something else?
		// Only via Inverse transformation
		sb=rnormal(n,cols(V),0,1)*P'
		sb=rowmax(abs(sb:/se))
		//sb
		// only 1 time
		_sort(sb,1)
		// Critical
		sb=sb[ceil(level*n)]
		st_s
		sb = b':-sb:*se',b':+sb:*se'
		
		st_matrix("myci_",sb')
	}
	
	
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