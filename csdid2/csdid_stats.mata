mata
class select_range {
	real matrix selgvar
	real matrix seltvar
	real matrix selevent
	real matrix selbal
}
//	mata drop estat
//	mata drop csdid_estat()
	
class csdid_estat {
	// functions to create tables
	void bvcv_asym()
	void bvcv_clus()
	// Aggregatprs
	// void attgt()
	void atts_asym()
	void atts_wboot()
	void group_att()
	void calendar_att()
	void simple_att()
	void cevent_att()
	void event_att()
	void pretrend()
	// makes WB and the table for WB
	void mboot_any()
	void make_table()
	// void init only for testing
	void init()
	string matrix attgt_names()
	
	real matrix aggte()
	real matrix rtokens()
	real matrix select_data()
	real matrix wmult()
	real matrix iqrse()
	real scalar qtc()
	
	
	real matrix erif, table
	real matrix bb, vv, sderr, bsmean
	string matrix onames
	// to be initialized
	real scalar t_stat
	// Required Info
	real scalar cilevel, bwtype, reps, max_mem, test_type
	// info created
	real scalar nclust, nobs, ggroups, ccalendar, eevent, error
	// to transfer Range Info.
	class select_range scalar range
}

// Creates ASYM VCV
void csdid_estat::init() {
	cilevel = 0.95
	bwtype  = 1
	reps    = 999
	max_mem = 1
	test_type = 1
}
void  csdid_estat::bvcv_asym(real matrix rif) {	
		bb  = mean(rif)
		nobs= rows(rif)
		
		vv  = quadcrossdev(rif,bb, rif,bb) :/ (nobs^2) 
}
// Creates ASYM Cluster VCV
// Need to think how to Compress data when clustered
 
void csdid_estat::bvcv_clus(real matrix rif,
							real matrix cvar) {
	real matrix ord, info
	bb  = mean(rif)
	nobs= rows(rif)	
	// sort	//ord  = order(cvar,1)	//rif = rif[ord,]	//cvar= cvar[ord,]
	// Standard Errors
	info  = panelsetup(cvar,1)
	nclust= rows(info)	
	real matrix sumrif
	sumrif= panelsum(rif:-bb,info)
	vv    = quadcross(sumrif,sumrif):/(nobs^2)	
	// unsort	//rif =  rif[invorder(ord),]	//cvar= cvar[invorder(ord),]
}
 

real matrix csdid_estat::aggte(real matrix rif,| real matrix wgt ) {
							   	
	real matrix mn_all, mn_rif, mn_wgt
	if (args()==1) {
		wgt = J(1,cols(rif),1)
	}
	// Avg Effect
	mn_rif = mean(rif)
	mn_wgt = mean(wgt)
	mn_all = sum(mn_rif:*mn_wgt):/sum(mn_wgt)
	// gets agg rif
	real matrix wgtw, attw
	wgtw = (mn_wgt ) :/sum(mn_wgt)
	attw = (mn_rif ) :/sum(mn_wgt)
	// r1 r2 r3
	real matrix r1 , r2 , r3
	r1   = (wgtw:*(rif :-mn_rif))
	r2   = (attw:*(wgt :-mn_wgt ))
	r3   = (wgt :- mn_wgt) :* (mn_all :/ sum(mn_wgt) )
	// Aggregates into 1
	return(rowsum(r1):+rowsum(r2):-rowsum(r3):+mn_all)
}

    
// Will use Separate function for WB bc it process data differently 
void csdid_estat::atts_asym(class csdid scalar csdid){	
	// Estimate effects
	error = 0
	if (test_type==1) {
		// ATTGT		
		erif=select(csdid.frif,select_data(csdid)')		
		if (length(csdid.cvar)==0) {
			bvcv_asym(erif)
		}
		else {                       
			bvcv_clus(erif,csdid.cvar)
		}
		// names
		onames=attgt_names(csdid)'
	}
	else if (test_type==2) {
		//simple att
		simple_att(csdid)
		if (length(csdid.cvar)==0) bvcv_asym(erif)
		else                       bvcv_clus(erif,csdid.cvar)
		onames = J(rows(onames),1,""),onames
	}
	else if (test_type==3) {
		//group att
		group_att(csdid)
		if (length(csdid.cvar)==0) bvcv_asym(erif)
		else                       bvcv_clus(erif,csdid.cvar)
		onames = J(rows(onames),1,""),onames
	}
	else if (test_type==4) {
		//calendar att
		calendar_att(csdid)
		if (length(csdid.cvar)==0) bvcv_asym(erif)
		else                       bvcv_clus(erif,csdid.cvar)
		onames = J(rows(onames),1,""),onames
	}
	else if (test_type==5) {
		//event att
		event_att(csdid)
		if (length(csdid.cvar)==0) bvcv_asym(erif)
		else                       bvcv_clus(erif,csdid.cvar)
		onames = J(rows(onames),1,""),onames
	}
	else if (test_type==6) {
		//cevent att
		cevent_att(csdid)
		if (length(csdid.cvar)==0) bvcv_asym(erif)
		else                       bvcv_clus(erif,csdid.cvar)	
		onames = J(rows(onames),1,""),onames
	}
	
	if (error == 0) {
		st_matrix("_bb",bb)
		st_matrix("_vv",vv)
		st_matrixcolstripe("_bb", onames)
		st_matrixrowstripe("_vv", onames)
		st_matrixcolstripe("_vv", onames)
	}
	else {
		stata(`"display in red "There was an error estimating aggregation" "')
	}
	// drops vv, the largest matrix
	vv=0
	erif = 0
}
 
void csdid_estat::make_table(){
	real matrix serr
	real matrix ci
	// Standard error
	serr = iqrse(bsmean)
	// Critical value
	
	t_stat =qtc(bsmean:/serr, cilevel )

	// bb are point estimates
	ci = (bb:-serr:*t_stat) \ (bb:+serr:*t_stat)
	 
	table = bb \ serr \ (bb:/serr) \ ci \ J(1,cols(bb),t_stat)
	bsmean=J(0,0,.)
	
}

void csdid_estat::atts_wboot(class csdid scalar csdid){
 
	// Estimate effects
	 if (test_type==1) {
		// ATTGT
		error=0
		erif=select(csdid.frif,select_data(csdid)')		 
		onames=attgt_names(csdid)'	 
		mboot_any(csdid)	
		make_table()
		// names
 	}
	else if (test_type==2) {
		//simple att
		simple_att(csdid)
		onames = J(rows(onames),1,""),onames
		mboot_any(csdid)
		make_table()

	}
	else if (test_type==3) {
		//group att
		group_att(csdid)
		onames = J(rows(onames),1,""),onames
		mboot_any(csdid)
		make_table()
	}
	else if (test_type==4) {
		//calendar att
		calendar_att(csdid)
		onames = J(rows(onames),1,""),onames
		mboot_any(csdid)
		make_table()
	}
	else if (test_type==5) {
		//event att
		event_att(csdid)
		onames = J(rows(onames),1,""),onames
		mboot_any(csdid)
		make_table()		
	}
	else if (test_type==6) {
		//cevent att
		cevent_att(csdid)
		onames = J(rows(onames),1,""),onames
		mboot_any(csdid)
		make_table()		
	}
	
	if (error == 0) {
		string matrix xnames
		xnames =J(6,1,""),("b"\"se"\"t"\"ll"\"ul"\"crit")
		
		st_matrix("_table",table)
		st_matrixrowstripe("_table", xnames)
		st_matrixcolstripe("_table", onames)
	}
	else {
		stata(`"display in red "There was an error estimating aggregation" "')
	}
	// drops vv, the largest matrix
 }

   
string csdid_estat::attgt_names(class csdid scalar csdid){
	real scalar i
	string matrix toreturn
	real matrix sfgtvar
 
 	sfgtvar=select(csdid.fgtvar,select_data(csdid))
	toreturn=J(2,rows(sfgtvar),"")
	for(i=1;i<=cols(toreturn);i++){
		toreturn[1,i]=sprintf("g%f",sfgtvar[i,1])
		toreturn[2,i]=sprintf("t%f_%f",sfgtvar[i,3],sfgtvar[i,4])
	}
	return(toreturn)
}
  
real matrix csdid_estat::rtokens(string scalar totok){
	return(uniqrows(strtoreal(tokens(totok))' )')
}
////////////////////////////////////////////////////////////////////////////////
/// Group Aggregations
////////////////////////////////////////////////////////////////////////////////
  
void csdid_estat::group_att(class csdid scalar csdid ){
	// Counter i
	// kgroups (max)
	real scalar i , iic 
	real matrix toselect0,toselect, aux_rif, sumwgt
	real matrix aux_wgt, aux
	toselect0 =select_data(csdid)'
	//:*csdid.convar'
	error=0
	if (sum(toselect0)>0) {
		ggroups = rows(csdid.sgvar)
		nobs	= rows(csdid.frif)

		onames=J(ggroups+1,1,"")
		onames[1,]="GAverage"
		
		aux    =J(nobs,ggroups,.)
		sumwgt =J(nobs,ggroups,.)
		iic=0
		for(i=1;i<=ggroups;i++){
			// select 
			toselect=toselect0:*(csdid.fgtvar[,1]:==csdid.sgvar[i]:& csdid.eventvar:>=0)'
			if (sum(toselect)>0) {
				iic++
				// if any selected -> Estimate
				onames[iic+1,] = sprintf("g%f", csdid.sgvar[i])
				aux_wgt      = select(csdid.frwt,toselect)			
				aux   [,iic]   = aggte(select(csdid.frif,toselect),aux_wgt )
				sumwgt[,iic]   = rowsum(aux_wgt):/cols(aux_wgt)
			}		
		}
		// Drop Zeroes
		sumwgt = sumwgt[,1..iic]
		aux    =    aux[,1..iic]
		onames = onames[1..iic+1,]
		sumwgt = colsum(sumwgt)
		erif= aggte(aux,sumwgt ), aux
	}
	else {
		error=1
	}
}
  
////////////////////////////////////////////////////////////////////////////////
/// Calendaar Aggregations
////////////////////////////////////////////////////////////////////////////////
 
void csdid_estat::calendar_att(class csdid scalar csdid ){
	// Counter i
	// kgroups (max)
	real scalar i , iic 
	real matrix toselect0,toselect, aux_rif, sumwgt
	real matrix aux_wgt, aux
	
	toselect0 =select_data(csdid)'
	//:*csdid.convar'
 	error=0
	if (sum(toselect0)>0) {
		ccalendar = rows(csdid.stvar)
		nobs	  = rows(csdid.frif)
		
		onames=J(ccalendar+1,1,"")
		onames[1,]="TAverage"
		 
		aux    =J(nobs,ccalendar,.)
		//sumwgt =J(nobs,ccalendar,.)
		iic=0
		for(i=1;i<=ccalendar;i++){
			// select 
			toselect=toselect0:*(csdid.fgtvar[,2]:==csdid.stvar[i] :& csdid.eventvar:>=0)'
			
			if (sum(toselect)>0) {
				iic++
				// if any selected -> Estimate
				onames[iic+1,]  = sprintf("t%f", csdid.stvar[i])
				aux_wgt      = select(csdid.frwt,toselect)			
				aux   [,iic]   = aggte(select(csdid.frif,toselect),aux_wgt )
				//sumwgt[i,]   = rowsum(aux_wgt):/cols(aux_wgt)
			}		
		}
		 
		//sumwgt = sumwgt[,1..iic]
		aux    =    aux[,1..iic]
		onames = onames[1..iic+1,]
		erif  = aggte(aux, J(1,cols(aux),1) ), aux
	}
	else {
		error=1
	}
} 
 
void csdid_estat::pretrend(class csdid scalar csdid ){
	// should be always drop v?
	real scalar df
	real matrix toselect,toselect0
	toselect0=select_data(csdid)'
	//:*csdid.convar'
	toselect=toselect0:*(csdid.eventvar :< 0)'
	error=0
	if (sum(toselect)>0) {
		if (length(csdid.cvar)==0) bvcv_asym(select(csdid.frif,toselect))
		else                       bvcv_clus(select(csdid.frif,toselect),csdid.cvar)
		
		real scalar chi2
		chi2=bb*invsym(vv)*bb'
		df = cols(bb)
		// Drops V matrix
		vv=0
		st_numscalar("chi2_",chi2)
		st_numscalar("df_",df)
		st_numscalar("pchi2_",chi2tail(df,chi2))
	}
	else {
		error = 1
	}
} 

void csdid_estat::simple_att(class csdid scalar csdid ){
	real matrix toselect,toselect0
	// nobs	  = rows(csdid.frif)
	// Select based on some criteria
	toselect0 = select_data(csdid)'
	//:*csdid.convar'
	toselect  = toselect0:*(csdid.eventvar:>=0)'
	error = 0 
	if (sum(toselect)>0) {	
		onames = "SimpleATT"
		erif  = aggte(select(csdid.frif,toselect),select(csdid.frwt,toselect) )	
	}
	else {
		error = 1
	}
} 

real matrix csdid_estat::select_data(class csdid scalar csdid){
	real matrix toselect1,toselect2,toselect3,toselect4
	real scalar i, i1, i2, i3, i4
	real scalar rws
	// Can we adapt this to other?. Yes we should be able to!
	rws = rows(csdid.eventvar)
	toselect1 =toselect2=toselect3=toselect4= J(rws,1,1)
	i1=length(range.selgvar)
	i2=length(range.seltvar)
	i3=length(range.selevent)
	i4=length(range.selbal)
	 
	if (i1>0) {
		toselect1 =J(rws,1,0)
		for(i=1;i<=i1;i++){
			toselect1=toselect1:+(csdid.fgtvar[,1]:==range.selgvar[i])
		}
	}
	if (i2>0){
		toselect2 =J(rws,1,0)
		for(i=1;i<=i2;i++){
			toselect2=toselect2:+(csdid.fgtvar[,2]:==range.seltvar[i])
		}
	}
	if (i3>0){
		toselect3 =J(rws,1,0)
		for(i=1;i<=i3;i++){
			toselect3=toselect3:+(csdid.eventvar[,1]:==range.selevent[i])
		}
	}
	if (i4>0){
		toselect4 =J(rws,1,0)
		for(i=1;i<=i4;i++){
			toselect4=toselect4:+(csdid.eventvar[,1]:==range.selbal[i])
		}
		real matrix gg
		// select Ggroups
		 
		gg = select(csdid.fgtvar[,1],toselect4:>0)
		 
		gg = uniqrows(gg,1) ; gg=select(gg[,1],gg[,2]:==max(gg[,2]))
	 
		// do gvar again
		toselect1 =J(rws,1,0)
		for(i=1;i<=length(gg);i++){
			toselect1=toselect1:+(csdid.fgtvar[,1]:==gg[i])
		}
		
		if (i3>0) {
			toselect4=toselect3
		}
 
	}
	
	// tosel1 gvar
	// tosel2 tvar
	// tosel3 evar
	// tosel4 evar 
	// if rbalance ---> tsel4 event Balance & tsel1 group balance
	//              \-> But if tsel3 exist It trumps tsel4
		
	return( csdid.convar:* (toselect1:*toselect2:*toselect3:*toselect4):>0 )
}

void csdid_estat::cevent_att(class csdid scalar csdid ){
	real matrix toselect
	toselect = select_data(csdid)'
	error    = 0 
	if (sum(toselect)>0) {
		onames = "ATTC"
		erif   = aggte(select(csdid.frif,toselect),select(csdid.frwt,toselect) )	
	}
	else {
		error = 1
	}
} 

////////////////////////////////////////////////////////////////////////////////
/// event Aggregations
////////////////////////////////////////////////////////////////////////////////

void csdid_estat::event_att(class csdid scalar csdid){
	// Counter i
	// kgroups (max)
	real scalar i  , iic , ievent
	real matrix toselect,toselect0, aux_rif, sumwgt
	real matrix aux_wgt, iim
	real matrix aux_event, aux
	
	//
	toselect0=select_data(csdid)'
	error = 0
	if (sum(toselect0)>0) {
		ievent = 0
		aux_event=select(csdid.eventvar,toselect0')

		eevent = rows(csdid.sevent)
		nobs   = rows(csdid.frif)			
		onames=J(eevent+sum(csdid.sevent:>=0)+sum(csdid.sevent:< 0),1,"")
	
		// Is there a Pre or post		
		iic = 0
		if (sum(aux_event:<0 )) {
			iic++
			ievent++
			onames[iic,]="Pre_avg"
		}
		if (sum(aux_event:>=0)) {
			iic++
			ievent++
			onames[iic,]="Post_avg"	
		}		
		aux    =J(nobs,eevent,.)
 
	
		iim    =J(1,0,.)
		for(i=1;i<=eevent;i++){
			// select 
			toselect=toselect0:*(csdid.eventvar:==csdid.sevent[i])'
			
			if (sum(toselect)>0) {
				iic++
				// if any selected -> Estimate
				if (csdid.sevent[i]<0) {
					onames[iic,] = sprintf("tm%f", abs(csdid.sevent[i]))
					iim = iim , 0
					
				}
				else                   {
					onames[iic,] = sprintf("tp%f", abs(csdid.sevent[i]))
					iim = iim , 1	
					
				}
				
				aux_wgt   =       select(csdid.frwt,toselect)							
				aux[,iic-ievent]   = aggte(select(csdid.frif,toselect),aux_wgt )
				//sumwgt[i,]   = rowsum(aux_wgt):/cols(aux_wgt)

			}		
		}
		// drop zeroes

		aux    =    aux[,1..iic-ievent]
		onames =    onames[1..iic,]
		// iim ids pre and post effects
		erif =J(nobs,0,.)
		if (sum(iim:==0)) {
			erif =erif, aggte(select(aux,iim:==0) )
		}
		if (sum(iim:==1)) {
			erif =erif, aggte(select(aux,iim:==1) )
		}
		// erif
		erif  = erif, aux
	}
	else {
		error=1
	}	
} 

/// Auxiliary programs
// Gets the pth value of the rowmas matrix sent
// used to get t-critical for uniform matrix
real scalar csdid_estat::qtc(real matrix y, real scalar p){
	// idea. maximizar
    y  =rowmax(y)
	_sort(y,1)
	if ( p>0 & p<1) return(y[ ceil( (rows(y)+1)*p ) ])
	else if (p==0)  return(y[ 1               ])	 
	else if (p==1)  return(y[ rows(y)         ])	 
}

real matrix csdid_estat::iqrse(real matrix y) {
    real scalar q25,q75
	// saves q25 and q75
	q25=ceil(rows(y)*.25);q75=ceil(rows(y)*.75)
	real scalar j
	real matrix iqrs, sy
	iqrs=J(1,cols(y),0)
	
	for(j=1;j<=cols(y);j++){
	    sy=sort(y[,j],1)
		iqrs[,j]=(sy[q75,]-sy[q25,]):/(invnormal(.75)-invnormal(.25) )
	}
	return(iqrs)
}

real matrix csdid_estat::wmult(real scalar mdsize_eff) {
	real scalar  k1, k2
	k1=((1+sqrt(5))/(2*sqrt(5)))
	k2=0.5*(1+sqrt(5)) 
	
	if (bwtype==1)      return( k2:-sqrt(5)*rbinomial(nobs,mdsize_eff,1, k1) )  			
	else if (bwtype==2) return( 1 :-2*      rbinomial(nobs,mdsize_eff,1,0.5) )

}

 
void csdid_estat::mboot_any(class csdid scalar csdid ) {
	// RIF is FED from out. 
	real matrix mean_rif
	real scalar i, ncols, xnobs
	real scalar coord1
	real matrix ccrd
	//real matrix bsmean	
	// First Means	
	bb=mean_rif=mean(erif)
	// Re-estimate RIF
	erif = erif:-mean_rif
	// contains all iterations, for reps parameters
	ncols=cols(erif)
	xnobs=rows(erif)
	//
	
	bsmean=J(reps,ncols,0)
	// Options for cluster. 
	real matrix info
	if (length(csdid.cvar)>0) {
		info=panelsetup(csdid.cvar,1)
		erif= panelsum(erif,info)
	}
	
	nobs =rows(erif)

 	// check Repetitions and parameters
	// This is to use BLOCKS of Stuff. But not sure about how large it can be
	real scalar mdsize_eff, mdsize, mmax_mem
	// 134217728 <-- Total number of observations in 1gb of memory. We can select More
	// Need to initialize max men<- Global. MMaxmem local
	if (max_mem==0)  mmax_mem=134217728 
	else	         mmax_mem=max_mem*134217728  
	
 	mdsize = min( (reps, max( ( 1 , floor(mmax_mem/nobs/ncols) ) ) ) )
	 
	coord1=1
	mdsize_eff = mdsize
	
	for(i=1;i<=reps;i=i+mdsize){ 
		ccrd          = (coord1,1) \ ( coord1+mdsize_eff-1 ,ncols)
		coord1        = coord1+mdsize_eff
		bsmean[|ccrd|]= cross(erif, wmult(mdsize_eff))':/xnobs	
		mdsize_eff    = min( (mdsize, reps-(coord1-1)) ) 
	}
 	erif = J(0,0,.)
	//return(bsmean)
}

end
