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
	ball.spx=-4
	ball.spy=4
	ball.sz=2
	ball.col=10
end

function draw_ball()
	circfill(ball.x,ball.y,ball.sz,ball.col)
end

function update_ball()
	-- bouncing off walls
	local lbx,lby=ball.x,ball.y

	--side walls
	ball.x+=ball.spx
	if ball.x<ball.sz or ball.x>127-ball.sz then
		ball.x=mid(ball.sz,ball.x,127-ball.sz)
		ball.spx=-ball.spx
		sfx(0)
	end
	
	-- top wall
	ball.y+=ball.spy
	if ball.y<ball.sz or ball.y>127-ball.sz then
		ball.y=mid(ball.sz,ball.y,127-ball.sz)
		ball.spy=-ball.spy
		sfx(0)
	end
	
	-- pulsate
	ball.sz=3+flr(sin(tsec/4))
	
	-- paddle collision detection
	local sx,sy,ssz=ball.x,ball.y,3--ball.sz
	local tx,ty,tw,th=pad.x,pad.y,pad.w,pad.h

	-- if pad collision
	if has_collision(sx,sy,ssz,tx,ty,tw,th) then	
		local has_h=lby+ssz<ty or lby-ssz>ty+th
		local has_v=lbx+ssz<tx or lbx-ssz>tx+tw
		
		-- on corner
		if has_h and has_v then
			has_h=1+flr(rnd(10))>5
			has_v=not has_h
		end
	
	 	-- on horiz surface
		if has_h then
			if lby<ty then
				ball.y=ty-ssz
			else
				ball.y=ty+th+ssz
			end
			ball.spy*=-1
		end

	 	-- on vert surface
		if has_v then
			if lbx<tx then
				ball.x=tx-ssz
			else
				ball.x=tx+tw+ssz
			end
			ball.spx*=-1
		end
		
		sfx(1)	
	end
end
-->8
-- paddle
pad={}

function make_paddle()
	pad.x=52
	pad.y=100
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
	
	pad.x=mid(1,pad.x,126-pad.w)
end
-->8
-- utils
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
-->8
-- collisions
function has_collision(sx,sy,ssz,tx,ty,tw,th)
	return sx+ssz>tx and sx-ssz<tx+tw and sy+ssz>ty and sy-ssz<ty+th
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
