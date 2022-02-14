-- game loop
function game_init()
	_update = game_update
	_draw = game_draw
	player = make_player()
	player_move = cocreate(move)
end

function game_update()
	if player_move and costatus(player_move) != "dead" then
		coresume(player_move)
	else
		player_move = cocreate(move)
	end

	if btnp(🅾️) then
		gameover_init()
	end
end

function game_draw()
	cls()
	player:draw()
	print(player.status)
	print_centered("press 🅾️ to lose",70,11)
end

function move()
	local i=32
	player.status="left to right"
	repeat

			i+=1
			player.x=i

			yield()
	until i>96
	
	player.status="top to bottom"
	i=32
	repeat

			i+=1
			player.y=i

		yield()
	until i>96
	
	player.status="back to start"
	i=96
	repeat

			i-=1
			player.x,player.y=i,i

		yield()
	until i<32
end