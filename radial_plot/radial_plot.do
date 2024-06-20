*program polarhist
preserve
	clear
	range x 0 (2*_pi*.75) 50
	replace x=-x
	*local lval 32.6 37.9 41.9 43.1 33.9 39.2 35.1 35.8 25.7
	local lval 14.2 15.1 16.1 14.2 12.8 14.5 16.5 14.8 12.5 16.1 14.2 12.8 14.5 16.5 14.8 12.5
	local mx=0
	foreach i of local lval {
		if `i'>`mx' local mx `i'
	}
	foreach i of local lval {
		local lvalrs `lvalrs' `=`i'/`mx''
	}
	local lval `lvalrs'
	local nn:word count `lval'
	local i0=5

	local i =`i0'
	foreach ii in `lval' {
		local i = `i'+1
		local r `=(2*`i'-1)/(2*(`nn'+`i0'))'
		
		gen x`i'=`r'*cos(x*`ii'+0.5*_pi)
		gen y`i'=`r'*sin(x*`ii'+0.5*_pi)
	}
	local i =`i0'
	foreach ii in `lval' {
		local i = `i'+1
		local r `=(2*`i'-1)/(2*(`nn'+`i0'))'
		
		gen x_0`i'=`r'*cos(x+0.5*_pi)
		gen y_0`i'=`r'*sin(x+0.5*_pi)
	}
	

	local i =`i0'
	foreach ii in `lval' {
		
		local i = `i'+1
		local toline `toline' (line y_0`i' x_0`i', lwidth(.14in) color(gs15))
	}
	
		local i =`i0'
	foreach ii in `lval' {
		local j = `j'+1
		local i = `i'+1
		local toline `toline' (line y`i' x`i', lwidth(.14in) pstyle(p`j') )
	} 
	display `"`toline'"'32.6 37.9 41.9 43.1 33.9 39.2 35.1 35.8 25.7
	two `toline' , aspect(1)
	(scatteri `=y6[1]' 0 (9) "New England (14.2hrs)" ///
					       `=y7[1]' 0 (9) "M  Atlantic (15.1hrs)" ///
					  `=y8[1]' 0 (9) "EN Central (16.1hrs)" ///
					  `=y9[1]' 0 (9) "WN Central (14.2hrs)" ///
					  `=y10[1]' 0 (9) "S Atlantic (12.8hrs)" ///
					  `=y11[1]' 0 (9) "ES Central (14.5hrs)" ///
					  `=y12[1]' 0 (9) "WS Central (16.5hrs)" ///
					  `=y13[1]' 0 (9) "Mountain (14.8hrs)" ///
					  `=y14[1]' 0 (9) "Pacific (12.5hrs)", msymbol(none) ) , ///
			yscale(range(-1 1)) xscale(range(-1 1)) aspect(1)  xline(0) yline(0) ///
			xlabel("") ylabel("") legend(off)
restore	
*end

 