pico-8 cartridge // http://www.pico-8.com
version 23
__lua__
--main
function lerp(start,finish,factor)
	local value=mid(start,start*(1-factor)+finish*factor,finish)
	if (abs(finish-value)<0.05) value=finish
	return value
end

function rr(v)
	local av=abs(v)
	local rup=av-flr(av)>=0.5

	if v>0 then
		if rup then
			return flr(v)+1
		else
			return flr(v)
		end
	else
		if rup then
			return flr(v)
		else
			return flr(v)-1
		end
	end
end

function _init()
	pos={x=64,y=64}
	spd={x=0,y=0}
	radius=3
	
	black=0
	blue=1
	white=7
	orange=9
end

function _update()
	oldpos={x=pos.x,y=pos.y}
	oldspd={x=spd.x,y=spd.y}
	local dx,dy=0,0
	local m=2
	if (btn(⬅️)) then dx-=1 end
	if (btn(➡️)) then dx+=1 end
	if (btn(⬆️)) then dy-=1 end
	if (btn(⬇️)) then dy+=1 end
	if (dx~=0 and dy~=0) m=flr(m*0.707)

	spd.x=lerp(spd.x,m*dx,0.1)		
	spd.y=lerp(spd.y,m*dy,0.1)
	
	pos.x=mid(radius,rr(pos.x+spd.x),127-radius)	
	pos.y=mid(radius,rr(pos.y+spd.y),127-radius)
end

function _draw()
	rectfill(0,0,127,127,blue)
	print("x,y:"..pos.x..","..pos.y,1,1,white)
	circfill(pos.x,pos.y,radius,orange)
	local dx=abs(pos.x-oldpos.x)
	local dy=abs(pos.y-oldpos.y)
	print("sx="..abs(spd.x)..",sy="..abs(spd.y),1,7,white)
	--print("dx,dy:"..dx..","..dy,4,10,white)	
	line(pos.x,pos.y,pos.x+dx*spd.x,pos.y+dy*spd.y,white)
end
__gfx__
00000000002aa000000aa20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000002aaaa0000aaaa2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007002a4aa4a00a4aa4a200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000aaaaaaaaaaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000aa4444aaaa4444aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007002aa44aa00aa44aa200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000002aaaa0000aaaa2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000002aa000000aa20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
