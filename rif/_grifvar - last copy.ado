*! version 3.2 Agust 2021 Fernando Rios-Avila Quick fixed to iqratio. 
*! version 3.1 July 2021 Fernando Rios-Avila Quick fixed to CINDEX. 
* Indices are now faster. Just a bit slower than ado
* version 3. March 2021 Fernando Rios-Avila
* All translated to Mata
** Future Versions Cowel 2015
** Mean Deviation
** Pietra index
** Perhaps Half variance 
** Sen Sorrocks inequality
** ucs mcs
capture program drop _grifvar
program define _grifvar, sortpreserve
	version 8
	* Syntax sextion. Indicates what can be used and what cannot
	syntax newvarname =/exp [if] [in] ,  					///
	[, weight(varname) BY(varlist) 							/// This are options for allowing for sample weights and BY groups
	gini mean var cvar std q(str) iqr(str) kernel(str) bw(str)	/// Thes are options for basic RIFS See FFL(2018) Kernel and bw are optional.
	iqratio(str) ginismall q2(str) q3(str) iqr2(str) iqratio2(str)	/// This comes from Choe Van Kerm 2018, im also adding q2, as a better alternative than q when there are ties.
	glor(str) lor(str) ucs(str) iqsr(str) mcs(str)			/// This will contain the options from Essama-NssahLambert Lorenz Glorenz and IQRS (me?)
	pov(str) pline(str) watts(str) sen(str) tip(str) 		/// This will contain the options from Essama-NssahLambert  
	entropy(str) atkin(str) logvar   						/// This are RIFS from Cowell Flachaire (2007) There are other couple from Cowell 2015 
	agini giniold											/// This are RIFS from HEckley Gerdthan and Kjellson Only one that is rank independent
	acindex(str) cindex(str) 								/// This are RIFS from HEckley Gerdthan and Kjellson which are Rank Dependent
	eindex(str) arcindex(str) srindex(str) windex(str) ub(str) lb(str) seed(str) /// This are RIFS from Heckley Gerdthan and Kjellson  which are Rank Dependent and with additional information
	rifown(str) rifopt(str)]  
															/// hvarp and hvarn are semivariances or half variances implement by LOO
															/// ginismall better GINI for small samples undocumented
	** Data cleaning before syntax
	* This cleans the "exp" from paranthesis or spaces. Just handy
	local exp = regexr("`exp'", "\(", "")
	local exp = regexr("`exp'", "\)", "")
	local exp = regexr("`exp'", " ", "")
	
	tempvar touse 
	quietly {
		gen byte `touse'=0
		replace  `touse'=1 `if' `in' 
		if "`weight'"!="" {
			replace `touse'=0 if `weight'==.
		}
		if "`by'"!="" {
			replace `touse'=0 if `by'==.
		}
	   replace `touse'=0 if `exp'==.
	** This checks how many options have been selected	Only 1 option is allowed
	local d=("`gini'"!="")+("`ginismall'"!="")+("`mean'"!="")+("`var'"!="")+ ///
			("`std'"!="")+("`cvar'"!="")+("`q'"!="")+("`q2'"!="")+("`q3'"!="")+ ///
			("`iqr'"!="")+("`iqr2'"!="")+("`iqratio'"!="")+ ///
	        ("`glor'"!="")+("`lor'"!="")+("`ucs'"!="")+("`iqsr'"!="")+ ///
			("`mcs'"!="")+("`pov'"!="")+("`entropy'"!="")+("`atkin'"!="")+ /// 
			("`agini'"!="")+("`acindex'"!="")+("`cindex'"!="")+("`eindex'"!="")+ ///
			("`logvar'"!="")+("`giniold'"!="")+ ///
			("`watts'"!="")+("`sen'"!="")+("`tip'"!="")+("`arcindex'"!="")+ ///
			("`srindex'"!="")+("`windex'"!="")+("`rifown'"!="")
	
	if `d'>1  {
		display in red "Only one option allowed"
		error 1
	}
	if `d'==0 {
		display in red "Need to specify at least one option"
		error 1
	}
	** create weight
	if "`weight'"=="" {
		tempvar weight
		gen byte `weight'=1
	}
	** create by
	if "`by'"=="" {
	  tempvar by
	  gen byte `by'=1
	}
	else {
		 if `:word count `by''>1 {
		 	tempvar bys
			egen long `bys'=groups(`by')
			tempname by
			ren `bys' `by'
		 }
	}
	
	local sysseed=c(seed)
	
	if "`seed'"!="" {
		tempvar sortseed
		set seed `seed'
		qui:gen double `sortseed'=rnormal()
	}

	** This section will Test if the options are correctly specified. Right now only checks for poverty
	if "`pov'"!="" {
	   if "`pline'"=="" {
	   display "Requires to specify a poverty line (value or variable)"
	   error 1
	   }
	}
	
	**# RIF of Mean its the variable itself. Default option.
	else if ("`mean'"!="") {
		* uses default mean
		qui:gen `typlist' `varlist'=`exp' if `touse'
		label var `varlist' "RIF for Mean of `exp'"
	}
	
	**# RIF of variance
	else if "`var'"!="" {
		gen `typlist' `varlist' = .
		mata:rif_var("`exp' `weight' `by'", "`touse'","`varlist'")
		label var `varlist' "RIF for Var of `exp'"
	}
	
	**# RIF of quantile
	else if "`q'`q2'`q3'"!="" {
		numlist "`q'`q2'`q3'", min(1) max(1)  range(>0 <100)
		qui:gen `typlist' `varlist'=.
		if "`kernel'"=="" {
			// kernel gaussian
			local kernel gaussian
		}
		if "`bw'"!="" {
			numlist "`bw'", min(1) max(1) range(>=0)
		}
		else local bw 0
		
		     if "`kernel'"=="gaussian" 	local k=1
		else if "`kernel'"=="epan"   	local k=2
		else if "`kernel'"=="epan2" 	local k=3
		else if "`kernel'"=="biweight"  local k=4
		else if "`kernel'"=="cosine" 	local k=5
		else if "`kernel'"=="parzen"	local k=6
		else if "`kernel'"=="rectan" 	local k=7
		else if "`kernel'"=="triangle"	local k=8
		else if "`kernel'"=="triweight" local k=9	
		
			if "`q'"!="" {
			mata:rif_q("`exp' `weight' `by'", "`touse'","`varlist'",`q',`bw',`k')
		}
		else if "`q2'"!="" {
			mata:rif_q2("`exp' `weight' `by'", "`touse'","`varlist'",`q2',`bw',`k')
		}
		else if "`q3'"!="" {
			mata:rif_q3("`exp' `weight' `by'", "`touse'","`varlist'",`q3',`bw',`k')
		}
		
		local bbw=round(scalar(bbww),0.00001)
		label var `varlist' "RIF for q(`q'`q2'`q3') with kernel(`kernel') of `exp' with bw `bbw'" 
	 }

	**# RIF of IQR quantile
	** RIF for interquantile difference
	else if "`iqr'`iqr2'"!="" {
		qui:gen `typlist' `varlist'=.
		if "`kernel'"=="" {
			// kernel gaussian
			local kernel gaussian
		}
		if "`bw'"!="" {
			numlist "`bw'", min(1) max(1) range(>=0)
		}
		else local bw 0
		
			 if "`kernel'"=="gaussian" 	local k=1
		else if "`kernel'"=="epan"   	local k=2
		else if "`kernel'"=="epan2" 	local k=3
		else if "`kernel'"=="biweight"  local k=4
		else if "`kernel'"=="cosine" 	local k=5
		else if "`kernel'"=="parzen"	local k=6
		else if "`kernel'"=="rectan" 	local k=7
		else if "`kernel'"=="triangle"	local k=8
		else if "`kernel'"=="triweight" local k=9	
		
		numlist "`iqr'`iqr2'", min(2) max(2) sort range(>0 <100)
		local i0:word 1 of `r(numlist)'
		local i1:word 2 of `r(numlist)'
			
		  if  "`iqr'"!="" mata:rif_iqr("`exp' `weight' `by'", "`touse'","`varlist'",`i0',`i1',`bw',`k',1)
		else "`iqr2'"!="" mata:rif_iqr("`exp' `weight' `by'", "`touse'","`varlist'",`i0',`i1',`bw',`k',2)
		
		local bbw=round(scalar(bbww),0.00001)
		label var `varlist' "RIF for Interquantile difference(`i1' `i0') of `exp' with bw `bbw'"
	 }
	*** like IQR but allows for ties

	**# RIF for Gini, Perfect!
	else if "`gini'"!=""  {
		qui:gen `typlist' `varlist'=.
		mata:rif_gini("`exp' `weight' `by'", "`touse'","`varlist'")
		label var `varlist' "RIF for gini of `exp'"
	} 
	
	**# RIF for Coefficient of Variation
    ** Coefficient of variation. From Firpo and Pinto(2016)	. I ll set it here because its kind of the baby from FFL
	else if "`cvar'"!="" {
	  qui {
		qui:gen `typlist' `varlist'=.
		mata:rif_cvar("`exp' `weight' `by'", "`touse'","`varlist'")
		label var `varlist' "RIF for coefficient of variation of `exp'"
	 }
	}
	
	**# RIF standard deviation RIF. 
	else if "`std'"!="" {
	  qui {
		qui:gen `typlist' `varlist'=.
		mata:rif_std("`exp' `weight' `by'", "`touse'","`varlist'")
		label var `varlist' "RIF for Standard deviation of `exp'"
	  }
	}
	** This one is from Choe Van Kerm
	**# Interquartile Ratio 
	else if "`iqratio'`iqratio2'"!="" {
		qui:gen `typlist' `varlist'=.
		if "`kernel'"=="" {
			// kernel gaussian
			local kernel gaussian
		}
		if "`bw'"!="" {
			numlist "`bw'", min(1) max(1) range(>=0)
		}
		else local bw 0
			 if "`kernel'"=="gaussian" 	local k=1
		else if "`kernel'"=="epan"   	local k=2
		else if "`kernel'"=="epan2" 	local k=3
		else if "`kernel'"=="biweight"  local k=4
		else if "`kernel'"=="cosine" 	local k=5
		else if "`kernel'"=="parzen"	local k=6
		else if "`kernel'"=="rectan" 	local k=7
		else if "`kernel'"=="triangle"	local k=8
		else if "`kernel'"=="triweight" local k=9	
		
		numlist "`iqratio'`iqratio2'", min(2) max(2) sort range(>0 <100)
		local i0:word 1 of `r(numlist)'
		local i1:word 2 of `r(numlist)'
			
		  if  "`iqratio'"!="" mata: rif_iqratio("`exp' `weight' `by'", "`touse'","`varlist'",`i0',`i1',`bw',`k')
		else "`iqratio2'"!="" mata:rif_iqratio2("`exp' `weight' `by'", "`touse'","`varlist'",`i0',`i1',`bw',`k')
		
		local bbw=round(scalar(bbww),0.00001)
	    label var `varlist' "RIF for Inter quantile ratio(`i1' `i0') of `exp'"
	 }
	 
	** From here on it follows ESSANNA Lambert 
	**# RIF for Glorenz  
	else if "`glor'"!="" {
		qui:gen `typlist' `varlist'=.
		numlist "`glor'", min(1) max(1)  range(>0 <100)
		mata:rif_glor("`exp' `weight' `by'", "`touse'","`varlist'",`glor')
		label var `varlist' "RIF for Glorenz ordinate at p(`glor') of `exp'"
	}
	**# RIF lorenz 
	else if "`lor'"!="" {
		qui:gen `typlist' `varlist'=.
		numlist "`lor'", min(1) max(1)  range(>0 <100)
		mata:rif_lor("`exp' `weight' `by'", "`touse'","`varlist'",`lor')
		label var `varlist' "RIF for Lorenz ordinate at p(`lor') of `exp'"
	}
	**# RIF 1-lorenz. Upper lorenz?
    else if "`ucs'"!="" {
		numlist "`ucs'", min(1) max(1)  range(>0 <100)
		qui:gen `typlist' `varlist'=.
		mata:rif_ucs("`exp' `weight' `by'", "`touse'","`varlist'",`ucs')
		label var `varlist' "RIF for Upper class share: 1-Lorenz ordinate at p(`ucs') of `exp'"
	}
	**# RIF iqrs UP/Low
	else if "`iqsr'"!="" {
		qui:gen `typlist' `varlist'=.
		numlist "`iqsr'", min(2) max(2) sort range(>0 <100)
		local i0:word 1 of `r(numlist)'
		local i1:word 2 of `r(numlist)'
		mata:rif_iqsr("`exp' `weight' `by'", "`touse'","`varlist'",`i0',`i1')
		label var `varlist' "RIF for IQSR p(`i0' `i1') of `exp'"
	}
	********************************
	**# MIddle class share Between Qs
	else if "`mcs'"!="" {
		qui:gen `typlist' `varlist'=.
		numlist "`mcs'", min(2) max(2) sort range(>0 <100)
		local i0:word 1 of `r(numlist)'
		local i1:word 2 of `r(numlist)'
		mata:rif_mcs("`exp' `weight' `by'", "`touse'","`varlist'",`i0',`i1')
	    label var `varlist' "RIF for Middle class share at p(`i0' `i1') of `exp'"
	}
	**# RIF poverty. Flexible to admit any value for pov (0 headcount 1 poverty gap 2 poverty severity)
	if "`pov'"!="" & "`pline'"!=""  {
		** can also use either a fixed poverty line or a variable poverty line
		numlist "`pov'", min(1) max(1)  range(>=0 )
		tempvar ppline
		gen double `ppline'=`pline'
		replace `touse'=0 if `ppline'==.
		gen `typlist' `varlist'=.
		mata:rif_pov("`exp' `weight' `by' `ppline'", "`touse'","`varlist'",`pov')
		label var `varlist' "RIF for FGT poverty with alpha=`pov' and pline:`pline' of `exp'"
	}	
	* Other ESSAMMA indices
	**# watts poverty index can be used with different poverty measures. So assume for now its either a variable or number
	else if "`watts'"!="" {
		gen `typlist' `varlist'=ln(`watts'/`exp')*(`watts'>=`exp')
		label var `varlist' "RIF for Watts poverty index of `exp'"
	}
	**# Sen index
	else if "`sen'"!="" {
		gen `typlist' `varlist'=.
		mata:rif_sen("`exp' `weight' `by' ", "`touse'","`varlist'",`sen')
		label var `varlist' "RIF for Sen poverty index of `exp'"
	}
	*TIP curves for poverty line z at ordinate p
	**#tip(p) pov()
	else if "`tip'"!="" {
		*assuming excludes 0 - 100
		numlist "`tip'", min(1) max(1)  range(>0 <100)
		if "`pline'"=="" {
			noisily display "Requires to specify a poverty line using pline() option"
			error 1
		}
		numlist "`pline'", min(1) max(1)  range(>0)
		gen `typlist' `varlist'=.
		mata:rif_tip("`exp' `weight' `by' ", "`touse'","`varlist'",`tip',`pline')
		label var `varlist' "TIP curve at `tip' nad pline `pline'"
	}
	** Pro poorness statistics seem not to be adequate here. It requires to estimate growth by quantiles, and not clear how is that done.
	** From here on we follow Cawley Flechaire 2007
	**# Entropy Index
	else if "`entropy'"!="" {
		numlist "`entropy'", min(1) max(1)  
		gen `typlist' `varlist'=.
		mata:rif_entropy("`exp' `weight' `by'", "`touse'","`varlist'",`entropy')
		label var `varlist' "RIF for Entropy alpha=`entropy' of `exp'"
	}
	**# Atkinson
	else if "`atkin'"!="" {
		numlist "`atkin'", min(1) max(1) range(>0) 
		gen `typlist' `varlist'=.
		mata:rif_atkin("`exp' `weight' `by'", "`touse'","`varlist'",`atkin')
		label var `varlist' "RIF for Atkinson e=`atkin' of `exp'"
	}
	**# Logaritmic variance
	* different from variance of logs
	else if "`logvar'"!="" {
		gen `typlist' `varlist'=.
		mata:rif_logvar("`exp' `weight' `by'", "`touse'","`varlist'")
		label var `varlist' "RIF for logvariance of `exp'"
	}
	* From here we get the indices added by Heckley Gerdthan and Kjellson
	**# Absolute Gini
	else if "`agini'"!="" {
		gen `typlist' `varlist'=.     
		mata:rif_agini("`exp' `weight' `by'", "`touse'","`varlist'")
		label var `varlist' "RIF for Abs gini of `exp'"
	}
	**# Absolute Concentration index
	else if "`acindex'"!="" {
		tempvar nexp v1 v2
		qui:gen double `v1'=.
		qui:gen double `v2'=.
		gen double `nexp'=-`exp'
		
		mata:rif_acindex("`exp' `weight' `by' `acindex' `exp'", "`touse'","`v1'")
		mata:rif_acindex("`exp' `weight' `by' `acindex' `nexp'", "`touse'","`v2'")
		gen `typlist' `varlist'=0.5*(`v1'+`v2')
		label var `varlist' "RIF for Abs concentration of `exp'"
	}
	**#   Concentration index (Standard)
	else if "`cindex'"!="" {
		tempvar nexp v1 v2
		qui:gen double `v1'=.
		qui:gen double `v2'=.
		gen double  `nexp'=-`exp'
		mata:rif_cindex("`exp' `weight' `by' `cindex' `exp'", "`touse'","`v1'")
		mata:rif_cindex("`exp' `weight' `by' `cindex' `nexp'", "`touse'","`v2'")
		gen `typlist' `varlist'=0.5*(`v1'+`v2')
		label var `varlist' "RIF for Concentration index of `exp'"
	}
	**# eindex specifies the Erreygers index
	else if "`eindex'"!="" {
		numlist "`lb' `ub'", min(2) max(2) ascending 
		tempvar nexp v1 v2
		qui:gen double `v1'=.
		qui:gen double `v2'=.
		gen double  `nexp'=-`exp'
		mata:rif_eindex("`exp' `weight' `by' `eindex' `exp'", "`touse'","`v1'",`lb',`ub')
		mata:rif_eindex("`exp' `weight' `by' `eindex' `nexp'", "`touse'","`v2'",`lb',`ub')
		gen `typlist' `varlist'=0.5*(`v1'+`v2')
	    label var `varlist' "RIF for Erreygers index of `exp'"
	}
	**# Attainment Relative Concentration Index
	else if "`arcindex'"!="" {
		numlist "`lb'", min(1) max(1)
		tempvar nexp v1 v2
		qui:gen double `v1'=.
		qui:gen double `v2'=.
		gen double  `nexp'=-`exp'
		mata:rif_arcindex("`exp' `weight' `by' `arcindex' `exp'", "`touse'","`v1'",`lb')
		mata:rif_arcindex("`exp' `weight' `by' `arcindex' `nexp'", "`touse'","`v2'",`lb')
		gen `typlist' `varlist'=0.5*(`v1'+`v2')
		label var `varlist' "RIF for Attainment Relative Concentration of `exp'" 
	}
	**# Shortfall relative concentration index
 	else if "`srindex'"!="" {
		numlist "`ub'", min(1) max(1)
		tempvar nexp v1 v2
		qui:gen double `v1'=.
		qui:gen double `v2'=.
		gen double  `nexp'=-`exp'
		mata:rif_srindex("`exp' `weight' `by' `srindex' `exp'" , "`touse'","`v1'",`ub')
		mata:rif_srindex("`exp' `weight' `by' `srindex' `nexp'", "`touse'","`v2'",`ub')
		gen `typlist' `varlist'=0.5*(`v1'+`v2')
		label var `varlist' "RIF for Shortfall Rel concentration index of `exp' ul= `ub'"
	}
	**# Wagstaff index
	else if "`windex'"!="" {
		numlist "`lb' `ub'", min(2) max(2) ascending 
		tempvar nexp v1 v2
		qui:gen double `v1'=.
		qui:gen double `v2'=.
		gen double  `nexp'=-`exp'
		mata:rif_windex("`exp' `weight' `by' `windex' `exp'", "`touse'","`v1'",`lb',`ub')
		mata:rif_windex("`exp' `weight' `by' `windex' `nexp'", "`touse'","`v2'",`lb',`ub')
		gen `typlist' `varlist'=0.5*(`v1'+`v2')
		label var `varlist' "RIF for Wagstaff index of `exp' with ll =`lb' and ul= `ub'"
	}
	   	
	**# Alternative rifown rifown
	else if "`rifown'"!="" {
		** Alternative User written RIFS"
		sort `touse' `by' `exp' `sortseed'
		by `touse' `by':egen `typlist' `varlist'=`rifown'(`exp'), weight(`weight') `rifopt'
	}
 
  }
  
	
  set seed `sysseed'
  
end
  
********************************************************************************
**# Mata part

mata:

//this one makes the RIF
void rif_var(string scalar ywb, touse,newvar) {
    // prepares
    ywby=st_data(.,ywb,touse)
	//  y w by, Outcome weight by
	ord1=order(ywby,(3,1))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)
	// estimates RIF
    rif=J(rows(ywby),1,0)
	for(i=1;i<=rows(info);i++){
	    aux = panelsubmatrix((ywby), i, (info))
		rif[|(info)[i,1],1 \  (info)[i,2],1|] =
		(aux[,1]:-mean(aux[,1],aux[,2])):^2
	}
	
	st_store(.,newvar,touse,rif[invorder(ord1),])
}

//qtile
 
void rif_q(string scalar ywb,touse,newvar, real scalar q, bw, k ) {
     // prepares
    ywby=st_data(.,ywb,touse)
	//  y w by, Outcome weight by
	ord1=order(ywby,(3,1))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)
	
	// estimates RIF
    rif=J(rows(ywby),1,0)
	for(i=1;i<=rows(info);i++){
	    //prep
	    aux = panelsubmatrix(ywby, i, info)
		//aux=aux 
		//k type of kernel
		qth=qtile(&aux,q)
 		rif[|info[i,1],1 \ info[i,2],1|] =
		qth:+ (-(aux[,1]:<qth):+q/100):/  mean( qden(&aux,qth,bw,k) , aux[,2] )

	}
	st_store(.,newvar,touse,rif[invorder(ord1),])
	st_numscalar("bbww",bw)
}
 
/// q2

void rif_q2(string scalar ywb,touse,newvar, real scalar q, bw, k ) {
     // prepares
    ywby=st_data(.,ywb,touse)
	//  y w by, Outcome weight by
	ord1=order(ywby,(3,1))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)
	
	// estimates RIF
    rif=J(rows(ywby),1,0)
	for(i=1;i<=rows(info);i++){
	    //prep
	    aux = panelsubmatrix(ywby, i, info)
		
		//k type of kernel
		qth=qtile(&aux,q)
		rif[|info[i,1],1 \ info[i,2],1|] = 
		qth:+ (aux[,1]!=qth):* (-(aux[,1]:<qth):+q/100):/ mean(qden(&aux,qth,bw,k),aux[,2])

	}
	st_store(.,newvar,touse,rif[invorder(ord1),])
	st_numscalar("bbww",bw)
}
 
 
void rif_q3(string scalar ywb,touse,newvar, real scalar q, bw, k ) {
     // prepares
    ywby=st_data(.,ywb,touse)
	//  y w by, Outcome weight by
	ord1=order(ywby,(3,1))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)
	
	// estimates RIF
    rif=J(rows(ywby),1,0)
	for(i=1;i<=rows(info);i++){
	    //prep
	    aux = panelsubmatrix(ywby, i, info)
		//aux=aux 
		//k type of kernel		
		qth=qtile(&aux,q)
		qden(&aux,qth,bw,k)
 		aux2 = qth:+ (-(aux[,1]:<qth):+q/100):/ mean( qden(&aux,qth,bw,k) , aux[,2] )
		
		rif[|info[i,1],1 \ info[i,2],1|] = aux2:- mean( aux2 , aux[,2] ):+ qth
	}
	st_store(.,newvar,touse,rif[invorder(ord1),])
	st_numscalar("bbww",bw)
}
 

//Qvalue

	real scalar qtile( pointer matrix y , real scalar q) {
		x=y[1]
		p=quadrunningsum((*x)[,2]):/quadsum((*x)[,2])*100
		pp=max((1::rows(*x)):*(p:<=q))
	/// pp is the higest PP less or equal than q
		if (p[pp,]==q) qq=((*x)[pp,1]+(*x)[pp+1,1])/2
		else qq=((*x)[pp+1,1])
		return(qq)
	}
	
//Qdensity	

	real matrix qden(pointer matrix y , real scalar q,bw,k) {
	    if (bw==0) {
			//nobs=rows((*y)[,1])
				 if (k==1) d=(1/(4*pi()))^.1
			else if (k==2) d=(3/(5*sqrt(5)))^(1/5)
			else if (k==3) d=15^.2
			else if (k==4) d=35^.2
			else if (k==5) d=(6/(1/6-1/pi()^2)^2)^.2
			else if (k==6) d=2*(151/35)^.2
			else if (k==7) d=(9/2)^.2
			else if (k==8) d=24^.2
			else if (k==9) d=(9450/143)^.2
			bw = 1.3643*d*rows((*y)[,1])^(-.2)*min( (  sqrt(variance((*y)[,1], (*y)[,2])) , (qtile(y,75)-qtile(y,25))/ (invnormal(.75)-invnormal(.25))  ) ) 
			//    cons *d*Nobs   ^(-1/5) * min (IQR,SD)
		}
	    z=((*y)[,1]:-q):/bw
			 if (k==1)  fden=normalden(z)
		else if (k==2)  fden=3/4*1/sqrt(5)*(-1/5*z:^2:+1):*(abs(z):<=sqrt(5))
		else if (k==3)  fden=3/4*(-(z:^2):+1)     :*(abs(z):<=sqrt(1))
		else if (k==4)  fden=15/16*((-z:^2:+1):^2):*(abs(z):<=1) 
		else if (k==5)  fden=(cos(2*pi():*z):+1)    :*(abs(z):<=0.5) 
		else if (k==6)  {
			fden=(4/3-8*z:^2+8*abs(z):^3):* (abs(z):<=0.5) 
			fden=fden+(8/3*(1-abs(z)):^3):*((abs(z):> 0.5) & (abs(z):<=1))
		} 
		else if (k==7)  fden=1/2*(abs(z):<=1)
		else if (k==8)  fden=(-abs(z):+1)  :*(abs(z):<=1)
		else if (k==9)  fden=35/32*((-z:^2:+1):^3):*(abs(z)<=1) 
		return(fden:/bw)
 
	}
 
void rif_iqr(string scalar ywb,touse,newvar, real scalar q1,q2, bw, k , t ) {
     // prepares
    ywby=st_data(.,ywb,touse)
	//  y w by, Outcome weight by
	ord1=order(ywby,(3,1))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)
	
	// estimates RIF
    rif=J(rows(ywby),1,0)
	for(i=1;i<=rows(info);i++){
	    //prep
	    aux = panelsubmatrix(ywby, i, info)
		//aux=aux,(1::rows(aux))
		//k type of kernel
		qth1=qtile(&aux,q1)
		qth2=qtile(&aux,q2)
		
		if (bw==0) {
			nobs=rows(aux[,1])
				 if (k==1) d=(1/(4*pi()))^.1
			else if (k==2) d=(3/(5*sqrt(5)))^(1/5)
			else if (k==3) d=15^.2
			else if (k==4) d=35^.2
			else if (k==5) d=(6/(1/6-1/pi()^2)^2)^.2
			else if (k==6) d=2*(151/35)^.2
			else if (k==7) d=(9/2)^.2
			else if (k==8) d=24^.2
			else if (k==9) d=(9450/143)^.2
			bwx = 1.3643*d*nobs^-.2*min( (sqrt(variance(aux[,1], aux[,2])), (qtile(&aux,75)-qtile(&aux,25))/1.349) )
			
		}
		
		if (t==1) {
			rif[|info[i,1],1 \ info[i,2],1|] = 
			qth2:+ (aux[,1]!=qth2):*(-(aux[,1]:<qth2):+q2/100):/mean(qden(&aux,qth2,bwx,k),aux[,2]):- 
		   (qth1:+ (aux[,1]!=qth1):*(-(aux[,1]:<qth1):+q1/100):/mean(qden(&aux,qth1,bwx,k),aux[,2]))
		}
		else if (t==2) {
			rif[|info[i,1],1 \ info[i,2],1|] = 
			qth2:+ (aux[,1]!=qth2):*(aux[,1]!=qth2):*(-(aux[,1]:<qth2):+q2/100):/mean(qden(&aux,qth2,bwx,k),aux[,2]):- 
		   (qth1:+ (aux[,1]!=qth1):*(aux[,1]!=qth1):*(-(aux[,1]:<qth1):+q1/100):/mean(qden(&aux,qth1,bwx,k),aux[,2]))
		}
	}
	st_store(.,newvar,touse,rif[invorder(ord1),])
	st_numscalar("bbww",bw)
}	
 

void rif_gini(string scalar ywb,touse,newvar) {
    // prepares
    ywby=st_data(.,ywb,touse)
	//  y w by, Outcome weight by
	ord1=order(ywby,(3,1,2))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)
	// estimates RIF
    rif=J(rows(ywby),1,0)	
	
	for(i=1;i<=rows(info);i++){
		aux = panelsubmatrix(ywby, i, info)
		nn  = rows(aux)
		awgt= aux[,2]/mean(aux[,2])
 		sumw= runningsum( awgt )
		// v1 mean v2 rank v3 cov
		v1  = runningsum(aux[,1]:*awgt/nn)
		//info2=panelsetup(aux, 1)
		v2=(sumw:-0.5*awgt):/nn
		//for cov
		v3=	runningsum( (aux[,1]:- v1[nn]):*(v2:-.5):* awgt:/nn)
 
		//instead of int
		rf=0.5*v1[nn]-v3[nn]
		//regular rank
		pvar=sumw:/nn
		// RIF
		rif[|(info)[i,1],1 \  (info)[i,2],1|]=
		   (2/v1[nn]*rf):*aux[,1]:/v1[nn]:+2/v1[nn]:*(aux[,1]:*(pvar:-1):-v1):+1
		//(2/`mns'*`rf')*`exp'/`mns'+2/`mns'*(`exp'*(`pvar'-1)-`glp') +1
 	}
	st_store(.,newvar,touse,rif[invorder(ord1),])
}	


void rif_cvar(string scalar ywb,touse,newvar) {
    // prepares
    ywby=st_data(.,ywb,touse)
	//  y w by, Outcome weight by
	ord1=order(ywby,(3,1,2))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)
	// estimates RIF
    rif=J(rows(ywby),1,0)	
	for(i=1;i<=rows(info);i++){
	    aux = panelsubmatrix(ywby, i, info)
		nn  = rows(aux)
		mns   = mean(aux[,1], aux[,2] )
		mnssq = mean(aux[,1]:^2, aux[,2] )
		
		rif[|(info)[i,1],1 \  (info)[i,2],1|]=
		(mnssq-mns^2)^0.5/mns:+1/2*((aux[,1]:-mns):^2:-(mnssq-mns^2)):/
		(mns*(mnssq-mns^2)^.5):-(aux[,1]:-mns):*((mnssq-mns^2)^.5/(mns^2))
 	}
	st_store(.,newvar,touse,rif[invorder(ord1),])
	
}		 


void rif_std(string scalar ywb,touse,newvar) {
    // prepares
    ywby=st_data(.,ywb,touse)
	//  y w by, Outcome weight by
	ord1=order(ywby,(3,1,2))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)
	// estimates RIF
    rif=J(rows(ywby),1,0)	
	for(i=1;i<=rows(info);i++){
	    aux = panelsubmatrix(ywby, i, info)
		mns   = mean(aux[,1], aux[,2] )
		mnssq = mean(aux[,1]:^2, aux[,2] )
		rif[|(info)[i,1],1 \  (info)[i,2],1|]=
		(mnssq-mns^2)^0.5:+ 1/2*((aux[,1]:-mns):^2:-(mnssq-mns^2)):/((mnssq-mns^2)^.5)
 	}
	st_store(.,newvar,touse,rif[invorder(ord1),])
}		


void rif_iqratio(string scalar ywb,touse,newvar, real scalar q1,q2, bw, k ) {
     // prepares
    ywby=st_data(.,ywb,touse)
	//  y w by, Outcome weight by
	ord1=order(ywby,(3,1))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)
	
	// estimates RIF
    rif=J(rows(ywby),1,0)
	for(i=1;i<=rows(info);i++){
	    //prep
	    aux = panelsubmatrix(ywby, i, info)
		//aux=aux,(1::rows(aux))
		//k type of kernel
		qth1=qtile(&aux,q1)
		qth2=qtile(&aux,q2)
		
		if (bw==0) {
			nobs=rows(aux[,1])
				 if (k==1) d=(1/(4*pi()))^.1
			else if (k==2) d=(3/(5*sqrt(5)))^(1/5)
			else if (k==3) d=15^.2
			else if (k==4) d=35^.2
			else if (k==5) d=(6/(1/6-1/pi()^2)^2)^.2
			else if (k==6) d=2*(151/35)^.2
			else if (k==7) d=(9/2)^.2
			else if (k==8) d=24^.2
			else if (k==9) d=(9450/143)^.2
			bw = 1.3643*d*nobs^-.2*min( (sqrt(variance(aux[,1], aux[,2])), 
				(qtile(&aux,75)-qtile(&aux,25))) / (invnormal(.75)-invnormal(.25)) )
			//    cons *d*Nobs   ^(-1/5) * min (IQR,SD)
		}
		qlow = (-(aux[,1]:<qth1):+q1/100):/  mean( qden(&aux,qth1,bw,k) , aux[,2] )
		qhigh= (-(aux[,1]:<qth2):+q2/100):/  mean( qden(&aux,qth2,bw,k) , aux[,2] )
		rif[|info[i,1],1 \ info[i,2],1|] =	qth2/qth1:+1/qth1:*(qhigh:-qth2/qth1:*qlow)
	}
	st_store(.,newvar,touse,rif[invorder(ord1),])
	st_numscalar("bbww",bw)

}


void rif_iqratio2(string scalar ywb,touse,newvar, real scalar q1,q2, bw, k ) {
     // prepares
    ywby=st_data(.,ywb,touse)
	//  y w by, Outcome weight by
	ord1=order(ywby,(3,1))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)
	
	// estimates RIF
    rif=J(rows(ywby),1,0)
	for(i=1;i<=rows(info);i++){
	    //prep
	    aux = panelsubmatrix(ywby, i, info)
		//aux=aux,(1::rows(aux))
		//k type of kernel
		qth1=qtile(&aux,q1)
		qth2=qtile(&aux,q2)
		
		if (bw==0) {
			nobs=rows(aux[,1])
				 if (k==1) d=(1/(4*pi()))^.1
			else if (k==2) d=(3/(5*sqrt(5)))^(1/5)
			else if (k==3) d=15^.2
			else if (k==4) d=35^.2
			else if (k==5) d=(6/(1/6-1/pi()^2)^2)^.2
			else if (k==6) d=2*(151/35)^.2
			else if (k==7) d=(9/2)^.2
			else if (k==8) d=24^.2
			else if (k==9) d=(9450/143)^.2
			bw = 1.3643*d*nobs^-.2*min( (sqrt(variance(aux[,1], aux[,2])), 
				(qtile(&aux,75)-qtile(&aux,25))) / (invnormal(.75)-invnormal(.25)) )
			//    cons *d*Nobs   ^(-1/5) * min (IQR,SD)
		}
		qlow = (-(aux[,1]:<qth1):+q1/100):/  mean( qden(&aux,qth1,bw,k) , aux[,2] ):*(aux[,1]:!=qth1)
		qhigh= (-(aux[,1]:<qth2):+q2/100):/  mean( qden(&aux,qth2,bw,k) , aux[,2] ):*(aux[,1]:!=qth2)
		rif[|info[i,1],1 \ info[i,2],1|] =		
		qth2/qth1:+1/qth1:*(qhigh:-qth2/qth1:*qlow)
	}
	st_store(.,newvar,touse,rif[invorder(ord1),])
		st_numscalar("bbww",bw)

}

 
void rif_glor(string scalar ywb,touse,newvar, real scalar q ) {
     // prepares
    ywby=st_data(.,ywb,touse)
	//  y w by, Outcome weight by
	ord1=order(ywby,(3,1))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)

	// estimates RIF
    rif=J(rows(ywby),1,0)
	for(i=1;i<=rows(info);i++){
	    //prep
	    aux = panelsubmatrix(ywby, i, info)
		//aux=aux,(1::rows(aux))
		//k type of kernel
		qth=qtile(&aux,q)
		// gLor for below, and glor for above
		rif[|info[i,1],1 \ info[i,2],1|] =
		(aux[,1]:-((1-q/100)*qth)):*(aux[,1]:<qth) :+q/100*qth:*(aux[,1]:>=qth)
		
	}
	st_store(.,newvar,touse,rif[invorder(ord1),])
}

 
void rif_lor(string scalar ywb,touse,newvar, real scalar lor ) {
     // prepares
    ywby=st_data(.,ywb,touse)
	//  y w by, Outcome weight by
	ord1=order(ywby,(3,1))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)
	// estimates RIF
    rif=J(rows(ywby),1,0)
	for(i=1;i<=rows(info);i++){
	    //prep
	    aux = panelsubmatrix(ywby, i, info)
		nn  = rows(aux)
		awgt= aux[,2]/mean(aux[,2])
		sumw= runningsum( awgt )
		glp  = runningsum(aux[,1]:*awgt/nn)
		lorp=lor/100
		// ordinates
		lpc=runningsum( (aux[,1]:*awgt:/(nn*glp[nn]) ):*((sumw/nn):<=(lorp)) ) 
		lpcp=lpc[nn]
	   	qth=qtile(&aux,lor)
     	//        (   lorp *qth)/glp[nn]:+lpcp*(1:-aux[,1]/glp[nn]):*(aux[,1]:>=qth)
		// gLor for below, and glor for above
		//=(`exp'-(1-`lorp')*`qvar'[1])/`mu'+`lpcp'*(1-`exp'/`mu') if float(`by')==float(`k') & `exp'<`qvar'[1]  & `touse'		
		//=          (`lorp'*`qvar'[1])/`mu'+`lpcp'*(1-`exp'/`mu') if float(`by')==float(`k') & `exp'>=`qvar'[1] & `touse'
		rif[|info[i,1],1 \ info[i,2],1|] =
		((aux[,1]:-(1-lorp)*qth)/glp[nn]:+lpcp*(1:-aux[,1]/glp[nn])):*(aux[,1]:<qth):+
		      (( lorp*qth)/glp[nn]:+lpcp*(1:-aux[,1]/glp[nn])):*(aux[,1]:>=qth)	
	}
	st_store(.,newvar,touse,rif[invorder(ord1),])
}


void rif_ucs(string scalar ywb,touse,newvar, real scalar lor ) {
     // prepares
    ywby=st_data(.,ywb,touse)
	//  y w by, Outcome weight by
	ord1=order(ywby,(3,1))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)
	// estimates RIF
    rif=J(rows(ywby),1,0)
	for(i=1;i<=rows(info);i++){
	    //prep
	    aux = panelsubmatrix(ywby, i, info)
		//aux=aux,(1::rows(aux))
		nn  = rows(aux)
		awgt= aux[,2]/mean(aux[,2])
		sumw= runningsum( awgt )
		glp  = runningsum(aux[,1]:*awgt/nn)
		// ordinates
		lorp=lor/100
		lpc=runningsum( (aux[,1]:*awgt:*((sumw/nn):<=lorp))/(nn*glp[nn]) )
		lpcp=lpc[nn]
	   	qth=qtile(&aux,lor)
		// gLor for below, and glor for above
		rif[|info[i,1],1 \ info[i,2],1|] =1:-
		(((aux[,1]:-((1-lorp)*qth)):/glp[nn]:+lpcp*(1:-aux[,1]/glp[nn])):*(aux[,1]:< qth):+
		           ((   lorp *qth):/glp[nn]:+lpcp*(1:-aux[,1]/glp[nn])):*(aux[,1]:>=qth)) 
			
	}
	st_store(.,newvar,touse,rif[invorder(ord1),])
}


void rif_iqsr(string scalar ywb,touse,newvar, real scalar ii0,ii1 ) {
     // prepares
    ywby=st_data(.,ywb,touse)
	//  y w by, Outcome weight by
	ord1=order(ywby,(3,1))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)
	// estimates RIF
    rif=J(rows(ywby),1,0)
	for(i=1;i<=rows(info);i++){
	    //prep
	    aux = panelsubmatrix(ywby, i, info)
		//aux=aux,(1::rows(aux))
		nn  = rows(aux)
		awgt= aux[,2]/mean(aux[,2])
		sumw= runningsum( awgt )
		glp  = runningsum(aux[,1]:*awgt/nn)
		i0=ii0/100
		i1=ii1/100
		// ordinates
		lpc0=runningsum( (aux[,1]:*awgt:*((sumw/nn):<=i0))/(nn*glp[nn]) )
		lpcp0=lpc0[nn]
		lpc1=runningsum( (aux[,1]:*awgt:*((sumw/nn):<=i1))/(nn*glp[nn]) )
		lpcp1=lpc1[nn]
	   	qth0=qtile(&aux,ii0)
		qth1=qtile(&aux,ii1)
		
		// gLor for below, and glor for above
 		rlow =((aux[,1]:-(1-i0)*qth0)/glp[nn]:+lpcp0*(-aux[,1]/glp[nn])):*(aux[,1]:< qth0):+
		         (((         i0*qth0)/glp[nn]:+lpcp0*(-aux[,1]/glp[nn])):*(aux[,1]:>=qth0))
		rhigh=((aux[,1]:-(1-i1)*qth1)/glp[nn]:+lpcp1*(-aux[,1]/glp[nn])):*(aux[,1]:< qth1):+
		         (((         i1*qth1)/glp[nn]:+lpcp1*(-aux[,1]/glp[nn])):*(aux[,1]:>=qth1))
		// RIF	 (1-lpcp1)/lpcp0:+	 
		//(1-`lpc1p')/`lpc0p'+1/`lpc0p'*(-`qhigh'-(1-`lpc1p')/`lpc0p'*`qlow')
		rif[|info[i,1],1 \ info[i,2],1|] =
			((1-lpcp1)/lpcp0):+((1/lpcp0):*(-(rhigh):-( ((1-lpcp1)/lpcp0)*(rlow))))
	}
	st_store(.,newvar,touse,rif[invorder(ord1),])
}

  
void rif_mcs(string scalar ywb,touse,newvar, real scalar ii0,ii1 ) {
     // prepares
    ywby=st_data(.,ywb,touse)
	//  y w by, Outcome weight by
	ord1=order(ywby,(3,1))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)
	// estimates RIF
    rif=J(rows(ywby),1,0)
	for(i=1;i<=rows(info);i++){
	    //prep
	    aux = panelsubmatrix(ywby, i, info)
		//aux=aux,(1::rows(aux))
		nn  = rows(aux)
		awgt= aux[,2]/mean(aux[,2])
		sumw= runningsum( awgt )
		glp  = runningsum(aux[,1]:*awgt/nn)
		i0=ii0/100
		i1=ii1/100
		// ordinates
		lpc0=runningsum( (aux[,1]:*awgt:*((sumw/nn):<=i0))/(nn*glp[nn]) )
		lpcp0=lpc0[nn]
		lpc1=runningsum( (aux[,1]:*awgt:*((sumw/nn):<=i1))/(nn*glp[nn]) )
		lpcp1=lpc1[nn]
	   	qth0=qtile(&aux,ii0)
		qth1=qtile(&aux,ii1)
		
		// gLor for below, and glor for above
		rlow =((aux[,1]:-(1-i0)*qth0)/glp[nn]:+lpcp0*(1:-aux[,1]/glp[nn])):*(aux[,1]:< qth0):+
		         (((         i0*qth0)/glp[nn]:+lpcp0*(1:-aux[,1]/glp[nn])):*(aux[,1]:>=qth0))
		rhigh=((aux[,1]:-(1-i1)*qth1)/glp[nn]:+lpcp1*(1:-aux[,1]/glp[nn])):*(aux[,1]:< qth1):+
		         (((         i1*qth1)/glp[nn]:+lpcp1*(1:-aux[,1]/glp[nn])):*(aux[,1]:>=qth1))		 
		// RIF		 
		//.60765734
		rif[|info[i,1],1 \ info[i,2],1|] =	(rhigh:-rlow)
		
	}
	st_store(.,newvar,touse,rif[invorder(ord1),])
}
 
 
void rif_pov(string scalar ywb,touse,newvar, real scalar pov ) {
     // prepares
    ywby =st_data(.,ywb ,touse)
	incz= (ywby[,4]:>ywby[,1]):*(-(ywby[,1]:/ywby[,4]):+1)	
	if (pov==0)    rif =(ywby[,4]:>ywby[,1])
	else           rif =(incz:^pov)		
	st_store(.,newvar,touse,rif )
}	


void rif_watts(string scalar ywb,touse,newvar ) {
     // prepares
    ywby =st_data(.,ywb ,touse)
 	rif =ln(ywby[,4]:/ywby[,1])*(ywby[,4]:>=ywby[,1])
	st_store(.,newvar,touse,rif )
}	
 

void rif_sen(string scalar ywb,touse,newvar, real scalar sen ) {
     // prepares
    ywby=st_data(.,ywb,touse)
	//  y w by, Outcome weight by
	ord1=order(ywby,(3,1))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)

	// estimates RIF
    rif=J(rows(ywby),1,0)
	for(i=1;i<=rows(info);i++){
	    //prep
	    aux = panelsubmatrix(ywby, i, info)
		nn  = rows(aux)
		awgt= aux[,2]:/mean(aux[,2])
		//sumw= runningsum( awgt )
		pvar= runningsum((awgt/nn):*(aux[,1]:<sen)) 
		cums =runningsum((sen:-aux[,1]):*(pvar[nn]:-pvar):*(aux[,1]:<sen):*(awgt/nn))
		glp  =runningsum(aux[,1]:*(aux[,1]:<sen):*(awgt/nn))
		
		isen=2/(sen*pvar[nn])*cums[nn]
		// gLor for below, and glor for above
		rif[|info[i,1],1 \ info[i,2],1|] =
			((2/(sen*pvar[nn])):*((sen*pvar[nn]-(1/2*sen*isen)):-(aux[,1]*pvar[nn]):+(aux[,1]:*pvar):-glp)):*(aux[,1]:<sen)	
	}
	st_store(.,newvar,touse,rif[invorder(ord1),])
}
 
void rif_tip(string scalar ywb,touse,newvar, real scalar tip, pline ) {
     // prepares
    ywby=st_data(.,ywb,touse)
	//  y w by, pline
	ord1=order(ywby,(3,1))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)
	// estimates RIF
	tip/100
    rif=J(rows(ywby),1,0)
	for(i=1;i<=rows(info);i++){
	    //prep
	    aux = panelsubmatrix(ywby, i, info)
		ptile=qtile(&aux,tip)
 		rif[|info[i,1],1 \ info[i,2],1|] =
		((pline:-aux[,1]):*(pline:>aux[,1]):*(pline<ptile)):+
		(tip/100:*(pline-ptile):+(ptile:-aux[,1]):*(ptile:<aux[,1])):*(pline>=ptile)
			 // q= 4.335394 z=2.5
 	}
	st_store(.,newvar,touse,rif[invorder(ord1),])
} 
 

void rif_entropy(string scalar ywb,touse,newvar, real scalar entropy ) {
     // prepares
	 
    ywby=st_data(.,ywb,touse)
	//  y w by, pline
	ord1=order(ywby,(3,1))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)

	// estimates RIF
    rif=J(rows(ywby),1,0)
	for(i=1;i<=rows(info);i++){
	    //prep
	    aux = panelsubmatrix(ywby, i, info)
		mu=mean(aux[,1],aux[,2])   
		if (entropy==0)	{
			v=mean(log(aux[,1]),aux[,2])
			e0=log(mu)-v
			rif[|info[i,1],1 \ info[i,2],1|] =
			e0:-(log(aux[,1]):-v):+(1/mu):*(aux[,1]:-mu)
			
		}	
		else if (entropy==1) {
			v=mean(log(aux[,1]):*aux[,1],aux[,2])
			e1=v/mu-log(mu)
			rif[|info[i,1],1 \ info[i,2],1|] =
			e1:+(1/mu):*(aux[,1]:*log(aux[,1]):-v):-((v+mu)/(mu^2)):*(aux[,1]:-mu)  
		}
		else {
			v=mean(aux[,1]:^entropy,aux[,2])
			ea=1/(entropy*(entropy-1))*(v/mu^entropy-1) 
			rif[|info[i,1],1 \ info[i,2],1|] =
			(ea:+(aux[,1]:^entropy:-v):/(entropy*(entropy-1)*mu^entropy)):- (v/((entropy-1)*mu^(entropy+1)):*(aux[,1]:-mu))
		} 
	}
	st_store(.,newvar,touse,rif[invorder(ord1),])
} 	 


void rif_atkin(string scalar ywb,touse,newvar, real scalar atkin ) {
     // prepares
	 
    ywby=st_data(.,ywb,touse)
	//  y w by, pline
	ord1=order(ywby,(3,1))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)

	// estimates RIF
    rif=J(rows(ywby),1,0)
	for(i=1;i<=rows(info);i++){
	    //prep
	    aux = panelsubmatrix(ywby, i, info)
		mu=mean(aux[,1],aux[,2])   
		if (atkin==1)	{
			v=mean(log(aux[,1]),aux[,2])
			a1=1-exp(v)/mu
			rif[|info[i,1],1 \ info[i,2],1|] =
			a1:-exp(v)/mu:*(log(aux[,1]):-v):+(aux[,1]:-mu):*(exp(v)/mu^2)
			
		}	
		else {
			v=mean(aux[,1]:^(1-atkin),aux[,2])
			ax=1-v^(1/(1-atkin))/mu
			rif[|info[i,1],1 \ info[i,2],1|] =
			ax:+(atkin/(1-atkin):+aux[,1]:/mu):*(1-ax):-( ((1-ax)^atkin):*aux[,1]:^(1-atkin) ):/( (1-atkin)*mu^(1-atkin) )
		} 
	}
	st_store(.,newvar,touse,rif[invorder(ord1),])
} 
 
 
void rif_logvar(string scalar ywb,touse,newvar) {
     // prepares
	 
    ywby=st_data(.,ywb,touse)
	//  y w by, pline
	ord1=order(ywby,(3,1))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)

	// estimates RIF
    rif=J(rows(ywby),1,0)
	for(i=1;i<=rows(info);i++){
	    //prep
	    aux = panelsubmatrix(ywby, i, info)
		v1=mean(log(aux[,1]):^2,aux[,2])
		v2=mean(log(aux[,1])   ,aux[,2])
		mu=mean(    aux[,1]    ,aux[,2])
		lgvr=v1-2*v2*log(mu)+log(mu)^2
		rif[|info[i,1],1 \ info[i,2],1|] =
		lgvr:+(log(aux[,1]):^2:-v1):-(2*log(mu))*(log(aux[,1]):-v2):-((2/mu)*(v2-log(mu))):*(aux[,1]:-mu) 
		} 
	
	st_store(.,newvar,touse,rif[invorder(ord1),])
} 
	

void rif_agini(string scalar ywb,touse,newvar) {
    // prepares
    ywby=st_data(.,ywb,touse)
	//  y w by, Outcome weight by
	ord1=order(ywby,(3,1,2))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)
	// estimates RIF
    rif=J(rows(ywby),1,0)	
	for(i=1;i<=rows(info);i++){
	    aux = panelsubmatrix(ywby, i, info)
		nn  = rows(aux)
		//needed?
		awgt= aux[,2]/mean(aux[,2])
		sumw= runningsum( awgt )
		//
		glp  = runningsum(aux[,1]:*awgt/nn)
		pvar=sumw:/nn
		padj = (sumw:-0.5*awgt):/nn
		covx = runningsum( (aux[,1]:- glp[nn]):*(padj:-.5):* awgt:/nn)
		 
		aggini=2*covx[nn]
				
		// RIF
		rif[|(info)[i,1],1 \  (info)[i,2],1|]=
		-aggini:+(-aux[,1]:+glp[nn])+2*((aux[,1]:*pvar):-glp) 
 	}
	st_store(.,newvar,touse,rif[invorder(ord1),])
}	
	

void rif_acindex(string scalar ywb,touse,newvar) {
    // prepares
    ywby=st_data(.,ywb,touse)
	//  y w by sort, ysort
	//  1 2  3  4       5
	ord1=order(ywby,(3,4,2,5))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)
	// estimates RIF
    rif=J(rows(ywby),1,0)	
	
	for(i=1;i<=rows(info);i++){
	    aux = panelsubmatrix(ywby, i, info)
		nn  = rows(aux)
		//needed?
		awgt= aux[,2]/mean(aux[,2])
		sumw= runningsum( awgt )
		glp  = runningsum(aux[,1]:*awgt/nn)
		pvar=sumw:/nn
		padj = (sumw:-0.5*awgt):/nn
		info2=panelsetup(aux, 4)
		
		aux3=(awgt,sumw)

		for(j=1;j<=rows(info2);j++){
			if (info2[j,2]>info2[j,1]) {
				naux = rows(aux2)
				aux2 = panelsubmatrix(aux3, j, info2)
				padj[|info2[j,1],1 \ info2[j,2],1|]=J(naux,1,1)#(0.5/nn):*(aux2[naux,2]:+aux2[1,2]-aux2[1,1])
			}
		}
		covx = runningsum( (aux[,1]:- glp[nn]):*(padj:-.5):* awgt:/nn)
		accindex=2*covx[nn]
 		// RIF
		rif[|(info)[i,1],1 \  (info)[i,2],1|]=
		(-accindex:+(-aux[,1]:+glp[nn]):+2*(aux[,1]:*pvar:-glp))
 	}
	st_store(.,newvar,touse,rif[invorder(ord1),])
}
 
void rif_cindex(string scalar ywb,touse,newvar) {
    // prepares
	real matrix ywby, ord1, info, rif, aux, awgt, sumw, glp, pvar, padj, info2, aux2, covx, rf, aux3
	real scalar i, nn, j , naux
    ywby=st_data(.,ywb,touse)
	//  y w by sort, ysort
	//  1 2  3  4       5
	ord1=order(ywby,(3,4,2,5))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)
	// estimates RIF
    rif=J(rows(ywby),1,0)	
	for(i=1;i<=rows(info);i++){
		
	    aux = panelsubmatrix(ywby, i, info)
		nn  = rows(aux)
		//needed?
		awgt= aux[,2]/mean(aux[,2])
		sumw= runningsum( awgt )
		glp  = runningsum(aux[,1]:*awgt/nn)
		pvar=sumw:/nn
		padj = (sumw:-0.5*awgt):/nn

		info2=panelsetup(aux, 4)
		
		aux3=(awgt,sumw)
		for(j=1;j<=rows(info2);j++){
			if (info2[j,2]>info2[j,1]) {
				aux2 = panelsubmatrix(aux3, j, info2)
				naux = rows(aux2)
				padj[|info2[j,1],1 \ info2[j,2],1|]=J(naux,1,1)#(0.5/nn)*(aux2[naux,2]:+aux2[1,2]:-aux2[1,1])
			}
		}
		covx = runningsum( (aux[,1]:- glp[nn]):*(padj:-.5):* awgt:/nn)
		rf=0.5*glp[nn]-covx[nn]
		//cindex=1-2/glp[nn]*rf 
		// RIF
		rif[|(info)[i,1],1 \  (info)[i,2],1|]=
		(2*rf/(glp[nn]^2)):*aux[,1]:+(2/glp[nn])*( (aux[,1]:*(pvar:-1)) :-glp):+1 
 	}
	st_store(.,newvar,touse,rif[invorder(ord1),])
}

 

void rif_eindex(string scalar ywb,touse,newvar, real scalar  lb,ub) {
    // prepares
    ywby=st_data(.,ywb,touse)
	//  y w by sort, ysort
	//  1 2  3  4       5
	ord1=order(ywby,(3,4,2,5))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)
	// estimates RIF
    rif=J(rows(ywby),1,0)	
	for(i=1;i<=rows(info);i++){
	    aux = panelsubmatrix(ywby, i, info)
		nn  = rows(aux)
		awgt= aux[,2]/mean(aux[,2])
		sumw= runningsum( awgt )
		glp  = runningsum(aux[,1]:*awgt/nn)
		pvar=sumw:/nn
		padj = (sumw:-0.5*awgt):/nn
		info2=panelsetup(aux, 4)
		aux3=(awgt,sumw)

		for(j=1;j<=rows(info2);j++){
			if (info2[j,2]>info2[j,1]) {
				aux2 = panelsubmatrix(aux3, j, info2)
				naux = rows(aux2)		
				padj[|info2[j,1],1 \ info2[j,2],1|]=
				J(naux,1,1)#(0.5/nn)*(aux2[naux,2]:+aux2[1,2]-aux2[1,1])
			}
		}
		covx = runningsum( (aux[,1]:- glp[nn]):*(padj:-.5):* awgt:/nn)
		accindex=2*covx[nn]
		// RIF
		rif[|(info)[i,1],1 \  (info)[i,2],1|]=
		(-accindex:+(-aux[,1]:+glp[nn]):+2*(aux[,1]:*pvar:-glp)):*(4/(ub-lb)) 
 	}
	st_store(.,newvar,touse,rif[invorder(ord1),])
}


void rif_arcindex(string scalar ywb,touse,newvar, real scalar   lb) {
    // prepares
    ywby=st_data(.,ywb,touse)
	//  y w by sort, ysort
	//  1 2  3  4       5
	ord1=order(ywby,(3,4,2,5))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)
	// estimates RIF
    rif=J(rows(ywby),1,0)	
	for(i=1;i<=rows(info);i++){
	    aux = panelsubmatrix(ywby, i, info)
		nn  = rows(aux)
		awgt= aux[,2]/mean(aux[,2])
		sumw= runningsum( awgt )
		glp  = runningsum(aux[,1]:*awgt/nn)
		pvar=sumw:/nn
		padj = (sumw:-0.5*awgt):/nn
		info2=panelsetup(aux, 4)
				aux3=(awgt,sumw)

		for(j=1;j<=rows(info2);j++){
			if (info2[j,2]>info2[j,1]) {
				aux2 = panelsubmatrix(aux3, j, info2)
				naux = rows(aux2)		
				padj[|info2[j,1],1 \ info2[j,2],1|]=
				J(naux,1,1)#(0.5/nn)*(aux2[naux,2]:+aux2[1,2]-aux2[1,1])
			}
		}
		covx = runningsum( (aux[,1]:- glp[nn]):*(padj:-.5):* awgt:/nn)
		accindex=2*covx[nn]
		// RIF
		rif[|(info)[i,1],1 \  (info)[i,2],1|]=
		(-accindex:+(-aux[,1]:+glp[nn]):+2*(aux[,1]:*pvar:-glp)):*(1/(glp[nn]-lb)):-
		  accindex:*( aux[,1]:-glp[nn]):/((glp[nn]-lb)^2)
 		
 	}
	st_store(.,newvar,touse,rif[invorder(ord1),])
}		
 
void rif_srindex(string scalar ywb,touse,newvar, real scalar   ub) {
    // prepares
    ywby=st_data(.,ywb,touse)
	//  y w by sort, ysort
	//  1 2  3  4       5
	ord1=order(ywby,(3,4,2,5))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)
	// estimates RIF
    rif=J(rows(ywby),1,0)	
	for(i=1;i<=rows(info);i++){
	    aux = panelsubmatrix(ywby, i, info)
		nn  = rows(aux)
		awgt= aux[,2]/mean(aux[,2])
		sumw= runningsum( awgt )
		glp  = runningsum(aux[,1]:*awgt/nn)
		pvar=sumw:/nn
		padj = (sumw:-0.5*awgt):/nn
		info2=panelsetup(aux, 4)
		aux3=(awgt,sumw)

		for(j=1;j<=rows(info2);j++){
			if (info2[j,2]>info2[j,1]) {
				aux2 = panelsubmatrix(aux3, j, info2)
				naux = rows(aux2)						
				padj[|info2[j,1],1 \ info2[j,2],1|]=
				J(naux,1,1)#(0.5/nn)*(aux2[naux,2]:+aux2[1,2]-aux2[1,1])
			}
		}
		covx = runningsum( (aux[,1]:- glp[nn]):*(padj:-.5):* awgt:/nn)
		accindex=2*covx[nn]
		// RIF
		rif[|(info)[i,1],1 \  (info)[i,2],1|]=((-accindex:+(-aux[,1]:+glp[nn]):+2*(aux[,1]:*pvar:-glp)):*(1/(ub-glp[nn])):-
		accindex:*(-aux[,1]:+glp[nn]):/((ub-glp[nn])^2))
		
 	}
	 
	st_store(.,newvar,touse,rif[invorder(ord1),])
}	  
 
  
 void rif_windex(string scalar ywb,touse,newvar, real scalar   lb,ub) {
    // prepares
    ywby=st_data(.,ywb,touse)
	//  y w by sort, ysort
	//  1 2  3  4       5
	ord1=order(ywby,(3,4,2,5))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)
	// estimates RIF
    rif=J(rows(ywby),1,0)	
	for(i=1;i<=rows(info);i++){
	    aux = panelsubmatrix(ywby, i, info)
		nn  = rows(aux)
		awgt= aux[,2]/mean(aux[,2])
		sumw= runningsum( awgt )
		glp  = runningsum(aux[,1]:*awgt/nn)
		pvar=sumw:/nn
		padj = (sumw:-0.5*awgt):/nn
		info2=panelsetup(aux, 4)
		aux3=(awgt,sumw)

		for(j=1;j<=rows(info2);j++){
			if (info2[j,2]>info2[j,1]) {
				aux2 = panelsubmatrix(aux3, j, info2)
				naux = rows(aux2)					
				padj[|info2[j,1],1 \ info2[j,2],1|]=
				J(naux,1,1)#(0.5/nn)*(aux2[naux,2]:+aux2[1,2]-aux2[1,1])
			}
		}
		covx = runningsum( (aux[,1]:- glp[nn]):*(padj:-.5):* awgt:/nn)
		accindex=2*covx[nn]
		// RIF
		z2	= ((ub+lb-2*glp[nn])*(aux[,1]:- glp[nn])) 
		z3	= ((ub-glp[nn])*(glp[nn]-lb)) 
		
		rif[|(info)[i,1],1 \  (info)[i,2],1|]=
		(-accindex:+(-aux[,1]:+glp[nn]):+2*(aux[,1]:*pvar:-glp)):*((ub-lb)/((ub-glp[nn])*(glp[nn]-lb))):-
		  accindex:*( ((ub-lb)/(z3*z3)) * z2)
 	}
	st_store(.,newvar,touse,rif[invorder(ord1),])
}
	
end



