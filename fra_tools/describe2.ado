*! Describe, but with types
program describe2,
    syntax [varlist], [type(str asis)] [*]
    if "`varlist'"=="" local varlist *
    local final_vlist
    foreach var of varlist `varlist' {
        capture confirm `type' var `var'
        if _rc == 0 {
            local final_vlist `final_vlist' `var'
        }
    }
    
    describe `final_vlist', `options'
    addr local vlist `final_vlist'
end