*! v 1 Save and clear
program csdid2_clean
	syntax [namelist(max=1 id="Names")], [save clear load replace dir(string asis)]
	if "`clear'"!="" {
		mata:mata drop csdid
		mata:mata drop csdidstat
	}
	else if "`save'"!="" {
		local old `"`c(pwd)'"'
		if `"`dir'"' !="" qui: cd `dir'
		mata:mata matsave `namelist' csdid, `replace' 
		qui: cd `"`old'"'
	}
	else if "`load'"!="" {
		local old `"`c(pwd)'"'
		if `"`dir'"' !="" qui: cd `dir'
		mata:mata matuse  `namelist', `replace'
		qui: cd `"`old'"'
	}
end