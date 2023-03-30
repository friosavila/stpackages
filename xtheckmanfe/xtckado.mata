** xtheckmanfe wage age tenure, select(working = age market)
** option 1 eq
clear all
use "C:\data\wagework.dta", clear
keep if personid<200
ren market barket
bysort personid:egen mn_age   =mean(age)
bysort personid:egen mn_tenure=mean(tenure )
bysort personid:egen mn_market=mean(barket)
gen tmp1=.
forvalues i = 2013/2016 {
	tempvar x
	probit working age tenure barket mn_* if year==`i'
	capture drop `x'
	predict `x', score
	replace tmp1=`x' if year==`i'
}
** opm eq
probit working i.year#c.(age tenure barket mn_*) i.year, 
mata:hh=st_matrix("e(V)")
predict tmp2, score
predict xb, xb

reg wage age tenure mn_age mn_tenure mn_market i.year i.year#c.tmp2
mata:gamma=st_matrix("e(b)")
mata:gamma=gamma[1,13-3..13]

mata: st_view(z2 =.,.,"i.year#c.(age tenure barket mn_*) i.year")
mata: st_view(xb =.,.,"xb")
mata: st_view(lmb=.,.,"tmp2")
mata: st_view(wrk=.,.,"working")
mata: st_view(yr=.,.,"ibn.year")
mata: st_view(id=.,.,"personid")

mata:aux=wrk:*yr[,1]:*(-lmb):*(lmb+xb)*gamma[1]
mata:gx=z2:*aux
mata:aux=wrk:*yr[,2]:*(-lmb):*(lmb+xb)*gamma[2]
mata:gx=gx,z2:*aux
mata:aux=wrk:*yr[,3]:*(-lmb):*(lmb+xb)*gamma[3]
mata:gx=gx,z2:*aux
mata:aux=wrk:*yr[,4]:*(-lmb):*(lmb+xb)*gamma[4]
mata:gx=gx,z2:*aux


mata:info = panelsetup(id, 1)
mata: nc   = rows(info)

mata:aux=z2:*yr[,1]:*lmb
mata:qx=aux

mata:
        for(i=1; i<=nc; i++) {
            xi = panelsubmatrix(aux,i,info)
			aux[|info[i,1],1\info[i,2],cols(xi)|]=xi[1,]#J(rows(xi),1,1)
        }
end
mata:aux=z2:*yr[,2]:*lmb
mata:
        for(i=1; i<=nc; i++) {
            xi = panelsubmatrix(aux,i,info)
			aux[|info[i,1],1\info[i,2],cols(xi)|]=xi[2,]#J(rows(xi),1,1)
        }
end
mata:qx=qx,aux
mata:aux=z2:*yr[,3]:*lmb
mata:
        for(i=1; i<=nc; i++) {
            xi = panelsubmatrix(aux,i,info)
			aux[|info[i,1],1\info[i,2],cols(xi)|]=xi[3,]#J(rows(xi),1,1)
        }
end
mata:qx=qx,aux
mata:aux=z2:*yr[,4]:*lmb
mata:
        for(i=1; i<=nc; i++) {
            xi = panelsubmatrix(aux,i,info)
			aux[|info[i,1],1\info[i,2],cols(xi)|]=xi[4,]#J(rows(xi),1,1)
        }
end
mata:qx=qx,aux

** sample working
