use cps_sample, clear
mata mata clear

mata
	class info_fe {
		real matrix info
	}
	class mean_fe {
		real matrix mean
	}
	class hdfe {
		real matrix yx 
		real matrix fe
		real matrix wgt
		real matrix gm,std // grand mean
		real matrix n
		real matrix k
		real 		  matrix kfe
		real 		  matrix sortfe
		real matrix mean_k()
		class info_fe matrix info_fe
		//class mean_fe matrix mean_fe
		void readyx()
		void readfe()
		void readwg()
		void setup()
		void stxy()
		void recode_setupfe()
		void demean_1st()
		void demean()
	}
	void hdfe::readyx( string scalar yxvar ,| string scalar touse){
		yx = st_data(.,yxvar)
		
	}
	void hdfe::readfe( string scalar fevar ,| string scalar touse){
		fe = st_data(.,fevar)
	}
	void hdfe::readwg( string scalar  wvar ,| string scalar touse){
		wgt= st_data(.,wvar)
	}
	
	void hdfe::stxy(){
		gm = mean(yx)
		std= sqrt(mean( (yx:-gm):^2))
		yx = (yx:-gm):/std
		n  = rows(yx); k=cols(yx)
	}
	
	void hdfe::setup(){
		kfe = cols(fe)
		info_fe = info_fe(kfe)
		real scalar i 
		// sort index
 
		sortfe=J(n,kfe,.)
		for(i=1;i<=kfe;i++){
			sortfe[,i]=order(fe,i)
		}
		recode_setupfe()
 	}

	void hdfe::demean(){
		// first pass needs to check all FE
		demean_1st()
		// Second pass and beyond
		real scalar i,j
		
		real matrix mnx, sqx, sel
		real matrix cisel, isel, cyx
		
		// copies for Rang
		cyx  = J(rows(yx),cols(yx),.)
		// isel Index for Variables
		isel= range(1,cols(yx),1)'
		// cisel Copy of the index
		sqx=mean(yx:^2)
		
		
		for(j=k;j>0;j){
		// demean data	
 		
			for(i=1;i<=kfe;i++){
				
				mnx = mean_k(i)
				yx  = yx :- mnx[fe[,i],]			
			}
 
		// test if there is anything left to absorb
			
			mnx = mean(yx:^2)
			sel = abs(mnx-sqx):<epsilon(10000)
			if (sum(sel)>0) { 
 				cisel                 = select(isel,sel)
 				cyx[,cisel]           = select(yx,sel)
				yx                    = select(yx,!sel)
				isel 				  = select(isel,!sel)
				mnx					  = select(mnx,!sel)
				j = j-sum(sel)
			}
 
			//if (cols(sel)==0) j=1
			sqx = mnx
		}
		// recovering all
		yx = cyx :* std :+ gm
	}
	
	real matrix hdfe::mean_k(real scalar i){
		real matrix mnx
		mnx=panelsum(yx[sortfe[,i],],info_fe[i].info):/panelsum(J(n,1,1),info_fe[i].info)	
		return(mnx)
	}
	
	void hdfe::recode_setupfe(){
		real scalar i
		real matrix aux, idx
		for(i=1;i<=kfe;i++){
				aux=fe[sortfe[,i],i]
				idx = 1\(runningsum(aux[2..n,1]:!=aux[1..n-1,1]):+1)
				info_fe[i].info = panelsetup(idx,1)
				fe[,i] = idx[invorder(sortfe[,i])]
		}
	} 
 	 
	void hdfe::demean_1st(){
		real scalar i
		real matrix mean_sq
		class mean_fe matrix mean_fe
		mean_fe=mean_fe(kfe)
 
		mean_sq=J(kfe,k,.)
 
		for(i=1;i<=kfe;i++){
 
			mean_fe[i].mean   = panelsum(yx[sortfe[,i],],info_fe[i].info):/panelsum(J(n,1,1),info_fe[i].info) 
			mean_sq[i,]       = mean((yx - mean_fe[i].mean[fe[,i],]):^2)
			 
		}

		// which is best?
		real matrix best_fe, best_msq
		best_fe=J(1,k,0)
		best_msq=colmin(mean_sq)
		// lowest Diff

		for(i=1;i<=kfe;i++){
			best_fe=best_fe:+i*(mean_sq[i,]:==best_msq)			
		}

		real scalar best_i
 
  		real matrix amnx
		// Obtain first difference for all
  		for(i=1;i<=k;i++){
			best_i = best_fe[i]
		 
			amnx =mean_fe[best_i].mean[,i]
 
 			yx[,i] = yx[,i]:-amnx[fe[,best_i]]
		}
	}
	
 
end

mata:
hdfe=hdfe()
hdfe.readyx("x1 x2 x3 x4")
hdfe.readfe(" fe1 fe2 fe3 fe4 ")
hdfe.stxy()
hdfe.setup()

hdfe.demean()
xdm=hdfe.yx
hdfe.readyx("y")

hdfe.stxy()
hdfe.demean()
ydm=hdfe.yx
end

