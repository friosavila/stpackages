** Takes a file and adds something for markdown

program addmd
	syntax anything, [md(string asis)] 
	tempfile temp
	copy `anything' `temp'
	rm `anything'
	if `"`md'"'=="" {
		local head   "```"
		local bottom "```"
	}
	else {
		local head   "````md'"
		local bottom "```"
	}
	mata:addmd(`"`temp'"',`"`anything'"',"`head'")	
end

*mata: display_fileq(`"`anything'"', `"`save'"', `htmlc')
mata: 
void addmd(string scalar openf, string scalar temp, string scalar head){

	real scalar s1  , i, j, flag, fh_out
	string scalar linex
	// Creates file
	fh_out = fopen(temp, "w")
	// Adds Head
	fput(fh_out, head)
	//Opens original file
	j = 0 ; flag = 0
 	s1  = fopen(openf, "r")
	
	for(i=1;i<2;){
  		linex = _fget(s1)
		if (length(linex)>0) {
			fput(fh_out, linex)				
		}		
		else i=i+1
    }
	fput(fh_out, "```")
	fclose(fh_out)
	fclose(s1)
}
end	 
