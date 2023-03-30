*Author: Anastasia Semykina
****************************************************************************
* THIS PROGRAM SHOULD BE APPLIED ON A BALANCED PANEL, WHERE THE SELECTION
* INDICATOR IS ALWAYS OBSERVED, BUT THE DEPENDENT VARIABLE IN THE PRIMARY
* EQUATION MAY HAVE MISSING VALUES
*
****************************************************************************
* THE PROGRAM BELOW ASSUMES THAT THERE ARE NEITHER VARIABLES WHOSE NAMES
* START WITH T, t, m, g, q, lam
* NOR VARIABLES NAMED cons, ehat, sample, num, obs, countid IN THE DATA SET
*
* IF THIS DOES NOT HOLD, THEN EITHER THE CORRESPONDING VARIABLES
* SHOULD BE RENAMED OR THE PROGRAM SHOULD BE CHANGED ACCORDINGLY
****************************************************************************
* IN local COMMANDS BELOW, <description> NEEDS TO BE REPLACED WITH THE
* CORRESPONDING VARIABLE NAMES
*
* TIME MEANS OF THE INSTRUMENTS AND TIME DUMMIES SHOULD BE OMITTED (!!!)
* FROM THE VARIABLE LISTS; THESE VARIABLES WILL BE CREATED BY THE PROGRAM
****************************************************************************
* V2 IS THE NAME FOR THE VARIANCE-COVARIANCE MATRIX CORRECTED FOR
* THE FIRST-STEP ESTIMATION
****************************************************************************
* THE PROGRAM PERFORMS SEVERAL CHECKS (COMPUTING BETA AND ROBUST VAR-COV
* MATRIX AND COMPARING THOSE WITH THE ESTMATES OBTAINED USING BUILT-IN
* STATA COMMANDS); THESE CAN BE USED TO VERIFY THAT PROGRAM WORKS CORRECTLY
*
* IF CORRECTED STANDARD ERRORS ARE UNREASONABLY LARGE, IT MAY BE USEFUL
* TO RUN THE FIRST-STEP PROBIT REGRESSIONS SEPARATELY AND MAKE SURE THAT
* THOSE ARE ALL RIGHT (FOR EXAMPLE, THAT NO VARIABLES ARE DROPPED FROM
* PROBIT REGRESSIONS BECAUSE OF PERFECT COLLINEARITY)
****************************************************************************
use http://www.stata-press.com/data/r16/wagework.dta, clear
#delimit ;

 
set mem 80m;
set matsize 600;



local id personid;
local year year;

local y1 wage;
local y2 working;

local x1 age tenure ;

local z1 age tenure;
ren market barket;
local z2 age tenure barket;

*NOTE: IN GENERAL, z1 MAY CONTAIN FEWER VARIABLES THAN z2,
BUT IT MUST BE THE CASE THAT z2 CONTAINS ALL VARIABLES FROM z1;




*IF THE CONDITIONS ABOVE ARE MET, NOTHING NEEDS TO BE CHANGED BELOW THIS LINE

*****************************************************************************;
*preserve;

egen obs=sum(`y2'), by(`id');

qui sum `year';
replace `year'=`year'-r(min)+1;
scalar tmax=r(max)-r(min)+1;


*GENERATE TIME DUMMIES;

  local i=2;
     while `i'<=tmax {;
     qui gen T`i'=(`year'==`i');
  local i=`i'+1;
  };


*GENERATE TIME MEANS FOR REGRESSORS IN THE SELECTION EQUATION;

  local j = 0;
     foreach var of varlist `z2' {;
     qui egen m`var' = mean(`var'), by(`id');
  local j = `j'+1;
  };

scalar L2=`j';

  local j = 0;
     foreach var of varlist `z1' {;
  local j = `j'+1;
  };

scalar L1=`j';

  local j = 0;
     foreach var of varlist `x1' {;
  local j = `j'+1;
  };

scalar K=`j';


*GENERATE INVERSE MILLS RATIO FOR EACH T;

gen lambda=.;

  local i=1;
     while `i'<=tmax {;
     di "Year="`i';
     qui probit `y2' `z2' m* if `year'==`i';
     predict xb, xb;
     qui replace lambda=normalden(xb)/normal(xb) if `y2'==1&`year'==`i';
     drop xb;
  local i=`i'+1;
  };


*GENERATE INTERACTION TERMS FOR LAMBDA;

  local i=2;
     while `i'<=tmax {;
     qui gen lam`i'=T`i'*lambda;
  local i=`i'+1;
  };


***********PROCEDURE 5.1 (CORRECTION)***************;

reg `y1' `x1' lam* T* m* (`z1' lam* T* m*) if `y2'==1, robust cluster(`id');

qui gen sample=e(sample);


*OBTAIN COEFFICIENTS FOR LAMBDA TERMS FROM THE REGRESSION;

scalar gamma1=_b[lambda];
di gamma1;

  local i=2;
     while `i'<=tmax {;
     scalar gamma`i'=_b[lam`i']+gamma1;
     di gamma`i';
  local i=`i'+1;
  };


********************************************************************
*
* GENERATE NEW VARS AND A DIAGONAL MATRIX WITH HESSIANS
*
*  VARS1= GAMMA_t*d(LAMBDA)/d(xb)*VAR BY t, denote them "g"
*
*  VARS2= d(LnL)/d(xb)*VAR BY t - SCORES FOR EACH i, denote them "q"
*
*  DIAG(H)=diag(H_t), t=1,...,T
*
********************************************************************;

gen cons=1;

*****************************************************************;
* varli1 BELOW DEFINES THE LIST OF THE VARIABLES USED AS
* REGRESSORS AT THE 1st STAGE (PROBIT)
* varli3 AND varli4 ARE EMPTY FOR NOW AND WILL BE USED LATER
*****************************************************************;

local varli1 `z2' m* cons;

local varli3;
local varli4;

*****************************************************************;
* MATRIX H BELOW SHOULD BE A SQUARE MATRIX OF DIMENSION
* # REGRESSORS AT THE 1st STAGE (PROBIT) * # TIME PERIODS
*****************************************************************;

mat H=I((1+2*L2)*tmax);

  local i=1;
     while `i'<=tmax {;
     di "Year="`i';
     qui probit `y2' `z2' m* if `year'==`i';
     predict xb, xb;
     mat H`i'=e(V);
     qui gen tempvar1=normalden(xb)/normal(xb)          if `y2'==1 & `year'==`i';
     qui replace tempvar1=-normalden(xb)/(1-normal(xb)) if `y2'==0 & `year'==`i';
     assert lambda==tempvar1 if `y2'==1&`year'==`i';
     local j=`i'-1;
     mat H[(1+2*L2)*`j'+1,(1+2*L2)*`j'+1]=H`i';
	set trace on ;
          foreach var of varlist `varli1' {;
			  qui gen g`var'`j' = 0 if `y2'==1;
			  qui replace  g`var'`j'= -lambda*(lambda+xb)*gamma`i'*`var' if `y2'==1&`year'==`i';

			  qui gen q`var'`j' = .;
			  qui replace  q`var'`j'= tempvar1*`var' if `year'==`i';
			  qui gen xq`var'`j'= tempvar1*`var' if `year'==`i';
			  sort `id' `year';
			  qui by `id': replace q`var'`j'=q`var'`j'[`j'+1] if `year'~=`i';
			  local varli3 `varli3' g`var'`j';
			  local varli4 `varli4' q`var'`j';
          };
		  sum q*;
		  list qtenure* tenure if personid==27 &	year==2;

	set trace off ;
     drop xb tempvar*;
     mat drop H`i';
	local i=`i'+1;
  };
 
display in w "var1:`varli1'";
display in w "z1:`z2'";
display in w "var3:`varli3'";
display in w "var4:`varli4'";

          foreach var of varlist `y1' `x1' lam* T* m* `z1' `z2' cons {;
          qui replace  `var'=`var'*sample;
          };


*WE ESTIMATE THE EQUATION: reg y1 x1 lam* T* m* (z1 lam* T* m*);
*REPLICATE THIS RESULT USING MATRICES;

*****************************************************************;
* TO CREATE TEMP, FIRST LIST ALL THE SECOND-STAGE REGRESSORS,
* THEN LIST ALL THE FIRST-STAGE REGRESSORS
*****************************************************************;

mat accum TEMP=`x1' lam* T* m* cons `z1' lam* T* m* cons, nocons;

*****************************************************************;
* W IS A MATRIX OF THE SECOND-STAGE REGRESSORS
* Z IS A MATRIX OF THE SECOND-STAGE INSTRUMENTS
*****************************************************************;

*NOTE: # vars in W = K+T+(T-1)+L2+1 = K+2T+L2;

*****************************************************************;
* WZ IS THE UPPER RIGHT (OR LOWER LEFT) CORNER OF THE TEMP MATRIX
* IT IS CHOSEn AS
* ROWS: 1 .. <# REGRESSORS AT THE SECOND STAGE>
* COLUMNS: <# REGRESSORS AT THE SECOND STAGE> + 1 ...
*
* HERE AND EVERYWHERE BELOW # REGRESSORS INCLUDES THE CONSTANT
*****************************************************************;

mat WZ=TEMP[1..K+2*tmax+L2,K+2*tmax+L2+1...];
mat drop TEMP;

di "Number of rows in WZ="rowsof(WZ);
di "Number of columns in WZ="colsof(WZ);

mat accum ZZ=`z1' lam* T* m* cons, nocons;
mat vecaccum yZ=`y1' `z1' lam* T* m* cons, nocons;
mat BETA=invsym(WZ*invsym(ZZ)*WZ')*WZ*invsym(ZZ)*yZ';

********************************************************************;
* MATRIx BETA SHOULD BE IDENTICAL TO THE VECTOR OF THE COEFFICIENTS
* OBTAINED USING THE BUILT-IN STATA COMMAND, THIS IS JUST A CHECK
********************************************************************;

reg `y1' `x1' lam* T* m* (`z1' lam* T* m*) if sample==1;
predict ehat, res;

replace ehat=ehat*sample;

mat list BETA;


*REPLICATE ROBUST VARIANCE MATRIX USING MATRICES;

*****************************************************************;
* DEFINE NEW varli1, WHICH IS THE LIST OF THE VARIABLES USED AS
* INSTRUMENTS AT THE 2nd STAGE
*
* varli2 WILL BE THE LIST OF INTERACTION TERMS
* (Z*<residuals from the second-stage regression>)
*****************************************************************;

local varli1 `z1' lam* T* m* cons;
local varli2;

  local j = 1;
     foreach var of varlist `varli1' {;
     qui gen eh`var'=`var'*ehat;
     qui egen t`var' = sum(eh`var'), by(`id');
     local varli2 `varli2' t`var';
  local j = `j'+1;
  };
display in w "var1:`varli1'";
display in w "var2:`varli2'";

********************************************************************;
* SCALAR g BELOW IS THE NUMBER OF INDIVIDUALS IN THE SELECTED SAMPLE
********************************************************************;

sort `id' `year';
by `id': gen num=_n;

gen countid=(num==1) if obs>=1;
*gen countid=(num==1) if obs>1;
sum countid;
scalar g=r(sum);
drop countid;

mat accum ZEEZ=`varli2' if num==1, nocons;
mat V1=invsym(WZ*invsym(ZZ)*WZ')*WZ*invsym(ZZ)*ZEEZ*invsym(ZZ)*WZ'*invsym(WZ*invsym(ZZ)*WZ')
*(e(N)-2)*g/((g-1)*(e(N)-K-2*tmax-L2)+2);

*****************************************************;
*NOTE: THE SCALE FACTOR IS TAKEN FORM STATA'S WEBSITE;
*http://www.stata.com/support/faqs/stat/robust.html;
*****************************************************;

qui reg `y1' `x1' lam* T* m* (`z1' lam* T* m*) if sample==1, robust cluster(`id');

mat V=e(V);
mat VCE=V[1..5,1..5];
mat VCE1=V1[1..5,1..5];


********************************************************************;
* MATRICES VCE AND VCE1 SHOULD BE IDENTICAL, THIS IS JUST A CHECK
********************************************************************;

matrix list VCE;
matrix list VCE1;

sd
*OBTAIN STD ERRORS CORRECTED FOR THE FIRST-STEP ESTIMATION;

mat A=WZ*invsym(ZZ)*WZ';
mat TERM1=ZEEZ;

***********************************************************************;
* NUMBER OF VARIABLES IN varli2 (WHICH IS THE LIST OF INTERACTION TERMS
* Z*<residuals from the second-stage regression>) SHOULD BE EQUAL TO
* THE NUMBER OF INSTRUMENTS AT THE SECOND STAGE
*
* NUMBER OF VARIABLES IN varli4 SHOULD BE EQUAL TO
* <# FIRST-STAGE REGRESSORS> * <# TIME PERIODS>
***********************************************************************;

mat accum TEMP=`varli2' `varli4' if num==1, nocons;
*NOTE: #instruments*ehat (#vars in `varli2')=L1+T+(T-1)+L2+1=L1+L2+2T;
*Number of vars in Q (#vars in `varli4')=(1+2L2)T;

***********************************************************************;
* EXTRACT THE UPPER RIGHT CORNER OF THE TEMP MATRIX
***********************************************************************;

mat ZEQ=TEMP[1..L1+L2+2*tmax,L1+L2+2*tmax+1...];
di "Number of rows in ZEQ="rowsof(ZEQ);
di "Number of columns in ZEQ="colsof(ZEQ);

mat drop TEMP;

***********************************************************************;
* NUMBER OF VARIABLES IN varli1 SHOULD BE EQUAL TO
* THE NUMBER OF INSTRUMENTS AT THE SECOND STAGE
*
* NUMBER OF VARIABLES IN varli3 SHOULD BE EQUAL TO
* <# FIRST-STAGE REGRESSORS> * <# TIME PERIODS>
***********************************************************************;

mat accum TEMP=`varli1' `varli3', nocons;
*NOTE: #instruments (#vars in `varli1')=L1+T+(T-1)+L2+1=L1+L2+2T;
*Number of vars in G (#vars in `varli3')=(1+2L2)T;

***********************************************************************;
* EXTRACT THE UPPER RIGHT CORNER OF THE TEMP MATRIX
***********************************************************************;

mat ZG=TEMP[1..L1+L2+2*tmax,L1+L2+2*tmax+1...];
di "Number of rows in ZG="rowsof(ZG);
di "Number of columns in ZG="colsof(ZG);

mat drop TEMP;

*********************************************************************;
* IF EVERYTHING ABOVE WAS DONE CORRECTLY, THE REMAINING COMPUTATIONS
* BELOW SHOULD FOLLOW AUTOMATICALLY
*********************************************************************;
mat accum QQ=`varli4' if num==1&obs>=1, nocons;
mat TERM2=ZEQ*H*ZG';
mat TERM4=ZG*H*QQ*H*ZG';

*mat accum QQ=`varli4' if num==1&obs>1, nocons;



mat B=WZ*invsym(ZZ)*(TERM1-TERM2-TERM2'+TERM4)*invsym(ZZ)*WZ';

mat V2=invsym(A)*B*invsym(A)*(e(N)-1)*g/((g-1)*(e(N)-K-L2-2*tmax));
mat VCE2=V2[1..5,1..5];

*PART OF THE ROBUST V-C MATRIX FROM STATA;
matrix list VCE;

*PART OF THE ROBUST V-C MATRIX COMPUTED BY THE PROGRAM;
matrix list VCE1;

*PART OF THE ROBUST V-C MATRIX THAT ALSO TAKES INTO ACCOUNT THE FIRST-STEP ESTIMATION;
matrix list VCE2;

matrix b=BETA';

ereturn post b V2;
ereturn display;


