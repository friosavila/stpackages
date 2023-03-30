{smcl}
{* *! version 2.0  May 2021}{...}


{title:Title}

{phang}
{bf:rif} {hline 2} Modules to compute Recentered Influence Functions (RIF): RIF-Regression and RIF-Decomposition

{marker description}{...}
{title:Description}

{pstd}
Influence Functions (IF) are statistical tools that have been used for analyzing the robustness of distributional statistics, or
 functionals, to small disturbances in data (Cowell and Flachaire (2007)) or for a simplified strategy to estimate asymptotic variances of
 complex statistics (Deville 1999).

{pstd}
More recently, Firpo, Fortin, and Lemieux (2009) suggested the use of IFs, specifically Recentered Influence Functions (RIF), 
as a tool to analyze the impact that changes in the distribution of explanatory variables X has on the unconditional 
distribution of Y. 

{pstd}
The method introduced by Firpo, Fortin, and Lemieux (2009) focused on the estimation of Unconditional Quantile Regression (UQR), 
which allows the researcher to obtain partial effects of explanatory variables on any unconditional quantile of the dependent variable.

{pstd}
The flexibility and simplicity of this tool has opened the possibility to extend the analysis to other distributional statistics,
 using linear regressions or decomposition approaches. 

{pstd}
This package introduces a set of community contributed commands to facilitate the use of RIFs in the analysis of outcome distributions, using standard linear regression analysis or Oaxaca-Decomposition decomposition approaches. 

{pstd}
In this package you will find the following commands:

{pstd}
{help rifvar} is an egen extension that can be used to create RIFs for a large set of distributional statistics. It can also be used in combination with other statistics for which RIF's are not yet available. see {help hvar} for details. There are now two versions of this command. rifvar() has been rewritten to work with Mata, making it faster than the older command. Some algorithms have been changed, thus, for replication, the older command is now named {cmd: rifvar_old()}.

{pstd}
{help rifhdreg} is a command that facilitates the estimation of RIF regressions. It also enables the use of high-dimensional fixed effects 
(if {cmd:reghdfe} is installed). This command can also be used to estimate inequality treatment effects. There is now a wrapper named {cmd:bsrifhdreg} for bootstraping rif regressions. This is recomended for using the command {help qregplot} for plotting unconditional quantile regression coefficients.

{pstd}
{help oaxaca_rif} is a command that implements Oaxaca-Blinder decomposition (RIF decompositions), using the RIF's as dependent variables. It implements two type of decompositions: Standard OB deceomposition, and reweighted OB decomposition as suggested by Firpo, Fortin and Lemieux (2018). This requires the command {help oaxaca} (Jann, 2008). Names for the different components have been changed. Old version is now named oaxaca_rif_old.

{pstd}
{help rifsureg} and {help rifsureg2} are commands that can be used to estimate simulatenous RIF regressions. {cmd:rifsureg} focuses on the estimation of simultaneous unconditional quantile regressions, whereas {cmd:rifsureg2} can estimate simultanous RIF regressions.

{pstd}
{help rifmean} is a commands that can be used to estimate simulatenous RIF regressions. Similar to {cmd:rifsureg2}, this command can estimate simultanous RIFs. But it can more easily be used for the estimation of Mean statistics (and standard devations) over groups.

{pstd}
{help uqreg} is a self contained command that fits unconditional quantile regressions, allowing for other methods such as probit, logit, xtreg, etc.
 
{pstd}
For details on the commands, please refer to Rios-Avila(2019) (see references below).

{marker Author}{...}
{title:Author}

{pstd}Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Blithewood-Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org

{marker references}{...}
{title:References}

{phang}
Cowell, F. A., and E. Flachaire. 2007. Income distribution and inequality
measurement: The problem of extreme values. {it:Journal of Econometrics} 141:
1044-1072. {browse "https://doi.org/10.1016/j.jeconom.2007.01.001"}.

{phang}
Deville, J.-C. 1999. Variance estimation for complex statistics and
estimators: Linearization and residual techniques. {it:Survey Methodology} 25:
193-203.

{phang}
Firpo, S. P., N. M. Fortin, and T. Lemieux. 2009. Unconditional quantile
regressions. {it:Econometrica} 77: 953-973.
{browse "https://doi.org/10.3982/ECTA6822"}.

{phang}
Firpo, S. P., N. M. Fortin, and T. Lemieux. 2018.
Decomposing wage distributions using recentered influence function
regressions. {it:Econometrics} 6: 28. 
{browse "https://doi.org/10.3390/econometrics6020028"}.

{phang}
Jann, B. 2008. {browse "https://doi.org/10.1177/1536867X0800800401":The Blinder-Oaxaca decomposition for linear regression models}. {it:Stata Journal} 8: 453-479.

{phang}
Rios-Avila, F. 2020. Recentered influence functions (RIFs) in Stata: RIF regression and RIF decomposition.
Stata Journal, 20(1), 51-94. {browse "https://doi.org/10.1177/1536867X20909690"}. 

