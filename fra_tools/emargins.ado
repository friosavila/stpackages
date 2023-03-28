*! v0.1 HAck to margins to store results
program emargins, eclass
	syntax [anything(everything)], [* estore(name) esave(name)]
	tempname previous
	if "`estore'`esave'"!="" {
		qui:est store `previous'
		margins `anything', `options' post
		if "`estore'"!="" est store `estore'
		if "`esave'"!=""  est save  `esave'
		qui:est restore `previous'
	}
	else {
		margins `0'
	}
end