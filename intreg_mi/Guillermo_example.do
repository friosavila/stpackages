**
** Necesitas que el intreg_mi en tu carpeta "personal"
clear
** Considera este ejemplo

set obs 1000

** generamos data para X
gen x1 = runiform(0,3)
gen x2 = rbinomial(1,0.5)
gen p = runiform()
** algunos coefficientes
** generar el nivel de "ingreso"
gen y=1+x1+x2+rnormal()*(1+x1+x2)

** Esto genera los brackets (arriba y abajo)
gen yl=floor(y/2)*2
gen yu=ceil(y/2)*2
** Y esto genera los groups

egen tgr=group(yl)
** for consistency lets make the lowest and highest limits to missing
replace yl=.  if y<-2
replace yu=-2 if y<-2

replace yl=10  if y>10
replace yu=.   if y>10
tabstat yl yu , by(tgr)
** Para la data de Grenada tienes que verificar construir los low y high levels que correspondan a los brackets

** 
intreg yl yu x1 x2 , het(x1 x2)
intreg_mi yimp, reps(1)

** yimp es el dato imputado.

** Comparing

tabstat yl yu y yimp, by(tgr)

** La clave aca es usar un Mincer type regressions en vez de x1 x2.
** De manera similar, colocar las mismas variables en "het", asu se asumme heterogeneidad.
** El comando intreg_mi te genera la imputacion. Pero depende del 

two kdensity y || kdensity yimp  

** Ahora, la unica diferencia de este ejemplo a lo que haras en Grenada es que tienes que sacar LOGS a los limites superiores e inferiores

** Ejemplo 2. 
gen y2 = (exp(y))^(1/4)*10
gen yl2 = (exp(yl))^(1/4)*10
gen yu2 = (exp(yu))^(1/4)*10

*generar logs
gen log_yl=log(yl2)
gen log_yu=log(yu2)


intreg log_yl log_yu x1 x2 , het(x1 x2)
intreg_mi yimp2, reps(1)

replace yimp2=exp(yimp2)

tabstat yl2 yu2 y2 yimp2, by(tgr)

two kdensity yimp2 if yimp2 <200 || kdensity y2 if y2<200
** Nota en este caso que el modelo se lo hace en "Logs" pero las comparaciones (normalidad)
** se la hacen on exp(X). 

** N
