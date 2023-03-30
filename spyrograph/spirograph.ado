*! v0 Spyrigraph
*This is just for fun
program spirograph


	if `c(stata_version)'<16 {
		display "You need Stata 16 or higher to use this command"
		error 9
	}
	
	syntax, R(numlist min=1 ) S(numlist min=1 ) ///
			[R1(numlist min=1 ) S1(numlist min=1 ) ///
			R2(numlist min=1 ) S2(numlist min=1 ) ///
			R3(numlist min=1 ) S3(numlist min=1 ) ///
			R4(numlist min=1 ) S4(numlist min=1 ) ///
			R5(numlist min=1 ) S5(numlist min=1 ) ///
			R6(numlist min=1 ) S6(numlist min=1 ) ///
			R7(numlist min=1 ) S7(numlist min=1 ) ///
			R8(numlist min=1 ) S8(numlist min=1 ) ///
			R9(numlist min=1 ) S9(numlist min=1 ) ///			
			rotation(int 1) adjust(int 1) lwidth(real 0.1) * default color(string asis)]
 
 	tempname new
	frame create `new'
	if "`default'"!="" local default aspect(1) xlabel("") ylabel("")   ///
							   xsize(4) ysize(4)	xtitle("") ytitle("") ///
							   legend(off) xscale(noline) yscale(noline)
	frame `new': {
		local obs = `adjust'*54*`rotation'
		
		range t 0 (2*_pi*`rotation') `obs'

		local ccx=1	
		while "`r`cc''"!="" {		
			local flag = 1 
			local cnt  = 0
			
			gen y`cc'=0
			gen x`cc'=0
			
			while `flag'==1 {
				
				local cnt=`cnt'+1
				local x_r:word `cnt' of `r`cc''
				local x_s:word `cnt' of `s`cc''
	 
				if "`x_r'`x_s'"=="" {
					local flag=0
				}	
				else {
					if "`x_r'"=="" local x_r=0
					if "`x_s'"=="" local x_s=0
					qui:replace y`cc'=y`cc'+`x_r' * sin(`x_s'*t)
					qui:replace x`cc'=x`cc'+`x_r' * cos(`x_s'*t)
				}
				 
			}
			
			if `"`color'"'!="" {
				local ccol:word `ccx' of `color'
				if `"`ccol'"'!="" local fcolor `ccol'
			}	
			
			local lines `lines' (line x`cc' y`cc', lwidth(`lwidth') color(`ccol') )
			local cc=`cc'+1
			local ccx=`ccx'+1
		}
		two `lines' , `options' `default'
		
	}		 
end	
/*
set trace on
spyrograph, r(1 .3 .35 ) s(1.00 6.05 2 )  ///
			 r(1 .3 .35 ) s(1.00 6.05 3 )  ///
			 r(2 .3 .35 ) s(1.00 7.05 4 ) ///
			 r(3 .3 .35 ) s(1.00 7.05 5 ) ///
			 r(4 .3 .35 ) s(1.00 7.05 6 ) rotation(20) adjust(5) default lwidth(.1)
graph export bng.png, width(3000) replace
asd
spiral_plot, r1(1 .15 .75 .3 .5 .6 .5 4) s1(1 1 11.05 5.05 4 -5 1)   rotation(20) adjust(5) default color(white)
spiral_plot, r1(2 .15 .75 .3 .5 .6 .5 4) s1(1 2 11.05 5.05 4 -5 1)   rotation(20) adjust(5) default 
spiral_plot, r1(3 .15 .75 .3 .5 .6 .5 4) s1(1 3 11.05 5.05 4 -5 1)   rotation(20) adjust(5) default 
spiral_plot, r1(4 .15 .75 .3 .5 .6 .5 4) s1(1 4 11.05 5.05 4 -5 1)   rotation(20) adjust(5) default 
spiral_plot, r1(5 .15 .75 .3 .5 .6 .5 4) s1(1 5 11.05 5.05 4 -5 1)   rotation(20) adjust(5) default 
spiral_plot, r1(6 .15 .75 .3 .5 .6 .5 4) s1(1 6 11.05 5.05 4 -5 1)   rotation(20) adjust(5) default 
spiral_plot, r1(7 .15 .75 .3 .5 .6 .5 4) s1(1 7 11.05 5.05 4 -5 1)   rotation(20) adjust(5) default 
spiral_plot, r1(8 .15 .75 .3 .5 .6 .5 4) s1(1 8 11.05 5.05 4 -5 1)   rotation(20) adjust(5) default 
spiral_plot, r1(9 .15 .75 4.3 .5 2.6 .5 4) s1(1 9 11.05 5.05 4 -5 1)   rotation(20) adjust(5) default color(white)
*/

