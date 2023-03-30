{smcl}
{* *! version 1.0  Aug2014}{...}
{cmd:help regxfe}{right: ({browse "http://www.stata-journal.com/article.html?article=st0409":SJ15-3: st0409})}
{hline}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col :{cmd:regxfe} {hline 2}}Fit a linear high-order fixed-effects model{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmdab:regxfe}
{depvar} [{indepvars}] 
{ifin}
{weight}{cmd:,} {cmd:fe(}{it:{help varlist:fe_varlist}}{cmd:)}
[{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent :* {opt fe(fe_varlist)}}specify the list of fixed effects to use in model; must include between one to seven variables{p_end}
{synopt:{opt xfe(str)}}save estimated fixed effects as a new set of variables{p_end}
{synopt:{opth cluster(varname)}}specify the use of cluster standard errors{p_end}
{synopt:{opt robust}}specify the use of robust standard errors{p_end}
{synopt:{opth file(filename)}}save the transformed dataset to file{p_end}
{synopt:{opt replace}}overwrite and replace the existing dataset if the filename already exists{p_end}
{synopt:{opt mg(#)}}specify the number of degrees of freedom; used for modular implementation{p_end}
{synopt:{opt tolerance(#)}}specify the convergence criteria; default is {helpb epsfloat()}{p_end}
{synopt:{opt maxiter(#)}}specify the maximum number of iterations allowed; default is {cmd:maxiter(10000)}{p_end}
{synoptline}
{p2colreset}{...}
{pstd}
* {cmd:fe()} is required.{p_end}
{p 4 6 2}
{cmd:aweight}s, {cmd:fweight}s, and {cmd:iweight}s are allowed; see {help weight}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:regxfe} fits a linear high-order fixed-effects model, allowing for up to
seven fixed effects.  It allows for the use of weights and robust and one-way
clustered standard errors.  Robust and cluster errors are estimated using the
same assumptions as in the {helpb regress} and {helpb areg} commands.  The
command is based on a pretransformation of the variables to absorb the effect
of the {it:fe_varlist} variables of all dependent and independent variables
before fitting the model.  The transformed dataset can be saved as a separate
file.  The degrees of freedom to estimate the standard errors is corrected
using an approximation of the number of nonidentifiable parameters following
the modified algorithm of Abowd, Creecy, and Kramarz (2002).
 

{marker options}{...}
{title:Options}

{phang}
{opth fe:(varlist:fe_varlist)} specifies the fixed effects to use in the model.  The user must specify between one to seven variables.  The fixed-effects variables should be in
integer, long, or double format to ensure accuracy.  {cmd:fe()} is required.

{phang}
{opt xfe(str)} creates new variables using the fixed-effects names and the specified prefix.

{phang}
{opth cluster(varname)} specifies to use one-way clustered standard errors.

{phang}
{opt robust} specifies to use robust standard errors.

{phang}
{opth file(filename)} specifies to save the transformed dataset in
the current folder in a new file.

{phang}
{opt replace} overwrites and replaces existing dataset.

{phang}
{opt mg(#)} specifies the number of degrees of freedom.  If {opt mg(#)} is specified, the
program uses this number instead of attempting to estimate the degrees of
freedom.  This option is recommended if the number of unidentifiable
parameters is estimated externally.  (See {helpb nredound}.)

{phang}
{opt tolerance(#)} specifies the convergence criteria to be used for the
variable transformations.  Smaller tolerance levels can achieve
estimates closer to those using the full dummy specification but will also
take a longer time to achieve convergence.  The default is {helpb epsfloat()}.

{phang}
{opt maxiter(#)} specifies the maximum number of iterations allowed.  A small
number of iterations might reduce the accuracy of the results.  The default is
{cmd:maxiter(10000)}.


{title:Remarks}

{pstd}
The program uses the commands {helpb a2group}, {helpb center}, 
{helpb distinct}, and {helpb tuples}.  If not installed, they are installed in
the system the first time that the program is used.  See also {helpb nredound} and 
{helpb itercenter}.


{marker examples}{...}
{title:Examples}

{phang2}{cmd:. webuse nlswork}{p_end}
{phang2}{cmd:. regxfe ln_wage age tenure hours union, fe(ind_code occ_code idcode year)}{p_end}

{phang2}{cmd:. regxfe ln_wage age tenure hours union, fe(ind_code occ_code idcode year) cluster(idcode)}{p_end}

{phang2}{cmd:. regxfe ln_wage age tenure hours union, fe(ind_code occ_code idcode year) xfe(i) file(Tdata)}{p_end}

    {title:Modular implementation}

{pstd}
For modular implementation, be careful to use exactly the same sample for all commands.{p_end}
{phang2}{cmd:. mark  markvar}{p_end}

{phang2}{cmd:. markout markvar ln_wage age tenure union year idcode ind_code occ_code year}{p_end}

{phang2}{cmd:. itercenter ln_wage age hours if markvar, fe(ind_code occ_code idcode year) mean replace}{p_end}

{phang2}{cmd:. itercenter tenure union if markvar, fe(ind_code occ_code idcode year) mean replace}{p_end}

{phang2}{cmd:. nredound ind_code occ_code idcode year if markvar}{p_end}

{phang2}{cmd:. local x=e(M)}{p_end}

{phang2}{cmd:. regxfe ln_wage age tenure hours union  if markvar, fe(ind_code occ_code idcode year) maxiter(0) mg(`x')}{p_end}


{title:References}

{phang}
Abowd, J. M., R. H. Creecy, and F. Kramarz. 2002. Computing person and
firm effects using linked longitudinal employer-employee data.
Technical Paper No. TP-2002-06, Center for Economic Studies, U.S. Census
Bureau. {browse "http://www2.census.gov/ces/tp/tp-2002-06.pdf"}.

{phang}
Rios-Avila, F. 2015. Fit a linear high-order fixed-effects model. Stata Journal 15(3).

{marker Author}{...}
{title:Author}

{pstd}Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Blithewood-Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org


{marker also_see}{...}
{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 3: {browse "http://www.stata-journal.com/article.html?article=st0409":st0409}{p_end}
