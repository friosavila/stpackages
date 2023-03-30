*! v1.0 April 2020 Fernando Rios-Avila 
* This is the prefered specification, but probit and cloglog are also possible.
** ghmodel logit estimator
program ghlogit
	args lnf xb alpha2
	*** ML_y1 is the y0 y1 indicator
	*** ML_y2 is the gap indicator. Periods in between
	*** xb is the latent index, 
	*** and alpha2 the unconditional probability 
	tempvar alpha  p1
	if "$ML_y2"=="" {
		quietly:gen double `alpha'=exp(`alpha2')
		quietly:gen double `p1'=logistic(-`xb')/ (`alpha'+logistic(-`xb'))
	}
	else {
		** no need to add ^MLy2
		quietly:gen double `alpha'=exp(`alpha2')
		quietly:gen double `p1'=logistic(-`xb')^$ML_y2 / (`alpha'+logistic(-`xb')^$ML_y2 )
	}
	
	/****
	the Probability of transition:
	             F(xb) 
	PR(exit)= --------------------
			  alpha + F(xb) 
	Alpha is an adjustment constant.
	****/
	*sum `p1' `p0'
	quietly replace `lnf' = ln(`p1')   if ($ML_y1==1)
	quietly replace `lnf' = ln(1-`p1') if ($ML_y1==0)
end 
