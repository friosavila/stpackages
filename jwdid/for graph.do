matrix b=r(b)
matrix tbl=r(table)'
local coln:colname b
local coln= subinstr("`coln'","r2vs1._at@","",.)
local coln= subinstr("`coln'","bn","",.)
local coln= subinstr("`coln'",".__event__","",.)
local coln= subinstr("`coln'",".__event2__","",.)
matrix 
foreach i of local coln {
	local ll:label (__event__) `i'
	local lcoln `lcoln' `ll'
}
display "`lcoln'"

