** create panel
clear
set obs 10000
gen ivar = _n
gen x1 = rnormal()
gen x2 = runiformint(1,3)

expand 10
gen xsort=runiform()
sort xsort
gen x3 = rnormal()
gen x4 = runiformint(1,3)
 
global xvarcomb x1 i.x2 x3 i.x4 c.x1#i.x4 
	ms_fvstrip $xvarcomb , expand dropomit
	global vlist `r(varlist)'
local vlist `r(varlist)'
mata:
 xvar= st_data(.,"ivar `vlist'")
 ord = order(xvar[,1],1)
 xvar=xvar[ord,]
 xvarlist = tokens("`vlist'")
 k = cols(xvar) 
 for(i=2;i<=k;i++){

 	xord = order(xvar[,(1,i)],(1,2))
 	xvar[,i]=xvar[xord,i]
 }
 info = panelsetup(xvar,1)
 newx = xvar[info[,2],]:-xvar[info[,1],]
 newx = colsum(newx):>0
 toreturn = invtokens(select(xvarlist,newx[,2..k]))
 
end	