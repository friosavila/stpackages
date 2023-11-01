** manual
*gen one = 1
drop if lnwage==.
mata
	y = st_data(.,"lnwage")
	x = st_data(.,"educ exper one")
	n = rows(y)
	xx = cross(x,x); ixx = invsym(xx) ;  xy = cross(x,y)
	b = ixx * xy
	e = y:-x*b
	ae = 2*e:*((e:>0):-mean(e:>0))
	g = ixx * cross(x,ae)
	v = ae:-x*g
	sv = v:/(x*g)
	iff = n*ixx*(x:*(x*g))'
	cross(iff',iff')
	sqrt(mean(sv:^2)*cross(iff',iff'))/n
end
1.185514002
    +----------------------------------------------+
  1 |   23.89738188                                |
  2 |   1.217459671    1.288842438                 |
  3 |  -303.5253797   -35.45611191    4315.751988  |
    +----------------------------------------------+

/*
Scale 
        educ |  -.0130296   .0037118    -3.51   0.000    -.0203045   -.0057547
       exper |  -.0051003    .000862    -5.92   0.000    -.0067897   -.0034108
       _cons |   .5389329   .0498807    10.80   0.000     .4411685    .6366972
*/