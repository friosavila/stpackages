*! v0.1 FRA Prediction tool for Intreg multiple imputation
program intreg_mi,
version 14
syntax anything [if] [in], [reps(int 10) seed(str) replace auto] 
/// verify new variables exist
	confirm new variable `anything'
	if "`replace'"=="" {
		forvalues i = 1/`reps' {
			local vnames `vnames' `anything'`i'
		}
		confirm new variable `vnames'
	}
	
	if "`seed'"!="" set seed `seed'
	
	forvalues i = 1/`reps' {
		capture:drop `anything'`i' 
		capture:gen double `anything'`i'=.
		local v2names `v2names' `anything'`i'
		}
	 

	// Parse command line.
	local cmdlft `=subinstr("`e(cmdline)'","`e(cmd)'","",1)'
	intreg_parser `cmdlft'
 	*tempvar touse
	marksample touse
	mata:int_imp("e(b)", "e(V)", "`r(xlist)' ", "`r(hxlist)' " , "`r(ll)' `r(uu)'", "`touse'", "`anything'", `e(N)', `reps')
	/*foreach i in `vnames' {
		qui:replace `i'=. if !`touse' | `i'>1e50
	}*/
	
	if "`auto'"!="" {
		gen `anything'=.
		tempfile aux
		save `aux'
		mi import wide , imputed(`anything'=`v2names')
	}
end

program intreg_parser, rclass
	syntax anything [if] [in] [aw iw pw fw], [het(str) *]
	gettoken ll 00:anything
	gettoken ul xlist:00
	local hxlist `het'
	return local ll     `ll'
	return local uu     `ul'
	return local xlist  `xlist'
	return local hxlist `hxlist'
end

mata:

real matrix drawnorm(real scalar n, nn, real matrix b,V){
    real matrix vx 
	vx = V * nn/rchi2(1,1,nn)
	return(b:+invnormal(uniform(n,cols(vx)))*cholesky(vx)')
}
 
void int_imp(string scalar b, V,
					xlist, hxlist , uull, 
					touse, stub,
			   real scalar nn, reps) {
			       
    real matrix bb, VV, xlst, hxlst, vuull, one, xb, xg,bts1, bts2, ul1, ul2, yi
	real scalar kv, i, idx, idy,bts, nobs, k, rr
	bb     = st_matrix(b)
	VV     = st_matrix(V)
	vuull  = st_data(., uull , touse )
	nobs   = rows(vuull)
	one    = J(nobs,1,1)
	if (xlist!=" ") xlst   = st_data(. , xlist  , touse ),one
	else            xlst   = one
	if (hxlist!=" ") hxlst  = st_data(. , hxlist , touse ),one
	else            hxlst   = one	   
	kv = cols(xlst) 
 
	idx=J(1,0,.);idy=J(1,0,.)
	for(i=1;i<=cols(bb);i++){
		if (bb[i]!=0) {
		    
		    if (i<=kv) idx=idx,i
 
			if (i> kv) idy=idy,i			

		}
	}
 
	xlst  = xlst[,idx]
	hxlst = hxlst[,(idy:-kv)]
 
	bb=bb[(idx,idy)]
	VV=VV[(idx,idy),(idx,idy)]
 	bts = drawnorm(reps,nn,bb,VV)
	
	// xb
	bts1=bts[,(1..cols(idx))]
	
	// xg
	bts2=bts[,( cols((idx,1))..cols((idx,idy)))]
 
 	// loop
	string scalar stname
	stname=""
	yi=J(nobs,reps,0)
	
	for(k=1;k<=reps;k++){
		 xb =      xlst*bts1[k,]'
		 xg = exp( hxlst*bts2[k,]')
		 ul1 = normal((vuull[,1]:-xb):/xg )
		 ul2 = normal((vuull[,2]:-xb):/xg)
		 _editmissing(ul1, 0)
		 _editmissing(ul2, 1)
		 rr = ul1:+runiform(nobs,1,0,1):*(ul2:-ul1)
		 yi[,k] = xb :+ (xg :* invnormal(rr))
		 stname = stname  +" "+stub+strofreal(k)
	}
	st_store(., tokens(stname), touse, yi)  
}
end
 
