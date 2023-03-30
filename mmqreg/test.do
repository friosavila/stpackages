cscript
webuse dui
 gen cl=runiformint(1,20)
 
 mmqreg_r citations fines college , q(10)    robust
 est sto m0
 mmqreg_r citations fines college , q(10)    cluster(cl)
 est sto m1
 mmqreg_r citations fines , q(10)  robust abs(college )
est sto m2
 mmqreg_r citations fines , q(10)    cluster(cl) abs(college )
 est sto m3

 xtqreg  citations fines , q(.5)    i(college )
 bootstrap:mmqreg_r citations fines , q(.5)     abs(college ) robust

 