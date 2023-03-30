{smcl}
{* *! version 1.1 oct 30 2022}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install cv_kfold"}{...}
{vieweralsosee "Help command2 (if installed)" "help ck_kfold"}{...}
{viewerjumpto "Syntax" "cv_kfold##syntax"}{...}
{viewerjumpto "Description" "cv_kfold##description"}{...}
{viewerjumpto "Options" "cv_kfold##options"}{...}
{viewerjumpto "Remarks" "cv_kfold##remarks"}{...}
{viewerjumpto "Examples" "cv_kfold##examples"}{...}
{title:Title}
{phang}
{bf:cv_kfold} {hline 2} Module to implement k-fold cross-validation procedures

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:cv_kfold}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Optional}
{synopt:{opt k(#)}}  Indicates the number of equal sizes subsamples will be used for the estimation of the k-fold cross validation. 
					 Default value is 5. {p_end}
{synopt:{opt reps(#)}}  Indicates times the cross validation procedure will be implemented. Default value is 1.{p_end}
{synopt:{opt seed(str)}}  The author can provide a seed number for the generation of the random groups. {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}This {cmd:cv_kfold} is a post estimation command that implements k-fold crossvalidation for various stata commands. {p_end}

{pstd}The current version of this command can be used after: {cmd:regress}, {cmd:logit}, {cmd:probit}, {cmd:logit}, {cmd:cloglog}, 
{cmd:poisson}, {cmd:nbreg}, {cmd:mlogit}, {cmd:mprobit}, {cmd: ologit}, and {cmd: oprobit}. {p_end}

{pstd}When used after {cmd:regress}, {cmd:cv_kfold} estimates and reports the average unweighted Root Mean Squared error (RMSE) across all repetitions. 
For all other estimation commands, it reports the unweighted model loglikelihood function (AvLL). {p_end}

{pstd}Internally, {cmd:cv_kfold} uses the syntax from the previously estimated command for the k-fold cross validation producedure.
Using the overall estimation sample, {cmd:k} random groups of equalsize are created, and the same previously model syntax is used to re-estimate the model. {p_end}

{pstd}For example, if one uses a 5-folds, 4 of the 5 subsamples are used to estimate the model, leaving the 5th subsample to make an out-of sample prediction
and evaluate the model using the RMSE or the AvLL. when the option reps() is used, the command repeats the k-fold procedure N times, and reports the average RMSE and AVLL
across all repetitions, but stores the estatistics of each individual repetition in a separate matrix.

{pstd} If you are interested in a leave-one-out cross validation procedure 
for {cmd:regress}, see {cmd:cv_regress} available from ssc.

{pstd} The command has been tested under Stata 14. But it does not work with version control.

{marker examples}{...}
{title:Examples}

{pstd} Set up {p_end}

{pstd}{stata ssc install frause}{p_end}
{pstd}{stata set seed 10101}{p_end}
{pstd}{stata frause oaxaca, clear}{p_end}

{pstd} Leave on out cross validation {p_end}

{pstd}{stata ssc install cv_regress}{p_end}
{pstd}{stata regress lnwage educ exper tenure female age agesq }{p_end}
{pstd}{stata cv_regress}{p_end}

{pstd} k-fold cross validation {p_end}

{pstd}{stata regress lnwage educ exper tenure female age agesq }{p_end}
{pstd}{stata cv_kfold}{p_end}

{pstd} k-fold cross validation, with 5 repetitions {p_end}

{pstd}{stata regress lnwage educ exper tenure female age agesq }{p_end}
{pstd}{stata cv_kfold, reps(5) }{p_end}
{pstd}{stata matrix list r(msqr) }{p_end}
 
{pstd} k-fold for other type of models. Logit, poisson and mlogit {p_end}

{pstd}{stata "drop if lnwage==." } {p_end}
{pstd}{stata "gen dwage=lnwage>3.4" } {p_end}
{pstd}{stata "gen wage=round(exp(lnwage))"}{p_end} 
{pstd}{stata "xtile qwage=lnwage, n(5) "}{p_end} 
{pstd}{stata "logit dwage educ exper tenure female age agesq" }{p_end} 
{pstd}{stata "cv_kfold, reps(5)" }{p_end}
{pstd}{stata "matrix list r(msqr)" } 

{pstd} Currently, Poisson model only works if the Dep variable is {p_end}
{pstd}{stata "poisson wage educ exper tenure female age agesq"}{p_end} 
{pstd}{stata "cv_kfold, reps(5) "}{p_end}
{pstd}{stata "matrix list r(msqr) "} {p_end}

{pstd}{stata "mlogit qwage educ exper tenure female age agesq"}{p_end} 
{pstd}{stata "cv_kfold, reps(5)" }{p_end}
{pstd}{stata "matrix list r(msqr)" } {p_end}

{pstd}{stata "ologit qwage educ exper tenure female age agesq"}{p_end} 
{pstd}{stata "cv_kfold, reps(5)" }{p_end}
{pstd}{stata "matrix list r(msqr)" } {p_end}

{title:Author}

{pstd}
Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org

{title:Acknowledgement }

     Many thanks to Morteza Saharkhiz for suggesting extending he command to ologit and oprobit models.

{title:Also see}

{p 4 14 2}

Help:  {helpb cv_regress} 



