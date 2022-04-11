pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- tutorial 01
function _init()
	game_over=false
	make_cave()
	make_player()
end

function _update()
	if (not game_over) then
		update_cave()
		move_player()
		check_hit()
	else
		if (btnp(❎)) _init() --restart 
	end
end

function _draw()
	cls()
	draw_cave()
	draw_player()
	
	if (game_over) then
		print("game over!",44,44,7)
		print("your score:"..player.score,34,54,7)
		print("press ❎ to play again!",18,72,6)
	else
		print("score:"..player.score,2,2,7)
	end
end
-->8
function make_player()
	player={}
	player.x=24 			-- position
	player.y=60
	player.dy=0				-- fall speed
	player.rise=1		-- sprites
	player.fall=2
	player.dead=3
	player.speed=2	-- fly speed
	player.score=0
end

function draw_player()
	if (game_over) then
		spr(player.dead,player.x,player.y)
	elseif (player.dy<0) then
		spr(player.rise,player.x,player.y)
	else
		spr(player.fall,player.x,player.y)
	end
end

function move_player()
	gravity=0.2
	--fall
	player.dy += gravity
	
	--jump
	if (btnp(⬆️)) then
		player.dy -= 5
		sfx(0)
	end
	
	--calculate delta
	player.y += player.dy
	
	--update score
	player.score+=player.speed
end

function check_hit()
	for i=player.x,player.x+7 do
		if (cave[i+1].top>player.y or
		cave[i+1].btm<player.y+7) then
			game_over=true
			sfx(1)
		end
	end
end
-->8
function make_cave()
	cave={{["top"]=5,["btm"]=119}}
	top=45
	btm=85
end

function update_cave()
	-- remove back of the cave
	if (#cave>player.speed) then
		for i=1,player.speed do
			del(cave,cave[1])
		end
	end
	
	-- add more cave
	while (#cave<128) do
		local col={}
		local up=flr(rnd(7)-3)
		local dwn=flr(rnd(7)-3)
		col.top=mid(3,cave[#cave].top+up,top)
		col.btm=mid(btm,cave[#cave].btm+dwn,124)
		add(cave,col)
	end
end

function draw_cave()
	top_color=5
	btm_color=5
	for i=1,#cave do
		line(i-1,0,i-1,cave[i].top,top_color)
		line(i-1,127,i-1,cave[i].btm,btm_color)
	end
end
__gfx__
0000000000aaaa0000aaaa0000888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aaaaaa00aaaaaa008888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700aa0aa0aaaaaaaaaa88988988000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000aaaaaaaaaa0aa0aa88888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000aa0000aaaaaaaaaa88899888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700aaa00aaaaaa00aaa88988988000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aaaaaa00aa00aa008888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000aaaa0000aaaa0000888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000400001105014050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00003405000000000002605000000000001b05000000080400803008030080300802008020080200801008010080100800008000000000000000000000000000000000000000000000000000000000000000
00100000190501a5701a5701b5701b5602a0502c7402c7402c7302a0301a1401a1401a1401b140280401d540280401915019160191602b070300703307032070250601b5401953019530185301e5301f5301f530
__music__
00 02424344

