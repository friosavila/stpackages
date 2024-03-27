
 webuse akc, clear
 xtset breed year
 xthdidregress twfe (registered best) (movie), group(breed) hettype(time)

 ** Option 1
 reg registered i.year#1.movie i.year#i.best i.year i._did_cohort
 
 ** Option 2
 bysort _did_cohort:egen mn_best = mean(best)
 bysort _did_cohort:egen mn_best = mean(best)

 gen d_best = best - mn_best 
  reg registered i.year#1.movie i.year#1.movie#c.d_best i.year#i.best i.year i._did_cohort, cluster(breed)

 