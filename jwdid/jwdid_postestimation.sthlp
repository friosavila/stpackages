{smcl}
{* *! version 2}{...}

{title:Title}

{phang}
{bf:jwdid post-estimation} {hline 2} JWDID Post Estimation 

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
One can also request using weights different from those used in the estimation.

{pstd}Because {cmd:jwdid} uses {help margins} to estimate the aggregate ATTs, you can use many margins options, including "post" to store the output for further reporting, or predict() to produce results for other outcomes (other than default).{p_end}

{pstd}However, there are other options available options.{p_end}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
 
{synopt:{opt esave(name)}}Saves the output into a ster file, without erasing the previouly estimated results. Can be used with {opt replace}, to overwritte a previouly existing file{p_end}
{synopt:{opt estore(name)}}Stores the output in memory under {cmd: name}{p_end}
{synopt:{opt ores:triction(str)}}Imposes an additional restriction on the ATT's aggregation. For example, -estat simple, ores(sex==2)- would estimate a simple ATT for women only. This option can be used for all aggregations. {p_end}
{synopt:{opt over(varname)}}When using {opt simple} aggregation, one can request to obtain "simple" estimates across subgroups. For example, to produce ATT's for men and women.{p_end}
{synopt:{opt pretrend}}When using {opt event} aggregation, one can request to obtain a simple Parallel trends assumption test. This will use -test- on the Null that all pre-treament aggregated ATTs are zero. {p_end}
{synopt:{opt window}}When using {opt event} aggregation, this option can be requested to restrict the aggregation and use data only the event periods within {opt window}{p_end}
{synopt:{opt cwindow}}In contrast to {opt window}, this option censores the "events" to be used before doing the aggregation. For example, -cwindow(-4 4)- would display aggragates for periods -4 to 4, but the lower threshold would aggregate all ATTs before T-4. {p_end}
{synoptline}

The {opt plot} option works similar to a post estimation command. It uses the last estimated results to produce the corresponding plots. It has various options:

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}

{synoptline}



{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
In the simple linear model, average treatment effects on group G and time T can be directly analyzed by looking at the corresponding regression coefficients. However, in more complex models, those coefficients will not reflect the average treatment effect, except for the latent variable. 

{pstd}
The procedure used for aggregation is based on the following steps:

1. Given the estimated coefficients, obtain the predicted outcome of interest (linear index for ols) using all data as observed. Call this y_hat_observed.
2. Obtain the predicted outcome setting to zero all coefficients that are associated with the treatment dummy (ie __tr__=0). Call this y_hat_nontreated

{pstd} Once these two estimates are obtained, it is possible to calculate the individual level ATT as ATT_i = y_hat_observed_i - y_hat_nontreated_i. Which is the difference between the predicted potential outcome as observed minus the predicted potential outcome as if the individual was not treated.

{pstd} Once the ATT_i is obtained, Any aggregation can be calculated by simply using a weighted avarage, and a selection indicator. 

AGGATT = sum(ATT_i * w_i*sel_i)/sum(w_i*sel_i)

{pstd} In this case, -w_i- is the weight observation i has in the survey (or the weight requested using [pw=var]). And -sel_i- is a dummy variable that is 1 if the observation is selected for the aggregation, and 0 otherwise.

{pstd} Similar to {cmd:csdid} and {cmd:csdid2}, four basic aggregations are available:

Simple: sel_i = 1 if t_i >= g_i (all observations for periods after treatment)

Calendar: sel_i = 1 if t_i >= g_i & t_i == t_c (all observations for periods after treatment, if treated at time t_c)

Group: sel_i = 1 if t_i >= g_i & g_i == g_c (all observations for periods after treatment, if they belong to group g_c)

Event: sel_i = 1 if (t_i -  g_i) = e & g_i != 0 (all observations where the gap between time and treatment period is e)

{pstd}
When other estimation methods are used (probit/poisson) margins are calculated based on the default options in margins. However, the user can also request to use other options, such as -predict(xb)-.

{pstd}
Combining the basic aggregations with {opt ores:triction()} and {opt over()} allows for a wide range of aggregations to be calculated, allowing for the direct identification of Characteristics heterogeneity.

{pstd}
After producing the aggregations, one can use -estat plot- to produce the corresponding plots. 

{marker remarks}{...}
{title:Remarks}

{pstd}
This code shows how simple is to produce Aggregations for ATT's based on this approach. 
However, as experienced with the first round of CSDID, when you have too many periods and cohorts, 
some aggregations may take some time to be produced.

{pstd}
Also, the general recommendation is to produce aggregations and Standard errors using -vce(unconditional)- option. However, this not possible in all cases. Specifically, if the model is estimated with reghdfe (default) or ppmlhdfe, the unconditional standard errors are not available. 

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


{synoptline}
 
{title:{cmd:jwdid_plot}: Plots after jwdid}

{p}{cmd:jwdid} also comes with its own command to produce simple plots for all aggregations.
 It automatically recognizes last estimated results left by {cmd: jwdid post estimation} to produce the corresponding plots.
 This command is what is called when using -plot[()] option with -estat-. {p_end}


{marker syntax}{...}
{title:Syntax}

{phang}{cmd:jwdid_plot}, [options]

{synopthdr:Plot options}

{synoptset 20 tabbed}{...}
{synoptline}

{synopt:style(styleoption)} Allows you to change the style of the plot. The options are rspike (default), rarea, rcap and rbar.{p_end}

{synopt:title(str)}Sets title for the constructed graph{p_end}

{synopt:xtitle(str)}Sets title for horizontal axis{p_end}

{synopt:ytitle(str)}Sets title for vertical axis axis{p_end}

{synopt:name(str)}Request storing a graph in memory under {it:name}{p_end}
 
 
{synopt:pstyle[1|2](stype)} This can be used to choose an overall style for the figure colors. Default is p1 for pstyle1 and p2 for pstyle2. pstyle2 is only used for event style plots.

{synopt:color[1|2](colorstyle)} This can be used to choose a color for areas of the figures. It superseeds pstyle if a color is defined, but complements it if using transparency or intencity. Default depends on the type of graph style, but is set at %40 for rspike.

{synopt:lwidth[1|2](options)} This can be used to select width of line in figure. It affects the tickness of the countours of Area type plots. Default depends on the type of graph style.

{pstd}Other {cmd:twoway graph} options are allowed.


{marker remarks}{...}
{title:Remarks}

{pstd}
The command {cmd:jwdid_plot} is an easy-to-use command to plot different ATT aggregations, either across groups,
across time, or dynamic effects, (event plot). Its a clone of csdid_plot. It has, however, limited flexibility{p_end}
{pstd}
If you want to further modify this figure, I suggest using the community contributed command {help addplot} by Benn Jan.
If you do, please cite his software. See references section.

{marker examples}{...}
{title:Examples}

{phang} Setup: Estimation of ATTGTs without controls using never treated as controls{p_end}

{phang}{stata "ssc install frause"}{p_end}
{phang}{stata "frause mpdta.dta, clear"}{p_end}
{phang}{stata "jwdid lemp, ivar(countyreal) tvar(year) gvar(first_treat) never"}{p_end}

{phang} Estimation of event aggretation{p_end}
{phang}{stata "estat event"}{p_end}

{phang} Plot{p_end}
{phang}{stata "jwdid_plot"}{p_end}
{phang}{stata "jwdid_plot, pstyle1(p3)"}{p_end}
{phang}{stata "jwdid_plot, xscale(range(-4.5/3.5))"}{p_end}
{phang}{stata `"jwdid_plot, legend(order(1 "Before" 3 "After"))"'}{p_end}
{phang}{stata `"jwdid_plot, style(rbar)"'}{p_end}

{marker authors}{...}
{title:Authors}

{pstd}
Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org

{ptsd}
Arne J. Nagengast{break} 
Deutsche Bundesbank{break}
arne.nagengast@bundesbank.de

{ptsd}
Yoto V. Yotov{break}
School of Economics,Drexel University{break}
yotov@drexel.edu

{marker references}{...}
{title:References}

{phang2}Wooldridge, Jeffrey. 2021.
Two-Way Fixed Effects, the Two-Way Mundlak Regression, and 
Differences-in-Differences 
estimators. Working paper.{p_end}

{phang2}Wooldridge, Jeffrey. 2022.
Simple Approaches to Nonlinear Difference-in-Differences 
with Panel Data. Working paper.{p_end}


{title:Also see}

{p 7 14 2}
Help:  {help drdid}, {help csdid}, {help csdid_postestimation}, 
{help jwdid}, {help jwdid_postestimation}, {help xthdidregress} {p_end}

