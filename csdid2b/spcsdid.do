mata
    class spcsdid {
        real matrix index
        real matrix attgt
        real scalar gvar
        real scalar tvar
    }
    pmn = spcsdid(2)
    pmn[1].attgt = runiform(6,1,0,1)
    pmn[1].index = (1,4,5,6,10,12)'
    pmn[2].attgt = runiform(6,1,0,1)
    pmn[2].index = (2,3,7,10,11,12)'
end