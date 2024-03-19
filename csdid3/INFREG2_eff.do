clear
 webuse hhabits
 hdidregress ra (bmi medu i.girl i.sports) (hhabit), group(schools) time(year)
 

 csdid2 bmi  , cluster(schools) tvar(year) gvar(_did_cohort) agg(attgt) method(reg)
 
 /*
       2038  |  -3.534224    .351283   -10.06   0.000    -4.222726   -2.845722
*/
ss
** Manual
preserve
local y1 = 2036
local y0 = 2035
local g1 = 2036
keep if _did_cohort== `g1'|  _did_cohort==0
keep if inlist(year,`y1',`y0')
gen treat = _did_cohort==`g1'
gen post  = year == `y1'
tab year post
global xvars medu i.girl i.sports
qui:reg bmi medu i.girl i.sports  if treat == 0 & post ==0
predict y00

qui:reg bmi medu i.girl i.sports  if treat == 0 & post ==1
predict y01

qui:reg bmi medu i.girl i.sports  if treat == 1 & post ==0
predict y10

qui:reg bmi medu i.girl i.sports if treat == 1 & post ==1
predict y11

sum y*  if treat==1 
gen att = y11-y10 - (y01-y00)
sum att if treat==1 


restore


 2036  |  -1.568435   .4844934    -3.24   0.001    -2.518025   -.6188457
 global y bmi
 global x   medu i.girl i.sports _cons 
 global xiv medu i.girl i.sports  
 
gmm (($y-{b00:$x})*(treat==0 & post ==0)) ///
    (($y-{b01:$x})*(treat==0 & post ==1)) ///
    (($y-{b10:$x})*(treat==1 & post ==0)) ///
    (($y-{b11:$x})*(treat==1 & post ==1)) ///
    (({b00:}-{g00})*(treat==1 )) ///
    (({b01:}-{g01})*(treat==1 )) ///
    (({b10:}-{g10a})*(treat==1 & post==0)) ///
	(({b10:}-{g10b})*(treat==1 & post==1)) ///
    (({b10:}-{g10 })*(treat==1 )) ///	
    (({b11:}-{g11a})*(treat==1 & post==0)) ///
	(({b11:}-{g11b})*(treat==1 & post==1)) ///
    (({b11:}-{g11})*(treat==1 )) ///
    (({att}- ( ({b11:}-{b10:}) - ({b01:}-{b00:}) ))*(treat==1)), ///
    instruments(1: $xiv) instruments(2: $xiv) ///
    instruments(3: $xiv) instruments(4: $xiv) ///
    winit(identity) onestep quickderivatives  

------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         (1) |  -1.568435   .4844934    -3.24   0.001    -2.518025   -.6188457
------------------------------------------------------------------------------

        /g00 |   25.90386   .1390555   186.28   0.000     25.63131     26.1764
        /g01 |   25.81467   .1460807   176.72   0.000     25.52835    26.10098
        /g10 |   25.91617   .3130017    82.80   0.000      25.3027    26.52964
        /g11 |   24.25854   .3058624    79.31   0.000     23.65906    24.85802
        /att |  -1.568435   .4742694    -3.31   0.001    -2.497986   -.6388843

-------------+----------------------------------------------------------------
b00          |
        medu |   .0148359   .0486651     0.30   0.760     -.080546    .1102178
             |
        girl |
        Yes  |   .9846155   .2677647     3.68   0.000     .4598063    1.509425
             |
      sports |
        Yes  |   -1.06102   .2823557    -3.76   0.000    -1.614427   -.5076127
       _cons |   25.94681   .5541873    46.82   0.000     24.86062      27.033


*** Manual
sort treat post
mata
tp = st_data(.,"treat post"); n=rows(tp)
y  = st_data(.,"bmi");x = st_data(.,"medu i.girl i.sports"),J(n,1,1)
w00=(tp[,1]:==0):& (tp[,2]:==0)
w01=(tp[,1]:==0):& (tp[,2]:==1)
w10=(tp[,1]:==1):& (tp[,2]:==0)
w11=(tp[,1]:==1):& (tp[,2]:==1)
w1 =(tp[,1]:==1)
xx00 = cross(x,w00,x);xy00 = cross(x,w00,y);b00=invsym(xx00)*xy00
xx01 = cross(x,w01,x);xy01 = cross(x,w01,y);b01=invsym(xx01)*xy01 
xx10 = cross(x,w10,x);xy10 = cross(x,w10,y);b10=invsym(xx10)*xy10
xx11 = cross(x,w11,x);xy11 = cross(x,w11,y);b11=invsym(xx11)*xy11 
iff00 = (n  * invsym(xx00)*(x:*(y:-x*b00):*w00)')'
iff01 = (n  * invsym(xx01)*(x:*(y:-x*b01):*w01)')'
iff10 = (n  * invsym(xx10)*(x:*(y:-x*b10):*w10)')'
iff11 = (n  * invsym(xx11)*(x:*(y:-x*b11):*w11)')'
xb10=x*b10:*w11 + y:*w10
// Ahora los Means
ifd00  = (n/sum(w1))*(w1:*(x*b00:-mean(x*b00,w1)):- iff00 *colsum(x:*w1)'/n)
ifd01  = (n/sum(w1))*(w1:*(x*b01:-mean(x*b01,w1)):- iff01 *colsum(x:*w1)'/n)
// for t10 and t01 things are different because we observe the outcome some times.
// Kind of like 
ifd10a  = (n/sum(w10))*(w10:*(y:-mean(y,w10)))
ifd10b  = (n/sum(w11))*(w11:*(x*b10:-mean(x*b10,w11)):- iff10 *colsum(x:*w11)'/n)
// How do I combine the  
ifd10 = mean(w10)/mean(w1):*ifd10a :+ mean(w11)/mean(w1):*ifd10b :+ 
       mean(y,w10)*((w10:-mean(w10))/mean(w1) :- mean(w10):*(w1:-mean(w1)):/mean(w1)^2) :+ 
	   mean(x*b10,w11)*((w11:-mean(w11))/mean(w1) :- mean(w11):*(w1:-mean(w1)):/mean(w1)^2)  
	   
	   mean(x*b10,w11)*(w11:-mean(w11))/n   
 
ifd11a  = (n/sum(w11))*(w11:*(y:-mean(y,w11)))    
ifd11b  = (n/sum(w10))*(w10:*(x*b11:-mean(x*b11,w10)):- iff11 *colsum(x:*w10)'/n)


end

preserve 
keep if treat==0 & post ==0
 gmm (($y-{b00:$x})*(treat==0 & post ==0)) , ///
    instruments(1: $xiv)     winit(identity) onestep quickderivatives vce(cluster school)
 