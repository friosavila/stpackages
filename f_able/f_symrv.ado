* v1 makes r matrix symetric
program f_symrv, rclass
	local cnm:colname r(V)
	local ceq:coleq r(V)
	tempname V
	mata:st_matrix("`V'",makesymmetric(st_matrix("r(V)")))
	matrix roweq   `V'= `ceq'
	matrix rowname `V'= `cnm'
	matrix coleq   `V'= `ceq' 
	matrix colname `V'= `cnm'
	return add
	return matrix V=`V'
end
