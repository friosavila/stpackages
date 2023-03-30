{smcl}
{* *! version 2.0 Fernando Rios-Avila September 2020}{...}
{cmd:help f_able}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{cmd:f_able} {hline 2}} Module for the estimation of marginal effects with transformed covariates{p_end}
{p2colreset}{...}


{title:Syntax}

{phang}
Create new variable with label {it:exp}. The newly created variable is stored with format {cmd:double}.

{p 8 17 2}
{opt fgen}
{newvar} {cmd:=}{it:{help exp}}

{phang}
Replace contents of existing variable and change label

{p 8 17 2}
{cmd:frep}
{it:oldvar}
{cmd:=}{it:{help exp}}

{phang}
Declares which variables in the specification are "constructed/transformed" variables.  

{p 8 17 2}
{cmd:f_able} [varlist] {cmd:,} {cmdab:nl:var(varlist)} [auto]

{phang}
Automatically detects which variables in a regression are "constructed/transformed" variables.  

{p 8 17 2}
{cmd:f_reg} {cmd:command} depvar [indepvars] [if in] [weights], [command options]
 
{phang}
Resets stored in e() to the original ones

{p 8 17 2}
{cmd:f_able_reset}  

{phang}
Makes the variance covariance matrix stored in e(V) symetric, when nonsymmetric warning appears

{p 8 17 2}
{cmd:f_symev}  

{phang}
Makes the variance covariance matrix stored in r(V) symetric, when nonsymmetric warning appears

{p 8 17 2}
{cmd:f_symrv}  

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}

{p2coldent : {opt newvar}} Stands for a new variable to be created with the format of choice. Its suggested to create them in double format. {p_end}
{p2coldent : {opt oldvar}} Stands for the name of a variable already in the dataset. {p_end}
{p2coldent : {opt exp}} stands for any expression to be used for creating or replacing the values of the variable. This will be used as the variable label.
if the expresion is longer than 75 characters, the expression will be stored as a {cmd:note} in that variable. {p_end}
{p2coldent : {opt nlvar(varlist)}} is used to indicate all variables in the model that are constructed variables. They can also be declared as a varlist after {cmd:f_able}.
These variables must be present in the estimated model, and should be labelled accordingly. {cmd:fgen} and {cmd:frep} 
are used to help with the proper variable labeling. {p_end}
{p2coldent : {opt auto}} can be used to declare the set of covariates in the model, excluding the constructed variables. This 
may facilitate the use of {cmd:margins}, without using options nochain or numerical. This is an experimental feature.

{synoptline}
{pstd}

{title:Description}

{pstd}
{cmd:f_able} is a command that can be used to enable margins to correctly estimate 
marginal effects when using transformed/constructed data.

{pstd}
Internally, this command adds information to e() that is later used by the estimation 
{cmd:predict} command, so that constructed data is handled correctly.

{pstd}
The command f_able_reset is used to reset the information in e() to the values before 
f_able was used.

{pstd}
The commands {cmd:fgen} and {cmd:frep} are used to create or replace variables storing the 
expression used for their creation as labels. If the expression is longer than 75 characters, 
it assigns the label "See note", and the note will contain the used expression.

{pstd}
When creating the new variables with {cmd:fgen}, they will be stored with double precision.

{pstd}
See Rios-Avila(2020) for brief discussion on the estimation of marginal effects, and how the command works.

{title:Examples}

{pstd}
{bf:. {stata "webuse dui, clear"}}{p_end}

{pstd}Example 1{p_end}
{pstd}Replication of margins when using factor notation and interactions. {p_end}
{pstd}First, using factor notation{p_end}

{pstd}
{bf:. {stata "reg citations fines c.fines#c.fines"}}{p_end}
{pstd}{bf:. {stata "margins, dydx(fines)"}}{p_end}

{pstd}Replicating this using f_able{p_end}

{pstd}{bf:. {stata "fgen fines2=fines^2"}}{p_end}
{pstd}{bf:. {stata "reg citations fines fines2"}}{p_end}
{pstd}{bf:. {stata "f_able, nlvar(fines2)"}}{p_end}

{pstd}Margins need to include the option nochain{p_end}
{pstd}{bf:. {stata "margins, dydx(fines) nochain"}}{p_end}

{pstd}Same in 1-step{p_end}
{pstd}{bf:. {stata "freg reg citations fines fines2"}}{p_end}
{pstd}{bf:. {stata "margins, dydx(fines) nochain"}}{p_end}


{pstd}Example 2{p_end}
{pstd} Using spline transformations. Quadratic spline, with 1 knot {p_end}
{pstd}{bf:. {stata "fgen fines3=max(fines-9.9,0)^2"}}{p_end}

{pstd}Option 1{p_end}
{pstd}{bf:. {stata "reg citations fines fines2 fines3"}}{p_end}
{pstd}{bf:. {stata "f_able, nlvar(fines2 fines3)"}}{p_end}
{pstd}Option 2{p_end}
{pstd}{bf:. {stata "f_reg reg citations fines fines2 fines3"}}{p_end}

{pstd} Estimating marginal effects{p_end}
{pstd}{bf:. {stata "margins, dydx(fines) nochain"}}{p_end}

{pstd} Estimating marginal effects across various points of fines, and plotting. {p_end}
{pstd}{bf:. {stata "margins, dydx(fines) nochain at(fines=(7.5(.25)12)) plot"}}{p_end}

{pstd} Estimating marginal means across various points of fines, and plotting. {p_end}
{pstd}{bf:. {stata "margins, nochain at(fines=(7.5(.25)12)) plot"}}{p_end}

{pstd}Example 3{p_end}
{pstd} Using an inverse transformation excluding the original variable {p_end}
{pstd}{bf:. {stata "frep fines2=1/fines"}}{p_end}
{pstd}{bf:. {stata "reg citations o.fines fines2"}}{p_end}
{pstd}{bf:. {stata "f_able, nlvar(fines2)"}}{p_end}
{pstd}{bf:. {stata "margins, dydx(fines) nochain"}}{p_end}

{pstd}Example 4{p_end}
{pstd} Using other nonlinear estimators like {cmd:poisson} {p_end}
{pstd}{bf:. {stata "poisson citations c.fines c.fines#c.fines, robust"}}{p_end}
{pstd}{bf:. {stata "margins, dydx(fines)"}}{p_end}

{pstd} Replicating it with f_able {p_end}
{pstd}{bf:. {stata "frep fines2=fines^2"}}{p_end}
{pstd}{bf:. {stata "poisson citations fines fines2, robust"}}{p_end}
{pstd}{bf:. {stata "f_able, nlvar(fines2)"}}{p_end}

{pstd} This will give incorrect results.  {p_end}
{pstd}{bf:. {stata "margins, dydx(fines) nochain"}}{p_end}

{pstd} Instead, one must use option numerical to force numerical derivatives{p_end}
{pstd}{bf:. {stata "margins, dydx(fines) nochain numerical"}}{p_end}

{pstd}Example 5{p_end}
{pstd} Going back to the OLS model, I now estimate the equivalent to a Varying Coefficient models
making use of both factor notation and f_able. {p_end}
{pstd} I choose this particular problem because it shows some of the problems that may arise using f_able {p_end}
{pstd}{bf:. {stata "webuse dui, clear"}}{p_end}
{pstd}{bf:. {stata "fgen   fines2=fines^2"}}{p_end}
{pstd}{bf:. {stata "fgen   fines3=fines^3"}}{p_end}
{pstd}{bf:. {stata "fgen   fines4=max(fines-9.1,0)^3"}}{p_end}
{pstd}{bf:. {stata "fgen   fines5=max(fines-9.9,0)^3"}}{p_end}
{pstd}{bf:. {stata "fgen   fines6=max(fines-11.1,0)^3"}}{p_end}
{pstd}{bf:. {stata "reg citations fines fines2 fines3 fines4 fines5 fines6 i.csize i.csize#c.(fines fines2 fines3 fines4 fines5 fines6)"}}{p_end}
{pstd}{bf:. {stata "f_able fines2 fines3 fines4 fines5 fines6, auto"}}{p_end}

{pstd} This may fail because of the complexity of the model{p_end}
{pstd}{bf:. {stata "margins, dydx(fines) nochain "}}{p_end}

{pstd} One solution is to add the {cmd:noestimcheck} option {p_end}
{pstd}{bf:. {stata "margins, dydx(fines) nochain noestimcheck"}}{p_end}

{pstd} Estimating margins across various values of fines {p_end}
{pstd}{bf:. {stata "margins, dydx(fines) nochain noestimcheck at(fines=(8(.5)11.5)) plot"}}{p_end}
{pstd}{bf:. {stata "margins, nochain noestimcheck at(fines=(8(.5)11.5)) plot"}}{p_end}

{pstd} The commands may shows no standard errors. One solution is to use f_symrv before plotting{p_end}
{pstd}{bf:. {stata "margins, dydx(fines) nochain noestimcheck at(fines=(8(.5)11.5)) "}}{p_end}
{pstd}{bf:. {stata "f_symrv"}}{p_end}
{pstd}{bf:. {stata "marginsplot"}}{p_end}

{pstd}{bf:. {stata "margins, nochain noestimcheck at(fines=(8(.5)11.5)) "}}{p_end}
{pstd}{bf:. {stata "f_symrv"}}{p_end}
{pstd}{bf:. {stata "marginsplot"}}{p_end}

{pstd}Example 6{p_end}
{pstd} One can also use post, and correct e(V) with f_symev {p_end}
{pstd}{bf:. {stata "margins, dydx(fines) nochain noestimcheck at(fines=(8(.5)11.5)) post"}}{p_end}
{pstd}{bf:. {stata "f_symev"}}{p_end}
{pstd}{bf:. {stata "margins"}}{p_end}

{pstd}Example 7{p_end}
{pstd} Marginal effects for other variables in model will be the same with and without f_able, with small differences in point estimates {p_end}
{pstd}{bf:. {stata "qui:reg citations fines fines2 fines3 fines4 fines5 fines6 i.csize i.csize#c.(fines fines2 fines3 fines4 fines5 fines6)"}}{p_end}
{pstd}{bf:. {stata "qui:f_able fines2 fines3 fines4 fines5 fines6, auto"}}{p_end}

{pstd}{bf:. {stata "margins, dydx(csize) noestimcheck"}}{p_end}
{pstd}{bf:. {stata "margins, dydx(csize) noestimcheck nochain"}}{p_end}
{pstd}{bf:. {stata "f_able_reset"}}{p_end}
{pstd}{bf:. {stata "margins, dydx(csize) noestimcheck"}}{p_end}
{pstd}{bf:. {stata "margins, dydx(csize) noestimcheck nochain"}}{p_end}

{pstd} But can still be corrected using f_symrv, and reported using _coef_table {p_end}
{pstd}{bf:. {stata "f_able, nlvar(fines2 fines3 fines4 fines5 fines6)"}}{p_end}
{pstd}{bf:. {stata "margins, dydx(csize) noestimcheck nochain"}}{p_end}
{pstd}{bf:. {stata "f_symrv"}}{p_end}
{pstd}{bf:. {stata "matrix bts=r(b)"}}{p_end}
{pstd}{bf:. {stata "matrix vcv=r(V)"}}{p_end}
{pstd}{bf:. {stata "_coef_table, bmatrix(bts) vmatrix(vcv)"}}{p_end}

{pstd}{bf:. {stata "f_able_reset"}}{p_end}
{pstd}{bf:. {stata "margins, dydx(csize) noestimcheck  "}}{p_end}
{pstd}{bf:. {stata "f_symrv"}}{p_end}
{pstd}{bf:. {stata "matrix bts=r(b)"}}{p_end}
{pstd}{bf:. {stata "matrix vcv=r(V)"}}{p_end}
{pstd}{bf:. {stata "_coef_table, bmatrix(bts) vmatrix(vcv)"}}{p_end}

{pstd} Nevertheless one can still use this to estimate point estimates, without further manipulation{p_end}

{pstd}Example 8{p_end}
{pstd} Another use of f_able could be in combination with fractional polynomials {p_end}

{pstd}{bf:. {stata "webuse igg, clear"}}{p_end}
{pstd}{bf:. {stata "fp <age>: regress sqrtigg <age>"}}{p_end}

{pstd} As before, we create the new variables based on the selected model, and use f_able to enable margins{p_end}
{pstd}{bf:. {stata "fgen age1=age^-2"}}{p_end}
{pstd}{bf:. {stata "fgen age2=age^2"}}{p_end}
{pstd}{bf:. {stata "regress sqrtigg age1 age2 o.age"}}{p_end}
{pstd}{bf:. {stata "f_able, nlvar(age1 age2)"}}{p_end}
{pstd}{bf:. {stata "margins, dydx(age) nochain"}}{p_end}
{pstd} It does require the option noestimcheck to get results for various points in the distribution of age {p_end}
{pstd}{bf:. {stata "margins, dydx(age) nochain noestimcheck at(age=(1(0.5)6)) plot" }}{p_end}
{pstd}{bf:. {stata "margins, nochain noestimcheck at(age=(1(0.5)6)) plot"}}{p_end}

{pstd}Example 9{p_end}

{pstd} now and even more complex, multiple equation model like mlogit {p_end}
{pstd}{bf:. {stata "webuse sysdsn1, clear"}}{p_end}
{pstd}{bf:. {stata "mlogit insure age c.age#c.age male nonwhite i.site"}}{p_end}
{pstd}{bf:. {stata "margins, dydx(age)"}}{p_end}

{pstd} Using f_able {p_end}
{pstd}{bf:. {stata "fgen double age2=age^2"}}{p_end}
{pstd}{bf:. {stata "mlogit insure age age2 male nonwhite i.site"}}{p_end}
{pstd}{bf:. {stata "f_able, nlvar(age2)"}}{p_end}
{pstd}{bf:. {stata "margins, dydx(age) nochain numerical"}}{p_end}

{pstd}Example 10{p_end}

{pstd} and now using {cmd:fp} {p_end}
{pstd}{bf:. {stata "fp <age>, dim(3):mlogit insure <age> male nonwhite i.site"}}{p_end}
{pstd}{bf:. {stata "drop age2"}}{p_end}
{pstd}{bf:. {stata "fgen age2=age^2"}}{p_end}
{pstd}{bf:. {stata "fgen age3=log(age)*age^2"}}{p_end}

{pstd}{bf:. {stata "mlogit insure age age2 age3 male nonwhite i.site"}}{p_end}
{pstd}{bf:. {stata "f_able, nlvar(age2 age3)"}}{p_end}
{pstd}{bf:. {stata "margins, dydx(age) nochain numerical"}}{p_end}

{pstd}Example 11{p_end}
{pstd} As shown before, the options nochain and numeric are not necessary 
if "age" is not of interest (assumed fixed) {p_end}

{pstd}{bf:. {stata "margins, dydx( male nonwhite i.site) "}}{p_end}
{pstd}{bf:. {stata "margins, dydx( male nonwhite i.site) nochain numerical"}}{p_end}

{pstd}Example 12{p_end}
{pstd} And just for completeness we estimate the effects across various points of the age {p_end}

{pstd}{bf:. {stata "margins, dydx(age) nochain numerical at(age=(25(5)80)) plot"}}{p_end}
{pstd}{bf:. {stata "margins, nochain numerical at(age=(25(5)80)) plot"}}{p_end}

{pstd}Example 13{p_end}
{pstd} Using alternative syntax, and option auto {p_end}

{pstd}{bf:. {stata "webuse sysdsn1, clear"}}{p_end}
{pstd}{bf:. {stata "mlogit insure age c.age#c.age male"}}{p_end}
{pstd}{bf:. {stata "margins, dydx(*)"}}{p_end}

{pstd}{bf:. {stata "fgen age2=age*age"}}{p_end}
{pstd}{bf:. {stata "mlogit insure age age2 male"}}{p_end}
{pstd}{bf:. {stata "f_able age2, auto"}}{p_end}
{pstd}{bf:. {stata "margins, dydx(*)"}}{p_end}

{title:References}

{phang}
Rios-Avila, F. 2021.  Estimation of marginal effects for models with alternative variable transformations.  Stata Journal 21: 81-96. https://doi.org/10.1177/1536867X211000005.

{marker Acknowledgments}{...}
{title:Acknowledgments}

{pstd}
This program was inspired by some discussions with Enrique Pinzon who described with some detail the workings behind
{help npregress series}, and behind {help margins}. 

{pstd}
All errors are my own.

{marker Author}{...}
{title:Author}

{pstd}
Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org


{title:Also see}

{p 7 14 2}
Help:  {helpb margins}, {helpb predict}, {helpb f_spline}, {helpb f_rcspline},  {helpb _coef_table}  {p_end}
