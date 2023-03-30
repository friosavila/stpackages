{smcl}
{* *! version 1.0 Fernando Rios-Avila April 2020}{...}
{cmd:help ghsurv}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{cmd:ghsurv} {hline 2}}Module for the estimation of survival model using repeated crosssection data {p_end}
{p2colreset}{...}


{title:Syntax}

{pstd}
Module for the model estimation. 

{p 8 17 2}
{opt ghsurv}
{indepvars} {ifin} {weight} [{cmd:,} gap({varname}) alpha({varlist}) cluster({varname})]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}

{p2coldent : {opt indepvar}} Declares all independent variables in the model. It should include the created variable {cmd:_dur}
or some transformation of it. This is created using ghsurv_set. {p_end}
{p2coldent : {opt gap(varname)}} Indicates the variable to identify the gap between measured spells. Default uses gap=1. Use this only
if setting data with different gaps between data collection and spell measuring. {p_end}
{p2coldent : {opt alpha(varlist)}} Declares variables that explain the unconditional cohort to cohort probability of transition. 
Default assumes alpha is a constant. It typically contains {cmd:_dur} or transformation of such variable. {p_end}
{p2coldent : {opt cluster(varname)}} Indicates the use of cluster standard errors using varname as clusters. The default is to use {cmd:_id}
as cluster. THis variable is created when using {cmd:ghsurv_set }{p_end}
{p2coldent : {opt weight}} The command allows for all type of weights, however, standard errors obtained using clustered standard errors.  {p_end}
{synoptline}
{pstd}


{pstd}
Module for setting up the data for the estimation.

{p 8 17 2}
{opt ghsurv_set} {cmd:,} dur({varname}) time({varname}) [nowarning]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}

{p2coldent : {opt dur(varname)}} Indicates the number of periods observation "i" has "survived" until the moment the information 
is been collected (in the survey).{p_end}
{p2coldent : {opt time(varname)}} Indicates the time period when the data has been collected.  {p_end}
{p2coldent : {opt nowarning}} Because this command modifies the data, the default will ask you to confirm before proceeding. This option bypasses this warning. {p_end}

{synoptline}
{pstd}

{pstd}After the data has been set up,  four variables are created: {cmd:_id}  Observation ID; {cmd:_dur} Spell duration; {cmd:_t} Time variable; 
{cmd:_y01} base sample (=0) and continuation sample (=1) indicator.


{title:Postestimaton}

{pstd} After the estimation, one can calculate either the probability of exit (for example exit unemployment) using the option {cmd:p_exit} 
or probability of continuation {cmd:p_cont}. This can be used in combination with {help margins} and {help predict}.

{synoptline}
{pstd}

{title:Description}

{pstd}
{cmd:ghsurv} is a command that implements the estimator proposed by Guell and Hu (2006) and described in detail in Mundra and Rios-Avila (2020)
 for the estimation of duration type of models based on uncompleted spells using repeated cross-section data.

{pstd}
Consider the example proposed by Guell and Hu (2006) that focuses on analyzing determinants of unemployment duration. 
when panel data is unavailable, it is not possible to use conventional models to estimate duration models. 

{pstd}
Instead, Guell and Hu(2006) proposes to identify the determinants of continued 
unemployment comparing the distribution of those who are unemployed across 
two (or more) periods, using a pseudo panel model "linking" individuals based on
actual and potential number of periods of unemployment a person experiences in two 
points in time.

{pstd}For example, to analyze the probability of between two periods, one can analyze the distribution 
of characteristics of everyone who was unemployed for {cmd:S} periods at time {cmd:T} and compare it to those
unemployed for {cmd:S+1} periods at time {cmd:T+1}. Guell and Hu(2006) and Mundra and Rios-Avila (2020) call this
the base and continuation Samples.

{pstd} If there are fewer individuals with characteristics X at time T+1 with unemployment length S+1, in relative terms, 
then that characteristic is associated to an increase in the probability of exiting unemployment. 

{pstd} For the implementation of the command, one must take particular care identifying the base and continuation sample, 
and the linking "duration" variable. There should always be a 1-1 linking between base con continuation samples.

{pstd} Consider a case with 3 periods: 

{pstd} Observations in period 1 can be part of the base sample, but not the continuation sample.

{pstd} Observations in period 2 can be part of the continuation sample for observations on period 1, or base sample for observations in period 3.

{pstd} Observations in period 3 can be part of the continuation sample, but not the base sample.

{pstd} If the periods between crossection data are measured in the same units as periods of unemployment, say data collected monthly with unemployment duration
measured in months, then {cmd:ghsurv_set} can be used to setup and prepare the data. This process modifies the data, and cannot be reversed.

{pstd} {cmd:ghsurb} can be used to estimate models with different "gaps" in collected time and measured unemployment spell, but is the user responsability
to ensure the 1-1 relationship between all potential base and continuation samples.

{pstd} The model reports clustered standard errors using individual identifiers (_id) as clusters. This can be superseeded using other relevant variables.

{pstd} See Guell and Hu(2006) for the original article, and Mundra and Rios-Avila (2020) for a detailed revision of the methodology, simulation evidence 
and empirical example analyzing unemployment duration among immigrants.

{title:Examples}

{pstd}Setup{p_end}
{pstd}{bf:. {stata "ssc install estout, replace"}}{p_end}
{pstd}{bf:. {stata "use http://cameron.econ.ucdavis.edu/mmabook/ema1996.dta, clear"}}{p_end}
{pstd}{bf:. {stata "global xvars logwage tenure slack explose houshead married female ychild nonwhite age schgt12 "}}{p_end}

{pstd}I first restructure the data {p_end}
{pstd}{bf:. {stata "gen id=_n"}}{p_end}
{pstd}{bf:. {stata "expand 2 if censor1==0"}}{p_end}
{pstd}{bf:. {stata "bysort id:gen time=_n"}}{p_end}
{pstd}{bf:. {stata "replace spell=spell+1 if time==2"}}{p_end}
{pstd}{bf:. {stata "gen logspell=log(spell)"}}{p_end}
{pstd}{bf:. {stata "gen exit=1 if censor1==1 & time==1"}}{p_end}
{pstd}{bf:. {stata "replace exit=0 if exit==."}}{p_end}
{pstd}{bf:. {stata "bysort id (time):gen spell0=spell[1]-1"}}{p_end}

{pstd}I will use "event" as the only Failure option. First estimate model with Logit{p_end}

{pstd}{bf:. {stata "logit censor1 $xvars logspell if time==1"}}{p_end}
{pstd}{bf:. {stata "est sto m1"}}{p_end}

{pstd}Second, I estimate the model using {help streg} for comparison {p_end}
{pstd}{bf:. {stata "stset spell, failure(exit) enter(spell0) id(id)"}}{p_end}
{pstd}{bf:. {stata "streg $xvars , distribution(exponential) nohr"}}{p_end}
{pstd}{bf:. {stata "est sto m2"}}{p_end}

{pstd}Third, I use ghsurv to estimate the model assuming we do not observe the panel data information. {p_end}
{pstd}{bf:. {stata "stset, clear "}}{p_end}
{pstd}{bf:. {stata "ghsurv_set, dur(spell) time(time) nowarning"}}{p_end}
{pstd}{bf:. {stata "gen logdur=log(_dur)"}}{p_end}
{pstd}{bf:. {stata "ghsurv $xvars logdur, alpha(logdur) technique(nr bhhh)"}}{p_end}
{pstd}{bf:. {stata "est sto m3"}}{p_end}

{pstd}But also compare it to the case where standard errors are clustered using original ID indicator, instead of _id (the default) {p_end}
{pstd}{bf:. {stata "ghsurv $xvars logdur, alpha(logdur) technique(nr bhhh) cluster(id)"}}{p_end}
{pstd}{bf:. {stata "est sto m4"}}{p_end}

{pstd}{bf:. {stata "esttab m1 m2 m3 m4, se star(* 0.1 ** 0.05 *** 0.01) nogaps"}}{p_end}
 
{res}
{txt}{hline 76}
{txt}                      (1)             (2)             (3)             (4)   
{txt}                  censor1              _t            _y01            _y01   
{txt}{hline 76}
{res}main                                                                        {txt}
{txt}logwage     {res}        0.372***        0.251***        0.470*          0.470***{txt}
            {res} {ralign 12:{txt:(}0.0847{txt:)}}    {ralign 12:{txt:(}0.0659{txt:)}}    {ralign 12:{txt:(}0.242{txt:)}}    {ralign 12:{txt:(}0.136{txt:)}}   {txt}
{txt}tenure      {res}      0.00329       -0.000538        0.000689        0.000689   {txt}
            {res} {ralign 12:{txt:(}0.00759{txt:)}}    {ralign 12:{txt:(}0.00598{txt:)}}    {ralign 12:{txt:(}0.0160{txt:)}}    {ralign 12:{txt:(}0.00907{txt:)}}   {txt}
{txt}slack       {res}       -0.318***       -0.313***       -0.302          -0.302** {txt}
            {res} {ralign 12:{txt:(}0.0807{txt:)}}    {ralign 12:{txt:(}0.0642{txt:)}}    {ralign 12:{txt:(}0.221{txt:)}}    {ralign 12:{txt:(}0.120{txt:)}}   {txt}
{txt}explose     {res}       0.0402          0.0881           0.187           0.187   {txt}
            {res} {ralign 12:{txt:(}0.0783{txt:)}}    {ralign 12:{txt:(}0.0616{txt:)}}    {ralign 12:{txt:(}0.264{txt:)}}    {ralign 12:{txt:(}0.144{txt:)}}   {txt}
{txt}houshead    {res}        0.305***        0.294***        0.330           0.330** {txt}
            {res} {ralign 12:{txt:(}0.0966{txt:)}}    {ralign 12:{txt:(}0.0779{txt:)}}    {ralign 12:{txt:(}0.298{txt:)}}    {ralign 12:{txt:(}0.155{txt:)}}   {txt}
{txt}married     {res}        0.367***        0.307***        0.505           0.505***{txt}
            {res} {ralign 12:{txt:(}0.0892{txt:)}}    {ralign 12:{txt:(}0.0711{txt:)}}    {ralign 12:{txt:(}0.342{txt:)}}    {ralign 12:{txt:(}0.184{txt:)}}   {txt}
{txt}female      {res}        0.209**         0.178**         0.227           0.227   {txt}
            {res} {ralign 12:{txt:(}0.0967{txt:)}}    {ralign 12:{txt:(}0.0776{txt:)}}    {ralign 12:{txt:(}0.269{txt:)}}    {ralign 12:{txt:(}0.142{txt:)}}   {txt}
{txt}ychild      {res}       -0.178          -0.160*         -0.198          -0.198   {txt}
            {res} {ralign 12:{txt:(}0.109{txt:)}}    {ralign 12:{txt:(}0.0852{txt:)}}    {ralign 12:{txt:(}0.252{txt:)}}    {ralign 12:{txt:(}0.140{txt:)}}   {txt}
{txt}nonwhite    {res}       -0.420***       -0.431***       -0.452          -0.452*  {txt}
            {res} {ralign 12:{txt:(}0.128{txt:)}}    {ralign 12:{txt:(}0.109{txt:)}}    {ralign 12:{txt:(}0.484{txt:)}}    {ralign 12:{txt:(}0.238{txt:)}}   {txt}
{txt}age         {res}      -0.0145***      -0.0160***     -0.00966        -0.00966   {txt}
            {res} {ralign 12:{txt:(}0.00462{txt:)}}    {ralign 12:{txt:(}0.00366{txt:)}}    {ralign 12:{txt:(}0.0112{txt:)}}    {ralign 12:{txt:(}0.00614{txt:)}}   {txt}
{txt}schgt12     {res}        0.354***        0.274***        0.292           0.292***{txt}
            {res} {ralign 12:{txt:(}0.0835{txt:)}}    {ralign 12:{txt:(}0.0649{txt:)}}    {ralign 12:{txt:(}0.196{txt:)}}    {ralign 12:{txt:(}0.111{txt:)}}   {txt}
{txt}logspell    {res}       -0.471***                                                {txt}
            {res} {ralign 12:{txt:(}0.0440{txt:)}}                                                   {txt}
{txt}logdur      {res}                                       -0.954***       -0.954***{txt}
            {res}                                 {ralign 12:{txt:(}0.340{txt:)}}    {ralign 12:{txt:(}0.182{txt:)}}   {txt}
{txt}_cons       {res}       -2.124***       -2.878***       -2.700          -2.700** {txt}
            {res} {ralign 12:{txt:(}0.481{txt:)}}    {ralign 12:{txt:(}0.376{txt:)}}    {ralign 12:{txt:(}2.087{txt:)}}    {ralign 12:{txt:(}1.094{txt:)}}   {txt}
{hline 76}
{res}alpha                                                                       {txt}
{txt}logdur      {res}                                       0.0861          0.0861** {txt}
            {res}                                 {ralign 12:{txt:(}0.0969{txt:)}}    {ralign 12:{txt:(}0.0401{txt:)}}   {txt}
{txt}_cons       {res}                                      -0.0670         -0.0670   {txt}
            {res}                                 {ralign 12:{txt:(}0.339{txt:)}}    {ralign 12:{txt:(}0.153{txt:)}}   {txt}
{txt}{hline 76}
{txt}N           {res}         3343            5613            5613            5613   {txt}
{txt}{hline 76}
{txt}Standard errors in parentheses
{txt}* p<0.1, ** p<0.05, *** p<0.01


{title:References}

{phang}
Mundra, K & Rios-Avila, F. 2020. Using repeated cross-sectional data to examine the role
of immigrant birth-country networks on unemployment
duration: an application of Guell and Hu (2006) approach. Empirical Economics.  https://doi.org/10.1007/s00181-020-01855-x

{phang}
Güell, M. & Hu, L. 2006. Estimating the probability of leaving unemployment using uncompleted spells from repeated
 cross-section data. Journal of Econometrics, 133(1), 307–341. doi:10.1016/j.jeconom.2005.03.017 

{marker Author}{...}
{title:Author}

{pstd}
Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org


{marker Acknowledgments}{...}
{title:Acknowledgments}

{pstd}
All errors are my own.

{pstd}If you find the program useful and use in your research, please consider citing Mundra & Rios-Avila (2020).  

 
