** SIMULATION STUDY as in BOTAI
capture program drop sim_data
program sim_data
	syntax, [n(int 250) scenario(int 1) reps(int 10)]
		clear
		set obs `n'
		gen x1 = runiform(0,3)
		gen x2 = rbinomial(1,0.5)
		gen p = runiform()
		if `scenario'==1 {
			gen b0=p
			gen b1=((p-.1)^2)
			gen b2=(1+(p-1)^3)
			gen y=b0+b1*x1+b2*x2
			gen yl=floor(y*2)/2
			gen yu=ceil(y*2)/2
		}
		if `scenario'==2 {
			gen b0=-log(1-p)
			gen b1=p^(1/3)
			gen b2=sqrt(p)
			gen y=b0+b1*x1+b2*x2
			gen yl=floor(y)
			gen yu=ceil(y)
			replace yl=7 if yu>7
			replace yu=. if yu>7
		}
		if `scenario'==3 {
			gen b0=5+2*invnormal(p)
			gen b1=2*p+0.5*cos(2*_pi*p)
			gen b2=5*(p-0.5)*(p>0.5)
			gen y=b0+b1*x1+b2*x2
			gen yl=floor(y/2)*2
			gen yu=ceil(y/2)*2
			replace yl=. if yl<0
			replace yu=0 if yl==.
			replace yl=14 if yu>14
			replace yu=. if yu>14
		}
		
		
end

capture program drop sim_proc
program sim_proc, eclass
	syntax, [n(passthru) scenario(passthru) reps(passthru)]
	sim_data, `n' `scenario'
	intreg yl yu c.(x1 i.x2)##c.(x1 i.x2), het(c.(x1 i.x2)##c.(x1 i.x2))
	intreg_mi yimp	, `reps'
	tempfile temp
	gen ymiss=.
	save `temp', replace
	mi import wide, imputed(ymiss=  yimp* )
	qui:sum y,d
	local mn `r(mean)'
	
	qrprocess y x1 x2, q(.25 .50 .75)
	matrix b11=e(b)
	mata:st_matrix("se11",sqrt(diagonal(st_matrix("e(V)")))')
	matrix coleq b11= qreg_q25 qreg_q25 qreg_q25 qreg_q50 qreg_q50 qreg_q50 qreg_q75 qreg_q75 qreg_q75 
	
	matrix coleq se11= qreg_q25se qreg_q25se qreg_q25se qreg_q50se qreg_q50se qreg_q50se qreg_q75se qreg_q75se qreg_q75se 
	matrix colname se11 = `:colnames b11'
	
	
	gen dy = y>`mn'
	logit dy x1 x2
	matrix b12=e(b)
	mata:st_matrix("se12",sqrt(diagonal(st_matrix("e(V)")))')
	
	matrix coleq b12= logit
	matrix coleq se12= logitse
	matrix colname se12 = `:colnames b12'
	
	rifhdreg y x1 x2, rif(gini) scale(100)
	matrix b13=e(b)
	mata:st_matrix("se13",sqrt(diagonal(st_matrix("e(V)")))')
	matrix coleq b13= rifgini
	matrix coleq se13= rifginise
	matrix colname se13 = `:colnames b13'
	
	mi estimate, cmdok post:qrprocess ymiss x1 x2, q(.25 .50 .75)
	matrix b21=e(b)
	mata:st_matrix("se21",sqrt(diagonal(st_matrix("e(V)")))')
	matrix coleq b21= miqreg_q25 miqreg_q25 miqreg_q25 miqreg_q50 miqreg_q50 miqreg_q50 miqreg_q75 miqreg_q75 miqreg_q75 
	matrix coleq se21= miqreg_q25se miqreg_q25se miqreg_q25se ///
						miqreg_q50se miqreg_q50se miqreg_q50se /// 
						miqreg_q75se miqreg_q75se miqreg_q75se 
	matrix colname se21 = `:colnames b21'
	
	
	mi passive:gen dyy=ymiss>`mn' if ymiss!=.
	mi estimate, cmdok post noisily:logit dyy x1 x2
	matrix b22=e(b)
	mata:st_matrix("se22",sqrt(diagonal(st_matrix("e(V)")))')
	
	matrix coleq b22= milogit
	matrix coleq se22= milogitse
	matrix colname se22 = `:colnames b22'
	
	mi estimate, cmdok post:rifhdreg ymiss x1 x2, rif(gini) scale(100)
	matrix b23=e(b)
	mata:st_matrix("se23",sqrt(diagonal(st_matrix("e(V)")))')
	matrix coleq b23= mirifgini
	matrix coleq se23= mirifginise
	matrix colname se23 = `:colnames b23'
	matrix b = b11,se11,b12,se12,b13,se13,b21,se21,b22,se22,b23,se23
	ereturn post b
end
ll

parallel setclusters 8, force

foreach i in 250 500 1000 {
	foreach j in 1 2 3 {
		parallel sim, reps(5000) programs(sim_data):sim_proc, n(`i') scenario(`j')
		save sim_n`i'_s`j', replace
	}
}
