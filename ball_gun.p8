pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
	make_gun()	
end

function _update()
	mv_gun_left()
 if (btn(❎)) fire_gun()
	update_ball()
end

function _draw()
 cls(1)
 draw_gun()
 draw_ball()
end
-->8
--utils
function p2c(r,a)
	local p={}
	p.x=r*cos(0.25-a/360)
	p.y=r*sin(0.25-a/360)
	return p
end
-->8
--ball gun
gun={}
function make_gun()
	gun.cx=63
	gun.cy=63
	gun.r=60
	gun.a=30
	gun.col=8
	
	update_gun()
end

function fire_gun()
	make_ball()
	ball.shot=true
end

function update_gun()
 local p1,p2=p2c(gun.r,gun.a),p2c(gun.r-7,gun.a)
 gun.x=gun.cx+p1.x
 gun.y=gun.cy+p1.y
 gun.mx=gun.cx+p2.x
 gun.my=gun.cy+p2.y
end


function mv_gun_left()
	gun.a-=10
	update_gun()
end

function mv_gun_right()
	gun.a+=10
	update_gun()
end

function draw_gun()
 local cx,cy=gun.cx,gun.cy
 local r=gun.r
	local p
	for a=10,360,10 do
		p=p2c(r,a)
		pset(cx+p.x,cy+p.y,7)
		if (a%30==0) then
			circfill(cx+p.x,cy+p.y,2,7)
		end
	end
	circ(gun.x,gun.y,3,gun.col)
	line(gun.x,gun.y,gun.mx,gun.my,gun.col)
end
-->8
--ball
ball={}
function make_ball()
	ball.x=gun.mx
	ball.y=gun.my
	ball.r=3
	
	ball.dy=gun.my-gun.cy
	ball.dx=gun.mx-gun.cx
	
	ball.shot=false
end

function update_ball()
	if ball.shot then
		ball.x+=ball.dx
		ball.y+=ball.dy
		ball.shot=ball.x>0 and ball.x<128
			and ball.y>0 and ball.y<128
	end
end

function draw_ball()
	circfill(ball.x,ball.y,ball.r,7)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
