pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
-- nest 2
-- DOCZI_DOMINIK ~ 2020-2021

-- [[ cartdata essentails ]]
cartdata("doczidominik_nest2")

menuitem(2, "toggle guide", function()
  dset(10, dget(10) == 1 and 0 or 1)
end)

menuitem(3, "reset progress?!?", function()
  for i = 6, 9 do
    dset(i, 0)
  end
  extcmd("reset")
end)

-- [[ helpers ]]
function reset_pal()
  pal()
  pal(15, 0)
end

-- [ randoms ]
-- returns a random integer
-- between 0 - x-1
function frnd(x)
  return flr(rnd(x))
end

-- returns a random integer
-- between 1 - x
function crnd(x)
  return ceil(rnd(x))
end

-- randomly returns -1, 0 or 1
function rand_dir()
  return frnd(3) - 1
end

-- returns a random integer
-- between x and y
function rnd2(x, y)
  return x + frnd(y - x + 1)
end

-- determines if val
-- is in table
function in_table(val, table)
  for v in all(table) do
    if (v == val) return true
  end

  return false
end

-- determines if two boxes
-- partially overlap each other
function box_collision(x1, y1, x2, y2, w1, h1, w2, h2)
  if x1 > x2 + w2
    or x1 + w1 < x2
    or y1 > y2 + h2
    or y1 + h1 < y2
  then
    return false
  end

  return true
end

-- returns the length of a
-- line segment
function len(dx, dy)
  return sqrt(dx^2 + dy^2)
end

-- returns the length of a
-- line segment between
-- two points
function dist(x1, y1, x2, y2)
  local dx, dy = x1 - x2, y1 - y2

  return len(dx, dy)
end

-- returns the normalized
-- direction between two points
function direction(x1, y1, x2, y2)
  local dx, dy = x1 - x2, y1 - y2

  return dx/len(dx, dy), dy/len(dx, dy)
end

-- determines if point b
-- overlaps line segment
-- ac
function point_line_overlap(ax, ay, bx, by, cx, cy, leeway)
  local ab = dist(bx, by, ax, ay)
  local bc = dist(cx, cy, bx, by)

  local ac = dist(cx, cy, ax, ay)

  return mid(ac - leeway, ab + bc, ac + leeway) == ab + bc
end

-- determines if a point is
-- inside a convex polygon
-- defined by points
-- inside a table
function inbounds(x, y, w, h, table)
  table = table or points

  for i, pt in pairs(table) do
    po = table[i < #table and i+1 or 1]

    local pt_x, pt_y = pt.x - pt.dx*w, pt.y - pt.dy*w
    local po_x, po_y = po.x - po.dx*w, po.y - po.dy*w

    if (y - pt_y)*(po_x - pt_x) - (x - pt_x)*(po_y - pt_y) < 0 then
      return false
    end
  end

  return true
end

-- prints text with an outline
-- bg_color = color of outline
-- fg_color = color of text
function outline(s, x, y, fg_color, bg_color)
  fg_color = fg_color or 7
  bg_color = bg_color or 0

  for i=0, 2 do
    for j=0, 2 do
      print(s, x + i, y + j, bg_color)
    end
  end

  print(s, x + 1, y + 1, fg_color)
end

-- returns a zero padded
-- string for displaying time
function pad_left(str)
  str = tostr(str)

  if (#str == 2) return str

  return "0"..str
end

-- calculates minutes and
-- seconds from frames and
-- returns a string
function display_time(frames)
  local minutes, seconds = pad_left(flr(frames/3600)), pad_left(flr(frames%3600/60))

  if (minutes == "00") return seconds

  return minutes..":"..seconds
end

-->8
-- [[ effects ]]

-- [ player move particles ]
player_move_particles = {}

-- create
function add_player_move_particle(_x, _y)
  add(player_move_particles, {
    x = _x,
    y = _y,
    t = 1,

    max_t = 10,
    r = 3,
    col = split("12,12,12,12,3,3,1,1,1,1")
  })
end

-- update all
function update_player_move_particles()
  for pa in all(player_move_particles) do
    if pa.t < pa.max_t then
      if (pa.t > 6) pa.r -= 1

      pa.t += 1
    else
      del(player_move_particles, pa)
    end
  end
end

-- draw all
function draw_player_move_particles()
  for pa in all(player_move_particles) do
    circfill(
      pa.x,
      pa.y,
      pa.r,
      pa.col[mid(1, pa.t, #pa.col)]
    )
  end
end


-- [ player dash particles ]
-- create
function add_player_dash_particle(target_x, target_y, col_type)
  for i = 0, 10, 0.1 do
    local dx, dy =
      target_x - pl_x,
      target_y - pl_y

    local _x, _y =
      pl_x + dx * i/10,
      pl_y + dy * i/10

    add(player_dash_particles, {
      x = _x,
      y = _y,
      r = i,
      col = col_type == nil and split("12,12,12,12,3,3,3,3,1,1,1,1,1,0") or split("8,8,8,8,2,2,2,2,2,2,0,0,0,0")
    })
  end
end

-- update
function update_player_dash_particles()
  for pa in all(player_dash_particles) do
    if pa.r > 0 then
      pa.r -= 1
    else
      del(player_dash_particles, pa)
    end
  end
end

-- draw
function draw_player_dash_particles()
  for pa in all(player_dash_particles) do
    circfill(
      pa.x,
      pa.y,
      mid(0, pa.r, 3),
      pa.col[ceil(pa.r)]
    )
  end
end


-- [ general-purpose "smoke" ]
-- create
function add_smoke_particle(_x, _y, _dx, _dy, _r, _col, _max_t, _t)
  add(smoke_particles, {
    orig_x = _x,
    x = _x,
    y = _y,

    dx = _dx,
    dy = _dy,

    r = _r,
    col = _col,

    max_t = _max_t,
    t = _t or 1
  })
end

function update_smoke_particles()
  for pa in all(smoke_particles) do
    if pa.t < pa.max_t then
      if pa.t > 0 then
        pa.x += pa.dx
        pa.y -= pa.dy
      end

      pa.t += 1
    else
      del(smoke_particles, pa)
    end
  end
end

function draw_smoke_particles()
  if (dget(3) == 2) return

  for pa in all(smoke_particles) do
    -- shrinking from
    -- @krystman's
    -- explosion snippet
    local shrink_mult = 1

    shrink_mult = (pa.t - 5) / pa.max_t
    shrink_mult = mid(0, 1 - (shrink_mult*shrink_mult), 1)

    local current_col = pa.col[mid(#pa.col, pa.t, 1)]

    if (pa.t > 0) circfill(pa.x, pa.y, pa.r * shrink_mult, current_col)
  end
end

-- [ screenshake ]
screenshake_x, screenshake_y, cam_x, cam_y = 0, 0, 0, 0, 0
function screenshake()
  end

-->8
-- [[ scores and player ]]

-- [ scores ]
-- variables: see tab 7: init_game()

-- functions

-- add a right-shifted number
-- to the counter. score is
-- right-shifted to allow for
-- bigger, juicier numbers :)
function add_score(amount, hud_offset)
  current_score += shr(amount, 16)
  hud_score_offset_x = hud_offset or 6
end

-- display right-shifted
-- score as a string
-- ------------------------
-- by @felice on bbs
function display_score(val)
  local s, v = "", abs(val)

  repeat
    s = (v % 0x0.000a / 0x.0001)..s
    v /= 10
  until v==0

  return s
end


-- [ player ]
-- init: see: tab 7
-- top of init_game()

function update_player()
  local _dir = 0

  -- determine direction
  if btn(pl_forward and 0 or 1) then
    _dir = 1
  elseif btn(pl_forward and 1 or 0) then
    _dir = -1
  end


  -- move player on grid
  local l = 10/len(pl_dx, pl_dy)
  local speed = pl_combo > 9 and pl_speed + 0.15 or pl_speed

  pl_step = mid(0, pl_step + (l * speed * _dir), 10)

  pl_x, pl_y, pl_dx, pl_dy =
    calculate_grid_position(pl_prev, pl_next, pl_step, 10)


  -- turn corners after
  -- reaching a vertex
  if _dir == 1 and pl_step == 10 then
    pl_next = pl_prev
    if (pl_prev < #points) pl_prev += 1 else pl_prev = 1

    pl_step = 0
  elseif _dir == -1 and pl_step == 0 then
    pl_prev = pl_next
    if (pl_next > 1) pl_next -= 1 else pl_next = #points

    pl_step = 10
  end


  -- dashing (if not invincible)
  if btnp(5) or btnp(4) then
    if (dget(2) <= 1) sfx(11)

    current_dashes += 1
    total_dashes += 1

    local hit_spike, hit_enemy = false, false
    local target_prev, target_next, old_step = pl_prev, pl_next, pl_step


    -- jumping to other side
    local len_points = #points

    -- on triangles/pentagons,
    -- jump to opposite vertex
    -- instead of the side
    if (len_points % 2 ~= 0) pl_step = 0

    for i=1,#points/2 do
      if (target_prev < #points) target_prev += 1 else target_prev = 1
      if (target_next < #points) target_next += 1 else target_next = 1
    end


    -- hitting enemies, spikes
    local target_step = 10 - pl_step
    local target_x, target_y = calculate_grid_position(target_prev, target_next, target_step)

    local min_enemy_distance

    -- enemies
    for en in all(enemies) do
      if point_line_overlap(pl_x, pl_y, en.x, en.y, target_x, target_y, 2) then
        pl_combo += 1
        pl_combo_timer, hud_combo_y = 110, pl_combo < 4 and 8 or 3

        add_score(150 * (en.type + 1) * mid(1, pl_combo/2, 20))


        -- find closest killed
        -- enemy
        local current_distance = dist(en.x, en.y, pl_x, pl_y)

        if min_enemy_distance == nil
          or current_distance < min_enemy_distance
        then
          min_enemy_distance = current_distance
        end

        kill_enemy(en)

        hit_enemy = true
      end
    end

    if (hit_enemy) accurate_dashes += 1

    -- spikes
    for sp in all(spikes) do
      if point_line_overlap(pl_x, pl_y, sp.x, sp.y, target_x, target_y, 1) then
        -- damage player
        -- if no enemy was
        -- before the spike
        min_enemy_distance = min_enemy_distance or 32767

        if pl_i_frames == 0
          and (min_enemy_distance > dist(sp.x, sp.y, pl_x, pl_y))
        then
          add_player_dash_particle(sp.x, sp.y, 1)

          damage_player(115)

          pl_step = old_step

          accurate_dashes = max(accurate_dashes - 1)

          hit_spike = true
        end

        -- if there was an enemy
        -- the spike gets killed
        if not hit_spike then
          sp.death_timer = 0

          hud_show_message("- spike skip -", "200PTS")

          add_score(200, 8)
          special_heal()
        end
      end
    end

    -- add dash particles
    if not hit_spike then
      add_player_dash_particle(target_x, target_y)

      pl_prev, pl_next, pl_step = target_prev, target_next, target_step
      pl_forward = not pl_forward
    end

    -- combo bonus
    if (pl_combo > 0 and pl_i_frames == 0) pl_combo_timer = mid(0, pl_combo_timer + 18, 110)

    screenshake_x += 1
    screenshake_y += 1
  end


  -- health
  if pl_hp > 0 then
    --pl_hp -= mid(0, pl_speed/1.4, 1.75)
    pl_hp -= pl_speed/1.4
  else
    init_gameover()
  end


  -- combo
  if pl_combo_timer > 0 then
    pl_combo_timer -= 1
  elseif pl_combo_timer <= 0 and pl_combo > 0 then
    if (dget(2) <= 1) sfx(15)
    if (stat(24) < 10 and dget(1) <= 1) music(10, 2000)

    if (pl_combo > 9) init_background()

    if (pl_combo > pl_best_combo) pl_best_combo = pl_combo
    pl_combo = 0
  end


  -- invicibility frames
  if (pl_i_frames > 0) pl_i_frames -= 1


  -- effects
  if _dir ~= 0 and pl_i_frames == 0 then
    add_player_move_particle(pl_x, pl_y)
  end

  update_player_move_particles()
  update_player_dash_particles()

  -- add particles around player
  -- if combo is high enough
  local color = rnd(split("12,3,7,11"))

  if pl_combo > 9 then
    -- play different music
    -- if reactive music is
    -- enabled
    if stat(24) >= 10 and dget(1) <= 1 then
      screenshake_x, screenshake_y = 10, 10
      music(8, 2000)
    end

    add_smoke_particle(rnd2(pl_x - 3, pl_x + 3), pl_y + crnd(5), 0, crnd(2), crnd(3), {color}, 8 + crnd(2) * 2)
    pl_hp += pl_speed/1.4 * 1.85
    
  end
end

function draw_player()
  -- effects
  draw_player_move_particles()
  draw_player_dash_particles()

  -- only draw if player's not
  -- invincible
  if pl_i_frames % 10 == 0 or current_state == "gameover" then
    -- draw high combo effect
    if pl_combo > 9 then
      fillp(0xf0f)
      circfill(pl_x, pl_y, 4, 0xcb)
      fillp()
    end

    -- draw player with origin
    -- at center
    spr(1, pl_x - 3, pl_y - 3)
  end
end

-- functions

-- calculates x,y positions
-- and dx,dy directoins for
-- the player
function calculate_grid_position(prev, next, step)
  local from = points[next]
  local to = points[prev]

  local dx = to.x - from.x
  local dy = to.y - from.y

  local x = flr(from.x + dx * step/10)
  local y = flr(from.y + dy * step/10)

  return x, y, dx, dy
end

-- heals the player by amount
function heal_player(amount)
  pl_hp = min(pl_hp + amount, 640)
end

function special_heal()
  heal_player(125)
  hud_heal_timer, hud_hp_spr = 45, 24
end

-- damages the player by amount
function damage_player(amount)
  if (dget(2) <= 1) sfx(14, 1)

  freezeframe_timer, screenshake_y = 25, 10

  pl_hp -= flr(amount * pl_speed + 0.5)
  if (pl_hp <= 0) init_gameover()

  pl_combo_timer = 0
  pl_i_frames = 40
end

-->8
-- [[ enemies, bullets, spikes ]]

-- [ enemies ]

-- create
function enemy(_x, _y, _type)
  local type=_type or 0

  local en = {
    x = _x,
    y = _y,
    id = #enemies,

    dx = 0,
    dy = 0,
    t = 0,
    max_t = 0,
    type = type,
  }

  if type == 0 then
    en.width, en.height = 5, 5
    en.colors = split("8,8,8,8,8,8,8,2,2,2,2,2,2,1,1")
  elseif type == 1 then
    en.width, en.height = 5, 5
    en.colors = split("10,10,10,10,10,10,10,9,9,9,9,9,9,4,4")
  else
    en.width, en.height, en.shoot_t, en.shoot_max_t = 6, 6, -frnd(12), rnd2(40, 60)
    en.colors = type == 2 and split("12,12,12,12,12,12,12,1,1,1,1,1,1,1,1") or split("11,11,11,11,11,11,11,3,3,3,3,3,3,5,5")
  end

  add(enemies, en)
end

-- update
function update_enemies()
  for en in all(enemies) do
    if en.type == 0 then
      move_enemy(en, 0.1, 47 + crnd(8))
    elseif en.type == 1 then
      move_enemy(en, 1, 22 + crnd(5))
    else
      move_enemy(en, 0.1, 47 + crnd(8))

      if en.shoot_t >= en.shoot_max_t then
        local dx, dy = pl_x - en.x, pl_y - en.y

        local l = sqrt(dx*dx + dy*dy)

        local nx, ny = dx/l*2, dy/l*2

        bullet(en.id, en.x, en.y, nx, ny)
        if (en.type == 3) bullet(en.id, en.x, en.y, -nx/2, -ny/2)
        en.shoot_t = -1
      end

      en.shoot_t += 1
    end

    en.x += en.dx
    en.y += en.dy

    en.t += 1
  end
end

-- draw
function draw_enemies()
  for en in all(enemies) do
    -- draw enemy with origin
    -- at the center

    local x=en.x 
    local y=en.y
    local shoot_t=en.shoot_t

    spr(en.type+2,x-flr(en.width/2),y- flr(en.height/2))

    if (en.type >= 2) circ(x,y,12-shoot_t/en.shoot_max_t*12, shoot_t % 2 == 0 and 10 or 9)
  end
end

-- dispose
function kill_enemy(en)
  if (dget(2) <= 1) sfx(13, 3)

  for i=0,0.75,0.1 do
    add_smoke_particle(en.x, en.y, sin(i) * crnd(3), cos(i) * crnd(3), 2, en.colors, 25 - frnd(4))
  end

  for b in all(enemy_bullets) do
    if (b.id == en.id) del(enemy_bullets, b)
  end

  del(enemies, en)
end

-- moves an enemy by speed
-- every _max_t frames and
-- makes sure that it is inside
-- the grid
function move_enemy(en, speed, _max_t)
  if enemy_inbounds(en) then
    if en.t >= en.max_t then
      en.dx, en.dy = rand_dir()*speed, rand_dir()*speed

      en.t, en.max_t = 0, _max_t
    end
  else
    en.dx, en.dy = direction(64, 64, en.x, en.y)

    en.dx *= speed*1.5
    en.dy *= speed*1.5
  end
end

-- returns if the enemy is
-- inside the grid
function enemy_inbounds(en)
  local x, y, w, h = en.x + en.dx, en.y + en.dy, en.width, en.height
  local w2, h2 = w*2, h*2 -- 2.5

  return inbounds(x - w/2, y - h/2, w2, h2)
    and inbounds(x + w/2, y - h/2, w2, h2)
    and inbounds(x - w/2, y + h/2, w2, h2)
    and inbounds(x + w/2, y + h/2, w2, h2)
end


-- [ enemy bullets ]
enemy_bullets = {}

-- creation
function bullet(_id, _x, _y, _dx, _dy)
  if (dget(2) <= 1) sfx(39)
  add(enemy_bullets, {
    id = _id,
    x = _x,
    y = _y,
    dx = _dx,
    dy = _dy,
    t = 0,
    spr = 8 + frnd(2)
  })
end

-- update
function update_bullets()
  for bu in all(enemy_bullets) do
    if mid(0, bu.x, 127) == bu.x or mid(0, bu.y,127) == bu.y then

      bu.x += bu.dx
      bu.y += bu.dy

      if (pl_i_frames == 0 and box_collision(bu.x - 2, bu.y - 2, pl_x - 3, pl_y - 3, 4, 4, 6, 6)) damage_player(65) del(enemy_bullets, bu)

      if bu.t % 10 == 0 then
        bu.spr = bu.spr == 9 and 10 or 9
        add_smoke_particle(bu.x, bu.y, 0, 0, 2, split("10,10,9,4"), 15)
      end

      bu.t += 1
    else
      del(enemy_bullets, bu)
    end
  end
end

-- draw
function draw_bullets()
  for bu in all(enemy_bullets) do
    -- draws bullets with
    -- outline, origin at the
    -- center
    rectfill(bu.x - 3, bu.y - 3, bu.x + 2, bu.y + 2, 0)
    spr(bu.spr, bu.x-2, bu.y-2)
  end
end


-- [ spikes ]
spikes = {}

-- creation
function spike(_x, _y)
  add(spikes, {
    x = _x,
    y = _y,
    death_timer = 40 + frnd(3) * 60,
    spr = 7,
  })
end

-- update
function update_spikes()
  for sp in all(spikes) do
    local anim_speed = sp.death_timer < 30 and 5 or 30

    if sp.death_timer % anim_speed == 0 then
      if (dget(2) <= 1) sfx(28)
      sp.spr = sp.spr == 7 and 8 or 7
    end

    if sp.death_timer > 0 then
      sp.death_timer -= 1
    else
      for en in all(enemies) do
        if box_collision(sp.x - 10, sp.y - 10, en.x - en.width/2, en.y - en.height/2, 20, 20, en.width, en.height) then
          kill_enemy(en)
        end
      end
      kill_spike(sp)
    end

    -- moves spikes inside the
    -- grid if they get out
    -- by grid effects
    if not spike_inbounds(sp) then
      local dx, dy = direction(64, 64, sp.x, sp.y)

      sp.x += dx * 1.5
      sp.y += dy * 1.5
    end
  end
end

-- draw
function draw_spikes()
  for sp in all(spikes) do
    spr(sp.spr, sp.x - 3, sp.y - 3)
  end
end

-- dispose
function kill_spike(sp)
  if (dget(2) <= 1) sfx(22)

  screenshake_y = 3

  local colors_1 = split("8,8,8,2,2")
  local colors_2 = split("10,10,9,9,4")
  local colors_3 = split("7,7,7,7,6,6,6,5")

  for i=0,10 do
    local colors = frnd(2) == 0 and colors_1 or colors_2

    add_smoke_particle(sp.x + rand_dir() * frnd(7), sp.y + rand_dir() * frnd(7), 0, 0, rnd2(6, 9), colors, 15, -i*2)
    add_smoke_particle(sp.x + rand_dir() * frnd(7), sp.y + rand_dir() * frnd(7), 0, crnd(2), rnd2(5, 7), colors_3, 201, -10)
  end

  del(spikes, sp)
end

-- returns true if a spike
-- is inside the grid
function spike_inbounds(sp)
  local x, y = sp.x, sp.y

  return inbounds(x - 4, y - 4, 8, 8)
    and inbounds(x + 4, y - 4, 8, 8)
    and inbounds(x - 4, y + 4, 8, 8)
    and inbounds(x + 4, y + 4, 8, 8)
end

-->8
-- [[ point/grid handling ]]

-- [ creation ]
function point(_x, _y, _angle)
  local rotated_x, rotated_y = rotate_point(_x, _y, _angle)
  -- target and origins swapped
  -- to get inverse value
  local _dx, _dy = direction(rotated_x, rotated_y, 64, 64)

  return {
    x = rotated_x,
    y = rotated_y,
    dx = _dx,
    dy = _dy,
    t = 0,
  }
end

skew_x_effects = split("3,5,8,10,11")
skew_y_effects = split("4,5,9,10,11")
rotate_left_effects = split("6,8,10")
rotate_right_effects = split("7,9,11")

-- [ update ]
function update_points()
  for pt in all(points) do
    local cos_calc = 1.5 * pl_speed * sin(pt.t/200) / -4

    if (in_table(current_effect, skew_x_effects)) pt.x += cos_calc * pt.dx
    if (in_table(current_effect, skew_y_effects)) pt.y += cos_calc * pt.dy

    if (current_effect or 0) > 5 then
      local _dir = in_table(current_effect, rotate_left_effects) and -1 or 1

      pt.x, pt.y = rotate_point(pt.x, pt.y, 0.002 * _dir * pl_speed)
      pt.dx, pt.dy = rotate_point(pt.dx, pt.dy, 0.002 * _dir * pl_speed, 0)
    end

    pt.t += pl_speed
  end
end

-- [ draw one point ]
function draw_grid(_points)
  if (#_points < 2) return

  -- fill background
  local x1,x2={},{}
  for y=0,127 do
    x1[y],x2[y]=128,-1
  end
  local y1,y2=128,-1

  for i=1, #_points do
    local _next=i+1
    if (_next>#_points) _next=1

    -- alias verts from array
    local vx1=flr(_points[i].x)
    local vy1=flr(_points[i].y)
    local vx2=flr(_points[_next].x)
    local vy2=flr(_points[_next].y)

    if vy1>vy2 then
      local tempx,tempy=vx1,vy1
      vx1,vy1=vx2,vy2
      vx2,vy2=tempx,tempy
    end

    if vy1~=vy2
      and vy1<128
      and vy2>=0
    then
      if vy1<0 then
        vx1=(0-vy1)*(vx2-vx1)/(vy2-vy1)+vx1
        vy1=0
      end

      if vy2>127 then
        vx2=(127-vy1)*(vx2-vx1)/(vy2-vy1)+vx1
        vy2=127
      end

      for y=vy1,vy2 do
        if (y<y1) y1=y
        if (y>y2) y2=y

        x=(y-vy1)*(vx2-vx1)/(vy2-vy1)+vx1

        if (x<x1[y]) x1[y]=x
        if (x>x2[y]) x2[y]=x
      end
    end
  end

  -- render scans
  for y=y1,y2 do
    local sx1=flr(max(0,x1[y]))
    local sx2=flr(min(127,x2[y]))

    local ofs1=flr((sx1+1)/2)
    local ofs2=flr((sx2+1)/2)
    memset(0x6000+(y*64)+ofs1,c,ofs2-ofs1)
    pset(sx1,y,0)
    pset(sx2,y,0)
  end

  local po

  for i, pt in pairs(_points) do
    if i < #_points then
      po = _points[i+1]
    else
      po = _points[1]
    end

    line(pt.x, pt.y, po.x, po.y, 6)
  end

  local target_prev, target_next = pl_prev, pl_next

  if dget(10) == 1 and #_points > 2 and current_state == "game" then
    for i=1,#_points/2 do
      if (target_prev < #_points) target_prev += 1 else target_prev = 1
      if (target_next < #_points) target_next += 1 else target_next = 1
    end

    local x, y = calculate_grid_position(target_prev, target_next, #points % 2 == 0 and 10 - pl_step or 10)

    fillp(0b0101101001011010)
    line(pl_x, pl_y, x, y, 1)
    fillp()
    circfill(x,y,2,1)
  end
end

-- rotate a point by
-- angle around origin
-- (center of the screen if not
-- specified)
function rotate_point(x, y, angle, origin)
  origin = origin or 64

  x -= origin
  y -= origin

  local s, c = sin(angle), cos(angle)

  new_x = x * c - y * s
  new_y = y * c + x * s

  return new_x + origin, new_y + origin
end

-->8
-- [[ shapes ]]

-- format: x,y
-- clockwise from bottom left
shapes = {
  split("16,96,64,16,112,96"), -- triangle
  split("32,96,32,32,96,32,96,96"), -- square
  split("32,96,16,64,64,16,112,64,96,96"), --pentagon
  split("40,96,24,64,40,32,88,32,104,64,88,96"), --hexagon
  split("32,96,16,80,16,48,32,32,96,32,112,48,112,80,96,96") --octagon
}

-->8
-- [[ round handling ]]

-- init: see tab 7: init_game()

-- checks progress and
-- updates round variables
-- accordingly, then triggers
-- a round transition
function new_round()
  local check_enemy_overlap = function(x, y)
    for en in all(enemies) do
      local w, h = en.width, en.height

      if (box_collision(en.x - w, en.y - h, x, y, w * 2, h * 2, 0, 0)) return false
    end

    return true
  end

  local check_spike_overlap = function(x, y)
    for sp in all(spikes) do
      if (box_collision(sp.x - 3, sp.y - 3, x - 3, y - 3, 6, 6, 6, 6)) return false
    end

    for en in all(enemies) do
      local w, h = en.width, en.height

      if (box_collision(x - 3, y - 3, en.x - w, en.y - h, 6, 6, w * 2, h * 2)) return false
    end

    return true
  end


  -- heal player after every round
  hud_heal_timer = 45
  if (hud_heal_spr == 0) hud_heal_spr = 22
  if (hud_hp_spr == 14) hud_hp_spr = 22

  heal_player(ceil(pl_hp/160)*160 - pl_hp)

  -- bonus points if cleared
  -- round in 1 dash
  if current_dashes == 1 and num_of_enemies > 1 then
    hud_show_message("- insta-clear -", "500PTS")

    add_score(500, 10)
    special_heal()
  end


  current_dashes = 0
  pl_forward = false
  pl_i_frames = 0

  -- level definitions
  current_round += 1

  if current_round == next_round then
    current_level += 1

    if current_level == 2 then
      next_round, current_round = rnd2(5, 7), 0

      current_effect_list = split("0,0,1,2")

      current_max_enemy = 1
      num_of_enemies_range = {2,4}

      num_of_spikes_range = {0, 2}
    elseif current_level == 3 then
      next_round, current_round = rnd2(5, 7), 0

      current_effect_list = split("0,0,1,2,3,4")

      current_max_enemy = 1
      num_of_enemies_range = {2,3}

      num_of_spikes_range = {1,2}
      speed_up()
    elseif current_level == 4 then
      next_round, current_round = rnd2(5, 7), 0

      current_effect_list = split("0,1,2,3,4")

      current_max_enemy = 2
      num_of_enemies_range = {3,5}

      num_of_spikes_range = {1,4}
    elseif current_level == 5 then
      next_round, current_round = rnd2(2, 4), 0

      current_effect_list = split("1,2,3,4")

      current_max_enemy = 3
      num_of_spikes_range = {2,3}
    elseif current_level == 6 then
      next_round, current_round = rnd2(2, 6), 0

      current_effect_list = split("1,2,3,4,5,6")

      speed_up()
    elseif current_level == 7 then
      next_round, current_round = rnd2(2, 9), 0

      current_effect_list = split("1,2,5,6,7")

      current_max_enemy = 3
    elseif current_level == 8 then
      next_round, current_round = rnd2(2, 5), 0

      current_effect_list = {1,2}
    else
      next_round, current_round = rnd2(3, 7), 0

      current_effect_list = split("1,2,3,4,5,6,7,8,9,10,11")

      if (current_level % 3 == 0) speed_up()
    end
  end


  -- set up grid effects
  -- (mostly shape++,shape--)
  current_effect = current_effect_list[crnd(#current_effect_list)]

  if current_effect == 1 then
    current_shape = mid(1, current_shape + 1, 5)
  elseif current_effect == 2 then
    current_shape = mid(1, current_shape - 1, 5)
  end


  -- set up points
  next_points = {}
  round_transition_points = {}

  local rotation_effects = split("6,7,8,9,10,11")
  local rotation = 0.25 * frnd(4)
  local sp = shapes[current_shape]

  for i=1, #sp, 2 do
    add(next_points, point(sp[i], sp[i+1], in_table(current_effect, rotation_effects) and 0 or rotation))
    add(round_transition_points, point(64, 64, 0, 0))
  end


  -- add enemies
  enemies = {}
  num_of_enemies = rnd2(num_of_enemies_range[1], num_of_enemies_range[2])

  for i=1, num_of_enemies do
    local x, y = random_entity_position(check_enemy_overlap, next_points)

    enemy(x, y, frnd(current_max_enemy + 1))
  end


  -- add spikes
  spikes = {}

  local num_of_spikes = rnd2(num_of_spikes_range[1], num_of_spikes_range[2])

  for i=1, num_of_spikes do
    local x, y = random_entity_position(check_spike_overlap, next_points)

    spike(x, y)
  end
end

-- tries to create random x,y
-- positions for enemies/spikes
-- inside the grid
function random_entity_position(check_fun, points_table)
  local failsafe, x, y = 0

  repeat
    repeat
      x, y = frnd(128), frnd(128)
    until inbounds(x, y, 20, 20, points_table)

    failsafe += 1
  until failsafe == 14 or check_fun(x, y)

  return x, y
end

-- helper: increases game speed
-- and shows a message
function speed_up()
  hud_show_message("speed up!!", "", 3)
  pl_speed += 0.15
end

-->8
-- [[ game, hud, background ]]

-- [ game ]
-- init everything
function init_game()
  -- player
  -- render positioning
  pl_x = 64
  pl_y = 64
  pl_dx = 0
  pl_dy = 0
  pl_speed = 1

  -- grid positioning
  pl_step = 5
  pl_prev = 1
  pl_next = 3
  pl_forward = false

  -- health
  pl_hp = 640

  -- combo
  pl_combo = 0
  pl_combo_timer = 0
  pl_best_combo = 0


  init_background()

  -- init hud
  hud_top_y = -128
  hud_bottom_y = 250
  hud_combo_outline = 0
  hud_combo_y = 0
  hud_combo_x = -24
  hud_heal_timer = 0
  hud_heal_spr = 0
  hud_hp_spr = 14

  hud_message = ""

  hud_score_offset_x = 0

  current_score = 0

  -- resets every round
  current_dashes = 0
  total_dashes = 0

  -- dashes that hit an enemy
  accurate_dashes = 0

  points = {}

  next_round, current_round = 5 + frnd(3), 0

  current_level = 1
  current_shape = 2

  current_effect_list, current_effect = {}, 0

  current_max_enemy, num_of_enemies_range = 0, {1, 3}
  num_of_spikes_range = {0, 0}

  init_round_transition()

  smoke_particles =
    {}, {}, {}
  player_move_particles, player_dash_particles, enemy_bullets = {}, {}, {}

  freezeframe_timer = 0

  music(-1)

  local music_style = dget(1)

  if music_style < 3 then
    music(10, 4000)
  elseif music_style == 3 then
    music(0, 4000)
  end

  game_t = 0

  init_state_transition("roundtransition")
end

-- update everything
function update_game()
  if #enemies == 0 then
    init_round_transition()
    current_state = "roundtransition"
  end

  update_points()
  update_background()

  if freezeframe_timer == 0 then
    update_player()
    update_enemies()
    update_bullets()
    update_spikes()
  else
    freezeframe_timer -= 1
  end

  update_smoke_particles()
  update_hud()

  game_t += 1
end

-- [ hud ]
-- init: see: tab 7: init_game()

update_hud_smoke_one = split("8,8,8,8,8,8,8,8")
update_hud_smoke_two = split("7,7,7,7,7,7,7,7,7")

-- update
function update_hud()
  -- combo number particles
  if pl_combo > 9 then

    for i=0,pl_combo_timer,50 do
      local angle=i/110*0.25
      local x,y = hud_combo_x-sin(angle)*16,hud_bottom_y-cos(angle)*16

      add_smoke_particle(x+crnd(5), y+rnd2(-2,2), 0, crnd(2), rnd2(3, 4), frnd(2) == 0 and update_hud_smoke_one or update_hud_smoke_two, rnd2(12, 16))
    end

    hud_combo_outline = 7
    hud_hp_spr = 38
  else
    hud_combo_outline = 0

    -- healing effect
    if (hud_heal_timer > 0) hud_heal_timer -= 1 else hud_hp_spr = 14
  end


  -- combo number jump on value change
  if (hud_combo_y > 0) hud_combo_y -= 1


  -- adding score effect
  if (hud_score_offset_x > 0) hud_score_offset_x -= 1


  -- bonus message
  if hud_message ~= "" then
    if hud_msg_t < 100 then
      hud_msg_x = mid(-127, hud_msg_x + hud_msg_dx, 64 - #hud_message*2)
      hud_msg_dx = mid(1, hud_msg_dx * 0.8, 127)

      hud_msg_st_x = mid(-127, hud_msg_st_x + hud_msg_st_dx, 64 - #hud_msg_subtext*2)
      hud_msg_st_dx = mid(1, hud_msg_st_dx * 0.8, 127)
    elseif 100 <= hud_msg_t and hud_msg_t < 165 then
      hud_msg_dx *= 1.5
      hud_msg_x += hud_msg_dx

      hud_msg_st_dx *= 1.25
      hud_msg_st_x += hud_msg_st_dx
    else
      hud_message = ""
    end

    hud_msg_t += 1
  end


  -- dodge player: combo disp.
  if pl_combo > 1 and hud_combo_x < 0 and pl_y < 113 then
    hud_combo_x += 2
  elseif pl_y >= 113 and hud_combo_x < -22 then
    hud_combo_x -= 2
  elseif pl_combo == 0 and hud_combo_x != -22 then
    hud_combo_x = -22
  end

  -- dodge player: top hud
  if pl_y <= 14 then
    if (hud_top_y > -16) hud_top_y -= 2
  else
    if (hud_top_y < 0) hud_top_y += 2
  end

  -- dodge player: bottom hud
  if pl_y >= 113 then
    if (hud_bottom_y < 130) hud_bottom_y += 2
  else
    if (hud_bottom_y > 122) hud_bottom_y -= 2
  end
end

-- draw
function draw_hud()
  -- health display
  for i=0,3 do
    local x, y = 24+19*i, hud_bottom_y

    if (i == flr(pl_hp/160)) x += rand_dir()/2; y += rand_dir()/8

    spr(11, x, y - 1, 3, 1)

    clip(x + 2, y, (pl_hp - 160*i)/10, 8)
    spr(hud_hp_spr, x + 2, y, 2, 1)
    clip()
  end


  -- combo timer
  if pl_combo > 1 then
    for i=0,pl_combo_timer do
      local angle=i/110*0.25
      circfill(hud_combo_x - sin(angle)*16, hud_bottom_y - cos(angle)*16, 3, 0)
    end

    for i=0,pl_combo_timer do
      local angle=i/110*0.25
      circfill(hud_combo_x - sin(angle)*16, hud_bottom_y - cos(angle)*16, 1, 8)
    end


    outline(pl_combo, hud_combo_x + 1, hud_bottom_y - 9 - hud_combo_y, 8, hud_combo_outline)
    outline("chain", hud_combo_x + 1, hud_bottom_y - 1, 8, hud_combo_outline)
  end


  -- score display
  local score = display_score(current_score)

  outline(score, hud_score_offset_x + 64 - #score * 2, hud_top_y)

  if hud_message ~= "" then
    outline(hud_message, hud_msg_x, 8, hud_top_y + 7, hud_msg_color)
    outline(hud_msg_subtext, hud_msg_st_x, hud_top_y + 16)
  end


  -- time display
  print(display_time(game_t), 128 - #display_time(game_t)*4, hud_top_y + 1, 6)
end

-- helper: sets hud message
-- variables to display a
-- message
function hud_show_message(message, subtext, color)
  if (dget(2) <= 1) sfx(27)

  hud_message = message
  hud_msg_color = color or 8
  hud_msg_x = -#message * 4
  hud_msg_dx = 19

  hud_msg_subtext = subtext or ""
  hud_msg_st_x = hud_msg_x * 2
  hud_msg_st_dx = 36.5

  hud_msg_t = 0
end


-- [ background ]
-- init
function init_background()
  background_particles = {}

  if (dget(5) == 3) return

  for x=0,127,10 do
    background_particle(x)
    background_particle(x)
  end
end

-- update
function update_background()
  local combo_mult = 1

  for bp in all(background_particles) do
    if bp.y > 0 then
      bp.y -= (bp.dy+pl_combo*combo_mult)/8
      bp.rad = sin(bp.t/ceil(bp.dy * 100/combo_mult)) * 4

      if pl_combo > 9 and dget(5) <= 1 then
        bp.use_combo = true
        combo_mult = 2
      else
        bp.use_combo = false
        combo_mult = 1
      end

      bp.t += 1
    else
      bp.y = rnd2(128, 135)
    end
  end
end

-- draw
function draw_background()
  for bp in all(background_particles) do
    local color_table = bp.use_combo and bp.combo_colors or {8, 2}

    if pl_combo < 20 then
      circfill(bp.x, bp.y, bp.rad, 0)
      circ(bp.x, bp.y, bp.rad, color_table[bp.rad > 2 and 1 or 2])
    else
      circfill(bp.x, bp.y, bp.rad, color_table[bp.rad > 2 and 1 or 2])
    end
  end
end

-- create new particle
function background_particle(_x)
  local bp = {
    x = _x,
    y = rnd2(130, 257),
    dy = rnd2(1, 2),
    rad = crnd(3),
    t = frnd(10)^2,
    use_combo = false
  }

  bp.combo_colors = rnd({
    {7, 5},
    {11, 3},
    {12, 1}
  })

  add(background_particles, bp)
end

-->8
-- [[ other states ]]

-- [ title screen ]

-- create title letters
function add_title_spinning_letter(_target_x, _target_y, _spr, delay)
  add(title_spinning_letters, {
    x = 128,
    y = 128,
    target_x = _target_x,
    target_y = _target_y,
    spr = _spr,
    rad = 150,
    t = -delay
  })
end

-- update all
function update_title_spinning_letters()
  for sl in all(title_spinning_letters) do
    if sl.t > 0 then
      sl.x = sl.target_x + cos(sl.t/100) * sl.rad
      sl.y = sl.target_y + sin(sl.t/100) * sl.rad

      sl.rad = mid(0, sl.rad - 1.25, 125)
    end

    sl.t += 1.25
  end
end

-- draw all
function draw_title_spinning_letters()
  for sl in all(title_spinning_letters) do
    if sl.t > 0 then
      local y = title_t < 220 and sl.y or sl.y + sin(sl.t/75) * 6

      spr(sl.spr, sl.x, y, 3, 4)
    end
  end
end

-- draw background animation
function draw_menu_background(_t, col1, col2)
  col1 = col1 or 8
  col2 = col2 or 2

  for y = 0, 127, 12 do
    for x = 0, 127, 12 do
      local rad = mid(-1, sin((_t + x + y)/100) * 4, 3)

      circfill(x, y, rad, rad > 2 and col1 or col2)
    end
  end
end


-- [ options screen ]

-- init:
function init_options()
  options_selection = 1

  options_music_style = split("reactive,calm,intense,off")
  options_background = split("reactive,calm,off")
  options_toggle = {"on", "off"}

  options_tiles = {
    new_option_tile(32, "music style:", options_music_style),
    new_option_tile(48, "game sound effects:", options_toggle),
    new_option_tile(64, "smoke:", options_toggle),
    new_option_tile(80, "new round effect:", options_toggle),
    new_option_tile(96, "background:", options_background)
  }

  for i = 1, 5 do
    local value = dget(i)

    if value ~= 0 then
      options_tiles[i].index = value
    end
  end

  options_current = options_tiles[1]

  options_t = 0

  init_state_transition("options")
end

-- create option
function new_option_tile(_y, _header, _values)
  return {
    y = _y,
    header = _header,
    values = _values,
    index = 1,
  }
end


-- [[ help screen ]]

-- init
function init_help()
  help_slide_index = 1
  help_t = 0

  init_state_transition("help")
end

-- [[ game over screen ]]

-- init
function init_gameover()
  music(-1)
  if (dget(2) <= 1) sfx(9)

  if (pl_combo > pl_best_combo) pl_best_combo = pl_combo

  gameover_t = 0

  current_state = "gameover"
end

-- [[ results screen ]]
-- init
function init_results()
  sfx(-1)
  music(26, 3500)

  local accuracy = flr((accurate_dashes/total_dashes)*100)

  results_tiles = {
    new_result_tile("time", game_t, 7),
    new_result_tile("best chain", pl_best_combo, 8),
    new_result_tile("accuracy", accuracy, 9)
  }

  results_tile_index = 1
  results_current_tile = results_tiles[1]

  results_finished_timer = -1

  results_final_score = current_score + shr(pl_best_combo * 500, 16) + shr(accuracy * 250, 16)

  results_t = 0

  if (dget(6) == 0) dset(10, 0)

  init_state_transition("results")
end

function new_result_tile(_header, _goal, _save_index)
  return {
    header = _header,
    content = 0,
    goal = _goal,
    save_index = _save_index,
    x = -127,
    y_offset = 0,
    best = false
  }
end


-- [[ round transition ]]

-- init
function init_round_transition()
  new_round()

  if dget(4) == 2 then
    round_transition_state = "finish"
  else
    round_transition_state = "in"
  end

  round_transition_t = 0
end

-- [[ state transition ]]

-- init
function init_state_transition(_next_state)
  state_transition_r, state_transition_t = 150, 0
  state_transition_colorscheme = frnd(2)
  state_transition_next_state = _next_state

  state_transition_on = true
end

-- update: see at the top
-- of _update60()

-- draw: see at the bottom
-- of _draw()

-->8
-- [[ state management ]]

-- init
reset_pal()

music(-1)
sfx(31)
title_spinning_letters = {}
title_t = 0
title_num_x = 950
title_select_x = 64
title_selection = 0

if (dget(6) == 0) dset(10, 1)

title_stats = {
  "★ hi-score", display_score(dget(6)),
  "⧗ longest time", display_time(dget(7)),
  "◆ highest chain", tostr(dget(8)),
  "∧ best accuracy", tostr(dget(9)).."%"
}

title_stat_displays = {
  {y = 89, t = 10, index = 1, min_index = 1, max_index = 7},
  {y = 89, t = 0, index = 2, min_index = 2, max_index = 8}
}

title_scroll = 0

for i = 0, 3 do
  add_title_spinning_letter(12 + i * 24, 18, 132 + i*3, i*35-5)
  add_title_spinning_letter(12 + i * 24, 18, 26 + i*3, i*35)
end

current_state = "title"
gameover_explosion_color = 1
gameover_colors = {
  split("11,11,11,11,11,11,11,11,11,11,11,11,11,11"),
  split("7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7"),
  split("12,12,12,12,12,12,12,12,12,12,12,12,12,12")
}

-- update
function _update60()
  if state_transition_on then
    if state_transition_t == 147 then
      current_state = state_transition_next_state
    elseif state_transition_t == 267 then
      state_transition_on = false
    end

    state_transition_r -= 3
    state_transition_t += 3
  elseif current_state == "title" then
    --update_title()
    update_title_spinning_letters()

    if (title_num_x > 84) title_num_x -= 4

    if (title_scroll < 20) title_scroll += 0.5 else title_scroll = 0

    -- update stats
    if title_t == 187 and dget(1) < 4 then
      music(27)
    elseif title_t == 221 and dget(1) < 4 then
      music(18)
    elseif title_t > 220 then
      for sd in all(title_stat_displays) do
        local t = sd.t

        if 120 <= t then
          sd.y += 1

          if t == 129 then
            sd.index = sd.index < sd.max_index and sd.index + 2 or sd.min_index
            sd.y = 81
          elseif 138 <= t then
            sd.t = 0
          end
        end

        sd.t += 1
      end
    end


    if (btn(0) and title_select_x > 12) title_select_x -=1
    if (btn(1) and title_select_x < 115) title_select_x +=1

    if (btn(0) or btn(1)) add_player_move_particle(title_select_x, 112)

    title_selection = flr(title_select_x/42)


    if btnp(5) then
      -- skip intro
      if title_t < 220 then
        sfx(-1)

        title_t = 220
        title_num_x = 82

        for sl in all(title_spinning_letters) do
          sl.rad = 0
          sl.t += 200
        end
      elseif title_t > 225 then
        sfx(36)
        if title_selection == 0 then
          init_options()
        elseif title_selection == 1 then
          init_game()
        else
          init_help()
        end
      end
    end


    update_player_move_particles()
    update_player_dash_particles()


    title_t += 1
  elseif current_state == "options" then
    -- select options
    if (btnp(2) and options_selection > 1) sfx(35) options_selection -= 1
    if (btnp(3) and options_selection < 5) sfx(35) options_selection += 1


    -- change values
    options_current = options_tiles[options_selection]

    local len_values = #options_current.values

    if btnp(0) then
      sfx(34)
      if (options_current.index > 1) options_current.index -= 1 else options_current.index = len_values
    elseif btnp(1) then
      sfx(34)
      if (options_current.index < len_values) options_current.index += 1 else options_current.index = 1
    end


    -- save and exit
    if btnp(4) then
      sfx(37)
      for i = 1, 5 do
        dset(i, options_tiles[i].index)
      end

      init_state_transition("title")
    end

    options_t += 1
  elseif current_state == "help" then
    if (btnp(0) and help_slide_index > 1) sfx(34) help_slide_index -= 1
    if (btnp(1) and help_slide_index < 7) sfx(34) help_slide_index += 1

    if (btnp(4)) sfx(37) init_state_transition("title")

    help_t += 1
  elseif current_state == "game" then
    update_game()
  elseif current_state == "gameover" then
    -- hide hud
    if (hud_top_y > -8) hud_top_y -= 1
    if (hud_bottom_y < 130) hud_bottom_y += 1

    if 280 == gameover_t then
      if (dget(2) <= 1) sfx(29)
    elseif 280 < gameover_t and gameover_t < 320 and gameover_t % 10 == 0 then 
     	gameover_explosion_color = (gameover_explosion_color + 1) % 3

      for i=0,1,0.01 do
        local speed = rnd2(1, 3)

        add_smoke_particle(pl_x, pl_y, sin(i) * speed, cos(i) * speed, rnd2(6, 9), gameover_colors[gameover_explosion_color+1], 250 - frnd(10))
      end
    elseif 321 == gameover_t then
      pl_x, pl_y = -5, -5
    elseif 440 == gameover_t then
      init_results()
    end

    update_smoke_particles()

    gameover_t += 1
  elseif current_state == "results" then
    results_current_tile = results_tiles[results_tile_index]

    if results_current_tile.x < 12 then
      results_current_tile.x += 2
    elseif results_current_tile.content < results_current_tile.goal then
      sfx(30, 3)
      results_current_tile.content = mid(0, results_current_tile.content + ceil((results_current_tile.goal - results_current_tile.content)/8), results_current_tile.goal)
      if (results_current_tile.y_offset == 0) results_current_tile.y_offset = 4
    else
      if results_tile_index == 3 then
        results_finished_timer += 1
      else
        results_tile_index += 1
      end
    end

    for rt in all(results_tiles) do
      if (rt.y_offset > 0) rt.y_offset -= 1
    end

    if results_finished_timer == 60 then
      if (results_final_score > dget(6)) dset(6, results_final_score)

      for i = 7, 9 do
        local tile = results_tiles[i - 6]

        if (tile.goal > dget(tile.save_index)) dset(i, tile.goal)
      end
    elseif results_finished_timer > 60 then
      if btnp(5) then
        init_game()
      elseif btnp(4) then
        extcmd("reset")
      end
    end

    results_t += 1
  elseif current_state == "roundtransition" then
    local function no_incomplete_points()
    	for pt in all(points) do
        if (pt.x ~= 64 or pt.y ~= 64) return false
      end

      return true
    end

    if hud_top_y ~= 0 and current_round == 1 and current_level == 1 then
      update_hud()
      return
    end

    if round_transition_state == "in" then
      if (dget(2) <= 1 and round_transition_t == 0) sfx(12)
      for i, pt in pairs(points) do
        local dx = 64 - pt.x
        local dy = 64 - pt.y

        local length = dist(64, 64, pt.x, pt.y)

        if length > 3 then
          local nx, ny = dx/length, dy/length

          pt.x += nx*2*i
          pt.y += ny*2*i
        else
          del(points, pt)
        end
      end

      if (#points == 0 or no_incomplete_points(points)) round_transition_state = "out"
    elseif round_transition_state == "out" then
      local complete

      for i=1, #round_transition_points do
        local np = next_points[i]
        local tp = round_transition_points[i]

        local dx = np.x - tp.x
        local dy = np.y - tp.y

        local length = dist(np.x, np.y, tp.x, tp.y)

        if length > 1 then
          local nx, ny = dx/length, dy/length

          tp.x += nx*2
          tp.y += ny*2

          complete = false
        else
          complete = true
        end
      end

      if (complete) round_transition_state = "finish"
    elseif round_transition_state == "finish" then
      points = next_points

      pl_prev, pl_next = 1, #points
      pl_step = 5

      pl_x, pl_y, pl_dx, pl_dy = calculate_grid_position(pl_prev, pl_next, pl_step)

      freezeframe_timer = 30
      screenshake_x = 5
      player_move_particles, player_dash_particles, enemy_bullets = {}, {}, {}


      for i,en in pairs(enemies) do
        for j=0,9 do
          add_smoke_particle(rnd2(en.x, en.x + en.width), rnd2(en.y - en.height, en.y + en.height), 0, crnd(3), rnd2(2, 4), en.colors, rnd2(6, 25))
        end
      end

      current_state = "game"
    end


    -- effects
    update_hud()
    update_smoke_particles()
    update_background()
    update_player_dash_particles()

    round_transition_t += 1
  end
end

-- draw
function _draw()
  cls()
  
  cam_x, cam_y = frnd(2) == 0 and -1 or 1, frnd(2) == 0 and -1 or 1

  cam_x *= screenshake_x
  cam_y *= screenshake_y

  screenshake_x *= 0.4
  screenshake_y *= 0.4

  camera(cam_x, cam_y)

  if current_state == "title" then
    if title_t > 220 then
      draw_menu_background(title_t)

      outline("DOCZI_DOMINIK ~ 2020-2021", 14, 121, 2)

      rectfill(82,0,127,63,0)

      clip(82, 1, 40, 63)

      for i = title_scroll - 127, title_scroll + 127, 20 do
        line(127 - i, 0, 127 - i, 127, 2)
        line(0, 127 - i, 127, 127 - i, 2)

        line(i, 0, i, 127, 8)
        line(0, i, 127, i, 8)
      end

      clip()

      rectfill(11,96,116,113,0)
      line(12, 97, 115, 97, 7)
      line(12, 112, 115, 112, 7)

      outline("options", 17, 102, title_selection == 0 and 12 or 7, title_selection == 0 and 1)
      outline("begin", 54, 102, title_selection == 1 and 12 or 7, title_selection == 1 and 1)
      outline("help", 92, 102, title_selection == 2 and 12 or 7, title_selection == 2 and 1)

      local stat_header = title_stat_displays[1]
      local stat_content = title_stat_displays[2]
      local stat_content_text = title_stats[stat_content.index]

      clip(12, 89, 103, 8)

      outline(title_stats[stat_header.index], 12, stat_header.y, 2)
      outline(stat_content_text, 115-#stat_content_text*4, stat_content.y, 8)

      clip()

      draw_player_move_particles()
      draw_player_dash_particles()

      spr(1, title_select_x - 3, 109)
    end

    -- draw logo
    rectfill(82,0,title_num_x,63,0)

    sspr(0, 64, 20, 32, title_num_x, 1, 40, 64)
    draw_title_spinning_letters()

    -- white flash after intro
    if 220 <= title_t and title_t <= 225 then
      rectfill(-15,-15,142,142,7)
      screenshake_x, screenshake_y = 15, 15
    end
  elseif current_state == "options" then
    draw_menu_background(options_t, 4, 9)

    sspr(0, 48, 29, 8, 35, 8, 58, 16)

    spr(41, 12 + sin(options_t/75) * 3, options_current.y)

    for ot in all(options_tiles) do
      outline(ot.header, 20, ot.y, 6)

      local display = ot.values[ot.index]
      outline(display, 115 - #display * 4, ot.y, 7, 4)
    end

    outline("⬆️/⬇️ move|⬅️/➡️ change|🅾️ exit", 2, 121)
  elseif current_state == "help" then
    draw_menu_background(help_t, 1, 12)

    sspr(32, 48, 17, 8, 47, 8, 34, 16)

    if help_slide_index == 1 then
      sspr(0, 96, 32, 32, 32, 24, 64, 64)

      outline("use ⬅️/➡️ to move around", 16, 93)
      outline("➡️ rotates clockwise", 24, 101, 12)
      outline("⬅️ rotates counter clockwise", 6, 109, 9)
    elseif help_slide_index == 2 then
      sspr(32, 96, 32, 32, 32, 24, 64, 64)

      outline("press ❎/🅾️ to dash", 26, 93)
      outline("odd shapes: opposite vert.", 8, 101, 12)
      outline("even shapes: opposite side", 8, 109, 9)
    elseif help_slide_index == 3 then
      sspr(64, 96, 32, 16, 32, 24, 64, 32)
      
      outline("your health drains", 28, 60, 8)
      outline("while on the grid", 30, 68)

      outline("dash through enemies to clear", 6, 84, 12)
      outline("the grid and restore health", 10, 92)
    elseif help_slide_index == 4 then
      outline("spikes damage you when you try", 4, 44, 8)
      outline("to dash though them", 26, 52)

      outline("they explode after a short while", 0, 68)
      outline("taking out nearby enemies", 14, 76)
    elseif help_slide_index == 5 then
      sspr(96, 96, 32, 32, 32, 24, 64, 64)

      outline("dash through an enemy before a", 4, 93)
      outline("spike to", 48, 101)
      outline("spike skip!", 42, 109, 9)
    elseif help_slide_index == 6 then
      outline("clear all enemies in a single", 6, 44)
      outline("move to 'insta-clear'", 22, 52, 9)

      outline("this and spike skipping earns", 6, 68)
      outline("extra health and points!", 16, 76, 11)
    elseif help_slide_index == 7 then
      outline("clear enemies quickly to", 16, 44)
      outline("increase your chain", 26, 52, 8)
      outline("and multiply your score!", 16, 60)

      outline("having a big chain will", 18, 76)
      outline("also heal you slowly", 24, 84, 11)
    end

    local sin_calc = sin(help_t/75) * 3

    if (help_slide_index > 1) spr(40,4 + sin_calc, 61)
    if (help_slide_index < 7) spr(41,119 - sin_calc, 61)

    outline("🅾️ go back", 44, 121)
  elseif current_state == "game" then
    draw_background()
    draw_grid(points)
    draw_spikes()
    draw_smoke_particles()
    draw_enemies()
    draw_player()
    draw_bullets()

    draw_hud()
  elseif current_state == "gameover" then
    if 40 < gameover_t then
      local fade_colors = split("0,0,1,1,2,1,5,13,2,4,4,3,1,1,2,5")

      for i=0,15 do
        pal(i, fade_colors[i+1])
      end
    end

    draw_background()
    draw_grid(points)
    draw_spikes()
    draw_smoke_particles()
    draw_enemies()

    draw_hud()

    reset_pal()
    draw_player()
    draw_smoke_particles()
  elseif current_state == "results" then
    local final_string, letters = display_score(results_final_score), {}
    print(final_string, 0, 0, 1)

    for y = 0, 7 do
      letters[y] = {}
      for x = 0, #final_string * 8 - 1 do
        if pget(x, y) == 1 then
          letters[y][x] = {x * 3, y * 3}
        end
      end
    end

    cls()

    if results_finished_timer < 60 then
      draw_menu_background(results_t, 2, 8)
    else
      draw_menu_background(results_t)
    end

    sspr(56, 48, 29, 8, 35, 10, 58, 16)

    for i = 1, 3 do
      local tile = results_tiles[i]
      local x, y = tile.x, 16 + i * 16

      rectfill(x, y, x + 103, y + 8, 0)

      outline(tile.header, x, y)
      line(x, y + 8, x + 103, y + 8, 7)

      local content = tile.content
      local output

      if i == 1 then
        output = display_time(content)
      elseif i == 3 then
        output = tostr(content).."%"
      else
        output = tostr(content)
      end

      local offset, color = 0, 8

      if (content > dget(tile.save_index)) tile.best = true

      if tile.best then
        color = 9
        output = "★ "..output
        offset = 4
      end

      outline(output, x + 103 - #output * 4 - offset, y - tile.y_offset, 7, color)
    end

    if results_finished_timer > 64 then
      local start_x, end_x = 64 - #final_string * 6, 64 + #final_string * 6

      for x = start_x + 1, end_x + 6, 3 do
        local y = 90 - sin((x*4 + results_t) / 75) * 4
        rectfill(x, y, x + 3, y + 17, 0)
      end

      rectfill(0, 83, 127, 110, 0)

      print("final", 1, 85, 2)
      print("score", 108, 104, 2)

      rect(-6, 83, 133, 110, 7)

      for y = 0, 7 do
        local row = letters[y]
        for x, p in pairs(row) do
          local draw_x, draw_y = start_x + p[1], 90 + p[2] + sin((x*4 + results_t) / 75) * 4

          rectfill(draw_x + 2, draw_y, draw_x + 4, draw_y + 2, 7)
        end
      end

      outline("❎ new game   🅾️ to title", 14, 121)
    end

    if 60 <= results_finished_timer and results_finished_timer <= 65 then
      sfx(38)
      screenshake_x, screenshake_y = 5, 5
      rectfill(-5, -5, 132, 132, 7)
    end
  elseif current_state == "roundtransition" then
    draw_background()

    if current_level == 1 and current_round == 1 then
      rectfill(52, 61, 76, 67, rnd({2, 8}))
      spr(54, 52, 61, 4, 1)
      if dget(6) == 0 then
        print("first-timer guide on!", 22, 68, 12)
      end
    end

    if round_transition_state == "in" then
      draw_grid(points)
    else
      draw_grid(round_transition_points)
    end

    draw_player_dash_particles()

    draw_smoke_particles()
    draw_hud()
  end

  if state_transition_on then
    for i = 0, 127 do
      local y = 64 - i
      local x = sqrt(max(state_transition_r^2 - y^2))

      local cos_calc = cos(i / 10 * state_transition_t / 100) * 20

      fillp(0b0101111110101111)
      rectfill(-1, i, 64 - x + cos_calc, i, state_transition_colorscheme == 0 and 0x08 or 0x02)

      fillp(0b1111101011110101)
      rectfill(64 + x + cos_calc, i, 128, i, state_transition_colorscheme == 0 and 0x02 or 0x08)

      fillp()
    end
  end
end

__gfx__
00000000007770008888880000aa000000ccc00000bbb00000eee000000700000008000099990000aaaa000000007777777777777777c0000088888888888888
0000000007111700822228000a99a0000cc1cc000bb3bb000e888e00007560000085e0009aa90000a99a00000007111111111111117c00000888888888888880
0070070071111170822228000a99a000cc111cc0bb333bb0e88888e0068887000e8888009aa90000a99a0000007111111111111117c000008888888888888800
000770007111117082222800a9999a000cc1cc00b33333b0e88888e0758285708587858099990000aaaa000007111111111111117c0000000000000000000000
000770007111117082222800a9999a0000ccc000bb333bb0e88888e00788860008888e0000000000000000007777777777777777c00000000000000000000000
00700700d711175088888800aaaaaa00000000000bb3bb002e888e500065700000e580000000000000000000cccccccccccccccc000000000000000000000000
000000000d77750000000000000000000000000000bbb00002eee500000700000008000000000000000000000000000000000000000000000000000000000000
0000000000ddd0000000000000000000000000000000000000222000000000000000000000000000000000000000000000000000000000000000000000000000
0fffffffffffffffffff000000000000000000000000000000e88e88e88e88e800a9a9a9a9a9a9a9777777777777777700000000777777777777777777777700
ff00f0f0f000f000f00ff00000ff0f0f0fff0fff0ff00000088e88e88e88e8800a9a9a9a9a9a9a90722ccccccccccccc70000000722cccccccccccccccccc700
f0fff0f0f0f0ff0ff0f0f0000f000f0f0f0f00f00f0f000088e88e88e88e8800a9a9a9a9a9a9a900722cccccccccccccc7000000722cccccccccccccccccc700
f0fff000f000ff0ff0f0f0000f000fff0fff00f00f0f000000000000000000000000000000000000722ccccccccccccccc700000722cccccccccccccccccc700
f0fff0f0f0f0ff0ff0f0f0000f000f0f0f0f00f00f0f000000000000000000000000000000000000722cccccccccccccccc70000722cccccccccccccccccc700
ff00f0f0f0f0f000f0f0f00000ff0f0f0f0f0fff0f0f000000000000000000000000000000000000722ccccccccccccccccc7000722cccccccccccccccccc700
0ffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000722cccccccccccccccccc700722cccccccccccccccccc700
00000000000000000000000000000000000000000000000000000000000000000000000000000000722cccccc777722cccccc700722cccccc777777777777700
00000777777777777777770077777777777777777777770000bb0cc77cc0bbbb00fff000fff00000722cccccc700722cccccc700722cccccc700000000000000
00007222ccccccccccccc700722cccccccccccccccccc7000bb0cc7bb7cc0bb00ff7f000f7ff0000722cccccc700722cccccc700722cccccc700000000000000
0007222cccccccccccccc700722cccccccccccccccccc700bbbb0cc77cc0bb00ff7ff000ff7ff000722cccccc700722cccccc700722cccccc700000000000000
007222ccccccccccccccc700722cccccccccccccccccc7000000000000000000f7ff00000ff7f000722cccccc700722cccccc700722cccccc700000000000000
07222cccccccccccccccc700722cccccccccccccccccc7000000000000000000ff7ff000ff7ff000722cccccc700722cccccc700722cccccc777777770000000
7222ccccccccccccccccc700722cccccccccccccccccc70000000000000000000ff7f000f7ff0000722cccccc700722cccccc700722ccccccccccccc70000000
722cccccccccccccccccc700722cccccccccccccccccc700000000000000000000fff000fff00000722cccccc700722cccccc700722ccccccccccccc70000000
722cccccc777777777777700777777722cccccc77777770000000000000000000000000000000000722cccccc700722cccccc700722ccccccccccccc70000000
722cccccc700000000000000000000722cccccc700000000fffffffffffffffffffffffff0000000722cccccc700722cccccc700722ccccccccccccc70000000
722cccccc700000000000000000000722cccccc700000000f000f000f000f00ff0f0f000f0000000722cccccc700722cccccc700722ccccccccccccc70000000
722cccccc700000000000000000000722cccccc700000000f0f0f0fff0f0f0f0f0f0fff0f0000000722cccccc700722cccccc700722ccccccccccccc70000000
722cccccc700000000000000000000722cccccc700000000f00ff00ff000f0f0f000ff00f0000000722cccccc700722cccccc700722cccccc777777770000000
722cccccc777777777777700000000722cccccc700000000f0f0f0fff0f0f0f0fff0fffff0000000722cccccc700722cccccc700722cccccc700000000000000
722cccccccccccccccccc700000000722cccccc700000000f0f0f000f0f0f000f000ff0ff0000000722cccccc700722cccccc700722cccccc700000000000000
722cccccccccccccccccc700000000722cccccc700000000fffffffffffffffffffffffff0000000722cccccc700722cccccc700722cccccc700000000000000
722cccccccccccccccccc700000000722cccccc70000000000000000000000000000000000000000722cccccc700722cccccc700722cccccc700000000000000
722cccccccccccccccccc700000000722cccccc70000000000000000000000000000000000000000722cccccc700722cccccc700722cccccc777777777777700
722cccccccccccccccccc700000000722cccccc70000000000000000000000000000000000000000722cccccc700722cccccc700722cccccccccccccccccc700
722cccccccccccccccccc700000000722cccccc70000000000000000000000000000000000000000722cccccc700722cccccc700722cccccccccccccccccc700
777777777777722cccccc700000000722cccccc70000000000000000000000000000000000000000722cccccc700722cccccc700722cccccccccccccccccc700
000000000000722cccccc700000000722cccccc70000000000000000000000000000000000000000722cccccc700722cccccc700722cccccccccccccccccc700
000000000000722cccccc700000000722cccccc70000000000000000000000000000000000000000722cccccc700722cccccc700722cccccccccccccccccc700
000000000000722cccccc700000000722cccccc70000000000000000000000000000000000000000722cccccc700722cccccc700722cccccccccccccccccc700
000000000000722cccccc700000000722cccccc70000000000000000000000000000000000000000777777777700777777777700777777777777777777777700
777777777777722cccccc700000000722cccccc70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
722cccccccccccccccccc700000000722cccccc70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
722ccccccccccccccccc7000000000722cccccc70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
722cccccccccccccccc70000000000722cccccc70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
722ccccccccccccccc700000000000722cccccc70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
722cccccccccccccc7000000000000722cccccc70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
722ccccccccccccc70000000000000722cccccc70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777770000000000000077777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0fffffffffffffffffffffff0ffff000fffffffffff0fffff0000000fffffffffffffffffff0fffffffff0000000000000000000ffffffffffffffff00000000
ff77f777f777f777ff77f77fff77f000f7f7f777f7f0f777f0000000f777f777ff77f7f7f7f0f777ff77f0000000000000000000ffffff7777777fff00000000
f747f747f474f474f747f747f744f000f7f7f711f7f0f717f0000000f787f788f788f7f7f7f0f878f788f0000000000000000000fffff770000077ff00000000
f7f7f777ff7fff7ff7f7f7f7f777f000f777f77ff7f0f777f0000000f778f77ff777f7f7f7f0ff7ff777f0000000000000000000777777008880077f00000000
f7f7f744ff7fff7ff7f7f7f7f447f000f717f71ff7fff711f0000000f787f78ff887f7f7f7ffff7ff887f000000000000000000072cccc088888007f00000000
f774f7ffff7ff777f774f7f7f774f000f7f7f777f777f7fff0000000f7f7f777f778f877f777ff7ff778f000000000000000000072cccc000088807f00000000
f44ff4f00f4ff444f44ff4f4f44ff000f1f1f111f111f1f000000000f8f8f888f88fff88f888ff8ff88ff000000000000000000072cc72cc0088807f00000000
fffffff00fffffffffffffffffff0000fffffffffffffff000000000ffffffffffff0fffffffffffffff0000000000000000000072cc72cc0888007f00000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000072cc72cc8880077f00000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000072cc72cc880077ff00000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000072cc72cc8007777f00000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000072cc72cc0000007f00000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000072cc72cc8888807f00000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000072cc72cc8888807f00000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000072cc72cc0000007f00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777777777777777f00000000
fffff8888888888fffffffffffffffff111111111111111100000000111111111111111111111100000001111111111111111100111111111111111111111100
ffff880000000088ffffffffffffffff111111111111111110000000111111111111111111111100000011111111111111111100111111111111111111111100
fff88000000000088fffffffffffffff111111111111111111000000111111111111111111111100000111111111111111111100111111111111111111111100
ff8800000000000088ffffffffffffff111111111111111111100000111111111111111111111100001111111111111111111100111111111111111111111100
f880000000000000088fffffffffffff111111111111111111110000111111111111111111111100011111111111111111111100111111111111111111111100
88000000000000000088ffffffffffff111111111111111111111000111111111111111111111100111111111111111111111100111111111111111111111100
80000000000000000008ffffffffffff111111111111111111111100111111111111111111111100111111111111111111111100111111111111111111111100
80000000088000000008ffffffffffff111111111111111111111100111111111111111111111100111111111111111111111100111111111111111111111100
800000008ff800000008ffffffffffff111111111100111111111100111111111100000000000000111111111100000000000000000000111111111100000000
80000008ffff80000008ffffffffffff111111111100111111111100111111111100000000000000111111111100000000000000000000111111111100000000
80000008ffff80000008ffffffffffff111111111100111111111100111111111100000000000000111111111100000000000000000000111111111100000000
80000008ffff80000008ffffffffffff111111111100111111111100111111111100000000000000111111111100000000000000000000111111111100000000
80000008fff880000008ffffffffffff111111111100111111111100111111111111111110000000111111111111111111111100000000111111111100000000
88888888ff8800000008ffffffffffff111111111100111111111100111111111111111110000000111111111111111111111100000000111111111100000000
fffffffff88000000088ffffffffffff111111111100111111111100111111111111111110000000111111111111111111111100000000111111111100000000
ffffffff88000000088fffffffffffff111111111100111111111100111111111111111110000000111111111111111111111100000000111111111100000000
fffffff88000000088ffffffffffffff111111111100111111111100111111111111111110000000111111111111111111111100000000111111111100000000
ffffff88000000088fffffffffffffff111111111100111111111100111111111111111110000000111111111111111111111100000000111111111100000000
fffff88000000088ffffffffffffffff111111111100111111111100111111111111111110000000111111111111111111111100000000111111111100000000
ffff88000000088fffffffffffffffff111111111100111111111100111111111111111110000000111111111111111111111100000000111111111100000000
fff88000000088ffffffffffffffffff111111111100111111111100111111111100000000000000000000000000111111111100000000111111111100000000
ff88000000088fffffffffffffffffff111111111100111111111100111111111100000000000000000000000000111111111100000000111111111100000000
f88000000088ffffffffffffffffffff111111111100111111111100111111111100000000000000000000000000111111111100000000111111111100000000
88000000088fffffffffffffffffffff111111111100111111111100111111111100000000000000000000000000111111111100000000111111111100000000
8000000008ffffffffffffffffffffff111111111100111111111100111111111111111111111100111111111111111111111100000000111111111100000000
80000000088888888888ffffffffffff111111111100111111111100111111111111111111111100111111111111111111111100000000111111111100000000
80000000000000000008ffffffffffff111111111100111111111100111111111111111111111100111111111111111111111000000000111111111100000000
80000000000000000008ffffffffffff111111111100111111111100111111111111111111111100111111111111111111110000000000111111111100000000
80000000000000000008ffffffffffff111111111100111111111100111111111111111111111100111111111111111111100000000000111111111100000000
80000000000000000008ffffffffffff111111111100111111111100111111111111111111111100111111111111111111000000000000111111111100000000
80000000000000000008ffffffffffff111111111100111111111100111111111111111111111100111111111111111110000000000000111111111100000000
88888888888888888888ffffffffffff111111111100111111111100111111111111111111111100111111111111111100000000000000111111111100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ffffffffffffffffffffffffffffff00ffffffffffffffffffffffffffffff00ffffffffffffffffffffffffffffff00ffffffffffffffffffffffffffffff0
0f6666666666666666666666666666f00ffffffffffffffffffffffffffffff00ffffffffffffffffffffffffffffff00ffffffffffffffffffffffffffffff0
0f6ffffffffffffffffffffffffff6f00ffffffffff66fffffffff66fffffff00ffffffffffffffffffffffffffffff00ffffffffffffffffffffffffffffff0
0f6fffffffffffcffffffffffffff6f00fffffffff7777fffffcff66fffffff00ffffffffffffffffffffffffffffff00fffffffffffffffffffcffffffffff0
0f6ffffffffffffcfffffffffffff6f00ffffffff771177fffffcf66fffffff00ffffffffffffffffffffffffffffff00fffffffff7ffff88888fcfff8fff8f0
0f6fffffcccccccccffffffffffff6f00ffffffff771177ccccccc66fffffff00ffffffffffffffffffffffffffffff00ffffffff787fff82228ffcfff8f8ff0
0f6ffffcfffffffcfffffffffffff6f00ffffffff771177fffffcf66fffffff00ffffffffffffffffffffffffffffff00fcccccc78287cc82228ccccfff8fff0
0f6fffcfcccccfcffffffffffffff6f00fffffffff7777fffffcff66fffffff00ffffffffffffffffffffffffffffff00ffffffff787fff82228ffcfff8f8ff0
0f6ffcfccffcccfffffffffffffff6f00ffffffffff66fffffffff66fffffff00fff7777fff7777fff7777fff7777ff00fffffffff7ffff88888fcfff8fff8f0
0f6ffcfccfffccfffffffffffffff6f00ffffffffff66fffffffff66fffffff00ff7887fff7887fff7887fff7887fff00fffffffffffffffffffcffffffffff0
0f6ffcfccffcccfffffffffffffff6f00ffffffffffffffffffffffffffffff00f7777fff7777fff7777fff7777ffff00ffffffffffffffffffffffffffffff0
0f6ffcffcccccffffffffffffffff6f00ffffffffffffffffffffffffffffff00ffffffffffffffffffffffffffffff00ffffffffffffffffffffffffffffff0
0f6ffcfffffffffffffffffff9fff6f00ffffffffffffffffffffffffffffff00ffffffffffffffffffffffffffffff00ffffffffffffffffffffffffffffff0
0f6ff1ffffffffffffffffff999ff6f00ffffffffffffffffffffffffffffff00ffffffffffffffffffffffffffffff00ffffffffffffffffffffffffffffff0
0f6ffffffffffffffffffff9f9f9f6f00ffffffffffffffffffffffffffffff0000000000000000000000000000000000ffffffffffffffffffffffffffffff0
0f6ffffffffffffffffffffff9fff6f00ffffffffffffffffffffffffffffff0000000000000000000000000000000000ffffffffffffffffffffffffffffff0
0f6ffffffffffffffffffffff9fff6f00ffffffffffffffffffffffffffffff0000000000000000000000000000000000ffffffffffffffffffffffffffffff0
0f6ffffffffffffffffffffff9fff6f00fffffffffffffffcffffffffffffff0000000000000000000000000000000000ffffffffffffffffffffffffffffff0
0f6ffffffffffffffffffffff9fff6f00ffffffffffffffcccfffffffffffff0000000000000000000000000000000000fffffffffffffffffffcffffffffff0
0f6fffffffffffffff99999ff9fff6f00fffffffffffffcfcfcffffffffffff0000000000000000000000000000000000fffffff88888ffff7fffcfffffffbf0
0f6ffffffffffffff999ff99f9fff6f00ffffffffffff6ffcff6fffffffffff0000000000000000000000000000000000fffffff82228fff787fffcfffffbff0
0f6ffffffffffffff99fff99f9fff6f00fffffffffff6fffcfff6ffffffffff0000000000000000000000000000000000fcccccc82228cc78287ccccfbfbfff0
0f6ffffffffffffff999ff99f9fff6f00ffffffffff6ffffcffff6fffffffff0000000000000000000000000000000000fffffff82228fff787fffcfffbffff0
0f6fffffffffffffff99999f9ffff6f00fffffffff6fffffcfffff6ffffffff0000000000000000000000000000000000fffffff88888ffff7fffcfffffffff0
0f6ffffffffffffffffffff9fffff6f00ffffffff6ffff77777ffff6fffffff0000000000000000000000000000000000fffffffffffffffffffcffffffffff0
0f6fffffffffffffff49999ffffff6f00ffffffff6fff7711177fff6fffffff0000000000000000000000000000000000ffffffffffffffffffffffffffffff0
0f6fffffffffff7777fffffffffff6f00ffffffff666677111776666fffffff0000000000000000000000000000000000ffffffffffffffffffffffffffffff0
0f6ffffffffff771177ffffffffff6f00ffffffffffff7711177fffffffffff0000000000000000000000000000000000ffffffffffffffffffffffffffffff0
0f6666666666677117766666666666f00fffffffffffff77777ffffffffffff0000000000000000000000000000000000ffffffffffffffffffffffffffffff0
0ffffffffffff771177ffffffffffff00ffffffffffffffffffffffffffffff0000000000000000000000000000000000ffffffffffffffffffffffffffffff0
00000000000000777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000020000000088888880000088888880000008888800000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000088888880000088888880000008888800000000000000000888888888888888888880000000000000000
00000000000000000000000000000000000000000000008888800000008888800000000888000000000000000000888888888888888888880000000000000000
00000000000000000000000000000000000000000000000888000000000888000000000000000000000000000088880000800000000020888800000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088880000800000000020888800000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008888000000800000000020008888000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008888000000800000000020008888000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000888800000000800000000020000088880000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000888822222222222222222222222288880000000000
00000000000000000000000000000000000888000000000888000000000000000000000000000000000088882000000000800000000020000000888800000000
00000000000000000000000000000000008888800000008888800000000888000000000000000000000088882000000000800000000020000000888800000000
00000000000000000000000000000000088888880000088888880000008888800000000000000000008888002000000000800000000020000000008888000000
00000000000000000000000020000000088888880000088888880000008888800000000000000000008888002000000000800000000020000000008888000000
00000000000000000000000000000000088888880000088888880000008888800000000000000000008800002000000000800000000020000000008088000000
00000000000000000000000000000000008888800000008888800000000888000000000000000000008800002000000000800000000020000000008088000000
00000000000000000000000000000000000888000000000888000000000000000000000000000000008800002000000000808888000020000000008088000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000008800002000000000808888000020000000008088000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000008800002000000000880000880020000000008088000000
00000000000077777777777777770000000077777777777777777777770000000777777777777777778877777777777777777777778888888888888888000000
000000000000722ccccccccccccc70000000722cccccccccccccccccc70000007222ccccccccccccc788722cccccccccccccccccc78820000000008088000000
000000000000722cccccccccccccc7000000722cccccccccccccccccc7000007222cccccccccccccc788722cccccccccccccccccc78820000000008088000000
000000000000722ccccccccccccccc700008722cccccccccccccccccc700007222ccccccccccccccc788722cccccccccccccccccc78820000000008088000000
000000000000722cccccccccccccccc70088722cccccccccccccccccc70007222cccccccccccccccc788722cccccccccccccccccc78820000000008088000000
000000000000722ccccccccccccccccc7888722cccccccccccccccccc7007222ccccccccccccccccc788722cccccccccccccccccc78820000000008088000000
000000000000722cccccccccccccccccc788722cccccccccccccccccc700722cccccccccccccccccc788722cccccccccccccccccc78820000000008088000000
000000000000722cccccc777722cccccc788722cccccc777777777777700722cccccc777777777777788777777722cccccc77777778820000000008088000000
000000000000722cccccc788722cccccc788722cccccc708880000000000722cccccc700000000000088000020722cccccc70000888820000000008088000000
000000000000722cccccc708722cccccc708722cccccc700000000000000722cccccc700000000000088888888722cccccc70088880020000000008088000000
000000000000722cccccc700722cccccc700722cccccc700000000000000722cccccc700000000000088888888722cccccc70088882222222222228288000000
000000000000722cccccc700722cccccc700722cccccc700000000000000722cccccc700000000000000000000722cccccc78888000020000000008888000000
000000000000722cccccc700722cccccc700722cccccc777777770000000722cccccc777777777777700000000722cccccc78888000020000000008888000000
000000000000722cccccc700722cccccc700722ccccccccccccc70000000722cccccccccccccccccc700000000722cccccc78800000020000000888800000000
000000000000722cccccc700722cccccc700722ccccccccccccc70000000722cccccccccccccccccc700000000722cccccc78800000020000000888800000000
000000000008722cccccc708722cccccc700722ccccccccccccc70000000722cccccccccccccccccc700000000722cccccc70000000020000088880000000000
000000000088722cccccc788722cccccc708722ccccccccccccc70000000722cccccccccccccccccc700000000722cccccc70000000020000088880000000000
000000000888722cccccc788722cccccc788722ccccccccccccc70000000722cccccccccccccccccc700000000722cccccc70000000020008888000000000000
200000000888722cccccc788722cccccc788722ccccccccccccc70000000722cccccccccccccccccc700000000722cccccc70000000020008888000000000000
000000000888722cccccc788722cccccc788722cccccc777777770000000777777777777722cccccc700000000722cccccc70000000020888800000000000000
000000000088722cccccc788722cccccc708722cccccc700000000000000000000000000722cccccc700000000722cccccc78888888888888800000000000000
000000000008722cccccc708722cccccc700722cccccc700000000000000000000000000722cccccc700000000722cccccc70000000088880000000000000000
000000000000722cccccc700722cccccc700722cccccc700000000000000000000000000722cccccc700000000722cccccc70000000088880000000000000000
000000000000722cccccc700722cccccc700722cccccc700000000000000000000000000722cccccc700000088722cccccc70000008888000000000000000000
000000000000722cccccc700722cccccc700722cccccc777777777777700777777777777722cccccc700000088722cccccc70000008888000000000000000000
000000000000722cccccc700722cccccc700722cccccccccccccccccc700722cccccccccccccccccc700008888722cccccc70000888800000000000000000000
000000000000722cccccc700722cccccc700722cccccccccccccccccc700722ccccccccccccccccc7000008888722cccccc70000888800000000000000000000
880000000008722cccccc700722cccccc700722cccccccccccccccccc700722cccccccccccccccc70000888820722cccccc70088880000000000000000000000
888000000088722cccccc708722cccccc700722cccccccccccccccccc700722ccccccccccccccc700000888820722cccccc70088880000000000000000000000
888800000888722cccccc788722cccccc700722cccccccccccccccccc700722cccccccccccccc7000088880020722cccccc78888000000000000000000000000
888800000888722cccccc788722cccccc700722cccccccccccccccccc700722ccccccccccccc70000088882222722cccccc78888000000000000000000000000
88880000088877777777778877777777770077777777777777777777770077777777777777770000008800002077777777778800000000000000000000000000
88800000008888800000000888000000000000000000000000000000000000000000000000000000008800002000000000808800000000000000000000000000
88000000000888000000000000000000000000000000000000000000000000000000000000000000008800002000000000808888888888888888888888000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000008800002000000000808888888888888888888888000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000008800002000000000800000000020000000008088000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000008800002000000000800000000020000000008088000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000008800002000000000800000000020000000008088000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000008800002000000000800000000020000000008088000000
88000000000000000000000000000000000000000000000000000000000000000000000000000000008800002000000000800000000020000000008088000000
88800000000888000000000000000000000000000000000000000000000000000000000000000000008888888888888888888888888888888888888888000000
88880000008888800000000000000000000000000000000000000000000000000000000000000000008800002000000000800000000020000000008088000000
88880000008888800000000000000000000000000000000000000000000000000000000000000000008800002000000000800000000020000000008088000000
88880000008888800000000000000000000000000000000000000000000000000000000000000000008800002000000000800000000020000000008088000000
88800000000888000000000000000000000000000000000000000000000000000000000000000000008800002000000000800000000020000000008088000000
88000000000000000000000000000000000000000000000000000000000000000000000000000000008888888888888888888888888888888888888888000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000008888888888888888888888888888888888888888000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000888000000000888000000000000000000000000000000
88000000000000000000000000000000000000000000000000000000000000000000000888000000008888800000008888800000000000000000000000000000
88800000000000000000000000000000000000000000000000000000000000000000008888800000088888880000088888880000000000000000000000000000
88800000000000000000000000000000000000000000000000000000000000000000008888800000088888880000088888880000000020000000000000000000
88800000000000000000000000000000000000000000000000000000000000000000008888800000088888880000088888880000000000000000000000000000
88000000000000000000000000000000000000000000000000000000000000000000000888000000008888800000008888800000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000888000000000888000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000888000000000888000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000888000000008888800000008888800000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000008888800000088888880000088888880000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000008888800000088888880000088888880000000020000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000008888800000088888880000088888880000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000888000000008888800000008888800000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000888000000000888000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000888000000000888000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000888000000008888800000008888800000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000008888800000088888880000088888880000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000008888800000088888880000088888880000000020000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000008888800000088888880000088888880000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000888000000008888800000008888800000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000888000000000888000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000888000000000888000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000888000000008888800000008888800000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000008888800000088888880000088888880000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000008888800000088888880000088888880000000020000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000008888800000088888880000088888880000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000888000000008888800000008888800000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000888000000000888000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000888000000000888000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000888000000008888800000008888800000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000008888800000088888880000088888880000000000000000000000000000000000000000000000000000000000000000000020000000
00000000000000000000008888800000088888880000088888880000000020000000000000000000000000000000000000000000000000000000000222000000
00000000000000000000008888800000088888880000088888880000000000000000000000000000000000000000000000000000000000000000000020000000
00000000000000000000000888000000008888800000008888800000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000888000000000888000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
000c0020180530c235004303a324004453c3253c3240c0533c6150c0530044000440002353e5253e5250c1530c0530f244034451b323034453702437522370253c6153e5250334003440032351b3230c0531b323
010c00200c05312235064303a324064453c3253c3240c0533c6150c0530644006440062353e5253e5250c1530c05311244054451b323054453a0242e5223a0253c6153e52503345054451323605436033451b323
010c00202202524225244202432422425243252432422325223252402522420242242222524425245252422522325222242442524326224252402424522220252452524524223252442522227244262432522325
010c0000224002b4202e42030420304203042033420304203042030222294202b2202e420302202b420272202a4202a4222a42227420274202742025421274212742027420274202722027422272222742227222
010c00002a4202a4222a422274202742027422272222742527400254202a2202e4202b2202a426252202a4202742027422274222442024222244222242124421244202442024420244202422024422182210c421
011100200c0330c2150041039604004253b6053a6040c0333c6150c0330042000420002153e5053e5050c1330c0330f224034251b313034253700437502370053c6153e5050332003420032151b3130c0331b313
011100200c03312215064103a304064253c3053c3040c0333c6150c0330642006420062153e5053e5050c1330c03311224054251b313054253a0042e5023a0053c6153e50503325054251321605416033251b313
011100201601518215184101831416415183151831416315163151801516410182141621518415185151821516315162141841518316164151801418512160151851518514163151841516217184161831516315
00110000224002b7252e72530725307253072533725307253072530522297252b0252e725300252b725275252a7252a7222a72227725277252772525721277212772527725277252772527722275122771227712
001100002a7252a7222a722277252772527722270222772527400257252a0252e7252b0252a726250252a7252772527722277222472524022247222272124721247252472524725247252402524722180210c731
0109000015050120300e0200b020070100601005010040100461003610395001c0001b0001b0001a0001a000000003f0003e0003d0003d0003b00039000380003700032000220002200000000000000000000000
000400002677523765207651e74500725007000470004700047000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
011800000c74100775007740c74116205112050d2051020516205282052c20505205042000420018200182021820512200122050a2000a2000a2000a2050a20500200002000d2001420014205002000020000200
010c00001366502435002150c133002000c1000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
010e0000236431b443144330c4230c413004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
010e00000c13109721071110671105111047150010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000000
000c00000030018600001000030000300003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c1530005300353186350c0000c0000023318200003531863530700307000c15300100003530c6350c600047000c05300100307001863518635186450000000000000000000000000000000000000000
011000000222002155021330e13502020020100222002155021330e13502020020100222002155021330e13502020020100222002155021000214502100021552100021000210002100021000210002100021000
011000000e753000000013402134021000c4000e75327000001340213400700007000e7530070000134021340c700007000c0350c0350c0350e1450e1450e1450000000000000000000000000000000000000000
01100000267552673518174267522673226733267550e0001a1741a5521a5422673526715021000c1742675226741025311804518055240651a7651a775267750000000000000000000000000000000000000000
001000002604524025001612604224022181101a1400e000001611a0421a0321a03202063021000c1600e1420e131260001861518625246351a6351a645266550000000000000000000000000000000000000000
000200003f643232333a64121231346411e2312f641172312a63112221246310d2211e63109221186310522111621032110c62101211086250121504625002150261500615000000000000000000000000000000
010f00000c153000000000000000186550000000000000000c1530c1530000000000186550000000000000000c153000000000000000186550000000000000000c1530c153000000000018655186000000000000
010f00000224502265002000e2000e20002265022650e26502400022450226502400024000240002255022550526502400022450226502400024000240002245022550226500400024450246500000021000e100
010f00001a0351a1351a1451a145180351813518145181450c1000c1000c1000c1000000000000000000000024700247002470024700247002470024700247000000000000000000000000000000000000000000
010f000018763187630c7001c700307001876318763247630e70318763187630e7031c7031c70318763187631d7630e70318763187631a7030e7030e703187631876318763107031876318763100000e00018600
010600002474526745297452e7453074532745357453a7453a7003a7353a7003a725300053a7003a7153a00500000000000000000000000000000000000000000000000000000000000000000000000000000000
010800003f02500300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01081c2032251376512a25133641222412e6411b2412564115241216410c2311d631092311963106231166310323112631022310e631012310a63100221086210022104621002210362100211026110021100611
010400001a5441a5441a5441a54421554002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
011000000c6000c6000c6000c6000c600006340262300033006440263300043006540264300033006640265300063101001510015100256002560025600256000000000000000000000000000000000000000000
010400000e713117130e713117130e723117230e723117230e733117330e733117330e743117430e743117430e753117530e753117530e753117530e7531125313000002000e100002000e100002000e10000000
000400000011500115001250012500125001250013500135001350013500145001450014500145001550015500155001550015500155001550015500155181530010000100001000010000100001000010018100
000200003055034530171000c10011100171000c10011100171000c1001110017100051000b1000c100051000b1000c1000e1000e1000e1001110011100111000000000000000000000000000000000000000000
010200002455028530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800002403234032320323703537025370150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800002b03226032280221802118015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d0000113630d363013630322300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000326431a625000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 00424040
00 01424344
01 00024344
00 01024344
00 00024344
00 01024344
00 00034344
00 01044344
00 00034344
02 01044344
00 05424344
00 06424344
01 05074344
00 06074344
00 05074344
00 06074344
00 05084344
02 06094344
01 10111255
00 10111253
00 10111213
00 10111213
00 10111214
00 10111214
00 10111314
02 10111315
03 17181a19
00 5f202144

