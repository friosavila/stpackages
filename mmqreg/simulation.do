** Lesson 1: you read it well. Your formulas for standard work. 
** Lesson 2: formulas for notstandard need work. How to allow for clusters? and robust?
** Create small simulation to get this.

** Baseline Simulation. First the case 
** Similar to what He does
program drop mmqregsim
program mmqregsim, eclass
** Set N and T
	syntax, N(str) T(str) [k(real 1) u(string) q(int 50) dfadj]
	clear
	set obs `n'
	gen id = _n
	gen a1 = rchi2(3)/3
	expand `t'
	sort id
	gen x1 = 0.5*(a1 + rchi2(3)/3)
	** Data gen
	if "`u'"=="" {
		tempvar ru
		gen `ru'=rnormal()
	}
	else {
		if "`u'"!="" {
			tempvar ru
			gen `ru'=`u'
		}
	}
	gen y = a1 + x1 + (1+x1+`k'*a1)*`ru'
	mmqreg y x1 , abs(id)  q(`q') `dfadj'
	matrix b=_b[qtile:x1]
	matrix b =b, _se[qtile:x1]
	mmqreg y x1 , abs(id) robust q(`q') `dfadj'
	matrix b =b, _se[qtile:x1]
	mmqreg y x1 , abs(id) cluster(id) q(`q') `dfadj'
	matrix b =b, _se[qtile:x1]
	xtqreg y x1 , i(id) q(`=`q'/100')
	matrix b =b, _se[x1]
	matrix coleq b = point simple robust cluster xtqreg
	ereturn post b
end

simulate, reps(500) seed(1):mmqregsim, n(50) t(50) k(0) q(10) dfadj u(rchi2(3)/3-1)

local kk = 1+invnormal(.90)
local kk = 1+(invchi2(3,0.1)/3-1)
*simple_b_c2 robust_b_c3 cluster_b_c4 xtqreg_b_c5

gen m1 = inrange(`kk' ,  point_b_c1-1.96*simple_b_c2  ,point_b_c1+1.96*simple_b_c2 )
gen m2 = inrange(`kk' ,  point_b_c1-1.96*robust_b_c3  ,point_b_c1+1.96*robust_b_c3 )
gen m3 = inrange(`kk' ,  point_b_c1-1.96*cluster_b_c4 ,point_b_c1+1.96*cluster_b_c4 )
gen m4 = inrange(`kk' ,  point_b_c1-1.96*xtqreg_b_c5  ,point_b_c1+1.96*xtqreg_b_c5 )

 sum  
*** as Sample increases, mmqreg is better.
 
 
*program drop mmqregsim2
program mmqregsim2, eclass
** Set N and T
	syntax,NN(str) N(str) T(str) [k(real 1) u(string) q(int 50) dfadj]
	clear
	set obs `nn'
	gen id = runiformint(1,`n')
	gen t  = runiformint(1,`t')
	gen a1 = rchi2(3)/3
	gen a2 = rchi2(3)/3
	gen e2 = rchi2(3)/3
	*expand `t'
	bysort id:replace a1=a1[1]
	bysort t :replace a2=a2[1]
	bysort t :replace e2=e2[1]
	gen x1 = 0.5*(a1 + e2+ 0.1*rchi2(3)/3)
	** Data gen
	if "`u'"=="" {
		tempvar ru
		gen `ru'=rnormal()
	}
	else {
		if "`u'"!="" {
			tempvar ru
			gen `ru'=`u'
		}
	}
	gen y = a1 + x1 + a2+ (1+x1+`k'*a1+a2)*`ru'
	mmqreg y x1 , abs(id)  q(`q') `dfadj'
	matrix b=_b[qtile:x1]
	matrix b =b, _se[qtile:x1]
	mmqreg y x1 , abs(id) robust q(`q') `dfadj'
	matrix b =b, _se[qtile:x1]
	mmqreg y x1 , abs(id) cluster(t) q(`q') `dfadj'
	matrix b =b, _se[qtile:x1]
	xtqreg y x1 , i(id) q(`=`q'/100')
	matrix b =b, _se[x1]
	matrix coleq b = point simple robust cluster xtqreg
	ereturn post b
end 

simulate, reps(500) seed(1):mmqregsim2, nn(2000) n(50) t(50) k(1) q(15) dfadj u(rchi2(3)/3-1)

local kk = 1+invnormal(.90)
local kk = 1+(invchi2(3,0.15)/3-1)
*simple_b_c2 robust_b_c3 cluster_b_c4 xtqreg_b_c5

gen m1 = inrange(`kk' ,  point_b_c1-1.96*simple_b_c2  ,point_b_c1+1.96*simple_b_c2 )
gen m2 = inrange(`kk' ,  point_b_c1-1.96*robust_b_c3  ,point_b_c1+1.96*robust_b_c3 )
gen m3 = inrange(`kk' ,  point_b_c1-1.96*cluster_b_c4 ,point_b_c1+1.96*cluster_b_c4 )
gen m4 = inrange(`kk' ,  point_b_c1-1.96*xtqreg_b_c5  ,point_b_c1+1.96*xtqreg_b_c5 )

local kk = 1+(invchi2(3,0.15)/3-1)
sum point_b_c1
replace point_b_c1=point_b_c1-(r(mean)-`kk')
gen cm1 = inrange(`kk' ,  point_b_c1-1.96*simple_b_c2  ,point_b_c1+1.96*simple_b_c2 )
gen cm2 = inrange(`kk' ,  point_b_c1-1.96*robust_b_c3  ,point_b_c1+1.96*robust_b_c3 )
gen cm3 = inrange(`kk' ,  point_b_c1-1.96*cluster_b_c4 ,point_b_c1+1.96*cluster_b_c4 )
gen cm4 = inrange(`kk' ,  point_b_c1-1.96*xtqreg_b_c5  ,point_b_c1+1.96*xtqreg_b_c5 )

 sum  
*** as Sample increases, mmqreg is better.