capture program drop pie_i
capture program drop re_scale

program re_scale, rclass
    syntax anything, [total]
    numlist "`anything'" , min(0) range(>=0)
    tempname tval
    scalar `tval'=0
    foreach j of numlist `anything' {
        scalar `tval'=`tval'+`j'
    }
    
    if `tval'>100 {
        foreach j of numlist `anything' {
            local newlist `newlist' `=`j'/`tval'*100'
        }    
    }
    else if "`total'"!="" {
            foreach j of numlist `anything' {
                local newlist `newlist' `=`j'/`tval'*100'
            }
         }
    else {
        local newlist `anything' `=100-`tval''
    }
    return local newlist   `newlist'
end

program pie_i
    syntax anything, [total RESolution(int 100) plotopt(string asis) ]
    qui:re_scale `anything', `total'
    local newlist `r(newlist)'
    tempname toplot
    frame create `toplot'    
    frame `toplot': {
        set obs `resolution'
        range re 2*_pi 0
        local hi0 = 0
        set obs `=`resolution'+1'
        foreach i of numlist `newlist' {
            local j = `j'+1  
            local jm1 = `j'-1
            ** Local Cum
            local lw`j'=`hi`jm1''
            local hi`j'=`lw`j''+`i'/100             
            qui:gen  x`j' = cos(re*`i'/100+`lw`j''*2*_pi) 
            qui:gen  y`j' = sin(re*`i'/100+`lw`j''*2*_pi)
            qui:replace x`j'=0 in `=`resolution'+1'
            qui:replace y`j'=0 in `=`resolution'+1'
        }
        local tt `j'
        local j =0
        
        forvalues i = 1/`tt' {
            local pieplot `pieplot' (area x`i' y`i', nodropbase  lw(vthin))
        }
        
        two `pieplot', `plotopt' aspect(1) yscale(off) xscale(off)
    }
end