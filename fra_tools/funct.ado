*! v1 Functions for Many Commands
program funct, properties(prefix)
	set prefix funct
	gettoken first second : 0, parse(":")
	local prefix _new
	if "`first'"!=":" {
		funct_opt `first'
		local keep    `r(keep)'
		local replace `r(replace)'
		local prefix  `r(prefix)'
		gettoken cmd 0 : 0, parse(":")

	}
 	{
		gettoken cmd 0 : 0, parse(":")
		gettoken cmd 0: 0
		syntax anything [if] [in] [aw iw fw pw], [*]
		
		** loop
		while `"`anything'"'!="" {
			gettoken xv anything:anything, bind
			if  strpos("`xv'","(")==0 {
				local vars `vars' `xv'
			}
			else {
				local nc=`nc'+1
				if "`replace'"!="" capture drop `prefix'`nc'
				gen double  `prefix'`nc' = `xv'
				label var   `prefix'`nc' "`xv'"
				local todel `todel' `prefix'`nc'
				local vars  `vars' `prefix'`nc'
			}
		}
 		syntax anything [if] [in] [aw iw fw pw], [*]
 		`cmd' `vars' `if' `in' [`weight'`exp'], `options'
		if "`todel'"!="" & "`keep'"=="" drop `todel'
	}	
		
		
end

program funct_opt, rclass
	syntax , [keep replace prefix(name)]
	return local keep `keep'
	return local replace `replace'
	if "`prefix'"!="" return local prefix `prefix'
	else              return local prefix _new
end