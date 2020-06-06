pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--main
function _init()
	ball=make_ball(4*8,7*8)	
end

function _update()
	ball:update()
end

function _draw()
	cls()
	map()
	ball:draw()
end
-->8
--ball
function make_ball(x,y)
	local ball={
		x=x,y=y,
		spd=3,
		update=function(this)
			local x,y=this.x,this.y
			
			if (btn(⬅️)) x-=this.spd
			if (btn(➡️)) x+=this.spd
			if (btn(⬆️)) y-=this.spd
			if (btn(⬇️)) y+=this.spd
			
			this.x=x
			this.y=y
		end,
		draw=function(this)
			spr(1,this.x,this.y)
		end,		
	}
	return ball
end
__gfx__
0000000000aaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aa77aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700aaaa77aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000aaaaa7aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770009aaaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007009aaaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000009aaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000099aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333333336777777688888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333333337566666788888688000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333333337577776788888868000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333333337577776788888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333333337577776786888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333333337577776788688888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333333337555555788888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333333336777777688888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000102000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1211111111111111111111111111111200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1211111111111111111111111111111200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1211111111111111111111111111111200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1211111111111111111111111111111200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1211111111111111111111111111111200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1211111111111111111111111111111200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1211111111111113131111111111111200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1211111111111113131111111111111200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1211111111111111111111111111111200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1211111111111111111111111111111200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1211111111111111111111111111111200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1211111111111111111111111111111200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1211111111111111111111111111111200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1211111111111111111111111111111200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
