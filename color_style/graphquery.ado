*v1 Gets properties from scheme
mata:
	void gquery(string scalar scm, anything){
		string matrix any, sch, ssch
		ssch=cat(scm)
		any=stritrim(strtrim(tokens(anything)))
		real scalar i, fnd, nr
		nr=rows(ssch)
		fnd=1
		i=1
		while(fnd==1){			
			i++
			sch=stritrim(tokens(ssch[i,]))
			if (cols(sch)==3) {
				if (sch[1]==any[1] & sch[2]==any[2]) {		
					fnd=0
					st_local("toreturn",sch[3])
				}
			}
			if (i==nr) {
				fnd=0
			}
		}
	}
end

program graphquery, rclass
	syntax anything, [DEFAULT DEFAULT1(str asis) ]
	qui:findfile "scheme-`c(scheme)'.scheme"
	mata:gquery("`r(fn)'","`anything'") 
	if `"`toreturn'"'=="" & "`default'`default1'"!="" local toreturn `default'`default1'
	display "`anything':" `"`toreturn'"'
	
	return local query   `toreturn'
end