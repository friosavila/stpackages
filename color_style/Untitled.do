#delimit;
foreach i in afternoon_prarie 
airbnb 
alaquod 
algoma_forest 
always 
amber_safety 
anemone 
apricot 
archambault 
arya 
aurora 
austria 
aventura 
badbunny1 
badbunny2 
badgyal 
baie_mouton 
bangor 
baratheon 
baratheon2 
bay 
beckyg 
benedictus 
berry 
bottlerocket1 
bottlerocket2 
calle13 
calmdown
cascades 
cassatt1 
cassatt2 
cavalcanti1 
ceriselimon 
chevalier1 
coconut 
crait 
cranraspberry 
cross 
daddy1 
daddy2 
daenerys 
darjeeling1 
darjeeling2 
degas 
demuth 
derain 
don 
draco_malfoy 
durorthod 
egypt 
etsy 
eutrostox 
facebook 
fantasticfox1 
frenchdispatch 
frost 
game_of_thrones 
gauguin 
gley 
google 
gr_amber
gr_blue
gr_bluegrey
gr_brown
gr_cyan
gr_deeporange
gr_deeppurple
gr_green
gr_grey
gr_indigo
gr_lightblue
gr_lightgreen
gr_lime
gr_orange
gr_pink
gr_purple
gr_red
gr_teal
gr_yellow
grandbudapest1 
grandbudapest2 
greek 
greyjoy 
gryffindor 
gryffindor2 
halifax_harbor 
harry_potter 
hermione_granger 
hiroshige 
hokusai1 
hokusai2 
hokusai3 
homer1 
homer2 
ie1 
ie2 
ingres 
isfahan1 
isfahan2 
isleofdogs1 
isleofdogs2 
ivyqueen 
java 
johnson 
jon_snow 
juarez 
kandinsky 
karolg 
keylime 
kiwisandia 
klimt 
lake 
lake_superior 
lakota 
lannister 
lemon 
lime 
lumina 
luna_lovegood 
make_a_stand 
manet 
mango 
margaery 
martell 
melonpomelo 
mischief 
monet 
moonrise1 
moonrise2 
moonrise3 
moose_pond 
moreau 
morgenstern 
moth 
mountain_forms 
mud     
murepepino 
mushroom 
natrudoll 
natti 
nattier 
navajo 
newkingdom 
newt_scamander 
nicky 
nizami 
okeeffe1 
okeeffe2 
orange 
ozuna 
paired 
paleustalf 
pamplemousse 
paquin 
passionfruit 
peace   
peachpear 
peru1 
peru2 
pillement 
pinafraise 
pissaro 
planb 
podzol 
polarnight 
pommebaya 
pure 
ravenclaw 
ravenclaw2 
red_mountain 
redon 
redox 
redox2 
rendoll 
renoir 
rhythm  
robert 
rocky_mountain 
ronweasley 
ronweasley2 
rosalia 
royal1 
royal2 
rushmore 
sailboat 
shakira 
shuksan 
shuksan2 
signac 
silver_mine 
slytherin 
snowstorm 
spring 
sprout 
starfish 
stark 
stark2 
stevens 
sunset 
sunset2 
tam 
tangerine 
tara 
targaryen 
targaryen2 
thomas 
tiepolo 
troy 
tsimshian 
tully 
twitter 
tyrell 
vangogh1 
vangogh2 
vangogh3 
veronese 
victory_bonds 
vintage 
vitrixerand 
white_walkers 
wildfire 
winter 
wissing 
wyy 
x23andme 
zissou1 {;
	local lc=`lc'+1;
	if `lc'>10 local lc=1;
	
	if `lc'==1 local cilist `i' ;
	else local cilist `cilist' / `i' ;
****;
	display `"`cilist'"';
	if `lc'==10  {;
		colorpalette, span: `cilist' ;
	};
	
};
