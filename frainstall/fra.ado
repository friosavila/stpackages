*! v0.01 Own Installer 
program fra
	syntax anything, [all replace force]
	local from https://friosavila.github.io/stpackages
	tokenize `anything'
	if !inlist("`1'","describe", "install", "get") {
		display as error "`1' invalid subcommand"
	}	
	else {
		net `1' `2', `all' `replace' `from'
	}
end
