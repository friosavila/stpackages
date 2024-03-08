# csdid2
New Version of CSDID. All in Mata

Hi, this is a new version of csdid that is now fully integrated into Mata. 
Thus is faster a more veratile that before!

You can see for yourself how it works:

```stata
* loads data from a repository
ssc install frause
frause mpdta, clear
* This will generate everything, but show nothing! unless you request it.
* this can be done using the options agg(attgt) or agg(group) etc
. csdid2 lemp, ivar(countyreal) tvar(year) gvar(first)
Always Treated units have been excluded
----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5 
............
* However after that is done, you can just use estat to produce outcomes you want

. estat event
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
     Pre_avg |   .0018283    .007657     0.24   0.811    -.0131791    .0168357
    Post_avg |  -.0772398    .019965    -3.87   0.000    -.1163705   -.0381092
         tm3 |   .0305067   .0150336     2.03   0.042     .0010414    .0599719
         tm2 |  -.0005631   .0132916    -0.04   0.966    -.0266142    .0254881
         tm1 |  -.0244587   .0142364    -1.72   0.086    -.0523616    .0034441
         tp0 |  -.0199318   .0118264    -1.69   0.092    -.0431111    .0032474
         tp1 |  -.0509574   .0168935    -3.02   0.003     -.084068   -.0178468
         tp2 |  -.1372587   .0364357    -3.77   0.000    -.2086713   -.0658461
         tp3 |  -.1008114   .0343592    -2.93   0.003    -.1681542   -.0334685
------------------------------------------------------------------------------
* This produces Asymptotic Standard errors by default. But you can also reqyest bootstrap (no saverif anymore)

. estat event, wboot
---------------------------------------------------------------------
            | Coefficient  Std. err.      t      [95% conf. interval]
------------+--------------------------------------------------------
    Pre_avg |   .0018283   .0076744     0.24    -.0172037    .0208603
   Post_avg |  -.0772398    .020526    -3.76    -.1281428   -.0263368
        tm3 |   .0305067   .0156614     1.95    -.0083324    .0693458
        tm2 |  -.0005631    .013331    -0.04    -.0336231    .0324969
        tm1 |  -.0244587   .0147201    -1.66    -.0609636    .0120462
        tp0 |  -.0199318   .0116118    -1.72    -.0487284    .0088648
        tp1 |  -.0509574   .0162214    -3.14    -.0911853   -.0107294
        tp2 |  -.1372587   .0367764    -3.73    -.2284616   -.0460559
        tp3 |  -.1008114   .0358325    -2.81    -.1896734   -.0119493
---------------------------------------------------------------------
WildBootstrap Standard errors
with 999 Repetitions

** But the fun doesnt end there. You can also plot!
. estat event, wboot plot
[Plot not included but you can check it out]
```

Now the biggest difference (if you notice) is that all the IF information is kept in memory using Mata. 
So, if you do something else, you may want to clean the created objects:

```
csdid2 , clear
```

Or, probably better, save the object in disk, so you can come back to the analysis If needed. 

```
csdid2 save_ex1, save 
clear all
csdid2 save_ex1, load
```

Of course, the only caveat you may have to use csdid2 to do the deed, instead of estat 

```
csdid2 event, estat
```

Couple of notes. When using very large samples (many groups/periods/observations) you will need a lot of memory to keep it all in memory.
In general, you should plan to have atleast:

(nobs x (# periods) x ( # groups) x 16 /1024^3) GB 
of memory to store all the info needed. Which will stay in memory until you use `csdid2, clear`.

For most applications that would be fine, but I recall some people using 10gb datasets, which may find problems.

Last note!

you need to copy all files in this repository on your ado/personal folder. And start from a new Stata session for it to work.
Fernando



