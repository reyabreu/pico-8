pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--proof of concepts
--by reynaldo
function _init()
	make_ball()
end

function _update()
 update_time()
	move_ball()
end

function _draw()
	cls()
	draw_ball()
	print_time()
end

-->8
--ball
ball={}

function make_ball()
	ball.x=60
	ball.y=72
	ball.r=3
	ball.dr=0.5
	ball.dx=3
	ball.dy=2
	ball.c=10
end

function move_ball()
	ball.x+=ball.dx
	ball.y+=ball.dy

	if (ball.x>127-ball.r or ball.x<ball.r) ball.dx=-ball.dx
	if (ball.y>127-ball.r or ball.y<ball.r) ball.dy=-ball.dy
end

function draw_ball()
	ball.r+=ball.dr
	if (ball.r>3 or ball.r<2)	ball.dr=-ball.dr
	circfill(ball.x,ball.y,ball.r,ball.c)
end
-->8
--frames
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
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
