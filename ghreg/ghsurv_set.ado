*! v1.0 April 2020 Fernando Rios-Avila 
** setting data
program ghsurv_set
syntax, dur(varname) time(varname) [nowarning]
	if "`warning'"=="" {
		pause on
		display in red "Warning: This will modify your dataset." _n in red " It is recommended for you to save a copy of the original file"
		pause type "BREAK" to exit, or "q, end or exit" to continue
	}
	qui {
		gen long _id=_n
		expand 2
		gen byte _y01=0+(_id!=_n)
		gen long _dur=`dur'-1 if _y01==1
		replace  _dur=`dur'   if _y01==0

		gen long _t=`time'-1 if _y01==1
		replace  _t=`time'   if _y01==0
		tempvar h
		sort _t _dur _y01
		bysort _t _dur:gen byte `h'=_y01[_N]-_y01[1]
		replace _dur=. if `h'!=1
		replace _t  =. if `h'!=1
		replace _y01=. if `h'!=1
		drop if `h'==0 
		** most important part...d0 d1
		label var _id  "Observation ID"
		label var _dur "Spell duration"
		label var _t   "Time  variable"
		label var _y01 "=0 base sample =1 continuation sample"
	}
	** display
	display as result "Data has been setup for ghsurv" 
	display as text "Four variables were created" 
	display as result "_id  " as text "Observation ID"
	display as result "_dur " as text "Spell duration"
	display as result "_t   " as text "Time  variable"
	display as result "_y01 " as text "=0 base sample =1 continuation sample"
end
