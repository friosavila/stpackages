use https://friosavila.github.io/playingwithstata/drdid/lalonde.dta, clear
 keep  if treated==0 | sample==2
 drop if re==0
drop if re>26000
drop if re>25564
drop if re>25243
bysort id  :gen n=_N
drop if n!=2
 xtset id year
 by id:gen dy=re[2]-re[1]
 drop if year==1978
 drop if married==1
  gmm ( (dy - {b1:age educ black   nodegree hisp _cons})*(exper==0) )  ///
	 ( (dy - {b1:} - {att })*(exper==1) ) , ///
	 instrument(1:age educ black   nodegree hisp ) ///
	 winitial(identity) onestep  

  gmm ( (dy - {b1:cage ceduc i.black   i.nodegree i.hisp _cons})*(exper==0) )  ///
	 ( (dy - {b1:} - {att:cage ceduc i.black   i.nodegree i.hisp _cons })*(exper==1) ) , ///
	 instrument(1:age educ i.black   i.nodegree i.hisp ) ///
	 instrument(2:age educ i.black   i.nodegree i.hisp ) ///
	 winitial(identity) onestep 

  matrix b=e(b)		
  matrix V=e(V)
  matrix bb=b[1,"att:"]
  matrix vv=V["att:","att:"]
  
  regress dy 	 age educ i.black   i.nodegree i.hisp if exper==0
  predict dyy
  gen dy2=dy-dyy
  sum dy2 if exper==1
  
  sum age if exper==1
  gen cage=age-r(mean)  
  sum educ if exper==1
  gen ceduc=educ-r(mean)  
  
  regress dy2 cage ceduc i.black   i.nodegree i.hisp if exper==1
  adde repost b=bb V=vv, rename	
  
-------------+----------------------------------------------------------------
        /att |  -160.6014   547.8623    -0.29   0.769    -1234.392     913.189
------------------------------------------------------------------------------


 gmm ( (dy - {b1:age educ i.black   i.nodegree i.hisp _cons})*(exper==0) )  ///
	 ( (dy - {b1:} - {att:age educ i.black   i.nodegree i.hisp _cons})*(exper==1) ) , ///
	 instrument(age educ i.black   i.nodegree i.hisp ) winitial(identity) onestep