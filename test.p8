pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- test
srcx=52
srcy=120

function make_ball(x,y)
	local b={}
	b.x=x
	b.y=y
	b.dx=0
	b.dy=-2
	b.sz=3
	return b
end

function make_box(x,y,w,h)
	local bx={}
	bx.x=x --32
	bx.y=y --46
	bx.w=w --64
	bx.h=h --16
	bx.c=7
	bx.draw=draw_box
	return bx
end

function draw_box(bx)
	rect(bx.x,bx.y,bx.x+bx.w,bx.y+bx.h,bx.c)
end

function draw_ball()
	local x,y=srcx,srcy
	circfill(x,y,1,14)
	repeat
		pset(x,y,8)
		x+=ball.dx
		y+=ball.dy
	until (x==ball.x and y==ball.y)
	circfill(x,y,2,8)	
end

function print_stats()
 --rectfill(0,0,20,20,0)
	print("horiz:"..horiz,4,4,7)
	print(" vert:"..vert,4,10,7)	
end

function _init()
	box=make_box(32,46,64,16)
	ball=make_ball(srcx,srcy)
end

function _update()
	if (btn(0)) srcx-=1
	if (btn(1)) srcx+=1	
	if (btn(2)) srcy-=1
	if (btn(3)) srcy+=1

	srcx=mid(0,srcx,127)
	srcy=mid(0,srcy,127)

	local x,y,ssz=ball.x,ball.y,ball.sz

	if not check_collision(x,y,ssz,box.x,box.y,box.w,box.h) then
	 ball.x+=ball.dx
	 ball.y+=ball.dy		
	end

 horiz,vert="none","none"
	
	if is_horiz_impact(
		x,y,ssz,box.x,box.y,box.w,box.h) then
		horiz="collision!"
	end
	
	if is_vert_impact(
  x,y,ssz,box.x,box.y,box.w,box.h) then
		vert="collision!"
	end	
	
end

function _draw()
	cls()
	box:draw()
	draw_ball()
	print_stats()
end
-->8
--utils
function has_collision(ball,box)
	local cx,cy=false,false
	for x=ball.x-ball.sz,ball.x+ball.sz do
		cy
		cx=in_bounds(x,box.x,box.x+box.w)
		if (cx) break
	end
	for x=ball.x-ball.sz,ball.x+ball.sz do
		cx=in_bounds(x,box.x,box.x+box.w)
		if (cx) break
	end
end

function in_bounds(v,vmin,vmax)
	return v>=vmin and v<=vmax
end

function in_screen(x,y)
	return in_bounds(x,0,127) and in_bounds(y,0,127)
end

function lerp(vstart,vfinish,factor)
	return mid(vstart,vstart*(1-factor)+factor*vfinish,vfinish)
end
-->8
-- collisions
function check_collision(sx,sy,ssz,tx,ty,tw,th)
	local x,y=sx,sy
	return x+ssz>=tx and x-ssz<=tx+tw and y+ssz>=ty and y-ssz<=ty+th
end

function is_horiz_impact(sx,sy,ssz,tx,ty,tw,th)	
	if check_collision(sx,sy,ssz,tx,ty,tw,th) then
		local x,y=sx,sy		
		return abs(y+ssz-ty)<=ssz or abs(y-ssz-(ty+th))<=ssz
	else
		return false
	end
end

function is_vert_impact(sx,sy,ssz,tx,ty,tw,th)
	if check_collision(sx,sy,ssz,tx,ty,tw,th) then
		local x,y=sx,sy		
		return abs(x+ssz-tx)<=ssz or abs(x-ssz-(tx+tw))<=ssz
	else
		return false
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
