*! v1.0 April 2020 Fernando Rios-Avila
* This makes e(V) symetric
program f_symev, eclass
	tempname V
	mata:st_matrix("`V'",makesymmetric(st_matrix("r(V)")))
	ereturn repost V=`V'
end
