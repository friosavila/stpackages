*! 1.0 drop2: module to drop if any of the variables in the list is present.
* It only drops variables that match exactly what is typed to avoid incorrect drops 
* due to abreviation
*** drop2
*capture program drop drop2
program drop2
    novarabbrev {
        syntax anything 
        foreach i in `anything' {
            capture noisily fvexpand `i'            
            if _rc == 0 {
                drop `r(varlist)' 
            }
        }
    }
end