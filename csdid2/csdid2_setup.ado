*! v0 Simple Setup. Adds info so we do not need to type all the time
program csdid2_setup
	syntax, [ivar(varname) gvar(varname) tvar(varname) clear]
	if "`clear'"!="" {
		char _dta[ivar]    
		char _dta[gvar]    
		char _dta[tvar]    
		char _dta[csdid2]  
	}
	else {
		char _dta[ivar]   `ivar'
		char _dta[gvar]   `gvar'
		char _dta[tvar]   `tvar'
		char _dta[csdid2] csdid2
	}				
end