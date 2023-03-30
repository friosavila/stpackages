TITLE
      'F_ABLE': Module for the estimation of marginal effects with transformed covariates

DESCRIPTION/AUTHOR(S)
      
    'f_able' is a command that can be used to enable margins to correctly estimate marginal effects
    when using transformed/constructed data. This command adds information to e() that is later used 
   by the estimation 'predict' command, so that constructed data is handled correctly.
    This package comes with four commands: fgen and frep, for the creation and labeling of new variables,
    f_able, to indicate what variables are constructed before using Margins; and f_able_reset, to restore
    the original estimation output. 
   Due to Rounding errors, often you may receive a warning regarding nonsymetric matrix. To correct this, one 
   can use f_symev (when using post option after margins), and f_symrv otherwise.
   See examples in helpfile to see how it can be applied.
      
      KW: f_able
      KW: fgen
      KW: frep
      KW: f_symrv
      KW: f_symev
      KW: margins
      KW: predict
      
      Requires: Stata version 11 
      
      Distribution-Date: 20200318
      
      Author:  Fernando Rios-Avila, Levy Economics Institute of Bard College
      Support: email  friosavi@levy.org
      

Files:
f_able.ado, f_able.sthlp, f_able_p.ado, f_able_reset.ado, fgen.ado, frep.ado, f_symrv.ado, f_symev.ado, f_spline.ado, f_spline.sthlp, f_rcspline.ado, f_rcspline.sthlp