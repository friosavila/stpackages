TITLE
      'JWDID': Module for estimating Difference-in-Difference models using Extended-TWFE approach.

DESCRIPTION/AUTHOR(S)
      
      'JWDID' is a command that implements the estimation approach proposed by Wooldridge (2021,2023), and the suggestions in Nagengast et al(2024) for the estimations of DID in the context of Gravity-trade models. 
      The main idea of JWDID is that consistent estimations for ATT's can be obtained by allowing for full cohort X timing heterogeneity (cohort/year interactions) in them main model. The setup, however, allows for other types of model specifications and restrictions.
      One advantage over other estimators, is that it can also be applied using methods other than linear regressions, including count models (poisson) or binomial models (logit). Currently, ppmlhdfe is fully supported for the estimation of GravityTrade-models.
      Aggregated ATTs are obtained using margins.
	      
      KW: Differences in Differences
      KW: DID
      KW: Event Studies
      KW: ETWFE
      KW: Poisson pseudo-likelihood
      
      
      Requires: Stata version 15, reghdfe
      
      Author :  Fernando Rios-Avila, Levy Economics Institute of Bard College
      Support:  friosavi@levy.org

      Author :  Arne J. Nagengast, Deutsche Bundesbank
      email  :  arne.nagengast@bundesbank.de

      Author :  Yoto V. Yotov, School of Economics, Drexel University
      email  :  yotov@drexel.edu
      
Files:
jwdid.ado; jwdid_estat.ado; jwdid_plot.ado
jwdid.sthlp; jwdid_postestimation.sthlp