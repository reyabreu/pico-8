pico-8 cartridge // http://www.pico-8.com
version 20
__lua__
srand(t())last=-2
explosions={}
particles={}
function create_explosion(x,y,radius)
	local explosion={
		x=x,y=y,radius=radius,
		timer=0}
	
	--add particles to explosions
 for i=1,30 do
 	local a=rnd(1)
 	local vx=cos(a)*rnd(2)
 	local vy=sin(a)*rnd(2)
 	local p={x=x,y=y,vx=vx,vy=vy,colour=10,age=0}
		add(particles,p)
 end
 
 add(explosions,explosion)
end
::_::
if t()-last>2 then
	cls(1)
	create_explosion(rnd(64)+32,rnd(64)+32,rnd(32)+10)
	last=t()
end

for p in all(particles) do
	p.age+=1
	if p.age>15 then
		del(particles,p)
	elseif p.age>10 then
		p.colour=4
	elseif p.age>5 then
		p.colour=9
	end
	p.x+=p.vx
	p.y+=p.vy
	pset(p.x,p.y,p.colour)
end

for exp in all(explosions) do
	if exp.timer<2 then
  circfill(exp.x,exp.y,exp.radius,9)
 elseif exp.timer<4 then
  circfill(exp.x,exp.y,exp.radius,8)
 elseif exp.timer<5 then
  circ(exp.x,exp.y,exp.radius,7)
  del(explosions,exp)
  break
 end
 exp.timer+=1
end
flip()
goto _
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
