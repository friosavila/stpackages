** SS match 
*capture program drop _all
*mata:	mata clear

program ssmatch
version 16
	syntax [if] [in], id1(varlist) id2(varlist) /// This will contain the Original variable Ids.
					 survey(varname)		   /// identifies the survey. Only two values for a given sample.	
					 [weight(varname)]         /// required A variable with integer weights
					 [strata(varlist)]         /// required List of all variables used for strata from the highest detailed, to the "groser" one
					 pscore(varlist)           /// required list of all pscores. If k< K last will be used 
					 [impvar(varlist)]	       /// list of variables for "imputation"
					 [replace ]					// to drop variables if they exit
	
	display as result "Program for Implementation of Ranked Statistical matching"
	display as text   "{p} the program will modify your dataset, creating as many observations as needed based on weight splitting procedure {p_end}"
	
	if "`replace'"!="" {
		foreach i in __id1 __id2 __sort __round __flag __spwgt {
		    capture drop `i'
		}
	}	
	
	* Step 1. Define sample
	tempvar touse
	qui:gen  byte `touse'=0
	qui:replace `touse'=1 `if' `in'  
	** pscores can be missing, but strata cannot.
	markout `touse' `weight' `strata' `survey'
	
	if "`weight'"=="" {
	    tempvar weight
	    gen byte `weight'=1
	}
	if "`strata'"=="" {
	    tempvar strata
	    gen byte `strata'=1
	}
	* make sure you ahve SOME strata matching with pscore
	local nstrata:word count `strata'
	local npscore:word count `pscore'

	if `nstrata'!=`npscore' {
		display in red "Strata and Pscore need the same number of variables"
		display in red "you can reuse pscore variables multiple times"
		error 1
	}
	** make sure survey has only 2 values
	qui:levelsof `survey' if `touse', local(sloc)
	
	local nsurv:word count `sloc'
	if `nsurv'!=2 {
		display in red "Survey can only have 2 values: Donor and Recipient"
		error 1
	}
	else {
		tempvar ssurv
		local aux: word 1 of `sloc'
		gen byte `ssurv'=`survey' == `aux' if `touse'
		local survey `ssurv'
	}
	
	* Step 2. create generic id
 
	qui:gen double __id1 = _n
	* step 3. do match
	capture frame drop _new_
	
	display as result "Preparing Statistical Matching"
	mata:wwmatch("__id1","`weight'","`survey'","`strata'","`pscore'", "`touse'") 
	
	qui:frame _new_:compress
	qui:frame _new_:qui:drop if __id2==.
	qui:frmerge1m __id1, frame(_new_)
	* step4 impute all Ids
	foreach i in `id1' `id2' {
		capture confirm numeric variable `i'
		if _rc==7 {
			qui:replace `i'=`i'[__id2] if `i'==""
		}
		else {
			qui:replace `i'=`i'[__id2] if `i'==.
		}
	}
	tempvar nn
	qui:gen double `nn'=_n
	qui:gsort  `survey' __id1 __round -__spwgt
	display as result _n "Creating auxiliary variables"
	bysort `touse' `survey' __id1 :gen byte __flag=_n==1 if `touse' 
	sort `nn'
	ren `nn' __sort
	
	qui: compress __id1 __id2 __sort __round __flag __spwgt 
	display as result "Variable descriptions"
	label var __sort   "Variable used to preserve sorting of data"
	label var __flag   "=1 for 'best' match. Lower round with larger weight"
	label var __id1    "ID. identifying original observations"
	label var __id2    "Matched ID. (donor - recipient)"
	label var __round  "Round at which the 'match' was assigned"
	label var __spwgt  "Split weight."
	des __id1 __id2 __sort __round __flag __spwgt 
	
	display as text _n "{p} The variables (ID1:{cmd: `id1'}) and (ID2:{cmd: `id2'}) have changed. They now identify the matched observation for all donors {p_end}" 
	display as result "{p} For the 'assignment' of data from donor to recipient (or otherwise) use the following syntax: {p_end}" 
	display as text "sort __sort"
	display as text "gen imp_new = old_var [__id2]"
	display as result "{p} Where imp_new will contain the imputed data using information from {cmd:old_var} " /// 
					  " and its matched observation (as indicated by {cmd:__id2}) {p_end}"
	
	if "`impvar'"!="" {
		foreach i of varlist `impvar' {
			qui:gen     `i'_imp= `i'        if `touse'
			qui:replace `i'_imp= `i'[__id2] if `i'==. & `touse'
		}		
	}
end
  
program define frmerge1m, 
	syntax varlist , frame(name)
	version 16
	tempfile frm
	frame `frame':save `frm'
	merge 1:m `varlist' using `frm', nogen
	frame drop `frame' 
end

 program display_dots
	syntax ,  ndots(int) [maxdot(int 50)]
	if mod(`ndots',`maxdot')!=0 {
		display _c as text "."
	}
	else {
		display _c as text "." as result "`ndots'" _n
	}
 end
 
mata: 
	void wwmatch(string scalar id, weight, survey, strata, pscore, touse) 
	{
		real matrix ss_all, subss_all, ord
		real scalar kcol , kstr
		real scalar ist, nsrv0, nsrvt,  j0,j1
		real matrix xxs1 , xxs0, xs0, xs1, xx_out,ss_all_out
		real matrix pinfo
		real scalar cinfo
		real scalar cnter, point1 ,point0
		/// S1 Collect all data
		ss_all  = st_data(.,id    ,touse), 
				  st_data(.,weight,touse), 
				  st_data(.,survey,touse), 
				  st_data(.,strata,touse),
				  st_data(.,pscore,touse)
		// kcol will be the pointer
		kcol = 1
		// kstr is the number of columns. data in , strata or in pscore
		kstr = (cols(ss_all)-3)/2
		// out matrix init. In theory this has the largest dimension possible
		xx_out=J(3*rows(ss_all),4,0)
		
		point0=0
		point1=1
		// Here kcol goes from 0 to K most details to the "gross"
		for(kcol=1;kcol<=kstr;kcol++) {
			// strata:ss_all[3+kcol,]
			// survey:ss_all[3,]
			// pscore:ss_all[3+kstr+kcol,]
			stata(sprintf(`"display as text _n "variable: " as result " %f" "',kcol))
			// matrix output. Initialzed at zero dimention (problem?)
			ss_all_out=J(rows(ss_all),cols(ss_all),0)
 
			// this orders the data (that is why view doesnt work)
			ord = order( (ss_all[,3+kcol],
						  ss_all[,3],
						  ss_all[,3+kstr+kcol]),
						  (1,2,3) )		  
			/// preparing the data:
			// s1: Sort by panel and pscore. This sorts All available data
			ss_all=ss_all[ord,]
 			// s2 id panel info
			
			// this identifies all panel
			pinfo = panelsetup(ss_all, 3+kcol)
			// and this # cases per panel (# stratas) This may be the bottle neck. We have 5K to start with...
			cinfo = rows(pinfo)
			
			//just a counter for making "points"
			cnter=0
			
			real scalar point11 ,point00
			real matrix tmpx
			point00=0
			point11=1
///////////////////////////////////////////////////////////////		 This is just to display DOTS. May modify it	
			for(ist = 1;ist<=cinfo;ist++) {    
				if ( cnter<=(100*ist/cinfo) ) {
				    cnter=ceil(100*ist/cinfo)
					stata(sprintf("display_dots, ndots(%f) maxdot(100)",cnter))					
				}
				// extract submatrix. i out of Thousands
				subss_all=panelsubmatrix(ss_all,ist,pinfo)
				
				// count observations. 
				// Survey onlyhas to values 0 or 1 (donor or recipient)
				nsrv0 = sum(subss_all[,3]:==0)
				nsrvt = rows(subss_all)
							
				//need to verify I have data for each strata
				if (nsrv0==nsrvt | nsrv0==0)  {
					// If all in nsrv is in nsrvt or is zero then Put together
					point11=rows(subss_all)+point00
					ss_all_out[|((point00+1),1) \ (point11, cols(subss_all))|]=subss_all
					point00=point11
				}
				//second loop this may be where it Breaks
				else {
					// we break by survey and do the match
					xs0=subss_all[1::nsrv0,(1,2)] 
					xs1=subss_all[nsrv0+1::nsrvt,(1,2)]
					xxs0=J(nsrvt,4,0)
					xxs1=J(nsrvt,4,0)
					j0=j1=0
					//** xs0 and xs1 are inputs. BEfore, and puts down what is left
					//** xxs0 xxs1 are outputs. 
					ssmatch(&xs0, &xs1, &xxs0,&xxs1,&j0,&j1,kcol)
					//second bottle neck. 
					if (j0!=0) {
						tmpx=(xs0,subss_all[1::nsrv0,][j0,3::cols(ss_all)])
						point11=rows(tmpx)+point00
						ss_all_out[|((point00+1),1) \ (point11, cols(subss_all))|]=tmpx
						point00=point11		   
					}		   
					if (j1!=0) {
						tmpx=(xs1,subss_all[nsrv0+1::nsrvt,][j1,3::cols(ss_all)])
						point11=rows(tmpx)+point00
						ss_all_out[|((point00+1),1) \ (point11, cols(subss_all))|]=tmpx
						point00=point11		   
					}
					// This needs changing **
					point1=rows(xxs0\xxs1)+point0
					xx_out[|((point0+1),1)\(point1,4)|]=xxs0\xxs1
					point0=point1
 				}
			}
///////////////////////////////////////////////////////////////			
			ss_all=ss_all_out[1::point11,]
		}
		xx_out=xx_out[1::point1,]
		xx_out=xx_out\		
			ss_all[,1],J(rows(ss_all),1,.),ss_all[,2],J(rows(ss_all),1,.)
	 
		//last step. Exporting
		string scalar fr_curr
		fr_curr=st_framecurrent()
		
		st_framecreate( "_new_")
		st_framecurrent("_new_")
		
		add_vars( ("__id1","__id2","__spwgt","__round") )
		st_addobs(rows(xx_out))
		st_store(.,("__id1","__id2","__spwgt","__round"),xx_out)
		st_framecurrent(fr_curr)
	}
	
	void add_vars(string rowvector vlist) {
		 real scalar i
		 real scalar j
		 for(i=1;i<=cols(vlist);i++) {
			j=st_addvar("double",vlist[i])
		}
	}
	
	/// this does the SSmatch for a single cluster.	
	void ssmatch(pointer scalar xs0, xs1, xxs0, xxs1, l0, l1, 
				 real scalar kk)
		{
		real scalar i, j, ii, nx0, nx1, wmin	
		i=1
		j=1
		ii=0
		nx0=rows(*xs0)
		nx1=rows(*xs1)																							
		//xxs1=&J(nx0+nx1,5,0)
		//xxs0=&J(nx0+nx1,5,0)
		while (i<=nx0 & j<=nx1)
		 {
 
			ii++
			wmin = rowmin( ( (*xs0)[i,2],(*xs1)[j,2] ) )
			
			// store with split data
			
			(*xxs0)[ii,]=(*xs0)[i,1],(*xs1)[j,1],wmin,kk
			(*xxs1)[ii,]=(*xs1)[j,1],(*xs0)[i,1],wmin,kk
			// take min out id= 1 w =2
			
			(*xs0)[i,]=(*xs0)[i,1],(*xs0)[i,2]-wmin
			(*xs1)[j,]=(*xs1)[j,1],(*xs1)[j,2]-wmin
			
			// looks at w = 0
			if ( (*xs0)[i,2]==0) i++
			if ( (*xs1)[j,2]==0) j++
 
			
		}
		// this stores only what is needed
		(*xxs0)=(*xxs0)[(1::ii),]
		(*xxs1)=(*xxs1)[(1::ii),]
		
		// and this what is left. 
		if (i<=nx0) {
			(*xs0)=(*xs0)[(i::nx0),]
			(*l0)=range(i,nx0,1)
		}
		else {
				(*xs0)=J(0,2,0)
				(*l0)=0
		}
		////
		if (j<=nx1) {
			(*xs1)=(*xs1)[(j::nx1),]
			(*l1)=range(j,nx1,1)
		}
		else {
			(*xs1)=J(0,2,0)
			(*l1)=0
		}		
	}
end
