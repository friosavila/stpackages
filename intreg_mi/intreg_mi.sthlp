{smcl}
{* *! version 1.0  October 2021 }{...}
 
{title:Title}

{phang}
{bf:intreg_mi} {hline 2} Module for creation of imputed values from an Interval regression model, for Multiple Imputation


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:intreg_mi} {it:stub} [if] [in] [{cmd:,} ] [replace reps(#) seed(str)] 

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt stub}} The command will create a series of new simulated variables, based on a previously -intreg- model. All new variables
will start with {it:stub}#, where # represents the number repetion.  {p_end}
{synopt:{opt replace}} By default, the command assumes all {it:stub}#, are new variables. This option allows to overwrite them
if the name already exists in memory. {p_end}
{synopt:{opth reps(#)}} Specifies the number of simulated elements to produce. the default its 10{p_end}
{synopt:{opth seed(str)}} For replication purposes, it is possible to provide a seed number {p_end}

{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:intreg_mi} is a post-estimation utility for the generation of imputed values, based on a previously estimated interval regression model {help intreg}. {p_end}

{pstd}
The new variables are ment to be used for the analysis of inequality using a multiple imputation approach. {p_end} 
{pstd}
The command assumes that you have previously estimated an interval regression model, allowing for heteroskedastic errors. 
Given the estimated coefficients, their estimated errors, and the implicit conditional error variance, the command will simulate 
values for the underlying censored data, conditional the restrictions impoused in the censored data. {p_end}

{pstd}Under the assumption of conditional normality, the goal is to use a flexible enough conditional mean and conditional variance model, so it is possible to identify the conditional distribution of censored data. {p_end}

{pstd}Once multiple imputed draws are obtained, stub1, stub2,..., stub10, the imputed data can be analyzed using Stata's multiple imputation suit {help mi}.{p_end}

{pstd}See example for details on the use of the command. {p_end}
 
{marker Acknowledgments}
{title: Acknowledgments}

{pstd}
This program was created for the analyzis of censored income data for Grenada, as part of a project with the World Bank. {p_end}

{pstd}
All errors are my own.


{marker examples}{...}
{title:Examples}

{pstd} This example will use an excerpt from the Swiss Labor Market Survey 1998) {p_end}

{phang} Data Preparation. This includes getting the lower and upper thresholds based on censoring rules {p_end}
{phang} ======================================================================={p_end}
{smcl}
{com}. use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta, clear
{txt}(Excerpt from the Swiss Labor Market Survey 1998)

{com}. drop if lnwage==.
{txt}(213 observations deleted)

{com}. gen wage = exp(lnwage)
{txt}
. recode wage (0 /20=1) (20 /30=2) (30 /40=3 ) (40 /50=4) (50 /200=5), gen(cwage)
{txt}(1434 differences between {bf:wage} and {bf:cwage})

{com}. gen low_wage=0 if cwage==1
{txt}(1,205 missing values generated)

{com}. replace low_wage=20 if cwage==2
{txt}(482 real changes made)

{com}. replace low_wage=30 if cwage==3
{txt}(407 real changes made)

{com}. replace low_wage=40 if cwage==4
{txt}(173 real changes made)

{com}. replace low_wage=50 if cwage==5
{txt}(143 real changes made)

{com}. 
. gen high_wage=20 if cwage==1
{txt}(1,205 missing values generated)

{com}. replace high_wage=30 if cwage==2
{txt}(482 real changes made)

{com}. replace high_wage=40 if cwage==3
{txt}(407 real changes made)

{com}. replace high_wage=50 if cwage==4
{txt}(173 real changes made)

{com}. replace high_wage=.  if cwage==5
{txt}(0 real changes made)

{com}. 
. gen loglow_wage =log(low_wage)
{txt}(229 missing values generated)

{com}. gen loghigh_wage=log(high_wage)
{txt}(143 missing values generated)


{phang} Estimation of Interval regression model for imputation {p_end}
{phang} ======================================================{p_end}
{com}. 
. intreg loglow_wage loghigh_wage educ exper tenure  female age agesq married divorced kids6 kids714, het(educ exper tenure  female age agesq married divorced kids6 kids714)

{txt}Fitting full model:
{res}
{txt}Iteration 0:{space 3}log likelihood = {res:-2545.9831}  
Iteration 1:{space 3}log likelihood = {res:-2224.0343}  (not concave)
Iteration 2:{space 3}log likelihood = {res:-2020.7706}  (not concave)
Iteration 3:{space 3}log likelihood = {res:-1984.0957}  
Iteration 4:{space 3}log likelihood = {res:-1913.0813}  
Iteration 5:{space 3}log likelihood = {res:-1832.1535}  
Iteration 6:{space 3}log likelihood = {res:-1818.9823}  
Iteration 7:{space 3}log likelihood = {res:-1818.8992}  
Iteration 8:{space 3}log likelihood = {res:-1818.8991}  
{res}
{txt}{col 1}Interval regression{col 53}{lalign 17:Number of obs}{col 70} = {res}{ralign 6:1,434}
{txt}{col 53}{ralign 17:Uncensored}{col 70} = {res}{ralign 6:0}
{txt}{col 53}{ralign 17:Left-censored}{col 70} = {res}{ralign 6:229}
{txt}{col 53}{ralign 17:   Right-censored}{col 70} = {res}{ralign 6:143}
{txt}{col 53}{ralign 17:Interval-cens.}{col 70} = {res}{ralign 6:1,062}

{txt}{col 53}{lalign 17:Wald chi2({res:10})}{col 70} = {res}{ralign 6:606.73}
{txt}{col 1}{lalign 14:Log likelihood}{col 15} = {res}{ralign 10:-1818.8991}{txt}{col 53}{lalign 17:Prob > chi2}{col 70} = {res}{ralign 6:0.0000}

{txt}{hline 13}{c TT}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}
{col 14}{c |} Coefficient{col 26}  Std. err.{col 38}      z{col 46}   P>|z|{col 54}     [95% con{col 67}f. interval]
{hline 13}{c +}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}
{res}model        {txt}{c |}
{space 8}educ {c |}{col 14}{res}{space 2} .0527769{col 26}{space 2}  .004389{col 37}{space 1}   12.02{col 46}{space 3}0.000{col 54}{space 4} .0441746{col 67}{space 3} .0613793
{txt}{space 7}exper {c |}{col 14}{res}{space 2}-.0021238{col 26}{space 2} .0015868{col 37}{space 1}   -1.34{col 46}{space 3}0.181{col 54}{space 4}-.0052338{col 67}{space 3} .0009862
{txt}{space 6}tenure {c |}{col 14}{res}{space 2} .0039313{col 26}{space 2} .0015114{col 37}{space 1}    2.60{col 46}{space 3}0.009{col 54}{space 4} .0009689{col 67}{space 3} .0068937
{txt}{space 6}female {c |}{col 14}{res}{space 2}-.1298246{col 26}{space 2} .0203583{col 37}{space 1}   -6.38{col 46}{space 3}0.000{col 54}{space 4}-.1697261{col 67}{space 3}-.0899232
{txt}{space 9}age {c |}{col 14}{res}{space 2} .0659981{col 26}{space 2} .0069001{col 37}{space 1}    9.56{col 46}{space 3}0.000{col 54}{space 4} .0524741{col 67}{space 3} .0795221
{txt}{space 7}agesq {c |}{col 14}{res}{space 2} -.000675{col 26}{space 2} .0000857{col 37}{space 1}   -7.88{col 46}{space 3}0.000{col 54}{space 4}-.0008429{col 67}{space 3} -.000507
{txt}{space 5}married {c |}{col 14}{res}{space 2} .0064243{col 26}{space 2} .0250796{col 37}{space 1}    0.26{col 46}{space 3}0.798{col 54}{space 4}-.0427309{col 67}{space 3} .0555795
{txt}{space 4}divorced {c |}{col 14}{res}{space 2} .0169042{col 26}{space 2} .0353692{col 37}{space 1}    0.48{col 46}{space 3}0.633{col 54}{space 4}-.0524181{col 67}{space 3} .0862265
{txt}{space 7}kids6 {c |}{col 14}{res}{space 2}  .033832{col 26}{space 2} .0149031{col 37}{space 1}    2.27{col 46}{space 3}0.023{col 54}{space 4} .0046224{col 67}{space 3} .0630416
{txt}{space 5}kids714 {c |}{col 14}{res}{space 2} .0173022{col 26}{space 2}  .017022{col 37}{space 1}    1.02{col 46}{space 3}0.309{col 54}{space 4}-.0160603{col 67}{space 3} .0506647
{txt}{space 7}_cons {c |}{col 14}{res}{space 2} 1.366304{col 26}{space 2} .1280931{col 37}{space 1}   10.67{col 46}{space 3}0.000{col 54}{space 4} 1.115246{col 67}{space 3} 1.617361
{txt}{hline 13}{c +}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}
{res}lnsigma      {txt}{c |}
{space 8}educ {c |}{col 14}{res}{space 2} .0160979{col 26}{space 2} .0114969{col 37}{space 1}    1.40{col 46}{space 3}0.161{col 54}{space 4}-.0064356{col 67}{space 3} .0386314
{txt}{space 7}exper {c |}{col 14}{res}{space 2}-.0118936{col 26}{space 2} .0041351{col 37}{space 1}   -2.88{col 46}{space 3}0.004{col 54}{space 4}-.0199982{col 67}{space 3} -.003789
{txt}{space 6}tenure {c |}{col 14}{res}{space 2} .0025021{col 26}{space 2} .0041526{col 37}{space 1}    0.60{col 46}{space 3}0.547{col 54}{space 4}-.0056369{col 67}{space 3} .0106411
{txt}{space 6}female {c |}{col 14}{res}{space 2} .2987165{col 26}{space 2} .0544707{col 37}{space 1}    5.48{col 46}{space 3}0.000{col 54}{space 4}  .191956{col 67}{space 3}  .405477
{txt}{space 9}age {c |}{col 14}{res}{space 2}-.0267994{col 26}{space 2} .0194971{col 37}{space 1}   -1.37{col 46}{space 3}0.169{col 54}{space 4}-.0650129{col 67}{space 3} .0114142
{txt}{space 7}agesq {c |}{col 14}{res}{space 2} .0005063{col 26}{space 2} .0002382{col 37}{space 1}    2.13{col 46}{space 3}0.034{col 54}{space 4} .0000394{col 67}{space 3} .0009732
{txt}{space 5}married {c |}{col 14}{res}{space 2} .0310129{col 26}{space 2} .0691083{col 37}{space 1}    0.45{col 46}{space 3}0.654{col 54}{space 4}-.1044369{col 67}{space 3} .1664627
{txt}{space 4}divorced {c |}{col 14}{res}{space 2} .1554858{col 26}{space 2} .0892263{col 37}{space 1}    1.74{col 46}{space 3}0.081{col 54}{space 4}-.0193945{col 67}{space 3}  .330366
{txt}{space 7}kids6 {c |}{col 14}{res}{space 2}-.0878559{col 26}{space 2} .0487257{col 37}{space 1}   -1.80{col 46}{space 3}0.071{col 54}{space 4}-.1833566{col 67}{space 3} .0076448
{txt}{space 5}kids714 {c |}{col 14}{res}{space 2} .1256378{col 26}{space 2} .0438562{col 37}{space 1}    2.86{col 46}{space 3}0.004{col 54}{space 4} .0396812{col 67}{space 3} .2115943
{txt}{space 7}_cons {c |}{col 14}{res}{space 2}-1.195794{col 26}{space 2} .3788139{col 37}{space 1}   -3.16{col 46}{space 3}0.002{col 54}{space 4}-1.938256{col 67}{space 3}-.4533329
{txt}{hline 13}{c BT}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}


{phang} Using {cmd: intreg_mi} to impute the data {p_end}
{phang} ========================================={p_end}

{com}. intreg_mi ilwage, seed(10)
{res}{txt}
{com}. 

{phang} Creating variable for "missing" values{p_end}
{phang} ========================================={p_end}
. gen ilogwage = .
{txt}(1,434 missing values generated)

{phang} Save dataset in memory. Possible using tempfiles. 
This step is required to import mi data{p_end}
{phang} ========================================={p_end}
{com}. tempfile tosave
{txt}
{com}. save `tosave'
{txt}{p 0 4 2}
file {bf}
C:\Users\user\AppData\Local\Temp\ST_5b0_000002.tmp{rm}
saved
as .dta format
{p_end}

{phang} Import the imputed variables ilwage* into {help mi} enviroment.{p_end}
{phang} =========================================================={p_end}

{com}. 
. mi import wide, imputed(ilogwage=  ilwage* )
{res}{txt}

{phang} And create a new (passive) variable, to recover wage itself {p_end}
{phang} =========================================================={p_end}

{com}. mi passive: gen iwage = exp(ilogwage) 
{res}{txt}{it:m}=0:
(1,434 missing values generated)
{res}{txt}{it:m}=1:
{res}{txt}{it:m}=2:
{res}{txt}{it:m}=3:
{res}{txt}{it:m}=4:
{res}{txt}{it:m}=5:
{res}{txt}{it:m}=6:
{res}{txt}{it:m}=7:
{res}{txt}{it:m}=8:
{res}{txt}{it:m}=9:
{res}{txt}{it:m}=10:
{res}{txt}

{phang} For the following, you need to install -rif-{p_end}
{phang} =========================================================={p_end}

{com}. ssc install rif, replace 
{com}. 
. mi estimate, cmdok: rifmean iwage, rif(gini, entropy(1))
{res}
{txt}Multiple-imputation estimates{col 49}Imputations{col 67}= {res}        10
{txt}Mean estimation{col 49}Number of obs{col 67}= {res}     1,434
{txt}{col 49}Average RVI{col 67}= {res}    0.8036
{txt}{col 49}Largest FMI{col 67}= {res}    0.5433
{txt}{col 49}Complete DF{col 67}= {res}      1433
{txt}DF adjustment:{ralign 15: {res:Small sample}}{col 49}DF:     min{col 67}= {res}     32.18
{txt}{col 49}        avg{col 67}= {res}     38.31
{txt}Within VCE type: {ralign 12:{res:Analytic}}{col 49}        max{col 67}= {res}     44.43

{txt}{hline 13}{c TT}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}
{col 1}        Mean{col 14}{c |} Coefficient{col 26}  Std. err.{col 38}      t{col 46}   P>|t|{col 54}     [95% con{col 67}f. interval]
{hline 13}{c +}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}
{space 1}rif_iwage_1 {c |}{col 14}{res}{space 2} .2307596{col 26}{space 2} .0072971{col 37}{space 1}   31.62{col 46}{space 3}0.000{col 54}{space 4} .2160572{col 67}{space 3} .2454619
{txt}{space 1}rif_iwage_2 {c |}{col 14}{res}{space 2} .0903457{col 26}{space 2} .0081751{col 37}{space 1}   11.05{col 46}{space 3}0.000{col 54}{space 4} .0736972{col 67}{space 3} .1069942
{txt}{hline 13}{c BT}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}
{res}{txt}
{com}. rifmean wage, rif(gini, entropy(1))
{res}
{txt}{col 1}Mean estimation{col 42}{lalign 13:Number of obs}{col 55} = {res}{ralign 5:1,434}

{txt}{hline 13}{c TT}{hline 11}{hline 11}{hline 14}{hline 12}
{col 14}{c |}       Mean{col 26}   Std. err.{col 38}     [95% con{col 51}f. interval]
{hline 13}{c +}{hline 11}{hline 11}{hline 14}{hline 12}
{space 2}rif_wage_1 {c |}{col 14}{res}{space 2} .2460329{col 26}{space 2} .0064995{col 37}{space 5} .2332833{col 51}{space 3} .2587825
{txt}{space 2}rif_wage_2 {c |}{col 14}{res}{space 2} .1091853{col 26}{space 2} .0069857{col 37}{space 5} .0954821{col 51}{space 3} .1228885
{txt}{hline 13}{c BT}{hline 11}{hline 11}{hline 14}{hline 12}
rif_wage_1: RIF for gini of wage
rif_wage_2: RIF for Entropy alpha=1 of wage

{com}. 
. mi estimate, cmdok: qreg ilogwage  educ exper tenure female age  , q(90)
{res}
{txt}Multiple-imputation estimates{col 49}Imputations{col 67}= {res}        10
{txt}.9 Quantile regression{col 49}Number of obs{col 67}= {res}     1,434
{txt}{col 49}Average RVI{col 67}= {res}    0.7467
{txt}{col 49}Largest FMI{col 67}= {res}    0.5583
{txt}{col 49}Complete DF{col 67}= {res}      1428
{txt}DF adjustment:{ralign 15: {res:Small sample}}{col 49}DF:     min{col 67}= {res}     30.48
{txt}{col 49}        avg{col 67}= {res}     52.50
{txt}{col 49}        max{col 67}= {res}     72.21
{txt}Model F test:{ralign 16: {res:Equal FMI}}{col 49}F({res}   5{txt},{res}  189.2{txt}){col 67}= {res}     30.59
{txt}Within VCE type: {ralign 12:{res:IID}}{col 49}Prob > F{col 67}= {res}    0.0000

{txt}{hline 13}{c TT}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}
{col 1}    ilogwage{col 14}{c |} Coefficient{col 26}  Std. err.{col 38}      t{col 46}   P>|t|{col 54}     [95% con{col 67}f. interval]
{hline 13}{c +}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}
{space 8}educ {c |}{col 14}{res}{space 2} .0621284{col 26}{space 2} .0093043{col 37}{space 1}    6.68{col 46}{space 3}0.000{col 54}{space 4} .0434315{col 67}{space 3} .0808253
{txt}{space 7}exper {c |}{col 14}{res}{space 2}-.0067224{col 26}{space 2} .0032487{col 37}{space 1}   -2.07{col 46}{space 3}0.043{col 54}{space 4}-.0132229{col 67}{space 3}-.0002218
{txt}{space 6}tenure {c |}{col 14}{res}{space 2}  .000114{col 26}{space 2} .0032907{col 37}{space 1}    0.03{col 46}{space 3}0.972{col 54}{space 4}-.0064455{col 67}{space 3} .0066735
{txt}{space 6}female {c |}{col 14}{res}{space 2}-.0221343{col 26}{space 2}  .043778{col 37}{space 1}   -0.51{col 46}{space 3}0.615{col 54}{space 4}-.1097861{col 67}{space 3} .0655174
{txt}{space 9}age {c |}{col 14}{res}{space 2}  .022129{col 26}{space 2} .0031666{col 37}{space 1}    6.99{col 46}{space 3}0.000{col 54}{space 4} .0157582{col 67}{space 3} .0284998
{txt}{space 7}_cons {c |}{col 14}{res}{space 2} 2.329244{col 26}{space 2} .1446159{col 37}{space 1}   16.11{col 46}{space 3}0.000{col 54}{space 4} 2.034094{col 67}{space 3} 2.624393
{txt}{hline 13}{c BT}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}
{res}{txt}
{com}. qreg lnwage  educ exper tenure female age  , q(90) nolog
{res}
{txt}.9 Quantile regression{col 53}Number of obs = {res}     1,434
{txt}  Raw sum of deviations{res} 113.3647{txt} (about {res}3.9110236{txt})
  Min sum of deviations{res} 95.54951{col 53}{txt}Pseudo R2     = {res}    0.1571

{txt}{hline 13}{c TT}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}
{col 1}      lnwage{col 14}{c |} Coefficient{col 26}  Std. err.{col 38}      t{col 46}   P>|t|{col 54}     [95% con{col 67}f. interval]
{hline 13}{c +}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}
{space 8}educ {c |}{col 14}{res}{space 2} .0605548{col 26}{space 2} .0070932{col 37}{space 1}    8.54{col 46}{space 3}0.000{col 54}{space 4} .0466407{col 67}{space 3} .0744689
{txt}{space 7}exper {c |}{col 14}{res}{space 2}-.0040886{col 26}{space 2}  .002556{col 37}{space 1}   -1.60{col 46}{space 3}0.110{col 54}{space 4}-.0091024{col 67}{space 3} .0009253
{txt}{space 6}tenure {c |}{col 14}{res}{space 2}-.0036362{col 26}{space 2} .0026671{col 37}{space 1}   -1.36{col 46}{space 3}0.173{col 54}{space 4} -.008868{col 67}{space 3} .0015957
{txt}{space 6}female {c |}{col 14}{res}{space 2}-.0131006{col 26}{space 2} .0342885{col 37}{space 1}   -0.38{col 46}{space 3}0.702{col 54}{space 4}-.0803619{col 67}{space 3} .0541607
{txt}{space 9}age {c |}{col 14}{res}{space 2} .0234715{col 26}{space 2} .0023932{col 37}{space 1}    9.81{col 46}{space 3}0.000{col 54}{space 4} .0187769{col 67}{space 3} .0281662
{txt}{space 7}_cons {c |}{col 14}{res}{space 2} 2.280935{col 26}{space 2} .0987652{col 37}{space 1}   23.09{col 46}{space 3}0.000{col 54}{space 4} 2.087195{col 67}{space 3} 2.474676
{txt}{hline 13}{c BT}{hline 11}{hline 11}{hline 9}{hline 8}{hline 13}{hline 12}
 


{marker Author}{...}
{title:Author}

{pstd}Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Blithewood-Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org{p_end}


{title: See also}:{help intreg}, {help mi}
