pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
function _init()
 map_id=0
 mode=0
 hiscore=1800
 
 title_init()
end

function _update()

 if(mode==0)then
  title_update()
 else
  game_update()
 end
 
 --game start keys
 if(mode!=1)then
  if(btn(4) or btn(5))then
   game_init()
   mode=1
  end
 end
end

function _draw()
 if(mode==0)then
  title_draw()
 else
  game_draw()
 end
end

----------------
--draw methods--
----------------
function title_draw()
 cls()
 pal()
 palt()
 camera()
 
 --title logo draw
 local ty=7
 
 --top/bottom
 for i=0,11,1 do
  spr(141,16+i*8,ty)
  spr(141,16+i*8,24+ty,1,1,false,true)
 end
 
 --edges
 spr(156,8,8+ty)
 spr(156,8,16+ty,1,1,false,true)
 spr(156,112,8+ty,1,1,true)
 spr(156,112,16+ty,1,1,true,true)
 spr(140,8,0+ty)
 spr(140,8,24+ty,1,1,false,true)
 spr(140,112,0+ty,1,1,true)
 spr(140,112,24+ty,1,1,true,true)
 
 --middle
 spr(128,16,8+ty,12,2)
 
 --hi score
 print("hi-score "..hiscore..0,35,1,7)
 
 --ghosts
 print("character / nickname",30,40,7)
 
 local n=flr(title_timer/20)
 
 if(n>0)then
  spr(32,16,49)
 end
 if(n>1)then
  print('-chaser     "elroy"',30,50,8)
 end
 if(n>2)then
  spr(33,16,59)
 end
 if(n>3)then
  print('-trapper    "lexaloffle"',30,60,14)
 end
 if(n>4)then
  spr(34,16,69)
 end
 if(n>5)then
  print('-snapper    "zep"',30,70,12)
 end
 if(n>6)then
  spr(35,16,79)
 end
 if(n>7)then
  print('-pico       "siapran"',30,80,9)
 end
 
 if(n>8)then
  --scoring
  spr(12,25,103)
  print("10 pts",33,104,7)
  spr(13,63,103)
  print("50 pts",73,104,7)
 end
 
 if(n>9)then
  --pamco
  spr(176,39,112,6,1)
 end
 
 --credits
 print("credits  0",1,123,7)
 print("game by urbanmonk",60,123,5)

 for o in all(actors)do
  draw_actor(o)
 end
 
 if(pause_m==2)then
  palt(0,false)
  palt(1,true)
  spr(66+eat_c*2,pac.x-4,pac.y,2,1)
 end
 
end

function game_draw()
 cls()
 palt()
 
 --map color
 pal(12,map_c)
 --draw map
 map(msh,0,0,0,msh+19,21,0x1)
 pal()
 
 --draw dots
 for o in all(dots)do
  spr(di[o.t],o.x,o.y)
 end
 
 --draw fruit
 draw_fruit()
 
 --draw scared ghosts first
 for o in all(enes)do
  if(o.m==3)then
   draw_actor(o)
  end
 end
 
 --draw the player
 draw_actor(pac) 	
 
 --draw nonscared ghosts last
 for o in all(enes)do
  if(o.m!=3)then
   draw_actor(o)
  end
 end
 
 if(pause_m==1)then
  --ready
  spr(84,f_spawn.x-12,f_spawn.y,4,1)
 end
 
 if(pause_m==5)then
  --gameover
  spr(88,f_spawn.x-19,f_spawn.y,6,1)
 end

 if(map_id==0)then 
  --warp area fades
  palt(0,false)
  palt(8,true)
  spr(14,0,72,2,1)
  spr(14,136,72,2,1,1)
  rectfill(-8,72,0,80,0)
  rectfill(152,72,160,80,0)
 end
 
 gui_draw()
end

function gui_draw()

 --draw the eat score
 if(pause_m==2)then
  palt(0,false)
  palt(1,true)
  local o=enes[eat_gid]
  local ex=o.x-5
  local ey=o.y
  local n=68+(eat_c-1)*2
 	spr(n,ex,ey,2,1)
 end
 
 camera()
 
 rectfill(0,0,127,6,0)
 
 if(mode==1)then
  print(score..0,100,1,7)
  print("hi  "..hiscore..0,3,1,8)
 
  rectfill(0,119,127,127,0)
 
  --lives display
  palt()
  for i=1,lives,1 do
   spr(2,(i-1)*9,120,1,1,1)
  end
 
  --level icons
  for i=0,min(level,10),1 do
   spr(112+i,120-i*9,120)
  end
 else
  print("demo",57,1,7)
 end
end

function draw_actor(o)

 --not hidden
 if(o.h==0)then
  --setup pal swap
  pal(1,o.c)
  --get animation frame
  local f=
   min(o.as+o.a+0.4,o.ae)
  --draw
  spr(f,o.x,o.y,
       1,1,o.fx,o.fy)
  pal() --reset pal swap
 end
 
 if(pause_a==0)then
  --animation
  o.a+=o.sa
  if(o.a>o.ae-o.as)then
   if(o.al==1)then
    o.a=0
   else
    o.a=o.ae-o.as
   end
  end
 end
 
 --draw ghost eyes
 if(o.i>0
  and o.sc!=1
  and eat_gid!=o.i)then
  --get direction
  local d=get_sdir(o)
  spr(80+d,o.x,o.y)
 end
 
end

function draw_fruit()
 if(f_spawn.h==0)then
  local n=112+(level%11)
  spr(n,f_spawn.x,f_spawn.y)
 elseif(f_spawn.h==2)then
  palt(0,false)
  palt(1,true)
  local n=160+min(level,8)*2
  local fx=f_spawn.x-4
  local fy=f_spawn.y
 	spr(n,fx,fy,2,1)
 end
end

--title screen
function title_update()
 title_timer+=1
 
 prc_pause()
 
 if(pause_m==0)then
  for o in all(actors)do
   o.x+=o.xm o.y+=o.ym
  end
 end
 
 if(title_timer==200)then
  for i=1,4,1 do 
   local g=new_ghost(i)
   g.x=138+i*9
   g.y=91
   g.xm=-1.08
  end
 
  pdot=new_actor(10,91,13,13)
  pac=new_actor(127,91,0,4)
  pac.xm=-1
  pac.sa=1
  pac.fx=true
  eat_c=0
 end
 
 if(pac!=nil)then
  if(gdist(pac,pdot)<3)then
   del(actors,pdot)
   pac.xm=1
   pac.fx=false
   for o in all(enes)do
    o.as=64 o.ae=65 o.sc=1
    o.xm=0.5 o.s=0.5
   end
  end
  
  for o in all(enes)do
   if(gdist(pac,o)<3)then
    pause(30,2)
    pac.h=1
    eat_c+=1
    del(actors,o)
    del(enes,o)
   end
  end
 end
 
 if(title_timer>520)then
  game_init()
  mode=2
 end
end

--main game
function game_update()
 prc_pause()

 --not paused
 if(pause_m==0)then
  play_loop()

 --death animation
 elseif(pause_m==3)then
  if(pause_t==40)then
   for o in all(enes)do
    o.x=-1000
    o.y=-1000
   end
   pac.a=0
   pac.as=98
   pac.ae=107
   pac.sa=1
   pac.al=0
   pac.fx=false
   pac.fy=false
  elseif(pause_t==1)then
   if(mode==1)then
    if(lives>0)then
     new_round()
     lives-=1
    else
     gameover()  
    end
   else
    title_init()
   end
  end
  
 --next level animation
 elseif(pause_m==4)then
  if(pause_t<80)then
   blink_map()
  end
  if(pause_t==80)then
   for o in all(enes)do
    o.x=-1000
    o.y=-1000
   end
   pac.h=1
  elseif(pause_t==1)then
   level+=1
   load_map()
  end
  
 --gameover
 elseif(pause_m==5)then
  if(pause_t==1)then
   title_init()
  end
 end
 
 --process the camera
 if(cam.reset==1)then
  cam.x=cam.tox
  cam.y=cam.toy
  cam.reset=0
 end
 
 cam.x+=(cam.tox-cam.x)*0.14
 cam.y+=(cam.toy-cam.y)*0.14
 camera(cam.x-63,cam.y-63)
end

--processes gameplay
function play_loop()
 if(mode==1)then
  --read user input
  if(btn(0))then--left
   new_dir(pac,-1,0)
  elseif(btn(1))then--right
   new_dir(pac,1,0)
  elseif(btn(2))then--up
   new_dir(pac,0,-1)
  elseif(btn(3))then--down
   new_dir(pac,0,1)
  end
 else
  --attract mode
  atr_mv(pac)
 end

 --ghost ai
 for o in all(enes)do  
  pr_g(o)
 end
 
 --scared mode timer
 if(scared_timer>0)then
  scared_timer-=1
  if(scared_timer<80)then
   for i=1,4,1 do
    local o=enes[i]
    if(o.sc==1)then
     o.ae=67
    end
   end
  end
  if(scared_timer==1)then
   restore()
  end
 else
  --ai mode switching
  ai_mode_timer+=1
  if((ai_mode==0 and
   ai_mode_timer>30*7)
   or (ai_mode==1 and
   ai_mode_timer>30*20))then
    ai_mode=1-ai_mode
    ai_mode_timer=0
    for i=1,4,1 do
     local o=enes[i]
     if(o.m==2)then
      reverse(o)
     end
    end
  end
 end
 
 --actor control
 for o in all(actors) do
  --check for collisions
  if(col_ck(o)==false)then
   o.x+=o.xm*o.s
   o.y+=o.ym*o.s
   if(o==pac)then
    o.sa=1
   end
  else
   if(o==pac)then
    o.a=2 --pac animation freeze
    o.sa=0
   end
   o.it=0
   --snap to grid if colliding
   o.x=flr((o.x+4)/8)*8
   o.y=flr((o.y+4)/8)*8
  end
  
  --screen wrapping
  if(o.x>cx*2-6)then
   o.x=0
  end
  if(o.x<-4)then
   o.x=cx*2-6
  end
 end
 
 --set player speed
 pac.s=gv.ps
 
 --dots
 for o in all(dots)do
  --check dist from player
  if(gdist(o,pac)<3)then
   --slow player
   pac.s=gv.ps*0.5
   if(o.t==2)then
    power()
    score+=5
   else
    score+=1
   end
   del(dots,o)
   dot_c-=1
   
   --release ghosts from pen
   --based on the amount eatten
   local e=dot_sc-dot_c
   if(e>1)then
    release(enes[2])
   end
   if(e>30)then
    release(enes[3])
   end
   if(e>60)then
    release(enes[4])
   end
   --ghost speedup
   if(dot_c<gv.edl1)then
    enes[1].ss.s=gv.es1
   end
   if(dot_c<gv.edl2)then
    enes[1].ss.s=gv.es2
   end
   --spawn fruit
   if(e==120)then
    spawn_fruit()
   end
   --end of the round
   if(dot_c==0)then
    next_round()
   end
  end
 end
 
 --fruit eat
 if(f_spawn.h==0
  and gdist(f_spawn,pac)<3)then
  eat_fruit()
 end
 
 --process fruit
 prc_fruit()
 
 --ghost collisions
 for o in all(enes)do
  --check dist from player
  if(gdist(o,pac)<3)then
   --scared?
   if(o.sc==0)then
    die()
   elseif(o.sc==1)then
    eat(o)
   end
   break
  end
 end

 --update player animation
 if (pac.xm!=0)then
  pac.as=0 pac.ae=4
  pac.fx=(pac.xm<0)
 else
  pac.as=16 pac.ae=20
  pac.fy=(pac.ym<0)
 end

 --update hi score
 if(score>hiscore)then
  hiscore=score
 end
 
 --camera follow the player
 cam_player()
end

------
--ai--
------
--ghost process
function pr_g(o)

 --in pen
 if(o.m==1)then
 
  --collisions off
  o.col=0
  o.s=o.ss.p
  
  local p=pen[o.i-1]
  if(o.t==0)then
   new_sdir(o,3)
   if(o.y<p.y-2)then
    o.t=1
   end
  else
   new_sdir(o,1)
   if(o.y>p.y+2)then
    o.t=0
   end
  end
  
 --active
 elseif(o.m==2)then
  
  --collisions on
  o.col=1
  
  --in tunnel
  if(mget(
   flr((o.x+4)/8),
   flr((o.y+4)/8))==50)then
   o.s=gv.gts--slow
  else
    o.s=o.ss.s--normal
  end
  
  --scared
  if(o.sc==1)then
   o.s=gv.gfs
   rnd_mv(o)
   return
  end
  
  if(ai_mode==0)then
   --scatter
   sct_mv(o)
  else
   --ai bug emulate
   local ofs=0
   if(o.ym<0)then
    ofs=-1
   end
   --chase 
   if(o.i==1)then
    --target the player
    trg_mv(o,pac.x,pac.y)
   elseif(o.i==2)then
    --target 4 tiles in
    --front of player
    trg_mv(o,
     pac.x+(pac.xm+ofs)*40,
     pac.y+pac.ym*40)
   elseif(o.i==3)then
    --target away from red
    --in relation to the player
    local b=enes[1]
    trg_mv(o,
    b.x+((pac.x+(pac.xm+ofs)*16)-b.x)*2,
    b.y+((pac.y+pac.ym*16)-b.y)*2)
   elseif(o.i==4)then
    --move towards until
    --we get too close then
    --scatter
    if(dist(o.x,pac.x,o.y,pac.y)>70)then
     trg_mv(o,pac.x,pac.y)
    else
     sct_mv(o)
    end
   end
  end
 
 --back to pen
 elseif(o.m==4)then
  o.s=o.ss.r
  --move towards the pen door
  trg_mv(o,pen_d.x,pen_d.y)
  --check dist from pen
  if(gdist(o,pen_d)<12)then
   o.m=5
  end
 
 --enter pen
 elseif(o.m==5)then
 
  --collisions off
  o.col=0
  o.s=o.ss.r
  
  --move into the door
  new_sdir(o,1)
  
  --in the pen?
  if(o.y>=pen_d.y+8)then
   restore_anim(o)
   o.m=6
   --not scared
   o.sc=0
  end
  
 --exit pen
 elseif(o.m==6)then
 
  --collisions off
  o.col=0
  o.s=o.ss.p
  
  if(pen_d.x-o.x>1)then
   new_sdir(o,0)
  elseif(pen_d.x-o.x<-1)then
   new_sdir(o,2)
  else
   o.x=pen_d.x
   new_sdir(o,3)
  end
  
  --out of the pen?
  if(o.y<=pen_d.y-6)then
   o.m=2
   o.r=0
   o.it=0
   release_flag=0
  end
  
 end
 
end

--returns true when
--at an intersection
function ck_it(o)
 if(flr(o.x)%8==0
  and flr(o.y)%8==0)then
  if(o.it==0)then
   o.it=1
   --reverse flag check
   if(o.r==1)then
    o.r=0
    o.xm*=-1 o.ym*=-1
    return false
   end
   return true
  end
 else
  o.it=0
 end
 return false
end

--check directions
--finds avalible directions
function ck_dir(o)
 --get current tile id
 local tid=mget(
   flr((o.x+4)/8),
   flr((o.y+4)/8))
 local dl={}
 local b=(get_sdir(o)+2)%4
 if(col_ck(o,1,0)==false
  and b!=0)then
  add(dl,0) end
 if(col_ck(o,0,1)==false
  and b!=1)then
  add(dl,1) end
 if(col_ck(o,-1,0)==false
  and b!=2)then
  add(dl,2) end
 if(col_ck(o,0,-1)==false
  and b!=3
  --not over an up blocker
  and ((tid!=49
  and tid!=51)
  --scared mode ignores
  --the up blocker
  or o.sc==1))then
  add(dl,3) end
 return dl
end

--attract movement
function atr_mv(o)
 o.sc=1
 --at intersection
 if(ck_it(o))then
  --get avalible directions
  local dl=ck_dir(o,p)
  --count directions
  local c=0
  for _ in all(dl)do c+=1 end
  --pick one at random
  if(c>1 or col_ck(o))then
   dn+=1
   new_sdir(o,dr[dn])
  end
 end
end

--scatter movement
--moves to a corner based
--on id
function sct_mv(o)
 if(o.i==1)then
  trg_mv(o,cx*2-40,0)
 elseif(o.i==2)then
  trg_mv(o,30,0)
 elseif(o.i==3)then
  trg_mv(o,cx*2-40,cy*2)
 elseif(o.i==4)then
  trg_mv(o,30,cy*2)
 end
end

--random movement
--picks a random avalible
--direction
function rnd_mv(o)
 --at intersection
 if(ck_it(o))then
  --get avalible directions
  local dl=ck_dir(o)
  --count directions
  local c=0
  for _ in all(dl)do c+=1 end
  --pick one at random
  if(c>0)then
   new_sdir
    (o,dl[flr(rnd(c)+1)])
  end
 end
end

--target move
--move towards a target
function trg_mv(o,tx,ty)
 --at intersection
 if(ck_it(o))then
  --get avalible directions
  local dl=ck_dir(o)
  --count directions
  local c=0
  for _ in all(dl)do c+=1 end
  local cd=0--closest dist
  local fd=0--final direction
  --find closest to target
  for i=1,c,1 do
   local d=dl[i]--dir to test
   local dt=0--dir dist
   --get dir dist
   if(d==0)then
    dt=dist(o.x+8,tx,o.y,ty)
   elseif(d==1)then
    dt=dist(o.x,tx,o.y+8,ty)
   elseif(d==2)then
    dt=dist(o.x-8,tx,o.y,ty)
   elseif(d==3)then
    dt=dist(o.x,tx,o.y-8,ty)
   end
   if(i==1 or dt<cd)then
    cd=dt
    fd=d
   end
  end
  if(c>0)then
   new_sdir(o,fd)
  end
 end
end

--change actor direction
--(if possible)
function new_dir(o,xm,ym)
 if(col_ck(o,xm,ym)==false
  --turn radius
  and col_ck(o,xm,ym,o.xm*2,o.ym*2)
  ==false)then
  o.xm=xm or 0
  o.ym=ym or 0
  if(o.col==1)then
   --snap to grid
   if(o.ym!=0)then
    o.x=flr((o.x+4)/8)*8
   elseif(o.xm!=0)then
    o.y=flr((o.y+4)/8)*8
   end
  end
 end
end

function new_sdir(o,d)
 if(d==0)then
  new_dir(o,1,0)
 elseif(d==1)then
  new_dir(o,0,1)
 elseif(d==2)then
  new_dir(o,-1,0)
 elseif(d==3)then
  new_dir(o,0,-1)
 end
end

function get_sdir(o)
 return max(o.ym,0)
   +(min(o.xm,0)*-2)
   +(min(o.ym,0)*-3)
end

--check actor collision
--in a particular direction
function col_ck(o,xm,ym,xs,ys)

 --collision off flag
 if(o.col==0)then
  return false
 end

 xm=xm or o.xm
 ym=ym or o.ym
 local x=o.x-(xs or 0)
 local y=o.y-(ys or 0)
 
 if(ym!=0)then
  x=flr((x+4)/8)*8
 end
 if(xm!=0)then
  y=flr((y+4)/8)*8
 end
 
 --get the tile in front
 --of the actor
 local idx=
  flr((x+min(xm,0))/8)
  +max(xm,0)
 local idy=
  flr((y+min(ym,0))/8)
  +max(ym,0)
  
 --out of bounds?
 if(idx>=19 or idx<0)then
  return false
 end
 
 --get tile id
 local id=mget(idx+msh,idy)
 
 --true if collision
 return (fget(id,0)==true)
end

-------------------
--object creation--
-------------------
function title_init()
 mode=0
 title_timer=0
 pac=nil
 
 --ghost colors
 ghost_cols={8,14,12,9}

 enes={}
 actors={}

 eat_c=0

 pause_t=0
 pause_m=0
 --pause mode
 --0=none
 --1=ready
 --2=eat
 --3=die
 --4=next level
 --5=gameover
 pause_a=0--animation pause
end

--called once before a games
--starts to setup all the
--objects
function game_init()
-- play_snd(0)

 srand(0)

 --attract values
 dr=
  {0,0,1,0,0,1,2,2,2,3
  ,0,0,3,0,1,0,1,0,3,0
  ,3,0,3,3,0,3,2,3,3,0
  ,1,0,1,0,1,0,3,0,3,0
  ,1,0,3,3,2,2,1,2,3,2
  ,1,1,1,1,2,1,0,1,0,3
  ,3,0,1,1,0,3,0,0,3,0
  ,3,3,2,1,0,1,1,1,0,2}
 dn=0
 
 --map colors
 map_cs={12,11,10,9,8,7,13,14}
 map_c=0
 map_blink=0
 
 --objects
 actors={}
 dots={}
 enes={}
  
 --fruit spawn
 f_spawn={}
 f_spawn.x=0
 f_spawn.y=0
 f_spawn.h=1
 f_spawn.t=0
 
 --fruit bonus
 f_bonus=
  {10,30,50,70,100,200,300,500}
 
 --player spawn
 p_spawn={}
 p_spawn.x=0
 p_spawn.y=0
 
 --camera
 cam={}
 cam.x=0
 cam.y=0
 cam.tox=0
 cam.toy=0
 
 --pen spaces
 pen={}
 --pen space count
 pen_c=0
 
 --pen door
 pen_d={}
 pen_d.x=0
 pen_d.y=0
 
 --ghost start spawn
 g_spawn={}
 
 --ghost pen order
 pen_o={3,2,4,1}
 
 --game values
 score=0
 lives=3
 level=0
 ai_mode=0
 --ai modes
 --0=scatter
 --1=chase
 ai_mode_timer=0
 scared_timer=0
 eat_gid=0
 eat_c=0
 release_flag=0
 
 pause_t=0
 pause_m=0
 --pause mode
 --0=none
 --1=ready
 --2=eat
 --3=die
 --4=next level
 pause_a=0--animation pause
 
 dot_c=0 --dot count
 dot_sc=0--dot starting count
 
 --dot images
 di={12,13}
 
 --center
 cx=76
 cy=88
 
 --create player
 pac=new_actor(0,0,0,3)
 pac.xm=1--move right
 pac.sa=1

 --create ghosts
 for i=1,4,1 do
  new_ghost(i)
 end
 
 --proccess the map
 load_map()
 game_update()
end

function load_map()
 set_level_values()

 --get map shift
 msh=map_id*19

 --set ghost speeds
 for o in all(enes)do
  o.ss.s=gv.gs
 end

 --get map color
 map_c=map_color()

 --reset dots
 dots={}
 
 --clear pen spaces
 pen={}
 pen_c=0
 
 --clear pen door
 pen_d.x=0
 pen_d.y=0
 
 --clear ghost spawn
 g_spawn={}
 
 --clear dot count
 dot_c=0
 dot_sc=0
 
 --scan the map
 for x=0,19,1 do
  for y=0,21,1 do
   
   local id=mget(msh+x,y)
   
   --player
   if(id==1)then
    p_spawn.x=x*8
    p_spawn.y=y*8
   end
   
   --dots
   if(id==12 or id==51)then
    local lid=mget(x+1+msh,y)
    local tid=mget(x+msh,y+1)
    new_dot(x*8,y*8)
    if(lid==12 or lid==51)then
     new_dot(x*8+4,y*8)
    end
    if(tid==12 or tid==51)then
     new_dot(x*8,y*8+4)
    end
   end
   
   --power dots
   if(id==13)then
    new_dot(x*8,y*8,2)
   end
  
   --ghosts
   if(id>=32 and id<=35)then
    --get ghost id
    local i=id-31
    local s={}
    s.x=x*8
    s.y=y*8
    s.gid=i
    add(g_spawn,s)
   end
   
   --pen door
   if(id==60)then
    pen_d.x=x*8
    pen_d.y=y*8
   end
   
   --pen spaces
   if(id==48)then
    --add the pen space
    local p={}
    pen_c+=1
    p.i=pen_c
    p.x=x*8
    p.y=y*8
    add(pen,p)
   end
   
   --fruit spawn
   if(id==52)then
    f_spawn.x=x*8
    f_spawn.y=y*8
   end
  
  end 
 end
 
 new_round()
 
end

function new_actor(x,y,as,ae,c)
 local o={}
 
 --position
 o.x=x
 o.y=y
 
 --movement
 o.xm=0
 o.ym=0
 o.s=1
 
 --animation
 o.as=as
 o.ae=ae
 o.a=0
 o.sa=0.5
 o.al=1--loop
 
 --hidden
 o.h=0
 
 --flip image x/y
 o.fx=false
 o.fy=false
 
 --color replace
 o.c=c or 0
 
 --intersection flag
 o.it=0
 
 --id
 o.i=0
 
 --collision flag
 o.col=1
 
 add(actors,o)
 return o
end

function new_ghost(i)
 --get ghost color
 col=ghost_cols[i]
 
 --create ghost
 local p=new_actor
  (-50,-50,96,97,col)
  
 --set default values
 p.i=i--id
 
 --speeds
 p.ss={}
 p.ss.s=0
 p.ss.p=0.4--pen speed
 p.ss.r=2--return to pen
 
 p.m=0--ai mode
 --ai modes
 --0=none
 --1=pen wait
 --2=active->scatter/chase
 --4=back to pen
 --5=enter pen
 --6=exit pen
 
 p.sc=0 --scared flag
 p.r=0--reverse flag
 p.sa=0.125--animation speed
 
 add(enes,p)
 return p
end

function new_dot(x,y,t)
 local o={}

 --position
 o.x=x
 o.y=y
 
 --type
 o.t=t or 1

 add(dots,o)
 
 dot_c+=1--count the dots
 dot_sc+=1
 
 return o
end

--------------------
--gameplay methods--
--------------------
function gameover()
 pause(100,5)
 pac.h=1
 f_spawn.h=1
 for o in all(enes)do
  o.x=-999
  o.y=-999
 end
end

function next_round()
 pause(100,4)
end

function new_round()
 --reset gameplay values
 ai_mode=0
 ai_mode_timer=0
 scared_timer=0
 pause_t=0
 pause_m=0
 eat_gid=0
 eat_c=0
 release_flag=0
 f_spawn.h=1

 --place the player
 pac.x=p_spawn.x
 pac.y=p_spawn.y
 pac.h=0--not hidden
 pac.a=0--reset animation
 pac.xm=1--reset direction
 pac.ym=0
 
 --player animation
 pac.as=0
 pac.al=1--loop
 pac.sa=1
 
 --reset the camera
 cam.reset=1
 cam_player()
 
 --place the pen ghosts
 for p in all(pen)do
  local o=enes[pen_o[p.i]]
  o.x=p.x
  o.y=p.y
  o.m=1
  o.t=p.i%2
  o.xm=1
  o.ym=0
  o.r=0
 end
 
 --place the spawn ghosts
 for s in all(g_spawn)do
  local o=enes[s.gid]
  o.x=s.x
  o.y=s.y
  --set to roam mode
  o.m=2
  --set direction
  o.xm=1
  o.ym=0
 end
 
 restore(1)
 
 --start of game ready
 pause(50,1,1)
end

function power()
 for i=1,4,1 do
  local o=enes[i]
  --not eatten
  if(o.sc!=2)then
   o.sc=1
   o.c=1
   o.a=0
   o.as=64
   o.ae=65
   reverse(o)
  end
 end
 scared_timer=gv.gft
end

function eat(o)
 o.m=4
 o.sc=2
 o.c=0
 o.h=1
 eat_gid=o.i
 score+=20*pow(2,eat_c)
 eat_c=min(eat_c+1,4)
 pac.h=1
 pause(30,2)
end

function restore_anim(o)
 --get ghost color
 col=ghost_cols[o.i]
 o.c=col
 o.as=96
 o.ae=97
 o.h=0
end

function restore(f)
 local f=f or 0
 eat_c=0
 scared_timer=0
 for i=1,4,1 do
  local o=enes[i]
  --is scared?
  if(o.sc==1 or f==1)then
   o.sc=0
   restore_anim(o)
   if(f==0)then
    reverse(o)
   end
  end
 end
end

function reverse(o)
 o.r=1
end

function release(o)
 if(release_flag==1)then
  return
 end
 if(o.sc==0 and o.m==1)then
  o.m=5
  release_flag=1
 end
end

function pause(t,m,a)
 pause_t=t or 10
 pause_m=m or 0
 pause_a=a or 0
end

function prc_pause()
 if(pause_t>0)then
  if(pause_t==1)then
   pause_a=0
   pause_m=0
   eat_gid=0
   pac.h=0
  end
  pause_t-=1
 end
end

function prc_fruit()
 if(f_spawn.h!=1)then
  f_spawn.t-=1
  if(f_spawn.t<=0)then
   f_spawn.h=1
  end
 end
end

--pacman dies
function die()
 pause(60,3)
end

function blink_map()
 map_blink+=1
 if(map_blink==12)then
  map_c=7
 elseif(map_blink==24)then
  map_c=map_color()
  map_blink=0
 end
end

function map_color()
 return map_cs[(level%8)+1]
end

function spawn_fruit()
 f_spawn.h=0
 f_spawn.t=300
end

function eat_fruit()
 f_spawn.h=2
 f_spawn.t=100
 local n=min(level+1,8)
 score+=f_bonus[n]
end

function cam_player()
 --follow the player
 cam.tox=cx-(cx-pac.x)*0.3
 cam.toy=cy-(cy-pac.y)*0.5
end

--gets the game values
--for the current level
function set_level_values()
 sm=1.3
 gv={}
 --player speed
 local ps=
  {80,90,90,90,100,100,100,90}
 --player frightened speed
 local pfs=
  {90,95,95,95,100,100,100,100}
 
 --ghost speed
 local gs=
  {75,85,85,85,95}
 --ghost tunnel speed
 local gts=
  {40,45,45,45,50}
 --ghost frightened speed
 local gfs=
  {50,55,55,55,60}
 
 --ghost frightned timer
 local gft=
  {6,5,4,3,2,5,2,2,1,5,2,1}
 
 --red speedup speeds
 local es1=
  {80,90,90,100,100}
 local es2=
  {85,95,95,95,105}
 
 local n=min(level+1,8)
 gv.ps=ps[n]*0.01*sm
 gv.pfs=pfs[n]*0.01*sm
 
 n=min(n,5)
 gv.gs=gs[n]*0.01*sm
 gv.gts=gts[n]*0.01*sm
 gv.gfs=gfs[n]*0.01*sm
 
 n=min(level+1,12)
 gv.gft=gft[n]*30
 
 n=min(n,5)
 gv.es1=es1[n]*0.01*sm
 gv.es2=es2[n]*0.01*sm
 
 gv.edl1=min(20+(level*10),120)
 gv.edl2=flr(gv.edl1/2)
end

function play_snd(i)
 sfx(i,i)
end

function stop_snd(i)
 sfx(-1,i)
end

--------------
--math stuff--
--------------
function dist(x1,x2,y1,y2)
 return sqrt((x1-x2)*(x1-x2)+
  (y1-y2)*(y1-y2))
end

--est dist between objects
function gdist(o1,o2)
 return abs(o1.x-o2.x)
       +abs(o1.y-o2.y)
end

function pow(x1,x2)
 local r=1
 for i=1,x2,1 do
  r*=x1
 end
 return r
end
__gfx__
00aaaa0000aaaa0000aaaa0000aaaa0000aaaa000000000000000000000000000000000000000000000000000000000000000000000000000000800080808880
0aaaaaa00aaaaaa00aaaaaa00aaaa0000aaaaaa0000cccccccccccccccccc000000cc000000cccccccccccccccccc00000000000000ff0000000008008088088
aaaaaaaaaaaaaaaaaaaaa000aaaa0000aaaaa00000c000000000000000000c0000c00c0000c000000000000000000c000000000000ffff000000800080808880
aaaaaaaaaaaa0000aaaa0000aaaa0000aaaa00000c00cccccccccccccccc00c00c0000c00c00000000000000000000c0000ff0000ffffff00000008008088088
aaaaaaaaaaaa0000aaaa0000aaaa0000aaaa00000c0c0000000000000000c0c00c0000c00c00000000000000000000c0000ff0000ffffff00000800080808880
aaaaaaaaaaaaaaaaaaaaa000aaaa0000aaaaa0000c0c0000000000000000c0c00c0000c000c000000000000000000c000000000000ffff000000008008088088
0aaaaaa00aaaaaa00aaaaaa00aaaa0000aaaaaa00c0c0000000000000000c0c00c0000c0000cccccccccccccccccc00000000000000ff0000000800080808880
00aaaa0000aaaa0000aaaa0000aaaa0000aaaa000c0c0000000000000000c0c00c0000c000000000000000000000000000000000000000000000008008088088
00aaaa0000aaaa0000aaaa0000aaaa0000aaaa000c0c0000000000000000c0c00c0000c000000000000000000000000000000000000000000000000000000000
0aaaaaa00aaaaaa00aaaaaa00aaaaaa00aaaaaa00c0c000000cccc000000c0c00c0000c0000cccccccccccccccccc00000000000000000000000000000000000
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0c0c00000c0000c00000c0c00c0000c000c000000000000000000c0000000000000000000000000000000000
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0c0c00000c0000c00000c0c00c0000c00c00000000000000000000c000000000000000000000000000000000
aaaaaaaaaaa00aaaaaa00aaaaa0000aaaaa00aaa0c0c00000c0000c00000c0c00c0000c00c00000000000000000000c0000000cccc0000000000000000000000
aaaaaaaaaaa00aaaaa0000aaa000000aaa0000aa0c0c00000c0000c00000c0c00c0000c00c00000000000000000000c000000c0000c000000000000000000000
0aaaaaa00aa00aa00a0000a0000000000a0000a00c0c000000cccc000000c0c00c0000c00c00000cc000000cc00000c00000c00cc00c00000000000000000000
00aaaa0000a00a000000000000000000000000000c0c0000000000000000c0c00c0000c00c0000c00c0000c00c0000c00000c0c00c0c00000000000000000000
0088880000eeee0000cccc000099990000bbbb000c0c0000000000000000c0c00c0000c00c0000c00c0000c00c0000c00000c0c00c0c00000000000000000000
088888800eeeeee00cccccc0099999900bbbbbb00c0c0000000000000000c0c00c0000c00c00000cc000000cc00000c00000c00cc00c00000000000000000000
88718871ee71ee71cc71cc7199719971bb71bb710c0c0000000000000000c0c00c0000c00c00000000000000000000c000000c0000c000000000000000000000
88718871ee71ee71cc71cc7199719971bb71bb710c0c0000000000000000c0c00c0000c00c00000000000000000000c0000000cccc0000000000000000000000
88888888eeeeeeeecccccccc99999999bbbbbbbb0c00cccccccccccccccc00c00c0000c00c00000000000000000000c000000000000000000000000000000000
88888888eeeeeeeecccccccc99999999bbbbbbbb00c000000000000000000c0000c00c000c00000000000000000000c000000000000000000000000000000000
88888888eeeeeeeecccccccc99999999bbbbbbbb000cccccccccccccccccc000000cc0000c00000cc000000cc00000c000000000000000000000000000000000
88088088ee0ee0eecc0cc0cc99099099bb0bb0bb000000000000000000000000000000000c0000c00c0000c00c0000c000000000000000000000000000000000
5555555555555555555555555555555555555555000000000000c0c00c0c00000c0000c00c0000c00c0000c00c0000c000000000000000000000000000000000
5550055555500555500550055550055550000005000000000000c00cc00c0000c000000c0c00000cc000000cc00000c0ffffffff000000000000000000000000
5500005555055055500550055505505550000005000000000000c000000c0000000000000c00000000000000000000c0ffffffff000000000000000000000000
500000055055550555555555505ff50550055555000000000000c000000c0000cccccccc0c00000000000000000000c0ffffffff000000000000000000000000
500000055555555555555555555ff55550000555cccccccc0000c000000c0000000000000c00000000000000000000c000000000000000000000000000000000
5000000550000005500550055000000550000555000000000000c000000c00000000000000c000000000000000000c0000000000000000000000000000000000
5000000550000005500550055000000550055555c000000c0000c00cc00c000000000000000cccccccccccccccccc00000000000000000000000000000000000
55555555555555555555555555555555500555550c0000c00000c0c00c0c00000000000000000000000000000000000000000000000000000000000000000000
00dddd0000dddd000077770000777700111101110111011111111011011101111111011101110111110111011101110100000000000000000000000000000000
0dddddd00dddddd007777770077777701110a010a010a01111110a00a010a0111110a010a010a01110a010a010a010a00000000000000000000c00c0c0c0ccc0
dffddffddffddffd7887788778877887110a0a0a0a0a0a011110aa0a0a0a0a01110a0a0a0a0a0a010aa00a0a0a0a0a0a00000000000000000000000000000000
dffddffddffddffd788778877887788711100a0a0a0a0a01110a0a0a0a0a0a011110a00a0a0a0a0110a00aa00a0a0a0a00000000000000000c000c0c0c0cc0cc
dddddddddddddddd77777777777777771110a00a0a0a0a01110aaa0a0a0a0a01110a0a0a0a0a0a0110a00a0a0a0a0a0a00000000000000000000000000000000
ddfdfdfdddfdfdfd7787878777878787110a000a0a0a0a0111100a0a0a0a0a01110a0a0a0a0a0a0110a00a0a0a0a0a0a00000000000000000000000000000000
dfdfdfdddfdfdfdd7878787778787877110aaa00a010a01111110a00a010a0111110a010a010a0110aaa00a010a010a000000000000000000000000000000000
dd0dd0ddd0d00d0d7707707770700707111000110111011111111011011101111111011101110111100011011101110100000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000001100110000000000000000000000000000000aa0000000000000000000000000000000000000000000000000000000000000000
00710071000000001700170007700770aaaa00aaaa00aaa00aaaa00aa0aa00aa0888800888008000808888000888008808808888088880000000000000000000
00710071077007701700170000000000aa0aa0aa000aa0aa0aa0aa0aa0aa0aaa8000008808808808808800008808808808808800088088000000000000000000
00000000011001100000000000000000aaaa00aaa00aaaaa0aa0aa00aaa00a008088808888808808808880008808808808808880088880000c000c0c0c0cc0cc
00000000000000000000000000000000aa0a00aa000a000a0aa0aa000a0000008008808000808080808800008808800808008800088080000000000000000000
00000000000000000000000000000000aa00a0aaaa0a000a0aaaa0000a00a000088880800080800080888800088800008000888808800800000c00c0c0c0ccc0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111100001111000000000000000000000000000000000000000000000000000000000000000000000000000a0000a000000000000000000000000000000000
01111110011111100a0000a0000000000000000000000000000000000000000000000000000000000000000000a00a0000000000000000000ccc0c0c0c00c000
1111111111111111aa0000aaa000000aa000000a000000000000000000000000000000000000000000000000a000000a00000000000000000000000000000000
1111111111111111aaa00aaaaaa00aaaaaaaaaaaaaaaaaaa00aaaa00000aa000000aa000000aa000000aa0000a0000a00000000000000000cc0cc0c0c0c000c0
1111111111111111aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00aaaa00000aa000000aa000000aa0000a0000a000000000000000000000000000000000
1111111111111111aaaaaaaaaaaaaaaa0aaaaaa0aaaaaaaaaaaaaaaa0aaaaaa000aaaa0000aaaa00000aa000a000000a00000000000000000000000000000000
11111111111111110aaaaaa00aaaaaa0000aa000000aa000aa0aa0aaaaaaaaaa0aaaaaa000aaaa00000aa00000a00a0000000000000000000000000000000000
110110111010010100aaaa0000aaaa000000000000000000000000000aa00aa000a00a0000000000000aa0000a0000a000000000000000000000000000000000
0000ffff0000f0000000bbb000000f0000444400000940000000ff000000000a00009333d008800d000cc0000000000000000000000000000000000000000000
000f00f000bbfbb0000bbb000080f8000000400000979400000bb000000000a000009033d088880d00c00c000000000000000000000000000000000000000000
08f00f00087bb8800990b0900888888000333300097a9440000bb000000009aa00f99f00daa88aad00cccc000000000000000000000000000000000000000000
88880f00088888709999999988888888033b3b00097a994000bbbb0000009aaa0fff9ff0ddaaaadd000660000000000000000000000000000000000000000000
87808f0008787880999999998888887833b3b33009aa994000bbbb000009aaaa0ffffff00ddaadd000060000000000000000000000000000cc0cc0c00c00c000
080888800888878099999999888887883b3b3b3009aa99400b33bbb0009aaaa00ffffff000daad00000660000000000000000000000000000000000000000000
0008788000878800099999900888888033b3b3309a7aa99400b3bb00aaaaaa0000ffff00000aa000000600000000000000000000000000000ccc0c0cc0c000c0
00008800000880000099990000808800033b300000099000000bb0000aaaa000000ff000000aa000000060000000000000000000000000000000000000000000
00000000009000000999900009999999900009999999999999999000099999990099999909999990009999000000999900000000000000000000000000000000
07777777770077770999077000999999077000999999999999999070099999907099999070009990709999070000099900000000000000000000000000000000
07000000000070000000700aaa009990700aaa00009999999999907000999907000099070a010990700999070aaa000900000008888888880000000000000000
070aaaaaaaaa00aaa0070aaaaaaa00070aaaaaaa0009999999999070a0099070a01099070a01099070a099070aaa000900000888888888880000000000000000
070aaaaaaaaaa0aaa070aaaaaaaaa070aaaaaaaaa010000000099070aa09070aa0109070aaa0109070aa09070aaa010900008888000000000000000000000000
070aaaa00aaaa0aaa00aaaaaaaaa0100aaaaaaaaa010077777099070aa09070aa0109070aaa0109070aaa0070aaa010900088800999999990000000000000000
070aaaa00aaaa0aaa00aaaaaaaa0100aaaaa0aaaaa01070000009070aaa070aaa010070aaaaa010070aaaa070aaa010900888099999999990000000000000000
070aaaaaaa0aa0aaa0aaaaaaaa01070aaaaa0aaaaa01070aaaa00070aaaa0aaaa010070aaaaa010070aaaa070aaa010900880999999999990000000000000000
070aaaa000aa00aaa0aaaaaaaa00070aaaaa0aa0aa01000aaaa01070aaaa0aaaa01070aaaaaaa01070aaaaa00aaa010908880999000000000000000000000000
070aaaaaaaa010aaa00aaaaaaaa0070aaaaaaaa0aa01090000001070aaaaaaa0a01070aaa0aaa01070aaaaaaaa0a010908809999000000000000000000000000
070aaaa0000100a0a00aaaaaaaaa0000aaaaaa0aa010999011111070aaaaaaa0a0070aaaa0a0aa0070aaaaaaaa0a010908809999000000000000000000000000
070aaaa0111070a0a010aaaaaa0aa090aaaa00aaa010999000000070aaaaa000a0070aaaaaa0aa0070aaaaaa000a010908809999000000000000000000000000
070aaaa0100000aaa0100aaa00aa01090aaaaaaa0109999999999000aaaaaaaaa000aaaaaa0aaaa000aaaaaaaaaa010908809999000000000000000000000000
00000000109990000010100aaa001099900aaa001099999999999990000000000010000000000000100000000000010908809999000000000000000000000000
99011111109999011110011000110999999000110999999999999999011111111110111111111111100111111111110908809999000000000000000000000000
99000000009999000000900111009999999900009999999999999999000000000000000000000000000000000000000908809999000000000000000000000000
11110111011101111110000101110111111000110111011111000011011101111011101110111011101110111011101100011011101110110001101110111011
1110f010f010f011110fff00f010f011110fff00f010f01110ffff00f010f0110f010f010f010f010f010f010f010f01fff00f010f010f01fff00f010f010f01
110ff00f0f0f0f0111000f0f0f0f0f01110f000f0f0f0f0110f00f0f0f0f0f01ff00f0f0f0f0f0f0f0f0f0f0f0f0f0f000f0f0f0f0f0f0f0f000f0f0f0f0f0f0
1110f00f0f0f0f011110f00f0f0f0f01110ff00f0f0f0f011100f00f0f0f0f010f00f0f0f0f0f0f000f0f0f0f0f0f0f00f00f0f0f0f0f0f0ff00f0f0f0f0f0f0
1110f00f0f0f0f0111100f0f0f0f0f0111100f0f0f0f0f011110f00f0f0f0f010f00f0f0f0f0f0f00f00f0f0f0f0f0f000f0f0f0f0f0f0f000f0f0f0f0f0f0f0
1110f00f0f0f0f01110f0f0f0f0f0f01110f0f0f0f0f0f01110f010f0f0f0f010f00f0f0f0f0f0f0f000f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0
110fff00f010f0111110f000f010f0111110f010f010f011110f0110f010f011fff00f010f010f01fff00f010f010f010f010f010f010f010f010f010f010f01
11100011011101111111011101110111111101110111011111101111011101110001101110111011000110111011101110111011101110111011101110111011
ddddddd000ddddd00dddddddd0000ddddddd00dddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd00dddddd0ddddddddd00dddddddd0dddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd0000dd000000dd0dd00dd00dd0dd0000000dd0000dd00000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd0ddddddd0dd00dd00dd0dd0000000dd0000dd00000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd0ddddddd0dd00dd00dd0dd0000000dd0000dd00000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd0000000dd000dd0dd00dd00dd0dd0000000dd0000dd00000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd0000000ddddddd0dd00dd00dd0dddddddd0dddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd0000000ddddddd0dd00dd00dd00ddddddd00dddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000707077700000077007700770777077700000770077707770777077700000000000000000000000000000000000000
00000000000000000000000000000000000707007000000700070007070707070000000070070707070707070700000000000000000000000000000000000000
00000000000000000000000000000000000777007007770777070007070770077000000070077707070707070700000000000000000000000000000000000000
00000000000000000000000000000000000707007000000007070007070707070000000070070707070707070700000000000000000000000000000000000000
00000000000000000000000000000000000707077700000770007707700707077700000777077707770777077700000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000088888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000
00000000000008888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888880000000000000
00000000000088880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008888000000000000
00000000000888009999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999990088800000000000
00000000008880999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999908880000000000
00000000008809999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999990880000000000
00000000088809990000000000900000099990000999999990000999999999999999900009999999009999990999999000999900000099999990888000000000
00000000088099990777777777007777099907700099999907700099999999999999907009999990709999907000999070999907000009999999088000000000
000000000880999907000000000070000000700aaa009990700aaa00009999999999907000999907000099070a010990700999070aaa00099999088000000000
0000000008809999070aaaaaaaaa00aaa0070aaaaaaa00070aaaaaaa0009999999999070a0099070a01099070a01099070a099070aaa00099999088000000000
0000000008809999070aaaaaaaaaa0aaa070aaaaaaaaa070aaaaaaaaa010000000099070aa09070aa0109070aaa0109070aa09070aaa01099999088000000000
0000000008809999070aaaa00aaaa0aaa00aaaaaaaaa0100aaaaaaaaa010077777099070aa09070aa0109070aaa0109070aaa0070aaa01099999088000000000
0000000008809999070aaaa00aaaa0aaa00aaaaaaaa0100aaaaa0aaaaa01070000009070aaa070aaa010070aaaaa010070aaaa070aaa01099999088000000000
0000000008809999070aaaaaaa0aa0aaa0aaaaaaaa01070aaaaa0aaaaa01070aaaa00070aaaa0aaaa010070aaaaa010070aaaa070aaa01099999088000000000
0000000008809999070aaaa000aa00aaa0aaaaaaaa00070aaaaa0aa0aa01000aaaa01070aaaa0aaaa01070aaaaaaa01070aaaaa00aaa01099999088000000000
0000000008809999070aaaaaaaa010aaa00aaaaaaaa0070aaaaaaaa0aa01090000001070aaaaaaa0a01070aaa0aaa01070aaaaaaaa0a01099999088000000000
0000000008809999070aaaa0000100a0a00aaaaaaaaa0000aaaaaa0aa010999011111070aaaaaaa0a0070aaaa0a0aa0070aaaaaaaa0a01099999088000000000
0000000008809999070aaaa0111070a0a010aaaaaa0aa090aaaa00aaa010999000000070aaaaa000a0070aaaaaa0aa0070aaaaaa000a01099999088000000000
0000000008809999070aaaa0100000aaa0100aaa00aa01090aaaaaaa0109999999999000aaaaaaaaa000aaaaaa0aaaa000aaaaaaaaaa01099999088000000000
000000000880999900000000109990000010100aaa001099900aaa00109999999999999000000000001000000000000010000000000001099999088000000000
00000000088099999901111110999901111001100011099999900011099999999999999901111111111011111111111110011111111111099999088000000000
00000000088809999900000000999900000090011100999999990000999999999999999900000000000000000000000000000000000000099990888000000000
00000000008809999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999990880000000000
00000000008880999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999908880000000000
00000000000888009999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999990088800000000000
00000000000088880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008888000000000000
00000000000008888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888880000000000000
00000000000000088888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000007707070777077707770077077707770777000000070000077007770077070707700777077707770000000000000000000
00000000000000000000000000000070007070707070707070700007007000707000000700000070700700700070707070707077707000000000000000000000
00000000000000000000000000000070007770777077007770700007007700770000000700000070700700700077007070777070707700000000000000000000
00000000000000000000000000000070007070707070707070700007007000707000000700000070700700700070707070707070707000000000000000000000
00000000000000000000000000000007707070707070707070077007007770707000007000000070707770077070707070707070707770000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000088880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000888888000000000000880808088800880888088800000000000000000000080808880800088800880808080800000000000000000000000
00000000000000008871887100000000008000808080808000800080800000000000000000000080808000800080808080808080800000000000000000000000
00000000000000008871887100000088808000888088808880880088000000000000000000000000008800800088008080888000000000000000000000000000
00000000000000008888888800000000008000808080800080800080800000000000000000000000008000800080808080008000000000000000000000000000
00000000000000008888888800000000000880808080808800888080800000000000000000000000008880888080808800888000000000000000000000000000
00000000000000008888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000008808808800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000eeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000eeeeee00000000000eee0eee0eee0eee0eee0eee0eee00000000000000000e0e0e000eee0e0e0eee0e0000ee0eee0eee0e000eee0e0e000
0000000000000000ee71ee7100000000000e00e0e0e0e0e0e0e0e0e000e0e00000000000000000e0e0e000e000e0e0e0e0e000e0e0e000e000e000e000e0e000
0000000000000000ee71ee71000000eee00e00ee00eee0eee0eee0ee00ee0000000000000000000000e000ee000e00eee0e000e0e0ee00ee00e000ee00000000
0000000000000000eeeeeeee00000000000e00e0e0e0e0e000e000e000e0e000000000000000000000e000e000e0e0e0e0e000e0e0e000e000e000e000000000
0000000000000000eeeeeeee00000000000e00e0e0e0e0e000e000eee0e0e000000000000000000000eee0eee0e0e0e0e0eee0ee00e000e000eee0eee0000000
0000000000000000eeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000ee0ee0ee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000cccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000cccccc000000000000cc0cc00ccc0ccc0ccc0ccc0ccc00000000000000000c0c0ccc0ccc0ccc0c0c0000000000000000000000000000000
0000000000000000cc71cc710000000000c000c0c0c0c0c0c0c0c0c000c0c00000000000000000c0c000c0c000c0c0c0c0000000000000000000000000000000
0000000000000000cc71cc71000000ccc0ccc0c0c0ccc0ccc0ccc0cc00cc00000000000000000000000c00cc00ccc00000000000000000000000000000000000
0000000000000000cccccccc000000000000c0c0c0c0c0c000c000c000c0c000000000000000000000c000c000c0000000000000000000000000000000000000
0000000000000000cccccccc0000000000cc00c0c0c0c0c000c000ccc0c0c000000000000000000000ccc0ccc0c0000000000000000000000000000000000000
0000000000000000cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cc0cc0cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000099990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000999999000000000009990999009900990000000000000000000000000000090900990999099909990999099909900909000000000000000
00000000000000009971997100000000009090090090009090000000000000000000000000000090909000090090909090909090909090909000000000000000
00000000000000009971997100000099909990090090009090000000000000000000000000000000009990090099909990990099909090000000000000000000
00000000000000009999999900000000009000090090009090000000000000000000000000000000000090090090909000909090909090000000000000000000
00000000000000009999999900000000009000999009909900000000000000000000000000000000009900999090909000909090909090000000000000000000
00000000000000009999999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009909909900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000aaaa0000000000888800000eeee00000cccc000009999000000000000000000000000000
0000000000000ff000000000000000000000000000000000000000000aaaa00000000888888000eeeeee000cccccc00099999900000000000000000000000000
000000000000ffff000000000000000000000000000000000000000000aaaa00000017881788017ee17ee017cc17cc0179917990000000000000000000000000
00000000000ffffff00000000000000000000000000000000000000000aaaa00000017881788017ee17ee017cc17cc0179917990000000000000000000000000
00000000000ffffff00000000000000000000000000000000000000000aaaa000000888888880eeeeeeee0cccccccc0999999990000000000000000000000000
000000000000ffff000000000000000000000000000000000000000000aaaa000000888888880eeeeeeee0cccccccc0999999990000000000000000000000000
0000000000000ff000000000000000000000000000000000000000000aaaa0000000888888880eeeeeeee0cccccccc0999999990000000000000000000000000
00000000000000000000000000000000000000000000000000000000aaaa00000000880880880ee0ee0ee0cc0cc0cc0990990990000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000770077700000777077700770000000000ff000007770777000007770777007700000000000000000000000000000000
00000000000000000000000000000000007007070000070700700700000000000ffff00007000707000007070070070000000000000000000000000000000000
0000000000000000000000000000ff0000700707000007770070077700000000ffffff0007770707000007770070077700000000000000000000000000000000
0000000000000000000000000000ff0000700707000007000070000700000000ffffff0000070707000007000070000700000000000000000000000000000000
00000000000000000000000000000000077707770000070000700770000000000ffff00007770777000007000070077000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000ff000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000ddddddd000ddddd00dddddddd0000ddddddd00dddddd000000000000000000000000000000000000000000000
000000000000000000000000000000000000000dddddddd00dddddd0ddddddddd00dddddddd0dddddddd00000000000000000000000000000000000000000000
000000000000000000000000000000000000000dd0000dd000000dd0dd00dd00dd0dd0000000dd0000dd00000000000000000000000000000000000000000000
000000000000000000000000000000000000000dddddddd0ddddddd0dd00dd00dd0dd0000000dd0000dd00000000000000000000000000000000000000000000
000000000000000000000000000000000000000dddddddd0ddddddd0dd00dd00dd0dd0000000dd0000dd00000000000000000000000000000000000000000000
000000000000000000000000000000000000000dd0000000dd000dd0dd00dd00dd0dd0000000dd0000dd00000000000000000000000000000000000000000000
000000000000000000000000000000000000000dd0000000ddddddd0dd00dd00dd0dddddddd0dddddddd00000000000000000000000000000000000000000000
000000000000000000000000000000000000000dd0000000ddddddd0dd00dd00dd00ddddddd00dddddd000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00770777077707700777077700770000000007770000000000000000000005505550555055500000555050500000505055505550555055005550055055005050
07000707070007070070007007000000000007070000000000000000000050005050555050000000505050500000505050505050505050505550505050505050
07000770077007070070007007770000000007070000000000000000000050005550505055000000550055500000505055005500555050505050505050505500
07000707070007070070007000070000000007070000000000000000000050505050505050000000505000500000505050505050505050505050505050505050
00770707077707770777007007700000000007770000000000000000000055505050505055500000555055500000055050505550505050505050550050505050

__gff__
0000000000010101010101010000000000000000000101010101010101010000000000000001010101010101010100000000000000010101010101010100000000000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000039000000000000000000000000000000003940667420690a6d6e296475695f6129
__map__
1c26262626262626263526262626262626261d1c26262626262635262626352626262626261d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
170c0c0c0c0c0c0c0c180c0c0c0c0c0c0c0c15170c0c0c0c0c0c180c0c0c180c0c0c0c0c0c15000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
170d090b0c090a0b0c280c090a0b0c090b0d15170c090b0c080c280c080c280c080c090b0c15000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
170c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c15170c0c0d0c180c0c0c180c0c0c180c0d0c0c15000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
170c090b0c080c090a1a0a0b0c080c090b0c15170c190b0c390a0b0c180c090a3b0c091b0c15000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
170c0c0c0c180c0c0c180c0c0c180c0c0c0c15170c180c0c0c0c0c0c180c0c0c0c0c0c180c15000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c0606070c290a0b002800090a2b0c0506062d270c280c090b00090a3a0a0b00090b0c280c25000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000170c1800003120310000180c15000000320c0c0c0c0031000020000031000c0c0c0c32000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5e5f26270c280005063c060700280c25267e7f070c090b0c080005063c060700080c090b0c05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
323232000c0000153030301700000c00323232170c0c0c0c1800153030301700180c0c0c0c15000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4e4f06070c0800252626262700080c05066e6f1700091b0c1800252626262700180c190b0015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000170c1800000034000000180c15000000170000180c1800000034000000180c18000015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c2626270c2800090a1a0a0b00280c2526261d360b00180c2800090a1a0a0b00280c18000937000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
170c0c0c0c0c0c0c0c180c0c0c0c0c0c0c0c15270000180c0c0c0c0c180c0c0c0c0c18000025000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
170c091b0c090a0b0c280c090a0b0c190b0c153200093b0c190a0b0c280c090a1b0c390b0032000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
170d0c180c0c0c0c3301330c0c0c0c180c0d15070c0c0c0c180c0c3301330c0c180c0c0c0c05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
360b0c280c080c090a1a0a0b0c080c280c0937170c080c093b0c080c160c080c390b0c080c15000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
170c0c0c0c180c0c0c180c0c0c180c0c0c0c15170c180c0d0c0c180c0c0c180c0c0d0c180c15000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
170c090a0a3a0a0b0c280c090a3a0a0a0b0c15170c390a0a0b0c390a0a0a3b0c090a0a3b0c15000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
170c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c15170c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c15000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c06060606060606060606060606060606062d2c06060606060606060606060606060606062d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00020020080700a0700c0700d0700e0700e0700f070110701107012070130701207012070120701107011070100700f0700e0700d0700c0700b0700a070090700907009070080700807009070090700a0700a070
00020011051700c170161701d1701a170151700f1700917004170071700b1700d1700c1700917004170011700110002200021000b100041000110001100021000210001100011000110001100011000110000000
