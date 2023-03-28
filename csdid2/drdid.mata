mata
// IPT
void  fipt(transmorphic M, 
					  real scalar todo,
					  real rowvector b, 
					  real scalar lnf,
					  real matrix gg,
					  real matrix hh){
	
	real colvector y1, xb
	y1 = moptimize_util_depvar(M,1)
	
	xb = moptimize_util_xb(M,b,1)
	
	lnf = moptimize_util_sum(M,  y1:*xb :- (y1:==0):*exp(xb) )
	if (todo>=1){
		gg = moptimize_util_vecsum(M, 1, y1:-(y1:==0):*exp(xb) , lnf)	
 		if (todo==2){
			hh = moptimize_util_matsum(M, 1,1, -(y1:==0):*exp(xb) , lnf)		
		}
	}
}
// logit
void  flogit(transmorphic M, 
			  real scalar todo,
			  real rowvector b, 
			  real scalar lnf,
			  real matrix gg,
			  real matrix hh){
	real colvector y1, pxb, xb, exb
	
	y1   = moptimize_util_depvar(M,1)
	xb   = moptimize_util_xb(M,b,1)
	pxb  = logistic(xb)
	exb  = exp(xb)
	
	lnf = moptimize_util_sum(M,  y1:*xb :- ln(exb:+1))
	if (todo>=1){
		gg = moptimize_util_vecsum(M, 1, y1:-exb:/(exb:+1) , lnf)	
 		if (todo==2){
			hh = moptimize_util_matsum(M, 1,1, -exb:/(exb:+1):^2 , lnf)		
		}
	}
}


class drdid {
	// For later.
	real scalar data_type
	real scalar method_type
	
	// Data needed
	real matrix yvar
	
	real matrix xvar
	real matrix wvar
	real matrix id
	real matrix oid
	real matrix trt
	real matrix wtrt
	real matrix tmt
	real matrix tmt_trt
	
	// also minn. if minn=1 -> reg regardless
	//real scalar minn
	
	// data created
	real matrix xb
	real matrix yhat
	real matrix b
	//real matrix ixx
	real matrix psv
	real scalar nn
	real scalar conv
	real scalar kx 
	real scalar minn 
	real scalar rolljw	
	real scalar err
	real matrix select4()
	// regressions
	///void    	fipt()
	void 		ipt()
	///void    	flogit()
	void 		ilogit()
	void 		ols()
	void		ols_ipw_rc()
	void		ols_ipt_rc()
	// out
	real matrix rif
	
	// Other functions
	void  		reg_panel()
	void  		drimp_panel()
	void  		stdipw_panel()
	void 		dripw_panel() 
	
	void  		reg_rc()
	void  		reg2_rc()
	void  		reg3_rc()
	void  		drimp_rc()
	void  		stdipw_rc()
	void 		dripw_rc()
	
	void		makeid()
	//void		makeid2()
	// setting up  data
	void 	    msetup_panel()
	void 	    msetup_panel2()
	void 	    msetup_rc()
	// this one "fixes stuff"
	// void 	    setup()
	// void 	    setup2()
	void 	    csdid_setup()	
	// master
	void 	    drdid()	
	// To "export, results"
	// void 		drdid_outpt()
	void 		init()
}

//# Regression models
void drdid::init(){
	yvar=xvar=wvar=id=oid=trt=wtrt=tmt=tmt_trt=J(0,0,.)
	xb=yhat=b=	psv=J(0,0,.)
	nn=conv=kx=minn=.
}
  
void drdid::ipt(){
	///real matrix sy,sx,sw 
	transmorphic M
	M = moptimize_init()
	moptimize_init_evaluator(M, &fipt())
	moptimize_init_depvar(M,1, trt)
	
	moptimize_init_weight(M, wvar)
	moptimize_init_eq_indepvars(M,1, xvar)
	
	b=J(1,cols(xvar),0),logit(mean(trt))
	moptimize_init_eq_coefs(M, 1, b)
	moptimize_init_evaluatortype(M, "d2")
	moptimize_init_conv_maxiter(M, 100)
	moptimize_init_tracelevel(M, "none")
	moptimize_init_conv_warning(M, "off")
	moptimize(M)
	b=	 moptimize_result_coefs(M)
	conv=moptimize_result_converged(M)
	
	xb  =(xvar,J(nn,1,1))*b'
	
}
 
void drdid::ilogit(){
	transmorphic M
	M = moptimize_init()
	
	moptimize_init_evaluator(M, &flogit())
	moptimize_init_depvar(M,1, trt)
	moptimize_init_weight(M, wvar)
	moptimize_init_eq_indepvars(M,1, xvar)
	b=J(1,cols(xvar),0),logit(mean(trt,wvar))
	moptimize_init_eq_coefs(M, 1, b)
	moptimize_init_evaluatortype(M, "d2")
	moptimize_init_conv_maxiter(M, 50)
	moptimize_init_tracelevel(M, "none")
	moptimize_init_conv_warning(M, "off")
	moptimize(M)
	b	=moptimize_result_coefs(M)
	psv =moptimize_result_V(M)
	conv=moptimize_result_converged(M)
	xb  =(xvar,J(nn,1,1))*b'
 
}

 
void drdid::ols(real matrix sw, ixx ){
	real matrix xy
	if (kx>0) {
		ixx   = invsym(quadcross(xvar,1,sw,xvar,1))
		xy   = quadcross(xvar,1,sw,yvar,0)
		b    = ixx*xy
	}
	else {
		b=mean(yvar,sw)
		ixx=1/sum(sw:!=0)
	} 
}
 
 
/// Setting Data UP
 
void drdid::msetup_panel(){
	// assume data is sorted
	// makeid to ID balance panel
	// expands current ID
	err = 0 
	makeid()
	// keeps only those with 2 observations
	tmt  = tmt :==max(tmt) ; 	trt  = trt :==max(trt)

	yvar = select(yvar,(id[,2]:==2))
	kx   = cols(xvar)	
	if (kx>0) {
	
		// Keep Data from T0 (earlier)
		xvar = select(xvar,((id[,2]:==2):*(tmt:==0)))
	
		// Keep only Xs with variation
		xvar = select(xvar,diagonal(variance(xvar))':!=0)
	}
 
	kx   = cols(xvar)
 
	// if Method is not OLS then check
 
	if (method_type <4) {
			 if (kx ==0)  {
			 	method_type=4 
 
			 }
		else if (kx >=minn) {
  // if More covariates than obs Keep minn-1 variables
 
			method_type=4
			stata(`"display in red "More X's than Observations. Dropping Variables""')
			xvar = xvar[,1..minn-1]
 
		}
	}
   
 	wtrt = wvar = select(wvar,((id[,2]:==2):*(tmt:==0)))
	wvar = wvar:/mean(wvar)
	
	// Original Copy of selected cases
	 
	oid   = select(oid ,(id[,2]:==2):*(tmt:==0))

	trt  = select(trt,(id[,2]:==2):*(tmt:==0))
	wtrt = wtrt:*trt
	tmt  = select(tmt,(id[,2]:==2))

	id   = select(id ,(id[,2]:==2))
	id   = select(id ,(tmt:==0))

	
	yvar = select(yvar,(tmt:==1)):-select(yvar,(tmt:==0))
	nn   = rows(yvar)
 	
	if (rows(yvar)==0) err=1
}

// For Rolling Regressions
 
void drdid::msetup_panel2(){
	// GOAL. get the Diff. Getting Mean
	//
	// assume data is sorted
	// makeid to ID balance panel
	// expands current ID	
	err = 0 

	makeid()
	// keeps only those with 2 observations

	tmt  = tmt :==max(tmt) ; 	trt  = trt :==max(trt)
	// Read Data in two blocks.
	// One for data at T=
	// Data for G-1 or earlier

	real matrix yvar_post, yvar_pre
	yvar_post = select(yvar,(tmt:==1))
	yvar_pre  = select(yvar,(tmt:==0))
	real matrix id2 
	id2 = select(id,(tmt:==0))
	real matrix info
	info = panelsetup(id2,1)

	yvar_pre = panelsum(yvar_pre,info):/(info[,2]:-info[,1]:+1)

	kx   = cols(xvar)
	// DOES NOT HANDLE time varying data
	if (kx>0) {
		// Keep Data from T0 (earlier): average Pre treatment
		xvar = select(xvar,(tmt:==0))
		xvar = panelsum(xvar,info):/(info[,2]:-info[,1]:+1)
		// Keep only Xs with variation
		xvar = select(xvar,diagonal(variance(xvar))':!=0)
	}
	
	kx   = cols(xvar)
 
	// if Method is not OLS then check
 
	if (method_type <4) {
			 if (kx ==0)  {
			 	method_type=4 
 
			 }
		else if (kx >=minn) {
  // if More covariates than obs Keep minn-1 variables
 
			method_type=4
			stata(`"display in red "More X's than Observations. Dropping Variables""')
			xvar = xvar[,1..minn-1]
 
		}
	}
   
 	wtrt = wvar = select(wvar,(tmt:==1))
	wvar = wvar:/mean(wvar)
	
	// Original Copy of selected cases
	 
	oid   = select(oid ,(tmt:==1))
	trt  = select(trt,(tmt:==1))
	wtrt = wtrt:*trt
	id   = select(id ,(tmt:==1))
 	
	yvar = yvar_post :-yvar_pre
	nn   = rows(yvar)
	
 	if (rows(yvar)==0) err=1

}
 
// Data setup
void drdid::msetup_rc(){
	// assume data is sorted
	// makeid to ID balance panel
	// expands current ID
	// makeid2()
	err=0
	oid=id
	id=1::rows(id)	
	// keeps only those with 2 observations
	tmt  = tmt :==max(tmt)
	trt  = trt :==max(trt)
	kx   = cols(xvar)
		
	tmt_trt = (tmt:+ 2*trt)
	
	if (kx>0) {
		// Drop data with constant
		xvar = select(xvar, select4() )
	}
	kx   = cols(xvar)
	wtrt = wvar:*trt
	wvar = wvar:/mean(wvar)
	nn   = rows(yvar)
	
	//if min( uniqrows(tmt_trt,1))[,2] ==0 ) err =1

}

real matrix drdid::select4(){
	real matrix s4way 
	//tmt_trt = (tmt:+ 2*trt)
	s4way=(diagonal(variance(xvar,tmt_trt :==0))':!=0):*
		  (diagonal(variance(xvar,tmt_trt :==1))':!=0):*
		  (diagonal(variance(xvar,tmt_trt :==2))':!=0):*
		  (diagonal(variance(xvar,tmt_trt :==3))':!=0)
	
	return(s4way)	  
}

// makes IDS for panel and RC
void drdid::makeid(){
	real scalar i,j
	real matrix id2
	//makes a copy
	//oid=id
	id2=J(rows(id),1,0)
	// Recode ID. Assumes ID are ordered
	// 
	j = 1
	for(i=1;i<=rows(id);i++){
		if (i>1) {
			if (id[i]>id[i-1]) {
				j++		
			}  		
		}	
		id2[i]=j
	}
	// recoded
	id=uniqrows(id2,1)[id2,]		
	
}

/*void drdid::makeid2(){
	oid=id
	id=1::rows(id)	
}*/	

////
 
void drdid::reg_panel(){

	real matrix wols, w_1
	real scalar mw_1
	real matrix ixx
	
	wols    = wvar :* (1 :- trt)
	w_1     = wvar :* trt
	mw_1    = mean(w_1)
	
	// OLS Simple. no checks.
	ols(wols,ixx)
 
	if (kx>0) xb = xvar*b[1..kx]:+b[kx+1]
	else      xb = b
	 
	// adds constant
	if (kx>0) xvar = xvar, J(nn,1,1)
	else      xvar =       J(nn,1,1) 
	 
	/// ATTs	
	real matrix att_treat, att_cont
	att_treat = w_1:* yvar
	att_cont  = w_1:* xb
	
	real scalar eta_treat, eta_cont
	eta_treat = mean(att_treat):/mw_1
	eta_cont  = mean(att_cont) :/mw_1	
	 
	//real matrix XpX_inv
    //XpX_inv = invsym(quadcross(xvar,wols,xvar))*nn		
	//wols_eX = wols :* (dy:-xb) :* xvar
	real matrix lin_ols
	lin_ols = ( wols :* (yvar:-xb) :* xvar ) * 
			  ( ixx * nn )
	 
	//real matrix inf_treat, inf_cont_1, inf_cont_2, inf_control
 	
	rif  		 = (eta_treat :- eta_cont):+
				   (att_treat :- w_1 * eta_treat)/mw_1 :- 
				   (att_cont  :- w_1 * eta_cont)/mw_1  :- 
				    lin_ols * (mean(xvar, w_1))'     
	
}
 

void drdid::drimp_panel(){
	// estimate psxb
		ipt()
		if (conv==1) {
			//xb=quadcross(xvar',b)
			real matrix psc, ixx
			psc=logistic(xb)
			
			real matrix w_1 , w_0, att
			w_1 = wvar :* trt
			w_0 = wvar :* psc :* (1:-trt):/(1:-psc)
			w_1 = w_1:/mean(w_1)
			w_0 = w_0:/mean(w_0)
			
			ols(w_0,ixx)
			
			if (kx>0) xb  = xvar*b[1..kx]:+b[kx+1]
				else  xb = b
		
			att=(yvar:-xb):*(w_1:-w_0)
		
			rif = mean(att) :+ att :- w_1:*mean(att)
		}
}

void drdid::stdipw_panel() {
		ilogit()
		if (conv==1) {
		real matrix psc, inf_cont_1
		psc=logistic(xb)
		// and matrices
		//psb =st_matrix(psb_ )
		
		real matrix w_1, w_0, att_cont, att_treat,
					eta_treat, eta_cont, 
					lin_ps
			
 		w_1= wvar :* trt
		w_0= wvar :* psc :* (1 :- trt):/(1 :- psc)
		
		real scalar mw_1 , mw_0
		mw_1=mean(w_1)
		mw_0=mean(w_0)
		
		att_treat = w_1:* yvar
		att_cont  = w_0:* yvar
		
		eta_treat = mean(att_treat)/mw_1
		eta_cont  = mean(att_cont) /mw_0
		//ipw_att   = eta_treat :- eta_cont
		//inf_treat  = (att_treat :- (w_1 :* eta_treat))/mw_1
		inf_cont_1 = (att_cont  :- (w_0 :* eta_cont ))
		
		xvar=xvar,J(nn,1,1)
		//lin_ps = (wvar:* (trt :- psc) :* xvar)*(psv * nn)
		//M2 =
		///inf_cont_2 = ( (wvar:* (trt :- psc) :* xvar) ) * ( psv * mean(inf_cont_1 :* xvar)' ) * nn 
		// inf_control = (inf_cont_1 :+ inf_cont_2)/mw_0
		
		rif = ( eta_treat :- eta_cont ) :+ 
				( (att_treat :- (w_1 :* eta_treat)) /mw_1 ) :- 
				( inf_cont_1  :+ (wvar:* (trt :- psc) :* xvar ) * 
				(psv * mean(inf_cont_1 :* xvar)') * nn )/mw_0		
		}	
	}
	

void drdid::dripw_panel() {
		
		real matrix exb, psc
		real matrix w_1, w_0, wols
		real matrix dy_xb, ixx
		real matrix lin_ols, lin_ps
		
		ilogit()
		if (conv==1) {
			real matrix nest
			exb=exp(xb); psc=logistic(xb)
						
			w_1 = (wvar:*trt)
			w_0 = (wvar:*psc:*(1:-trt):/(1:-psc))
			w_1 = w_1 / mean(w_1)
			w_0 = w_0 / mean(w_0)
			
			// ols part
			wols    = wvar :* (1 :- trt)	
			
			ols(wols,ixx)
			 
			if (kx>0) xb  = xvar*b[1..kx]:+b[kx+1]
			else      xb = b					
			
			// adds a constant for the rest of the analysis
	 
			xvar=xvar,J(nn,1,1)		
			dy_xb = yvar:-xb
			//att = mean((w_1:-w_0):*(dy_xb))
			
			lin_ols = (wols :* (dy_xb)    :* xvar) * (ixx * nn)
			lin_ps 	= (wvar :* (trt:-psc) :* xvar) * (psv * nn)
			
			// Components for RIF
			real matrix  aa
			
			//n1   = w_1:*(dy_xb:-mean(dy_xb,w_1))
			//n0   = w_0:*(dy_xb:-mean(dy_xb,w_0))
			aa    = ((1:-trt):/(1:-psc):^2)/ mean(psc:*(1:-trt):/(1:-psc))
			  
			nest = lin_ols * (mean(xvar,w_1)     :- mean(xvar ,w_0))' :+
				   lin_ps   *  mean( aa :* (dy_xb :- mean(dy_xb,w_0))  :* 
				   exb:/(1:+exb):^2:*xvar )'	
				   
			// RIF att_inf_func = inf_treat' :- inf_control
			rif = mean((w_1:-w_0):*(dy_xb)):+ 
						w_1:*(dy_xb:-mean(dy_xb,w_1)):-
						w_0:*(dy_xb:-mean(dy_xb,w_0)):-
						nest
		}
	}

void drdid::ols_ipw_rc(real scalar ii, real matrix yy, real matrix ixx ){
	///tmt_trt = (tmt:+ 2*trt)
	/// 0   0  = 0
	/// 1   0  = 1
	/// 0   1  = 2
	/// 1   1  = 3
	real matrix xy, sw 
	sw = wvar:*(tmt_trt:==ii)	
	sw = sw :/mean(sw)
	if (kx>0) {
		ixx  = invsym(quadcross(xvar,1, sw ,xvar,1))
		xy   =        quadcross(xvar,1, sw ,yvar,0)
		b    = ixx*xy
		yy   = (xvar,J(nn,1,1))*b
	}
	else {
		b=mean(yvar,sw)
		ixx=1/sum(sw:!=0)
		yy   = b
	}
}	

void drdid::ols_ipt_rc( real scalar ii,
						real matrix ww, 
						real matrix yy,
						real matrix ixx ){
	///tmt_trt = (tmt:+ 2*trt)
	/// 0   0  = 0
	/// 1   0  = 1
	/// 0   1  = 2
	/// 1   1  = 3
	
	real matrix xy, sw 
	
	sw = ww:*(tmt_trt:==ii)
	
	if (kx>0) {
	
		ixx  = invsym(quadcross(xvar,1,sw,xvar,1))
		xy   =        quadcross(xvar,1,sw,yvar,0)
		b    = ixx*xy
		yy   = (xvar,J(nn,1,1))*b
	}
	else {
	
		b=mean(yvar,sw)
		ixx=1/sum(sw:!=0)
		yy   = b
	}
}

void drdid::dripw_rc(){
    // main Loading variables
	ilogit()
	if (conv==1) {
		real matrix psc
		psc=logistic(xb)
		/// tmt trt
		real matrix y00,   y01,   y10,   y11
		real matrix ixx00, ixx01, ixx10, ixx11
		real matrix w00  , w01,   w10,   w11, w1
		real matrix y0
		
		ols_ipw_rc(0,y00,ixx00)
		ols_ipw_rc(1,y01,ixx01)
		ols_ipw_rc(2,y10,ixx10)
		ols_ipw_rc(3,y11,ixx11)
		
		y0   = y00:*(-tmt:+1) + y01:*tmt
		
		w00 = wvar :* (tmt_trt:==0) :* psc :/(1 :- psc) ; w00 = w00:/mean(w00 )
		w01 = wvar :* (tmt_trt:==1) :* psc :/(1 :- psc) ; w01 = w01:/mean(w01 ) 
		w10 = wvar :* (tmt_trt:==2)                     ; w10 = w10:/mean(w10 )   
		w11 = wvar :* (tmt_trt:==3)                     ; w11 = w11:/mean(w11 )  
		w1  = wvar :* trt                               ; w1  = w1 :/mean(w1  )

		
		real matrix att_treat_pre, att_treat_post,  att_cont_pre, att_cont_post,
					att_trt_post , att_trtt1_post, att_trt_pre  , att_trtt0_pre,
					eta_treat_pre, eta_treat_post,  eta_cont_pre, eta_cont_post,
					eta_trt_post , eta_trtt1_post, eta_trt_pre  , eta_trtt0_pre
					
		// adds constant
		real matrix y_y0
		xvar = xvar,J(nn,1,1)
		y_y0 = yvar:-y0
		att_treat_pre 		= w10 :* (y_y0)		 ; eta_treat_pre 		= mean(att_treat_pre)
		att_treat_post 		= w11 :* (y_y0)		 ; eta_treat_post 		= mean(att_treat_post)
		att_cont_pre  		= w00 :* (y_y0)		 ; eta_cont_pre  		= mean(att_cont_pre)
		att_cont_post  		= w01 :* (y_y0)		 ; eta_cont_post  		= mean(att_cont_post)
		att_trt_post   		= w1  :* (y11 :- y01); eta_trt_post   		= mean(att_trt_post)
		att_trtt1_post 		= w11 :* (y11 :- y01); eta_trtt1_post 		= mean(att_trtt1_post)
		att_trt_pre   		= w1  :* (y10 :- y00); eta_trt_pre   		= mean(att_trt_pre)
		att_trtt0_pre 		= w10 :* (y10 :- y00); eta_trtt0_pre 		= mean(att_trtt0_pre)
		
		real matrix trtr_att
		trtr_att      		= (eta_treat_post :- eta_treat_pre) :- (eta_cont_post :- eta_cont_pre) :+ 
							  (eta_trt_post :- eta_trtt1_post) :- (eta_trt_pre :- eta_trtt0_pre)
		
		real matrix wgt00, XpX_inv_pre, lin_ols_pre, 
					wgt01, XpX_inv_post, lin_ols_post,
					XpX_inv_pre_treat, lin_ols_pre_treat,
					XpX_inv_post_treat, lin_ols_post_treat
					
		// cannot be simplified
		wgt00     	= wvar :* (tmt_trt:==0)
		lin_ols_pre 		= ( wgt00 :* (yvar :- y00) :* xvar) * invsym(quadcross(xvar,wgt00, xvar)):*nn
		
		wgt01     	= wvar :* (tmt_trt:==1)
		lin_ols_post 		= (wgt01 :* (yvar :- y01) :* xvar) * invsym(quadcross(xvar,wgt01, xvar)):*nn

		//wols_x_pre_treat 	= w10 :* xvar
		//wols_eX_pre_treat 	= w10 :* (y :- y10) :* xvar
		
		// These ones CAN 
		lin_ols_pre_treat 	= ( w10 :* (yvar :- y10) :* xvar) * ixx10 *nn
		lin_ols_post_treat 	= (w11 :* (yvar :- y11) :* xvar) * ixx11 *nn
	 
		real matrix lin_rep_ps, inf_treat_pre, inf_treat_post
		// check psv for probit
		//score_ps 			= wgt :* (trt :- psc) :* xvar
		//Hessian_ps 			= psv :* nn
		lin_rep_ps 			= (wvar :* (trt :- psc) :* xvar) * (psv :* nn)
		inf_treat_pre 		= att_treat_pre  :- w10 :* eta_treat_pre 
		inf_treat_post 		= att_treat_post :- w11 :* eta_treat_post
	 
		real matrix M1_post, M1_pre, inf_treat_or_post, inf_treat_or_pre
	 
		inf_treat_or_post 	= -lin_ols_post * mean(w11 :* tmt :* xvar)'
		inf_treat_or_pre 	= -lin_ols_pre * mean(w10 :* (1 :- tmt) :* xvar)'
		
		real matrix inf_treat_or, inf_treat, inf_cont_post_pre
		
		//inf_treat_or 		= inf_treat_or_post :+ inf_treat_or_pre
		inf_treat 			= inf_treat_post :- inf_treat_pre :+
							  (inf_treat_or_post :+ inf_treat_or_pre)
							  
		inf_cont_post_pre	= (att_cont_post :- w01 :* eta_cont_post) :-
							 (att_cont_pre  :- w00 :* eta_cont_pre)
		
		real matrix M2_pre, M2_post, inf_cont_ps, M3_post, M3_pre, inf_cont_or_post, inf_cont_or_pre
		
		inf_cont_ps 		= lin_rep_ps * 
								(mean(w01 :* (y_y0 :- eta_cont_post) :* xvar):- 
								mean(w00 :* (y_y0 :- eta_cont_pre) :* xvar))'
		
		real matrix inf_cont_or, inf_cont, trtr_eta_inf_func1
		
		inf_cont_or 		= -lin_ols_post * mean(w01 :* tmt :* xvar)' :- 
							   lin_ols_pre  * mean(w00 :* (1 :- tmt) :* xvar)'

		inf_cont 			= inf_cont_post_pre     :+ 
							  inf_cont_ps :+ inf_cont_or
							  
		trtr_eta_inf_func1 	= inf_treat :- inf_cont
		
		real matrix inf_eff, mom_post, mom_pre, inf_or

		inf_eff 			= ((att_trt_post   :- w1  :* eta_trt_post)    :- 
							   (att_trtt1_post :- w11 :* eta_trtt1_post)) :-
							  ((att_trt_pre    :- w1  :* eta_trt_pre)     :- 
							   (att_trtt0_pre :- w10 :* eta_trtt0_pre))

		inf_or 				= (lin_ols_post_treat :- lin_ols_post) * mean((w1 :- w11) :* xvar)' :- 
							  (lin_ols_pre_treat :- lin_ols_pre) * mean((w1 :- w10) :* xvar)'
		
		
		rif	 				= trtr_att :+ trtr_eta_inf_func1 :+ inf_eff :+ inf_or	
	}	
  }

void drdid::drimp_rc(){
    // main Loading variables
	real matrix psc, ipw
	ipt()
	if (conv==1) {
		psc=logistic(xb)
		ipw=psc:/(1:-psc)
		/// tmt trt
		real matrix y00,   y01,   y10,   y11,
					ixx00, ixx01, ixx10, ixx11,
					w00  , w01,   w10,   w11, w1
				
		ols_ipt_rc(0,ipw,y00,ixx00)
		ols_ipt_rc(1,ipw,y01,ixx01)
		ols_ipt_rc(2,1  ,y10,ixx10)
		ols_ipt_rc(3,1  ,y11,ixx11)    				
		
		real matrix y0

		y0   = y00:*(1:-tmt) :+ y01:*tmt
		
	 
		w00 = wvar :* (tmt_trt:==0) :* ipw; w00 = w00:/mean(w00 )
		w01 = wvar :* (tmt_trt:==1) :* ipw; w01 = w01:/mean(w01 )
		w10 = wvar :* (tmt_trt:==2)       ; w10 = w10:/mean(w10 )
		w11 = wvar :* (tmt_trt:==3)       ; w11 = w11:/mean(w11 )
		w1  = wvar :* trt                 ; w1  = w1 :/mean(w1 )
		 
		real matrix att_treat_pre, att_treat_post, att_cont_pre, att_cont_post, att_trt_post, att_trtt1_post,
					att_trt_pre, att_trtt0_pre
		real matrix eta_treat_pre, eta_treat_post, eta_cont_pre, eta_cont_post, eta_trt_post, eta_trtt1_post,
					eta_trt_pre, eta_trtt0_pre				
		real matrix y_y0
		y_y0 = yvar :- y0
		 
		att_treat_pre  = w10 :* (y_y0)		; eta_treat_pre  = mean(att_treat_pre)
		att_treat_post = w11 :* (y_y0)		; eta_treat_post = mean(att_treat_post)
		att_cont_pre   = w00 :* (y_y0)		; eta_cont_pre   = mean(att_cont_pre)
		att_cont_post  = w01 :* (y_y0)		; eta_cont_post  = mean(att_cont_post)
		att_trt_post   = w1  :* (y11 :- y01); eta_trt_post   = mean(att_trt_post)
		att_trtt1_post = w11 :* (y11 :- y01); eta_trtt1_post = mean(att_trtt1_post)
		att_trt_pre    = w1  :* (y10 :- y00); eta_trt_pre    = mean(att_trt_pre)
		att_trtt0_pre  = w10 :* (y10 :- y00); eta_trtt0_pre  = mean(att_trtt0_pre)

		real matrix trtr_att
		trtr_att       = (eta_treat_post :- eta_treat_pre ) :- 
						 (eta_cont_post  :- eta_cont_pre  ) :+ 
						 (eta_trt_post   :- eta_trtt1_post) :- 
						 (eta_trt_pre    :- eta_trtt0_pre )
		
		real matrix inf_treat,  inf_cont,  att_inf_func1,  inf_eff, att_inf_func
		
		inf_treat      = (att_treat_post :- w11 :* eta_treat_post) :- 
						 (att_treat_pre  :- w10 :* eta_treat_pre)
		inf_cont       = (att_cont_post  :- w01 :* eta_cont_post)  :- 
						 (att_cont_pre   :- w00 :* eta_cont_pre)
		att_inf_func1  = inf_treat :- inf_cont
		
		inf_eff        =  ((att_trt_post   :- w1  :* eta_trt_post) :- 
						   (att_trtt1_post :- w11 :* eta_trtt1_post)) :- 
						  ((att_trt_pre    :- w1  :* eta_trt_pre) :- 
						   (att_trtt0_pre  :- w10 :* eta_trtt0_pre))
		
		rif = trtr_att :+ att_inf_func1 :+ inf_eff		
	}	
}



void drdid::reg_rc() {
    // main Loading variables
	real matrix y00, y01, ixx00, ixx01
	
	ols_ipt_rc(0,wvar,y00,ixx00)
	ols_ipt_rc(1,wvar,y01,ixx01)
	
	// add constant
	if (kx > 0) xvar=xvar,J(nn,1,1)
	else 	    xvar=     J(nn,1,1)
	 
	real matrix w10, w11, w1	
	w10 			= wvar :* trt :* (1 :- tmt);w10	= w10:/mean(w10 )
    w11 			= wvar :* trt :* tmt		  ;w11	= w11:/mean(w11 )
    w1 				= wvar :* trt			  ;w1	= w1 :/mean(w1  )
	
	real matrix att_treat_pre, att_treat_post, att_cont,
				eta_treat_pre, eta_treat_post, eta_cont, reg_att
	 			
    att_treat_pre 	= w10 :* yvar		; eta_treat_pre 	= mean(att_treat_pre)		
    att_treat_post 	= w11 :* yvar		; eta_treat_post 	= mean(att_treat_post)
    att_cont 		= w1 :* (y01 :- y00); eta_cont 			= mean(att_cont)
      
    reg_att 		= (eta_treat_post :- eta_treat_pre) :- eta_cont
	
	real matrix w_ols_pre, wols_eX_pre, lin_rep_ols_pre
	 
    w_ols_pre 		= wvar :* (1 :- trt) :* (1 :- tmt)
		
    wols_eX_pre 	= w_ols_pre :* (yvar :- y00) :* xvar
	lin_rep_ols_pre = wols_eX_pre * ixx00 * nn
	real matrix w_ols_post, wols_eX_post, lin_rep_ols_post
    w_ols_post 		= wvar :* (1 :- trt) :* tmt
    wols_eX_post 	= w_ols_post :* (yvar :- y01) :* xvar
    lin_rep_ols_post= wols_eX_post * ixx01 :* nn
     
	real matrix inf_treat, inf_cont_1, inf_cont_2_post, inf_cont_2_pre, inf_control

    inf_treat 		= (att_treat_post :- w11 :* eta_treat_post) :- 
					  (att_treat_pre  :- w10 :* eta_treat_pre)
 
    inf_cont_1 		= (att_cont :- w1 :* eta_cont)
 
    //M1 				= mean(w0 :* xvar)
    inf_cont_2_post = lin_rep_ols_post * mean(w1 :* xvar)'
    inf_cont_2_pre 	= lin_rep_ols_pre  * mean(w1 :* xvar)'
    inf_control 	= (inf_cont_1 :+ inf_cont_2_post :- inf_cont_2_pre)
    	
	rif 	= reg_att :+ (inf_treat :- inf_control)
	
 }
void drdid::reg2_rc(){
    // main Loading variables
	real matrix y00,   y01,   y10,   y11,
				ixx00, ixx01, ixx10, ixx11
				 
 			
	ols_ipw_rc(0,y00,ixx00)
	ols_ipw_rc(1,y01,ixx01)
	ols_ipw_rc(2,y10,ixx10)
	ols_ipw_rc(3,y11,ixx11)   				
	
	real matrix y0

	y0   = y00:*(1:-tmt) :+ y01:*tmt
	
	real matrix w10, w11, w00, w01, w1
	
	w00 = wvar :* (tmt_trt:==0) 	  ; w00 = w00:/mean(w00 )
    w01 = wvar :* (tmt_trt:==1) 	  ; w01 = w01:/mean(w01 )
    w10 = wvar :* (tmt_trt:==2)       ; w10 = w10:/mean(w10 )
    w11 = wvar :* (tmt_trt:==3)       ; w11 = w11:/mean(w11 )
    w1  = wvar :* trt                 ; w1  = w1 :/mean(w1 )
	
	real matrix att_treat_pre, att_treat_post, att_cont_pre, att_cont_post, att_trt_post, att_trtt1_post,
				att_trt_pre, att_trtt0_pre
	real matrix eta_treat_pre, eta_treat_post, eta_cont_pre, eta_cont_post, eta_trt_post, eta_trtt1_post,
				eta_trt_pre, eta_trtt0_pre				
	real matrix y_y0
	y_y0 = yvar :- y0
    att_treat_pre  = w10 :* (y_y0)		; eta_treat_pre  = mean(att_treat_pre)
    att_treat_post = w11 :* (y_y0)		; eta_treat_post = mean(att_treat_post)
    att_cont_pre   = w00 :* (y_y0)		; eta_cont_pre   = mean(att_cont_pre)
    att_cont_post  = w01 :* (y_y0)		; eta_cont_post  = mean(att_cont_post)
    att_trt_post   = w1  :* (y11 :- y01); eta_trt_post   = mean(att_trt_post)
    att_trtt1_post = w11 :* (y11 :- y01); eta_trtt1_post = mean(att_trtt1_post)
    att_trt_pre    = w1  :* (y10 :- y00); eta_trt_pre    = mean(att_trt_pre)
    att_trtt0_pre  = w10 :* (y10 :- y00); eta_trtt0_pre  = mean(att_trtt0_pre)

	real matrix trtr_att
    trtr_att       = (eta_treat_post :- eta_treat_pre ) :- 
					 (eta_cont_post  :- eta_cont_pre  ) :+ 
					 (eta_trt_post   :- eta_trtt1_post) :- 
					 (eta_trt_pre    :- eta_trtt0_pre )
	
	real matrix inf_treat,  inf_cont,  att_inf_func1,  inf_eff, att_inf_func
	
	inf_treat      = (att_treat_post :- w11 :* eta_treat_post) :- 
					 (att_treat_pre  :- w10 :* eta_treat_pre)
    inf_cont       = (att_cont_post  :- w01 :* eta_cont_post)  :- 
					 (att_cont_pre   :- w00 :* eta_cont_pre)
	att_inf_func1  = inf_treat :- inf_cont
	
    inf_eff        =  ((att_trt_post   :- w1  :* eta_trt_post) :- 
					   (att_trtt1_post :- w11 :* eta_trtt1_post)) :- 
					  ((att_trt_pre    :- w1  :* eta_trt_pre) :- 
					   (att_trtt0_pre  :- w10 :* eta_trtt0_pre))
	
    rif = trtr_att :+ att_inf_func1 :+ inf_eff		
} 
   
void drdid::reg3_rc() {
    // main Loading variables
	
	real matrix y00,   y01,   y10,   y11,
				ixx00, ixx01, ixx10, ixx11,
				w00  , w01,   w10,   w11, w0,w1
				
	ols_ipt_rc(0,wvar,y00,ixx00)
	ols_ipt_rc(1,wvar,y01,ixx01)
	ols_ipt_rc(2,wvar,y10,ixx10)
	ols_ipt_rc(3,wvar,y11,ixx11)
	
	// add constant
	xvar=xvar,J(nn,1,1)
	
	w00 			= wvar :* (tmt_trt:==0);w00	= w00:/mean(w00)
    w01 			= wvar :* (tmt_trt:==1);w01	= w01:/mean(w01)
	w10 			= wvar :* (tmt_trt:==2);w10	= w10:/mean(w10)
    w11 			= wvar :* (tmt_trt:==3);w11	= w11:/mean(w11)
    
	
	real matrix att_treat_pre, att_treat_post, att_cont,
				eta_treat_pre, eta_treat_post, eta_cont, reg_att
    att_treat_pre 	= w10 :* yvar		; eta_treat_pre 	= mean(att_treat_pre)		
    att_treat_post 	= w11 :* yvar		; eta_treat_post 	= mean(att_treat_post)
    att_cont 		= w1 :* (y01 :- y00); eta_cont 			= mean(att_cont)
        
    reg_att 		= (eta_treat_post :- eta_treat_pre) :- eta_cont
	
	real matrix w_ols_pre, wols_eX_pre, lin_rep_ols_pre
	
    w_ols_pre 		= wvar :* (1 :- trt) :* (1 :- tmt)
    wols_eX_pre 	= w_ols_pre :* (yvar :- y00) :* xvar
    lin_rep_ols_pre = wols_eX_pre * ixx00 * nn
	
	real matrix w_ols_post, wols_eX_post, lin_rep_ols_post
    w_ols_post 		= wvar :* (1 :- trt) :* tmt
    wols_eX_post 	= w_ols_post :* (yvar :- y01) :* xvar
    lin_rep_ols_post= wols_eX_post * ixx01 :* nn
    
	real matrix inf_treat, inf_cont_1, inf_cont_2_post, inf_cont_2_pre, inf_control

    inf_treat 		= (att_treat_post :- w11 :* eta_treat_post) :- 
					  (att_treat_pre  :- w10 :* eta_treat_pre)
    inf_cont_1 		= (att_cont :- w0 :* eta_cont)
    //M1 				= mean(w0 :* xvar)
    inf_cont_2_post = lin_rep_ols_post * mean(w0 :* xvar)'
    inf_cont_2_pre 	= lin_rep_ols_pre  * mean(w0 :* xvar)'
    inf_control 	= (inf_cont_1 :+ inf_cont_2_post :- inf_cont_2_pre)
    	
	rif 	= reg_att :+ (inf_treat :- inf_control)
	
 }   
   
void drdid::stdipw_rc(){
    // main Loading variables
    ilogit()
	if (conv==1) {
		real matrix psc, w00, w01, w10, w11
		psc=logistic(xb)    
		w00 = wvar :* (tmt_trt:==0) :* psc:/(1 :- psc)
		w01 = wvar :* (tmt_trt:==1) :* psc:/(1 :- psc)
		w10 = wvar :* (tmt_trt:==2)
		w11 = wvar :* (tmt_trt:==3)
		
		w00 = w00:/mean(w00 )
		w01 = w01:/mean(w01 )
		w10 = w10:/mean(w10 )
		w11 = w11:/mean(w11 )
		
		real matrix att_treat_pre, att_treat_post, att_cont_pre, att_cont_post,
					eta_treat_pre, eta_treat_post, eta_cont_pre, eta_cont_post
		att_treat_pre  	= w10 :* yvar; eta_treat_pre  	= mean(att_treat_pre)
		att_treat_post 	= w11 :* yvar; eta_treat_post 	= mean(att_treat_post)
		att_cont_pre   	= w00 :* yvar; eta_cont_pre   	= mean(att_cont_pre)
		att_cont_post  	= w01 :* yvar; eta_cont_post  	= mean(att_cont_post)
		// add constant   
		xvar=xvar,J(nn,1,1)
		
		real matrix ipw_att, lin_rep_ps
		ipw_att 		= (eta_treat_post :- eta_treat_pre) :-
						  (eta_cont_post  :- eta_cont_pre)
		//score_ps 		= wgt :* (trt :- psc) :* xvar
		//Hessian_ps 		= psv :* nn
		lin_rep_ps 		= (wvar :* (trt :- psc) :* xvar) * (psv :* nn)
		
		real matrix inf_treat, inf_cont,  inf_cont_ps, att_inf_func
		
		inf_treat 		= (att_treat_post:- w11 :* eta_treat_post) :- 
						  (att_treat_pre :- w10 :* eta_treat_pre)
		inf_cont 		= (att_cont_post :- w01 :* eta_cont_post) :- 
						  (att_cont_pre  :- w00 :* eta_cont_pre)
		//M2_pre 			= mean(w00 :* (yvar :- eta_cont_pre) :* xvar)
		//M2_post 		= mean(w01 :* (yvar :- eta_cont_post):* xvar)
		inf_cont_ps 	= lin_rep_ps * ( mean(w01 :* (yvar :- eta_cont_post):* xvar) :- 
										 mean(w00 :* (yvar :- eta_cont_pre) :* xvar))'
		//inf_cont 		= inf_cont :+ inf_cont_ps  
		//     ipw_att 		= (eta_treat_post :- eta_treat_pre) :-
		//			    	  (eta_cont_post  :- eta_cont_pre)
		
		rif = (eta_treat_post :- eta_treat_pre) :-
			  (eta_cont_post  :- eta_cont_pre) :+  
			inf_treat :- ( inf_cont :+ inf_cont_ps )
	
 //  -15.80330618	
 //  9.087929526
	}
 }   

/// SETUP Interactive Version 
 
/*void drdid::setup(){
	yvar = st_data(.,"re")
	xvar = st_data(.,"age educ black married nodegree hisp re74")
	tmt  = st_data(.,"year")
	trt  = st_data(.,"experimental")
	wvar = J(rows(yvar),1,1)
	id   = st_data(.,"id")
	oid   = st_data(.,"id")
}

void drdid::setup2(real scalar dt, real scalar mt){
	data_type   = dt
	method_type = mt
	yvar = st_data(.,"re")
	xvar = st_data(.,"age educ black married nodegree hisp re74")
	tmt  = st_data(.,"year")
	trt  = st_data(.,"experimental")
	wvar = J(rows(yvar),1,1)
	id   = st_data(.,"id")
	oid   = st_data(.,"id")
}*/

// Non Interactive. 
// This IMPLEMENTS DRDID
void drdid::drdid(){
	// setup2(dt,mt)
	// IF N=0 NOT CONVERGED. eRROR
	if (data_type == 1) {
		
		if (rolljw==0)      msetup_panel()  
		else if (rolljw==1) msetup_panel2()  
		
		if (err ==0) {
				 if (method_type ==1) dripw_panel()
			else if (method_type ==2) drimp_panel()
			else if (method_type ==3) stdipw_panel()
			else if (method_type ==4) reg_panel()
		}
		else conv=0
	}
	else {

		msetup_rc()
			 if (method_type ==1) dripw_rc()
		else if (method_type ==2) drimp_rc()
		else if (method_type ==3) stdipw_rc()
		else if (method_type ==4) reg_rc()
	} 
	
	if (conv==1) minn=rows(rif)*(1+(data_type:==1))
	        else minn=0
	
}

void drdid::csdid_setup(real matrix syvar, sxvar ,
						stvar, sgvar, swvar, sivar, soid, 
						real scalar dt, mt){						
	yvar = syvar
	xvar = sxvar
	tmt  = stvar
	trt  = sgvar
	wvar = swvar
	id   = sivar
	oid  = soid
	data_type   = dt
	method_type = mt	
	conv=1

}



/*void drdid::drdid_outpt(real matrix xout, minx, cnv){						
	//xout = oid, id[,1], tmt, trt, wvar, rif	
	//cnv = conv
	//minx=rows(rif)*(1+data_type:=1)
}*/



end
