{smcl}
{* 30may2020}{...}
{cmd:help fvhds97}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :{hi:fvhds97} {hline 2}}Restricted Least Squares Post-Estimation Command for (factor variable) Dummy Variable Sets{p_end}
{p2colreset}{...}



{title:Postestimation command for linear regression models}
{p 8 16 2}

{opt fvhds97} (Post-Estimation command with no options)

{phang}
Factor variable coefficients from the previously run {cmd:regress}, {cmd:areg} or {cmd:xtreg} 
command are are adjusted
to reflect deviations from a 
weighted average effect, and {bf:not} deviations 
from an arbitrary reference category as defined  
by the omitted reference dummy{p_end}



{title:Description}

{pstd}
{cmd:fvhds97} implements the restricted least squares (RLS) procedure as described by 
Haisken-DeNew and Schmidt (1997). {bf:Log} wages are regressed on a group of
k-1 industry/region/job/etc dummies using Stata's factor variable notation (e.g. i.gender). 
The k-th dummy is the omitted reference dummy. 
{p_end}

{pstd}
Using the factor variable notation, one can select
the desired reference dummy (e.g. b2.gender or b1.gender). It does not matter for the RLS.
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
The command {cmd:fvhds97} is run {ul:after} {cmd:regress}, {cmd:areg} or {cmd:xtreg}. 
{p_end}

{pstd}
General comments: The coefficients of {it:continuous} variables are not at all affected by {cmd:fvhds97}. Also, all results calculated 
in {cmd:fvhds97} are {it:independent} of the choice of the reference category. By the way, for all dummy variable sets having only 
two outcomes, i.e. male/female, the t-values of the {cmd:fvhds97} adjusted coefficients are always equal in magnitude, but opposite in sign.
{p_end}
 
{pstd}
{cmd:fvhds97} currently cannot deal with interactions. You may only use the "i" and "b" notation when using factor variables, e.g. {it:i.race} or {it:b2.race} but not {it:i.race#i.industry} or {it:i.race##i.industry} or {it:i.race#c.grade}.
{p_end}

{pstd}
If you have specfied any weights using the previous {cmd: reg}, {cmd: areg} or {cmd:xtreg} command, {cmd:fvhds97} will automatically use these same weights to weight the means of the dummies in the dummy set to arrive at the weighted average. If no weights were used in the previous command, then {cmd:fvhds97} assumes no weights. Also using the {cmd:if e(sample)} condition, {cmd:fvhds97} uses by definition the same observations as in the previous regression command. 
{p_end}



{title:Stored results}

{pstd}{cmd:fvhds97} stores the following in {cmd:e( )}:{p_end}

{pstd}Matrices{p_end}
{phang}{cmd:e(b)} fvhds97 replaces the e(b) of the previous regression.{p_end}
{phang}{cmd:e(V)} fvhds97 replaces the e(V) of the previous regression.{p_end}

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

{phang}. {stata regress   wage b1.race:regress   wage b1.race}{p_end}
{phang}. {stata fvhds97:fvhds97}{p_end}

. fvhds97
 
  Restricted Least Squares for Dummy Variable Sets (Stata Factor Variables)
 
 Authors     : Prof Dr John P. de New and Prof Dr Christoph M. Schmidt
               Version: 30 May 2020 

 Citation    : Haisken-DeNew, J.P. and Schmidt C.M. (1997):
               "Interindustry and Interregion Wage Differentials:
               Mechanics and Interpretation," Review of Economics
               and Statistics, 79(3), 516-521. REStat Reprint
 

      Source |       SS           df       MS      Number of obs   =     2,246
-------------+----------------------------------   F(2, 2243)      =     10.28
       Model |  675.510282         2  337.755141   Prob > F        =    0.0000
    Residual |  73692.4571     2,243  32.8544169   R-squared       =    0.0091
-------------+----------------------------------   Adj R-squared   =    0.0082
       Total |  74367.9674     2,245  33.1260434   Root MSE        =    5.7319

------------------------------------------------------------------------------
        wage |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
        race |
      white  |   .3160504   .0737694     4.28   0.000     .1713869    .4607138
      black  |  -.9223912   .2042697    -4.52   0.000    -1.322969   -.5218139
      other  |   .7838322   1.117588     0.70   0.483    -1.407783    2.975448
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

{phang}. {stata regress   wage b1.race:regress   wage b1.race}{p_end}
{phang}. {stata estimates store b1:estimates store b1}{p_end}

{phang}. {stata regress   wage b2.race:regress   wage b2.race}{p_end}
{phang}. {stata estimates store b2:estimates store b2}{p_end}

{phang}. {stata regress   wage b3.race:regress   wage b3.race}{p_end}
{phang}. {stata estimates store b3:estimates store b3}{p_end}

{phang}. {stata regress   wage b1.race:regress   wage b1.race}{p_end}
{phang}. {stata fvhds97:fvhds97}{p_end}
{phang}. {stata estimates store hds1:estimates store hds1}{p_end}

{phang}. {stata regress wage b2.race}{p_end}
{phang}. {stata fvhds97:fvhds97}{p_end}
{phang}. {stata estimates store hds2:estimates store hds2}{p_end}

{phang}. {stata regress wage b3.race}{p_end}
{phang}. {stata fvhds97:fvhds97}{p_end}
{phang}. {stata estimates store hds3:estimates store hds3}{p_end}

{phang}// Install {cmd:estout} if you have not already {p_end}
{phang}. {stata  ssc install estout:ssc install estout}{p_end}

{phang}// Now display the table of results {p_end}
    . {stata estout b1 b2 b3 hds1 hds2 hds3, cells(b(star fmt(%9.3f) vacant(-)) se(par)) stats(r2_a N race_sd race_f race_df race_dfr race_p, fmt(%9.3g) ) legend label:estout} with lots of options ...


{pstd}
The estimation results b1, b2, b3 are all different, as in each case, there is a different base or reference category. However, the estimation results hds1, hds2, hds3 are all identical, regardless  of base category used. {p_end}

{pstd}
The constant has been adjusted as well, to reflect the weighted average that had been removed from the deviations. {p_end}




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
{phang}. {stata fvhds97:fvhds97}{p_end}
{phang}. {stata estimates store HDS1:estimates store HDS1}{p_end}

{phang}. {stata xtreg invest mvalue kstock b2.time, fe:xtreg invest mvalue kstock b2.time, fe}{p_end}
{phang}. {stata estimates store B2:estimates store B2}{p_end}
{phang}. {stata fvhds97:fvhds97}{p_end}
{phang}. {stata estimates store HDS2:estimates store HDS2}{p_end}

{phang}// Examples using {cmd:reg}{p_end}
{phang}. {stata reg invest mvalue kstock b2.company i.time:reg invest mvalue kstock b2.company i.time}{p_end}
{phang}. {stata estimates store B3:estimates store B3}{p_end}
{phang}. {stata fvhds97:fvhds97}{p_end}
{phang}. {stata estimates store HDS3:estimates store HDS3}{p_end}

{phang}. {stata reg invest mvalue kstock b2.company b2.time:reg invest mvalue kstock b2.company b2.time}{p_end}
{phang}. {stata estimates store B4:estimates store B4}{p_end}
{phang}. {stata fvhds97:fvhds97}{p_end}
{phang}. {stata estimates store HDS4:estimates store HDS4}{p_end}

{phang}// Example using {cmd:areg}{p_end}
{phang}. {stata areg invest mvalue kstock b3.time, absorb(company):areg invest mvalue kstock b3.time, absorb(company)}{p_end}
{phang}. {stata estimates store B5:estimates store B5}{p_end}
{phang}. {stata fvhds97:fvhds97}{p_end}
{phang}. {stata estimates store HDS5:estimates store HDS5}{p_end}


{phang}// Install {cmd:estout} if you have not already {p_end}
{phang}. {stata  ssc install estout: ssc install estout}{p_end}

{phang}// Now display the table of results {p_end}
    . {stata estout B1 B2 B3 B4 B5 HDS1 HDS2 HDS3 HDS4 HDS5, cells(b(star fmt(%9.3f) vacant(-)) se(par)) stats(r2_a N company_sd time_sd, fmt(%9.3g) ) legend label:estout} with lots of options ...
	

{pstd}
Again, the estimation results B1, B2, B3, B4, B5 are all different, as in each case, there is a different base/reference category. The estimation results HDS1, HDS2, HDS3, HDS4, HDS5 are all identical, regardless  of base category used. {p_end}

{pstd}
The constant has been adjusted as well, to reflect the weighted average that had been removed from the deviations. The weighted average of every dummy variable set has been put back into the constant. {p_end}



{title:Authors}

Email    :  {browse "mailto:johnhd@unimelb.edu":Prof Dr John P. de New} and {browse "mailto:Christoph.Schmidt@rwi-essen.de":Prof Dr Christoph M. Schmidt}

{phang}Important Note - We would be absolutely thrilled 
if you would cite the Haisken-DeNew and Schmidt (1997) 
REStat paper should you decide to use this program!{p_end}


{hline}

