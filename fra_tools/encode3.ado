*! Encode3. replace
program encode3
    syntax anything, [* replace]
    if "`replace'"=="" {
        encode `0'
    }
    else {
        capture drop __aux__
        encode `anything', gen(__aux__)
        drop `anything'
        label copy __aux__ `anything'_lbl
        ren __aux__ `anything'
        label values  `anything' `anything'_lbl
        des
    }
end