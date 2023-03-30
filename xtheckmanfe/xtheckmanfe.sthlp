{smcl}
{*  version 1.0  April2020 by Fernando Rios-Avila}{...}

{viewerjumpto "Syntax" "xtheckmanfe##syntax"}{...}
{viewerjumpto "Options" "xtheckmanfe##options"}{...}
{viewerjumpto "Description" "xtheckmanfe##description"}{...}
{viewerjumpto "Examples" "xtheckmanfe##examples"}{...}

{p2colset 1 17 19 2}{...}
{p2col:{bf: xtheckmanfe} {hline 2}} CRE Panel data models in the presence of endogeneity and selection
{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{phang} Panel data models in the presence of endogeneity and selection

{p 8 17 2}
{cmd:xtheckmanfe} {depvar} {indepvars} {ifin}
[{cmd:,} 
{cmdab:selec:tion}(selection Equation)
[{cmdab:endog:enous}(endogenous equation/s) id(id variable) time(time variable) reps(#repetitions) seed()]

{pstd}where {it:selection} equation is specified as

{p 8 12 2}{cmd:(} [selection variable] {cmd:=} [instruments1]  {cmd:)}

{pstd}and the {it:endogenous} equations are specified as

{p 8 12 2}{cmd:(} [endogenous variables] {cmd:=} [instruments2]  {cmd:)}

{synoptset 28 tabbed}{...}
{marker options_table}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt :{cmdab:selec:tion(}sel Eq{cmdab:)}} specifies the selection equation. The selection variable svar should be =1 if observation 
i is observed at time t, and =0 otherwise. If no selection variable is specified (no "=" included), selection is defined of wheter the 
main dependent variable is observed or not. {p_end}
{synopt :{cmdab:endog:enous(}endog Eq(s){cmdab:)}} specifies the endogenous variables in the model. The model can have one or more
endogenous variables, which are defined as all variables to the left of the equal sign. All variables on the right of the equal sign 
are used as instruments.{p_end}
{synopt :{cmdab:id(varname)}} specifies the panel identifier variable. if both id and time are not specified, and panel data has been set,
the command will use information from {help svyset} as default. Othewise Both must be specified. {p_end}
{synopt :{cmdab:time(varname)}} specifies the time identifier variable. if both id and time are not specified, and panel data has been set,
the command will use information from {help svyset} as default. Othewise Both must be specified. {p_end}
{synopt :{cmdab:reps(#)}} specifies the number of bootstrap samples that will be used for the estimation of standard errors. Default is 50  {p_end}
{synopt :{cmdab:seed(#)}} specifies the seed for the generation of bootstrap random samples. Used for replication. {p_end}
{synopt :{cmdab:ml}} Request the estimation using a -pseudo- two-step by mle. See Rios-Avila & Canavire-Bacarreza (2018). This option is not available for cases with 
endogenous variables. {p_end}
{synoptline}
{p2colreset}{...}

INCLUDE help fvvarlist

{p 4 6 2}Weights are not allowed{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:xtheckmanfe} implements the estimation of panel data with selection and endogenous variables, as proposed by Wooldridge(1995)
and Semykina and Wooldridge (2010), based on the parametric correction, and applying Mundlak's (1978) modeling device to model. 
This is in fact, a correlated random effects model. {p_end}

{pstd} This estimator assumes that you have at least an instrument for the selection equation, as well as one instrument for each endogenous variable in the model. {p_end}

{pstd} As such, the selection equation will use as explanatory variables ALL exogenous variables of the outcome model, the instruments for the endogenous variables, 
and the instruments for the selection process. {p_end}

{pstd} If endogeneity exists, this equation will use as explanatory variables ALL exogenous variables of the outcome model, the inverse mills ratio from the selection equation, 
and the instruments to address endogeneity. {p_end}

{pstd} To account for sample selection, the command uses the interaction of the Inverse mills ratios with the time variable in the model specification. {p_end}

{pstd} Standard errors of the model are obtained using a panel bootstrap procedure, using the panel id as cluster. {p_end}

{pstd} If the model assumes selection problem only, one can requests the pseudo two-step approach, which is estimated via -ml-. This standard errors,
which are cluster by the panel id, would already be corrected for the two-step approach. However, because selection and outcome are 
estimated jointly, point estimates will differ from the bootstrap approach. {p_end}

{pstd} Internally, the command creates auxiliary variables with the prefix "_mn_", 
that store the individual specific averages for all exogenous variables. 
The command also creates the variable "_sel_imr", which contains the inverse mills ratio. 
This variables are dropped everytime the command is run. {p_end}
			
{marker examples}{...}
{title:Examples}

{pstd}Setup: Requires you to install ftools {p_end}
{phang2}{stata ssc install ftools}{p_end}

{pstd}For the example, we use the "wagework" data for {help xtheckman}{p_end}
{phang2}{stata "use http://www.stata-press.com/data/r16/wagework.dta, clear"}{p_end}

{pstd}I first estimate the model using the syntax for the official xtheckman command. The next line is only available for users of Stata 16 or above{p_end}
{phang2}{stata "xtheckman wage age tenure, select(working = age market)"}{p_end}

{pstd}The results above can be compared to the results of xtheckmanfe{p_end}
{phang2}{stata "xtheckmanfe wage age tenure, select(working = age market)"}{p_end}

{pstd}Using the pseudo two step approach for xtheckmanfe{p_end}
{phang2}{stata "xtheckmanfe wage age tenure, select(working = age market) ml "}{p_end}

{pstd}The command above, however, uses the information from xtset. If data is not xtset, it would give you an error{p_end}
{phang2}{stata "xtset, clear"}{p_end}
{phang2}{stata "xtheckmanfe wage age tenure, select(working = age market)"}{p_end}

{pstd}In which case you need to xtset the data, or provide the id and time variables:{p_end}
{phang2}{stata "xtheckmanfe wage age tenure, select(working = age market) id(personid) time(year)"}{p_end}

{pstd}Finally, because "age" is already defined in the outcome variable, it is unnecessary to include it in the selection model as well:{p_end}
{phang2}{stata "xtheckmanfe wage age tenure, select(working = market) id(personid) time(year)"}{p_end}

{marker Acknowledgments}{...}
{title:Acknowledgments}

{pstd}
This command was written with the intention of presenting this methodology for an econometrics class.{break}
The basic structure is based on the dofile written by Anastasia Semykina for the two-step parametric approach
that is posted on her website http://myweb.fsu.edu/asemykina/. {break}

{pstd}
The new approach based on pseudo two-step, is based on the strategies suggested in Rios-Avila and Canavire-Bacarreza (2018).

{pstd}
Program has been tested to work under Stata 13.

{marker Author}{...}
{title:Author}

{pstd}
Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org


{marker references}{...}
{title:References}

{phang}
Mundlak, Yair. 1978. "On the Pooling of Time Series and Cross Section Data."  Econometrica 46 (1):69-85. doi: 10.2307/1913646.

{phang}
Rios-Avila, Fernando and Canavire-Bacarreza, Gustavo. 2018. 
"Standard-error correction in two-stage optimization models: A quasi–maximum likelihood estimation approach" 
Stata Journal 18 (1):206-222. doi: 10.1177/1536867X1801800113.


{phang}
Semykina, Anastasia, and Jeffrey M. Wooldridge. 2010. "Estimating panel data models in the presence of endogeneity and selection."
  Journal of Econometrics 157 (2):375-380. doi: https://doi.org/10.1016/j.jeconom.2010.03.039.

{phang}
Wooldridge, Jeffrey M. 1995. "Selection corrections for panel data models under conditional mean independence assumptions." 
 Journal of Econometrics 68 (1):115-132. doi: https://doi.org/10.1016/0304-4076(94)01645-G.

