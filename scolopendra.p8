pico-8 cartridge // http://www.pico-8.com
version 23
__lua__
timer=0
spd=3
segments={}

function make_segment(idx,x,y)
	local segment={
		x=x,y=y,
		los=0,
		draw=function(s)
			spr(idx+16*s.los,s.x-4,s.y-4)
		end
	}
	return segment
end

function _init()
	add(segments,make_segment(1,64,64))
	for i=1,8 do
		add(segments,make_segment(2,64-4*i,64))
	end
	add(segments,make_segment(3,64-4*#segments-1,64))
end

function _update()
	timer+=1
	if (timer>10) timer=0
	
	local dx=0
	if (btn(0)) dx-=1
	if (btn(1)) dx+=1
	
	foreach(segments,function(s) 
		if (timer==10) s.los=(s.los+1)%2		
		s.x+=dx*spd 
	end)
end

function _draw()
	cls(1)
	for s in all(segments) do
		s:draw()	
	end
end
__gfx__
00000000000040000005000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000004404000040000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700099500800999000049099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000944900009449000000949000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000944900009449000000949000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700099500800999000049099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000004404000040000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000040000500000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000040000500000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000004404000040000040040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000099508000999000009099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000944900009449000000949000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000944900009449000000949000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000099508000999000009099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000004404000040000040040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000040000005000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
