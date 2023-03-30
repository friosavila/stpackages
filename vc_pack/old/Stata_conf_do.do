** Stata Conf Example
qui:webuse dui, clear
** citations|fines=f(college taxes, csize)
** Model selection
vc_bwalt citations i.college i.taxes i.csize, vcoeff(fines) plot
vc_bw citations i.college i.taxes i.csize, vcoeff(fines) plot
** Post Estimation
vc_predict citations i.college i.taxes i.csize, stest
**
set seed 1
vc_test citations i.college i.taxes i.csize, wbsrep(100) degree(1)
vc_test citations i.college i.taxes i.csize, wbsrep(100) degree(2)
vc_test citations i.college i.taxes i.csize, wbsrep(100) degree(3)
** Model 
vc_preg citations i.college i.taxes i.csize, klist(9) 
** Modeling various POR
vc_preg citations i.college i.taxes i.csize, k(10) 
vc_graph 1.taxes 1.college


