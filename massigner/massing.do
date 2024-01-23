mata org =r    = runiform(10000,1,0,1)
mata rsum = runningsum(r):/rs*100
mata
    ordx = J(10000,1,0)
    iord = range(1,10000,1)
    for(i=1;i<=10000-1;i++){
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
 
    ordx[10000,]=iord
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
