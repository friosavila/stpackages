mata
mata clear
class itermean {
		void            setup()        		
		void            clear()    
		void            ind()
		void            info()
		void            ord()
		void			info_obs()
		
		real scalar 	nobs()
		real scalar 	fecols()
		
		 
		real matrix		demeanby_1pass()
		real matrix		demeanby()
		real matrix 	std()
		void 			write_info()
		void 			write_info_n()
		void 			write_mean()
		real matrix     read_info()
		real matrix     read_info_n()
		real matrix 	read_mean()
		
		real scalar 	max_sd()
		
		real matrix 	max_sd
		real matrix		yxs
		real matrix		wgt
		real matrix		fe
		real matrix		gmean
		
		real matrix		ord
		real matrix		ind
		struct info_type matrix info_k
		struct info_type matrix info_n
		struct info_type matrix mean_xy
		
		
		
		real scalar 	nobs, fecols
}

// Nobs in the sample
real scalar itermean::nobs(){
	if (nobs==.z) {
		nobs=rows(yxs)
	}
	return(nobs)
}

// # of cols ~ variables in FE
real scalar itermean::fecols(){
	if (fecols==.z) {
		fecols=cols(fe)
	}
	return(fecols)
}

// Clears data
void itermean::clear(){
		//yxs=
		//wgt=
		//fe=
		nobs=.z
		fecols=.z
		
}
// Setup -> get min info YXS, WGT (but), FE

void itermean::setup( 	string scalar syx, 
						string scalar swgt, 
						string scalar sfe, 
						string scalar touse ){
	clear()						
	st_view(yxs=.,.,syx,touse)
	st_view(wgt=.,.,swgt,touse)
	st_view(fe=.,.,sfe,touse) 
	gmean = mean(yxs,wgt)
	// variable with order
	mean_xy=info_type(fecols())
	
	
 
}
// order, based on all FE
void	itermean::ord() {
	real scalar i 
	ord   = J(nobs(),fecols(),0)
	for(i=1;i<=fecols;i++){
		ord[,i] = order(fe,i)
	}              		
}

// getting info one col at a time
void	itermean::info() {
	real scalar i
	//struct info_type scalar aux1
	info_k=info_type(fecols)	
    for(i=1;i<=fecols();i++){
		
		write_info( panelsetup(fe[ord[,i],],i),i )		
	}	
}

void itermean::info_obs() {
	real scalar i
	//aux = info_type()
	//struct info_type scalar aux1
	info_n=info_type(fecols)	
    for(i=1;i<=fecols();i++){
		write_info_n(  panelsum( wgt[ord[,i],] , read_info(i) ),i 	)		
	}	
}

// indicator of where it will go
void	itermean::ind() {
	real scalar i1 , i2
	real matrix info_here
	ind  = J(nobs(),fecols(),0)
	for(i1=1;i1<=fecols();i1++){
		info_here = read_info(i1)
 		for(i2=1;i2<=rows(info_here);i2++){			
			ind[|info_here[i2,]',(i1\i1)|] = J(1+info_here[i2,2]-info_here[i2,1],1,i2)		   
		}			
	}		
}

/// Strunctore for infotype because matrices can have different sizes
struct info_type {
	real matrix info
}

void itermean::write_info( real matrix inp, real scalar k){
	info_k[k].info=inp
}

void itermean::write_info_n( real matrix inp, real scalar k){
	info_n[k].info=inp
}
void itermean::write_mean( real matrix inp, real scalar k){
	mean_xy[k].info=inp
}
real matrix itermean::read_info( real scalar k){
	return(info_k[k].info)
}

real matrix itermean::read_info_n( real scalar k){
	return(info_n[k].info)
}
real matrix itermean::read_mean( real scalar k){
	return(mean_xy[k].info)
}
///
real scalar itermean::max_sd(){
	real scalar i
	max_sd=0
	for(i=1;i<=fecols();i++){
		max_sd=max( ( max_sd , std(read_mean(i)) ) ) 
	}
	return(max_sd)
}

real matrix itermean::std(real matrix obj){
	return(diagonal(variance(obj))')
}


real matrix	itermean::demeanby_1pass() {
 	real scalar i
	real matrix mns
	for(i=1;i<=fecols;i++){
		// sort
		yxs=yxs[ord[,i],]
		// check sorting for wgt. If none?
		wgt=wgt[ord[,i],]
		mns=panelsum(yxs,wgt ,read_info(i)):/read_info_n(i)
		write_mean(mns,i)
		yxs=yxs:-mns[ind[,i],]
		yxs=yxs[invorder(ord[,i]),]
		wgt=wgt[invorder(ord[,i]),]
	}
	
}

real matrix	itermean::demeanby() {
	demeanby_1pass()
 	while(max_sd()>1/2^25) {
		
		demeanby_1pass()
	}
	return(yxs:+gmean)
}

end
  
use cps_sample, clear
gen wt=1
sum lnwageh age union yrs_school sex wt yrm state ind occ

mata
sol = itermean()
sol.setup("lnwageh age union yrs_school sex","wt","age yrm state ind occ ","wt")
sol.ord()
sol.info()
sol.info_obs()
sol.ind()
xs = sol.demeanby()
sol = NULL
end
	
getmata xs*=xs
reg xs*	
  