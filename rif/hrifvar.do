 
mata
mata drop rif_hvar()
real matrix rif_hvar(string scalar ywb, touse,newvar){
    ywby=st_data(.,ywb,touse)
	ord1=order(ywby,(3,2))
	ywby=ywby[ord1,]
	info=panelsetup(ywby, 3)
	// estimates RIF
    rif=J(rows(ywby),1,0)
	for(i=1;i<=rows(info);i++){
	    aux = panelsubmatrix(ywby, i, info)
		awgt= aux[,2]/mean(aux[,2])
		aux=aux[,1],awgt
		nn=sum(awgt)
		rifaux=J(rows(aux),1,0)
		rifi=hvarp(&aux)
		for(j=1;j<=nn;j++){
			if (j==1) aux2=aux[(2::nn),]
			else if (j==nn) aux2=aux[(1::(nn-1)),]
			else aux2=aux[(1::(j-1)),]\aux[((j+1)::nn),]
			rifaux[j]=hvarp(&aux2)
		}
		
		rif[|(info)[i,1],1 \ (info)[i,2],1|]=
		rifi:+(rifi:-rifaux):/(awgt/nn)
	}	
	st_store(.,newvar,touse,rif[invorder(ord1),])
}
end
mata 
mata drop hvarp()
real matrix hvarp(pointer aux){
	mu=mean((*aux)[,1],(*aux)[,2])
	hvarp=mean(
			(
			((*aux)[,1]:-mu):*( (*aux)[,1]:>=mu)
			):^2
			,(*aux)[,2]
			)
	return(hvarp)		
}
end