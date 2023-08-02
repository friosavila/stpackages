{smcl}
{* 16nov2021}{...}
{cmd:help creg}
{hline}

{p2colset 1 16 18 2}{...}
{p2col:{bf:creg} {hline 2}}Centered linear regression (all RHS variable coefficients are treated as resulting from "de-meaned" explanatory variables){p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{opt creg}
   [{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Handling simulations appropriate for use after {cmd:rifhdreg} or any {cmd:reg}-based linear model}

{synopt :{opt eval}}{it:eval} activate transformations a la Haisken-DeNew and Schmidt (1997).{p_end}

{synopt :{opt radn}}{it:radn} activate transformations a la Rios-Avila and de New (2022).{p_end}

{synopt :{opt divbycons}}{it:divbycons} divide all coefficients by the constant a la Rios-Avila and de New (2022).{p_end}

{synopt :{opt pp(#)}}{it:pp} is set by default to 1 percentage point; this is used when one is simulating a 1 percentage-point increase in a dummy variable using the option {opt radn}.{p_end}

{synopt :{opt eststub(string)}}{it:eststub} is a string indicating a name for the set of estimation results for use in {cmd:estimates table}.{p_end}




{title:Postestimation command for linear regression models}
{p 8 16 2}

{opt creg} (Post-Estimation command with options)

{pstd}
{cmd:creg} is a post-estimation command run after any linear regression command like {cmd:regress}, {cmd:areg}, {cmd:rifhdreg} or {cmd:xtreg}. It adjusts coefficients and the variance-covariance matrix. 
{p_end}

{pstd}
{cmd:creg} requires all factor variables in the main command ({cmd:regress}, {cmd:areg}, {cmd:rifhdreg} or {cmd:xtreg}) to be explicitly declared using the standard "c." or "i." variable prefixes. All other variables are assumed to be continuous.{p_end} 
{pstd}
All dummy variable coefficient sets are adjusted to be deviations from a weighted average.
{p_end}

{pstd}
All continuous variable coefficients are adjusted as if the variables had been deviations from their means. {p_end}

{pstd}
The result is a "centered regression" such that the overall constant of the regression is equal to the unconditional mean of the dependent variable.
{p_end}



{title:Description}

{pstd}
{cmd:creg} implements the restricted least squares (RLS) procedure for dummy variable sets as described by 
Haisken-DeNew and Schmidt (1997). For example, log wages are regressed on a group of
k-1 industry/region/job/etc dummies using Stata's factor variable notation (e.g. i.gender). 
The k-th dummy is the omitted reference dummy. 
{p_end}

{pstd}
Using the factor variable notation, one can select
the desired reference dummy (e.g. b2.gender or b1.gender). It does not matter for RLS.
Using RLS, all k dummy coefficients and standard errors are reported. The coefficients are interpreted
as deviations from the dummy group weighted average. 
{p_end}

{pstd}
If the preceeding regression command has a constant, 
it is adjusted to include the dummy set averages.  It does not matter how many sets of dummies are 
included in the previous regression. All sets will be handled if using factor variable notation.
{p_end}

{pstd}
This ado corrects problems with the Krueger and Summers (1988) Econometrica methodology
of overstated differential standard errors, and understated overall dispersion.
The command {cmd:creg} is run {ul:after} {cmd:regress}, {cmd:areg}, {cmd:rifhdreg} or {cmd:xtreg}. 
{p_end}

{pstd}
The coefficients of {it:continuous} variables are also affected by {cmd:creg}. All continuous variable coefficients reflect a "demeaned variable", such that this variable mean (times the coefficient) is added to the constant. 
{p_end}

{pstd}
Also, all results calculated 
in {cmd:creg} are {it:independent} of the choice of the reference category. By the way, for all dummy variable sets having only 
two outcomes, i.e. male/female, the t-values of the {cmd:creg} adjusted coefficients are always equal in magnitude, but opposite in sign.
{p_end}
 
{pstd}
{cmd:creg} currently can deal with some interactions. You may only use the "i" and "b" notation when using factor variables, e.g. {it:i.race} or {it:b2.race} but not {it:i.race#i.industry} or {it:i.race##i.industry} or {it:i.race#c.grade}. 
{p_end}

{pstd}
There are some interactions which {cmd:creg} cannot handle directly. However, see {cmd:fvint} for single # dummy set interactions.
{p_end}

{pstd}
If you have specfied any weights using the previous {cmd: reg}, {cmd: areg}, {cmd:rifhdreg} or {cmd:xtreg} command, {cmd:creg} will automatically use these same weights to weight the means of the dummies in the dummy set to arrive at the weighted average. If no weights were used in the previous command, then {cmd:creg} assumes no weights. Also using the {cmd:if e(sample)} condition, {cmd:creg} uses by definition the same observations as in the previous regression command. 
{p_end}



{title:Stored results}

{pstd}{cmd:creg} stores the following in {cmd:e( )}:{p_end}

{pstd}Matrices{p_end}
{phang}{cmd:e(b)} creg replaces the e(b) of the previous regression.{p_end}
{phang}{cmd:e(V)} creg replaces the e(V) of the previous regression.{p_end}

{pstd}Macros{p_end}
{phang}{cmd:e(allfactors)} List of all factor variable base names, e.g. race state education.{p_end}
{phang}{cmd:e(all_sd)} List of all factor variable standard deviation of values from a dummy variable set, e.g. for the regressor i.race, the contents of e(all_sd) would be "race_sd" and "race_sd" is the scalar register name of e(race_sd).{p_end}


{pstd}Scalars (Example given for the factor variable: i.race used in previous command){p_end}
{phang}{cmd:e(race_sd)} Assuming the factor variable i.race, e(race_sd) is the standard deviation of of the associated coefficients weighted by their sample means and taking into account their respective standard errors.{p_end}
{phang}{cmd:e(race_f)} Assuming the factor variable i.race, e(race_f) is the F statistic associated with the joint test of all associated coefficients being equal to zero.{p_end}
{phang}{cmd:e(race_df)} Assuming the factor variable i.race, e(race_df) is degrees of freedom of the F statistic associated with the joint test of all associated coefficients being equal to zero.{p_end}
{phang}{cmd:e(race_dfr)} Assuming the factor variable i.race, e(race_dfr) is restricted degrees of freedom of the F statistic associated with the joint test of all associated coefficients being equal to zero.{p_end}
{phang}{cmd:e(race_p)} Assuming the factor variable i.race, e(race_p) is p-value of the F statistic associated with the joint test of all associated coefficients being equal to zero.{p_end}



{title:References}

{phang}
Haisken-DeNew, John P. and Christoph M. Schmidt (1997): "Inter-Industry and Inter-Region Wage Differentials:
Mechanics and Interpretation," Review of Economics and Statistics, 79(3), 516-21. {browse "https://www.mitpressjournals.org/doi/pdf/10.1162/rest.1997.79.3.516":Download REStat Reprint}
{p_end}

{phang}
Krueger, Alan and Lawrence Summers (1988): "Efficiency wages and the Inter-Industry Wage
Structure", Econometrica, 56, 259-193. {browse "https://www.jstor.org/stable/1911072?seq=1":Download Econometrica Reprint}
{p_end}







{title:Numerical example after regress command}

{phang}. {stata sysuse    nlsw88, clear:sysuse    nlsw88, clear}{p_end}
{phang}. {stata numlabel, add mask("[#] "):numlabel, add mask("[#] ")}{p_end}
{phang}. {stata tab race:tab race}{p_end}

. tab race

       Race |      Freq.     Percent        Cum.
------------+-----------------------------------
  [1] White |      1,637       72.89       72.89
  [2] Black |        583       25.96       98.84
  [3] Other |         26        1.16      100.00
------------+-----------------------------------
      Total |      2,246      100.00


{phang}. {stata regress   wage b1.race:regress   wage b1.race}{p_end}

. regress   wage b1.race

      Source |       SS           df       MS      Number of obs   =     2,246
-------------+----------------------------------   F(2, 2243)      =     10.28
       Model |  675.510282         2  337.755141   Prob > F        =    0.0000
    Residual |  73692.4571     2,243  32.8544169   R-squared       =    0.0091
-------------+----------------------------------   Adj R-squared   =    0.0082
       Total |  74367.9674     2,245  33.1260434   Root MSE        =    5.7319

------------------------------------------------------------------------------
        wage | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
        race |
  [2] Black  |  -1.238442   .2764488    -4.48   0.000    -1.780564   -.6963193
  [3] Other  |   .4677818   1.133005     0.41   0.680    -1.754067    2.689631
             |
       _cons |   8.082999   .1416683    57.06   0.000     7.805185    8.360814
------------------------------------------------------------------------------



{phang}. {stata creg, eval:creg, eval}{p_end}
 
 Restricted Least Squares for Dummy Variable Sets (Stata Factor Variables)
 
 Authors     : Prof Dr John P. de New and Prof Dr Christoph M. Schmidt
               Version: 22 Dec 2021 

 Citation    : Haisken-DeNew, J.P. and Schmidt C.M. (1997):
               "Interindustry and Interregion Wage Differentials:
               Mechanics and Interpretation," Review of Economics
               and Statistics, 79(3), 516-521. REStat Reprint
 
------------------------------------------------------------------------------
        wage | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
        race |
  [1] White  |   .3160504   .0737694     4.28   0.000     .1713869    .4607138
  [2] Black  |  -.9223912   .2042697    -4.52   0.000    -1.322969   -.5218139
  [3] Other  |   .7838322   1.117588     0.70   0.483    -1.407783    2.975448
             |
       _cons |   7.766949   .1209461    64.22   0.000     7.529771    8.004127
------------------------------------------------------------------------------

 Sampling-Error-Corrected Standard Deviation of Differentials
 Joint test of all coefficients in dummy variable set = 0, Prob > F = p
------------------------------------------------------------------------------
                race |  0.521062      F(2,2243) = 10.28         p=0.0000 
------------------------------------------------------------------------------




{title:Numerical example after regress command, comparing results}

{phang}. {stata sysuse    nlsw88, clear:sysuse    nlsw88, clear}{p_end}
{phang}. {stata numlabel, add mask("[#] "):numlabel, add mask("[#] ")}{p_end}

{phang}. {stata regress   wage:regress   wage}{p_end}
{phang}. {stata estimates store b0:estimates store b0}{p_end}

{phang}. {stata regress   wage b1.race:regress   wage b1.race}{p_end}
{phang}. {stata estimates store b1:estimates store b1}{p_end}

{phang}. {stata regress   wage b2.race:regress   wage b2.race}{p_end}
{phang}. {stata estimates store b2:estimates store b2}{p_end}

{phang}. {stata regress   wage b3.race:regress   wage b3.race}{p_end}
{phang}. {stata estimates store b3:estimates store b3}{p_end}

{phang}. {stata regress   wage b1.race:regress   wage b1.race}{p_end}
{phang}. {stata creg, eval:creg, eval}{p_end}
{phang}. {stata estimates store hds1:estimates store hds1}{p_end}

{phang}. {stata regress wage b2.race}{p_end}
{phang}. {stata creg, eval:creg, eval}{p_end}
{phang}. {stata estimates store hds2:estimates store hds2}{p_end}

{phang}. {stata regress wage b3.race}{p_end}
{phang}. {stata creg, eval:creg, eval}{p_end}
{phang}. {stata estimates store hds3:estimates store hds3}{p_end}

{phang}// Install {cmd:estout} if you have not already {p_end}
{phang}. {stata  ssc install estout:ssc install estout}{p_end}

{phang}// Now display the table of results {p_end}
    . {stata estout b0 b1 b2 b3 hds1 hds2 hds3, cells(b(star fmt(%9.3f) vacant(-)) se(par)) stats(r2_a N race_sd race_f race_df race_dfr race_p, fmt(%9.3g) ) legend label:estout} with lots of options ...


{pstd}
The estimation results b1, b2, b3 are all different, as in each case, there is a different base or reference category. However, the estimation results hds1, hds2, hds3 are all identical, regardless  of base category used. {p_end}

{pstd}
The constant has been adjusted as well, to reflect the weighted average that had been removed from the deviations. {p_end}

{pstd}
The constant reported will always be the unconditional mean of the dependent variable, after constant adjustments for dummy and continuous explanatory variables are made through centering.{p_end}



{title:Numerical example after xtreg command (compare to reg with i.factor)}

{phang}{p_end}
{phang}// Given that i.company is already the ID in xtset, {p_end}
{phang}// we should expect identical results for estimations (1) and (2):{p_end}
{phang}// {bf:(1) xtreg invest mvalue kstock i.time, fe }{p_end}
{phang}// {bf:(2) reg   invest mvalue kstock i.time {ul:i.company}}{p_end}

{phang}. {stata webuse grunfeld, clear:webuse grunfeld, clear}{p_end}
{phang}. {stata compress:compress}{p_end}
{phang}. {stata xtset:xtset}{p_end}


{phang}// Examples using {cmd:xtreg}{p_end}
{phang}. {stata xtreg invest mvalue kstock i.time, fe:xtreg invest mvalue kstock i.time, fe}{p_end}
{phang}. {stata estimates store B1:estimates store B1}{p_end}
{phang}. {stata creg, eval:creg, eval}{p_end}
{phang}. {stata estimates store HDS1:estimates store HDS1}{p_end}

{phang}. {stata xtreg invest mvalue kstock b2.time, fe:xtreg invest mvalue kstock b2.time, fe}{p_end}
{phang}. {stata estimates store B2:estimates store B2}{p_end}
{phang}. {stata creg, eval:creg, eval}{p_end}
{phang}. {stata estimates store HDS2:estimates store HDS2}{p_end}

{phang}// Examples using {cmd:reg}{p_end}
{phang}. {stata reg invest mvalue kstock b2.company i.time:reg invest mvalue kstock b2.company i.time}{p_end}
{phang}. {stata estimates store B3:estimates store B3}{p_end}
{phang}. {stata creg, eval:creg, eval}{p_end}
{phang}. {stata estimates store HDS3:estimates store HDS3}{p_end}

{phang}. {stata reg invest mvalue kstock b2.company b2.time:reg invest mvalue kstock b2.company b2.time}{p_end}
{phang}. {stata estimates store B4:estimates store B4}{p_end}
{phang}. {stata creg, eval:creg, eval}{p_end}
{phang}. {stata estimates store HDS4:estimates store HDS4}{p_end}

{phang}// Example using {cmd:areg}{p_end}
{phang}. {stata areg invest mvalue kstock b3.time, absorb(company):areg invest mvalue kstock b3.time, absorb(company)}{p_end}
{phang}. {stata estimates store B5:estimates store B5}{p_end}
{phang}. {stata creg, eval:creg, eval}{p_end}
{phang}. {stata estimates store HDS5:estimates store HDS5}{p_end}


{phang}// Install {cmd:estout} if you have not already {p_end}
{phang}. {stata  ssc install estout: ssc install estout}{p_end}

{phang}// Now display the table of results {p_end}
    . {stata estout B1 B2 B3 B4 B5 HDS1 HDS2 HDS3 HDS4 HDS5, cells(b(star fmt(%9.3f) vacant(-)) se(par)) stats(r2_a N company_sd time_sd, fmt(%9.3g) ) legend label:estout} with lots of options ...


{pstd}
Again, the estimation results B1, B2, B3, B4, B5 are all different, as in each case, there is a different base/reference category. The estimation results HDS1, HDS2, HDS3, HDS4, HDS5 are all identical, regardless  of base category used. {p_end}

{pstd}
The constant has been adjusted as well, to reflect the weighted average that had been removed from the deviations and continuous variables. {p_end}

{pstd}
The weighted average of every dummy variable set has been put back into the constant. The mean X_bar of every continuous variable X is multiplied by the estimated coefficient _b[X] and also re-added to the constant.  {p_end}



{title:Numerical example after reg command (using factor variable interactions)}

{phang}. {stata sysuse    nlsw88, clear:sysuse    nlsw88, clear}{p_end}
{phang}. {stata numlabel, add mask("[#] "):numlabel, add mask("[#] ")}{p_end}

{phang}// Make sure you have installed Benn Jann's cool {cmd: center} ado{p_end}
{phang}. {stata ssc install center:ssc install center}{p_end}

{phang}// Must pre-center variables used in polynomial{p_end}
{phang}. {stata center age:center age}{p_end}

{phang}// Run regession using explanatory vars and interactions {p_end}
{phang}. {stata reg wage i.occupation# #i.race i.industry c.c_age# #c.c_age hours:reg wage i.occupation##i.race i.industry c.c_age##c.c_age hours}{p_end} 
{phang}. {stata gen touse=e(sample):gen touse=e(sample)}{p_end}
{phang}// i.occupation##i.race {space 1} : the complex dummy-on-dummy interaction{p_end}
{phang}// {space 24} (i.occupation#i.race){p_end}
{phang}// i.industry {space 12}: a standard dummy set{p_end}
{phang}// c.c_age##c.c_age {space 10}: a quandratic term in age (must be 2#'s){p_end}
{phang}// c.grade#i.south {space 7}: a continuous var interacted with a dummy set{p_end}
{phang}// hours {space 17}: a standard continuous var{p_end} 
{phang}// Now run post-estimation command to adjust e(b) and e(V) to "center" results.{p_end}
{phang}// Automatically get marginal effects of interactions and polynomials.{p_end}


{phang}// Because there is a quadratic in c_age and an interaction {p_end}
{phang}// in i.occupation##i.race, we first need marginals. See what Stata says: {p_end}
{phang}. {stata margins, dydx(*):stata margins, dydx(*)}{p_end} 
{phang}// Re-Run regession using explanatory vars and interactions {p_end}
{phang}. {stata reg wage i.occupation# #i.race i.industry c.c_age# #c.c_age hours:reg wage i.occupation##i.race i.industry c.c_age##c.c_age hours}{p_end} 
{phang}. {stata creg, eval:creg, eval}{p_end} 	
{phang}// Run naked regession without any explanatory variables {p_end}
{phang}// The constant is the unconditional mean of the dependent variable {it:wage} {p_end}
{phang}. {stata reg wage if touse==1:reg wage if touse==1}{p_end}




{title:Numerical example after reg command (using factor variable interactions)}

{phang}// Make sure you have installed Ben Jann's cool {cmd: oaxaca} ado{p_end}
{phang}. {stata ssc install rifhdreg:ssc install oaxaca}{p_end}

{phang}. {stata use oaxaca, clear:use 		oaxaca, clear}{p_end}

{phang}. {stata drop if lnwage==. | married==. | female==. | isco==.  | age==.:drop 		if lnwage==. | married==. | female==. | isco==.  | age==.}{p_end}

{phang}// Make sure you have installed Benn Jann's cool {cmd: center} ado{p_end}
{phang}. {stata ssc install center:ssc install center}{p_end}

{phang}// You must pre-center a variable to be used in a quadratic or polynomial{p_end}
{phang}// Must be consistent with any weights used, also in centered vars{p_end}
{phang}. {stata center		age [aw=wt]:center		age [aw=wt]}{p_end}

{phang}. {stata label define isco 1 "Managers", modify:label define isco 1 "Managers", modify}{p_end}
{phang}. {stata label define isco 2 "Professional", modify:label define isco 2 "Professional", modify}{p_end}
{phang}. {stata label define isco 3 "Technicians and associate professionals", modify:label define isco 3 "Technicians and associate professionals", modify}{p_end}
{phang}. {stata label define isco 4 "Clerical support workers", modify:label define isco 4 "Clerical support workers", modify}{p_end}
{phang}. {stata label define isco 5 "Service and sales workers", modify:label define isco 5 "Service and sales workers", modify}{p_end}
{phang}. {stata label define isco 6 "Skilled agricultural, forestry and fishery workers", modify:label define isco 6 "Skilled agricultural, forestry and fishery workers", modify}{p_end}
{phang}. {stata label define isco 7 "Craft and related trades workers", modify:label define isco 7 "Craft and related trades workers", modify}{p_end}
{phang}. {stata label define isco 8 "Plant and machine operators, and assemblers", modify:label define isco 8 "Plant and machine operators, and assemblers", modify}{p_end}
{phang}. {stata label define isco 9 "Elementary occupations", modify:label define isco 9 "Elementary occupations", modify}{p_end}
{phang}. {stata label values isco isco:label values isco isco}{p_end}
 
{phang}. {stata label define married 0 "not married", modify:label define married 0 "not married", modify}{p_end}
{phang}. {stata label define married 1 "married", modify:label define married 1 "married", modify}{p_end}
{phang}. {stata label values married married:label values married married}{p_end}
 
{phang}. {stata label define single 0 "not single", modify:label define single 0 "not single", modify}{p_end}
{phang}. {stata label define single 1 "single", modify:label define single 1 "single", modify}{p_end}
{phang}. {stata label values single single:label values single single}{p_end}
 
{phang}. {stata label define female 0 "not female", modify:label define female 0 "not female", modify}{p_end}
{phang}. {stata label define female 1 "female", modify:label define female 1 "female", modify}{p_end}
{phang}. {stata label values female female:label values female female}{p_end}

{phang}. {stata numlabel, add mask("[#] "):numlabel, add mask("[#] ")}{p_end}

{phang}. {stata desc:desc}{p_end}

{phang}//			get unconditional mean{p_end}
{phang}. {stata reg lnwage [aw=wt]:reg 		lnwage [aw=wt]}{p_end}

{phang}//			run simple regression{p_end}
{phang}// 			interaction of i.married#i.isco{p_end}
{phang}// 			interaction of i.single#i.female{p_end}
{phang}. {stata reg	lnwage educ exper i.kids6 i.kids714 i.married# #i.isco c.c_age# #c.c_age [aw=wt]:reg lnwage educ exper i.kids6 i.kids714 i.married##i.isco c.c_age##c.c_age [aw=wt]}{p_end}

{phang}// get HDS97 and center any continuous vars; transform a la Rios-Avila & de New (2021){p_end}
{phang}// Continuous vars: 1 unit increase from average{p_end}
{phang}// Dummy vars: 1 percentage point (PP) increase from average{p_end}
{phang}// Constant: unconditional mean of LHS var or functional{p_end}
{phang}. {stata creg, eval radn pp(1):creg, eval radn pp(1)}{p_end}


{phang}// Make sure you have installed Fernando Rios-Avila's cool {cmd: rifhdreg} ado{p_end}
{phang}. {stata ssc install rifhdreg:ssc install rifhdreg}{p_end}

{phang}// Do Unconditional Quantile Regression at the 25th percentile of LHS var "lnwage"{p_end}
{phang}. {stata rifhdreg	lnwage educ exper i.kids6 i.kids714 i.married# #i.isco c.c_age# #c.c_age [aw=wt], rif(q(25)):rifhdreg lnwage educ exper i.kids6 i.kids714 i.married##i.isco c.c_age##c.c_age [aw=wt], rif(q(25))}{p_end}

{phang}// get HDS97 and center any continuous vars; transform a la Rios-Avila & de New (2021){p_end}
{phang}// Continuous vars: 1 unit increase from average{p_end}
{phang}// Dummy vars: 1 percentage point (PP) increase from average{p_end}
{phang}// Constant: unconditional mean of LHS var or functional{p_end}
{phang}. {stata creg, eval radn pp(1):creg, eval radn pp(1)}{p_end}

{phang}// Now do it again with Stata "margins" to check marginals{p_end}
{phang}. {stata rifhdreg	lnwage educ exper i.kids6 i.kids714 i.married# #i.isco c.c_age# #c.c_age [aw=wt], rif(q(25)):rifhdreg lnwage educ exper i.kids6 i.kids714 i.married##i.isco c.c_age##c.c_age [aw=wt], rif(q(25))}{p_end}
{phang}. {stata margins, dydx(*):margins, dydx(*)}{p_end}

{phang}// Compare with creg marginals{p_end}
{phang}. {stata creg, eval:creg, eval}{p_end}

{title:Authors}

{phang}Dealing with Restricted Least Squares{p_end}
{phang}Email: {browse "mailto:johnhd@unimelb.edu":Prof Dr John P. de New} and {browse "mailto:Christoph.Schmidt@rwi-essen.de":Prof Dr Christoph M. Schmidt}{p_end}

{phang}Dealing with Centered Regression with RIFs/UQR{p_end}
{phang}Email: {browse "mailto:johnhd@unimelb.edu":Prof Dr John P. de New} and {browse "mailto:friosavi@levy.org":Dr Fernando Rios-Avila}{p_end}

{phang}We would be delighted if you cited us if you use this ado and research. Please drop us a line if you do.{p_end}

{hline}

