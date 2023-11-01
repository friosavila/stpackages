*! v 0.0.1 Simple Multi Installer.
* For those who want it all at once.
program msscinstall 
	syntax namelist, [replace]
	
	foreach i of local namelist {
		capture noisily ssc install `i', `replace'
	}
end