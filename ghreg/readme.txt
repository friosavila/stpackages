TITLE
      'ghsurv': Module for the estimation of survival model using repeated cross-sectional data 

DESCRIPTION/AUTHOR(S)
      
    'ghsurv' is a command that implements Guell and Hu (2006) estimator
    for survival analysis using repeated cross-section and uncompleted spells. 
    The method uses the observed distribution of current uncompleted spells length across
    two periods (base sample and continuation sample) to determine what factors 
    affect the likelihood of an individual exiting, or remaining in the sample.
    For example, characteristics that are observed with less frequency in the continuation sample
    are associated with higher risks of exiting (failure) the spell.
    Details of the estimator are described in Mundra and Rios-Avila (2020).
	      
      KW: ghsurv
      KW: ghsurv_p
      KW: ghsurv_set
      KW: streg
      KW: logit
      
      Requires: Stata version 11 
      
      Distribution-Date: 20200318
      
      Author:  Fernando Rios-Avila, Levy Economics Institute of Bard College
      Support: email  friosavi@levy.org
      

Files:
ghsurv.ado, ghsurv.sthlp, ghsurv_set.ado, ghsurv_p.ado, 
ghlogit.ado, ghprobit.ado, ghcloglog.ado