pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
-- pengo 0.80
-- 2021 paul hammond

-- debug
--debug_stats=false
version="0.80"

-- cartridge data
cartdata("phammond_pengo_8_p8")

-- constants
tile_size=8
arena_width=15
arena_width_px=120 --arena_width*tile_size
arena_height=15
arena_height_px=120 --arena_height*tile_size

-- movement
d_none=0
d_up=1
d_right=2
d_down=3
d_left=4

xinc={[0]=0,0,1,0,-1}
yinc={[0]=0,-1,0,1,0}

dirrev={[0]=d_none,d_down,d_left,d_up,d_right}

-- enums
gs_titles=0 -- game state
gs_game=3

tm_normal=0 -- title mode
tm_scoring=1

s_playing=0 -- session state
s_lostlife=1
s_levelstart=2
s_diamondslinedup=5
s_levelcomplete=8
s_gameover=9

ps_normal=0 -- player state
ps_pushing=1
ps_dying=99

bs_egg=0 -- bee state
bs_hatching=1
bs_normal=2
bs_dizzy=3
bs_sliding=4
bs_squashing=5
bs_exiting=6

bcs_normal=0 -- bee chase state
bcs_bashing=1
bcs_fleeing=2
bcs_homing=3

et_bee=0 -- entity type
et_slidingblock=1
et_static=99

tt_none=0 -- tile type
tt_block=16
tt_diamond=17
tt_solid=99

-- sfx and music
sfx_slide=0
sfx_buzz=1
sfx_crumble=2
sfx_slidestop=3
sfx_beesquash=4
sfx_snap=5
sfx_bonus=6
sfx_timetable=8
sfx_playerspawn=9

music_titles=1
music_game=40  
music_lifelost=35
music_levelcomplete=36
music_interval=50
music_mazedraw=56
music_gameover=28

-- other
hiscore=dget(0)
input={}

-- titles
title_text="2021 paul hammond (@paulhamx) ◆ testing by finn ◆ many thanks to paul niven (@nivz) for the logo ◆ based on the 1982 sega arcade game ◆ push ice blocks to crush the sno-bees or electrify the boundary by pushing it and then run over the dizzy bees ◆ line up the 3 diamond blocks for bonus points"

function _init()
 -- enable keyboard
 poke(24365,1)

 -- palette
 poke(0x5f2e,1) 
 pal(1,140,1)
 pal(4,1,1)
 pal(5,130,1)
 pal(13,129,1)
 
 -- initialise
 reset_titles()

 -- hi score
 if (hiscore<=0) hiscore=50
end

function reset_titles()
 flash=false
 state=gs_titles
 titlecounter=-40
 titlecounter2=-40
 titlemode=tm_normal

 -- new hi score?
 if player and player.score>hiscore then
  hiscore=player.score

  -- save
  dset(0,hiscore)
 end

 -- initialise game so we can draw behind titles
 --game_reset()

 -- sfx and music
 sfx(-1)
 music(music_titles)
 
 -- transition
 transition:start()
end

function _update60()
 -- counters
 flash=(time()*3)%2<1
 
 -- input (global just cos)
 input_update(input)
 
 -- update
 if state==gs_titles then
  -- titles
  update_titles()
 else
   -- game
  game_update() 

  if (gameover) reset_titles()
 end

 -- transition
 transition:update()
 
 -- quit game?
 if (kb("q")) gameover=true
end

function _draw()
 if state==gs_titles then
  draw_titles()
 else
  game_draw()
 end

 -- transition
 transition:draw()
end

function update_titles()
 -- game in demo mode
 --game_update() 
 
 -- start game?
 if btnp(5) then
  state=gs_game
  game_reset()
 end

 -- counters
 titlecounter=(titlecounter+1)%1500
 titlecounter2+=1
 
 if btnp(4) then
  if titlemode==tm_scoring then
   titlemode=tm_normal
   titlecounter2=0
  else
   titlemode=tm_scoring
   titlecounter2=920
  end
 end
 
 -- switch title modes
 if titlecounter2==240 then
  titlemode=tm_scoring
  
  -- transition
  --transition:start()  
 elseif titlecounter2==1500 then
  titlemode=tm_normal
  titlecounter=-40
  titlecounter2=-40
  
  -- transition
  transition:start()  
 end
end

function draw_titles()
 cls(13)
 
 if titlemode!=tm_normal then
  -- entity scores
  local y=56
  local anim=flr((titlecounter/10)%2)
  
  spr(64+anim,44,y,1,2)
  prints("pengo",60,y+8,12)
  y+=18
  
  spr(52+anim*2,40,y,2,1)
  prints("sno-bee",60,y+3,10)
  y+=12
  
  spr(17+flr((titlecounter/4)%2),44,y)  
  prints("diamond",60,y+3,14)
 end
 
 -- high score
 if(titlecounter2>256) printc("hi "..pad0(hiscore,5).."0",2,8,true)

 -- logo
 spr(144,0,0,16,7)
 
 -- bees
 if titlecounter2<256 then
  rectfill(titlecounter2/2,0,128,64,13)
  fillp(0b0101101001011010.1)
  rectfill(titlecounter2/2-4,0,128,64,13)
  fillp()
 end
 for y=0,5 do
  bee_palette(1+y*2)
  spr(52+2*flr((titlecounter/10)%2),titlecounter2/2-4,y*10,2,1)
  bee_palette()
 end
 
 -- message
 prints(title_text,128-titlecounter,121,12)
 
 -- controls
 if (flash) printc("❎ start",108,7,true)
 
 -- version
 --if (time()<2) print(version,112,1,7)
end
-->8
-- game

function game_reset()
 -- initialise
 gameover=false
 level=0
 lives=3
 
 -- demo?
 demo=state==gs_titles
 --if (demo) level=flr(rnd(4))
 
 -- clear music
 if (not demo) music(-1)
 
 -- objects
 intermissions={} 
 intermission=nil
 player=player_create()

 -- reset level
 game_resetlevel(true)
end

function game_resetlevel(advance)
 -- advance?
 if advance then
  level+=1
  
  -- level properties
  mazegenerator=nil
  
  -- initialise tile map
  tilemap={} 
  for y=1,arena_height do
   tilemap[y]={}
   for x=1,arena_width do
    tilemap[y][x]={type=tt_block,tilex=x,tiley=y,x=(x-1)*tile_size,y=(y-1)*tile_size,frame=16}
   end
  end
  
  -- objects
  entities={}  

  -- properties
  leveltime=0
  lineupcount=0
  bonusawarded=false
  bonusscore=0
  
  -- bee stats
  bees_hatch_delay=0
  bees_hatch_delay_period=max(100,250-level*10)
  bees_bash_delay_period=0
  bees_count=6+flr((level%8)/2)*2
  bees_max_in_play=min(5,3+flr(level/8))
  bees_gone=0
  bees_dizzy_period=max(30,200-level*10)

  bees_in_eggs=bees_count
  bees_in_play=0
  bees_hatching=0
  bees_total=0
 end
 
 -- other
 --message=""
 wallshake=d_none
 wallshakecount=0

 -- objects
 particles={}
 player:resetlevel()
 
 -- finalise
 if advance and not demo then
  game_setstate(s_levelstart)
 else
  game_setstate(s_playing)
 end
 
 -- transition
 --if (advance and not demo) transition:start()
 
 -- sfx
 sfx(-1)
 
 -- level start intermission
 if (advance) add(intermissions,int_levelstart) 
end

function game_setstate(s,c)
 gamestate=s
 gstatecount=c or 0
end

function game_update()
 -- intermission?
 -- note: may be a queue of intermissions to show
 if #intermissions>0 then
  if intermission then
   if intermission.active then
    intermission:update()
   else
    del(intermissions,intermission)
    intermission=nil
    
    -- game over?
    if #intermissions==0 and gamestate==s_gameover then
     gameover=true
    end
   end
  else
   intermission=intermissions[1]
   intermission:start()
  end
  
  return
 end

 if gamestate==s_levelstart then
  -- ###########
  -- level start
  -- ###########
  if gstatecount==1 then
   -- ensure player draws
   player:update()
  elseif gstatecount==30 then
   game_setstate(s_playing)
  end
 elseif gamestate==s_playing then
  -- #######
  -- playing
  -- #######
  if gstatecount==1 then
   --message=""
   
   -- sfx
   --gsfx(sfx_playerspawn,3)   
   
   -- music
   if (not demo) music(music_game)
  end

  -- player
  if (not demo) player:update()
  
  -- counters
  bees_in_eggs=0
  bees_total=0
  bees_in_play=0
  bees_hatching=0
  for e in all(entities) do
   if e.type==et_bee then
    bees_total+=1
    if (e.state==bs_egg) bees_in_eggs+=1
    if (e.state==bs_normal or e.state==bs_dizzy) bees_in_play+=1
    if (e.state==bs_hatching) bees_hatching+=1
   end
  end
  
   -- entities
  for e in all(entities) do
   e:update()
   if (not e.active) del(entities,e)
  end
  
  -- arena
  arena_update()
  
  -- particles
  particles_update()
  
  -- counters
  bees_hatch_delay=move(bees_hatch_delay,0,1)
  bees_bash_delay_period=move(bees_bash_delay_period,0,1)
  
  -- timer
  leveltime+=1/60
  
  -- level cleared?
  if bees_total==0 and #entities==0 and #particles==0 then
   game_setstate(s_levelcomplete)
  end
 elseif gamestate==s_diamondslinedup then
  -- #################
  -- diamonds lined up
  -- #################
  if gstatecount==1 then
   -- bonus score
   --message="super bonus!"
   player_scoreadd(bonusscore)
   bonusawarded=true
   
   -- sfx
   music(-1)
   sfx(sfx_bonus)
  end
  
  if gstatecount==240 then
   -- make all bees dizzy and continue?
   for e in all (entities) do
    if e.type==et_bee and e.state==bs_normal then
     entity_setstate(e,bs_dizzy)
    end
   end

   -- continue
   --message=""
   game_setstate(s_playing)
  end  
 elseif gamestate==s_levelcomplete then
  -- ##############
  -- level complete
  -- ##############
  add(intermissions,int_levelclear)  
 elseif gamestate==s_lostlife then
  -- #########
  -- lost life
  -- #########
  if gstatecount==1 then
   lives-=1
   if lives==0 then
    game_setstate(s_gameover)
   else
    -- return bees to corners
    for e in all(entities) do
     if (e.type==et_bee) e:reset(true)
    end
    
    game_resetlevel(false)
    
    -- transition
    transition:start()

    -- sfx
    music(-1)
   end
  end
 elseif gamestate==s_gameover then
  -- #########
  -- game over
  -- #########
  if gstatecount==1 then
   --message="game over"
   
   -- sfx
   sfx(-1)   
   music(music_gameover)
  elseif gstatecount==380 then
   gameover=true
  end
 end
 
 -- other
 player.displayscore=move(player.displayscore,player.score,2)
 
 -- counters
 gstatecount+=1
end

function game_draw()
 -- intermission?
 if #intermissions>0 then 
  if (intermission and intermission.active) intermission:draw()
  return
 end

 -- intitialise
 cls(0)
 camera(-4,-7)
 
 -- palette
 bee_palette(level) 
 
 -- arena
 arena_draw()

 -- player (behind bees when dying)
 if (not demo and player.state==ps_dying) player:draw()

 -- entities (normal)
 for e in all(entities) do
  if (not e.foreground) e:draw()
 end

 -- player
 if (not demo and player.state!=ps_dying) player:draw()

 -- entities (foreground)
 for e in all(entities) do
  if (e.foreground) e:draw()
 end

 -- palette
 bee_palette() 

 -- bonus starry wall
 if gamestate==s_diamondslinedup then
  pal(1,0)
  local dir=d_right
  local x,y,counter=-4,-4,0
  local c=gstatecount\6
  while(true) do
   x+=xinc[dir]*4
   y+=yinc[dir]*4
   pal(10,10+c%5)
   spr(3,x,y)
   
   counter+=1
   c+=1
   if counter==30 or counter==60 or counter==90 or counter==120 then
    dir+=1
    if (dir==5) dir=1
    if (dir==2) break
   end
  end
  pal(1,1)
  pal(10,10)
 end
 
 -- particles
 particles_draw()
 
 -- finalise
 camera()
 
 -- score panel
 if (not demo) game_draw_scorepanel()
 
 -- message
 --if message then
 -- printc(message,52,8,true)
 --end
 if gamestate==s_diamondslinedup then
  local text=iif(bonusscore==500,"bonus","super bonus")
  printwavy(text,24,8,true)
  printwavy(bonusscore.."0 points",44,14)
 elseif gamestate==s_gameover then
  printwavy("game over",52,8,true)
 end
end

function game_draw_scorepanel()
 pal(1,0)
 camera(0,0)
 
 -- score
 print("p1",1,0,12)
 if flash and player.score>hiscore then
 else
  print(pad0(flr(player.displayscore),5).."0",10,0,8)
 end
 
 -- hi score
 print("hi",38,0,12)
 print(pad0(hiscore,5).."0",47,0,8)
 
 -- level
 spr(2,72,-1)
 print(level,79,0,9)

 --eggs
 for i=0,min(bees_in_eggs,7)-1 do
  spr(4,86+i*3,-1)
 end
 
 -- lives
 for i=1,lives do
  spr(1,124-i*3,-1)
 end
 
 camera()
 pal(1,1)
end



-- arena
function arena_draw()
 -- walls
 if gamestate!=s_diamondslinedup then
  -- normal
  for i=1,4 do
   local wall=wallpos[i]
   if wallshake!=i then
    line(wall[1],wall[2],wall[3],wall[4],7)
   end
  end
  
  if wallshake!=d_none then
   local shake=wallshakepos[wallshake]
   local x,y,dir,l=shake[1],shake[2],shake[3],shake[4]
   
   clip(3,6,122,126)
   fillp(▒)
   
   for i=1,l+2 do
    local offset=cos((((wallshakecount*5)+i)/100))*1.5
    local dx=x+offset*yinc[dir]
    local dy=y+offset*xinc[dir]
    
    rectfill(dx-1,dy-1,dx+1,dy+1,10)
       
    x+=xinc[dir]
    y+=yinc[dir]
   end
   
   fillp()
   clip()
  end
 end
 
 -- blocks
 for y=1,arena_height do
  for x=1,arena_width do
   local t=tilemap[y][x]
   
   if t.type==tt_diamond and lineupcount>1 and gstatecount%8<4 then
    spr(18,t.x,t.y)
   elseif t.type!=tt_none then
    spr(t.frame,t.x,t.y)
    
    -- bee indicator
    if (t.bee and gamestate==s_playing and gstatecount<100) spr(5+(gstatecount\5)%6,t.x,t.y)
   elseif gamestate==s_levelstart and (t.introcounter==nil or t.introcounter<3) then
    -- shrinking block as maze is created
    if (t.introcounter==nil) t.introcounter=0
    spr(27+flr(t.introcounter),t.x,t.y)
    t.introcounter+=0.1        
   end
  end
 end
end

function arena_update()
 for y=1,arena_height do
  for x=1,arena_width do
   local t=tilemap[y][x]
   
   if t.crumblecount!=nil then
    -- crumble
    t.crumblecount-=1
    t.frame=32+(16-t.crumblecount)\2
    if t.crumblecount==0 then
     t.crumblecount=nil
     t.type=tt_none
    end
   end
  end
 end
 
 -- wall shake
 if wallshakecount>0 then
  wallshakecount-=1
  if (wallshakecount==0) wallshake=d_none
 end
end

function arena_destroyblock(t,score)
 if t.crumblecount==nil then
  t.crumblecount=16
 end
 
 -- kill bee?
 if t.bee!=nil then
  t.bee.x=t.x
  t.bee.y=t.y
  entity_setstate(t.bee,bs_squashing)
  
  if score then
   player_scoreadd(50)
   floatingtext_add("50",t.x,t.y)   
  end
 end
end

function arena_canmove(x,y,dir,bashing)
 local testx,testy=x+xinc[dir],y+yinc[dir]
 local tt=arena_gettiletype(testx,testy)

 -- cannot bash a block containing a bee (since this function is only used by bees, not the player)
 return tt==tt_none or (tt==tt_block and bashing and tilemap[testy][testx].bee==nil)
end

function arena_gettiletype(x,y)
 if x>0 and x<=arena_width and y>0 and y<=arena_height then
  return tilemap[y][x].type
 else
  return tt_solid
 end
end

function arena_settiletype(x,y,t)
 if x>0 and x<=arena_width and y>0 and y<=arena_height then
  local tile=tilemap[y][x]
  tile.type=t
  if t==tt_block then
   tile.frame=16
  elseif t==tt_diamond then
   tile.frame=17
  end
 end
end

function arena_getmazedrawdiratpos(x,y)
 local s=self
 
 -- must start on a blank tile
 if (arena_gettiletype(x,y)!=tt_none) return d_none
 
 if arena_gettiletype(x+1,y)==tt_block and arena_gettiletype(x+2,y)==tt_block then
  if (arena_gettiletype(x+1,y+1)==tt_block and arena_gettiletype(x+2,y+1)==tt_block) return d_right
  if (arena_gettiletype(x+1,y-1)==tt_block and arena_gettiletype(x+2,y-1)==tt_block) return d_right
 end

 if arena_gettiletype(x+1,y)==tt_block and arena_gettiletype(x+2,y)==tt_block then
  if (arena_gettiletype(x-1,y+1)==tt_block and arena_gettiletype(x-2,y+1)==tt_block) return d_left
  if (arena_gettiletype(x-1,y-1)==tt_block and arena_gettiletype(x-2,y-1)==tt_block) return d_left
 end

 if arena_gettiletype(x,y+1)==tt_block and arena_gettiletype(x,y+2)==tt_block then
  if (arena_gettiletype(x+1,y+1)==tt_block and arena_gettiletype(x+1,y+2)==tt_block) return d_down
  if (arena_gettiletype(x-1,y+1)==tt_block and arena_gettiletype(x-1,y+2)==tt_block) return d_down
 end

 if arena_gettiletype(x,y-1)==tt_block and arena_gettiletype(x,y-2)==tt_block then
  if (arena_gettiletype(x+1,y-1)==tt_block and arena_gettiletype(x+1,y-2)==tt_block) return d_up
  if (arena_gettiletype(x-1,y-1)==tt_block and arena_gettiletype(x-1,y-2)==tt_block) return d_up
 end
 
 return d_none
end

function arena_generatemaze()
 -- initialise
 if not mazegenerator then
  mazegenerator={
   complete=false,
   mazex=1,
   mazey=arena_height,
   maze3count=0,
   mazedir=iif(rnd(2)>1,d_up,d_right)
  }
 end
 local s=mazegenerator
 
 -- complete?
 if (mazegenerator.complete) return true
 
 -- erase blocks (always erase in lots of 3)
 tilemap[s.mazey][s.mazex].type=tt_none
 if s.maze3count<2 then
  s.mazex+=xinc[s.mazedir]
  s.mazey+=yinc[s.mazedir]
 end
 s.maze3count+=1
 
 -- 3 done?
 if s.maze3count==3 then
  -- reset
  s.maze3count=0
  
  -- must change direction?
  local changedir=arena_gettiletype(s.mazex+xinc[s.mazedir],s.mazey+yinc[s.mazedir])!=tt_block
  
  -- random change of direction?
  if (not changedir and rnd(2)>1) changedir=true
  
  -- change direction
  if changedir then
   local found=false
   
   if s.mazedir==d_right or s.mazedir==d_left then
    -- change to up or down
    if arena_gettiletype(s.mazex,s.mazey+2)==tt_block and rnd(2)>1 then
     s.mazedir=d_down
     found=true
    else
     if arena_gettiletype(s.mazex,s.mazey-2)==tt_block then
      s.mazedir=d_up
      found=true
     elseif arena_gettiletype(s.mazex,s.mazey+2)==tt_block then
      s.mazedir=d_down
      found=true
     end
    end
   else
    -- change to left or right
    if arena_gettiletype(s.mazex+2,s.mazey)==tt_block and rnd(2)>1 then
     s.mazedir=d_right
     found=true
    else
     if arena_gettiletype(s.mazex-2,s.mazey)==tt_block then
      s.mazedir=d_left
      found=true
     elseif arena_gettiletype(s.mazex+2,s.mazey)==tt_block then
      s.mazedir=d_right
      found=true
     end
    end     
   end
   
   -- could not move so pick random position
   if not found then
    for y=arena_height,1,-2 do
     for x=1,arena_width,2 do
      local newdir=arena_getmazedrawdiratpos(x,y)
      if newdir!=d_none then
       s.mazedir=newdir
       s.mazex=x
       s.mazey=y
       found=true
       break
      end
     end
     if (found) break
    end
   end

   -- complete?
   if not found then
    s.complete=true
 
    -- create 3 diamond blocks (not next to walls)
    local i=0
    repeat 
     local	x=2+flr(rnd(arena_width-2))
     local	y=2+flr(rnd(arena_height-2))
     if arena_gettiletype(x,y)==tt_block then
      arena_settiletype(x,y,tt_diamond)
      
      -- check not placing them touching
      if arena_getlineupcount()<2 then
       i+=1
      else
       -- undo
       arena_settiletype(x,y,tt_block)
      end
     end
    until (i==3)

    -- create bees
    i=0
    repeat
     local	x=1+flr(rnd(arena_width))
     local	y=1+flr(rnd(arena_height))
     local t=tilemap[y][x]
     if t.type==tt_block and t.bee==nil then
      i+=1
      
      local b=bee_create(i,t)
      add(entities,b)
     end
    until (i==bees_count)
   end
  end
 end
 
 return mazegenerator.complete
end

function arena_getlineupcount()
 local count=0
 local touchingwall=false
 local touchingdiamond=false
 local linedup=false
 local diamonds={}

 -- count lined up diamond blocks
 for y=1,arena_height do
  for x=1,arena_width do
   local t=tilemap[y][x]
   if t.type==tt_diamond then 
    add(diamonds,t)
    if (arena_istouching(x,y,tt_solid)) touchingwall=true
    if (arena_istouching(x,y,tt_diamond)) touchingdiamond=true
    
    -- lined up horizontally?
    if (arena_gettiletype(x+1,y)==tt_diamond and arena_gettiletype(x+2,y)==tt_diamond) linedup=true
    
    -- lined up vertically?
    if (arena_gettiletype(x,y+1)==tt_diamond and arena_gettiletype(x,y+2)==tt_diamond) linedup=true
   end
  end
 end
 
 if linedup then
  count=3
 elseif touchingdiamond then
  count=2
 end 
  
 return count,touchingwall
end

function arena_istouching(x,y,t)
 return arena_gettiletype(x-1,y)==t or arena_gettiletype(x+1,y)==t or arena_gettiletype(x,y-1)==t or arena_gettiletype(x,y+1)==t
end

function arena_pushwall(dir)
 if (wallshakecount>0) return
 
 wallshake=dir
 wallshakecount=30
 
 -- sfx
 gsfx(sfx_buzz,2)
end



-- player
function player_create()
 local s={
  score=0,
  displayscore=0,
  speed=1/12,
  
  w=8,
  h=8,
  
  draw=player_draw,
  update=player_update,
  updatespecialaction=player_updatespecialaction,
  resetlevel=player_resetlevel
 }

 player_resetlevel(s)
 
 return s
end

function player_resetlevel(s)
 -- reset
 s.x=nil
 s.mazex=9
 s.mazey=7
 s.lerp=0
 s.dir=d_down
 s.pushed=false
 s.trypush=d_none
 
 s.frame=66
 s.flipx=0
 s.spritewidth=1
 s.spriteheight=2
 s.animation={speed=0.1,frames={64,65}}
 
 -- clear/ move vertically if on a block or diamond block
 if tilemap then
  for y=0,2 do
   local t=tilemap[s.mazey+y][s.mazex]
   if t.type==tt_none then
    -- fine
    break
   elseif t.type==tt_diamond then
    -- diamond so can't start here!
    s.mazey+=1
   elseif t.type==tt_block then
    -- melt block
    arena_destroyblock(t,false)
    break
   end
  end
 end

 s.destmazex=s.mazex
 s.destmazey=s.mazey
 entity_calcxy(s)
 
 entity_setstate(s,ps_normal)
end

function player_updatespecialaction(s,action)
 if action=="runleft" then
  s.spritewidth=1
  s.flipx=true   
  s.animation.frames=anim_player_walk[d_left]
  entity_animate(s,true)
  if (s.x) s.x-=0.75
 end
end

function player_update(s)
 if s.state==ps_normal then
  -- ======
  -- normal
  -- ======
  -- move
  local moving=false
  local newdir=input.dir
  
  if newdir!=d_none then
   if s.mazex==s.destmazex and s.mazey==s.destmazey then
    -- aligned so move normally
    local newx=s.mazex+xinc[newdir]
    local newy=s.mazey+yinc[newdir]
    
    s.dir=newdir
    
    local t=arena_gettiletype(newx,newy)
    if t==tt_none then
     s.lerp=0
     s.destmazex=newx
     s.destmazey=newy
    end
   else
    -- can only move between current and dest locations
    if (s.dir==d_up and newdir==d_down) or
       (s.dir==d_down and newdir==d_up) or
       (s.dir==d_left and newdir==d_right) or
       (s.dir==d_right and newdir==d_left) then
     s.dir=newdir
     s.lerp=1-s.lerp
     s.mazex,s.destmazex=s.destmazex,s.mazex
     s.mazey,s.destmazey=s.destmazey,s.mazey
    end
    -- todo:
   end
   
   -- push/ shake wall
   -- note: trypush is to make pushing reliable, even when not tile aligned
   if input.fire2 and newdir!=d_none and not s.pushed then
    s.trypush=newdir
   end

   if s.trypush and s.lerp==0  then
    newdir=s.trypush
    s.trypush=d_none
    
    local tt=arena_gettiletype(s.mazex+xinc[newdir],s.mazey+yinc[newdir])
    local t
    if (tt!=tt_solid) t=tilemap[s.mazey+yinc[newdir]][s.mazex+xinc[newdir]]

    if tt!=tt_none then
     s.dir=newdir    
     entity_setstate(s,ps_pushing)
     if tt==tt_solid then
      -- push wall
      arena_pushwall(newdir)
     elseif tt==tt_none and t and t.bee and t.bee.state==bs_hatching then
      -- bee hatching edge case
      arena_destroyblock(t,true)
     elseif tt!=tt_none and t.crumblecount==nil then
      -- push block
      local t=tilemap[s.mazey+yinc[newdir]][s.mazex+xinc[newdir]]
      local ttplus=arena_gettiletype(s.mazex+xinc[newdir]*2,s.mazey+yinc[newdir]*2)
      if (ttplus!=tt_none and tt==tt_block) or (t.bee and t.bee.state==bs_hatching) then
       -- crumble
       arena_destroyblock(t,true)
       
       -- sfx
       gsfx(sfx_crumble,2)
      elseif ttplus==tt_none then
       -- slide
       slidingblock_add(t,newdir)
      end
     end
    end
   elseif s.lerp==0 then
    s.trypush=d_none
   end
   
   -- ensure fire must be repressed to push (while still keeping the niceties of btn)
   if (not input.fire2) s.pushed=false
  end
  
  -- animate
  s.spritewidth=1
  s.animation.frames=anim_player_walk[s.dir]
  entity_animate(s,s.mazex!=s.destmazex or s.mazey!=s.destmazey)
  s.flipx=s.dir==d_left
 elseif s.state==ps_pushing then
  -- =======
  -- pushing
  -- =======
  if s.statecount==20 then
   entity_setstate(s,ps_normal)
   s.pushed=true
  end
  
  -- animate
  if s.dir==d_left or s.dir==d_right then
   s.spritewidth=2
  else
   s.spritewidth=1
  end
  s.frame=anim_player_push[s.dir][1+(s.statecount)\4]  
  s.flipx=s.dir==d_left
 elseif s.state==ps_dying then
  -- =====
  -- dying
  -- =====
  if s.statecount==1 then
   s.animation.frames=anim_player_dying
   s.animation.pointer=nil
   
   -- sfx
   music(music_lifelost)
  elseif s.statecount==200 then
   game_setstate(s_lostlife)
  end
  
  -- animate
  s.spritewidth=2
  s.spriteheight=1
  entity_animate(s,true,true)
 end
 
 -- lerp
 if (s.mazex!=s.destmazex or s.mazey!=s.destmazey) and s.state==ps_normal then
  s.lerp=move(s.lerp,1,s.speed)
  if s.lerp==1 then
   s.mazex=s.destmazex
   s.mazey=s.destmazey
   s.lerp=0
  end
 end
 
 -- calculate actual (draw) position
 entity_calcxy(s)
 
 -- hit rectangle
 s.hitrect=rectl(s.x+1,s.y+1,6,6) 
 
 -- collision checks
 if s.state!=ps_dying then
  for e in all(entities) do
   if e.type==et_bee and s.hitrect and e.hitrect and rectsoverlap(s.hitrect,e.hitrect) then
    if e.state==bs_normal then
     -- kill player
     entity_setstate(s,ps_dying)
     e.pausecount=60
    elseif e.state==bs_dizzy then
     -- kill bee
     entity_setstate(e,bs_squashing)
      
     -- score
     player_scoreadd(10)
     floatingtext_add("100",e.x,e.y)   
    end
   end
  end
 end
 
 -- counters
 s.statecount+=1 
end

function player_draw(s)
 entity_drawgeneric(s)
end

function player_scoreadd(v)
 local oldscore=player.score
 
 player.score+=v
 
 if (player.score>=3000 and oldscore<3000) or (player.score>=6000 and oldscore<6000) then
  lives+=1
  
  -- sfx
  sfx(sfx_bonuslife)
  
  -- floating text
  if player.state==ps_normal and player.x then
   floatingtext_add("♥",player.x,player.y,8)
  end
  
 end
end



-- particles
function particles_add(x,y,count,colour,large)
 for i=1,count do
  if (#particles>100) return
  
  add(particles,{x=x-4+rnd(4),y=y-4+rnd(4),colour=colour,ttl=30,dx=0.5-rnd(1),dy=-rnd(1),r=iif(large,1+rnd(2),1.5)})
 end
end

function particles_draw()
  for p in all(particles) do
  circfill(p.x,p.y,p.r,p.colour)
 end
end

function particles_update()
 for p in all(particles) do
  p.x+=p.dx
  p.y+=p.dy
  p.dy+=0.03--0.05
  p.r-=0.07
  p.ttl-=1
  if (p.ttl<=0 or p.r<=0) del(particles,p)
 end
end



-- entity
function entity_setstate(s,st,c)
 s.state=st
 s.statecount=c or 0
end

function entity_calcxy(s)
 s.x=(lerp(s.mazex,s.destmazex,s.lerp)-1)*tile_size
 s.y=(lerp(s.mazey,s.destmazey,s.lerp)-1)*tile_size
end

function entity_drawgeneric(s)
 if (s.x==nil or s.frame==nil) return

 local drawx,drawy=s.x,s.y
 if (s.spriteheight==2) drawy-=8 -- 2 x height are bottom-aligned
 if (s.spritewidth==2) drawx-=4  -- 2 x width are centred
 
 spr(s.frame+(s.frameoffset or 0),drawx,drawy,s.spritewidth,s.spriteheight,s.flipx)
 
 -- debug
 --if (s.hitrect) rect(s.hitrect.x,s.hitrect.y,s.hitrect.x+s.hitrect.w-1,s.hitrect.y+s.hitrect.h-1,10)
 --print(s.x..","..s.y,drawx,drawy-1,7)
 --local drawx=(s.mazex-1)*tile_size
 --local drawy=(s.mazey-1)*tile_size
 --rect(drawx,drawy,drawx+7,drawy+7,8)
end

function entity_animate(s,progress,loop)
 local anim=s.animation
 if (loop==nil) loop=true
 if (anim.loopcount==nil) anim.loopcount=0
 
 if anim and anim.frames then
  if (anim.pointer==nil) anim.pointer=0
  
  if (progress) anim.pointer+=anim.speed
  if anim.pointer>=#anim.frames then
   anim.loopcount+=1
   if loop then
    anim.pointer-=#anim.frames
   else
    anim.pointer=#anim.frames-1  
   end
  end
  s.frame=anim.frames[1+flr(anim.pointer)]
 end
end



-- bee
function bee_create(index,tile)
 local corner=1+index%4
 
 local s={
  type=et_bee,
  index=index,
  active=true,
  tile=tile,
  
  w=8,
  h=8,
  speed=1/14,
  speedmultiplier=1,
  
  chasestate=bcs_normal,
  
  cornerx=({1,arena_width,arena_width,1})[corner],
  cornery=({1,1,arena_height,arena_height})[corner],
  
  update=bee_update,
  draw=bee_draw,
  reset=bee_reset
 }
 
 -- attach to tile
 tile.bee=s

 -- reset
 bee_reset(s)
 
 return s
end

function bee_reset(s,resettocorner)
 s.x=nil
 s.hitrect=nil
 
 if resettocorner then
  s.mazex=s.cornerx
  s.mazey=s.cornery
  
  -- destroy block or reposition if on diamond
  local t=tilemap[s.mazey][s.mazex]
  if t.type==tt_block then
   arena_destroyblock(t,false)
  elseif t.type==tt_diamond then
   -- somewhere along the top row will do
   s.mazey=1
   for x=2,arena_width do
    t=tilemap[1][x]
    s.mazex=x
    if t.type==tt_none then
     break
    elseif t.type==tt_block then
     arena_destroyblock(t,false)
     break
    end
   end
  end
 end
 
 s.destmazex=s.mazex
 s.destmazey=s.mazey
 s.lerp=0
 s.dir=d_down
 s.pausecount=0
 
 s.frame=nil
 s.frameoffset=0
 s.flipx=false
 s.spritewidth=1
 s.spriteheight=1

 
 if resettocorner then
  if s.state==bs_hatching or s.state==bs_dizzy or s.state==bs_normal then
   entity_setstate(s,bs_normal)
   s.pausecount=60
  end
 else
  entity_setstate(s,bs_egg)
 end
end

function bee_update(s)
 if s.state==bs_egg then
  -- ===
  -- egg
  -- ===
  -- hatch?
  -- note: delay but still want "max in play" to hatch straight away at start of level
  if bees_in_play+bees_hatching<bees_max_in_play and (bees_hatch_delay==0 or leveltime<0.5) and not s.tile.sliding then
   bees_hatching+=1
   bees_hatch_delay=bees_hatch_delay_period
   entity_setstate(s,bs_hatching)
  end  
  
  -- animate
  s.frame=nil
 elseif s.state==bs_hatching then
  -- ========
  -- hatching
  -- ========
  if s.statecount==1 then
   -- position at tile
   s.mazex=s.tile.tilex
   s.mazey=s.tile.tiley
   s.destmazex=s.mazex
   s.destmazey=s.mazey
   
   -- initialise animation
   s.animation={speed=0.05,frames=anim_bee_hatching}   
  elseif s.animation.loopcount>0 then
   -- melt cube
   if s.tile.type==tt_none then
    -- player has crumbled or pushed block while hatching so kill bee
    arena_destroyblock(s.tile,true)
   else
    arena_destroyblock(s.tile,false)   
    s.tile.bee=nil
    --s.tile.type=tt_none -- plays smoother, e.g., blocks slid against this do not stop
    s.tile=nil
    s.dir=1+flr(rnd(4))
    s.animation.pointer=0
    
    entity_setstate(s,bs_normal)
   end
  end
  
  -- animate
  entity_animate(s,true,false)
  s.spritewidth=1
 elseif s.state==bs_normal then
  -- ======
  -- normal
  -- ======
  -- ai move
  if s.pausecount>0 then
   s.pausecount-=1
  elseif s.lerp==0 then
   local homex,homey=player.mazex,player.mazey
   local newdir=s.dir
   local bashing=(s.chasestate==bcs_bashing or s.chasestate==bcs_fleeing)
   local smart=min(7,level+leveltime/15)
   
   -- normal speed
   s.speedmultiplier=1
   if (leveltime>30) s.speedmultiplier=1.1

   -- start fleeing?
   if bees_total==1 and leveltime>60 and rnd(1)<0.5 then
    s.chasestate=bcs_fleeing
   end

   -- fleeing?
   if s.chasestate==bcs_fleeing then
    smart=8
    homex=s.cornerx
    homey=s.cornery
    s.speedmultiplier=1.5
    
    -- arrived at corner?
    if s.mazex==s.cornerx and s.mazey==s.cornery then
     entity_setstate(s,bs_exiting)
    end
   end
   
   -- home
   if homex>s.mazex and arena_canmove(s.mazex,s.mazey,d_right,bashing) and rnd(10)<smart then
    newdir=d_right
   elseif homex<s.mazex and arena_canmove(s.mazex,s.mazey,d_left,bashing) and rnd(10)<smart then
    newdir=d_left
   elseif homey>s.mazey and arena_canmove(s.mazex,s.mazey,d_down,bashing) and rnd(10)<smart then
    newdir=d_down
   elseif homey<s.mazey and arena_canmove(s.mazex,s.mazey,d_up,bashing) and rnd(10)<smart then
    newdir=d_up
   end

   -- limit complete changes of direction
   if dirrev[newdir]==s.dir then
    if (rnd(10)<3 and arena_canmove(s.mazex,s.mazey,s.dir,bashing)) newdir=s.dir
   end

   -- randomly start bashing?
   if bees_bash_delay_period<=0 and s.chasestate==bcs_normal then
    if level*4+rnd(80+leveltime)>90 then    
     s.chasestate=bcs_bashing
     bees_bash_delay_period=10+rnd(max(0,100-level*3))
    end
   end

   -- move to new target
   if arena_canmove(s.mazex,s.mazey,newdir,bashing) then
    -- tiny pause if changing direction?
    if (newdir!=s.dir and s.chasestate!=bcs_fleeing and rnd(1)>0.5) s.pausecount=max(0,18-level*3) 
   
    s.dir=newdir
    s.destmazex+=xinc[s.dir]
    s.destmazey+=yinc[s.dir]
    
    -- bash block?
    if bashing then
     local t=tilemap[s.destmazey][s.destmazex]
     if t.type==tt_block then
      arena_destroyblock(t,false)
      
      -- half speed
      s.speedmultiplier=0.5
      
      -- force bashing state (so, if fleeing, it animates as a basher)
      s.chasestate=bcs_bashing
     end
    end
   else
    -- try a random direction
    s.dir=1+flr(rnd(4))
    
    -- tiny pause if changing direction?
    if (arena_canmove(s.mazex,s.mazey,newdir,bashing)) s.pausecount=max(0,18-level*3) 
   end
    
   -- end bash?
   if s.chasestate==bcs_bashing and rnd(30)<4 and leveltime<25 then
    s.chasestate=bcs_normal
   end
  end

  -- make dizzy?
  if s.lerp==0 then
   if (wallshake==d_up and s.mazey==1) or
      (wallshake==d_down and s.mazey==arena_height) or
      (wallshake==d_left and s.mazex==1) or
      (wallshake==d_right and s.mazex==arena_width) then
    entity_setstate(s,bs_dizzy)
   end
  end
  
  -- animate
  s.animation.speed=0.1
  s.animation.frames=anim_bee_move[s.dir]
  entity_animate(s,true)
  if s.dir==d_left or s.dir==d_right then
   s.spritewidth=2
  else
   s.spritewidth=1
  end
  s.flipx=s.dir==d_left
  
  if s.chasestate==bcs_bashing then
   s.frameoffset=64
  elseif s.chasestate==bcs_fleeing then
   s.frameoffset=48
  else
   s.frameoffset=0
  end
 elseif s.state==bs_dizzy then
  -- =====
  -- dizzy
  -- =====
  if s.statecount==1 then
   s.animation={speed=0.25,frames=anim_bee_dizzy}     
   s.flipx=false   
   s.spritewidth=1
  elseif s.statecount>=bees_dizzy_period then
   entity_setstate(s,bs_normal)
  end
  
  -- animate
  entity_animate(s,true)
  s.frameoffset=0
 elseif s.state==bs_sliding then
  -- =======
  -- sliding
  -- =======
  local sb=s.slidingblock
  s.x=sb.x+xinc[sb.dir]*8
  s.y=sb.y+yinc[sb.dir]*8
  s.x=mid(0,s.x,arena_width_px)
  s.y=mid(0,s.y,arena_height_px)
 elseif s.state==bs_squashing then
  -- =========
  -- squashing
  -- =========
  if s.x==nil then
   -- position not yet calculated, e.g., bee was in egg or hatching
  else
   s.active=false
   
   -- particles
   particles_add(s.x+4,s.y+4,10,8,true)
   
   -- sfx
   sfx(sfx_beesquash)
  end
 elseif s.state==bs_exiting then
  -- =======
  -- exiting
  -- =======
  if s.statecount==1 then
  elseif s.statecount==50 then
   -- escaped
   s.active=false
  else
   -- animate
   s.spritewidth=1
   s.frame=15-s.statecount\10
   s.frameoffset=0
  end
 end

 -- lerp
 if s.pausecount<=0 and s.mazex and s.state==bs_normal then
  if s.mazex!=s.destmazex or s.mazey!=s.destmazey then
   s.lerp=move(s.lerp,1,s.speed*s.speedmultiplier)
   if s.lerp==1 then
    s.mazex=s.destmazex
    s.mazey=s.destmazey
    s.lerp=0
   end
  end
 end
 
 -- calculate actual (draw) position
 if s.mazex and s.state!=bs_sliding then
  entity_calcxy(s)
 end

 -- hit rectangle (centred)
 if (s.x) s.hitrect=rectl(s.x+1,s.y+1,6,6) 
 
 -- counters
 s.statecount+=1  
end

function bee_destroy(s)
 s.active=false
 
 -- particles
 particles_add(s.x,s.y,12,8,false)

 -- sfx
 sfx(sfx_explode1,2)
end

function bee_draw(s)
 if s.state==bs_dizzy and s.statecount>bees_dizzy_period-90 and s.statecount%20<10 then
  pal(9,1)
 end
 
 entity_drawgeneric(s)
end



-- sliding block
function slidingblock_add(tile,dir)
 local s={
  type=et_bird,
  active=true, 
  tile=tile,
  x=tile.x,
  y=tile.y,
  w=8,
  h=8,
  speed=3,
  dir=dir,
  frame=tile.frame,
  trail={},
  statecount=0,
  bees={},
  
  update=slidingblock_update,
  draw=slidingblock_draw,
 }
 
 -- blank out tile being pushed
 tilemap[tile.tiley][tile.tilex]={type=tt_none,tilex=tile.tilex,tiley=tile.tiley,x=tile.x,y=tile.y}
 
 -- calculate target tile and position
 local tx,ty=tile.tilex,tile.tiley
 while(true) do
  tx+=xinc[dir]
  ty+=yinc[dir]
  local tt=arena_gettiletype(tx,ty)
  if tt==tt_none then
   s.targettile=tilemap[ty][tx]
  else
   break
  end
 end
 s.targetx=s.targettile.x
 s.targety=s.targettile.y
 
 -- ensure bee won't attempt to hatch while sliding
 tile.sliding=true

 -- add
 add(entities,s)
 
 -- sfx
 gsfx(sfx_slide,2)
 
 return s
end

function slidingblock_update(s)
 -- move
 s.x=move(s.x,s.targetx,s.speed)
 s.y=move(s.y,s.targety,s.speed)
 
 -- add to trail
 if s.statecount%2==1 then
  add(s.trail,{x=s.x,y=s.y})
  if (#s.trail>6) del(s.trail,s.trail[1])
 end
 
  -- hit rectangle
 s.hitrect=rectl(s.x+1,s.y+1,7,7) 

 -- collision checks
 for e in all(entities) do
  if e.active and e.type==et_bee and (e.state==bs_normal or e.state==bs_dizzy) and rectsoverlap(e.hitrect,s.hitrect) then
   entity_setstate(e,bs_sliding)
   e.slidingblock=s
   add(s.bees,e)
  end
 end
 
 -- done?
 if s.x==s.targetx and s.y==s.targety then
  s.active=false
  
  -- replace target tile
  -- note: we do this since the tile could have additional properties like hosting a bee egg
  local tt=s.targettile
  tilemap[tt.tiley][tt.tilex]=s.tile
  s.tile.x=tt.x
  s.tile.y=tt.y
  s.tile.tilex=tt.tilex
  s.tile.tiley=tt.tiley
  s.tile.sliding=false  
  
  -- score bees
  for b in all(s.bees) do
   entity_setstate(b,bs_squashing)
  end
  local v=0
  if #s.bees==1 then
   v=40
  elseif #s.bees==2 then
   v=160
  elseif #s.bees==3 then
   v=320
  elseif #s.bees>=4 then
   v=640
  end
  if v>0 then
   player_scoreadd(v)
   floatingtext_add(v.."0",s.x,s.y)   
  end
  
  -- recalculate tile line ups
  local touchingwall
  lineupcount,touchingwall=arena_getlineupcount()
  if lineupcount==3 and not bonusawarded then
   bonusscore=iif(touchingwall,500,1000)
   game_setstate(s_diamondslinedup)
  end
  
  -- sfx
  gsfx(sfx_slidestop,2)
 end
 
 -- counters
 s.statecount+=1
end

function slidingblock_draw(s)
 -- trail
 fillp(▒)
 local r=3
 for i=#s.trail,1,-1 do
  local t=s.trail[i]
  circfill(t.x+4,t.y+4,min(r,4),2)
  r-=0.5
 end
 fillp()
 
 spr(s.frame,s.x,s.y)
end



-- floating text
function floatingtext_add(text,x,y,c)
 local s={
  type=et_static,
  active=true, 
  foreground=true,
  text=text,
  x=x,
  y=y,
  c=c,
  statecount=0,
  
  update=floatingtext_update,
  draw=floatingtext_draw,
 }

 -- add
 add(entities,s)
 
 return s
end

function floatingtext_update(s)
 s.y-=0.25
 
 -- counters
 s.statecount+=1
 
 if (s.statecount==72) s.active=false
end

function floatingtext_draw(s)
 local c=s.c or 7
 if (s.statecount>40 and not s.c) c=fade_colours[1+(s.statecount-40)\8]
 prints(s.text,s.x,s.y,c)
end
-->8
-- helper

function gsfx(s,c)
 if (not demo) sfx(s,c)
end

function rectl(x,y,w,h)
 return {x=x,y=y,w=w,h=h}
end

function rectc(x,y,w,h)
 return {x=x-w/2,y=y-h/2,w=w,h=h}
end

function pad0(n,l)
 local s="0000000000"..n
 return sub(s,#s-l+1)
end

function padspace(n,l)
 local s="          "..n
 return sub(s,#s-l+1)
end

function lerp(a,b,t) 
 return a*(1-t)+b*t
end

function kb(k)
 return stat(30) and stat(31)==k
end

function lerp(a,b,t) 
 return a*(1-t)+b*t
end

function iif(c,t,f)
 if c then
  return t
 else
  return f
 end
end

function move(c,d,s)
 if (c<d) return min(c+s,d)
 if (c>d) return max(c-s,d)
 return c
end

function printc(s,y,c,shad,sc)
 -- detect wide characters
 local offx=0
 for i=1,#s do
  if (ord(sub(s,i,i))>134) offx+=2
 end

 local x=64-offx-#s*2
 if shad then
  prints(s,x,y,c,sc) 	
 else
  ? s,x,y,c
	end
end

function prints(s,x,y,c,sc)
 for y1=-1,1 do
  for x1=-1,1 do
   ? s,x+x1,y+y1,sc or 0
  end
 end

	? s,x,y,c
end

function printwavy(s,y,c,large)
 for i=1,#s do
  if large then
   prints("\^w\^t"..sub(s,i,i),(56-#s*4)+i*8,y+cos((2*i+time()*60)/40)*4,c,true)
  else
   prints(sub(s,i,i),(60-#s*2)+i*4,y+cos((2*i+time()*60)/40)*4,c,true)  
  end
 end
end

function rectsoverlap(e1,e2,e1offsetx,e1offsety)
 if (e1offsetx==nil) e1offsetx=0
 if (e1offsety==nil) e1offsety=0
 return (e1.x+e1offsetx)<e2.x+e2.w and e2.x<e1.x+e1.w+e1offsetx and (e1.y+e1offsety)<e2.y+e2.h and e2.y<e1.y+e1.h+e1offsety
end

function distance(e1,e2)
 local dx=e1.x-e2.x
 local dy=e1.y-e2.y
 return sqrt(dx^2+dy^2)
end



-- input
function input_update(s)
 s.moved=false
 local olddir=s.dir
 
 s.up=btn(2)
 s.down=btn(3)
 s.left=btn(0)
 s.right=btn(1)
 s.fire1=btn(4)
 s.fire2=btn(5)
 s.fire1hit=s.fire1 and not s.fire1old
 s.fire2hit=s.fire2 and not s.fire2old
 
 if s.up then
  s.dir=d_up
 elseif s.right then
  s.dir=d_right
 elseif s.down then
  s.dir=d_down
 elseif s.left then
  s.dir=d_left
 else
  s.dir=d_none
 end
 
 s.moved=s.dir!=olddir
 s.fire1old=s.fire1
 s.fire2old=s.fire2
 
 -- fire 2 held down n/a if moving
 if (s.fire2downtime==nil) s.fire2downtime=0
 if s.fire2 and s.dir==d_none then
  s.fire2downtime+=1 
 else
  s.fire2downtime=0
 end
end
-->8
-- effects

-- transition
transition={
 
 start=function(self,colour) 
  self.value=-8
 end,
 
 draw=function(self)
  if self.value<128 then
   fillp(0b0101101001011010.1)
   rectfill(0,self.value,128,128,0)
   fillp()
   rectfill(0,self.value+8,128,128,0)
  end
 end,
 
 update=function(self)
  if (self.value<128) self.value+=3
 end
}
-->8
-- intermissions

-- ###########
-- level clear
-- ###########
int_levelclear={
 active=false,
 
 start=function(s)
  s.active=true
  s.counter=0
  s.dancebreak=level%2==0 -- dance break every 2 levels
  s.playeronscreen=player.x!=nil
  
  -- calculate time bonus
  s.bonusindex=6
  if leveltime<20 then
   s.bonusindex=1
  elseif leveltime<30 then
   s.bonusindex=2
  elseif leveltime<40 then
   s.bonusindex=3
  elseif leveltime<50 then
   s.bonusindex=4
  elseif leveltime<60 then
   s.bonusindex=5
  end
  s.bonusscores=split("500,200,100,50,1,0")
  s.bonusscore=s.bonusscores[s.bonusindex]
  
  -- create disco circles
  s.circles={}
  if s.dancebreak then
   for y=0,10 do
    for x=0,10 do
     local r=sin((x+y*cos(y/10))/10)*5
     local gd=0.25
     local c=4
     if r<1.5 then
      c=5
     end
     add(s.circles,{x=4+x*12,y=4+y*12,r=r,c=c,gd=gd})
    end
   end
  end
  
  -- rhythm hits
  s.hit=1
  
  -- baby penguins
  s.penguins={}
  for i=1,4 do
   local p={x=-76+i*12,y=104,c1=(split("14,10,1,9"))[i],c2=(split("2,9,4,5"))[i],spriteheight=2,flipx=false}
   add(s.penguins,p)
  end
  s.dance=dances[1+((level-1)\2)%#dances]
  s.danceindex=-1
  s.dancemove=""
  s.dancecounter=0
  s.danceanimcounter=0
   
  -- music
  music(music_levelcomplete)
 end,
 
 draw=function(s)
  if (not s.active) return
  
  if s.playeronscreen then
   -- =========================
   -- player running off screen
   -- =========================
   cls(0)
   camera(-4,-7)
   arena_draw()
   rectfill(-4,-7,127,s.counter*2,0)
   player:draw()
   entity_drawgeneric(player)
   camera()   
  else
   -- =====================
   -- stats and dance break
   -- =====================
   cls(13)

   if s.dancebreak then
    -- disco circles
    for c in all(s.circles) do
     local r=c.r*s.hit
     local cl=c.c
     if cl==4 and s.counter<580 then
      if s.hit>2.8 then
       cl=7
      elseif s.hit>2.5 then
       cl=1
      end
     end
     circfill(c.x,c.y,r,cl)
    end
    
    -- baby penguins
    for p in all(s.penguins) do
     pal(8,p.c1)
     pal(2,p.c2)
     entity_drawgeneric(p)
     pal(8,8)
     pal(2,2)
    end
   end
   
   -- bonus
   printwavy(flr(leveltime).." seconds",24,14)  
   printwavy(iif(s.bonusscore==0,"no bonus","bonus "..s.bonusscore.."0"),8,8,true)
   
   -- score table
   local l=0
   for i=1,6 do
    local c=iif(i==s.bonusindex,10,7)
    local h=iif(i==1,l+19,l+9)
    local text=pad0(l,2).." to "..pad0(h,2).." "..padspace(s.bonusscores[i],5).."0 pts"
    if (i!=s.bonusindex or flash) printc(text,32+i*9,c,true)
    l=h+1
   end
  end
 end,
  
 update=function(s)
  if (not s.active) return
  
  s.counter+=1
   
  if s.playeronscreen then
   -- =========================
   -- player running off screen
   -- =========================
   if s.counter>64 then
    player:updatespecialaction("runleft")
    if player.x!=nil and player.x<-32 and s.counter>160 then
     s.playeronscreen=false
     
     -- music
     if s.dancebreak then
      music(music_interval)
     else
      sfx(sfx_timetable)
     end
     s.counter=0
    end
   end
  else
   -- =====================
   -- stats and dance break
   -- =====================
   if s.dancebreak then 
    -- disco circles
    for c in all(s.circles) do
     c.r+=c.gd
     if c.r>=6 then
      c.gd=abs(c.gd)*-1
     elseif c.r<1.5 then
      c.gd=abs(c.gd)
     end
    end
    
    -- baby penguins dance
    if s.dancecounter<=0 and s.counter>60 then
     s.danceindex+=2
     s.danceanimcounter=0    
     
     if s.danceindex>=#s.dance then
      s.dancemove=""
     else
      s.dancemove=s.dance[s.danceindex]
      s.dancecounter=s.dance[s.danceindex+1]
     end
    end
    
    if s.dancecounter>0 then
     local anim2,anim5=(s.danceanimcounter\8)%2,(s.danceanimcounter\8)%5
     s.danceanimcounter+=1
     
     for p in all(s.penguins) do
      if s.dancemove=="wr" then
       -- walk right
       p.x+=0.5
       p.frame=64+anim2
       p.flipx=false
       p.spritewidth=1
      elseif s.dancemove=="wl" then
       -- walk left
       p.x-=0.5
       p.frame=64+anim2
       p.flipx=true
       p.spritewidth=1
      elseif s.dancemove=="pr" then
       -- push right
       p.frame=anim_player_push[d_right][1+anim5]
       p.flipx=false
       p.spritewidth=2
      elseif s.dancemove=="pl" then
       -- push left
       p.frame=anim_player_push[d_left][1+anim5]
       p.flipx=true
       p.spritewidth=2
      elseif s.dancemove=="f" then
       -- front walk
       p.frame=70+anim2
       p.flipx=true
       p.spritewidth=1
     elseif sub(s.dancemove,1,2)=="sj" then
       -- star jump
       p.frame=74+anim2*2
       p.flipx=false
       p.spritewidth=2 
       if (s.dancemove=="sjr") p.x+=0.5
       --if (s.dancemove=="sjl") p.x-=0.5
     elseif sub(s.dancemove,1,2)=="pw" then
       -- penguin waddle
       p.frame=44+anim2*2
       p.flipx=false
       p.spritewidth=2 
       if (s.dancemove=="pwr") p.x+=0.5
       --if (s.dancemove=="pwl") p.x-=0.5       
      end
     end
     
     s.dancecounter-=0.5
    end

    -- rhythm hits
    s.hit=move(s.hit,1,0.2)    
    if s.counter%36==15 then
     s.hit=3
    end
    
    if btnp(5) then
     s.hit=2
     printh(s.counter)
    end
   end
   
   -- done?
   if s.counter>=iif(s.dancebreak,680,200) then
    s.active=false
    
    -- award bonus
    player_scoreadd(s.bonusscore)
    
    -- next level
    game_resetlevel(true)     
   end
  end
 end
}


-- ###########
-- level start
-- ###########
int_levelstart={
 active=false,
 
 start=function(s)
  s.active=true
  s.counter=0
  s.animation={speed=0.15,frames=anim_pengo_peek}
  s.frame=nil
  
  -- transition
  transition:start()
  
  -- music
  music(music_mazedraw)
 end,
 
 draw=function(s)
  if (not s.active) return
  
  cls(13)
  camera(-4,-7) 
  
  -- arena
  arena_draw()
  
  -- pengo peek
  if (s.frame) spr(s.frame,8*tile_size,6*tile_size)
  
  camera()
   
  -- text
  printwavy("act "..level,24,8,true)
  printwavy("get ready!",44,14)
 end,
  
 update=function(s)
  if (not s.active) return
  
  s.counter+=1

  -- pengo peek
  if arena_gettiletype(9,7)==tt_none and s.counter>140 then
   entity_animate(s,true,false)
  end
   
  -- generate maze
  if arena_generatemaze() and s.counter>=240 and s.frame==135 then
   s.active=false
    
   -- sfx
   sfx(sfx_snap)
   
   --transition:start()
  end
 end
}
-->8
-- data
wallpos={{-1,-1,arena_width_px,-1},
         {arena_width_px,-1,arena_width_px,arena_height_px},
         {-1,arena_height_px,arena_width_px,arena_height_px},
         {-1,-1,-1,arena_height_px}}
         
wallshakepos={{1,-1,d_right,arena_width_px-4},
              {arena_width_px+1,1,d_down,arena_height_px-4},
              {1,arena_height_px+1,d_right,arena_width_px-4},
              {-1,1,d_down,arena_height_px-4}}

bee_colours=split("9,8,12,10,14,11")
bee_colours_light=split("15,14,6,7,15,7")

fade_colours=split("7,6,4,13")

-- animation
anim_player_walk={}
anim_player_walk[d_left]=split("64,65")
anim_player_walk[d_right]=split("64,65")
anim_player_walk[d_up]=split("68,69")
anim_player_walk[d_down]=split("66,67")

anim_player_push={}
anim_player_push[d_left]=split("96,98,98,98,96")
anim_player_push[d_right]=split("96,98,98,98,96")
anim_player_push[d_up]=split("72,73,73,73,72")
anim_player_push[d_down]=split("70,71,71,71,70")

anim_player_dying=split("108,110")

anim_pengo_peek=split("128,129,130,131,132,133,132,131,131,131,132,133,132,131,131,131,132,133,132,131,130,130,129,128,129,130,131,134,135,136")

anim_bee_hatching=split("11,12,13,14,15")
anim_bee_dizzy=split("48,49,50,51")

anim_bee_move={}
anim_bee_move[d_left]={52,54}
anim_bee_move[d_right]={52,54}
anim_bee_move[d_up]={58,59}
anim_bee_move[d_down]={56,57}

-- dances
--  wr  - walk right
--  pr  - push right
--  f   - front shuffle
--  sj  - star jump
--  sjr - star jump while moving right
--  pw  - penguin waddle
--  pwr - penguin waddle while moving right

dances={
 split("wr,104,pr,40,pl,40,f,20,wr,100"),
 split("wr,20,sjr,84,f,60,sjr,100"),
 split("wr,104,f,10,sj,40,f,10,wr,100"),
 split("wr,44,pwr,20,wr,40,pw,40,f,20,pw,40,wr,40,pwr,60"),
 split("wr,64,pwr,40,pr,20,pl,20,pw,20,wr,20,pwr,20,wr,60"),
 split("wr,74,sj,20,wr,30,pw,20,sj,30,f,20,wr,40,pw,20,wr,50"), 
}

function bee_palette(level)
 if level then
  level=1+((level-1)\2)%#bee_colours
  pal(9,bee_colours[level])
  pal(15,bee_colours_light[level])
 else
  pal(9,9)
  pal(15,15)
 end
end

__gfx__
00000000001010000001110000000000001110000999999002222220011111100111111002222220099999900000000000000000000000000009900000999000
0000000001818100001ee710011a110001bbb10099f9999622f22226116111161161111622f2222699f99996000000000000000000099000009f990009f99900
007007001888881001eee7101aaaaa101bfbbb109f9999962f22222616111116161111162f2222269f9999960000000000099000009f99000979979097797790
0007700018888810001ee71001aaa1001bbbbb10999999962222222611111116111111162222222699999996000f9000009f990009c99c9009c99c9097c9c790
00077000018881000001171001a1a1001bbbbb10999999962222222611111116111111162222222699999996000990000099990009999990099bb990999b9990
0070070000181000000017100010100001bbb1009999999622222226111111161111111622222226999999960000000000099000009999000999999099999990
00000000000000000000000000000000000000009999996622222266111111661111116622222266999999660000000000000000000990000099990009999900
00000000000000000000000000000000000000000666666006666660066666600666666006666660066666600000000000000000000000000000000000000000
0111111067717761677b7761000000000000000004444440055d5550000000000000000000000000055555500000000000000000000000000000000000000000
116c11167711177c77bbb77c00000000000000004444444055d5d550004444000000000000000000555555500011110000000000000000000000000000000000
16c1111671bbb17c7b111b7c0000000000000000444444405d555d50044444000044400000000000555555500111110000111000000000000000000000000000
1c11111611bbb11cbb111bbc000000000000000044444440d55555d0044444000044400000040000555555500111110000111000000100000000000000000000
1111111671bbb17c7b111b7c0000000000000000444444405d555d50044444000044400000000000555555500111110000111000000000000000000000000000
111111167711177c77bbb77c00000000000000004444444055d5d550044440000000000000000000555555500111100000000000000000000000000000000000
111111666771776c677b776c000000000000000044444400555d5500000000000000000000000000555555000000000000000000000000000000000000000000
066666601cccccc11cccccc100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111110001111100011011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
106c1016006c10060060100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
16c1111616c1011616c1011610c1011610c101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c0101161c0101101c0101000c0101000c0101000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111016111110160111101601001010010010100100100001001000000000000000000000000000000000000000000000000000000000000000008880000000
10110116101100161011001610010016000100100001001000010010000000000000000000000000000000000000000000000088800000000000087878000000
11111166111011661110116001101060001010600010100000001000000010000000000000000000000000000000000000000878780000000000871871800000
0666666006666000006660000066000000060000000000000000000000000000000000000000000000000000000000000000871817800000000086bbb6800000
000a000000a000000a000000a000a0000000000000000000000000000000000000999900000000000099990000000000000086bbb68000000000b88888b00000
a0000a0a0000a0a0000a0a0000a000a000000099900000000000000000000000099999900099990009999990009999000000b88888b000000000b87778b00000
00000000000000000000000000000000000009f99900000000000099990000009779977909f9999099f9999909f999900000b87778b00000000bb77777bb0000
0099990000999900009999000099990000009999779000000000099f9990000097c99c799f9999999f9999999f9999990000b77777b000000000077777000000
09997790099999900779999007797790000099997c9b0000000099f997c90000999bb999977997799999999999999999000bb77777bb000000000b777b000000
9779c7999779c79997c9c79997c9c7990000999999900000000099999779b0009f99999997cbbc799f9999999999999900000b777b00000000000b000b000000
97c9999997c97799999977999999999900009999f9900000000099999999000009f999909999999909f999909ff9999900000b000b00000000000bb0bb000000
0999999009999990099999900999999000000999990000000000099999900000009999000999999000999900099999900000bbb0bbb000000000b00000b00000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088800000000000000000000000
00088800000000000088880000888800008888000088880000888800000000000000000000888800000000888000000000000878780000000000000000000000
00887680000888000878788008878780088888800888888008787880008888000088880008888880000b0878780b000000008718178000000000000000000000
0088718b008876808718178bb87181788888888bb8888888b718178b0887878008888880b888888b000b8178178b0000000086bbb68000000000000000000000
088b88800088718b86bbb68bb86bbb688888888bb8888888b6bbb68b0871817008888880b888888b000b86bbb68b0000000bb88888bb00000000000000000000
08b38870088b8880b88888b33b88888bb88888833888888b3b8888b3086bbb60088888803b8888b30000b88888b00000000b8877788b00000000000000000000
0b388770088b8870b87778800887778bb88888800888888b88777880bb8888bbbb8888bb888888800000887778800000000b8777778b00000000000000000000
8b88776008bb8770b87777800877778bb88888800888888b88777780b887778bb888888b88888880000087777780000000000777770000000000000000000000
02887600888b77608777778008777778888888800888888887777780087777780888888888888880000bb77777bb000000000b777b0000000000000000000000
000b0000bb88760bbbb77bb00bb77bbbbbb888b00b888bbbbbb77bb00bb77bbb0bb88bbbbbb88bb0000b0077700b000000000b000b0000000000000000000000
00bbbb000bb000b00bb0000000000bb0bbb0000000000bbb0bb0000000000bb000000bb00bb0000000bbb00000bbb0000000bbb0bbb000000000000000000000
00000000000000000000000000000000000000999000000000000099900000000099990000999900009999000099990000000b000000000000000b0000b00000
00000000000000000000000000000000000009f999000000000009f999000000099999900999999009f9999009f99990000088877600000000008887760b0000
00000000000000000000000000000000000099997c900000000099997790000097799779977997799f9999999f999999000861887760b0000008678877600000
0000000000000000000000000000000000009999779b0000000099997c9b000097c99c7997c99c799999999999999999000877888770b0000008718887700000
0000000000000000000000000000000000009494999000000000949999900000999bb999999bb9999f9999999f999999000888b3888bb000000888bbbb800000
0000000000000000000000000000000000009949494000000000499494900000d9d9d9d99d9d9d9dd9d9d9d9d9d9d9d90000888b3880b00000008888b88b0000
0000000888000000000000008880000000009097909000000000774949070000077d97700779d770077d9770077d977000000088bb2000000000008888bb0000
00000088768000000000000887680000000000777700000000000770077000000000077007700000000007700770000000000000080000000000000008b00000
00000088718b0000000000888718b000000000000000000000000000000000000099990000999900000000bbbb00000000000000000000000000000000000000
000008888880000000000888888800000000009990000000000000000000000009999990099999900099993bb300000000000000000000000000000000000000
0000888b8700000000088888b770b000000009f99900000000000099990000009779977997799779b9f999966099990000000000000000000000000000000000
00088883bb000000000288873bbbb00000009999779000000000099f9990000097c99c7997c99c799f99999969f9999b00000000000000000000000000000000
000288873bb000000000288773330000000099997c9b0000000099f997c90000999bb999999bb999999999999f99999900000000000000000000000000000000
0000287760b00000000b3777600000000000999693b00000000099999773b000bf9999966999999b9f9999999999999900000000000000000000000000000000
000b00bb00000000000bb00000000000000099966bb0000000009999966bb0000999993bb300000099f999999ff9999900000000000000000000000000000000
0000bb00bb0000000000bb00000000000000099993b00000000009999993b000000000bbbb000000099999900999999000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000008888000088880000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000888800087878800878788000000000000000000000000000000000000000000000000000000000
00000000000000000000000000888800008888000088880008888880871817808718178000000000000000000000000000000000000000000000000000000000
0000000000000000008888000887878008888880088888808718178086bbb68086bbb68b00000000000000000000000000000000000000000000000000000000
00000000000000000878788008718178087181780888888886bbb680b88888b0b87778b300000000000000000000000000000000000000000000000000000000
000000000088880087181780086bbb68086bbb68086bbb68b88888b0b8777880b877778000000000000000000000000000000000000000000000000000000000
008888000878788086bbb6800b88888b0b88888b0b88888bb8777880b87777808777778000000000000000000000000000000000000000000000000000000000
b878788bb718178bb88888bbbb87778bbb87778bbb87778bb877778087777780bb777bb000000000000000000000000000000000000000000000000000000000
00000000000000000000000888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000008888bbbbbbb8880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000888800000000008888bbbbbbbbbbbb88000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0088bb888800000888bbbbbbbbbbbbbbbb8800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
008bbbbbb8888888bbbbbbbbbbbbbbbbbbb880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
008bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb88000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0088bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000088bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000088bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb88000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000008bb7bbbbbbbbbbbbbbb8888bbbbbbbbbbb8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000088b77bbbbbbbbbbbb8880088bbbbbbbbbb8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000008bb77bbbbbbbbbbb8000008bbbbbbbbbb8000000000000000000000000000000000000000000000000000000000008888880000008888880000000000
000000088b777bbbbbbbbbb8800088bbbbbbbbbb8000000000000000000000000000000000000000000000000000000000088bbbb88008888bbbb88880000000
000000008b777bbbbbbbbbbb88888b77bbbbbbbb800000000000000000000000000000000000000000000008888888888888bbbbbb8888bbbbbbbbbb88000000
000000008bb77bbbbbbbbbbbbbbbb777bbbbbbbb800000000000000000000000000008888888000000008888bbbbbbbbbbbbb77bbb88bbbbbbb7777bb8800000
0000000088b77bbbbbbbbbbbbbb7777bbbbbbbbb800000000000000000000000000888bbbbb8880000888bbbbbbbbbbbbbb777bbb88bbbbbbb777777bb880000
0000000008b7bbbbbbbbbbbbbbb777bbbbbbbbb88000000000000000000000000888bbb77bbbb880088bbb777bbbbbbbbb777bbb88bbbbbbbbbbbb777bb88000
0000000008bbbbbbbbbbbbbbbbbbbbbbbbbbbbb888888880000000008888888088bbb777777bbb8888bb7777bbbbbbbbbbbbbbb88bbbbbbbbbbbbbbb7bbb8000
0000000008bbbbbbbbbbbbbbbbbbbbbbbbbbbb88bbbbbb88880000888bbbbb888bb77777bbbbbbb88bb777bbbbbbbbbbbbbbbb88bbbbbbbbbbbbbbbbbbbb8800
0000000008bbbbbbbbbbbbbbbbbbbbbbbbbbb88bbbbbbbbbb888088bbb777b88bb7777bbbbbbbbb8bb777bbbbbbbbbbbbbbbbb8bbbbbbbbbbbbbbbbbbbbbb800
0000000008bbbbbbbbbbbbbbbbbbbbbbbbbb88bbbbbbbbbbbbb888bb777bbbbbbbb77bbbbbbbbbb8bb77bbbb8888bbbbbbbbbb8bbbbbbbb888bbbbbbbbbbb800
0000000008bbbbbbbbbbbbbbbbbbbbbbbbb88bbbbbbbbb777bbb8bb777bbbbbbbbbbbbbbbbbbbb88b777bbb88008bbbbbbbbb88bbbbbbb88088bbbbbbbbbb880
0000000008bbbbbbbbbbbbbbbbbbbbbbbb88bbbbbbbbbbbb777b88bb7bbbbbbbbbbbbbbbbbbbbb8bb777bbb80008bbbbbbbbb8bbbbbbbb80008bbbbbbbbbbb80
0000000088bbbbbbbbbbbbbbbbbbbbbbb88bbbbbbbbbbbbbb77bb88bbbbbbbbbbbbbbbbbbbbbbb8bbb7bbbb80088bbbbbbbbb8bbbbbbbb88088bbbbbbbbbbb80
000000008bbbbbbbbbbbbbbbbbbbbbb888bbbbbbbbbbbbbbbb77bb8bbbbbbbbbbbbbbbbbbbbbbb8bbbbbbbb8888bbbbbbbbbb8bbbbbbbbb888bbbbbbbbbbbb80
000000008bbbbbbbbbbbb88bbbbbb888bbbbbbbbbbbbbbbbbbb7bb8bbbbbbbbbbbbbbbbbbbbbbb8bbbbbbbbbbbbbbbbbbbbbb8bbbbbbbbbbbbb77bbbbbbbbb80
000000008bbbbbbbbbbbbb88888888bbbbbbbbbbbbbbbbbbbbbbbb8bbbbbbbbbbbbbbbbbbbbbbb8bbbbbbbbbbbbbbbbbbbbb88bbbbbbbbbbbb777bbbbbbbbb80
000000088bbbbbbbbbbbbbb800088bbbbbbbbb88888bbbbbbbbbbb8bbbbbbbbbbb77bbbbbbbbbb8bbbbbbbbbbbbbbbbbbbbb8bbbbbbbbbbbbb77bbbbbbbbbb80
00000008bbbbbbbbbbbbbbb80008bbbbbbbbb880008bbbbbbbbbbb8bbbbbbbbbbbb77bbbbbbbbb88bbbbbbbbbbbbbbbbbbbb8bb7bbbbbbbbbbbbbbbbbbbbbb80
00000008bbbbbbbbbbbbbbb80088bbbbbbbbb800008bbbbbbbbbbb8bbbbbbbbb8bb77bbbbbbbbbb88bbbbbbbbbbbbbbbbbbb8b77bbbbbbbbbbbbbbbbbbbbbb80
00000088bbbbbbbbbbbbbbb8008bbbbbbbbbb88888bb7bbbbbbbb88bbbbbbbbb88b77bbbbbbbbbbb8888bbbbbbbbbbbbbbbb8b777bbbbbbbbbbbbbbbbbbbb880
0000008bbbbbbbbbbbbbbbb8088bbbbbbbbbbbbbbbb77bbbbbbbb8bbbbbbbbbbb8b77bbbbbbbbbb88bbbbbbbbbbbbbbbbbbb8b777bbbbbbbbbbbbbbbbbbbb800
0000088bbbbbbbbbbbbbbbb808bbbbbbbbbbbbbb7777bbbbbbbb888bbbbbbbbbb8b77bbbbbbbbb88bb77bbbbbbbbbbbbbb888bb77bbbbbbbbbbbbbbbbbbbb800
000008bbbbbbbbbbbbbbbbb888b7bbbbbbbbbbbbb77bbbbbbbb88b8bbbbbbbbbb8b77bbbbbbbbb8bb777bbbbbbbbbbbbb88b88b77bbbbbbbbbbbbbbbbbbbb800
000008bbbbbbbbbbbbbbbbb88bb7bbbbbbbbbbbbbbbbbbbbbb88bb8bbbbbbbbbb8b7bbbbbbbbbb8b77bbbbbbbbbbbbbbbbbbb8b777bbbbbbbbbbbbbbbbbb8800
000088bbbbbbbbbbbbbbbbb88bb7bbbbbbbbbbbbbbbbbbbbb88bbb8bbbbbbbbbb8b7bbbbbbbbbb8b7bbbbbbbbbbbbbbbbbbbb8bb77bbbbbbbbbbbbbbbbbb8000
00008bb7bbbbbbbbbbbbbbb88bb77bbbbbbbbbbbbbbbbbbb88bbb88bbbbbbbbbb8bbbbbbbbbbbb8bbbbbbbbbbbbbbbbbbbbbb88b777bbbbbbbbbbbbbbbb88000
00088bb7bbbbbbbbbbbbbbb88bb77bbbbbbbbbbbbbbbbb888bbbb8bbbbbbbbbb88bbbbbbbbbbb8888bbbbbbbbbbbbbbbbbbbbb8bb777bbbbbbbbbbbbbbb80000
0008bb77bbbbbbbbbbbbbbb88bb77bbbbbbbbbbbbbbb888bbbbb88bbbbbbbbbb8bbbbbbbbbbbb8bb888bbbbbbbbbbbbbbbbbbb88bb777bbbbbbbbbbbbb880000
0008bb77bbbbbbbbbbbbbbb888b777bbbbbbbbbbb8888bbbbbbb8bbbbbbbbbbb8bbbbbbbbbbb88bbbbbbbbbbbbbbbbbbbbbbbbb88bb77bbbbbbbbbbbb8800000
0008bb77bbbbbbbbbbbbbbb808b777bbbbbbbbbbbbbbbbbbbbbb8b7bbbbbbbbb8bb7bbbbbbbb8bb77bbbbbbbbbbbbbbbbbbbbbbb88bbbbbbbbbbbbbb88000000
0088b777bbbbbbbbbbbbbbb808bb777bbbbbbbbbbbbbbbbbbbb88b77bbbbbbbb8bb77bbbbbb88b77bbbbbb88888bbbbbbbbbbbbbb8888bbbbbbbb88880000000
008bb777bbbbbbbbbbbbbbb8088b777bbbbbbbbbbbbbbbbbbb888b77bbbbbbbb8bb7777bbbb8bb7bbbbbb880008bbbbbbbbbbbbbb80088888888880000000000
008bb777bbbbbbbbbbbbbb88008bb77bbbbbbbbbbbbbbbbbb8808b777bbbbbb888bb7777bbb8b77bbbbbb800088bbbbbbbbbbbbbb80000000000000000000000
008bb7777bbbbbbbbbbbbb800088bb7bbbbbbbbbbbbbbbbb88008bb777bbbbb8088bb777bbb8b77bbbbbb88888bbbbbbbbbbbbbbb80000000000000000000000
008bb7777bbbbbbbbbbbbb8000088bbbbbbbbbbbbbbbbbb8800088bb77bbbb880088bbbbb888b77bbbbbbbbbbbb77bbbbbbbbbbb880000000000000000000000
008bbb7777bbbbbbbbbbb880000088bbbbbbbbbbbbbbb8880000088bbbbb8880000888888808b777bbbbbbbbb7777bbbbbbbbbbb800000000000000000000000
0088bb77777bbbbbbbbbb800000008888bbbbbbb888888000000008888888000000000000008bb77bbbbbbbbb777bbbbbbbbbbb8800000000000000000000000
0008bbb7777bbbbbbbbb880000000000888888888000000000000000000000000000000000088b77bbbbbbbbbbbbbbbbbbbbbbb8000000000000000000000000
00088bbb77bbbbbbbbbb800000000000000000000000000000000000000000000000000000008bbbbbbbbbbbbbbbbbbbbbbbbb88000000000000000000000000
000088bbbbbbbbbbbbb8800000000000000000000000000000000000000000000000000000008bbbbbbbbbbbbbbbbbbbbbbbb880000000000000000000000000
0000088bbbbbbbbbbb880000000000000000000000000000000000000000000000000000000088bbbbbbbbbbbbbbbbbbbbb88800000000000000000000000000
00000088bbbbbbbbb88000000000000000000000000000000000000000000000000000000000088bbbbbbbbbbbbbbbbbb8880000000000000000000000000000
0000000888bbbbb8880000000000000000000000000000000000000000000000000000000000008888bbbbbbbbbbbbb888000000000000000000000000000000
00000000088888880000000000000000000000000000000000000000000000000000000000000000088888888888888800000000000000000000000000000000
__label__
hhhhhhhhhhhhhhhhhhhhhhh888888888hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhh8888bbbbbbb888hhhhhhhhhhh000000000hhh0000000000000000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhh8888hhhhhhhhhh8888bbbbbbbbbbbb88hhhhhhhhhh080808880hhh0888088808880880088008880hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hh88bb8888hhhhh888bbbbbbbbbbbbbbbb88hhhhhhhhh080800800hhh0808000800080080008008080hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hh8bbbbbb8888888bbbbbbbbbbbbbbbbbbb88hhhhhhhh08880080hhhh0808088808880080h08008080hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hh8bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb88hhhhhhh080800800hhh0808080008000080008008080hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hh88bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb88hhhhhh080808880hhh0888088808880888088808880hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhh88bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb88hhhhh000000000hhh0000000000000000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhh88bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhh88bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb88hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhh8bb7bbbbbbbbbbbbbbb8888bbbbbbbbbbb8hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhh88b77bbbbbbbbbbbb888hh88bbbbbbbbbb8hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhh8bb77bbbbbbbbbbb8hhhhh8bbbbbbbbbb8hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh888888hhhhhh888888hhhhhhhhhh
hhhhhhh88b777bbbbbbbbbb88hhh88bbbbbbbbbb8hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh88bbbb88hh8888bbbb8888hhhhhhh
hhhhhhhh8b777bbbbbbbbbbb88888b77bbbbbbbb8hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8888888888888bbbbbb8888bbbbbbbbbb88hhhhhh
hhhhhhhh8bb77bbbbbbbbbbbbbbbb777bbbbbbbb8hhhhhhhhhhhhhhhhhhhhhhhhhhhh8888888hhhhhhhh8888bbbbbbbbbbbbb77bbb88bbbbbbb7777bb88hhhhh
hhhhhhhh88b77bbbbbbbbbbbbbb7777bbbbbbbbb8hhhhhhhhhhhhhhhhhhhhhhhhhh888bbbbb888hhhh888bbbbbbbbbbbbbb777bbb88bbbbbbb777777bb88hhhh
hhhhhhhhh8b7bbbbbbbbbbbbbbb777bbbbbbbbb88hhhhhhhhhhhhhhhhhhhhhhhh888bbb77bbbb88hh88bbb777bbbbbbbbb777bbb88bbbbbbbbbbbb777bb88hhh
hhhhhhhhh8bbbbbbbbbbbbbbbbbbbbbbbbbbbbb88888888hhhhhhhhh8888888h88bbb777777bbb8888bb7777bbbbbbbbbbbbbbb88bbbbbbbbbbbbbbb7bbb8hhh
hhhhhhhhh8bbbbbbbbbbbbbbbbbbbbbbbbbbbb88bbbbbb8888hhhh888bbbbb888bb77777bbbbbbb88bb777bbbbbbbbbbbbbbbb88bbbbbbbbbbbbbbbbbbbb88hh
hhhhhhhhh8bbbbbbbbbbbbbbbbbbbbbbbbbbb88bbbbbbbbbb888h88bbb777b88bb7777bbbbbbbbb8bb777bbbbbbbbbbbbbbbbb8bbbbbbbbbbbbbbbbbbbbbb8hh
hhhhhhhhh8bbbbbbbbbbbbbbbbbbbbbbbbbb88bbbbbbbbbbbbb888bb777bbbbbbbb77bbbbbbbbbb8bb77bbbb8888bbbbbbbbbb8bbbbbbbb888bbbbbbbbbbb8hh
hhhhhhhhh8bbbbbbbbbbbbbbbbbbbbbbbbb88bbbbbbbbb777bbb8bb777bbbbbbbbbbbbbbbbbbbb88b777bbb88hh8bbbbbbbbb88bbbbbbb88h88bbbbbbbbbb88h
hhhhhhhhh8bbbbbbbbbbbbbbbbbbbbbbbb88bbbbbbbbbbbb777b88bb7bbbbbbbbbbbbbbbbbbbbb8bb777bbb8hhh8bbbbbbbbb8bbbbbbbb8hhh8bbbbbbbbbbb8h
hhhhhhhh88bbbbbbbbbbbbbbbbbbbbbbb88bbbbbbbbbbbbbb77bb88bbbbbbbbbbbbbbbbbbbbbbb8bbb7bbbb8hh88bbbbbbbbb8bbbbbbbb88h88bbbbbbbbbbb8h
hhhhhhhh8bbbbbbbbbbbbbbbbbbbbbb888bbbbbbbbbbbbbbbb77bb8bbbbbbbbbbbbbbbbbbbbbbb8bbbbbbbb8888bbbbbbbbbb8bbbbbbbbb888bbbbbbbbbbbb8h
hhhhhhhh8bbbbbbbbbbbb88bbbbbb888bbbbbbbbbbbbbbbbbbb7bb8bbbbbbbbbbbbbbbbbbbbbbb8bbbbbbbbbbbbbbbbbbbbbb8bbbbbbbbbbbbb77bbbbbbbbb8h
hhhhhhhh8bbbbbbbbbbbbb88888888bbbbbbbbbbbbbbbbbbbbbbbb8bbbbbbbbbbbbbbbbbbbbbbb8bbbbbbbbbbbbbbbbbbbbb88bbbbbbbbbbbb777bbbbbbbbb8h
hhhhhhh88bbbbbbbbbbbbbb8hhh88bbbbbbbbb88888bbbbbbbbbbb8bbbbbbbbbbb77bbbbbbbbbb8bbbbbbbbbbbbbbbbbbbbb8bbbbbbbbbbbbb77bbbbbbbbbb8h
hhhhhhh8bbbbbbbbbbbbbbb8hhh8bbbbbbbbb88hhh8bbbbbbbbbbb8bbbbbbbbbbbb77bbbbbbbbb88bbbbbbbbbbbbbbbbbbbb8bb7bbbbbbbbbbbbbbbbbbbbbb8h
hhhhhhh8bbbbbbbbbbbbbbb8hh88bbbbbbbbb8hhhh8bbbbbbbbbbb8bbbbbbbbb8bb77bbbbbbbbbb88bbbbbbbbbbbbbbbbbbb8b77bbbbbbbbbbbbbbbbbbbbbb8h
hhhhhh88bbbbbbbbbbbbbbb8hh8bbbbbbbbbb88888bb7bbbbbbbb88bbbbbbbbb88b77bbbbbbbbbbb8888bbbbbbbbbbbbbbbb8b777bbbbbbbbbbbbbbbbbbbb88h
hhhhhh8bbbbbbbbbbbbbbbb8h88bbbbbbbbbbbbbbbb77bbbbbbbb8bbbbbbbbbbb8b77bbbbbbbbbb88bbbbbbbbbbbbbbbbbbb8b777bbbbbbbbbbbbbbbbbbbb8hh
hhhhh88bbbbbbbbbbbbbbbb8h8bbbbbbbbbbbbbb7777bbbbbbbb888bbbbbbbbbb8b77bbbbbbbbb88bb77bbbbbbbbbbbbbb888bb77bbbbbbbbbbbbbbbbbbbb8hh
hhhhh8bbbbbbbbbbbbbbbbb888b7bbbbbbbbbbbbb77bbbbbbbb88b8bbbbbbbbbb8b77bbbbbbbbb8bb777bbbbbbbbbbbbb88b88b77bbbbbbbbbbbbbbbbbbbb8hh
hhhhh8bbbbbbbbbbbbbbbbb88bb7bbbbbbbbbbbbbbbbbbbbbb88bb8bbbbbbbbbb8b7bbbbbbbbbb8b77bbbbbbbbbbbbbbbbbbb8b777bbbbbbbbbbbbbbbbbb88hh
hhhh88bbbbbbbbbbbbbbbbb88bb7bbbbbbbbbbbbbbbbbbbbb88bbb8bbbbbbbbbb8b7bbbbbbbbbb8b7bbbbbbbbbbbbbbbbbbbb8bb77bbbbbbbbbbbbbbbbbb8hhh
hhhh8bb7bbbbbbbbbbbbbbb88bb77bbbbbbbbbbbbbbbbbbb88bbb88bbbbbbbbbb8bbbbbbbbbbbb8bbbbbbbbbbbbbbbbbbbbbb88b777bbbbbbbbbbbbbbbb88hhh
hhh88bb7bbbbbbbbbbbbbbb88bb77bbbbbbbbbbbbbbbbb888bbbb8bbbbbbbbbb88bbbbbbbbbbb8888bbbbbbbbbbbbbbbbbbbbb8bb777bbbbbbbbbbbbbbb8hhhh
hhh8bb77bbbbbbbbbbbbbbb88bb77bbbbbbbbbbbbbbb888bbbbb88bbbbbbbbbb8bbbbbbbbbbbb8bb888bbbbbbbbbbbbbbbbbbb88bb777bbbbbbbbbbbbb88hhhh
hhh8bb77bbbbbbbbbbbbbbb888b777bbbbbbbbbbb8888bbbbbbb8bbbbbbbbbbb8bbbbbbbbbbb88bbbbbbbbbbbbbbbbbbbbbbbbb88bb77bbbbbbbbbbbb88hhhhh
hhh8bb77bbbbbbbbbbbbbbb8h8b777bbbbbbbbbbbbbbbbbbbbbb8b7bbbbbbbbb8bb7bbbbbbbb8bb77bbbbbbbbbbbbbbbbbbbbbbb88bbbbbbbbbbbbbb88hhhhhh
hh88b777bbbbbbbbbbbbbbb8h8bb777bbbbbbbbbbbbbbbbbbbb88b77bbbbbbbb8bb77bbbbbb88b77bbbbbb88888bbbbbbbbbbbbbb8888bbbbbbbb8888hhhhhhh
hh8bb777bbbbbbbbbbbbbbb8h88b777bbbbbbbbbbbbbbbbbbb888b77bbbbbbbb8bb7777bbbb8bb7bbbbbb88hhh8bbbbbbbbbbbbbb8hh8888888888hhhhhhhhhh
hh8bb777bbbbbbbbbbbbbb88hh8bb77bbbbbbbbbbbbbbbbbb88h8b777bbbbbb888bb7777bbb8b77bbbbbb8hhh88bbbbbbbbbbbbbb8hhhhhhhhhhhhhhhhhhhhhh
hh8bb7777bbbbbbbbbbbbb8hhh88bb7bbbbbbbbbbbbbbbbb88hh8bb777bbbbb8h88bb777bbb8b77bbbbbb88888bbbbbbbbbbbbbbb8hhhhhhhhhhhhhhhhhhhhhh
hh8bb7777bbbbbbbbbbbbb8hhhh88bbbbbbbbbbbbbbbbbb88hhh88bb77bbbb88hh88bbbbb888b77bbbbbbbbbbbb77bbbbbbbbbbb88hhhhhhhhhhhhhhhhhhhhhh
hh8bbb7777bbbbbbbbbbb88hhhhh88bbbbbbbbbbbbbbb888hhhhh88bbbbb888hhhh8888888h8b777bbbbbbbbb7777bbbbbbbbbbb8hhhhhhhhhhhhhhhhhhhhhhh
hh88bb77777bbbbbbbbbb8hhhhhhh8888bbbbbbb888888hhhhhhhh8888888hhhhhhhhhhhhhh8bb77bbbbbbbbb777bbbbbbbbbbb88hhhhhhhhhhhhhhhhhhhhhhh
hhh8bbb7777bbbbbbbbb88hhhhhhhhhh888888888hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh88b77bbbbbbbbbbbbbbbbbbbbbbb8hhhhhhhhhhhhhhhhhhhhhhhh
hhh88bbb77bbbbbbbbbb8hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8bbbbbbbbbbbbbbbbbbbbbbbbb88hhhhhhhhhhhhhhhhhhhhhhhh
hhhh88bbbbbbbbbbbbb88hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8bbbbbbbbbbbbbbbbbbbbbbbb88hhhhhhhhhhhhhhhhhhhhhhhhh
hhhhh88bbbbbbbbbbb88hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh88bbbbbbbbbbbbbbbbbbbbb888hhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhh88bbbbbbbbb88hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh88bbbbbbbbbbbbbbbbbb888hhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhh888bbbbb888hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8888bbbbbbbbbbbbb888hhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhh8888888hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh888888888888888hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh888hhhhhhhhh000000000000h00000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh88768hhhhhhhh0ccc0ccc0cc000cc00cc0hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh887s8bhhhhhhh0c0c0c000c0c0c000c0c0hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh88b888hhhhhhhh0ccc0cc00c0c0c000c0c0hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh88b887hhhhhhhh0c000c000c0c0c0c0c0c0hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8bb877hhhhhhhh0c0h0ccc0c0c0ccc0cc00hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh888b776hhhhhhhh000h0000000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhbb8876hbhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhbbhhhbhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh9999hhhhhhhhhh0000000h0000hhh0000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh99f999hhhhhhhh00aa0aa000aa0hhh0aaa0aaa0aaa0hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh99f997c9hhhhhhh0a000a0a0a0a00000a0a0a000a000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh99999779bhhhhhh0aaa0a0a0a0a0aaa0aa00aa00aa0hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh99999999hhhhhhh000a0a0a0a0a00000a0a0a000a000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh999999hhhhhhhh0aa00a0a0aa00hhh0aaa0aaa0aaa0hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh000000000000hhhh0000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh677s776shhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh77sss77chhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh7sbbbs7chhhhhhh0000000000000000000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhssbbbsschhhhhhh0ee00eee0eee0eee00ee0ee00ee00hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh7sbbbs7chhhhhhh0e0e00e00e0e0eee0e0e0e0e0e0e0hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh77sss77chhhhhhh0e0e00e00eee0e0e0e0e0e0e0e0e0hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh677s776chhhhhhh0e0e00e00e0e0e0e0e0e0e0e0e0e0hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhsccccccshhhhhhh0eee0eee0e0e0e0e0ee00e0e0eee0hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh00000000000000000000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh0000000hhhhh00000000000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh007777700hhh007707770777077707770hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh077070770hhh070000700707070700700hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh077707770hhh07770070077707700070hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh077070770hhh00070070070707070070hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh007777700hhh07700070070707070070hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh0000000hhhh0000h000000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
00hhh0000000000000000hhhhhhh000hhhhhh00000000000000000hhh0000000000000000000000000hhh000000000hhh000000000000000hhhhh00000000000
c0hhh0ccc0ccc0cc00cc00hhhhh00c00hhhhh0ccc0ccc0cc00c0c0hhh0ccc0c0c0ccc0cc00c0c00cc0hhh0ccc00cc0hhh0ccc0ccc0c0c0c0hhhhh0cc00ccc0c0
c0hhh0c0000c00c0c0c0c0hhhh00ccc00hhhh0ccc0c0c0c0c0c0c0hhh00c00c0c0c0c0c0c0c0c0c000hhh00c00c0c0hhh0c0c0c0c0c0c0c0hhhhh0c0c00c00c0
c0hhh0cc0h0c00c0c0c0c0hhhh0ccccc0hhhh0c0c0ccc0c0c0ccc0hhhh0c00ccc0ccc0c0c0cc00ccc0hhhh0c00c0c0hhh0ccc0ccc0c0c0c0hhhhh0c0c00c00c0
c0hhh0c0000c00c0c0c0c0hhhh00ccc00hhhh0c0c0c0c0c0c000c0hhhh0c00c0c0c0c0c0c0c0c000c0hhhh0c00c0c0hhh0c000c0c0c0c0c000hhh0c0c00c00cc
c0hhh0c0h0ccc0c0c0c0c0hhhhh00c00hhhhh0c0c0c0c0c0c0ccc0hhhh0c00c0c0c0c0c0c0c0c0cc00hhhh0c00cc00hhh0c0h0c0c00cc0ccc0hhh0c0c0ccc00c
00hhh000h0000000000000hhhhhh000hhhhhh00000000000000000hhhh00000000000000000000000hhhhh0000000hhhh000h0000000000000hhh00000000000
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh

__map__
0000000000f400000000000000000000151c1c1c1c1c1c1c1c1c1c1c1c1c1c16c2c3cccdc0c145464344c8c9c4c5cecfc6c7cacb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000f5e4f2e6f3e4f600000000000000191e1e1e1e1e1e1e1e1e1e1e1e1e1e1ad2d3dcddd0d155565354d8d9d4d5dedfd6d7dadb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f5f7e1e1f000f1e1e1f8f60000000000191e1e1e1e1e1e1e1e1e1e1e1e1e1e1a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000191e1e1e1e1e1e1e1e1e1e1e1e1e1e1a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000191e1e1e1e1e1e1e1e1e1e1e1e1e1e1a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9091000000000097ba00000000000000191e1e1e1e1e1e1e1e1e1e1e1e1e1e1a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0a1a2a3a4a5a6a7a8a9000000000000191e1e1e1e1e1e1e1e1e1e1e1e1e1e1a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b0b1b2b3b4b5b6b7b8b9000000000000191e1e1e1e1e1e1e1e1e1e1e1e1e1e1a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000c00191e1e1e1e1e1e1e1e1e1e1e1e1e1e1a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000191e1e1e1e1e1e1e1e1e1e1e1e1e1e1a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000005c191e1e1e1e1e1e1e1e1e1e1e1e1e1e1a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c000c000c000d000d000d000000005d191e1e1e1e1e1e1e1e1e1e1e1e1e1e1a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
63646566676867686566636400000000171b1b1b1b1b1b1b1b1b1b1b574c4718000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7374757677787778757673740000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4344454647484748454643440000000000000000000000003030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5354555657585758555653540000000000000000000000003030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
262728292a2b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
363738393a3b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202123
20207c64642d2d245e3073202120207c685e202068236864202020732021687c685e2068782378682024682420202073202323202023687c68642d2d2d68782378682023232368202020732023242023687c685e2068782378680000000000000000000000000000000000000000000000000000000000000000000000642d20
20407868784020232323685e732023687c2323242020682020407868784063685e207373687c2323232420682020407868784020682d2d6864642d687c6124682020407868784020685e5e207c612368302040786878402068640000000000000000000000000000000000000000000000000000000000000000000000687840
206863684021237c63206820202026682020206863684021237c237c2123686864642d2d686821237c2168682020202d632d2020206868217c612368686320233030236320686861237c616868632d2061202d636868617c23230000000000000000000000000000000000000000000000000000000000000000000000686863
2d2061242461202d636868237c68685e21215e68687c367c23236868632d20212323202d63686823237c347c337c61236868632d632d63686861237c2168685e5e6868217c2123686830202020266330686821237c237c735e5e0000000000000000000000000000000000000000000000000000000000000000000000682323
73732373732323682020207c685e2368202368232068232024232024232020682020207c682026632023202023206823206823202023202020682020207c612363232320682320202320202363682020207c6323202020242320000000000000000000000000000000000000000000000000000000000000000000000023687c
2024232020202423202023686823202023232020785e687c232363232024232068232020232020232020236320687c232020202423202023206823202023632320202324202020687c6323202423206823202423202068232020000000000000000000000000000000000000000000000000000000000000000000000020687c
202023202423206823202023636820202324202320202320687c202320202320686863202420206820202023632023687c5e682121212020687c626262626240407363407c405e202020305e63207363407c4063682340232340402368405e207363407c4063685e736840234023234040237363407c40202323406863206873
68232023203023642d2d2d407c40242020206820202024736873232320232040235e24407c40636820202068736873232020232020235e30407c40682020206820202068736873232024232620235e23407c406820202068202020687340232320202323202363202423407c406862782340407340632023202363202323407c
406820646440642d23202320202420202023407c406863202420206863202323202363232323407c406820206840784040406840404023682320202320202024232020407c406820206840202020406840202023686178234023202420407c406820206840202020406840242023685e2020232340407c406820246840203020
406840612340402323234061407c6820302023235e636464647c6861235e202323685e5e7c6861235e202323682023402340234023402340237c6861235e202323682024202420242024202420247c6823232423235e202323682378237823782378237823787c68612320242020302020232368237823782378237823782378
__sfx__
6b010000150321504215052150521605217052180521804218042190321a0321c0321d0321f0322203224032280322b0322d03230032350323c0323d03221002200021e0021c0021b0021700213002140020c002
1b0400000c3570e35710357113570c3570e35710357113571a3471c3471d3371f3371c3271d3271f31721317003070030718307193071a3071a3071b307193070030700307023070130700307003070430701307
250100000a1710f17110161101610916108161091610d1611016112151111510a1510615105151071510a15109141061410414104141061410214100141001310c2070d2070e2070c2070c2071c2071f20718207
2d0204003e555305002d5012a501005010e5010c5010e5010c5010e5010c5010e5010c5010e5010c5010e50118501185011850118501185011850118501185010c5010c5010c5010c5010c5010c5010c5010c501
1e020000115721157213572165721e572285720d5720f572125721b572255720c5720d5720e57212572155721a5722057232562235521753209522085020a5020c50211502155022250218502185021850218502
2b0200003056634556375563554614500115000e5000a500305263452637526355160a5000a500075000450024516285162b516295160150000500005000050024516285162b5162951600500005000450001500
450e000024576285762b5763057626576295762d57632576285662b5662b5662f56630556285562b546305362452626526285162951624000230012200121001200011f0011e0011d0001c0001b0001a00018000
0b0200001b643116630a673066730067300673006730066300653006530065300663006530064300643006330062300613006130061301603185020c502006030060301603026030060300603007030470301703
790e0000245752457528575285752b5652b5653056530565245552455528555285552b5452b5452f5452f545245352453528535285352d5252d5252b5222b5222b5222b515155051750524536285362b52630516
7b0400001d5363a53637536325362c5362853625536215361c53619536175361452612526115260f5260d5260b5160a516055160351603516005160c5060b5060a50608506065060450602506005060050600506
010906001f3751f325243752432528375283252830503305103050f3050e3050e3050d30509305063050430503305003050030534305183052f305003053630518305343053730537305343052d3050030500305
010900002b3752b3352b3252b3152b3752b3252d3752d3252b3752b32529375293252837528325263752632528375283352832528315283752832529375293252837528325263752632524375243252337523325
0109000024375243452433524315213752132524375243352432524315213752132524375243252637526325283752834528335283152937529325283752832526375263251f3751f32524375243252837528325
010900002137521325243752434524335243151f3751f3252b3752b3452b3352b3152937529345293352931528375283452833528315263752634526335263152437524345243352431504300013000030000300
010900000c1732d1002a100301030517322100211651a100181731210011100131002d165161000c173191000c1731d10018143211003016525100281002a1000c1732d10018125351000c17338100241633c100
110a000018560185201f5601f5201e5601e52018560185201e5601e5201d5601d52018560185201d5601d5201c5601c52018560185201a5601a5201b5601b5201c5601c5501c5401c5401c5321c5221c5221c512
050a000013762137421373213722137122170212762127421273212722127123b7021176211742117321172211712117021076210742107321072210712267020c7620c7420c7420c7320c7320c7220c7220c712
010a0000243752434524335243152637526345263352631527375273452733527315283752834528335283152b3752b3652b3552b3452b3352b32524375243652437524365243552434524335243252432524315
010a000000552005220c5720c52218562185220c5520c52200552005220c5720c52218562185220c5520c522075520752213572135221d5621d5220c5520c5320c5220c5120a5000a50009500095000750007500
010d00000c7000c7000c7000c700187001870018700187000a7000a7000a7000a7000c7000c7000c7000c700057000570005700057000c7000c7000c7000c7000e7000e7000e7000e700237751c700217751c700
010d0000237752a7051e7752a7051a775287051e7752670517775267051770525705237752a705217752a705237752a7051e7752a7051a775287051e7752670517775267051770525705237752a705257752a705
010d0000267752a705257752a7052677528705237752670525775267052377525705257752a705217752a705237752a705217752a705237752870521775267052377526705257052570523775267052177525705
010d0000267752a705257752a7052677528705237752670525775267052377525705257752a705217752a705237752a705217752a70523775287052577526705267752670525705257052a7752a705287752a705
010d00002a7752a705267752a705217752870526775267051e7752670525705257052a7752a705287752a7052a7752a705267752a705217752870526775267051e7752670525705257052a7752a7052c77511705
010d00002d7752a7052c7752a7052d775287052a775267052c775267052a775257052c7752a705287752a7052a7752a705287752a7052a7752870526775267052a7752670525705257052a7752a7052877511705
010d00002d7752a7052c7752a7052d775287052a775267052c775267052a775257052c7752a705287752a7052a7752a705287752a7052a7752870528775267052a775267052570525705233751c700213751c700
490d0000233752a3051e3752a3051a3751e375173051737517305263051730525305233752a305213752a305233752a3051e3752a3051a3751e3751e3051737517305263051730525305233752a305253752a305
490d0000263752a3052537526375263052637523305233752537526305233752537525305253752130521375233752a3052137523375233052337521305213752337526305253052530523375263052137525305
490d0000263752a3052537526375263052637523305233752537526305233752537525305253752130521375233752a305213752337523305233752130525375263752630525305253052a375263052837525305
490d00002a3752a305263752a3052137526375263051e3751e3052630525305253052a3752a305283752a3052a3752a305263752a3052137526375263051e3751e3052630525305253052a3752a3052c37511305
490d00002d3752a3052c3752d3752d3052d3752a3052a3752c375263052a3752c3752c3052c37528305283752a3752a305283752a3752a3052a37526305263752a3752630525305253052a3752a3052837511305
490d00002d3752a3052c3752d3752d3052d3752a3052a3752c375263052a3752c3752c3052c37528305283752a3752a305283752a3752a3052a37526305263752a3752630525305253052a3052a3052830511305
7d0d000023572235722356223562235522355223542235422354223532235322353223522235222157221532235722357223562235321e5721e5721e5621e5621e5521e5521e5321e52223572235322557225532
7d0d00002657226572265622656226542265322357223532255722557225562255622554225532215722153223572235722457126571285712a5712c5712e5712f5712f5702f5602f5602f5522f5422f5322f522
7d0d00002657226572265622656226552265322357223532255722557225562255622555225532215722153223576265762a5762f57623556265562a5562f5562f54632546365463b5460c57332500185733b500
7d0d00002d5722d5722d5622d5622d5622d5622d5522d5522d5522d5522d5422d5322d5322d5222c5722c5322d5722d5722d5622d5322a5722a5722a5622a5622a5522a5522a5322a5252d5722d5322f5722f532
7d0d000031572315723156231562315523155231542315322f5722f5722f5622f5622f5522f5522f5322f5222d5722d5722d5712c5712d5612d5622d5612c5612d5512d5522d5522d5522d5422d5422d5222c552
7d0d000031572315723156231562315523155231542315322f5722f5722f5622f5622f5522f5522f5422f5322d5722d5722d5622d5622d5622d5622d5522d5522d1552d1452d1352d125237651c700217651c700
1b0900000c5732d5002a5003050305573225001d5001a5001857312500115001350024500265002850029500185731d5001857321500240002600028500295000c5732d500305003550024426344263741630416
010a00002b7002a7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002670026700267002670026700267002670026700
350d00000b14510105121450e145061450e105121450e1450614509105121450e14506145091450d145121450b14510105121450e145061450e105121450e1450614509105121450e14506145091450d14512145
350d00000914510105101450d145091450e105101450d14507145091050e1450b14507145091050e1450b1450b14510105121450e145061450e105121450e1450614509105121450e14506145091450d14512145
350d00000e145101051514512145061450e105151451214502145091051514512145061450814515145121450e145101051514512145061450e10515145121450214509105151451214506145081451514512145
350d000006145101050d14509145061450e1050d1450914504145091050b1450814504145091050b1450814502145101050914512145061450e10515145121450214509105091451214506145081451514512145
490d0400233751c700213751c7001c7001c700213051c7000a7000a7000a7000a7000c7000c7000c7000c700057000570005700057000c7000c7000c7000c7000e7000e7000e7000e700233051c700213051c700
490d00002d3752a3052c3752d3752d3052d3752a3052a3752c375263052a3752c3752c3052c37528305283752a3752a305283752a3752a3052a37526305263752a375263052530525305233751c700213751c700
010800000c1750c1151014510115131351311510135101150c1750c11510145101151313513115101351011511175111151514515115181351811515135151151117511115151451511518135181151513515115
010800000c1750c1151014510115131351311510135101150c1750c1150e1450e1150f1450f11510145101150c1420c1420c1320c1320c1220c1220c1120c1120c1050c1050c1050c1050c1050c1050c1050c105
190800002a5752a5352b5752b5522b5322b512285752854528542285322853228512245752455224532245122d5552d5252c5552c5252d5552d5252c5552c5252d5552d525305553055230542305323052230512
190700002a5002a5002b5002b5002b5002b500285002850028500285002850028500245002450024500245001a5001a5001d5001d5001d5001d5001f5001f5001f5001f5001f5001f50023500235002350023500
190800002857528535275752755528535285152757527535285752853524575245552653526515285752853524555245422454224542245322453224522245222451224512245122451218502185021850218502
010b00001c5521c5121f5521f51228552285121c5521c5121f5521f51228552285121c5521c5121f5521f51226552265121c5521c5121f5521f512265522653226522265121c5521c5121f5521f5122655226512
010b000018552185121c5521c512245522451218552185121c5521c512245522451218552185121c5521c51224552245422454224532245322452224522245122b50209502245022450228502285023050230502
010b00000517505115111651111505165051151115511115051750511511165111150516505115121551211507175071151316513115071650711513155131150717507115131651311507165071151115511115
190b00000c1752810000175291000c1752610000175281000c1752810000175291000c1752610018175281000c1752810000105291000c1052610000105281000c1052810000105291000c105261000010528100
2d0c1800283002830028300283002d3002d3002d3002d30028300283002d3002d3002f3002f3002f3002f30030300303003230034300353003530035300353002930029300293002930028300283002830028300
010c00003b6552430018053243003b6552330024053233003b65521300293531f3003b6551c30024053180533b6551830029353353533b655113003b655103003b6552930035353293533b6553b6553b6553b655
011600002173221732217222172221712217121f7321f7321f7321f7321f7221f7221f7221f7221f7121f7121f7121f7121f7121f7121f7121f7121f7121f7121d7321d7221d7221d7121c7321d7221c7221c712
0116000018745187351872518725187351872518715187150c0250c0250c0150c0150c0150c0150c0150c01518705187051870518705187051870518705187051870518705187051870518705187051870518705
010900000c275002002f205002000b275002002b20500200092750020000200002000727500200002000020009275002002f2050020015275002002b205002000727500200002000020013275002000020000200
0109000005275002000020000200112750020000200002000527500200002000020011275002000020000200002750020000200002000c2750020000200002000727500200002000020013275002000020000200
010900000527500200002000020011275002000020000200072750020000200002001327500200002000020007275002000020000200172750020000200002000c27500200002000020000200002000020000200
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 54685844
01 13285944
01 14285844
00 15295944
00 14287044
00 16295944
00 172a7244
00 182b7344
00 172a7244
00 192b7344
00 1a287244
00 1b297344
00 1a287244
00 1c297344
00 1d2a7244
00 1e2b7344
00 1d2a7244
00 1f2b7344
00 20287244
00 21297344
00 20287244
00 22297344
00 232a7244
00 242b7344
00 232a7244
02 252b7344
00 6a6e7244
00 6b6f7344
01 33354344
04 34364344
00 41424344
00 41424344
01 4a794344
00 4b504344
00 4c4f4344
05 0f104344
05 11124344
00 4d504344
00 4c4f4344
00 4d504344
01 402c7344
01 1a287244
00 1b297344
00 1a287244
00 1c297344
00 1d2a7244
00 1e2b7344
00 1d2a7244
02 2d2b7344
00 5456585c
01 0a794344
00 0b0e3b44
00 0c0e3c44
00 0b0e3b5c
04 0d263d44
00 41424344
01 2e305a44
04 2f325b44
00 6e705b44
00 6f725b44
00 41424344
00 41424344
00 41424344
00 44454344

