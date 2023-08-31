*! v0.2 Hack to margins to store results
program emargins, eclass
	syntax [anything(everything)], [* estore(name) esave(name) from(name) post]
	// estore: Stores margins into estore
	// esave: saves margins into esave
	// from: uses from to create margins from
	tempname previous
	// Always Store, just in case
	qui:est store `previous'

	if "`from'"!="" capture est store `previous'
	
	if "`estore'`esave'"!="" {		
		margins `anything', `options' post
		if "`estore'"!="" est store `estore'
		if "`esave'"!=""  est save  `esave'
		qui:est restore `previous'
	}
	else {
		margins `0'
	}

	if "`from'"!="" capture est restore `previous'
end
