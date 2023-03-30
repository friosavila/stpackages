{smcl}
{* *! version 1.1  March 2018}{...}
 
{title:Title}

{phang}
{bf:cv_regress} {hline 2} Reproduces the Leave-one-out cross-validation statistics using the shortcut for Linear models.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:cv_regress} [{cmd:,} {it:options}] [cvwgt(varname) gen(new varname)] 

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opth cvwgt(varname)}} Weights to be used for the error evaluation purpose {p_end}
{synopt:{opth generr(new varname)}} If specified, creates a new variable containing the predicted Leave-one-out error.  y-E(y_-i|X) {p_end}
{synopt:{opth genhat(new varname)}} If specified, creates a new variable containing the Leave-one-out prediction E(y_-i|X)   {p_end}
{synopt:{opth genlev(new varname)}} If specified, creates a new variable containing the leverage statistic h(X). Accounts for the use of weights {p_end}

{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:cv_regress}  This command uses the shortcut that relies on the leverage statistics to estimate the leave-one-out error, which is typically used 
in the estimation of Cross-Validation Statistics.{p_end} 

{pstd}
For the correct implementation, the OLS model needs to be estimated using -regress-, before this program is executed.{p_end}

{pstd}
cv_regress reports four goodness-of-fit measures: the root mean squared error (RMSE), Log Mean Squared error (LMSE),
 the mean absolute error (MAE), and the pseudo-R2 
 (the square of the correlation coefficient of the predicted and observed values of the dependent variable). {p_end}
 
{pstd} 
It also gives you the option to save the predicted Leave-one-out error,
 leave one out prediction and the leverage statistic from the model.{p_end}
 
{title:Saved Results}

{pstd}
cv_regress returns the root mean squared error r(rmse), the log mean squared error
 r(lmse), the mean absolute deviation r(mae), and the pseudo R squared r(pr2). {p_end}
{pstd}
The program may also create the predicted Leave-one-out error, LOO prediction and 
leverage statistic for the same sample used in the estimated model.

{marker Acknowledgments}
{title: Acknowledgments}

{pstd}
The program is based on the shortcut evaluation of the Leave-one-out CV strategy in linear models described in "An Introduction to Statistical Learning" by James, G. et al (2013). 
The reported statistics are the same as the ones provided in Manuel Barron's -loocv- module. 
The program relies on Stata program -regress-.

I want to thank Scott Susin for his valuable feedback that helped finding a bug in the command. 

All errors are my own.


{marker examples}{...}
{title:Examples}
. sysuse auto,clear
. set seed 1
. gen wgt=runiform()
. loocv reg price weight i.foreign 


 Leave-One-Out Cross-Validation Results 
-----------------------------------------
         Method          |    Value
-------------------------+---------------
Root Mean Squared Errors |   2172.9124
Mean Absolute Errors     |   1690.7928
Pseudo-R2                |   .45133264
-----------------------------------------

. qui:reg price weight i.foreign 

. cv_regress
 
Leave-One-Out Cross-Validation Results 
-----------------------------------------
         Method          |    Value
-------------------------+---------------
Root Mean Squared Errors |    2172.9125
Log Mean Squared Errors  |      15.3676
Mean Absolute Errors     |    1690.7928
Pseudo-R2                |      0.45133
-----------------------------------------

. 
. loocv reg price weight i.foreign [aw=wgt]


 Leave-One-Out Cross-Validation Results 
-----------------------------------------
         Method          |    Value
-------------------------+---------------
Root Mean Squared Errors |   2196.2179
Mean Absolute Errors     |   1671.0773
Pseudo-R2                |   .44172641
-----------------------------------------

. qui:reg price weight i.foreign [aw=wgt]

. cv_regress


Leave-One-Out Cross-Validation Results 

-----------------------------------------
         Method          |    Value
-------------------------+---------------
Root Mean Squared Errors |    2196.2179
Log Mean Squared Errors  |      15.3890
Mean Absolute Errors     |    1671.0773
Pseudo-R2                |      0.44173
-----------------------------------------


* Using different weights for CV evaluation

. qui:reg price weight i.foreign  

. cv_regress, cvwgt(wgt)

Leave-One-Out Cross-Validation Results 
Statistics are estimated using -wgt- as weights

-----------------------------------------
         Method          |    Value
-------------------------+---------------
Root Mean Squared Errors |    2212.4447
Log Mean Squared Errors  |      15.4037
Mean Absolute Errors     |    1703.7026
Pseudo-R2                |      0.37805
-----------------------------------------


** this would be the same as:
. cv_regress, generr(e_i)

. gen double e_ia=abs(e_i)

. gen double e_ib=e_i^2

. sum e_ia [w=wgt]
(analytic weights assumed)

    Variable |     Obs      Weight        Mean   Std. Dev.       Min        Max
-------------+-----------------------------------------------------------------
        e_ia |      74  32.6092222    1703.703   1421.127   25.81131    6967.48

. sum e_ib [w=wgt]	
(analytic weights assumed)
    Variable |     Obs      Weight        Mean   Std. Dev.       Min        Max
-------------+-----------------------------------------------------------------
	    e_ib |      74  32.6092222     4894912    9496328   666.2237   4.85e+07

.display r(mean)^.5
2212.4447
 

{marker Author}{...}
{title:Author}

{pstd}
Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Blithewood-Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org

