clear all
webuse nlswork, clear
ssc install rif
ssc install mmqreg
** using qreg
forvalues i=2(2)98 {
qui:qreg ln_wage age race msp nev_mar collgrad not_smsa c_city south union ttl_exp tenure , q(`i')
matrix rr=r(table)
matrix bqreg=nullmat(bqreg)\rr["b",....]
matrix llqreg=nullmat(llqreg)\rr["ll",....]
matrix ulqreg=nullmat(ulqreg)\rr["ul",....]
}

gen qtile=2+(_n-1)*2 if 2+(_n-1)*2 <=98
lbsvmat bqreg , name(b) matname
lbsvmat llqreg , name(ll) matname
lbsvmat ulqreg , name(ul) matname

two rarea ll_age ul_age qtile || line b_age qtile, name(m1,replace)


forvalues i=2(2)98 {
qui:rifhdreg ln_wage age race msp nev_mar collgrad not_smsa c_city south union ttl_exp tenure , rif(q(`i')) robust
matrix rr=r(table)
matrix buqreg=nullmat(buqreg)\rr["b","_:"]
matrix lluqreg=nullmat(lluqreg)\rr["ll","_:"]
matrix uluqreg=nullmat(uluqreg)\rr["ul","_:"]
}

lbsvmat buqreg , name(bu) matname
lbsvmat lluqreg , name(llu) matname
lbsvmat uluqreg , name(ulu) matname

two rarea llu_age ulu_age qtile || line bu_age qtile, name(m2,replace)


** this is the equivalent to xtqreg
forvalues i=2(2)98 {
qui:mmqreg ln_wage age race msp nev_mar collgrad not_smsa c_city south union ttl_exp tenure , q(`i')  
matrix rr=r(table)
matrix bmmqreg=nullmat(bmmqreg)\rr["b","qtile:"]
matrix llmmqreg=nullmat(llmmqreg)\rr["ll","qtile:"]
matrix ulmmqreg=nullmat(ulmmqreg)\rr["ul","qtile:"]
}

matrix coleq bmmqreg =""
matrix coleq llmmqreg =""
matrix coleq ulmmqreg =""
lbsvmat bmmqreg , name(bm) matname
lbsvmat llmmqreg , name(llm) matname
lbsvmat ulmmqreg , name(ulm) matname

two rarea llm_age ulm_age qtile || line bm_age qtile, name(m3,replace)

graph combine m1 m2 m3
