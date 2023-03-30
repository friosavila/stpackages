*! v1.21 Fixes "" colors
*! v1.2 Works with Stata 9.2 or higher
* v1.12 Showcase fix and adds recycle
* v1.1 Color_style FRA findfix
* v1 Color_style FRA 
** Simply puts colors from Palette to style

program color_style
	syntax [anything], [graph * opacity(passthru) LIST LIST1(str) showcase]
	
	if `c(stata_version)'>=14.2 {
	
		color_style14 `0'
		}
	if `c(stata_version)'<14.2  {
	
		color_style9 `0'
	}
end

program color_style14
	syntax [anything], [graph * opacity(passthru) LIST LIST1(str) showcase random]
	** First install extra palettes

	
	if "`list'`list1'"!="" {
		list_palettes, opt(`list1')
		exit
	}
	
	if "`random'"!="" {
		color_random
		display "Using Random Color: `r(rcolor)'"
		local anything `r(rcolor)'
	}
	
	if "`showcase'"!="" {
		color_showcase `anything'
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
	capture findfile color_brewer.ado
	capture do "`r(fn)'"
	
	colorpalette, span: `anything', n(1)  / `anything', n(2)  / `anything' , n(3) / `anything', n(4)  / `anything', n(5)  / ///
						`anything', n(6)  / `anything', n(7)  / `anything', n(8)  / `anything', n(9)  / `anything', n(10) / ///
						`anything', n(11) / `anything', n(12) / `anything', n(13) / `anything', n(14) / `anything', n(15)

end

program color_random, rclass
	local r=runiformint(1,226)
	foreach i in afternoon_prarie airbnb alaquod algoma_forest always amber_safety anemone apricot archambault arya aurora austria aventura badbunny1 badbunny2 badgyal baie_mouton bangor baratheon baratheon2 bay beckyg benedictus berry bottlerocket1 bottlerocket2 calle13 calmdown cascades cassatt1 cassatt2 cavalcanti1 ceriselimon chevalier1 coconut crait cranraspberry cross daddy1 daddy2 daenerys darjeeling1 darjeeling2 degas demuth derain don draco_malfoy durorthod egypt etsy eutrostox facebook fantasticfox1 frenchdispatch frost game_of_thrones gauguin gley google gr_amber gr_blue gr_bluegrey gr_brown gr_cyan gr_deeporange gr_deeppurple gr_green gr_grey gr_indigo gr_lightblue gr_lightgreen gr_lime gr_orange gr_pink gr_purple gr_red gr_teal gr_yellow grandbudapest1 grandbudapest2 greek greyjoy gryffindor gryffindor2 halifax_harbor harry_potter hermione_granger hiroshige hokusai1 hokusai2 hokusai3 homer1 homer2 ie1 ie2 ingres isfahan1 isfahan2 isleofdogs1 isleofdogs2 ivyqueen java johnson jon_snow juarez kandinsky karolg keylime kiwisandia klimt lake lake_superior lakota lannister lemon lime lumina luna_lovegood make_a_stand manet mango margaery martell melonpomelo mischief monet moonrise1 moonrise2 moonrise3 moose_pond moreau morgenstern moth mountain_forms mud murepepino mushroom natrudoll natti nattier navajo newkingdom newt_scamander nicky nizami okeeffe1 okeeffe2 orange ozuna paired paleustalf pamplemousse paquin passionfruit peace peachpear peru1 peru2 pillement pinafraise pissaro planb podzol polarnight pommebaya pure ravenclaw ravenclaw2 red_mountain redon redox redox2 rendoll renoir rhythm robert rocky_mountain ronweasley ronweasley2 rosalia royal1 royal2 rushmore sailboat shakira shuksan shuksan2 signac silver_mine slytherin snowstorm spring sprout starfish stark stark2 stevens sunset sunset2 tam tangerine tara targaryen targaryen2 thomas tiepolo troy tsimshian tully twitter tyrell vangogh1 vangogh2 vangogh3 veronese victory_bonds vintage vitrixerand white_walkers wildfire winter wissing wyy x23andme zissou1 {
		local j = `j'+1
		if `r'==`j' {
			return local rcolor `i'
		}
	}
end

program list_palettes 
	syntax, [opt(str)]
	if "`opt'"=="" {
		display as result "Right now, this are the options for palettes. " _newline
		foreach i in afternoon_prarie airbnb alaquod algoma_forest always amber_safety anemone apricot archambault arya aurora austria aventura badbunny1 badbunny2 badgyal baie_mouton bangor baratheon baratheon2 bay beckyg benedictus berry bottlerocket1 bottlerocket2 calle13 calmdown cascades cassatt1 cassatt2 cavalcanti1 ceriselimon chevalier1 coconut crait cranraspberry cross daddy1 daddy2 daenerys darjeeling1 darjeeling2 degas demuth derain don draco_malfoy durorthod egypt etsy eutrostox facebook fantasticfox1 frenchdispatch frost game_of_thrones gauguin gley google gr_amber gr_blue gr_bluegrey gr_brown gr_cyan gr_deeporange gr_deeppurple gr_green gr_grey gr_indigo gr_lightblue gr_lightgreen gr_lime gr_orange gr_pink gr_purple gr_red gr_teal gr_yellow grandbudapest1 grandbudapest2 greek greyjoy gryffindor gryffindor2 halifax_harbor harry_potter hermione_granger hiroshige hokusai1 hokusai2 hokusai3 homer1 homer2 ie1 ie2 ingres isfahan1 isfahan2 isleofdogs1 isleofdogs2 ivyqueen java johnson jon_snow juarez kandinsky karolg keylime kiwisandia klimt lake lake_superior lakota lannister lemon lime lumina luna_lovegood make_a_stand manet mango margaery martell melonpomelo mischief monet moonrise1 moonrise2 moonrise3 moose_pond moreau morgenstern moth mountain_forms mud murepepino mushroom natrudoll natti nattier navajo newkingdom newt_scamander nicky nizami okeeffe1 okeeffe2 orange ozuna paired paleustalf pamplemousse paquin passionfruit peace peachpear peru1 peru2 pillement pinafraise pissaro planb podzol polarnight pommebaya pure ravenclaw ravenclaw2 red_mountain redon redox redox2 rendoll renoir rhythm robert rocky_mountain ronweasley ronweasley2 rosalia royal1 royal2 rushmore sailboat shakira shuksan shuksan2 signac silver_mine slytherin snowstorm spring sprout starfish stark stark2 stevens sunset sunset2 tam tangerine tara targaryen targaryen2 thomas tiepolo troy tsimshian tully twitter tyrell vangogh1 vangogh2 vangogh3 veronese victory_bonds vintage vitrixerand white_walkers wildfire winter wissing wyy x23andme zissou1   {
			local cnt = `cnt'+1
			display _cont "`i'" " "
			if mod(`cnt',7)==0 display " "
		}
	}
	else {
		local letter_opt = substr("`opt'",1,1)
		display as result "list of pallets starting with `letter_opt'" _newline
		foreach i in afternoon_prarie airbnb alaquod algoma_forest always amber_safety anemone apricot archambault arya aurora austria aventura badbunny1 badbunny2 badgyal baie_mouton bangor baratheon baratheon2 bay beckyg benedictus berry bottlerocket1 bottlerocket2 calle13 calmdown cascades cassatt1 cassatt2 cavalcanti1 ceriselimon chevalier1 coconut crait cranraspberry cross daddy1 daddy2 daenerys darjeeling1 darjeeling2 degas demuth derain don draco_malfoy durorthod egypt etsy eutrostox facebook fantasticfox1 frenchdispatch frost game_of_thrones gauguin gley google gr_amber gr_blue gr_bluegrey gr_brown gr_cyan gr_deeporange gr_deeppurple gr_green gr_grey gr_indigo gr_lightblue gr_lightgreen gr_lime gr_orange gr_pink gr_purple gr_red gr_teal gr_yellow grandbudapest1 grandbudapest2 greek greyjoy gryffindor gryffindor2 halifax_harbor harry_potter hermione_granger hiroshige hokusai1 hokusai2 hokusai3 homer1 homer2 ie1 ie2 ingres isfahan1 isfahan2 isleofdogs1 isleofdogs2 ivyqueen java johnson jon_snow juarez kandinsky karolg keylime kiwisandia klimt lake lake_superior lakota lannister lemon lime lumina luna_lovegood make_a_stand manet mango margaery martell melonpomelo mischief monet moonrise1 moonrise2 moonrise3 moose_pond moreau morgenstern moth mountain_forms mud murepepino mushroom natrudoll natti nattier navajo newkingdom newt_scamander nicky nizami okeeffe1 okeeffe2 orange ozuna paired paleustalf pamplemousse paquin passionfruit peace peachpear peru1 peru2 pillement pinafraise pissaro planb podzol polarnight pommebaya pure ravenclaw ravenclaw2 red_mountain redon redox redox2 rendoll renoir rhythm robert rocky_mountain ronweasley ronweasley2 rosalia royal1 royal2 rushmore sailboat shakira shuksan shuksan2 signac silver_mine slytherin snowstorm spring sprout starfish stark stark2 stevens sunset sunset2 tam tangerine tara targaryen targaryen2 thomas tiepolo troy tsimshian tully twitter tyrell vangogh1 vangogh2 vangogh3 veronese victory_bonds vintage vitrixerand white_walkers wildfire winter wissing wyy x23andme zissou1 {
			if "`letter_opt'"==substr("`i'",1,1) {
				local cnt = `cnt'+1
				display _cont "`i'" " "
				if mod(`cnt',7)==0 display " "
			}
		}
	}
	capture findfile color_brewer.ado
	capture do "`r(fn)'"
	/*Paired*/
end

program colorpalette_parser, rclass
	syntax [anything(everything)], [graph * ]
	return local clp =  `"`anything', `options' nograph"'
end

program color_stylex
	syntax anything, [graph * opacity(passthru)  ]
	capture findfile color_brewer.ado
	capture do "`r(fn)'"
	if "`graph'"=="" {
		*if strpos( "`0'" , ",") == 0 local to0 `0', nograph 
		*else local to0 `0' nograph 
		grstyle init
		colorpalette_parser `0'
		colorpalette `r(clp)'
	}
	else {
		syntax anything, graph *
		*if strpos( "`0'" , ",") == 0 local to0 `0', 
		*else local to0 `0' // 		
		grstyle init
		colorpalette: `anything', `options'
		colorpalette `anything', `options' nograph
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
