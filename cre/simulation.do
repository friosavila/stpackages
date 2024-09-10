program drop sim
program sim, eclass
clear
set obs 250
gen id  = _n
gen c_i = runiform(-.5,.5)
expand 10
gen x1_i = 0.8*rnormal()+invnormal(c_i+.5)
gen x2_i = 0.8*rnormal()-invnormal(c_i+.5)
gen expy = exp(x1_i + x2_i + c_i)
gen ypois=rpoisson(expy)

poisson ypois x1 x2 c
matrix b1=e(b)
poisson ypois x1 x2 
matrix b2=e(b)
ppmlhdfe ypois x1 x2 , abs(id)
matrix b3=e(b)
cre, keep abs(id1 id2)  : poisson ypois x1 x2 , robust
matrix b4=e(b)

matrix coleq b1 = true
matrix coleq b2 = false
matrix coleq b3 = ppmlhdfe
matrix coleq b4 = cre
matrix b = b1,b2,b3,b4

ereturn post b

end

simulate, reps(100): sim

program drop sim
program sim, eclass
clear
set obs 250
gen id  = _n
gen c_i = runiform(-.5,.5)
expand 10
gen x1_i = 0.8*rnormal()+invnormal(c_i+.5)
gen x2_i = 0.8*rnormal()-invnormal(c_i+.5)

gen y = 0.5*x1_i + 0.5*x2_i + 0.5*c_i + rnormal()
gen yd = y>0

xtset id
logit yd x1 x2 c
margins, dydx(x1 x2)
matrix b1 = r(b)
logit yd x1 x2 
margins, dydx(x1 x2)
matrix b2 = r(b)

xtlogit yd x1 x2, fe
margins, dydx(x1 x2)
matrix b3 = r(b)

cre, abs(id) keep:logit yd x1 x2 
margins, dydx(x1 x2)
matrix b4 = r(b)

matrix coleq b1 = true
matrix coleq b2 = false
matrix coleq b3 = xtlogit
matrix coleq b4 = cre
matrix b = b1,b2,b3,b4

ereturn post b

end
parallel initialize 8
parallel sim , reps(1000): sim


two kdensity true_b_x1_i || kdensity false_b_x1_i || kdensity  xtlogit_b_x1_i || kdensity cre_b_x1_i

** MWAY

