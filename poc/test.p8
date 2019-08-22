pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- test
srcx=40
srcy=127

box={}
ball={}

horiz=""
vert=""

function make_ball()
	ball.x=srcx
	ball.y=srcy
	ball.dx=0
	ball.dy=-2
	ball.sz=2
end

function make_box()
	box.x=32
	box.y=46
	box.w=64
	box.h=16
end

function draw_box()
	rect(box.x,box.y,box.x+box.w,box.y+box.h,7)
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
	make_box()
	make_ball()
end

function _update()
	if (btn(⬅️)) srcx-=1
	if (btn(➡️)) srcx+=1	
	if (btn(⬆️)) srcy-=1
	if (btn(⬇️)) srcy+=1

	srcx=clamp(srcx,0,127)
	srcy=clamp(srcy,0,127)

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
 draw_box()
 draw_ball()
	print_stats()
end
-->8
--utils
function clamp(v,vmin,vmax)
	if (v<vmin) return vmin
	if (v>vmax) return vmax
	return v
end

function in_bounds(v,vmin,vmax)
	return v>=vmin and v<=vmax
end

function in_screen(x,y)
	return in_bounds(x,0,127) and 
		in_bounds(y,0,127)
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
