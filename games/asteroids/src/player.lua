-- player routines
function make_player()
  local instance = {
    x=32,
    y=32,
    status="not started",
    draw=function(self)
      spr(1, self.x, self.y)
    end
  }
  return instance
end