set seed 101
clear
set obs 10000

gen yw=rnormal(1,0.5)
gen ym=rnormal(1.1,0.7)


gen uu=runiform()
gen p = uu<.5
gen pc = uu<.6

gen y0 = yw*(p==1)+ym*(p==0)
gen yc = yw*(pc==1)+ym*(pc==0)

** Estimating UQR effects
pctile aux1=y0, n(100) 
pctile aux2=yc, n(100)
gen uqr=(aux2-aux1)
gen uqrscale=(aux2-aux1)/0.1
gen q=_n if _n<100
** This is the true effect. How the distribution changes from y0 to yC 
** when the proportion of women increases in aprox 10%
scatter uqr q
** However this is what uqr rif estimates. The rescaled effect
gen uqrscale=(aux2-aux1)/0.1
scatter uqrscale q
** You can compare it with the output from rifhdreg simple:
rifhdreg y0 p, rif(q(10))
ssc install qregplot
qregplot p, q(5(1)95)
ssc install addplot
addplot:scatter uqr q

**Estimation of QTE. Comparing the distribution of wages across gender
**How does Women distribution Aux2 compares to Men? aux1
drop aux1 aux2
pctile aux1=ym , n(100) 
pctile aux2=yw , n(100)
gen qte=(aux2-aux1)

** Here you have the quatniles for Mens, and women's distribution only.
** qte shows how the distrbution of wages differs between Men and women
scatter qte q

** And it is possible to obtain this using rifhdreg too:
** Here there is no "reweight" because there are no controls
rifhdreg y0 p, rif(q(50)) over(p)
qregplot p, q(5(1)95) 

addplot:scatter qte q

** In this case the UQR and QTE are similar, but that is just coincidence. 
** They could just as well be very different

** For UQR, it is usually better talk about the Small effect in the change of "Shares" of women (in this example)
** For QTE, you talk about the change of women vs men. (as if there was a 100% change)