use c:\data\oaxaca, clear
drop if lnwage==.

global y lnwage
global x educ exper tenure female age
global z educ exper  married divorced kids6 kids714 female age

reg $y $x 
matrix b=e(b)
predict res, res
replace res=abs(res)
reg res $x 
matrix g=e(b)

matrix bg=(b,g,0)*0.01


global y qty
global x price 
global z price stormy rainy
matrix bg = J(1,2,1),J(1,2,0),0
gmm ($y - {b:$x _cons}) ///
	(abs($y-{b:})-{g:$x _cons}) ///
	(normal( ({q}-($y-{b:})/{g:})/0.1)-0.5), ///
	instruments(1:$x ) instruments(2:$x) ///
	onestep winitial(identity) from(bg) ///
	derivative(1/b=-1) ///
	derivative(2/g=-1) ///
	derivative(2/b=-sign($y-{b:})) ///
	derivative(3/q=normalden( ({q}-($y-{b:})/{g:}),0.1 )) 	///
	derivative(3/b=normalden( ({q}-($y-{b:})/{g:}),0.1 )*1/{g:}) ///
	derivative(3/g=normalden( ({q}-($y-{b:})/{g:}),0.1 )*($y-{b:})/{g:}^2) 


------------------------------------------------------------------------------
             |               Robust
             | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
b            |
        educ |   .0743986   .0061236    12.15   0.000     .0623966    .0864007
       exper |   .0022628   .0018112     1.25   0.212    -.0012872    .0058127
      tenure |   .0021805   .0017975     1.21   0.225    -.0013424    .0057034
      female |  -.1321951   .0245453    -5.39   0.000     -.180303   -.0840872
         age |   .0136344   .0022103     6.17   0.000     .0093023    .0179665
       _cons |   1.985785     .08905    22.30   0.000     1.811251     2.16032
-------------+----------------------------------------------------------------
g            |
        educ |   -.013627   .0039504    -3.45   0.001    -.0213697   -.0058843
       exper |  -.0053696   .0013869    -3.87   0.000    -.0080878   -.0026513
      tenure |   .0001023   .0012234     0.08   0.933    -.0022955    .0025001
      female |   .0768039   .0190577     4.03   0.000     .0394514    .1141563
         age |   .0021127   .0016544     1.28   0.202    -.0011299    .0053553
       _cons |   .4203882   .0579346     7.26   0.000     .3068385    .5339379
-------------+----------------------------------------------------------------

          /q |   .1621686   .0259582     6.25   0.000     .1112913    .2130458
------------------------------------------------------------------------------

