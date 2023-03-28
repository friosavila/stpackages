*! v1 Random program. To add stuff to r()
* This should be useful to "store" additional information into r() results for later use
program addr, rclass
	version 9
	syntax anything(equalok), [new copy]
	if "`new'"=="" {
		return add
		if "`copy'"!=""	local 0 `anything', copy
		else 			local 0 `anything'
	}
	else {
	    if "`copy'"!=""	local 0 `anything', copy
		else 			local 0 `anything'
	}
	return `0'
end