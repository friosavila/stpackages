*! v1 An alternative to encode. 
* Uses the same mapping for a list of variables.
*program drop encode2
program encode2
	version 11
	syntax varlist, prefix(name)
	foreach i in `varlist' {
		qui:gen `prefix'`i'=.
		if "`lbvlist'"=="" local lbvlist `prefix'`i'
		local nvlist `nvlist' `prefix'`i'
	}
	mata:encode2("`varlist'","`nvlist'")
	label values `nvlist' `lbvlist'
end

mata:
//mata drop encode2()
void encode2(string scalar vlist, nvlist) {
	string matrix a, b
	real matrix d
	real scalar i
	a=st_sdata(.,vlist)
	b=uniqrows(vec(a))
	
	d=J(rows(a),cols(a),0)
	for(i=1;i<=rows(b);i++) {
		d=d:+i*(a:==b[i])
	}
	st_store(.,tokens(nvlist),d)
	
	st_vlmodify(tokens(nvlist)[1], (1::rows(b)), b)
	
}
end
