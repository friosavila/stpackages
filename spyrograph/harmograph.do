program drop harmonogram
program harmonogram
syntax, x(string asis) y(string asis)
clear
range t 0 100 2000
gen x1 = `x'
gen y1 = `y'
replace t = -t
two scatteri `=x1[1]' `=y1[1]' || line x1 y1 , aspect(1) lwidth(.1)
end

local a1 = 100
local a2 = 200
local f1 = 1
local f2 = 1
local p1 = _pi/3
local p2 = _pi/2
local d1 = 0.02
local d2 = 0.02
harmonogram, y(`a1'*sin(`f1'*t+`p1')*exp(-(`d1'*t))+250*sin(2*t + `p1')) ///
			 x(`a2'*cos(`f2'*t+`p2')*exp(-(`d2'*t))+50*sin(3*t + `p2'))