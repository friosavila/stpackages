frause mpdta, clear
gen st = floor(county/1000)
gen w = runiformint(1,7)
bysort county:replace w=w[1]
mata mata clear
run "C:\Users\Fernando\Documents\GitHub\stpackages\csdid2\drdid.mata"
run "C:\Users\Fernando\Documents\GitHub\stpackages\csdid2\csdid.mata"
run "C:\Users\Fernando\Documents\GitHub\stpackages\csdid2\csdid_stats.mata"
csdid  lemp    , ivar( countyreal) time(year) gvar(first) agg(attgt) method(reg) long2
csdid2 lemp    , ivar( countyreal) tvar(year) gvar(first) agg(attgt) method(reg)


csdid2 lemp  , ivar( countyreal) tvar(year) gvar(first) agg(event) 
csdid lemp  , ivar( countyreal) time(year) gvar(first) agg(event)  long2

csdid2 lemp lpop  , ivar( countyreal) tvar(year) gvar(first) agg(event) method(reg)
csdid lemp lpop  , ivar( countyreal) time(year) gvar(first) agg(event)  method(reg) long2

csdid2 lemp [w=w]  , ivar( countyreal) tvar(year) gvar(first) agg(attgt) method(reg)

csdid lemp [w=w], ivar( countyreal) time(year) gvar(first) agg(attgt)  method(reg) long2

csdid2 lemp , ivar( countyreal) tvar(year) gvar(first) agg(event) 
assert `"`e(base)'"'       == `"Base Universal"'
assert `"`e(cntrl)'"'      == `"Never treated"'
assert `"`e(method)'"'     == `"reg"'
assert `"`e(estat_cmd)'"'  == `"csdid2_estat"'
assert `"`e(cmdline)'"'    == `"csdid2 lemp , ivar( countyreal) tvar(year) gvar(first) agg(event)"'
assert `"`e(cmd)'"'        == `"csdid2"'
assert `"`e(vcetype)'"'    == `"Robust"'
assert `"`e(properties)'"' == `"b V"'

qui {
mat T_b = J(1,9,0)
mat T_b[1,1] =   .017595643753745
mat T_b[1,2] = -.0772398214573161
mat T_b[1,3] =   .003306356692512
mat T_b[1,4] =  .0250218295975542
mat T_b[1,5] =   .024458744971169
mat T_b[1,6] = -.0199318167892598
mat T_b[1,7] =  -.050957367065195
mat T_b[1,8] = -.1372587388894044
mat T_b[1,9] = -.1008113630854053
}
matrix C_b = e(b)
assert mreldif( C_b , T_b ) < 1E-8
_assert_streq `"`: rowfullnames C_b'"' `"y1"'
_assert_streq `"`: colfullnames C_b'"' `"Pre_avg Post_avg tm4 tm3 tm2 tp0 tp1 tp2 tp3"'
mat drop C_b T_b

qui {
mat T_V = J(9,9,0)
mat T_V[1,1] =   .000286290277302
mat T_V[1,2] = -.0000699197196847
mat T_V[1,3] =  .0003815389226184
mat T_V[1,4] =  .0002804513165675
mat T_V[1,5] =  .0001968805927202
mat T_V[1,6] =  .0000333051709288
mat T_V[1,7] = -.0000551650679429
mat T_V[1,8] = -.0001468122320985
mat T_V[1,9] = -.0001110067496262
mat T_V[2,1] = -.0000699197196847
mat T_V[2,2] =  .0003986007882398
mat T_V[2,3] =  -.000109822195412
mat T_V[2,4] = -.0000581427116154
mat T_V[2,5] = -.0000417942520266
mat T_V[2,6] =  .0000776843638391
mat T_V[2,7] =  .0002581489637783
mat T_V[2,8] =  .0006493134095847
mat T_V[2,9] =  .0006092564157568
mat T_V[3,1] =  .0003815389226184
mat T_V[3,2] =  -.000109822195412
mat T_V[3,3] =  .0005978940904662
mat T_V[3,4] =  .0003359073547961
mat T_V[3,5] =  .0002108153225929
mat T_V[3,6] =  .0000284213133248
mat T_V[3,7] = -.0000824643289709
mat T_V[3,8] = -.0002135535062099
mat T_V[3,9] = -.0001716922597921
mat T_V[4,1] =  .0002804513165675
mat T_V[4,2] = -.0000581427116154
mat T_V[4,3] =  .0003359073547961
mat T_V[4,4] =  .0003282952872387
mat T_V[4,5] =  .0001771513076679
mat T_V[4,6] =  .0000382262676265
mat T_V[4,7] =  -.000042674305463
mat T_V[4,8] = -.0001311357514049
mat T_V[4,9] = -.0000969870572202
mat T_V[5,1] =  .0001968805927202
mat T_V[5,2] = -.0000417942520266
mat T_V[5,3] =  .0002108153225929
mat T_V[5,4] =  .0001771513076679
mat T_V[5,5] =  .0002026751478997
mat T_V[5,6] =  .0000332679318352
mat T_V[5,7] = -.0000403565693949
mat T_V[5,8] = -.0000957474386806
mat T_V[5,9] = -.0000643409318662
mat T_V[6,1] =  .0000333051709288
mat T_V[6,2] =  .0000776843638391
mat T_V[6,3] =  .0000284213133248
mat T_V[6,4] =  .0000382262676265
mat T_V[6,5] =  .0000332679318352
mat T_V[6,6] =  .0001398628868337
mat T_V[6,7] =  .0000615316221245
mat T_V[6,8] =  .0000437211453232
mat T_V[6,9] =  .0000656218010752
mat T_V[7,1] = -.0000551650679429
mat T_V[7,2] =  .0002581489637783
mat T_V[7,3] = -.0000824643289709
mat T_V[7,4] =  -.000042674305463
mat T_V[7,5] = -.0000403565693949
mat T_V[7,6] =  .0000615316221245
mat T_V[7,7] =  .0002853895404404
mat T_V[7,8] =  .0003604010457427
mat T_V[7,9] =  .0003252736468058
mat T_V[8,1] = -.0001468122320985
mat T_V[8,2] =  .0006493134095847
mat T_V[8,3] = -.0002135535062099
mat T_V[8,4] = -.0001311357514049
mat T_V[8,5] = -.0000957474386806
mat T_V[8,6] =  .0000437211453232
mat T_V[8,7] =  .0003604010457427
mat T_V[8,8] =   .001327557632085
mat T_V[8,9] =  .0008655738151882
mat T_V[9,1] = -.0001110067496262
mat T_V[9,2] =  .0006092564157568
mat T_V[9,3] = -.0001716922597921
mat T_V[9,4] = -.0000969870572202
mat T_V[9,5] = -.0000643409318662
mat T_V[9,6] =  .0000656218010752
mat T_V[9,7] =  .0003252736468058
mat T_V[9,8] =  .0008655738151882
mat T_V[9,9] =  .0011805563999581
}
matrix C_V = e(V)
assert mreldif( C_V , T_V ) < 1E-8
_assert_streq `"`: rowfullnames C_V'"' `"Pre_avg Post_avg tm4 tm3 tm2 tp0 tp1 tp2 tp3"'
_assert_streq `"`: colfullnames C_V'"' `"Pre_avg Post_avg tm4 tm3 tm2 tp0 tp1 tp2 tp3"'
mat drop C_V T_V


csdid2 lemp [w=lpop], ivar( countyreal) tvar(year) gvar(first) agg(event)

assert `"`e(base)'"'       == `"Base Universal"'
assert `"`e(cntrl)'"'      == `"Never treated"'
assert `"`e(method)'"'     == `"reg"'
assert `"`e(estat_cmd)'"'  == `"csdid2_estat"'
assert `"`e(cmdline)'"'    == `"csdid2 lemp [w=lpop], ivar( countyreal) tvar(year) gvar(first) agg(event)"'
assert `"`e(cmd)'"'        == `"csdid2"'
assert `"`e(vcetype)'"'    == `"Robust"'
assert `"`e(properties)'"' == `"b V"'

qui {
mat T_b = J(1,9,0)
mat T_b[1,1] =  .0169262437014923
mat T_b[1,2] =  -.069393526595745
mat T_b[1,3] =   .007932802034353
mat T_b[1,4] =  .0214173492404631
mat T_b[1,5] =  .0214285798296607
mat T_b[1,6] = -.0237705768478331
mat T_b[1,7] = -.0407911825853478
mat T_b[1,8] = -.1153380429226659
mat T_b[1,9] = -.0976743040271333
}
matrix C_b = e(b)
assert mreldif( C_b , T_b ) < 1E-8
_assert_streq `"`: rowfullnames C_b'"' `"y1"'
_assert_streq `"`: colfullnames C_b'"' `"Pre_avg Post_avg tm4 tm3 tm2 tp0 tp1 tp2 tp3"'
mat drop C_b T_b

qui {
mat T_V = J(9,9,0)
mat T_V[1,1] =  .0002311442272515
mat T_V[1,2] = -.0000913516255354
mat T_V[1,3] =  .0002942556613254
mat T_V[1,4] =  .0002300102113643
mat T_V[1,5] =  .0001691668090648
mat T_V[1,6] =  1.97724945317e-06
mat T_V[1,7] = -.0000719224656945
mat T_V[1,8] = -.0001704115735685
mat T_V[1,9] = -.0001250497123318
mat T_V[2,1] = -.0000913516255354
mat T_V[2,2] =  .0002956989691059
mat T_V[2,3] = -.0001229611368996
mat T_V[2,4] = -.0000827218925021
mat T_V[2,5] = -.0000683718472045
mat T_V[2,6] =  .0000497459253988
mat T_V[2,7] =  .0001986659277167
mat T_V[2,8] =  .0005048986425726
mat T_V[2,9] =  .0004294853807356
mat T_V[3,1] =  .0002942556613254
mat T_V[3,2] = -.0001229611368996
mat T_V[3,3] =  .0004321568114057
mat T_V[3,4] =  .0002650905107159
mat T_V[3,5] =  .0001855196618545
mat T_V[3,6] =  4.29689321764e-06
mat T_V[3,7] = -.0000922749994412
mat T_V[3,8] = -.0002301133832139
mat T_V[3,9] = -.0001737530581611
mat T_V[4,1] =  .0002300102113643
mat T_V[4,2] = -.0000827218925021
mat T_V[4,3] =  .0002650905107159
mat T_V[4,4] =  .0002623370288506
mat T_V[4,5] =  .0001626030945263
mat T_V[4,6] =  1.91446099020e-06
mat T_V[4,7] = -.0000640406288387
mat T_V[4,8] = -.0001547330524719
mat T_V[4,9] = -.0001140283496882
mat T_V[5,1] =  .0001691668090648
mat T_V[5,2] = -.0000683718472045
mat T_V[5,3] =  .0001855196618545
mat T_V[5,4] =  .0001626030945263
mat T_V[5,5] =  .0001593776708136
mat T_V[5,6] = -2.79605848321e-07
mat T_V[5,7] = -.0000594517688036
mat T_V[5,8] = -.0001263882850197
mat T_V[5,9] = -.0000873677291463
mat T_V[6,1] =  1.97724945317e-06
mat T_V[6,2] =  .0000497459253988
mat T_V[6,3] =  4.29689321764e-06
mat T_V[6,4] =  1.91446099020e-06
mat T_V[6,5] = -2.79605848321e-07
mat T_V[6,6] =  .0000730459300969
mat T_V[6,7] =  .0000481226655546
mat T_V[6,8] =   .000031455063973
mat T_V[6,9] =  .0000463600419708
mat T_V[7,1] = -.0000719224656945
mat T_V[7,2] =  .0001986659277167
mat T_V[7,3] = -.0000922749994412
mat T_V[7,4] = -.0000640406288387
mat T_V[7,5] = -.0000594517688036
mat T_V[7,6] =  .0000481226655546
mat T_V[7,7] =  .0002266976249852
mat T_V[7,8] =  .0002812880537518
mat T_V[7,9] =  .0002385553665754
mat T_V[8,1] = -.0001704115735685
mat T_V[8,2] =  .0005048986425726
mat T_V[8,3] = -.0002301133832139
mat T_V[8,4] = -.0001547330524719
mat T_V[8,5] = -.0001263882850197
mat T_V[8,6] =   .000031455063973
mat T_V[8,7] =  .0002812880537518
mat T_V[8,8] =  .0010145967593686
mat T_V[8,9] =  .0006922546931968
mat T_V[9,1] = -.0001250497123318
mat T_V[9,2] =  .0004294853807356
mat T_V[9,3] = -.0001737530581611
mat T_V[9,4] = -.0001140283496882
mat T_V[9,5] = -.0000873677291463
mat T_V[9,6] =  .0000463600419708
mat T_V[9,7] =  .0002385553665754
mat T_V[9,8] =  .0006922546931968
mat T_V[9,9] =  .0007407714211994
}
matrix C_V = e(V)
assert mreldif( C_V , T_V ) < 1E-8
_assert_streq `"`: rowfullnames C_V'"' `"Pre_avg Post_avg tm4 tm3 tm2 tp0 tp1 tp2 tp3"'
_assert_streq `"`: colfullnames C_V'"' `"Pre_avg Post_avg tm4 tm3 tm2 tp0 tp1 tp2 tp3"'
mat drop C_V T_V


csdid2 lemp , ivar( countyreal) tvar(year) gvar(first) agg(event) cluster(st) 


assert `"`e(base)'"'       == `"Base Universal"'
assert `"`e(cntrl)'"'      == `"Never treated"'
assert `"`e(cluster)'"'    == `"st"'
assert `"`e(method)'"'     == `"reg"'
assert `"`e(estat_cmd)'"'  == `"csdid2_estat"'
_assert_streq `"`e(cmdline)'"' `"csdid2 lemp , ivar( countyreal) tvar(year) gvar(first) agg(event) cluster(st)"'
assert `"`e(cmd)'"'        == `"csdid2"'
assert `"`e(vcetype)'"'    == `"Robust"'
assert `"`e(properties)'"' == `"b V"'

qui {
mat T_b = J(1,9,0)
mat T_b[1,1] =   .017595643753745
mat T_b[1,2] = -.0772398214573161
mat T_b[1,3] =   .003306356692512
mat T_b[1,4] =  .0250218295975542
mat T_b[1,5] =   .024458744971169
mat T_b[1,6] = -.0199318167892598
mat T_b[1,7] =  -.050957367065195
mat T_b[1,8] = -.1372587388894044
mat T_b[1,9] = -.1008113630854053
}
matrix C_b = e(b)
assert mreldif( C_b , T_b ) < 1E-8
_assert_streq `"`: rowfullnames C_b'"' `"y1"'
_assert_streq `"`: colfullnames C_b'"' `"Pre_avg Post_avg tm4 tm3 tm2 tp0 tp1 tp2 tp3"'
mat drop C_b T_b

qui {
mat T_V = J(9,9,0)
mat T_V[1,1] =  .0007829071217662
mat T_V[1,2] = -.0002717218539991
mat T_V[1,3] =  .0010315906382616
mat T_V[1,4] =   .000760194622637
mat T_V[1,5] =     .0005569361044
mat T_V[1,6] = -.0001115421517223
mat T_V[1,7] = -.0002578712924792
mat T_V[1,8] = -.0003893609598156
mat T_V[1,9] = -.0003281130119792
mat T_V[2,1] = -.0002717218539991
mat T_V[2,2] =  .0002183504515259
mat T_V[2,3] = -.0003294819691427
mat T_V[2,4] = -.0002994560390609
mat T_V[2,5] = -.0001862275537937
mat T_V[2,6] =  .0000568837146026
mat T_V[2,7] =  .0002265694813186
mat T_V[2,8] =  .0003051592816874
mat T_V[2,9] =  .0002847893284949
mat T_V[3,1] =  .0010315906382616
mat T_V[3,2] = -.0003294819691427
mat T_V[3,3] =  .0015201009874528
mat T_V[3,4] =  .0009289254297727
mat T_V[3,5] =  .0006457454975592
mat T_V[3,6] =  -.000110003095552
mat T_V[3,7] = -.0002160765790923
mat T_V[3,8] = -.0005383288323113
mat T_V[3,9] = -.0004535193696153
mat T_V[4,1] =   .000760194622637
mat T_V[4,2] = -.0002994560390609
mat T_V[4,3] =  .0009289254297727
mat T_V[4,4] =  .0008118381067114
mat T_V[4,5] =  .0005398203314268
mat T_V[4,6] = -.0001164242778234
mat T_V[4,7] = -.0003698006047936
mat T_V[4,8] = -.0003826496670879
mat T_V[4,9] = -.0003289496065386
mat T_V[5,1] =     .0005569361044
mat T_V[5,2] = -.0001862275537937
mat T_V[5,3] =  .0006457454975592
mat T_V[5,4] =  .0005398203314268
mat T_V[5,5] =  .0004852424842139
mat T_V[5,6] = -.0001081990817914
mat T_V[5,7] = -.0001877366935518
mat T_V[5,8] = -.0002471043800477
mat T_V[5,9] = -.0002018700597838
mat T_V[6,1] = -.0001115421517223
mat T_V[6,2] =  .0000568837146026
mat T_V[6,3] =  -.000110003095552
mat T_V[6,4] = -.0001164242778234
mat T_V[6,5] = -.0001081990817914
mat T_V[6,6] =  .0001057850796644
mat T_V[6,7] =  .0000670490666338
mat T_V[6,8] =  .0000127123457306
mat T_V[6,9] =  .0000419883663815
mat T_V[7,1] = -.0002578712924792
mat T_V[7,2] =  .0002265694813186
mat T_V[7,3] = -.0002160765790923
mat T_V[7,4] = -.0003698006047936
mat T_V[7,5] = -.0001877366935518
mat T_V[7,6] =  .0000670490666338
mat T_V[7,7] =  .0004120548254679
mat T_V[7,8] =  .0002160765790923
mat T_V[7,9] =  .0002110974540805
mat T_V[8,1] = -.0003893609598156
mat T_V[8,2] =  .0003051592816874
mat T_V[8,3] = -.0005383288323113
mat T_V[8,4] = -.0003826496670879
mat T_V[8,5] = -.0002471043800477
mat T_V[8,6] =  .0000127123457306
mat T_V[8,7] =  .0002160765790923
mat T_V[8,8] =  .0005383288323113
mat T_V[8,9] =  .0004535193696153
mat T_V[9,1] = -.0003281130119792
mat T_V[9,2] =  .0002847893284949
mat T_V[9,3] = -.0004535193696153
mat T_V[9,4] = -.0003289496065386
mat T_V[9,5] = -.0002018700597838
mat T_V[9,6] =  .0000419883663815
mat T_V[9,7] =  .0002110974540805
mat T_V[9,8] =  .0004535193696153
mat T_V[9,9] =  .0004325521239021
}
matrix C_V = e(V)
assert mreldif( C_V , T_V ) < 1E-8
_assert_streq `"`: rowfullnames C_V'"' `"Pre_avg Post_avg tm4 tm3 tm2 tp0 tp1 tp2 tp3"'
_assert_streq `"`: colfullnames C_V'"' `"Pre_avg Post_avg tm4 tm3 tm2 tp0 tp1 tp2 tp3"'
mat drop C_V T_V

csdid2 lemp [w=lpop], ivar( countyreal) tvar(year) gvar(first) agg(event) cluster(st)


assert `"`e(base)'"'       == `"Base Universal"'
assert `"`e(cntrl)'"'      == `"Never treated"'
assert `"`e(cluster)'"'    == `"st"'
assert `"`e(method)'"'     == `"reg"'
assert `"`e(estat_cmd)'"'  == `"csdid2_estat"'
_assert_streq `"`e(cmdline)'"' `"csdid2 lemp [w=lpop], ivar( countyreal) tvar(year) gvar(first) agg(event) cluster(st)"'
assert `"`e(cmd)'"'        == `"csdid2"'
assert `"`e(vcetype)'"'    == `"Robust"'
assert `"`e(properties)'"' == `"b V"'

qui {
mat T_b = J(1,9,0)
mat T_b[1,1] =  .0169262437014923
mat T_b[1,2] =  -.069393526595745
mat T_b[1,3] =   .007932802034353
mat T_b[1,4] =  .0214173492404631
mat T_b[1,5] =  .0214285798296607
mat T_b[1,6] = -.0237705768478331
mat T_b[1,7] = -.0407911825853478
mat T_b[1,8] = -.1153380429226659
mat T_b[1,9] = -.0976743040271333
}
matrix C_b = e(b)
assert mreldif( C_b , T_b ) < 1E-8
_assert_streq `"`: rowfullnames C_b'"' `"y1"'
_assert_streq `"`: colfullnames C_b'"' `"Pre_avg Post_avg tm4 tm3 tm2 tp0 tp1 tp2 tp3"'
mat drop C_b T_b

qui {
mat T_V = J(9,9,0)
mat T_V[1,1] =  .0008553362098125
mat T_V[1,2] = -.0003729056186157
mat T_V[1,3] =  .0011344934983186
mat T_V[1,4] =  .0008256904623471
mat T_V[1,5] =  .0006058246687719
mat T_V[1,6] = -.0001762809606567
mat T_V[1,7] = -.0003472355983124
mat T_V[1,8] = -.0005319225374714
mat T_V[1,9] = -.0004361833780222
mat T_V[2,1] = -.0003729056186157
mat T_V[2,2] =  .0002955924619583
mat T_V[2,3] = -.0004470501707058
mat T_V[2,4] = -.0004022834464612
mat T_V[2,5] = -.0002693832386801
mat T_V[2,6] =  .0000797094956907
mat T_V[2,7] =  .0003083500186895
mat T_V[2,8] =  .0004160569766317
mat T_V[2,9] =  .0003782533568214
mat T_V[3,1] =  .0011344934983186
mat T_V[3,2] = -.0004470501707058
mat T_V[3,3] =  .0016447127057925
mat T_V[3,4] =  .0010073691441048
mat T_V[3,5] =  .0007513986450585
mat T_V[3,6] = -.0001769648458234
mat T_V[3,7] = -.0002916471911943
mat T_V[3,8] = -.0007284565174212
mat T_V[3,9] = -.0005911321283841
mat T_V[4,1] =  .0008256904623471
mat T_V[4,2] = -.0004022834464612
mat T_V[4,3] =  .0010073691441048
mat T_V[4,4] =  .0008715078927645
mat T_V[4,5] =  .0005981943501718
mat T_V[4,6] = -.0001981435967092
mat T_V[4,7] = -.0004765814799506
mat T_V[4,8] = -.0005077733730396
mat T_V[4,9] = -.0004266353361453
mat T_V[5,1] =  .0006058246687719
mat T_V[5,2] = -.0002693832386801
mat T_V[5,3] =  .0007513986450585
mat T_V[5,4] =  .0005981943501718
mat T_V[5,5] =  .0004678810110854
mat T_V[5,6] = -.0001537344394376
mat T_V[5,7] = -.0002734781237922
mat T_V[5,8] = -.0003595377219535
mat T_V[5,9] = -.0002907826695372
mat T_V[6,1] = -.0001762809606567
mat T_V[6,2] =  .0000797094956907
mat T_V[6,3] = -.0001769648458234
mat T_V[6,4] = -.0001981435967092
mat T_V[6,5] = -.0001537344394376
mat T_V[6,6] =  .0001225240012724
mat T_V[6,7] =  .0001146947512824
mat T_V[6,8] =  .0000207157532791
mat T_V[6,9] =  .0000609034769289
mat T_V[7,1] = -.0003472355983124
mat T_V[7,2] =  .0003083500186895
mat T_V[7,3] = -.0002916471911943
mat T_V[7,4] = -.0004765814799506
mat T_V[7,5] = -.0002734781237922
mat T_V[7,6] =  .0001146947512824
mat T_V[7,7] =  .0005344335781815
mat T_V[7,8] =  .0002974894749616
mat T_V[7,9] =  .0002867822703325
mat T_V[8,1] = -.0005319225374714
mat T_V[8,2] =  .0004160569766317
mat T_V[8,3] = -.0007284565174212
mat T_V[8,4] = -.0005077733730396
mat T_V[8,5] = -.0003595377219535
mat T_V[8,6] =  .0000207157532791
mat T_V[8,7] =  .0002974894749616
mat T_V[8,8] =   .000743048976445
mat T_V[8,9] =  .0006029737018409
mat T_V[9,1] = -.0004361833780222
mat T_V[9,2] =  .0003782533568214
mat T_V[9,3] = -.0005911321283841
mat T_V[9,4] = -.0004266353361453
mat T_V[9,5] = -.0002907826695372
mat T_V[9,6] =  .0000609034769289
mat T_V[9,7] =  .0002867822703325
mat T_V[9,8] =  .0006029737018409
mat T_V[9,9] =  .0005623539781832
}
matrix C_V = e(V)
assert mreldif( C_V , T_V ) < 1E-8
_assert_streq `"`: rowfullnames C_V'"' `"Pre_avg Post_avg tm4 tm3 tm2 tp0 tp1 tp2 tp3"'
_assert_streq `"`: colfullnames C_V'"' `"Pre_avg Post_avg tm4 tm3 tm2 tp0 tp1 tp2 tp3"'
mat drop C_V T_V

