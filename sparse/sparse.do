mata
  mata clear
 x = runiform(10,600,0,1):<.01
 class svect {
     real matrix index
     real matrix spx
 }
 class spmatrix {
     class svect matrix sparse
     real matrix rindex
     real matrix cindex
     void load()
 }
 void spmatrix::load(real matrix x){
     sparse = svect(cols(x))
     rindex    = 1::rows(x)
     cindex    = 1..cols(x)
     sel       = J(1,cols(x),0)
     real scalar i
     real matrix aux
     for(i=1;i<=cols(x);i++){
         aux  = (x[,i]:!=0)       
         if (sum(aux)>0){
             sel[i]=1             
             sparse[i].spx=select(x[,i],aux)     
             
             sparse[i].index=select(rindex,aux)             
         }         
     
     }
     
     cindex = select(cindex,sel)
     
 }
 spm=spmatrix()
 spm.load(x)
 x=NULL
end