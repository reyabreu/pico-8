pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
man={}

function make_man(x,y)
	local man={
		x=x,y=x,
		dx=0,dy=0,--speed
		d=1,--direction -1,1
		f=0,--animation frame 0..4
		
		update=function (m)
		 local ac=0.1--accel
			if (btn(⬅️)) m.dx-=ac m.d=-1 
			if (btn(➡️)) m.dx+=ac m.d=1
			if (btn(⬆️)) m.dy-=ac
			if (btn(⬇️)) m.dy+=ac
			m.x+=m.dx m.y+=m.dy
			m.dx*=0.7 m.dy*=0.7--friction
			local spd=sqrt(m.dx*m.dx+m.dy*m.dy)
			m.f=(m.f+spd*2)%4--4 frames
			if (spd<0.05) m.f=0--idle
		end,

		draw=function (m)
			spr(1+m.f,m.x*8-4,m.y*8-4,1,1,m.d==-1)
		end
	}
	return man
end

function _init()
	man=make_man(24,24)
end

function _update()
 	man:update()
	if mget(man.x,man.y)==10 then
		mset(man.x,man.y,26)
		sfx(0)
	end
end

function _draw()
 cls(1)
 local room_x,room_y=flr(man.x/16),flr(man.y/16)
 camera(room_x*128,room_y*128)
 map()
 man:draw()
end
__gfx__
00000000000000000000000000088000000000000000000000000000000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddddd
00000000000880000008800000086000000880000000000000000000000000000000000000000000dddd655dddd6dd6ddddddddddd3333ddddddddddd6dd6ddd
00700700000860000008600008888800000860000000000000000000000000000000000000000000ddd65055dd6dd6ddddd6ddddd361613ddddddddddd6dd6dd
00077000088888000088800080888080088888000000000000000000000000000000000000000000dd65555dd6dd6dddddd6dd6dd333333dddddddddddd6dd6d
00077000808880800888880000999000808880800000000000000000000000000000000000000000ddd5556dddd6dd6dd6d6d6ddd3e5513dddddddddd6dd6ddd
00700700009990000099900000900900009990000000000000000000000000000000000000000000ddd55d6ddd6dd6ddd6ddd6ddd35e553ddddddddddd6dd6dd
00000000009090000090090008000800009090000000000000000000000000000000000000000000d55dddddd6dd6ddddddddddddd3333ddddddddddddd6dd6d
00000000118181000811181011111110018181000000000000000000000000000000000000000000dd5ddddddddddddddddddddddddddddddddddddddddddddd
00000000000000000000000000000000000000000000000000000000000000000000000000000000dddddddd0000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000dddd6d7d0000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000ddd670770000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000dd6d777d0000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000dddd7d6d0000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000ddd77d6d0000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000d77ddddd0000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000dd7ddddd0000000000000000000000000000000000000000
00000000000000000000000000088000000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000880000008800000086008000860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000860000008600008888880888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088888000888880080888000008880080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000808880808088808000999900009990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000009990000099900000900090009009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000009009000900090008000080008008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000181111808111181001111100011111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0c0e0e0e0e0e0e0e0c0c0e0e0e0c0e0e0c0c0e0e0e0e0e0e0c0c0e0e0c0e0e0e0e0e0e0e0e0e0e0e0f0f0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0a0e0e0e0e0e0e0e0e0e0e0d0d0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0c0e0e0e0e0d0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0a0a0e0e0e0e0e0e0e0e0e0e0e0e0e0e0d0e0e0e0e0e0e0e0e0d0e0e0e0e0e0e0d0d0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0e0e0e0e0d0e0e0e0e0e0e0e0e0e0e0e0e0a0e0a0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0d0d0e0e0e0e0e0e0e0d0d0e0e0b0e0e0e0d0d0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0e0e0e0e0e0d0d0e0e0e0e0e0e0e0e0e0a0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0b0b0e0e0e0e0e0e0e0e0e0e0d0d0b0b0b0b0e0d0d0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e1a0e0e0e0d0e0e0e0e0e0e0d0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0e0e0e0e0e0e0e0d0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0d0e0e0e0e0e0d0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0e0e0e0e0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0d0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0f0e0e0e0d0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e1a0e0e0b0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0d0d0d0e0e0e0e0e0e0e0d0e0d0d0e0e0e0e0e0e0e0e0e0d0d0e0e0e0e0e0a0a0e0e0e0e0e0e0e0e0e0e0e0e0b0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0d0d0d0e0e0e0e0e0d0d0e0e0e0e0e0e0e0d0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0b0b0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0a0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0d0d0e0e0e0e0e0e0e0d0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0c0e0e0e0f0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0d0e0e0e0e0e0e0e0e0e0d0e0e0e0e0b0e0e0e0e0e0e0f0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0c0e0e0e0f0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0d0e0e0e0e0e0e0e0e0e0e0e0f0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0a0e0e0e0e0e0e0e0e0e0a0a0e0e0e0f0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0a0e0e0e0d0d0e0e0e0e0e0a0a0e0e0e0f0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0a0e0e0e0e0d0d0d0e0e0e0e0a0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0c0e0e0e0e0a0a0a0e0d0d0d0d0d0e0d0e0d0d0e0e0e0a0e0e0e0e0e0e0e0e0a0e0e0b0e0e0e0d0d0e0e0e0a0e0e0e0e0e0e0e0e0e0a0a0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0a0a0a0e0e0e0e0e0e0e0e0e0e0a0a0e0e0e0e0e0e0e0e0a0e0e0b0b0e0e0e0e0e0e0e0a0e0e0e0e0e0e0e0e0e0e0a0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0a0e0a0a0e0a0a0e0a0a0e0e0e0e0e0e0e0e0e0e0e0e0e0e0b0e0e0e0e0e0e0e0e0e0e0e0e0e0d0d0e0e0e0a0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0f0e0f0f0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0d0d0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0a0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0d0e0e0e0e0e0b0b0b0e0e0e0d0d0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0f0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0d0e0e0e0e0b0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0c0e0e0e0d0d0d0d0d0e0e0d0e0e0e0e0e0e0e0e0e0e0f0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0d0d0e0e0e0e0e0a0a0e0e0a0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0d0d0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0d0d0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0f0f0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0f0f0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000200001012014120191401f150251502a170241601e16015150111400a130051200412000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
