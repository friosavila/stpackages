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
					 [impvar(varlist)]	       /// list of variables for "imputation" not used
					 [replace ]					// to drop variables if they exit not used
	
	display as result "Program for Implementation of Ranked Statistical matching"
	display as text   "{p} the program will modify your dataset, creating as many observations as needed based on weight splitting procedure {p_end}"
	
	if "`replace'"!="" {
		foreach i in __id1 __id2 __sort __round __flag __spwgt {
		    capture drop `i'
		}
	}	
	
	* Step 1. Define sample to do the analysis on.
	tempvar touse
	qui:gen  byte `touse'=0
	qui:replace `touse'=1 `if' `in'  
	** pscores can be missing, but strata cannot.
	** This further defines the sample. Based on Strata variables, weights, and a survey ID variable.
	markout `touse' `weight' `strata' `survey'
	
	
	** If weights are not given or strata is not given, assume Weight = 1 (no weights) or Strata =1
	** For weights, we assume weights are integers. The strategy will not work with decimal weights because of 
	** numerical precision
	if "`weight'"=="" {
	    tempvar weight
	    gen byte `weight'=1
	}
	if "`strata'"=="" {
	    tempvar strata
	    gen byte `strata'=1
	}
	* make sure you have SOME strata matching with pscore
	** There needs to be the same number of Strata and Pscore variables. Even if we reuse PSCORE multiple times for 
	** smaller Strata 
	local nstrata:word count `strata'
	local npscore:word count `pscore'

	if `nstrata'!=`npscore' {
		display in red "Strata and Pscore need the same number of variables"
		display in red "you can reuse pscore variables multiple times"
		error 1
	}
	** make sure survey has only 2 values
	** 1 donor 1 recipient.
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
	* This IDS are used internally. Not related to the IDS from the survey
	qui:gen double __id1 = _n
	* step 3. do match
	** Look into what WWmatch does.
	**This also uses Frames to get some data merging, but could be done just appending datasets
	capture frame drop _new_
	
	display as result "Preparing Statistical Matching"
	mata:wwmatch("__id1","`weight'","`survey'","`strata'","`pscore'", "`touse'") 
	
	qui:frame _new_:compress
	qui:frame _new_:qui:drop if __id2==.
	qui:frmerge1m __id1, frame(_new_)
	* step4 impute all Ids
	* This creates a key of variables that can be used for linking data. 
	* id1 and id2 can be single variables, or list of variables. 
	foreach i in `id1' `id2' {
		capture confirm numeric variable `i'
		if _rc==7 {
			qui:replace `i'=`i'[__id2] if `i'==""
		}
		else {
			qui:replace `i'=`i'[__id2] if `i'==.
		}
	}
	** Finally gets a series of auxiliary variables.
	** description is given below
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
	** This is extra if one wants to do the imputation from the ADO command. 
	** but it can always be done later using the code above.
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
** not important for program. just to make dots and see the progress of matching
 program display_dots
	syntax ,  ndots(int) [maxdot(int 50)]
	if mod(`ndots',`maxdot')!=0 {
		display _c as text "."
	}
	else {
		display _c as text "." as result "`ndots'" _n
	}
 end
/// Here is where the matching is done 
mata: 
// first, we need the ID variable, Weight, Survey indicator
// but also Strata list, pscore list, and the sample identyfier
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
		// kstr is the number of columns. data in strata or in pscore (similar to which round we are)
		kstr = (cols(ss_all)-3)/2
		// output matrix init. 
		// In theory this has the largest dimension possible, because it will contains both surveys information
		xx_out=J(3*rows(ss_all),4,0)
		
		// I use two pointers. This follows how large a mtrix is
		// and where will it fit in the final output matrix
		point0=0
		point1=1
		// Here kcol goes from 0 to K most detailed to the least detailed.  Kcol =K means no strata.
		// The following loop is the outer loop that goes over each Strata
		for(kcol=1;kcol<=kstr;kcol++) {
			
			stata(sprintf(`"display as text _n "variable: " as result " %f" "',kcol))
			
			// matrix output. Initialzed at zero dimention 
			ss_all_out=J(rows(ss_all),cols(ss_all),0)
 
			// this creates a variable that will Sort the data 
			ord = order( (ss_all[,3+kcol],
						  ss_all[,3],
						  ss_all[,3+kstr+kcol]),
						  (1,2,3) )		  
			/// preparing the data:
			// s1: Sort by panel and pscore. This sorts All available data, using "ord" variable
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
			
			// THis is to folow the size of the smaller matrixes
			point00=0
			point11=1
			** The following loop is done for each observation 
			// This loop is done within each strata variable
			for(ist = 1;ist<=cinfo;ist++) {    
				
///////////////////////////////////////////////////////////////		 This is just to display DOTS. 				
				if ( cnter<=(100*ist/cinfo) ) {
				    cnter=ceil(100*ist/cinfo)
					stata(sprintf("display_dots, ndots(%f) maxdot(100)",cnter))					
				}
///////////////////////////////////////////////////////////////
				
				// extract submatrix. i out of Thousands
				subss_all=panelsubmatrix(ss_all,ist,pinfo)
				
				// count observations. 
				// Survey onlyhas to values 0 or 1 (donor or recipient)
				nsrv0 = sum(subss_all[,3]:==0)
				nsrvt = rows(subss_all)
							
				//need to verify I have data for each strata
				//If there is no information left to be match in a strata, the Strata loop will end
				if (nsrv0==nsrvt | nsrv0==0)  {
					// If all in nsrv is in nsrvt or is zero then Put together
					point11=rows(subss_all)+point00
					ss_all_out[|((point00+1),1) \ (point11, cols(subss_all))|]=subss_all
					point00=point11
				}
				//
				else {
					// we break by survey and do the match
					// If there are any observations left to be matched within a strata
					// that is done here.
					xs0=subss_all[1::nsrv0,(1,2)] 
					xs1=subss_all[nsrv0+1::nsrvt,(1,2)]
					xxs0=J(nsrvt,4,0)
					xxs1=J(nsrvt,4,0)
					j0=j1=0
					//** xs0 and xs1 are inputs. BEfore, and puts down what is left
					//** xxs0 xxs1 are outputs. 
					// SSmatch is what does the "matching" 
					// This feeds the program with data from donor and recipient Xs0 & xs1
					// for all observations within a single strata.
					// WIthin a single strata, matching is done using rank matching, until all "weights"
					// have been exhausted for atleast 1 sample (donor or recipient)
					ssmatch(&xs0, &xs1, &xxs0,&xxs1,&j0,&j1,kcol)
					// This is done to figure out where will the "matched" data go.
					// if j0=0 or j1=0 means that all data was allocated/matched
					// otherwise what is left is added to ss_all_out
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
					// puts together the data with the matched info
					// and counts how many observations the new merged matrix has.
					point1=rows(xxs0\xxs1)+point0
					xx_out[|((point0+1),1)\(point1,4)|]=xxs0\xxs1
					point0=point1
 				}
			}
///////////////////////////////////////////////////////////////	
			// This matrix contains everything that was left unmatched. 
			// for the next round/strata level
			ss_all=ss_all_out[1::point11,]
		}
		// This collects all the data. after matched. Xx_out has all the output (matched) data
		// including any unmatched observations SS_all
		xx_out=xx_out[1::point1,]
		xx_out=xx_out\		
			ss_all[,1],J(rows(ss_all),1,.),ss_all[,2],J(rows(ss_all),1,.)
	 
		// this are exported here, using frames.
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
	// mata for adding new variables
	void add_vars(string rowvector vlist) {
		 real scalar i
		 real scalar j
		 for(i=1;i<=cols(vlist);i++) {
			j=st_addvar("double",vlist[i])
		}
	}
	
	/// this does the SSmatch for a single value withing a strata.	
	void ssmatch(pointer scalar xs0, xs1, xxs0, xxs1, j0, j1, 
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
		
		//This is done exhautively. for each observations until all observations have a donor
		//and all weights have been used
		while (i<=nx0 & j<=nx1)
		 {
 
			ii++
			// this splits the weight
			wmin = rowmin( ( (*xs0)[i,2],(*xs1)[j,2] ) )
			
			// store with split weight
			
			(*xxs0)[ii,]=(*xs0)[i,1],(*xs1)[j,1],wmin,kk
			(*xxs1)[ii,]=(*xs1)[j,1],(*xs0)[i,1],wmin,kk
			
			// and takes the weight from the last observed
			// if an observation has a W=0, then we go over the next observation.
			// otherwise we continue using it with less weight
			
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
			(*j0)=range(i,nx0,1)
		}
		else {
			(*xs0)=J(0,2,0)
			(*j0)=0
		}
		////
		if (j<=nx1) {
			(*xs1)=(*xs1)[(j::nx1),]
			(*j1)=range(j,nx1,1)
		}
		else {
			(*xs1)=J(0,2,0)
			(*j1)=0
		}		
	}
end
