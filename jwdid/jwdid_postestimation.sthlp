{smcl}
{* *! version 1 }{...}

{title:Title}

{phang}
{bf:jwdid post-estimation} {hline 2} JWDID Post Estimation 

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:estat}
[aggregation]
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
{synoptline}

{pstd}Because {cmd:jwdid} uses {help margins} to estimate the ATT, you can use many margins options, including "post" to store the output for further reporting, or predict()
to produce results for other outcomes (other than default).{p_end}

{pstd}However, I added extra options to faciliate storing, as well as alternative effects.{p_end}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
Options
{synopt:{opt plot}[(plotting options)]} You can request plotting the results after producing them. THis follows a syntax similar to margins, plot[()]
Everything in parenthesis are two-way option plots that can be added to the figure construction.{p_end}
{synopt:{opt esave(name)}}Saves the output into a ster file{p_end}
{synopt:{opt estore(name)}}Saves the output in memory under name{p_end}
{synopt:{opt other(varname)}}When using calendar, group or event aggregations, you can request getting the aggregations for specific subgroups. Say excluding first and last event period.
This should be specified with a dummy that identifies with 1 observations to be kept in the analysis{p_end}
{synopt:{opt over(varname)}}When using simple, one can request to estimate "simple" estimates across multiple subgroups. For example,
to reproduce ATTGTs for all post-treament data in nonlinear model{p_end}
{synoptline}

{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:jwdid} comes with a basic post-estimation command that estimates 4 types of aggregations: 
Simple, Calendar, group and event/dynamic ATTs. These are similar to the aggregations based on {cmd:csdid}.

{pstd}
All estimations are constructed using {help margins} turning on and off the "treatment" dummy __tr__.
 You can use many margins options, including "post" to store the output for further reporting. For example, using predict(xb) to 
 get effects based on the linear predictor.

{pstd}
When other estimation methods are used (probit/poisson) margins are calculated based on the default options in margins.

{pstd}
The command allows you to directly save -esave- or store -estore- the outcomes from margins. As well as estimate margins for other subsamples using 
the -other(varname)- and -over(name) options.

{pstd}
You can also request to create plots right after producing the aggregations. This follows a syntax similar to margins, plot[()].

{marker remarks}{...}
{title:Remarks}

{pstd}
This code shows how simple is to produce Aggregations for ATT's based on this approach. 
However, as experienced with the first round of CSDID, when you have too many periods and cohorts, 
the aggregations may take some time.

{pstd}
Also, all errors are my own. And this code was not necessarily checked by Prof Wooldridge. So if something looks different from his, look into his work.

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

{marker references}{...}
{title:References}

{phang2}Wooldridge, Jeffrey. 2021.
Two-Way Fixed Effects, the Two-Way Mundlak Regression, and 
Differences-in-Differences 
estimators. Working paper.{p_end}

{phang2}Wooldridge, Jeffrey. 2022.
Simple Approaches to Nonlinear Difference-in-Differences 
with Panel Data. Working paper.{p_end}

{phang2}
 Jann, B. (2014). addplot: Stata module to add twoway plot objects to an existing twoway graph. Available from 
        http://ideas.repec.org/c/boc/bocode/s457917.html.
{p_end}

{marker acknowledgement}{...}
{title:Acknowledgement}

{pstd}This command was put together just for fun, and 
as my last push of "productivity" before my 
baby girl was born! Who is now 15months!{p_end}

{pstd}jwdid_plot was also written due to request of people interested in this estimator.
{p_end}


{title:Also see}

{p 7 14 2}
Help:  {help drdid}, {help csdid}, {help csdid_postestimation}, 
{help jwdid}, {help jwdid_postestimation}, {help xtdidregress} {p_end}

