pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- test
box={}
ray={}
horiz=""
vert=""

function make_box()
	box.x=32
	box.y=46
	box.w=64
	box.h=16
end

function make_ray()
	ray.x=20
	ray.y=20
	ray.dx=2
	ray.dy=2
end

function draw_box()
	rect(box.x,box.y,box.x+box.w,box.y+box.h,7)
end

function draw_ray()
	local px,py=ray.x,ray.y
	circfill(px,py,1,8)
	while in_screen(px,py) do
		pset(px,py,8)
		
		if in_bounds(px,box.x,box.x+box.w) and
			in_bounds(py,box.y,box.y+box.h) then
			return
		end	
		
		px+=ray.dx
		py+=ray.dy
	end
end

function print_stats(h,v)
	print("horiz:"..h,4,4,7)
	print(" vert:"..v,4,10,7)	
end

function _init()
	make_box()
	make_ray()
end

function _update()
	if (btn(⬅️)) ray.x-=1
	if (btn(➡️)) ray.x+=1	
	if (btn(⬆️)) ray.y-=1
	if (btn(⬇️)) ray.y+=1

	ray.x=clamp(ray.x,0,127)
	ray.y=clamp(ray.y,0,127)

 horiz,vert="none","none"
	
	if is_horiz_impact(
		ray.x,ray.y,ray.dx,ray.dy,
		box.x,box.y,box.w,box.h) then
		horiz="collision!"
	end
	
	if is_vert_impact(
		ray.x,ray.y,ray.dx,ray.dy,
		box.x,box.y,box.w,box.h) then
		vert="collision!"
	end	
end

function _draw()
 cls()
 draw_box()
 draw_ray()
	print_stats(horiz,vert)
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
function check_collision(sx,sy,dx,dy,tx,ty,tw,th)
	local x,y=sx,sy
	while in_screen(x,y) do
		if (x>=tx and x<=tx+tw and y>=ty and y<=ty+th) then
			return true	
		end
		x+=dx
		y+=dy
	end
	return false
end

function is_horiz_impact(sx,sy,dx,dy,tx,ty,tw,th)
	local x,y=sx,sy
	while in_screen(x,y) do
		if (x>=tx and x<=tx+tw and y>=ty and y<=ty+th) then
			if abs(y-ty)<=abs(dy) or
			 abs(y-(ty+th))<=abs(dy) then
				return true
			else
				return false
			end					
		end
		x+=dx
		y+=dy
	end
	return false
end

function is_vert_impact(sx,sy,dx,dy,tx,ty,tw,th)
	local x,y=sx,sy
	while in_screen(x,y) do
		if (x>=tx and x<=tx+tw and y>=ty and y<=ty+th) then
			if abs(x-tx)<=abs(dx) or
			 abs(x-(tx+tw))<=abs(dx) then
				return true
			else
				return false
			end			
		end
		x+=dx
		y+=dy
	end
	return false
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
