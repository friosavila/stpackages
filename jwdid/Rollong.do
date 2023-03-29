frause mpdta, clear
levelsof year , local(yl)
levelsof first if first>0, local(gl)

foreach i of local gl {
	foreach j of local yl {
		capture drop aux aux2
		if `j'>=`i'  {
			bysort county:egen aux = mean(lemp) if (year==(`i'-1)  ) & (firs==0 | first==`i')
			bysort county:egen aux2 = max(aux) 
			gen y1_`i'_`j' = lemp - aux2 if year==`j' & inlist(first,0,`i')
		}
		if `j'<`i' {
			bysort county:egen aux = mean(lemp) if ( year==(`j'-1) ) & (firs==0 | first==`i')
			bysort county:egen aux2 = max(aux) 
			gen y1_`i'_`j' = aux2 - lemp if year==(`i'-1) & inlist(first,0,`i') 
		}	
	}
}


foreach i of local gl {
	foreach j of local yl {
		capture drop aux aux2
		if `j'>=`i'  {
			bysort county:egen aux = mean(lemp) if (year<`i'  ) & (firs==0 | first==`i')
			bysort county:egen aux2 = max(aux) 
			gen y2_`i'_`j' = lemp - aux2 if year==`j' & inlist(first,0,`i')
		}
		if `j'<`i' {
			bysort county:egen aux = mean(lemp) if ( year<`j') & (firs==0 | first==`i')
			bysort county:egen aux2 = max(aux) 
			gen y2_`i'_`j' = aux2 - lemp if year==(`i'-1) & inlist(first,0,`i') 
		}	
	}
}


foreach i of local gl {
	foreach j of local yl {
		capture drop aux aux2
		if `j'>=`i'  {
			bysort county:egen aux = mean(lemp) if (year<`i'  ) & (firs==0 | first==`i' | first>`j' )
			bysort county:egen aux2 = max(aux) 
			gen y3_`i'_`j' = lemp - aux2 if year==`j' & ( first==0 | first==`i' | first>`j' )
		}
		if `j'<`i' {
			bysort county:egen aux = mean(lemp) if ( year<`j') & (firs==0 | first==`i' | first>`i')
			bysort county:egen aux2 = max(aux) 
			gen y3_`i'_`j' = aux2 - lemp if year==(`i'-1) & (first==0 | first ==`i' | first>`i')
		}	
	}
}
gen ttreat=year>=first 
replace ttreat=0 if first==0

foreach i in y_2004_2004 y_2004_2005 y_2004_2006 y_2004_2007 y_2006_2004 y_2006_2005 y_2006_2006 y_2006_2007 y_2007_2004 y_2007_2005 y_2007_2006 y_2007_2007 {
	reg `i' treat, nohead robust
}

foreach i in   y22004_2004 y22004_2005 y22004_2006 y22004_2007   y22006_2004 y22006_2005 y22006_2006 y22006_2007   y22007_2004 y22007_2005 y22007_2006 y22007_2007 {
	reg `i' treat, nohead robust
}

 -

jwdid lemp , ivar(county) gvar(first) tvar(year) never

gen h =0
foreach i in y22004_2003 y22004_2004 y22004_2005 y22004_2006 y22004_2007 y22006_2003 y22006_2004 y22006_2005 y22006_2006 y22006_2007 y22007_2003 y22007_2004 y22007_2005 y22007_2006  y22007_2007 {
	replace h =1  if `i'!=.
}

reg y1_2006_2007 ttreat
reg y2_2006_2007 ttreat
reg y3_2006_2007 ttreat


csdid2 lemp , ivar(county) gvar(first) tvar(year) agg(attgt) long
est sto m1
csdid2 lemp , ivar(county) gvar(first) tvar(year) agg(attgt) long notyet
est sto m2
csdid2 lemp , ivar(county) gvar(first) tvar(year) agg(attgt) long rolljw 
est sto m3
csdid2 lemp , ivar(county) gvar(first) tvar(year) agg(attgt) long notyet rolljw
est sto m4

esttab m1 m2 m3 m4, se mtitle(never notyet rnever rnotyet) b(5)


csdid2 asmrs , ivar(stfips) gvar(gvar) tvar(year) agg(attgt) long
est sto m1
csdid2 asmrs , ivar(stfips) gvar(gvar) tvar(year) agg(attgt) long notyet
est sto m2
csdid2 asmrs , ivar(stfips) gvar(gvar) tvar(year) agg(attgt) long rolljw 
est sto m3
csdid2 asmrs , ivar(stfips) gvar(gvar) tvar(year) agg(attgt) long notyet rolljw
est sto m4
