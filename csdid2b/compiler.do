cd "C:\Users\Fernando\Documents\GitHub\stpackages\csdid2"
clear all
 
run drdid.mata
run csdid.mata
run csdid_stats.mata
mata:mata mlib create lcsdid , replace
mata:mata mlib add    lcsdid *() , complete 

