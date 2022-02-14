-- main routines
function _init()
  menu_init()
end

function goodbye()
  cls()
  print_centered("goodbye.", 8)
  extcmd("shutdown")
end