clear
set obs 2000
gen x=_n/_N*5
gen y = sin(x)+cos(2*x)
scatter y x

gen flag=0
replace flag=1 if floor(_n/_N*25)==_n/_N*25
replace flag=1 if _n==1 | _n==_N

scatter y x if flag==1 


mata
y=st_data(.,"y","flag")
yf=st_data(.,"y")
x=st_data(.,"x")
xs=st_data(.,"x","flag")
inf=spline3(xs,y)
 
yy=spline3eval(inf,x)
mata:spline3eval(inf,x),x,yf
end

getmata yy
fgscatter (yy-y) y


*****
sysuse oaxaca, clear
drop if lnwage==.
sort lnwage

mata
// s1 : load data
y = st_data(.,"lnwage")
w = st_data(.,"wt")
w=w:/mean(w)
// s2: get points of interest
ys=rangen(min(y),max(y),100)
// s3: Estimate Statistic

lvar=mean( (y:-mean(y,w)):^2:*(y:<=mean(y,w)) , w )
uvar=mean( (y:-mean(y,w)):^2:*(y:>=mean(y,w)) , w )
// s4: loop for Statistics
iff1=J(100,1,0)
iff2=J(100,1,0)
for(i=1;i<=100;i++){
	y2=y\ys[i]
	w2=w\ 1/(2^10)
	lvars=mean( (y2:-mean(y2,w2)):^2:*(y2:<=mean(y2,w2)) , w2)
	uvars=mean( (y2:-mean(y2,w2)):^2:*(y2:>=mean(y2,w2)) , w2)
	iff1[i]=(lvars:-lvar)*1434*2^10
	iff2[i]=(uvars:-uvar)*1434*2^10
}
inf1=spline3(ys,iff1)
inf2=spline3(ys,iff2)
lvh=spline3eval(inf1,y) 
uvh=spline3eval(inf2,y) 
end

mata mata clear
mata:
	// the statistic
	real matrix lvar(real matrix y,w, real scalar extra) {
		real scalar myw
		real matrix iyw
		myw=mean(y,w)
		iyw=(y:-myw):^2:*(y:<=myw)
		return( mean( iyw , w ) )
	}
	real matrix hvar(real matrix y,w, real scalar extra) {
		return( mean( (y:-mean(y,w)):^2:*(y:>=mean(y,w)) , w ) )
	}	
	real matrix var(real matrix y,w, real scalar extra) {
		return( mean( (y:-mean(y,w)):^2 , w ) )
	}
	real matrix agini(real matrix y,w,real scalar extra) {
		real scalar nn, myw
		real matrix sumw, v2, id
		id = order(y,1)
		y=y[id,]
		w=w[id,]
		nn  = rows(y)
        sumw= runningsum( w )
        v2  = (sumw:-0.5*w):/nn
		myw=mean(y,w)
        return( 2*mean((y:-myw):*(v2:-0.5),w):/myw ) 
	}
	// RIF for a given K get IFF
 	real matrix rif_k(real matrix y, w, 
					  real scalar knt, extra,
					  pointer scalar func){
		real matrix id, ys, iff, y2, w2, inf
		real scalar stat,i , n_k
		//id=order(y,1)
		//y=y[id,.]
		w   = w:/mean(w)
		
		n_k = rows(y)
		  
		ys=rangen(min(y),max(y),knt)
		stat = (*func)(y,w,extra)
		iff=J(knt,1,0)
		for(i=1;i<=knt;i++){
			y2=y\ys[i]
			w2=w\ 1/(2^10)
 
			iff[i]=((*func)(y2,w2,extra):-stat)*n_k*2^10			
		}
		inf=spline3(ys,iff)
		iff=spline3eval(inf,y) :+stat
		//[invorder(id),]
		return(iff)
	}
 	// RIF breaks K
	real matrix rif_kk(real matrix y, w, k,  
					   real scalar knt, extra,
					   pointer scalar func){
		real matrix id, info, crd, ys, ws, iff
		real scalar n_info, i 
		id = order((k,y),(1,2))
		y  = y[id,.]
		k  = k[id,.]
		w  = w[id,.]:/mean(w)		
		info   = panelsetup(k, 1)
		n_info = rows(info)

		iff=J(rows(y),1,0)
		for(i=1;i<=n_info;i++){
 			ys = panelsubmatrix(y,i,info) 
 			ws = panelsubmatrix(w,i,info) 
 			crd=info[i,]',(1\1)
			iff[|crd|]=rif_k(ys,ws,knt,extra,func)
		}
 		return(iff[invorder(id),])
	}	
	
/// This the only section that will require changes	
 
 	void rif_sfunc(string scalar y, w, k,nvar, touse, 
					real scalar knt, extra,
					pointer scalar vv){
		real matrix yy, ww, kk , iff
		yy = st_data(.,y,touse)
		ww = st_data(.,w,touse)
		kk = st_data(.,k,touse)
		iff=rif_kk(yy,ww, kk, knt,extra, vv)
		st_store(.,nvar,touse,iff)
	}
end
mata: iff= rif_sfunc("pind2_d","perwt","sex","new1","t",100,1,&lvar())

gen new1=.
gen new2=.
gen new3=.
mata: iff= rif_sfunc("lnwage","wt","mstat","new1","t",100,&lvar())
mata: iff= rif_sfunc("lnwage","wt","mstat","new2","t",50,&lvar())
mata: iff= rif_sfunc("lnwage","wt","mstat","new3","t",25,1,&lvar())
mata: iff= rif_sfunc("lnwage","wt","mstat","new3","t",25,1,&uvar())




clear
set obs 1000000
gen y=rnormal()
gen t=1
gen new1=.
gen new2=.
gen new3=.
timer on 1
mata: iff= rif_sfunc("y","t","t","new1","t",100,1,&lvar())
timer off 1
timer on 2
mata: iff= rif_sfunc("y","t","t","new1","t",100,1,&hvar())
timer off 2

mata: iff= rif_sfunc("y","t","t","new2","t",50,1,&lvar())
mata: iff= rif_sfunc("y","t","t","new3","t",25,1,&lvar())




sort y
mata
// s1 : load data
y = st_data(.,"y")
// s2: get points of interest
ys=rangen(min(y),max(y),100)
// s3: Estimate Statistic
lvar=mean( (y:-mean(y)):^2:*(y:<=mean(y)) )
uvar=mean( (y:-mean(y)):^2:*(y:>=mean(y)) )
// s4: loop for Statistics
iff1=J(100,1,0)
iff2=J(100,1,0)
for(i=1;i<=100;i++){
	y2=y\ys[i]
	lvars=mean( (y2:-mean(y2)):^2:*(y2:<=mean(y2)) )
	uvars=mean( (y2:-mean(y2)):^2:*(y2:>=mean(y2)) )
	iff1[i]=(lvars:-lvar)*100000
	iff2[i]=(uvars:-uvar)*100000
}
inf1=spline3(ys,iff1)
inf2=spline3(ys,iff2)
lvh=spline3eval(inf1,y) 
uvh=spline3eval(inf2,y) 
end
program drop hvx
program hvx, eclass
	drop2 new
	sum y, meanonly
	gen new=(y-r(mean))^2*(y<=r(mean))
	sum new, meanonly
	matrix b= r(mean)
	ereturn post b
end
bootstrap : hvx
