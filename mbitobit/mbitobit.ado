*! v1.01 Corrected EQ parsing Fernando Rios Avila
* v1 Fernando Rios Avila
* This Program estimates a reduced form Bivariate Tobit.
* The program uses a similar syntax as: mvtobit , bitobit and cmp (for bitobit)
* The advantage this program, however, is that it comes with the added programs 
* mbitobit_p, which produce predicted values, as in tobit. 
* This also allows for estimation of marginal effects of different types.
* Only drawback....It allows left censoring at zero only.
* May programm different censorships at some point.

capture program drop myparse_tobit
program myparse_tobit, rclass
syntax anything, 
	local rest `anything'
	while "`rest'"!="" {
	   gettoken eqt rest: rest, match(nvu) 
	   if "`eqt'"!="" {
		  local cnt=`cnt'+1
		  local r`cnt' `eqt'
	   }
	}
	forvalues j=1/`cnt' {
		return local m`j' `r`j''
	}
return scalar cnt =`cnt'
end

capture program drop parse_eq
program parse_eq, rclass
	syntax anything(equalok)
	local equal=strpos("`anything'","=")
	if `equal'==0  {
		tokenize `anything'
		local y2 `1'
		macro shift
		local z2 `*'
		}
	else if `equal'!=0 	{
	    local sel2=subinstr("`anything'","="," ",.)
		tokenize `sel2'
		local y2 `1'
		macro shift
		local z2 `*'
	}	
	return local depvar  ="`y2'"
	return local indepvar ="`z2'"
end

capture program drop mbitobit
program mbitobit, eclass
    if  replay() {
	    if "`e(cmd)'"=="mbitobit" {
		    ml display  `0'
			exit
		}
    }
syntax anything [if] [aw fw pw iw], [   CLuster(string) Robust 						/// Standard error options. One can use Robust or Clustered
										lns1(string) lns2(string) arho(string)  	/// This are options for the Standard error and correlation
										init(string) CONSTraints(string)        	/// For estimation. Either use of Initial values and or Constraints
										TECHnique(string) DIFficult	             	/// Also Technique and option difficult
										ALLBASElevels BASElevels TRace					///
										] 
	version 13									
	** Start with sample selection
	marksample touse
*** first do parsing
 
	myparse_tobit `anything'
	if r(cnt)>2 {
		display in red "More than 2 equations defined"
		exit
	} 
	else if r(cnt)<2 {
		display in red "2 Equations needed"
		exit
	}
	local eq1 `r(m1)'
	local eq2 `r(m2)'

	parse_eq `eq1'
	local y1 `r(depvar)'
	local x1 `r(indepvar)'
	
	parse_eq `eq2'
	local y2 `r(depvar)'
	local x2 `r(indepvar)'
	* This probably would have been done later (ML has its own sample selection procedure)
	markout `touse' `y1' `y2' `x1' `x2' `cluster' `lns1' `lns2' `arho'
	*** Initial values:
	*** This helps to get the quickest results.
	*** Univariate Tobits are very robust to the Joint one. 
	if "`init'"=="" {
	    ** First estimate Marginal Tobits
		display "Estimating marginal models" 
		display "Fitting model 1"
		version 11:qui:tobit `y1' `x1' if `touse' [`weight'`exp'], ll(0) iter(50)
		tempname b1 b2
		matrix `b1'=e(b)
		tempvar rt1 rt2
		capture:predict `rt1', score
		if e(converged)==0 {
		    display in red "Warning: Univariate Tobit didn't converge after 50 iterations"
			display in red "You may find a problem estimating the Bivariate Tobit"
			}
		display "Fitting model 2"
		version 11:qui:tobit `y2' `x2' if `touse' [`weight'`exp'], ll(0) iter(50)
		matrix `b2'=e(b)
		capture:predict `rt2', score
		if e(converged)==0 {
		    display in red "Warning: Univariate Tobit didn't converge after 50 iterations"
			display in red "You may find a problem estimating the Bivariate Tobit"
			}
		*** Thes are the initial values 
		local ncola1=colsof(`b1')
		local ncolb1=colsof(`b2')
		local ncola2=`ncola1'-1
		local ncolb2=`ncolb1'-1
		tempname s12
		
		matrix `s12'=log(`b1'[1,`ncola1']),log(`b2'[1,`ncolb1'])
		matrix `b1'=`b1'[1,1..`ncola2']
		matrix `b2'=`b2'[1,1..`ncolb2']
		matrix coleq `b1'=`y1'
		matrix coleq `b2'=`y2'
		matrix coleq `s12'=lns1 lns2
		matrix colname `s12'=_cons
		if "`exp'"=="" qui:corr `rt1' `rt2' if `touse' 
		else if "`exp'"!="" qui:corr `rt1' `rt2' if `touse' [aw`exp']
		tempname crho
		matrix `crho'=atanh(`r(rho)')
		matrix coleq  `crho'=arho
		matrix colname `crho'=_cons
		tempname init
		matrix `init'=`b1',`b2',`s12',`crho'		
		** Do nothing if there are warnings. 
		** But at least we give a warning. Proceed at your own risk
	}
 
	*** then do the modeling
	display "Fitting full model: Bivariate Tobit model"
	ml model lf mbitobit_lf (`y1':`y1'=`x1') (`y2':`y2'=`x2') ///
							(lns1:=`lns1')  (lns2:=`lns2')  ///
							(arho:=`arho') if `touse' [`weight'`exp'] ///
							, maximize  constraints(`constrains') `robust' ///
							cluster(`cluster') init(`init') search(off) technique(`technique') `difficult' `trace'
	ml display, `allbaselevels' `baselevels'
 	tempname b V
	matrix `b'=e(b)
	matrix `V'=e(V)
	tempvar smp 
	**** Store variables if they were used for maximization
	ereturn local `y1'_var "`x1'"
	ereturn local `y2'_var "`x2'"
	foreach i in lns1 lns2 arho {
	    ereturn local `i'_var "``i''"
	}
	ereturn local  predict "mbitobit_p"
	ereturn local  cmd     "mbitobit"
	ereturn local  title   "Bi-variate Tobit regression"
end

 
  
 
