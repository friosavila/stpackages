mata:
 	void event_p( string scalar newvars, string scalar tblx){
	    real   matrix tbl, ntbl2
		string matrix ntbl
	    tbl = st_matrix(tblx)	
		 
		ntbl = st_matrixcolstripe(tblx)
		ntbl = usubinstr(ntbl,"tp","+",.)
		ntbl = usubinstr(ntbl,"tm","-",.)	
		ntbl2= strtoreal(ntbl)	
		tbl  = tbl[(1,5,6),]'	
		tbl  = select(tbl,(ntbl2[,2]:!=.))		
		ntbl2= select(ntbl2[,2],(ntbl2[,2]:!=.))
        real matrix ss
 		ss= _st_addvar("double",tokens(newvars))
 		st_store((1::rows(tbl)) ,tokens(newvars),(ntbl2,tbl))	
	}
 
	void other_p(string scalar newvars, string scalar tblx){
	    real   matrix tbl
		string matrix ntbl
	    tbl  = st_matrix(tblx)		
		ntbl = st_matrixcolstripe(tblx)
		//ntbl = usubinstr(ntbl,"g","",.)
		//ntbl = usubinstr(ntbl,"t","",.)
		ntbl = ntbl [,2]
		tbl  = tbl[(1,5,6),]'	
		string matrix tnv
		tnv = tokens(newvars)
		real matrix ss
		ss= _st_addvar(sprintf("str%f",max(strlen(ntbl))),tnv[1])
		ss= _st_addvar("double",tnv[2..4])
		st_sstore((1::rows(tbl)) ,tnv[1],ntbl)	
		st_store((1::rows(tbl)) ,tnv[2..4],tbl)	
	}
end
 

mata
class csdid {
	// input data
	real matrix yvar 
	real matrix xvar 
	real matrix cvar 
	real matrix tvar,stvar 
	real matrix gvar,sgvar
	real scalar delta
	real matrix wvar
	real matrix ivar
	real matrix oid
	real matrix foid
	real matrix ord
	// final RIF
	real matrix frif
	// weights 
	real matrix frwt
	/// type of model, options
	real scalar notyet
	real scalar shortx
	real scalar asinr
	real scalar type_data
	real scalar type_est
	/// Special Option for JW Rolling Regressopm
	real scalar rolljw
	
	// output for selection	
	real matrix fgtvar
	real matrix ogtvar
	real matrix eventvar, sevent
	// Did it converged?
	real matrix convar
	// useful functions
	real matrix sample_select()
	real matrix nvalid()
	real matrix nsample_select()
	void 		setup()
	void 		setup2()
	void 		gtvar()
	void 	    makeid()
	void 	    sevent()
	void 		fixrif()
	// model setup
	void 	    csdid()
	void 	    csdid_type()
	void 	    csdid_setup()
	void 	    setup_yvar()
	void 	    setup_xvar()
	void 	    setup_wvar()
	void 	    setup_cvar()
	void 	    setup_ivar()
	void 	    setup_tvar()
	void 	    setup_gvar()
	////////////////////////////////////////////////////////////////////////////
	void 	    easter_egg()
} 


// This Module FIXES the missing records.
void csdid::easter_egg() {
if (runiform(1,1,0,1)<.5) {
"                   .-^-."
"                 .'=^=^='."
"                /=^=^=^=^=\"
"        .-~-.  :^= HAPPY =^;"
"      .'~~*~~'.|^ EASTER! ^|"
"     /~~*~~~*~~\^=^=^=^=^=^:"
"    :~*~~~*~~~*~\.-*))`*-,/"
"    |~~~*~~~*~~|/*  ((*   *'."
"    :~*~~~*~~~*|   *))  *   *\"
"     \~~*~~~*~~| *  ((*   *  /"
"      '.~~*~~.' \  *))  *  .'"
"        '~~~'    '-.((*_.-'  "
}
else {
"                   .==."
"                  ()''()-."
"       .---.       ;--; /"
"     .'_:___'. _..'.  __'."
"     |__ --==|'-''' \'...;"
"     [  ]  :[|       |---\"
"     |__| I=[|     .'    '."
"     / / ____|     :       '._"
"    |-/.____.'      | :       :"
"    /___\ /___\      '-'._----'"
" ObiWan Kenobi-CSDID is our only hope"
}
}
 
void csdid::fixrif(){
	real matrix mn_rif, rif2
	real scalar cnmiss
	cnmiss = colnonmissing(frif)
	mn_rif= colsum(frif):/cnmiss
 	frif  = frif:-mn_rif
	frif   = editmissing(frif,0)
	frif   = mn_rif:+frif:*(rows(frif):/cnmiss)
}
/// Everything else will be used 
void csdid::setup2(){
	//xs  =J(0,0,.)
	//ivar=J(0,0,.)
	//ws  =.z
}
void csdid::setup(){
	//xs  =J(0,0,.)
	//ivar=J(0,0,.)
	//ws  =.z
}
// Load ALL data
/*
1. get data
2. set method and data type
3. final tuning
*/
/// SETS Data from Stata
/// yvar
void csdid::setup_yvar(string scalar ys, touse)	st_view(yvar =.,.,ys,touse)
/// xvar, may be null
void csdid::setup_xvar(string scalar xs, touse) st_view(xvar =.,.,xs,touse)
/// ivar May be null
void csdid::setup_ivar(string scalar is, touse) st_view(ivar =.,.,is,touse)
/// tvar
void csdid::setup_tvar(string scalar ts, touse) st_view(tvar =.,.,ts,touse)
void csdid::setup_gvar(string scalar gs, touse) st_view(gvar =.,.,gs,touse)
// wvar may be null
void csdid::setup_wvar(string scalar ws, touse) st_view(wvar =.,.,ws,touse)
void csdid::setup_cvar(string scalar cs, touse) st_view(cvar =.,.,cs,touse)

//Setting up model
void csdid::csdid_type(type_est, notyet, shrt, asinr){
	// notyet
	this.notyet    = notyet
	// isshort
	this.shortx      = shrt
	// as in r
	this.asinr     = asinr
	// panel or RC
	// this.type_data = type_data
	// DRIPW DRIMP SIPW REG
	this.type_est  = type_est	
}

 
void csdid::csdid_setup(){
	/// final Tunning to model
	// oid. Original ID. Useful for RC. DROP 
	// IF RC
	rolljw =0
	if (length(ivar)==0) {
		type_data = 2
		oid  = 1::rows(yvar)	
		ivar = oid 
		if (length(cvar)>0) ord = order((cvar,gvar,tvar,ivar),(1,2,3,4))
		else                ord = order((gvar,tvar,ivar),(1,2,3))
		
		if (ord!=oid) {
			yvar=yvar[ord,]
			if (length(xvar)>0)  xvar=xvar[ord,]
			tvar=tvar[ord,]
			gvar=gvar[ord,]
			
			if (length(wvar)>0)  wvar=wvar[ord,]
			
			ivar=ivar[ord,]
			//oid = oid[ord,]
			if (length(cvar)>0) cvar=cvar[ord,]

		}
		
	}
	else {
		// if panel, first sort
		type_data = 1
		oid  = 1::rows(yvar)
		ord = order((ivar,tvar),(1,2))
		if (ord!=oid) {
			yvar=yvar[ord,]
			if (length(xvar)>0) xvar=xvar[ord,]
			tvar=tvar[ord,]
			gvar=gvar[ord,]
			if (length(wvar)>0) wvar=wvar[ord,]
 			ivar=ivar[ord,]
			if (length(cvar)>0) cvar=cvar[ord,]
			 
		}
		// then recode
		makeid()
		// if panel
		foid = uniqrows(oid)
	}
	
	if (length(wvar)==0) wvar=J(rows(yvar),1,1)
}	
// Justs Puts all into Running Data
void csdid::makeid(){
	real scalar i,j, in
	real matrix aux
	in = rows(ivar)
	oid=runningsum(0\(ivar[2..in,]-ivar[1..in-1,]):>0):+1
	// recoded
	//oid=uniqrows(id2,1)[id2,]		
}
 
// gtvar creates 2 things
// fgtvar <- Full set of Cohort year for regression
// ogtvar <- All combinations observed in data. To detect what is missing
// This IDS data and Creates Gvar

void csdid::gtvar(){
	real matrix aux
	// ids all cohorts
	stvar=uniqrows(tvar)
	sgvar=uniqrows(gvar)
	// Check if there is overlap
	if (length(uniqrows(stvar\sgvar))>=(length(stvar)+length(sgvar))) {
		"There is no overlapping between Tvar and Gvar"
		"Check to verify Gvar is correctly Specified"
		exit(1)
	}
	
	// If Never treated in Time window
	/*if (max(sgvar):>max(stvar)) {
		stata(`"display "Some Records were treated After the last period in data ""')
		stata(`"display "They will be treated as Never treated""')
		// Recode as Never Treated
		gvar=gvar:*(gvar:<=max(stvar))
		sgvar=uniqrows(gvar)	
	}*/	
	// if Treated After Max T. Never treated
	//notyet -> Verify if there is any Not treated
	if (notyet==0) notyet=min(sgvar:>0)
	
	sgvar=select(sgvar, ( (sgvar:>0) :* (sgvar:>min(stvar)) :* (sgvar:<=max(stvar)) ) )
	// delta time. Period Change
	aux = uniqrows(sgvar\stvar)
	
	delta=min(aux[2..length(aux)]:-
	          aux[1..length(aux)-1])
			  
	// recreate stvar
	stvar=range(min(stvar),max(stvar),delta)
	real matrix stvar2
	stvar2=stvar[2..length(stvar)]
	// fullgtvar
	// may not be necessary. And may be waste of space
	// except for names! 
	fgtvar=sgvar#J(rows(stvar2),1,1), J(rows(sgvar),1,stvar2)	
	//   fgtvar = gvar tvar : ATT(G,T)
	ogtvar=uniqrows((gvar,tvar),1)
	
	// Next ID all good fgtvar
	real matrix sel_gtvar
	sel_gtvar=nsample_select()		

	// Contents. 
	// gvar tvar t0   t1   te   y00 y01 y10 y11 sel
	// fgtvar   ,sel_gtvar      N               Select
	fgtvar = select((fgtvar,sel_gtvar),sel_gtvar[,cols(sel_gtvar)])
	convar = J(rows(fgtvar),1,0)
	// IDs all events into eventvar
	// uses short and long differences
	sevent()
	sevent=uniqrows(eventvar)
	sgvar=uniqrows(fgtvar[,1])
	stvar=uniqrows(fgtvar[,2])
}
// Define event for all FGTVAR
// IDS Event For Dynamic Effects
void csdid::sevent(){
	eventvar=J(rows(fgtvar),1,1)
	eventvar = fgtvar[,2]-fgtvar[,1]
	if (shortx==0) eventvar = fgtvar[,5]-fgtvar[,1]
	
}
//!asd
 
real matrix csdid::sample_select(real matrix gvtv) {
	// Cohort Never
	real matrix tsel, gsel
	real scalar gv, tv0, tv1,tv
	gv = gvtv[1]
	tv = gvtv[2]
	tv0 = gvtv[3]
	tv1 = gvtv[4]
	if (notyet==0) 	gsel = (gvar:==0        :| gvar:==gv)
	else {
		                          gsel = (gvar:==0 :| gvar:>max((gv,tv1)) :| gvar:==gv)
		if ((asinr==1) & (tv<gv)) gsel = (gvar:==0 :| gvar:>tv1           :| gvar:==gv)
	}
		/// time Selection
	if (rolljw==0)      tsel = (tvar:==tv0 :| tvar:==tv1)		
	else if (rolljw==1) tsel = (tvar:<=tv0 :| tvar:==tv1)		
	return(tsel:*gsel)
}

// Based on Summary, check if a particular combination is valid
real matrix csdid::nvalid(real matrix sgtvar, 
						  real scalar gv ){
	real scalar tv0, tv1
	tv0 = min(sgtvar[,2])
	tv1 = max(sgtvar[,2])
			
	return( sum(sgtvar[,3]:*(sgtvar[,1]:!=gv):*(sgtvar[,2]:==tv0)),
			sum(sgtvar[,3]:*(sgtvar[,1]:!=gv):*(sgtvar[,2]:==tv1)),
			sum(sgtvar[,3]:*(sgtvar[,1]:==gv):*(sgtvar[,2]:==tv0)),
			sum(sgtvar[,3]:*(sgtvar[,1]:==gv):*(sgtvar[,2]:==tv1)) )	
}

 
real matrix csdid::nsample_select() {
	real scalar i
	real matrix tsel, gsel, sgtvar
	real scalar gv, tv
	real matrix toreturn
	real matrix eftime
	toreturn = J(rows(fgtvar),7,0)
	// event
	eftime=J(1,2,0)
	
	// This is to determine Obs  
	for(i=1;i<=rows(fgtvar);i++){
		gv = fgtvar[i,1];tv = fgtvar[i,2]
		
		if (notyet==0) 	gsel = (ogtvar[,1]:==0    :| ogtvar[,1]:==gv)
		else {
										gsel = (ogtvar[,1]:==0 :| ogtvar[,1]:>max((gv,tv)) :| ogtvar[,1]:==gv)			
			if ((asinr==1) & (tv<gv)) 	gsel = (ogtvar[,1]:==0 :| ogtvar[,1]:>tv           :| ogtvar[,1]:==gv)
				
		}
		/// time Selection
		if (tv>=gv) {
				tsel = (ogtvar[,2]:==gv-delta :| ogtvar[,2]:==tv)
				///        T0      T1    T
				eftime=( gv-delta ,tv , tv) 
		}
		else {
			if (shortx==0 ) {
				tsel = (ogtvar[,2]:==gv-delta :| ogtvar[,2]:==tv-delta)
				///        T0         T1        T
				eftime=( tv-delta ,gv-delta, tv-delta ) 	
			}	
			else {
				tsel = (ogtvar[,2]:==tv-delta :| ogtvar[,2]:==tv)
				///        T0         T1       T     
				eftime=(tv-delta ,tv       , tv-delta)
			}
		}
		// Up to here we "select" sample
		// next, we need to see if sample is feasible based on numbers
		
		sgtvar = select(ogtvar ,tsel:*gsel)

		toreturn[i,] = eftime, nvalid(sgtvar,gv)
	}
	
	toreturn=toreturn,rowmin(toreturn:>0)
	 
	return(toreturn)
	// T is used for Event . Capture relative numbers.
	// Otherwise use t0 t1 fgtvar34
}
 
    
void csdid::csdid(){
 	//frif=oid,gvar,wvar
	class drdid scalar drdid
	real matrix smsel
	real scalar gv, tv, dots, i
	
	frwt=frif=J( ((type_data==1) ? max(oid) : rows(oid))	, 
	             rows(fgtvar),.)	
	stata("_dots 0") 
	drdid.rolljw=rolljw
	for(i=1;i<=rows(fgtvar);i++) {
		dots = 1
		drdid.init()
		
		smsel = sample_select(fgtvar[i,])
		gv = fgtvar[i,1]; tv = fgtvar[i,4]
		 
		///minn = min(fgtvar[i,6..9])
		drdid.yvar=select(yvar,smsel)
		if (cols(xvar)>0) drdid.xvar=select(xvar,smsel)
		drdid.tmt =select(tvar,smsel):==tv
		drdid.trt =select(gvar,smsel):==gv
		if (cols(wvar)>0) drdid.wvar=select(wvar,smsel)     
		drdid.id  =select(ivar,smsel)
		drdid.oid =select(oid ,smsel) 
		drdid.data_type   = type_data
		drdid.method_type = type_est 
		drdid.conv=1	
   		drdid.drdid()	
		
		/// Stores RIFS		
		if ((drdid.conv==1) &   sum(abs(drdid.rif))>0 )  {			
			convar[i,]=1
			if (shortx==0) frif[drdid.oid,i]=drdid.rif:*sign(eventvar[i]+.01)
			else           frif[drdid.oid,i]=drdid.rif 
			frwt[drdid.oid,i]=drdid.wtrt
		}
		dots = dots-convar[i,]
		stata(sprintf("_dots %f %f",i,dots))
	} 
	 
	/// fixes missing in rifs
	fixrif()		
	_editmissing(frwt,0)
	/// Extra clean up
	frwt   = select(frwt , convar')
	frif   = select(frif , convar')
	eventvar = select(eventvar, convar)
	fgtvar   = select(fgtvar , convar)
	convar = select(convar , convar)
	
	
	
	/// cleaning all else
	 ord=tvar=xvar=yvar=J(0,0,.)
	/// One Risk. Missing data after drdid or else.
	// if panel
	if (type_data==1) {
		real matrix aux 

		if (length(cvar)>0) aux = oid, gvar, wvar, cvar
			else 			aux = oid, gvar, wvar
		aux=uniqrows(aux)
		oid = aux[,1]
		gvar= aux[,2]
		wvar= aux[,3]
		if (length(cvar)>0) cvar= aux[,4]
	}
 
	/// Very last step. Sort important variables by Cvar?
	if (length(cvar)>0) {
		ord = order( (cvar,oid), (1,2) )
		oid  = oid[ord,]
		cvar = cvar[ord,]
		gvar = gvar[ord,]
		wvar = wvar[ord,]
		frif = frif[ord,]
		frwt = frwt[ord,]
	}	
	aux = J(0,0,.)
}

end             
