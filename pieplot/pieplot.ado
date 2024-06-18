capture program drop pie_ii
program pie_ii
    syntax anything, [*]
    tempname nframe
    frame create `nframe'
    frame `nframe' {
         set obs 1
        foreach i in `anything' {
            local j = `j'+1
            gen v`j'=`i'
            local vlist `vlist' v`j'
        }
        graph pie `vlist', `options'
    }
end