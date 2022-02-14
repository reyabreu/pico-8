-- main menu loop
function menu_init()
  _update = menu_update
  _draw = menu_draw
end

function menu_update()
  if (btnp(❎)) game_init()
  if (btnp(🅾️)) goodbye()
end

function menu_draw()
  cls()
	print_centered("new game",58,12)
	print_centered("press ❎ to start",64,12)
  print_centered("press 🅾️ to exit" ,70,12)
end