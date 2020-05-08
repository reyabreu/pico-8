pico-8 cartridge // http://www.pico-8.com
version 23
__lua__

local values={}

function _init()
 cls(1)

	-- 0..1 is a half circle sweep (0..pi)
	for x=1,127 do
		pset(x,64-50*sin(x/127),10)
		pset(x,64-50*cos(x/127),15)
	end

	line(0,64,127,64,7)
	pset(33,65,7)	
	pset(64,65,7)
	pset(96,65,7)	
	pset(127,65,7)	
	print("pi/2",60,68,7)
	print("pi",120,68,7)
	line(0,0,0,127,7)
end

-- pico-8 circle sweep is 
-- from 0 to 1
function _update()
	-- sin is inverted (clockwise)
	values.sx0=sin(0)
	values.sx1=sin(0.25) -- pi/2
	values.sx2=sin(0.5)  -- pi
	
	-- cos is not inverted (anticlockwise)
	values.cx0=cos(0)
	values.cx1=cos(0.25) -- pi/2
	values.cx2=cos(0.5)  -- pi
end

function _draw()
	local sx0,sx1,sx2=values.sx0,values.sx1,values.sx2
	print("sin, 0:"..sx0..",0.25:"..sx1..",0.5:"..sx2,4,1,10)
 	local cx0,cx1,cx2=values.cx0,values.cx1,values.cx2 	
	print("cos, 0:"..cx0..",0.25:"..cx1..",0.5:"..cx2,4,7,15)	
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
