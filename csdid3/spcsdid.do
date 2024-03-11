mata
    mata clear
    class spcsdid {
        real matrix index
        void        attgt()
        real matrix attgt
   		real matrix wattgt		        
        real scalar mn_attgt, mn_wattgt
        real scalar gvar
        real scalar tvar
    }
    void spcsdid::attgt(real scalar row_rif, real matrix rif,| real matrix wgt){
        mn_attgt = mean(rif)
        attgt    = (rif:-mn_attgt)*(row_rif:/rows(rif))
        if (args()>2) {
            mn_wattgt  = sum(wgt)/row_rif
            wattgt     = wgt:-mn_wattgt
        }        
    }
    class caggte {
        real matrix aggte
        real scalar mn_aggte
    }

end

	//cnmiss = colnonmissing(frif)
	//mn_rif= colsum(frif):/cnmiss
 	//frif  = frif:-mn_rif
	//frif   = editmissing(frif,0)
	//frif   = mn_rif:+frif:*(rows(frif):/cnmiss)
    
mata
 x = runiform(10,5,1,2)
 dx = runiformint(10,5,1,3)
 dx = dx:!=1
 wx = runiformint(10,1,1,5)
 index = 1::10
 fx = x:*(dx)
 wwx = wx
 wx = wx:*(dx)
 fx = fx:*(fx:/fx)

 	cnmiss = colnonmissing(fx)
	mn_rif= colsum(fx):/cnmiss
 	fx= fx:-mn_rif
	fx= editmissing(fx,0)
	fx= mn_rif:+fx:*(rows(fx):/cnmiss)
 
 spcsdid =spcsdid(5)
 for(i=1;i<=5;i++){
     spcsdid[i].attgt(10,select(x[,i],dx[,i]),select(wwx,dx[,i]))
     spcsdid[i].index=(select(index,dx[,i]))
     //spcsdid[i].wattgt=select(wwx,dx[,i])
 }
end
 
mata
real matrix  aggte(real matrix rif,| real matrix wgt ) {
							   	
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
end
ss
mata
mata drop spaggte()

class caggte scalar spaggte(class csdid   matrix csdid   , 
                            class spcsdid matrix spcsdid , 
                            real matrix toselect ) {
 	// csdid contains the Index for spsdid
    // spsdid contains the RIFs
    
	real scalar mn_all, mn_wgt, mn_rif , ntoselect
    // How many Cols will be needed. Ideally less than FULL sample
    ntoselect = cols(toselect)
    mn_wgt = mn_rif = J(1,ntoselect,0)
    // over all toselect.
    for(i=1;i<=ntoselect;i++) {
        mn_wgt[,i] = spcsdid[i].mn_wattgt
        mn_rif[,i] = spcsdid[i].mn_attgt
    }   
    
	mn_all=mean(mn_rif',mn_wgt')
    // Stays as is
 	real matrix wgtw, attw
	wgtw = (mn_wgt ) :/sum(mn_wgt)
	attw = (mn_rif ) :/sum(mn_wgt)
    real matrix rr1
    rr1=J(10,1,0)
    //rr2=rr3 = J(10,1,0)
    for(i=1;i<=5;i++) {
        rr1[spcsdid[i].index] = rr1[spcsdid[i].index]:+ wgtw[i]:*(spcsdid[i].attgt    )
        arr2 = J(10,1,-spcsdid[i].mn_wattgt); 
        arr2[spcsdid[i].index] =(spcsdid[i].wattgt )
        rr1 = rr1 :+ arr2*(attw[i]:-(mn_all:/ sum(mn_wgt)))
    }
    //*
	// Aggregates into 1
    class caggte scalar toret
    toret.aggte = rr1
    toret.mn_aggte = mn_all
	return(toret)
}
spaggte(spcsdid)
end