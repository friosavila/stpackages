*! v 1.1 adds csname
* v 1 Save and clear
program csdid2_clean
	syntax [namelist(max=1 id="Names")], [save clear load replace dir(string asis) ///
										  csname(name) 				  ]
	if "`csname'"=="" local csname csdid
	if "`clear'"!="" {
		mata:mata drop `csname'
		capture: mata:mata drop csdidstat
	}
	else if "`save'"!="" {
		local old `"`c(pwd)'"'
		if `"`dir'"' !="" qui: cd `dir'
		mata:mata matsave `namelist' `csname', `replace' 
		qui: cd `"`old'"'
	}
	else if "`load'"!="" {
		local old `"`c(pwd)'"'
		if `"`dir'"' !="" qui: cd `dir'
		mata:mata matuse  `namelist', `replace'
		qui: cd `"`old'"'
	}
end