mata org =rs    = runiform(10,1,0,1);rt=sum(rs)
mata rsum = runningsum(rs):*100/rt
mata
    ord=smp = J(1000,1,0)
    // Sum from 1 to 100
    for(i=1;i<=1000;i++){
        ord[i,] = sum(rsum:<runiform(1,1,0,100))+1
    }
end




mata:pr=st_data(.,"pr*")


mata org =r    = pr[,1]
mata rsum = runningsum(r):/rs*100
mata
    n100 = rows(org)
    ordx = J(n100,1,0)
    iord = range(1,n100,1)
    for(i=1;i<=n100-1;i++){
        rnd = runiform(1,1,0,100)
        rsum = runningsum(r)
        rsum = rsum:/rsum[rows(r),]*100
        phld = sum(rsum:<rnd)+1
        ordx[i,]=iord[phld,]
        
             if (phld ==1)          {
                 r = r[2..rows(r),]
                 iord = iord[2..rows(iord),]
             }
        else if (phld == rows(r))   {
            r = r[1..phld-1,]
            iord = iord[1..phld-1,]
        }
        else                        {
            r=r[1..phld-1,]\r[phld+1..rows(r),]
            iord=iord[1..phld-1,]\iord[phld+1..rows(iord),]
        }    
    }
 
    ordx[n100,]=iord
end
