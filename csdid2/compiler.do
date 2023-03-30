clear all
capture cd "C:\Users\Fernando\Dropbox (Personal)\projects\00 Stata Projects\ssc csdid2"
capture cd "C:\Users\Fernando\Dropbox\projects\00 Stata Projects\ssc csdid2"
capture cd "C:\Users\Fernando\Documents\GitHub\csdid2"
run drdid.mata
run csdid.mata
run csdid_stats.mata
mata:mata mlib create lcsdid , replace
mata:mata mlib add    lcsdid *() , complete 
