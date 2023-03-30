---------------------------------------------------------------------
Package name:  RIF 

Title:  'RIF': module to compute Recentered Influence Functions (RIF): RIF-Regression and
        RIF-Decomposition

Title
    rif contains 5 userwritten commands that aim to faciliate the use of recentered influence functions as statistical tool for statistical inference regarding distributional statistics, as well as the estimation of RIF-Regressions and RIF-Decompositions.
    The first program, _grifvar.do adds additional extensions to egen to create RIF's for a large set of distributional statistics. 
    rifhdreg.ado can be used for the estimation of RIF-regressions allowing for high dimensional fixed effects. It can also be used for the estimation of treatment effects on distribution statistics. 
    oaxaca_rif.ado can be used to implement Oaxaca-Blinder type of decompositions using RIF's as dependent variables. 
    surifreg.ado can be used for the estimation of simultaneous unconditional quantile regressions across selected quantiles.
    uqreg.ado can be used for the estimation of unconditional quantile regression with other models including binomial models.
    A template program named _ghvar.ado is also included to be able to write egen extensions that can be used extend the use of rifhdreg and oaxaca_rif to statistics not currently available in rifvar.
		
Author 1 name:  Fernando Rios-Avila
Author 1 from:  Levy Economics Institute of Bard College, Annandale-on-Hudson, NY.
Author 1 email: friosavi@levy.org

Help keywords:  rifvar, rifhdreg, oaxaca_rif, surifreg, uqreg, oaxaca, blinder, decomposition, reweigthing, rif-regression, quantile treatment effects, inequality treatment effects.

File list: 
_grifvar.ado
rifvar.sthlp
rifhdreg.ado
rifhdreg.sthlp
oaxaca_rif.ado
oaxaca_rif.sthlp
surifreg.ado 
surifreg.sthlp
surifreg2.ado 
surifreg2.sthlp
uqreg.ado
uqreg.sthlp
_ghvar.ado
hvar.sthlp


Notes: oaxaca_rif requires the latest -oaxaca-, rifhdreg requires -reghdfe-. All programs work with Stata 12 and above.
