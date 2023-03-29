TITLE
      'JWDID': Module for the estimation of Difference-in-Difference using Mundlak approach.

DESCRIPTION/AUTHOR(S)
      
    'JWDID' is a command that implements the estimation approch proposed by Wooldridge (2021), based on the Mundlak approach.
    The main idea of JWDID is that consistent estimations for ATT's can be obtained by allowing for full cohort and timing heterogeneity, by simply adding cohort/year interactions in them main model.
	One advantage over other estimators, is that it can also be applied using methods other than linear regressions, including counte models (poisson) or binomial models (logit).
    Aggregations are obtained using margins.
	      
      KW: Differences in Differences
      KW: DID
      KW: Event Studies
      KW: jwdid
      
      Requires: Stata version 14, rehdfe
      
      Author:  Fernando Rios-Avila, Levy Economics Institute of Bard College
      Support: email  friosavi@levy.org
      
Files:
jwdid.ado; jwdid_estat.ado; 
jwdid.sthlp; jwdid_postestimation.sthlp