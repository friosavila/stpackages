{smcl}
{* *! version 2 May 2024}{...}

{title:Title}

{phang}
{bf:jwdid post-estimation} {hline 2} JWDID Post Estimation 

{pstd} -jwdid- has a set of post estimation options that can be used to either produce aggregations of the Average Treatment Effects on the Treated (ATT) or to produce plots of the estimated ATTs.

Aggregation Options:

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:estat}
[aggregation] [pw]
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt simple}}Estimates the ATT for all groups across all periods.{p_end}
{synopt:{opt group}}Estimates the ATT for each group or cohort, over all periods.{p_end}
{synopt:{opt calendar}}Estimates the ATT for each period, across all groups or cohorts.{p_end}
{synopt:{opt event}}Dynamic aggregation. When default option is used (not-yet treated)
this option only provides the post-treatment ATT aggregations.{p_end}
{synopt:{opt plot}}Produces Plots using the last estimated results{p_end}
{synoptline}

{pstd} One can also request using weights different from those used in the estimation.

{pstd}Because {cmd:jwdid} uses {help margins} to estimate the aggregate ATTs, you can use many margins options, including "post" to store the output for further reporting, or predict() to produce results for other outcomes (other than default).

{pstd}However, there are other available options.{p_end}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
 
{synopt:{opt esave(name)}}Saves the output into a .ster file, without erasing the previously estimated results. Can be used with {opt replace}, to overwrite a previously existing file{p_end}
{synopt:{opt estore(name)}}Stores the output in memory under {cmd: name}{p_end}
{synopt:{opt ores:triction(str)}}Imposes an additional restriction on the ATT's aggregation. For example, -estat simple, ores(sex==2)- would estimate a simple ATT for women only. This option can be used for all aggregations. {p_end}
{synopt:{opt over(varname)}}When using {opt simple} aggregation, one can request to obtain "simple" estimates across subgroups. For example, to produce ATT's for men and women.{p_end}
{synopt:{opt pretrend}}When using {opt event} aggregation, one can request to obtain a simple Parallel trends assumption test. This will use -test- on the Null that all pre-treatment aggregated ATTs are zero. {p_end}
{synopt:{opt window(#1 #2)}}When using {opt event} aggregation, this option can be requested to restrict the aggregation and use data only for the event periods within {opt window}{p_end}
{synopt:{opt cwindow(#1 #2)}}In contrast to {opt window}, this option censors the "events" to be used before doing the aggregation. For example, -cwindow(-4 4)- would display aggregates for periods -4 to 4, but the lower threshold would aggregate all ATTs before T-4. {p_end}
{synoptline}

{title:Plot Options}

{pstd}One of the post-estimation options can also be used to produce plots of the estimated ATTs. These are options in addition to the standard {cmd:twoway graph} options.

{synopt:{opt style(styleoption)}} Allows you to change the style of the plot. The options are rspike (default), rarea, rcap and rbar.{p_end}

{synopt:{opt title(str)}}Sets title for the constructed graph{p_end}

{synopt:{opt xtitle(str)}}Sets title for horizontal axis{p_end}

{synopt:{opt ytitle(str)}}Sets title for vertical axis{p_end}

{synopt:{opt name(str)}}Request storing a graph in memory under {it:name}{p_end}
 
{synopt:{opt pstyle[1|2](stype)}} This can be used to choose an overall style for the figure colors. Default is p1 for pstyle1 and p2 for pstyle2. pstyle2 is only used for event style plots, for the post-treatment effects.

{synopt:{opt color[1|2](colorstyle)}} This can be used to choose a color for areas of the figures. It supersedes pstyle if a color is defined, but complements it if using transparency or intensity. Default depends on the type of graph style, but is set at %40 for rspike.

{synopt:{opt lwidth[1|2](options)}} This can be used to select width of line in figure. It affects the thickness of the contours of Area type plots. Default depends on the type of graph style.

{synopt:{opt tight}} When requesting event, calendar or group aggregates, the plots are constructed using the original time scale. For example, if you had 3 groups, 10, 15 and 16, the plot across groups would use periods 10, 15 and 16, with black spaces in between. The option tight can be used to transform the scale of the data to start from 1, to the last period. This is useful to avoid the black spaces in between groups. {p_end}

{pstd}Other {cmd:twoway graph} options are allowed.

{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
In the simple linear model, average treatment effects on group G and time T can be directly analyzed by looking at the corresponding regression coefficients. However, in more complex models, those coefficients will not reflect the average treatment effect, except for the latent variable. 

{pstd}
The procedure used for aggregation is based on the following steps:

{phang2} 1. Given the estimated coefficients, obtain the predicted outcome of interest (linear index for ols) using all data as observed. Call this y_hat_observed.

{phang2} 2. Obtain the predicted outcome setting to zero all coefficients that are associated with the treatment dummy (ie __tr__=0). Call this y_hat_nontreated

{pstd} Once these two estimates are obtained, it is possible to calculate the individual level ATT as ATT_i = y_hat_observed_i - y_hat_nontreated_i. Which is the difference between the predicted potential outcome as observed minus the predicted potential outcome as if the individual was not treated.

{pstd} Once the ATT_i is obtained, Any aggregation can be calculated by simply using a weighted average, and a selection indicator. 

{phang2} AGGATT = sum(ATT_i * w_i*sel_i)/sum(w_i*sel_i)

{pstd} In this case, -w_i- is the weight observation i has in the survey (or the weight requested using [pw=var]). And -sel_i- is a dummy variable that is 1 if the observation is selected for the aggregation, and 0 otherwise.

{pstd} Similar to {cmd:csdid} and {cmd:csdid2}, four basic aggregations are available:

{phang2} Simple: sel_i = 1 if t_i >= g_i (all observations for periods after treatment)

{phang2} Calendar: sel_i = 1 if t_i >= g_i & t_i == t_c (all observations for periods after treatment, if treated at time t_c)

{phang2} Group: sel_i = 1 if t_i >= g_i & g_i == g_c (all observations for periods after treatment, if they belong to group g_c)

{phang2} Event: sel_i = 1 if (t_i -  g_i) = e & g_i != 0 (all observations where the gap between time and treatment period is e)

{pstd}
When other estimation methods are used (probit/poisson) margins are calculated based on the default options in margins. However, the user can also request to use other options, such as -predict(xb)-.

{pstd}
Combining the basic aggregations with {opt ores:triction()} and {opt over()} allows for a wide range of aggregations to be calculated, allowing for the direct identification of Characteristics heterogeneity.

{pstd}
After producing the aggregations, one can use -estat plot- to produce the corresponding plots. 

{marker remarks}{...}
{title:Remarks}

{pstd}
This code shows how simple it is to produce Aggregations for ATT's based on this approach. 
However, as experienced with the first round of CSDID, when you have too many periods and cohorts, 
some aggregations may take some time to be produced. The same is true for {cmd: xtdidregress twfe} and {cmd: hdidregress twfe} implementations.

{pstd}
Also, the general recommendation is to produce aggregations and Standard errors using -vce(unconditional)- option. However, this is not possible in all cases. Specifically, if the model is estimated with reghdfe (default) or ppmlhdfe, the unconditional standard errors are not available. {cmd: xtdidregress twfe} avoids this problem by implementing a regression approach combined with a full Mundlak approach.

{pstd}
Also, all errors are my own. 

{marker examples}{...}
{title:Examples}

{phang} Setup: Estimation of ATTGTs without controls using not-yet treated groups

{phang}{stata "ssc install frause"}{p_end}
{phang}{stata "frause mpdta.dta, clear"}{p_end}

{phang}{stata "jwdid lemp, ivar(countyreal) tvar(year) gvar(first_treat)"}{p_end}

{phang} Aggregations:

{phang}{stata "estat simple"}{p_end}
{phang}{stata "estat calendar"}{p_end}
{phang}{stata "estat group"}{p_end}
{phang}{stata "estat event"}{p_end}

{phang} Using Never treated as controls

{phang}{stata "jwdid lemp, ivar(countyreal) tvar(year) gvar(first_treat) never"}{p_end}

{phang}{stata "estat simple"}{p_end}
{phang}{stata "estat calendar"}{p_end}
{phang}{stata "estat group"}{p_end}
{phang}{stata "estat event"}{p_end}
{phang}{stata "estat event, window(-3 2)"}{p_end}
{phang}{stata "estat event, cwindow(-3 2)"}{p_end}

{phang} Using a single control variable 

{phang}{stata "jwdid lemp lpop, ivar(countyreal) tvar(year) gvar(first_treat) "}{p_end}

{phang}{stata "estat simple"}{p_end}
{phang}{stata "estat calendar"}{p_end}
{phang}{stata "estat group"}{p_end}
{phang}{stata "estat event"}{p_end}

{phang} Using a single control variable and poisson

{phang}{stata "gen emp = exp(lemp)"}{p_end}
{phang}{stata "jwdid emp lpop, ivar(countyreal) tvar(year) gvar(first_treat) method(poisson)"}{p_end}

{phang}{stata "estat simple"}{p_end}
{phang}{stata "estat calendar"}{p_end}
{phang}{stata "estat group"}{p_end}
{phang}{stata "estat event"}{p_end}

{phang} Using a different outcome

{phang}{stata "estat event, predict(xb)"}{p_end}

{phang} Plot Examples

{phang} Setup: Estimation of ATTGTs without controls using never treated as controls{p_end}
{phang}{stata "jwdid lemp, ivar(countyreal) tvar(year) gvar(first_treat) never"}{p_end}

{phang} Estimation of event aggregation{p_end}
{phang}{stata "estat event"}{p_end}

{phang} Plot{p_end}
{phang}{stata "estat plot"}{p_end}
{phang}{stata "estat plot, pstyle1(p3)"}{p_end}
{phang}{stata "estat plot, xscale(range(-4.5/3.5))"}{p_end}
{phang}{stata `"estat plot, legend(order(1 "Before" 3 "After"))"'}{p_end}
{phang}{stata `"estat plot, style(rbar)"'}{p_end}

{marker authors}{...}
{title:Authors}

{pstd}
Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org

{pstd}
Arne J. Nagengast{break} 
Deutsche Bundesbank{break}
arne.nagengast@bundesbank.de

{pstd}
Yoto V. Yotov{break}
School of Economics, Drexel University{break}
yotov@drexel.edu

{marker references}{...}
{title:References}

{phang}Nagengast, Arne J., Fernando Rios-Avila and Yoto V. Yotov. 2024. The European Single Market and Intra-EU Trade: An Assessment with Heterogeneity-Robust Difference-in-Differences Methods. 
School of Economics Working Paper Series 2024-5, LeBow College of Business, Drexel University. https://ideas.repec.org/p/ris/drxlwp/2024_005.html. {browse "https://drive.google.com/file/d/1d3RocZguRYoFNLjK6KFbX3oHXeVrbJcM/view":Paper}.{p_end}

{phang}Nagengast, Arne J. and Yoto V. Yotov. 2024. Staggered Difference-in-Differences in Gravity Settings: Revisiting the Effects of Trade Agreements. American Economic Journal: Applied Economics (forthcoming).{p_end}

{phang}Wooldridge, Jeffrey. 2021.
Two-Way Fixed Effects, the Two-Way Mundlak Regression, and Differences-in-Differences 
estimators. Working paper.{p_end}

{phang}Wooldridge, Jeffrey. 2023.
Simple Approaches to Nonlinear Difference-in-Differences with Panel Data. The Econometrics Journal, Volume 26, Issue 3, September 2023, Pages C31–C66.{p_end}

{title:Also see}

{p 7 14 2}
Help:  {help drdid}, {help csdid}, {help csdid_postestimation}, 
{help jwdid}, {help jwdid_postestimation}, {help xthdidregress}, {help hdidregress} {p_end}
