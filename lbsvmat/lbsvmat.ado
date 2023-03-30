*! V1.1 Bug fixed when N is small
* random program bc svmat doesnt do what i want it to do.
* solution. write my own version.
capture program drop lbsvmat
program define lbsvmat
	syntax anything, [name(string) matname]
	version 7
    parse "`anything'", parse(" ,")
	if "`2'" == "" | "`2'" == "," {
			local type "float"
			local A    "`1'"
			macro shift
	}
	else {
			local type "`1'"
			local A    "`2'"
			macro shift 2
	}
	local nx = rowsof(matrix(`A'))
	local nc = colsof(matrix(`A'))
	***************************************
	// here is where the safegards will be done.
	if _N<`nx' {
	    display as result "Expanding observations to `nx'"
		set obs `nx'
	}
	// here we create all variables
	forvalues i=1/`nc' {
		tempvar `i'
		qui:gen `type' ``i''=matrix(`A'[_n,`i'])
	}
	// here is where they are renamed.
	
	if "`name'`matname'"=="" {
		local eqn:coleq `A'
		local coln:colname `A'
		forvalues j=1/`nc' {
		   local eqnj:word `j' of `eqn'
		   local colnj:word `j' of `coln'
		   ren ``j'' `A'`j'
		   if "`eqnj'"=="_" {
		       label var `A'`j' "`colnj'"
		   }
		   else {
		       label var `A'`j' "`eqnj':`colnj'"
		   }
		}
	}
	
	if "`name'"!="" & "`matname'"=="" {
		local eqn:coleq `A'
		local coln:colname `A'
		forvalues j=1/`nc' {
		   local eqnj:word `j' of `eqn'
		   local colnj:word `j' of `coln'
		   ren ``j'' `name'`j'
		   if "`eqnj'"=="_" {
			   label var `name'`j' "`colnj'"
		   }
		   else {
			   label var `name'`j' "`eqnj':`colnj'"
		   }
		}
	}
	if "`matname'"!="" {
		local eqn:coleq `A'
		local coln:colname `A'
		forvalues j=1/`nc' {
		   local eqnj:word `j' of `eqn'
		   local colnj:word `j' of `coln'
		   if "`eqnj'"=="_" {
				local vnm = subinstr("`colnj'",".","_",.)
				local vnm = subinstr("`vnm'","#","X",.)
				local vnm = subinstr("`vnm'"," ","_",.)
				if strlen("`name'_`vnm'")<32 {
					ren ``j'' `name'_`vnm'	
					label var `name'_`vnm' "`colnj'"
				}
				else {
					ren ``j'' `name'_`j'
					label var `name'_`j' "`colnj'"
				}
		   }
		   else {
				local vnm = subinstr("`eqnj'_`colnj'",".","_",.)
				local vnm = subinstr("`vnm'","#","X",.)
				local vnm = subinstr("`vnm'"," ","_",.)
				if strlen("`name'_`vnm'")<32 {
					ren ``j'' `name'_`vnm'
					label var `name'_`vnm' "`colnj'"
				}
				else {
					ren ``j'' `name'_`j'
					label var `name'_`j' "`eqnj':`colnj'"
				}
		   }
		}
	}
end
