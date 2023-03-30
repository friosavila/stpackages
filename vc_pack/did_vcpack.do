 webuse nlswork, clear
 sort idcode year
 clonevar cunion=union
 by idcode:replace union=union[_n-1] if union==.
 forvalues i = 1/10 {
	by idcode:replace union=union[_n+1] if union==.
 }	
 
 by idcode:replace union=union[_n-1] if union[_n-1]==1
 
 capture drop fe1 fe2 xb
 
  bysort idcode:egen ng=min(year) if union==1
 bysort idcode:egen gvar=max(ng) 
 replace gvar=gvar-0
 
 reghdfe ln_wage if gvar>year | gvar==., abs(fe1=idcode fe2=year) keepsingletons
 predict xb
 capture drop ffe1 ffe2
 bysort idcode:egen ffe1=max(fe1)
 bysort year  :egen ffe2=max(fe2)
 
 
 gen dy = ln_wage - xb - ffe1 - ffe2
 drop if dy==.
 
 gen event = year - gvar
 
 vc_bw dy , vcoeff(event )
  
 bysort event: egen mean_dy=mean(dy)
 vc_reg dy if malways==0, vcoeff(event ) klist(-10/10) cluster(id) bw(0.2)
  vc_graph, constant
 addplot:, title("Union Wage gain After Some times Union") legend(off)

 ss
 matrix estd=e(std)
 matrix ebeas=e(betas)
 vc_reg dy if event>=0, vcoeff(event ) klist(0/15) cluster(id)

 matrix estd=estd\e(std)
 matrix ebeas=ebeas\e(betas)
 
 adde matrix std = estd
  adde matrix betas = ebeas
 
 vc_graph, constant
 addplot:, title("Union Wage gain After unionization") legend(off)
 addplot: scatter mean_dy event if inrange(event,-10,15) & event!=13
 sss
 gen  event2 =event+21
 replace event2=0 if event==.
 
 
 
 wks_ue hours wks_work
 
 capture drop fe1 fe2 xb
 reghdfe ln_wage if union==0, abs(fe1=idcode fe2=year) keepsingletons
 predict xb
 capture drop ffe1 ffe2
 bysort idcode:egen ffe1=max(fe1)
 bysort year  :egen ffe2=max(fe2)
 
 
 capture drop dy
 gen dy = ln_wage - xb - ffe1 - ffe2
 
 
  
  capture drop mean_dy 
 bysort event: egen mean_dy=mean(dy)
 vc_preg dy , vcoeff(event ) klist(-10/15) cluster(idcode)
 vc_graph, constant
 addplot:, title("Union weekswork/year change After unionization") legend(off)
 addplot: scatter mean_dy event if inrange(event,-10,15) & event!=13
 
 gen gfvar=gvar
 replace gfvar=1000 if gfvar==.
 replace event=year-(gvar-2)
  capture drop fe1 fe2 xb
 reghdfe ln_wage if year<(gfvar-2), abs(fe1=idcode fe2=year) keepsingletons
 predict xb
 capture drop ffe1 ffe2
 bysort idcode:egen ffe1=max(fe1)
 bysort year  :egen ffe2=max(fe2)
 
 vc_preg dy if event<0, vcoeff(event ) klist(-10/-1) cluster(idcode) bw(2)
 matrix std=e(std)
 matrix betas=e(betas)
 
   *vc_bw dy if event>=0 , vcoeff(event )

 vc_preg dy if event>=0, vcoeff(event ) klist(0/15) cluster(idcode) bw(2)
 matrix std=std\e(std)
 matrix betas=betas\e(betas)
 adde matrix std std
 adde matrix betas betas
 
 vc_graph, constant over(0)
  addplot: scatter mean_dy event if inrange(event,-10,15) & event!=15

 