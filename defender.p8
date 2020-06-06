pico-8 cartridge // http://www.pico-8.com
version 23
__lua__
function _init()
	asteroids={}
	shots={}
	gun={
		x=64,
		y=100,
		ml=7,
		r=4,
		a=0,
		step=0.01,
	}	
end

function add_asteroid()
	
	local ex,ey=0,0
	local dx,dy=0,0


	if (q==0) then
		ex=v
		ey=0
		dx=rndb(-2,2)
		dy=rndb(1,3)
	elseif (q==1) then
		ex=127
		ey=v-127
		dx=rndb(-1,-3)
		dy=rndb(-2,2)
	end
	local asteroid={x=ex,y=ey,dx=dx,dy=dy,r=rndb(3,6)}
	add(asteroids,asteroid)
end

function _update()
	--add asteroid
	if (#asteroids<10) add_asteroid()

	--update asteroid
	for e in all(asteroids) do
		e.x+=e.dx
		e.y+=e.dy
		if e.x<0 or e.x>128 or
			e.y<0 or e.y>128 then
			del(asteroids,e)
		end
	end

	--update shots
	for s in all(shots) do
	 s.r+=5
		local sx,sy=to_cartesian(s.ox,s.oy,s.r,s.a)
		if sx<0 or sx>128 or 
			sy<0 or sy>128 then
			del(shots,s)
		end
	end

	--rotate cannon muzzle
	if (btn(➡️)) gun.a-=gun.step
	if (btn(⬅️)) gun.a+=gun.step
	
	--shoot
	if (btnp(🅾️)) then
		shot={
			ox=gun.x,
			oy=gun.y,
			a=gun.a,
			r=gun.ml
		}
		add(shots,shot)
	end
end

function _draw()
	cls()

	--draw asteroids
	for e in all(asteroids) do
		circ(e.x,e.y,e.r)
	end

	--draw shots
	cursor()
	for s in all(shots) do
		local sx,sy=to_cartesian(s.ox,s.oy,s.r,s.a)
		pset(sx,sy,rnd({5,9,10}))
		print("s:"..sx..","..sy)
	end

	--draw gun	
	local mx,my=to_cartesian(gun.x,gun.y,gun.ml,gun.a)
	line(gun.x,gun.y,mx,my,10)
	circfill(gun.x,gun.y,gun.r,0)	
	circ(gun.x,gun.y,gun.r,7)	
end

function to_cartesian(ox,oy,r,a)
	return flr(ox+r*cos(a)),flr(oy+r*sin(a))
end

function rndb(lo,hi)
	return rnd(hi-lo+1)+lo
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
