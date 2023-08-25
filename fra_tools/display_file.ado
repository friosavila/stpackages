*! v0.0 Display File: Show textfile 

program display_file
	syntax anything, [quarto]
	if "`quarto'"=="" 	mata: display_file(`"`anything'"')
	else 				mata: display_fileq(`"`anything'"')
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
		else linex
		j = j+1
    }
} 

void display_fileq(string scalar s){
	real scalar s1  , i, j, flag
	string scalar linex
	j = 0 ; flag = 0
	s1  = fopen(s, "r")
	for(i=1;i<2;){
  		linex = _fget(s1)
		if (length(linex)>0) {
			if (strlen(linex)>=3) {
				if (substr(linex,1,3)=="```") {
					if (flag==0) linex = fget(s1)
					flag=1-flag				
				}
			}
			if (flag==1) linex			
		}		
		else i=i+1
		j = j+1
    }
}

end