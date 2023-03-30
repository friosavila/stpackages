*! v1.21 Fixes "" colors
*! v1.2 Works with Stata 12
*! v1.12 Showcase fix and adds recycle
*! v1.1 Color_style FRA findfix
*! v1 Color_style FRA 
** Simply puts colors from Palette to style

program color_style9
	syntax [anything], [graph * opacity(passthru) LIST LIST1(str) showcase]
	** First install extra palettes
	if "`showcase'"!="" {
		color_showcase `anything'
	}
	
	if "`list'`list1'"!="" {
		list_palettes, opt(`list1')
		exit
	}
	
	** Verify Colorpallette is installed
	capture which colorpalette
	if _rc!=0 {
		display in red "You do not have palettes or colrspace installed"
		display in red "You may want to install them using"
		display `" {stata  `"net install palettes , replace from("https://raw.githubusercontent.com/benjann/palettes/master/")"' }"'
		display `" {stata  `"net install colrspace, replace from("https://raw.githubusercontent.com/benjann/colrspace/master/")"' }"'
		exit
	} 
	capture which grstyle
	if _rc!=0 {
		display in red "You do not have grstyle installed"
		display in red "You may want to install them using"
		display `" {stata  `"ssc install grstyle"' }"'
		exit 
	} 
	
	if runiform()<0.001 {
		easter_egg
	}
	color_stylex `anything', `graph' `options' `opacity' 
end

program color_showcase
	syntax anything
	capture findfile color_brewer9.ado
	capture do "`r(fn)'"
	
	colorpalette9, span: `anything', ipolate(1)  / `anything', ipolate(2)  / `anything' , ipolate(3) / `anything', ipolate(4)  / `anything', ipolate(5)  / ///
						`anything', ipolate(6)  / `anything', ipolate(7)  / `anything', ipolate(8)  / `anything', ipolate(9)  / `anything', ipolate(10) / ///
						`anything', ipolate(11) / `anything', ipolate(12) / `anything', ipolate(13) / `anything', ipolate(14) / `anything', ipolate(15)

end

program list_palettes 
	syntax, [opt(str)]
	if "`opt'"=="" {
		display as result "Right now, this are the options for palettes. " _newline
		foreach i in  anemone apricot archambault austria bay benedictus berry bottlerocket1 bottlerocket2 cascades cassatt1 cassatt2 cavalcanti1 ceriselimon chevalier1 coconut cranraspberry cross darjeeling1 darjeeling2 degas demuth derain egypt fantasticfox1 frenchdispatch gauguin grandbudapest1 grandbudapest2 greek hiroshige hokusai1 hokusai2 hokusai3 homer1 homer2 ingres isfahan1 isfahan2 isleofdogs1 isleofdogs2 java johnson juarez kandinsky keylime kiwisandia klimt lake lakota lemon lime manet mango melonpomelo monet moonrise1 moonrise2 moonrise3 moreau morgenstern moth murepepino mushroom nattier navajo newkingdom nizami okeeffe1 okeeffe2 orange paired pamplemousse paquin passionfruit peachpear peru1 peru2 pillement pinafraise pissaro pommebaya pure redon renoir robert royal1 royal2 rushmore sailboat shuksan shuksan2 signac spring starfish stevens sunset sunset2 tam tangerine tara thomas tiepolo troy tsimshian vangogh1 vangogh2 vangogh3 veronese winter wissing zissou1 airbnb facebook google etsy twitter x23andme aventura badbunny1 badbunny2 badgyal beckyg calle13 daddy1 daddy2 don ivyqueen karolg natti nicky ozuna planb rosalia shakira wyy targaryen targaryen2 stark stark2 lannister martell tully greyjoy baratheon baratheon2 tyrell white_walkers jon_snow margaery daenerys game_of_thrones wildfire arya draco_malfoy ravenclaw luna_lovegood ravenclaw2 gryffindor gryffindor2 hermione_granger ronweasley sprout harry_potter slytherin always mischief newt_scamander ronweasley2 alaquod bangor crait durorthod eutrostox gley natrudoll paleustalf podzol redox redox2 rendoll vitrixerand  {
			local cnt = `cnt'+1
			display _cont "`i'" " "
			if mod(`cnt',7)==0 display " "
		}
	}
	else {
		local letter_opt = substr("`opt'",1,1)
		display as result "list of pallets starting with `letter_opt'" _newline
		foreach i in  anemone apricot archambault austria bay benedictus berry bottlerocket1 bottlerocket2 cascades cassatt1 cassatt2 cavalcanti1 ceriselimon chevalier1 coconut cranraspberry cross darjeeling1 darjeeling2 degas demuth derain egypt fantasticfox1 frenchdispatch gauguin grandbudapest1 grandbudapest2 greek hiroshige hokusai1 hokusai2 hokusai3 homer1 homer2 ingres isfahan1 isfahan2 isleofdogs1 isleofdogs2 java johnson juarez kandinsky keylime kiwisandia klimt lake lakota lemon lime manet mango melonpomelo monet moonrise1 moonrise2 moonrise3 moreau morgenstern moth murepepino mushroom nattier navajo newkingdom nizami okeeffe1 okeeffe2 orange paired pamplemousse paquin passionfruit peachpear peru1 peru2 pillement pinafraise pissaro pommebaya pure redon renoir robert royal1 royal2 rushmore sailboat shuksan shuksan2 signac spring starfish stevens sunset sunset2 tam tangerine tara thomas tiepolo troy tsimshian vangogh1 vangogh2 vangogh3 veronese winter wissing zissou1 airbnb facebook google etsy twitter x23andme aventura badbunny1 badbunny2 badgyal beckyg calle13 daddy1 daddy2 don ivyqueen karolg natti nicky ozuna planb rosalia shakira wyy targaryen targaryen2 stark stark2 lannister martell tully greyjoy baratheon baratheon2 tyrell white_walkers jon_snow margaery daenerys game_of_thrones wildfire arya draco_malfoy ravenclaw luna_lovegood ravenclaw2 gryffindor gryffindor2 hermione_granger ronweasley sprout harry_potter slytherin always mischief newt_scamander ronweasley2 alaquod bangor crait durorthod eutrostox gley natrudoll paleustalf podzol redox redox2 rendoll vitrixerand  {
			if "`letter_opt'"==substr("`i'",1,1) {
				local cnt = `cnt'+1
				display _cont "`i'" " "
				if mod(`cnt',7)==0 display " "
			}
		}
	}
	capture findfile color_brewer9.ado
	capture do "`r(fn)'"
	/*Paired*/
end

program colorpalette_parser, rclass
	syntax [anything(everything)], [graph * ]
	return local clp =  `"`anything', `options' nograph"'
end

program color_stylex
	syntax anything, [graph * opacity(passthru)  ]
	capture findfile color_brewer9.ado
	capture do "`r(fn)'"
	if "`graph'"=="" {
	
		grstyle init
		colorpalette_parser `0'
		colorpalette9 `r(clp)'
		
	}
	else {
		syntax anything, graph *
		*if strpos( "`0'" , ",") == 0 local to0 `0', 
		*else local to0 `0' // 		
		grstyle init
		colorpalette9: `anything', `options'
		colorpalette9 `anything', `options' nograph
	}
	
	
	forvalues i =1/`=r(n)' {
		grstyle color p`i'      "`r(p`i')'"
		grstyle color p`i'mark  "`r(p`i')'"
		grstyle color p`i'markline  "`r(p`i')'"
		grstyle color p`i'markfill  "`r(p`i')'"
		*grstyle color p`i'label  "`r(p`i')'"
		grstyle color p`i'lineplot  "`r(p`i')'"
		grstyle color p`i'line  "`r(p`i')'"
		grstyle color p`i'area  "`r(p`i')'"
		grstyle color p`i'arealine  "`r(p`i')'" 
		grstyle color p`i'bar   "`r(p`i')'"
		grstyle color p`i'barline   "`r(p`i')'"
		grstyle color p`i'box   "`r(p`i')'"
		grstyle color p`i'boxline   "`r(p`i')'"
		grstyle color p`i'boxmarkline   "`r(p`i')'"
		grstyle color p`i'boxmarkfill   "`r(p`i')'"
		grstyle color p`i'dot   "`r(p`i')'"
		grstyle color p`i'dotmarkfill "`r(p`i')'"
		grstyle color p`i'dotmarkline "`r(p`i')'"
		grstyle color p`i'pie   "`r(p`i')'"
		grstyle color p`i'arrow "`r(p`i')'"
		grstyle color p`i'aline  "`r(p`i')'" 
		grstyle color p`i'solid "`r(p`i')'"
		grstyle color p`i'boxmark "`r(p`i')'"
		grstyle color p`i'dotmark "`r(p`i')'"
		grstyle color p`i'other "`r(p`i')'"
		
	}
	local j =0
	forvalues i =`=r(n)+1'/15 {
		local j =`j'+1
		if `j'>`r(n)' local j = 1
		grstyle color p`i'            "`r(p`j')'"
		grstyle color p`i'markline    "`r(p`j')'"
		grstyle color p`i'markfill    "`r(p`j')'"
		*grstyle color p`i'label  "`r(p`i')'"
		grstyle color p`i'line        "`r(p`j')'"
		grstyle color p`i'lineplot    "`r(p`j')'"
		grstyle color p`i'bar         "`r(p`j')'"
		grstyle color p`i'barline     "`r(p`j')'"
		grstyle color p`i'box         "`r(p`j')'"
		grstyle color p`i'boxline     "`r(p`j')'"
		grstyle color p`i'dot         "`r(p`j')'"
		grstyle color p`i'pie         "`r(p`j')'"
		grstyle color p`i'arrow       "`r(p`j')'"
		grstyle color p`i'area        "`r(p`j')'"
		grstyle color p`i'arealine    "`r(p`j')'"
		grstyle color p`i'aline       "`r(p`j')'"
		grstyle color p`i'solid       "`r(p`j')'"
		grstyle color p`i'mark        "`r(p`j')'"
		grstyle color p`i'boxmark     "`r(p`j')'"
		grstyle color p`i'dotmark      "`r(p`j')'"
		grstyle color p`i'dotmarkfill "`r(p`j')'"
		grstyle color p`i'dotmarkline "`r(p`j')'"
		grstyle color p`i'other       "`r(p`j')'"		
	}
		grstyle color histogram    "`r(p1)'"
        grstyle color histogram_line  "`r(p1)'"
 
		grstyle color matrix        "`r(p1)'"
        grstyle color matrixmarkline    "`r(p1)'"
		

end

program easter_egg
display in w "{p}This is a small easter egg! And you are lucky because only 0.1% of people may ever see this!{p_end}"
display in w "{p}And here the hidden Message, In August 2022, Im turning 40, but most important, im turing a DAD! {p_end}"
display in w "{p}All right, that is it! {p_end}"
end 
