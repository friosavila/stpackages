*! v1.3 Sparse CSDID
*! v1.2 Balance event
*! v1.1 Corrects Group SE
*! v1 Allows for anticipation
mata
class select_range {
	real matrix selgvar
	real matrix seltvar
	real matrix selevent
	real matrix selbal
}
//	mata drop estat
//	mata drop csdid_estat()
class caggte {
        real matrix aggte
        real scalar mn_aggte
}
	
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
    void pretrend2()
	// makes WB and the table for WB
	void mboot_any()
	void make_table()
	// void init only for testing
	void init()
	string matrix attgt_names()
	
	real matrix aggte()
    class caggte scalar spaggte()
    class caggte scalar spvaggte
	real matrix rtokens()
	real matrix select_data()
	real matrix wmult()
	real matrix iqrse()
	real scalar qtc()
	real matrix fixrif()
	
	real matrix erif, table
	real matrix bb, vv, sderr, bsmean
	string matrix onames
	// to be initialized
	real scalar t_stat
	// Required Info
	real scalar cilevel, bwtype, reps, max_mem, test_type, noavg
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
// !! STOPED here for sparse 
void csdid_estat::bvcv_clus(real matrix rif,
							class csdid scalar csdid) {
	real matrix ord, info, cvar
	bb  = mean(rif)
	nobs= rows(rif)	
	// sort	//ord  = order(cvar,1)	//rif = rif[ord,]	//cvar= cvar[ord,]
	// Standard Errors
	// cvar = csdid.cvar
	//[csdid.sortcvar,]
	//rif  = rif
	//[csdid.sortcvar,]
	
	// Consider Cleaning data based on Rows. How? Would it be more Time consuming?
	// need to do this at an earlier stage.
	// Smaller sample may have faster Run.
	info  = panelsetup(csdid.cvar,1)
	nclust= rows(info)	
	real matrix sumrif
	sumrif= panelsum(rif:-bb,info)
	vv    = quadcross(sumrif,sumrif):/(nobs^2)	
	// unsort	//rif =  rif[invorder(ord),]	//cvar= cvar[invorder(ord),]
}
 

real matrix csdid_estat::aggte(real matrix rif,| real matrix wgt ) {
							   	
	real matrix mn_all, mn_rif, mn_wgt, bwgt
	if (args()==2) {
		//wgt = J(1,cols(rif),1)	
        // Avg Effect
		bwgt = wgt:*(rif:!=.)
		fixrif(rif)
        mn_rif = mean(rif)
        mn_wgt = mean(bwgt)
        mn_all = sum(mn_rif:*mn_wgt):/sum(mn_wgt)
        // gets agg rif
        real matrix wgtw, attw
        wgtw = (mn_wgt ) :/sum(mn_wgt)
        attw = (mn_rif ) :/sum(mn_wgt)
        // r1 r2 r3
        real matrix r1 , r2 , r3
        r1   = (wgtw:*(rif :-mn_rif))
        r2   = (attw:*(bwgt :-mn_wgt ))
        r3   = (bwgt :- mn_wgt) :* (mn_all :/ sum(mn_wgt) )
        // Aggregates into 1
        return(rowsum(r1):+rowsum(r2):-rowsum(r3):+mn_all)    
    }
    else {
		fixrif(rif)
        mn_rif = mean(rif)
        mn_all = mean(mn_rif')
        // gets agg rif
        real matrix wgtw, attw
        attw = (mn_rif ) :/cols(mn_rif)
        // r1 r2 r3
        real matrix r1 , r2 , r3
        r1   = ((rif :-mn_rif):/cols(mn_rif))
        //r3   = (wgt :- mn_wgt) :* (mn_all :/ sum(mn_wgt) )
        // Aggregates into 1
        return(rowsum(r1):+mn_all)  
    }
}

// 

real matrix csdid_estat::spaggte(class csdid matrix csdid   , 
                                        real matrix toselect ) {
                                             
 	// csdid contains the Index for spsdid
    // spsdid contains the RIFs
    
	real scalar mn_all, mn_wgt, mn_rif , ntoselect
    // How many Cols will be needed. Ideally less than FULL sample
        
    ntoselect = cols(toselect)
    mn_wgt = mn_rif = J(1,ntoselect,0)
	if (length(csdid.wvar)>0) {
		// over all toselect.
		for(i=1;i<=ntoselect;i++) {
			mn_wgt[,i] = csdid.spcsdid[i].mn_wattgt
			mn_rif[,i] = csdid.spcsdid[i].mn_attgt
		}   
		
		mn_all=mean(mn_rif',mn_wgt')
		// Stays as is
		real matrix wgtw, attw
		wgtw = (mn_wgt ) :/sum(mn_wgt)
		attw = (mn_rif ) :/sum(mn_wgt)
		real matrix rr1
		
		rr1=J(csdid.nobs,1,0)
		//rr2=rr3 = J(10,1,0)
		for(i=1;i<=ntoselect;i++) {
			 rr1[csdid.spcsdid[i].index] = rr1[csdid.spcsdid[i].index]:+ wgtw[i]:*(csdid.spcsdid[i].attgt    )
			arr2                         = J(csdid.nobs , 1 , - csdid.spcsdid[i].mn_wattgt); 
			arr2[csdid.spcsdid[i].index] =  (csdid.spcsdid[i].wattgt )
			rr1 = rr1 :+ arr2*(attw[i]:-(mn_all:/ sum(mn_wgt)))
		}
		return(rr1:+mn_all)
	}
	else {
		
		for(i=1;i<=ntoselect;i++) {
		//	mn_wgt[,i] = csdid.spcsdid[i].mn_wattgt
			mn_rif[,i] = csdid.spcsdid[i].mn_attgt
		}   
		
		mn_all=mean(mn_rif')
		// Stays as is
		real matrix wgtw, attw
		attw = (mn_rif ) :/cols(mn_rif)
		real matrix rr1
		
		rr1=J(csdid.nobs,1,0)
		//rr2=rr3 = J(10,1,0)
		for(i=1;i<=ntoselect;i++) {
			 rr1[csdid.spcsdid[i].index] = rr1[csdid.spcsdid[i].index]:+ (1:/cols(mn_rif)):*(csdid.spcsdid[i].attgt    ) 
		}
		return(rr1:+mn_all)
	}
	
}
// Only for Weights (if needed)
real matrix csdid_estat::spwaggte(class csdid matrix csdid   , 
                                    real        matrix toselect ) {
 	real scalar ntoselect   
    ntoselect = cols(toselect)                                       
    real scalar i, mnrout
    real matrix rout
    rout = J(csdid.nobs,1,0)
    mnrout =0
    for(i=1;i<=ntoselect;i++){
        mnrout = mnrout+ csdid.spcsdid[i].mn_wattgt/ntoselect     
        rout[csdid.spcsdid[i].index] = rout[csdid.spcsdid[i].index] :+ (csdid.spcsdid[i].wattgt )/ntoselect     
    }    
    return(rout:+mnrout)
 }
                                    
    
// Will use Separate function for WB bc it process data differently 
void csdid_estat::atts_asym(class csdid scalar csdid){	
	// Estimate effects
	error = 0
	if (test_type==1) {
		// ATTGT		
		erif_attgt(csdid)
		//=select(csdid.frif,select_data(csdid)')		
		if (length(csdid.cvar)==0) {
			bvcv_asym(erif)
		}
		else {                       
			bvcv_clus(erif,csdid)
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
	
	t_stat =qtc( abs(bsmean:/serr) , cilevel )

	// bb are point estimates
	ci = (bb:-serr:*t_stat) \ (bb:+serr:*t_stat)
	 
	table = bb \ serr \ (bb:/serr) \ ci \ J(1,cols(bb),t_stat)
	bsmean=J(0,0,.)
	
}
// This fixes ERIF
void csdid_estat::fixrif(real matrix arif){
	real matrix mn_rif, rif2
	real scalar cnmiss
	cnmiss = colnonmissing(arif)
	mn_rif= colsum(arif):/cnmiss
 	arif  = arif:-mn_rif
	_editmissing(arif,0)
	arif   = mn_rif:+arif:*(rows(arif):/cnmiss)
}
// erif should have only the important ERIFs
// This Saves
void csdid_estat::erif_attgt(class csdid scalar csdid){
	
	if (csdid.sparse == 1) {
		// IF Sparse, then Reconstruct eRIF
		real matrix spind, tosel
		tosel = select_data(csdid)'
		spind = select(csdid.spindex,tosel)
		real scalar i 
		erif = J(rows(csdid.oid),length(spind),.)
		for(i=1;i<=length(spind);i++){
			erif[,i]=csdid.spcsdid[i].attgt[csdid.spcsdid[i].index,]
		}
		// 
		fixrif(erif)
	}
	else {
		// If not. Just get the data
		erif = select(csdid.frif,select_data(csdid)')				
	}	
}

void csdid_estat::atts_wboot(class csdid scalar csdid){ 
	// Estimate effects
	 if (test_type==1) {
		// ATTGT
		error=0
		erif_attgt(csdid)		 
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
		toreturn[1,i]=sprintf("g%f",sfgtvar[i,1]:+csdid.antici)
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
		nobs	= csdid.nobs

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
				// Anticip only affects how things look
				onames[iic+1,] = sprintf("g%f", csdid.sgvar[i]:+csdid.antici)
                if (csdid.sparse==1) {
                    aux   [,iic]   = spaggte(csdid,toselect)                    
                    if (length(csdid.wvar)>0) sumwgt[,iic]   = spwaggte(csdid,toselect)
                    // else equal weight
                }
                else {
                    aux_wgt      = select(csdid.frwt,toselect)			
                    aux   [,iic]   = aggte(select(csdid.frif,toselect),aux_wgt )                
                    sumwgt[,iic]   = rowsum(aux_wgt):/cols(aux_wgt)
                }
				//sumwgt[,iic]   = aggte(aux_wgt)
			}		
		}
		// Drop Zeroes
        sumwgt = sumwgt[,1..iic]
		aux    =    aux[,1..iic]
		onames = onames[1..iic+1,]
		//sumwgt = colsum(sumwgt)
        if (length(csdid.wvar)>0) erif= aggte(aux,sumwgt ), aux
        else                      erif= aggte(aux        ), aux
		// If request no AVG

		if (noavg==1) {
			erif   =  erif[.,2..cols(erif)]
			onames =onames[2..rows(onames),] 
		}
		
	}
	else {
		error=1
	}
}
  
////////////////////////////////////////////////////////////////////////////////
/// Calendaar Aggregations
////////////////////////////////////////////////////////////////////////////////
/// !!to do calendar

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
		nobs	  = csdid.nobs
		
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
                if (csdid.sparse==1) {
                    aux   [,iic]   = spaggte(csdid,toselect)                    
                    // if (length(csdid.wvar)>0) sumwgt[,iic]   = spwaggte(csdid,toselect)
                    // else equal weight
                }
                else {
                    aux_wgt      = select(csdid.frwt,toselect)			
                    aux   [,iic]   = aggte(select(csdid.frif,toselect),aux_wgt )                
                    //sumwgt[,iic]   = rowsum(aux_wgt):/cols(aux_wgt)
                }
                
				
				//sumwgt[i,]   = rowsum(aux_wgt):/cols(aux_wgt)
			}		
		}
		 
		//sumwgt = sumwgt[,1..iic]
		aux    =    aux[,1..iic]
		onames = onames[1..iic+1,]
		erif  = aggte(aux, J(1,cols(aux),1) ), aux
		// If request no AVG
		if (noavg==1) {
			erif   =  erif[.,2..cols(erif)]
			onames =onames[2..rows(onames),] 
		}
		
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
        if (csdid.sparse == 1) {
            // gets all RIFs 
            erif_attgt(csdid)
            if (length(csdid.cvar)==0) bvcv_asym(erif)
            else                       bvcv_clus(erif,csdid.cvar)
        }
        else 
            if (length(csdid.cvar)==0) bvcv_asym(select(csdid.frif,toselect))
            else                       bvcv_clus(select(csdid.frif,toselect),csdid.cvar)
        }    
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
// PTA On aggregated Data
void csdid_estat::pretrend2(class csdid scalar csdid ){
	// should be always drop v?
	real scalar df
	real matrix toselect,toselect0
	toselect0=select_data(csdid)'
	//:*csdid.convar'
	toselect=toselect0:*(csdid.eventvar :< 0)'
	error=0
	if (sum(toselect)>0) {        
        if (csdid.sparse == 1) {
            // gets all RIFs 
            erif_attgt(csdid)
            if (length(csdid.cvar)==0) bvcv_asym(erif)
            else                       bvcv_clus(erif,csdid.cvar)
        }
        else 
            if (length(csdid.cvar)==0) bvcv_asym(select(csdid.frif,toselect))
            else                       bvcv_clus(select(csdid.frif,toselect),csdid.cvar)
        }    
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
        if (sum(toselect)>0) {	
            erif  = spaggte(csdid,toselect)	
        }
        else {
            erif  = aggte(select(csdid.frif,toselect),select(csdid.frwt,toselect) )	
        }        		
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
		real matrix gg, selbal2
		// Get smaller event: This is to verify we have all "reasonable" events in the list
		gg = uniqrows(csdid.eventvar)
		selbal2 = J(1,0,0)
		for(i=1;i<=i4;i++){
			if ( sum(gg[,1]:==range.selbal[i]) == 1) {
				selbal2=selbal2,range.selbal[i]
                 
			}	
		}		
		i4 = length(selbal2)
		toselect4 =J(rws,1,0)
		for(i=1;i<=i4;i++){
			toselect4=toselect4:+(csdid.eventvar[,1]:==selbal2[i])
		}

		// select Ggroups
		  
		gg = select(csdid.fgtvar[,1],toselect4:>0)
		gg = uniqrows(gg,1) ;  gg=select(gg[,1],gg[,2]:==i4)
        
		// do gvar again
		toselect4 =J(rws,1,0)
		for(i=1;i<=length(gg);i++){
			toselect4=toselect4:+(csdid.fgtvar[,1]:==gg[i])
		}
        if (sum(toselect4)==0) {
            _error(123,"No observations after imposing balance")
 
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
				// For Two. One is for names. The other one for iim
				
				if ((csdid.sevent[i])<0) {
					iim = iim , 0					
				}
				else {					
					iim = iim , 1	
					
				}
				
				if ((csdid.sevent[i]:-csdid.antici)<0) {
					onames[iic,] = sprintf("tm%f", abs(csdid.sevent[i]:-csdid.antici))
				}
				else {
					onames[iic,] = sprintf("tp%f", abs(csdid.sevent[i]:-csdid.antici))
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
		real scalar col_erif
		col_erif=cols(erif)+1
		// erif
		erif  = erif, aux
 
		// If request no AVG
		if (noavg==1) {
			erif   =  erif[.,col_erif..cols(erif)]
			onames =onames[col_erif..rows(onames),] 
		}		
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
