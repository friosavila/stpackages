{smcl}
{* *! version 1.0 9/27/2022}{...}
{cmd:help frause}
{hline}

{title:Title}
{phang}
{bf: frause -- Access Wooldridge Stata datasets}

{title:Syntax}
{p 8 17 2}
{cmd:frause}
{it:filename} 
[ 
{cmd:,}
{cmd:clear}
{cmd:dir([str])}
{cmd:{opt des:cribe}}
 
]

{title:Description}

{pstd}{cmd:frause} provides access to Stata-format datasets used
in "Introductory Econometrics: a Modern Approach" by J. Wooldridge, plus other datasets I find useful for my own classes.

{pstd}The command uses {cmd: webuse} in the background, and downloads data from Github, in my repository.
If you have problems downloading the data, it may be I exceeded my traffic allotment.

{pstd}The command and helpfile was based on -bcuse- by Prof. Baum.

{title:Options}

{phang}{opt clear} specifies that you want to clear Stata's memory before loading 
the new dataset.

{phang}{opt des:cribe} request describing the dataset of interest. This will load only the file describing the variables in the dataset, not the dataset itself. 

{phang}{opt dir([str])} request listing all datasets currently available in the repository. If no string is provided, it displays ALL datasets. But, if some string is provided, it displays only datasets that start with that string. In addition to the dataset names, it also provides Nobs and Number of variables.

{title:Examples} 


{phang}{stata "frause crime1" : . frause crime1}{p_end}
{phang}{stata "frause crime1, clear" : . frause crime1, clear}{p_end}
{phang}{stata "frause econmath, clear" : . frause econmath, clear}{p_end}

{phang}{stata "frause econmath, des" : . frause econmath, des}{p_end}
{phang}{stata "frause oaxaca, des" : . frause oaxaca, des}{p_end}

{phang}{stata "frause , dir" : . frause, dir}{p_end}
{phang}{stata "frause , dir(a)" : . frause, dir(a)}{p_end}
{phang}{stata "frause , dir(at)" : . frause, dir(at)}{p_end}



{title:Author}
{phang}Fernando Rios-Avila{break} 
friosa@gmail.com{p_end}

{title:Also see} 
  
  help for {help use}, {help sysuse}, {help webuse}
