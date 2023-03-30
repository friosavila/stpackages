program drop sim
program sim, eclass
	clear
	local n = `1'
	local t = `2'
	local k = `3'
	local q = `4'  
	local qq=`q'/100
	set obs `n'
	gen id = _n
	gen ai = rchi2(1)
	gen sk = rchi2(1)
	expand `t'
	gen xit =1/(2+`5')*(ai+rchi2(1)+`5'*sk)
	gen uit = rnormal()
	gen yit = ai+xit+(1+xit+`k'*ai)*uit
	bysort id:egen mx=mean(xit)

	
	qui:reghdfe yit xit, abs(fe =id)
	gen yit2=yit -fe
	qrprocess yit xit, q(`qq')
	matrix b=_b[xit]
	qrprocess yit2 xit, q(`qq')
	matrix b=b,_b[xit]
	qrprocess yit xit fe, q(`qq')
	matrix b=b,_b[xit]
	mmqreg yit xit , abs(id) q(`q')
	matrix b=b,_b[qtile:xit]
	
	qrprocess yit xit mx, q(`qq')
	matrix b=b,_b[xit]
	
	qrprocess yit xit ai, q(`qq')
	matrix b=b,_b[xit], `=1+invnormal(`qq')'
	
	matrix colname b = none Canay Mcanay mmqreg wld truobs tru
	ereturn post b
end
	/*local n = `1'
	local t = `2'
	local k = `3'
	local q = `4' */
parallel setclusters 5	
parallel sim, reps(2000): sim 50 10 1.0 90 0.5
sum
two kdensity _b_none || ///
	kdensity _b_Canay || ///
	kdensity _b_Mcanay  || ///
	kdensity _b_mmqreg  || ///
	kdensity _b_wld  || ///
	kdensity _b_truobs  , xline(`=_b_tru[1]')  
	
two kdensity _b_Canay || ///
	kdensity _b_Mcanay  || ///
	kdensity _b_mmqreg  || ///
	kdensity _b_wld  || ///
	kdensity _b_truobs  , xline(`=_b_tru[1]')  	
sum



program drop sim2
program sim2, eclass
	clear
	local n = `1'
	local t = `2'
	local k = `3'
	local q = `4'  
	local qq=`q'/100
	set obs `n'
	gen id = _n
	gen ai = rchi2(1)
	gen sk = rchi2(1)
	expand `t'
	gen xit =1/(2+`5')*(ai+rchi2(1)+`5'*sk)
	gen uit = rnormal()
	gen yit = ai+xit+(1+xit+`k'*ai)*uit
	bysort id:egen mx=mean(xit)

	qreg2 yit xit mx, q(`qq') cluster(id)
	matrix b=_b[xit],_se[xit]
	
	qrprocess yit xit ai, q(`qq') 
	matrix b=b,_b[xit],_se[xit]
	display in w "qq:`q'"
	mmqreg yit xit mx, q(`q') cluster(id)
	matrix b=b,_b[qtile:xit],_se[qtile:xit]
	
	mmqreg yit xit mx, q(`q') robust
	matrix b=b,_b[qtile:xit],_se[qtile:xit]
	
	mmqreg yit xit mx, q(`q') 
	matrix b=b,_b[qtile:xit],_se[qtile:xit]
	
	matrix colname b = b1 se1 b2 se2 b3 se3 b4 se4 b5 se5 
	ereturn post b
end
parallel sim, reps(1000): sim2 50 10 1.0 90 0.5
