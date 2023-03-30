program frause_update
		qui:findfile frause.ado
		local f_ado `r(fn)'
		qui:findfile frause.sthlp
		local f_hlp `r(fn)'
		copy https://friosavila.github.io/playingwithstata/data2/frause.ado  "`f_ado'", replace
		copy https://friosavila.github.io/playingwithstata/data2/frause.stlp "`f_hlp'", replace
		capture program drop frause
		exit
end