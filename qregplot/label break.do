capture program drop short_local
program short_local, rclass
	syntax, llocal(string) [maxlength(numlist integer >=1) lines(numlist integer >=1)]
	local lng = length("`llocal'")
	if "`maxlength'"!="" {
		if `lng'<=`maxlength' {
			return local out `llocal'	
			exit
		}
		local dlt `maxlength'
	}
	if "`lines'"!="" {
		local dlt = round(`lng'/`lines')
	}
	
	*local out = "*"
	*display "`lng':`dlt'"
	scalar out=""
	local low =1
		while ((`low')<=`lng') {
			
			local dlt0 = `dlt'
			while (substr("`llocal'",`low'+`dlt0',1)!=" ") & ((`low'+`dlt0')<= `lng') {
				local dlt0=`dlt0'+1
			}
			display substr("`llocal'",`low',`dlt0')
			local aux =strtrim(substr("`llocal'",`low',`dlt0'))
			local out "`out' "`aux'""
			
			local low =`low'+`dlt0'+1
			
		}
	
	local out ""`out'
	return local out `out'""
	
end
local ll:variable label taxes
display length("`ll'")

short_local, llocal(`ll') maxlength(10)  lines(2)
local kk "`r(out)'"
*local kk `r(k1)' `r(k2)' `r(k3)' `r(k4)'

scatter fines csize, title(`kk')