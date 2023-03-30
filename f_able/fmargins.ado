*! V1.1 tryint to add an auto mode for f_able
*  V1 This is my clone of margins to be used with f_able only. 
*     The Purpose is to keep infor for epilog and prolog. And in case earlier versions are not "fixed" retroactivly.
program add_e, eclass
	ereturn `0'
end
program fmargins
        version 11
		**********
		if "`e(cmd_old)'"!="" {
			local xcmd  `e(cmd)'
			local xcmdline `e(cmdline)'
			add_e local cmd     `e(cmd_old)'
			add_e local cmdline `e(cmdline_old)'
		}	
		**********
        if replay() {
                if inlist("margins", "`e(cmd)'", "`e(cmd2)'") {
                        _marg_report `0'
                        exit
                }
        }
        local vv : display "version " string(_caller()) ":"

        tempname m t
        `vv' .`m' = ._marg_work.new `t'

nobreak {
		local margins_epilog `e(margins_epilog)'
		local nldepvar `e(nldepvar)'
        if `"`e(margins_prolog)'"' != "" {
                `e(margins_prolog)'
        }

capture noisily break {

        `vv' .`m'.parse `0'
        .`m'.estimate_and_report

} // capture noisily break
        local rc = c(rc)

        if `"`margins_epilog'"' != "" {
            `margins_epilog' `nldepvar'
			if "`xcmd'"!="" {	
				add_e local cmd     `xcmd'
				add_e local cmdline `xcmdline'
			}	
        }


} // nobreak
        exit `rc'
end
