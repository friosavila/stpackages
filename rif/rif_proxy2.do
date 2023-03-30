mata mata clear
mata:
	// the statistic
	// Idea would be to program the Stat of interest here
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
	real matrix agini2(real matrix y,w,real scalar extra) {
		real scalar nn, myw
		real matrix sumw, v2, v1, id
		// Extra order for the extra parameter
		id = order(y,1)
		y=y[id,]
		w=w[id,]:/mean(w)
		nn  = rows(y)
		v1  = y:/mean(y,w):-1
		sumw= runningsum( w )
        v2  = 1:-(sumw:-0.5*w)/nn
		v2 = v2:^(extra-1):-mean(v2:^extra,w)		
        return( -extra*mean(v1:*v2,w) ) 
	}
	
	
	real matrix qts(real matrix y, sw, qts){
		real vector qqt
		real scalar i
		sw=sw:/sw[rows(sw)]*100	
		// iqr
		qqt=J(length(qts),1,1)
		for(i=1;i<=length(qts);i++){
			qqt[i]=sum(sw:<=qts[i])
			qqt[i]=qqt[i]+(sw[qqt[i]]<qts[i])
		} 
		// return
		return(y[qqt])	
	}
	 
	real matrix kden(real matrix y, sw, w){
		real scalar nobs, sd, iqrx, ss, bw, aiqr, bwobs, i
		real matrix ys, kfun, inf
		// Density
		nobs=rows(sw)
		// Possition of qreg
		sd =sqrt(variance(y,w))
		aiqr=qts(y,sw,(25,75))
		iqrx=(aiqr[2]-aiqr[1])/1.3489795
		ss = min(sd\iqrx)
		// bw plugin for gaussian
		bw=1.3643 * (1/(4*pi()))^.1	 * nobs ^-.2*ss
		
		// getting kdenfun
		// small ys
		bwobs=ceil((max(y)-min(y))/bw)*2
		ys  =rangen(min(y),max(y),bwobs)
		kfun=J(bwobs,1,0)
		for( i=1 ; i<=bwobs ; i++){
			kfun[i]=mean(normalden(y,ys[i],bw))
		}
		inf=spline3(ys,kfun)
		kfun=spline3eval(inf,y)
		
		return(kfun)
	}
	 
	real matrix der(real matrix y,w,real scalar extra) {
			real scalar nn, myw, mual
			real matrix sumw, v2, v1, id, aval, fden, fnl
			// Extra order for the extra parameter
			id = order(y,1)
			y=y[id,]
			w=w[id,]:/mean(w)
			nn  = rows(y)
			myw = mean(y,w)
			//v1  = y :- myw
			sumw= runningsum( w )
			//v2  = 1 :- (sumw:-0.5*w)/nn:-0.5
			v2  = runningsum( w :* y)
			//aval= v1:*v2:*-4
			aval  = myw :+ y:*((2*sumw:-w)/sumw[nn]:-1) :-
					(2*v2 :- y:*w)/sumw[nn]
							
			mual= 2 * myw :^ (1-extra)
			fden=kden(y,sumw,w)
			
			fnl =aval:*(fden:^extra):/mual
			//:* aval 
			//:/ mual
			return(mean(fnl,w))
		}
 
	
	// RIF for a given K get IFF
	// This Estimates the IFF for a single group K
 	real matrix rif_k(real matrix y, w, 
					  real scalar knt, eps, extra,
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
			w2=w\ 1/(2^eps)
		
			iff[i]=((*func)(y2,w2,extra):-stat)*n_k*2^eps			
		}
		inf=spline3(ys,iff)
		iff=spline3eval(inf,y) 
		iff=iff:+(stat-mean(iff))
		//[invorder(id),]		
		return(iff)
		
	}
 	// RIF breaks the task into many K groups
	real matrix rif_kk(real matrix y, w, k,  
					   real scalar knt, eps, extra,
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
			iff[|crd|]=rif_k(ys,ws,knt,eps, extra,func)
		}
 		return(iff[invorder(id),])
	}	
	
	/// This the only section that will require changes	
	/// calls on the RIF function
  	void rif_sfunc(string scalar y, w, k,nvar, touse, 
					real scalar knt, eps, extra,
					pointer scalar vv){
		real matrix yy, ww, kk , iff
		yy = st_data(.,y,touse)
		ww = st_data(.,w,touse)
		kk = st_data(.,k,touse)
		iff=rif_kk(yy,ww, kk, knt,eps, extra, vv)
		st_store(.,nvar,touse,iff)
	}
end
 
sysuse oaxaca , clear 
keep if lnwage!=.
gen sw=1
 sort lnwage
** DER needs 0-3
gen new1=.
gen new2=.
gen new3=.
gen new4=.
mata: iff= rif_sfunc("lnwage","sw","sw","new1","sw",10,0,0.5,&der())
mata: iff= rif_sfunc("lnwage","sw","sw","new2","sw",20,0,0.5,&der())
mata: iff= rif_sfunc("lnwage","sw","sw","new3","sw",40,0,0.5,&der())
mata: iff= rif_sfunc("lnwage","sw","sw","new4","sw",80,0,0.5,&der())
scatter new1 new2 new3 new4 lnwage
