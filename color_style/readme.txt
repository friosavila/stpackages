TITLE
      'COLOR_STYLE': Module to change the colors in the current scheme. (p1-p15)

DESCRIPTION/AUTHOR(S)
      
	'color_style' is a command that can be used to easily change the colors
 of the current scheme. It is a wrapper for Ben Jann's Colorpalette and grstyle commands.
	When used, all colors from p1 to p15 will be changed based on the specifications of a specific color palette. The command also comes with color_brewer.ado, which is a collection of palettes that have been shared for other plataforms.
	The package also comes with two schemes. Black and white, adapted from white_tableau and black tableau. And a small program for changing fonts. -font_style-

      KW: color_style
      KW: font_style
      KW: scheme

      Requires: Stata version 14, palettes, colrspace, grstyle 
      
      Author:  Fernando Rios-Avila, Levy Economics Institute of Bard College
      Support: email  friosavi@levy.org
      

Files:
color_style.ado
color_brewer.ado
color_style.sthlp
font_style.ado
scheme-white.scheme
scheme-black.scheme