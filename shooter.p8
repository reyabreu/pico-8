pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
r={x=0,y=0,w=60,h=10,col=7}
g={a=0,col=8}
c={r=63,col=6}
b={x=0,y=0,dx=0,dy=0,spd=4,r=2,col=11}
trail={}
fired=false

freeze=0

function _init()
	r.x=(127-r.w)/2
	r.y=(127-r.h)/2
end

function _update() 
	if btn(➡️) or btn(⬅️) then
		if (btn(➡️)) g.a+=0.01
		if (btn(⬅️)) g.a-=0.01
	end
	
	if fired then
		if (b.x<-b.r or b.x>127+b.r or b.y<-b.r or b.y>127+b.r) then
			fired=false
			trail={}
		else
			if hasCollision() then
				bounceBall()
			else
				add(trail,{x=b.x,y=b.y})
				b.x+=b.dx
				b.y+=b.dy
			end
		end
	end
	
	if not fired and btn(❎) then
		fired=true
		local x,y=63+c.r*cos(g.a),63-c.r*sin(g.a)
		b.x=x
		b.y=y
		b.dx=-b.spd*cos(g.a)
		b.dy=b.spd*sin(g.a)
	end
end

function hasCollision()
	return b.x+b.r>r.x and b.x-b.r<r.x+r.w and b.y+b.r>r.y and b.y-b.r<r.y+r.h
end

function bounceBall()
	local l=trail[#trail]
	if l.y+b.r<r.y or l.y-b.r>r.y+r.h then
		b.dy=-b.dy
		if l.y+b.r<r.y then 
			b.y=r.y-b.r
		else
			b.y=r.y+r.h+b.r
		end
	end
	if l.y+b.r>=r.y and l.y-b.r<=r.y+r.h then
		b.dx=-b.dx
		if l.x+b.r<r.x then 
			b.x=r.x-b.r
		else
			b.x=r.x+r.w+b.r
		end
	end
end


function _draw()
	cls(1)
	rect(r.x,r.y,r.x+r.w,r.y+r.h,r.col)
	--cross(63,63,10)
	--circ(63,63,c.r,c.col)
	cross(63+c.r*cos(g.a),63-c.r*sin(g.a),g.col)
	if (fired) then
		for v in all(trail) do
			pset(v.x,v.y,b.col)
		end
		circfill(b.x,b.y,b.r,b.col)
	end
	printh("a: "..g.a)
end

function cross(x,y,col)
	line(x-1,y,x+1,y,col)
	line(x,y-1,x,y+1,col)	
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
