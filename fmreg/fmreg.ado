*! v0.0.1 
* fmreg: Program to use frames with regressions. Will be goood 
*capture program drop framereg
program define framereg, properties(prefix)
	version 16
	set prefix fmreg
	gettoken first second : 0, parse(":")
	tempname temp
	if "`first'"==":" {
		*gettoken other cmd0 : second, parse(" :")
		*cmd0 will have the command itself.
		gettoken cmd 0: second
		syntax varlist [if] [in] [pw aw iw fw], [*] 
		frame put * `if', into(`temp')
		frame `temp': `cmd' `varlist' [`weight'`exp'], `options'
		*frame drop __temp
	}
end
 