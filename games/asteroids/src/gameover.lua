--gameover
function gameover_init()
	_update = gameover_update
	_draw = gameover_draw
end

function gameover_update()
	if (btnp(❎)) menu_init()
end

function gameover_draw()
	cls()
	print_centered("you lost",60,12)
	print_centered("press ❎ when ready to restart",68,12)
end