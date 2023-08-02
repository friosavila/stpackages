*! v0.0 Display File: Show textfile 

program display_file
	syntax anything,
	mata: display_file("`anything'")
end

mata: 
void display_file(string scalar s){
	real scalar s1  , i, j
	string scalar linex
	j = 0
	s1  = fopen(s, "r")
	for(i=1;i<2;){
 		linex = fget(s1) 
		if (length(linex)==0) {
			i=i+1
		}
		else {
			if (j>0) linex="\n"+linex
			printf(linex)
		}
		j = j+1
    }
}	
end	 

