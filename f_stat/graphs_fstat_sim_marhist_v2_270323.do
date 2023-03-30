********************************************************************************
	* Testing
	* Loading sysuse auto for testing
	sysuse auto, clear

	* Testing: 

	* Testing by using custom scheme
	sim_marhist price mpg, scheme(white_tableau) fit(lowess)
		* -> The scheme is not being applied on the plot
		* -> Possible solution: need to add `options' to each scatter and histogram command?
		* -> Solution works but may possibly not work effectively
		*~-> We can add it as explicit option in the program definition. 
	
	* Testing by adding titles to plot
	sim_marhist price mpg, title("{bf}Testing out the command", pos(11) size(3)) scheme(white_tableau)
		* -> If we add `options' to each plot that duplicates titles 3 times
		* -> Works fine if we remove `options' from each scatter and histogram 
		*~-> Good call. "Options" should be only for the Combined graph
	
	* Testing to change scatterplot colors
	sim_marhist price mpg, scheme(white_tableau) scatter(mcolor(red)) ///
		hhistogram(color(yellow)) ///
		vhistogram(color(green))
		* -> Histogram color is applied to both plots. Maybe we can try and give option for different colors
		*~-> So that hcolor (for horizontal) and vcolor(for vertical?) perhaps options vhistogram and hhistogram. when applied to each color
		* -> Maybe also consider using different colors by groups on scatter as well by group?
		*~-> This isnt as straigh forward. We could first write an alternative histogram command. 
		*    -mhistogram- that plots Multiple histograms by group. Then use that instead of histogram.
		*    then, it can be combined with mscatter
		
	* Testing alignment of side plots
	  
		* -> I could be wrong here but maybe we need to slightly tweak the starting
		*	 point of the side plot to begin where from where scatter starts
		*~-> Agreed. This is tricky. Right now, margins for the subplots (histograms) are defined excplicity
		*    and trying to set a code to modify them within the program is not straight forward. (what values to use may depends on case to case.)
		*    try for example: webuse dui
		*    sim_marhist citations fines. 
		*    Figure is slighly off.
		
		* -> Maybe we can also reduce distance of side plot on Y-axis from the graph region
		* 	 to make it consistent with one appearing on the x-axis?
		*~-> This goes with the previous point. Choosing the right values may be tricky. Perhaps "Keep" what u use as default
		*    but allow for it to change.
