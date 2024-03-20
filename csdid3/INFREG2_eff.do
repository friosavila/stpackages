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
       /g10a |   25.89431   .3189516    81.19   0.000     25.26917    26.51944
       /g10b |   25.93528   .3136956    82.68   0.000     25.32045    26.55012
        /g10 |   25.91617   .3130017    82.80   0.000      25.3027    26.52964
       /g11a |   24.22046   .3130322    77.37   0.000     23.60692    24.83399
       /g11b |   24.29185   .3090285    78.61   0.000     23.68617    24.89753
        /g11 |   24.25854   .3058624    79.31   0.000     23.65906    24.85802
        /att |  -1.568435   .4742694    -3.31   0.001    -2.497986   -.6388843

.3128083175
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

-------------+----------------------------------------------------------------
b10          |
        medu |   .1029998   .1377464     0.75   0.455    -.1669781    .3729777
             |
        girl |
        Yes  |   .9326201   .6309013     1.48   0.139    -.3039237    2.169164
             |
      sports |
        Yes  |  -1.407573   .6700489    -2.10   0.036    -2.720845   -.0943017
       _cons |   25.32263   1.461243    17.33   0.000     22.45865    28.18662
-------------+----------------------------------------------------------------


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
xx00 = cross(x,w00,x);b00=invsym(xx00)*cross(x,w00,y)
xx01 = cross(x,w01,x);b01=invsym(xx01)*cross(x,w01,y) 
xx10 = cross(x,w10,x);b10=invsym(xx10)*cross(x,w10,y)
xx11 = cross(x,w11,x);b11=invsym(xx11)*cross(x,w11,y) 
iff00 = (n  * invsym(xx00)*(x:*(y:-x*b00):*w00)')'
iff01 = (n  * invsym(xx01)*(x:*(y:-x*b01):*w01)')'
iff10 = (n  * invsym(xx10)*(x:*(y:-x*b10):*w10)')'
iff11 = (n  * invsym(xx11)*(x:*(y:-x*b11):*w11)')'
// Ahora los Means
ifd00  = (n/sum(w1))*(w1:*(x*b00:-mean(x*b00,w1)):+ iff00 *colsum(x:*w1)'/n) 
ifd01  = (n/sum(w1))*(w1:*(x*b01:-mean(x*b01,w1)):+ iff01 *colsum(x:*w1)'/n)
ifd10  = (n/sum(w1))*(w1:*(x*b10:-mean(x*b10,w1)):+ iff10 *colsum(x:*w1)'/n)
ifd11  = (n/sum(w1))*(w1:*(x*b11:-mean(x*b11,w1)):+ iff11 *colsum(x:*w1)'/n)
ift = (ifd11-ifd10)-(ifd01-ifd00)
end

preserve 
keep if treat==0 & post ==0
 gmm (($y-{b00:$x})*(treat==0 & post ==0)) , ///
    instruments(1: $xiv)     winit(identity) onestep quickderivatives vce(cluster school)
 