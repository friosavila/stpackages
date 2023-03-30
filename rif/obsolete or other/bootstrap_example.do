 ** this is the example using Stata Svy bootstrap
 ** it uses all the Bootstrap weights, to estimate the model 1000 times.
 webuse nmihs_bs, clear
 svyset
 svy, nodots: reg birthwgt age race childsex 
 
 /*
             |   Observed   Bootstrap                         Normal-based
    birthwgt |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
         age |   7.904174   1.295527     6.10   0.000     5.364988    10.44336
        race |  -253.9666   10.63105   -23.89   0.000    -274.8031   -233.1301
    childsex |    -118.46    13.1007    -9.04   0.000    -144.1369   -92.78308
       _cons |   3366.213   39.43916    85.35   0.000     3288.914    3443.512
------------------------------------------------------------------------------
*/
 *** I can do this using "simulate"
 global rep=0
 program myownbs
	global rep=$rep+1
	reg birthwgt age race childsex [aw=bsrw$rep]	
 end
 
 simulate, reps(1000):myownbs
 sum
 
/*

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
      _b_age |      1,000    7.901333    1.296175   3.440712   12.22203
     _b_race |      1,000   -253.8117    10.63637  -290.7321    -223.13
 _b_childsex |      1,000   -118.6838    13.10726  -164.4989  -76.10059
     _b_cons |      1,000     3366.19    39.45889   3223.819   3477.893
*/