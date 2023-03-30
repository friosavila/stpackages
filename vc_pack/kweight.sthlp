{smcl}
{* December 2018 {...}}
{vieweralsosee "[R] vc_bw" "help vc_bw"}{...}
{vieweralsosee "[R] vc_reg" "help vc_reg"}{...}
{vieweralsosee "[R] vc_bsreg" "help vc_bsreg"}{...}
{vieweralsosee "[R] vc_graph" "help vc_graph"}{...}
{vieweralsosee "[R] vc_predict" "help vc_predict"}{...}
{vieweralsosee "[R] cv_regress" "help cv_regress"}{...}

{hline}
help for {cmd:egen kweight}
{hline}

{title:Extension to generate kernel weights}

{p 8 17 2}{cmd:egen} [{it:type}] {it:newvar} {cmd:=}
{it:kweight}{cmd:(}{it:varname}{cmd:)} [{cmd:if} {it:exp}] [{cmd:in} {it:range}]
[{cmd:,} {it:options}]

	syntax newvarname =/exp [if] [in] , bw(real) pofr(real) [kernel(str)]

{title:Description}

{p 4 4 2}
{help egen kweight} creates {it:newvar} of the optionally specified storage type
equal to {it:kweight(varname)}. Using a specified bandwidth, kernel function and point of reference, This module produces the normalized kernel weights. 

{title:Main}

{p 4 4 2}
 {synoptset 20 tabbed}{...}

{synopt:{opth bw(#)}} Indicates bandwidth to be used for estimating the kernel weights {p_end}
{synopt:{opth pofr(#)}} Indicates a point of reference that will be used to estimate the kernel weights. Points closer to the pofr will have a higher weight {p_end}
{synopt:{opt kernel(kernel)}} Indicates which kernel function to be used in the process. Default is Gaussian Kernel. All kernel {p_end}

{synoptset 29}{...}
{synopthdr :kernel}
{synoptline}
{synopt :{opt gaussian}}Gaussian kernel function; The default{p_end}
{synopt :{opt epan}}Epanechnikov kernel function {p_end}
{synopt :{opt epan2}}alternative Epanechnikov kernel function{p_end}
{synopt :{opt biweight}}biweight kernel function{p_end}
{synopt :{opt cosine}}cosine trace kernel function{p_end}
{synopt :{opt parzen}}Parzen kernel function{p_end}
{synopt :{opt rectan}}rectangle kernel function{p_end}
{synopt :{opt trian}}triangle kernel function{p_end}

Additional Kernel functions: 

{synopt :{opt logistic}}Logistic kernel function{p_end}
{synopt :{opt tricube}}Tricube kernel function{p_end}
{synopt :{opt triweight}}Triweight kernel function{p_end}

Kernel functions for discrete data. All BW must lie between 0 and 1 for this kernels

{synopt :{opt liracine}} Li-Racine Kernel for unordered Data {p_end}
{synopt :{opt liracine2}} Li-Racine Kernel for ordered Data {p_end}
{synopt :{opt habbena}} Habbena kernel for ordered data {p_end}
{synopt :{opt logdis}} Log distance kernel for ordered data {p_end}
{synopt :{opt dtrian}} Triangular distance kernel for ordered data {p_end}


 {synoptline}
{p2colreset}{...}
{marker weight}{...}
{p 8 17 2}

{marker description}{...}
{title:Description}

{pstd}
The function kweight creates the normalized kernel weights based on a defined kernel function, a selected bandwidth and a given point of reference. {p_end}
{pstd}Given this information, the weights are created as follows: {p_end}
{pstd}First, it creates an auxiliary variable z defined as: z=(x-pofr)/bw {p_end}
{pstd}With this information, the normalized kernel weight is defined as: kw=kernel(z)/kernel(0). where kernel is any of the kernel functions indicated above. {p_end}
{pstd}For discrete ordered data, distance from the point of interest are weighted equally.
{p_end}
 
{marker Examples}{...}
{title:Examples}

{stata "webuse nlswork, clear"}
{stata "set seed 1"}
{stata "replace age=age+rnormal()*.5"}
{stata "egen kwage_30a=kweight(age), pofr(30) bw(3)"}
{stata "egen kwage_30b=kweight(age), pofr(30) bw(3) kernel(epan)"}
{stata "egen kwage_30c=kweight(age), pofr(30) bw(6) kernel(biweight)"}

Visualizing the weights:
{stata "line kwage_30* age, sort"}

{marker Author}{...}
{title:Author}

{pstd}Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Blithewood-Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org

