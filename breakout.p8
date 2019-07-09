pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- main

function _init()
	draw_bg()
	make_ball()
	make_paddle()
end

function _update()
	-- time and frames
	update_time()
	update_ball()
	update_paddle()
end

function _draw()
	draw_bg()
	draw_ball()
	draw_paddle()
	print("sz:"..ball.sz,4,10,7)
	print_time()
end

-->8
-- ball
ball={}

function make_ball()
	ball.x=35
	ball.y=30
	ball.spx=-2
	ball.spy=1
	ball.sz=2
	ball.col=10
end

function draw_ball()
	circfill(ball.x,ball.y,ball.sz,ball.col)
end

function update_ball()
	-- bouncing
	ball.x+=ball.spx
	if ball.x<ball.sz or ball.x>127-ball.sz then
		ball.x=clamp(ball.x,ball.sz,127-ball.sz)
		ball.spx=-ball.spx
		sfx(0)
	end
	
	ball.y+=ball.spy
	if ball.y<ball.sz or ball.y>127-ball.sz then
		ball.y=clamp(ball.y,ball.sz,127-ball.sz)
		ball.spy=-ball.spy
		sfx(0)
	end
	
	-- pulsate
	ball.sz=3+flr(sin(tsec/4))
	
	-- paddle collision detection
	if ball.x>pad.x-ball.sz and 
		ball.x<pad.x+ball.sz+pad.w and
		ball.y>pad.y-ball.sz and 
		ball.y<pad.y+ball.sz+pad.h then
		
		ball.y=pad.y-ball.sz
		ball.spy=-ball.spy
		
		sfx(1)	
	end
end
-->8
-- paddle
pad={}

function make_paddle()
	pad.x=52
	pad.y=120
	pad.w=20
	pad.h=4
	pad.spd=3
	pad.col=15
end

function draw_paddle()
	rectfill(pad.x,pad.y,pad.x+pad.w,pad.y+pad.h,pad.col)
end

function update_paddle()
	if (btn(➡️)) pad.spd=5
	if (btn(⬅️)) pad.spd=-5
	
	pad.spd=lerp(pad.spd,0,0.21)
	pad.x+=pad.spd
	
	pad.x=clamp(pad.x,1,126-pad.w)
end
-->8
-- utils
function clamp(value,lo,hi)
	if (value < lo) return lo
	if (value > hi) return hi
	return value
end

function draw_bg()
	rectfill(0,0,127,127,1)
end

frame=1
tsec=0

function update_time()
	frame+=1
	if (frame%3==0) tsec+=1
	if (frame>30) frame-=30
end

function print_time()
	print("tsec:"..tsec,4,4,7)
end

function lerp(start,finish,t)
 if (t<=0) return start
 if (t>=1) return finish
 local value = (1-t)*start+t*finish
 if (abs(finish-value) > 0.01) return value else return finish
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000c0000230701d0001800015000120000f0000d0000a000070000500003000000000000013000110000f0000d0000c0000900008000040000300001000000000d7000d7000d7000e7000f700107001070012700
000800001c04000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
