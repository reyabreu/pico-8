pico-8 cartridge // http://www.pico-8.com
version 20
__lua__
-- missile command
-- by lummi


function _init()
 cartdata("lummis_missile_command")
 music(0)
 title="00000000ccccc000ccccccccc0ccccccccc000ccccccccc0ccccccccc0000000ccccccccccccc0000000000000000c1111c0c1111c111cc111111111c0c111111111cc111c111c0000000c11111111111c0000000000000000c11111c11111c111c11111111111c11111111111c111c111c0000000c11111111111c0000000000000000c11111111111c111c11111111111c11111111111c111c111c0000000c11111111111c0000000000000000c11111111111c111c111ccccccccc111ccccccccc111c111c0000000c111ccccccccc0000000000000000c111c111c111c111c1111111111cc1111111111cc111c111c0000000c111111c000000000000000000000c111cc1cc111c111c11111111111c11111111111c111c111c0000000c111111c000000000000000000000c111c0c0c111c111cc1111111111cc1111111111c111c111c0000000c111111c000000000000000000000c111c000c111c111ccccccccc111ccccccccc111c111c111ccccccccc111ccccccccc0000000000000000c111c000c111c111c11111111111c11111111111c111c11111111111c11111111111c0000000000000000c111c000c111c111c11111111111c11111111111c111c11111111111c11111111111c0000000000000000c111c000c111c111cc111111111c0c111111111cc111c11111111111c11111111111c0000000000000000ccccc000ccccccccc0ccccccccc000ccccccccc0ccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccc00000ccccccc00ccccc000ccccccccc000ccccc000ccccc000ccccc000cccccccccccccc00000c1111111c000c1111111c0c1111c0c1111c1111c0c1111c00c11111c00c1111c00c111c111111111c000c111111111c0c111111111cc11111c11111c11111c11111c0c1111111c0c11111c0c111c1111111111c0c11111111111c11111111111c11111111111c11111111111cc111111111cc111111cc111c11111111111cc1111ccc1111c1111ccc1111c11111111111c11111111111c1111ccc1111c111c111c111c111cccc1111cc111c000ccccc111c000c111c111c111c111c111c111c111c111ccccc111c111cc111111c111c000c111cc111c0000000c111c000c111c111cc1cc111c111cc1cc111c11111111111c111c0c11111c111c000c111cc111c000ccccc111c000c111c111c0c0c111c111c0c0c111c11111111111c111c00c1111c111c000c111cc1111ccc1111c1111ccc1111c111c000c111c111c000c111c11111111111c111c000c111c111cccc1111cc11111111111c11111111111c111c000c111c111c000c111c111ccccc111c111c000c111c11111111111c0c111111111c0c111111111cc111c000c111c111c000c111c111c000c111c111c000c111c1111111111c000c1111111c000c1111111c0c111c000c111c111c000c111c111c000c111c111c000c111c111111111c00000ccccccc00000ccccccc00ccccc000ccccccccc000ccccccccc000ccccccccc000cccccccccccccc000"
 col={0,5,6,7,13}
 mcol={6,6,13,8,2,0,2,8,13}
 gcol={2,13,3,11,4,9,1,12,8,2,11,3,9,4,12,1,5,9,3,10,2,12}
 max_speed=40
 rocket={62,116,60,120,64,120,62,120,58,124,66,124,60,124,64,124,62,124}
 hiscr=dget(0)
 hstx="hi-score "..sub("00000",#tostr(hiscr))..hiscr
 stx="000000"
 init_game()
 init_player()
 _update=update_title
 _draw=draw_title
end

function init_game()
 bgc=0
 gc=1
 pal(14,2)
 pal(15,13)
 city={8,24,40,72,88,104}
 desc={}
 bonc={}
 tboc={}
 score=0
 bs=0
 level=0
 lvl={txt="level 1",timer=0}
end

function init_player()
 player={x=63,y=63,xspeed=0,yspeed=0}
 no_shot=true
 magazin={shot=0,s_tot=27,s_load=true}
 shot={}
 explosion={}
 missile={}
 plane={}
 impact={}
 quake={0,0}
 timer=0
 attack=12
 bonus={
  shot=0,
  city=0}
 button={
  txt="",
  y=0,
  col=0}
 hole={}
end

-->8
function update_game()

-- left/right
 if (player.xspeed>0) player.xspeed-=2
 if (player.xspeed<0) player.xspeed+=2
 if btn(0) then
  player.xspeed-=4
  if (player.xspeed<-max_speed) player.xspeed=-max_speed
 end
 if btn(1) then
  player.xspeed+=4
  if (player.xspeed>max_speed) player.xspeed=max_speed
 end
 player.x+=flr(player.xspeed/10)
 if (player.x<0) player.x=0
 if (player.x>127) player.x=127
-- up/down 
 if (player.yspeed>0) player.yspeed-=2
 if (player.yspeed<0) player.yspeed+=2
 if btn(2) then
  player.yspeed-=4
  if (player.yspeed<-max_speed) player.yspeed=-max_speed
 end
 if btn(3) then
  player.yspeed+=4
  if (player.yspeed>max_speed) player.yspeed=max_speed
 end
 player.y+=flr(player.yspeed/10)
 if (player.y<0) player.y=0
 if (player.y>104) player.y=104
-- shot
 if btn(4) or btn(5) then
  if no_shot==true then
   if magazin.s_load==false then
    no_shot=false
    local dx=63-player.x
    local dy=120-player.y            
    local s={
     x1=63,
     y1=120,
     x2=player.x,
     y2=player.y,
     xs=dx/sqrt((dx*dx)+(dy*dy))*2,
     ys=dy/sqrt((dx*dx)+(dy*dy))*2,
     col=1}
    add(shot,s)
    magazin.shot-=1
    magazin.s_tot-=1
    if (magazin.shot==0) magazin.s_load=true
    sfx(0)
   else
    sfx(2,-1,1,16)
   end
  end
 else
  no_shot=true
 end

 if magazin.s_load==true then
  if #impact==0 and magazin.s_tot>0 then
   magazin.shot+=1
   if (magazin.shot==9) magazin.s_load=false
  end
 end

 if attack>0 then
  if timer<0 or (#missile+#plane)==0 then
   if (#missile+#plane)<7 then
    local sel=flr(rnd(3+level))
-- normal missile
    if sel<3 then
     if (attack<3) sel=attack-1
     calc_missile(sel,0,missile,false,sel+1)
    elseif sel==3 then
     if attack>1 then
      calc_missile(2,0,missile,false,2)
      del(missile,missile[#missile-1])
     end
-- plane
    elseif sel<6 then
     local high=flr(rnd(48)+8)
     local p={
      typ=7,
      x=-8,
      y=high,
      missile={}}
     add(plane,p)
     calc_missile(2,high+6,plane[#plane].missile,false,1)
     if plane[#plane].missile[1].dx<0 then
      plane[#plane].typ=8
      plane[#plane].x=128
     end
-- smart bomb
    else
     calc_missile(0,0,missile,true,1)
    end
  end
  else
   timer-=1
  end
-- end of level
 elseif (#missile+#plane+#explosion+#impact+#shot)==0 then
  timer=0
  _update=update_bonus
  _draw=draw_bonus   
 end
-- shot flight  
 for s in all(shot) do
  s.x1-=s.xs
  s.y1-=s.ys
  s.col+=1
  if (s.col==9) s.col=1
  if s.y1<s.y2 then
   local e={
    x=s.x2,
    y=s.y2,
    r=0,
    dr=0.5,
    col=7}
   add(explosion,e)
   del(shot,s)
   sfx(4)
  end
 end
-- plane flight
 for p in all(plane) do
  if p.typ==7 then
   p.x+=0.5
   if (p.x>127) del(plane,p)
   if #p.missile>0 then
    if p.x+4>=p.missile[1].x0 then
     add(missile,p.missile[1])
     del(p.missile,p.missile[1])
    end
   end
  else
   p.x+=-0.5
   if (p.x<-7) del(plane,p)
   if #p.missile>0 then
    if p.x+4<=p.missile[#p.missile].x0 then
     add(missile,p.missile[#p.missile])
     del(p.missile,p.missile[#p.missile])
    end
   end
  end
 end
-- missile flight
 for m in all(missile) do
  m.ti+=1
  if m.ti>m.sp then
   m.ti=0
   m.y1+=1
   m.x1+=m.dx
  end
  m.col+=1
  if (m.col==9) m.col=1
-- missile impact
  if m.y1==119 then
   if (m.x2-8)==56 then
    magazin.s_tot-=magazin.shot
    magazin.shot=0
    magazin.s_load=true
   else
				for c in all(city) do
				 if (m.x2-8)==c then 
      add(desc,c)
      del(city,c)
     end
    end
   end
--   end
   local i={
    x=m.x1,
    r=0,
    dr=0.5,
    col=7}
   add(impact,i)
   del(missile,m)
   bgc=6
   sfx(1)
  end
 end
-- explosion
 for e in all(explosion) do
  e.r+=e.dr
  if e.r==0 then
   del(explosion,e)
  else
   if e.r==10 then
    e.dr=-0.5
   end
   e.col=col[flr(rnd(5)+1)]
-- smart bomb
   for m in all(missile) do
    local dxy=sqrt(((m.x1-e.x)*(m.x1-e.x))+((m.y1-e.y)*(m.y1-e.y)))
    if m.sb==true and dxy<e.r and dxy>4 then
     m.y1=flr(e.y-((e.r+1)/dxy*(e.y-m.y1)))
     m.x1=e.x-((e.r+1)/dxy*(e.x-m.x1))
     m.dx=(m.x2-m.x1)/(119-m.y1)
    elseif dxy<e.r then
-- missile destroyed
     local ex={
      x=m.x1,
      y=m.y1,
      r=0,
      dr=0.5,
      bgcol=7}
     add(explosion,ex)
     points(10)
     if (m.sb==true) points(40)
     del(missile,m)
     sfx(1)
    end
   end
-- plane destroyed
   for p in all(plane) do
    if sqrt(((p.x+4-e.x)*(p.x+4-e.x))+((p.y+4-e.y)*(p.y+4-e.y)))-4<e.r then
     local ex={
      x=p.x+4,
      y=p.y+4,
      r=0,
      dr=0.5,
      col=7}
     add(explosion,ex)
     points(30+(#p.missile*15))
     del(plane,p)
     sfx(1)
    end
   end
  end
 end
-- impacts
 for i in all(impact) do
  i.r+=i.dr
  if i.r<=0 then
   del(impact,i)
   quake={0,0}
  else
   if i.r>=10 then
    i.dr=-0.5
   end
   i.col=col[flr(rnd(5)+1)]
   quake[1]=flr(rnd(3))-1
   quake[2]=flr(rnd(2))-1 
  end
 end
 if (bgc>1) bgc-=1
end
 
function update_bonus()
 if timer==0 then 
  if magazin.s_tot>0 then
   if magazin.shot>0 then
    magazin.shot-=1
    magazin.s_tot-=1
    bonus.shot+=1
    points(5)
    sfx(6)
    timer=2
   elseif magazin.s_tot>=9 then
    magazin.shot=9
   end
  elseif #city>0 then
   add(bonc,city[1]) 
   del(city,city[1])
   points(50)
   timer=10
   sfx(7)
  elseif bs>=4000 and #desc>0 then
   for t=1,flr(bs/4000) do
    if #desc>0 then
     local cp=flr(rnd(#desc)+1)
     add(tboc,desc[cp])
     del(desc,desc[cp])
     bs-=4000
     sfx(11)
    end
   end
  elseif #desc==6 then
--   quake={0,0}
   if score>hiscr then
    hiscr=score
    dset(0,hiscr)
    hstx="hi-score "..sub("00000",#tostr(hiscr))..hiscr
   end
   lvl.txt="game over"
   for t=0,9 do
    local e={
     x=46+rnd(36),
     y=64+rnd(5),
     r=0,
     dr=0.5,
     col=7,
     timer=(t*6)+rnd(4)}
    add(explosion,e)
   end
   _update=update_over
   _draw=draw_over
-- next level
  else
   button.txt="press any key"
   if any_key(0)==true then
    for t in all(tboc) do
     add(city,t)
    end 
    tboc={}
    for b in all(bonc) do
     add(city,b)
    end
    bonc={}
    repeat
     local sort=false
     for i=1,#city-1 do
      if city[i]>city[i+1] then
       temp=city[i]
       city[i]=city[i+1]
       city[i+1]=temp
       sort=true
       break 
      end
     end
    until sort==false
    init_player()
    level+=1
    gc+=2
    if (gc>#gcol) gc=1
    pal(14,gcol[gc])
    pal(15,gcol[gc+1])
--    quake={0,0}
--    timer=0
    titlebomb("level "..level)
    _update=update_level
    _draw=draw_level
    sfx(12)
   end
  end
 else 
  timer-=1
 end
end

function update_title()
 timer+=1
 if (timer>200) timer=0
 if #explosion==0 and any_key()==true then
  music(-1)
  for t=0,9 do
   local e={
    x=rnd(86)+21,
    y=rnd(28)+46,
    r=0,
    dr=0.5,
    col=7,
    timer=(t*6)+rnd(4)}
   add(explosion,e)
  end
 end
 for e in all(explosion) do
  if e.timer>0 then 
   e.timer-=1
   if (e.timer<0) sfx(4)
  else
   e.r+=e.dr
   if e.r==0 then
    del(explosion,e)
    if #explosion==0 then
     quake={0,0}
     timer=0
     level+=1
     titlebomb("level 1")
     _update=update_level
     _draw=draw_level
     sfx(12)
    end
   else
    if e.r==10 then
     e.dr=-0.5
     local h={
      x=e.x,
      y=e.y}
     add(hole,h)
    end
    e.col=col[flr(rnd(5)+1)]    
   end
  end
 end
end

function update_level()
 for e in all(explosion) do
  if e.timer>0 then 
   e.timer-=1
  else
   e.r+=e.dr
   if e.r==0 then
    del(explosion,e)
    if #explosion==0 then
     quake={0,0}
     timer=0
     _update=update_game
     _draw=draw_game
     sfx(-1)
    end
   else
    if (e.r==10) e.dr=-0.5
    e.col=col[flr(rnd(5)+1)]    
   end
  end
 end
end

function update_over()
 if #explosion>0 then
  bgc=flr(rnd(5)+1)
  pal(14,col[bgc])
  quake[1]=flr(rnd(3))-1
  quake[2]=flr(rnd(2))-1
  for e in all(explosion) do
   if e.timer>0 then 
    e.timer-=1
    if (e.timer<0) sfx(4)
   else
    e.r+=e.dr
    if e.r==0 then
     del(explosion,e)
    else
     if (e.r==10) e.dr=-0.5
     e.col=col[flr(rnd(5)+1)]    
    end
   end
  end
 else
  init_game()
  init_player()
  _update=update_title
  _draw=draw_title
  music(0)
 end
end

-->8
function draw_game()
 cls(col[bgc])
 map(0,0,0+quake[1],112+quake[2],16,2)
 for s=1,magazin.shot*2,2 do
  spr(6,rocket[s]+quake[1],rocket[s+1]+quake[2])
 end
 for e in all(explosion) do
  circfill(e.x,e.y,e.r,e.col)
 end
 for i in all(impact) do
  circfill(i.x,119,i.r,i.col)
 end
 for c in all(city) do
  spr(2,c+quake[1],113+quake[2],2,1)
 end
 for d in all(desc) do
  spr(4,d+quake[1],113+quake[2],2,1)
 end
 for ec=1,flr(bs/4000) do
  pset((ec*2)+quake[1],126+quake[2],15)
 end 
 for m in all(missile) do
  if m.sb==false then
   for t=m.y0,m.y1-1 do
    pset(m.x0+((t-m.y0)*m.dx),t,1)
   end
  end
  pset(m.x1,m.y1,mcol[m.col])
 end
 for p in all(plane) do
  spr(p.typ,p.x,p.y)
 end
 spr(1,player.x-3,player.y-3)
 for s in all(shot) do
  pset(s.x1,s.y1,mcol[s.col])
  pset(s.x2,s.y2,5)
 end
 print(sub("00000",#tostr(score))..score,52,0,5)
 print(sub("00000",#tostr(score))..score,51,0,6)
end

function draw_bonus()
 cls()
 map(0,0,0,112,16,2)
 for s=1,magazin.shot*2,2 do
  spr(6,rocket[s],rocket[s+1])
 end
 for c=1,flr(bs/4000) do
  pset((c*2),126,15)
 end 
 for c in all(city) do
  spr(2,c,113,2,1)
 end
 for d in all(desc) do
  spr(4,d,113,2,1)
 end
 if button.txt~="" then
  print(button.txt,66-(#button.txt*2),90,5)
  print(button.txt,65-(#button.txt*2),90,mcol[button.col])
  if button.col<7 then
   for t in all(tboc) do
    spr(2,t,113,2,1)
   end
  end 
 end
 print(stx,52,0,5)
 print(stx,51,0,6)
 print("rocket bonus: "..(bonus.shot*5),1,34,5)
 print("rocket bonus: "..(bonus.shot*5),0,34,6)
 if bonus.shot>0 then
  for t=0,bonus.shot-1 do
   if t>17 then
    spr(9,(t*7)-125,48)
   else 
    spr(9,t*7,41)
   end
  end
 end
 print("city bonus: "..(#bonc*50),1,60,5)
 print("city bonus: "..(#bonc*50),0,60,6)
 for t=0,#bonc-1 do
  spr(2,(t*15)-3,67,2,1)
 end
end

function draw_title()
 cls()
 map(0,0,0,112,16,2)
 for c in all(city) do
  spr(2,c,113,2,1)
 end
 if timer>100 then
  print(stx,52,0,5)
  print(stx,51,0,6) 
 else
  print(hstx,34,0,5)
  print(hstx,33,0,6) 
 end
 for z=0,26 do
 	for s=0,84 do
 	 pset(21+s+quake[1],46+z+quake[2],tonum("0x"..sub(title,1+(z*85)+s,1+(z*85)+s)))
  end
 end
 if #explosion>0 then
  for h in all(hole) do
   circfill(h.x+quake[1],h.y+quake[2],10,0)
  end
  for e in all(explosion) do
   if (e.timer<0) circfill(e.x,e.y,e.r,e.col)
  end
  quake[1]=flr(rnd(2))-1
  quake[2]=flr(rnd(2))-1
 else
  print(button.txt,66-(#button.txt*2),90,5)
  print(button.txt,65-(#button.txt*2),90,mcol[button.col])
 end
end

function draw_level()
 cls()
 map(0,0,0,112,16,2)
 for c in all(city) do
  spr(2,c+quake[1],113+quake[2],2,1)
 end
 for d in all(desc) do
  spr(4,d+quake[1],113+quake[2],2,1)
 end
 for ec=1,flr(bs/4000) do
  pset((ec*2),126,15)
 end 
 print(stx,52,0,5)
 print(stx,51,0,6) 
 for e in all(explosion) do
  if (e.timer<0) circfill(e.x,e.y,e.r,e.col)
 end
 print(lvl.txt,64-(#lvl.txt*2),64,0)
end

function draw_over()
 cls(col[bgc])
 map(0,0,0+quake[1],112+quake[2],16,2)
 for d in all(desc) do
  spr(4,d+quake[1],113+quake[2],2,1)
 end
 print(stx,52,0,5)
 print(stx,51,0,6) 
 for e in all(explosion) do
  if (e.timer<0) circfill(e.x,e.y,e.r,e.col)
 end
 print(lvl.txt,64-(#lvl.txt*2)+flr(rnd(2))-1,64+flr(rnd(2))-1,0)
end
-->8
function calc_missile(n,ys,msave,smart,att)
 local xs=flr(rnd(112-(n*16)))+8
 local xe=flr(rnd(9-n))*16
 local speed=3-flr(rnd(level/2))
 if (speed<1) speed=1
 for t=0,n*16,16 do
  local m={
   x0=xs+t,
   y0=ys,
   x1=xs+t,
   y1=ys,
   x2=xe+t,
   dx=((xs+t)-(xe+t))/(ys-119),
   sp=speed,
   ti=0,
   sb=smart,
   col=1}
  add(msave,m)
 end
 attack-=att
 sfx(3)
 timer=flr(rnd(400))
end

function points(pts)
 score+=pts
 stx=sub("00000",#tostr(score))..score
 bs+=pts
end

function titlebomb(txt)
 lvl.txt=txt
 for t=0,#lvl.txt-1 do
  local e={
   x=64-(#lvl.txt*2)+(t*4)+rnd(4),
   y=64+rnd(5),
   r=0,
   dr=0.5,
   col=7,
   timer=(t*6)+rnd(4)}
  add(explosion,e)
 end
end

function any_key()
 button.txt="press any key"
 for t=0,5 do
  if btn(t) then
   button.txt=""
   return(true)
  end
 end
 button.col+=1
 if (button.col==9) button.col=1
end
-->8
function draw_reynaldo()
 cols={0,5,6,7,13}
 bgc=0
 cls(cols[bgc])
 print("reynaldo",52,0,5)
 print("reynaldo",51,0,6) 
 title="00000000ccccc000ccccccccc0ccccccccc000ccccccccc0ccccccccc0000000ccccccccccccc0000000000000000c1111c0c1111c111cc111111111c0c111111111cc111c111c0000000c11111111111c0000000000000000c11111c11111c111c11111111111c11111111111c111c111c0000000c11111111111c0000000000000000c11111111111c111c11111111111c11111111111c111c111c0000000c11111111111c0000000000000000c11111111111c111c111ccccccccc111ccccccccc111c111c0000000c111ccccccccc0000000000000000c111c111c111c111c1111111111cc1111111111cc111c111c0000000c111111c000000000000000000000c111cc1cc111c111c11111111111c11111111111c111c111c0000000c111111c000000000000000000000c111c0c0c111c111cc1111111111cc1111111111c111c111c0000000c111111c000000000000000000000c111c000c111c111ccccccccc111ccccccccc111c111c111ccccccccc111ccccccccc0000000000000000c111c000c111c111c11111111111c11111111111c111c11111111111c11111111111c0000000000000000c111c000c111c111c11111111111c11111111111c111c11111111111c11111111111c0000000000000000c111c000c111c111cc111111111c0c111111111cc111c11111111111c11111111111c0000000000000000ccccc000ccccccccc0ccccccccc000ccccccccc0ccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccc00000ccccccc00ccccc000ccccccccc000ccccc000ccccc000ccccc000cccccccccccccc00000c1111111c000c1111111c0c1111c0c1111c1111c0c1111c00c11111c00c1111c00c111c111111111c000c111111111c0c111111111cc11111c11111c11111c11111c0c1111111c0c11111c0c111c1111111111c0c11111111111c11111111111c11111111111c11111111111cc111111111cc111111cc111c11111111111cc1111ccc1111c1111ccc1111c11111111111c11111111111c1111ccc1111c111c111c111c111cccc1111cc111c000ccccc111c000c111c111c111c111c111c111c111c111ccccc111c111cc111111c111c000c111cc111c0000000c111c000c111c111cc1cc111c111cc1cc111c11111111111c111c0c11111c111c000c111cc111c000ccccc111c000c111c111c0c0c111c111c0c0c111c11111111111c111c00c1111c111c000c111cc1111ccc1111c1111ccc1111c111c000c111c111c000c111c11111111111c111c000c111c111cccc1111cc11111111111c11111111111c111c000c111c111c000c111c111ccccc111c111c000c111c11111111111c0c111111111c0c111111111cc111c000c111c111c000c111c111c000c111c111c000c111c1111111111c000c1111111c000c1111111c0c111c000c111c111c000c111c111c000c111c111c000c111c111111111c00000ccccccc00000ccccccc00ccccc000ccccccccc000ccccccccc000ccccccccc000cccccccccccccc000"
	for z=0,26 do
 	for s=0,84 do 	
 		local value=tonum("0x"..sub(title,1+(z*85)+s,1+(z*85)+s))
 	 pset(21+s,46+z,value)
  end
 end
end
__gfx__
000000000000000000000000000000000000000000000000070000000000000000000000000000000000000ff0000000ff000000000000ffeeeeeeee00000000
00000000070007000000000500000000000000000000000006000000d10000000000001d00000770000000feef000000eeffffffffffffeeeeeeeeee00000000
007007000060600000005505050000000000000000000000d0d000006d510000000015d60000777000000feeeef00000eeeeeeeeeeeeeeeeeeeeeeee00000000
00077000000000000000565655050000000000000000000000000000d66667766776666d0d5667000000feeeeeef0000eeeeeeeeeeeeeeeeeeeeeeee00000000
00077000006060000005675666555000000000000000000000000000555d66655666d555d56d6000000feeeeeeeef000eeeeeeeeeeeeeeeeeeeeeeee00000000
00700700070007000005776676665000000000000000000000000000551100000000115500d6500000feeeeeeeeeef00eeeeeeeeeeeeeeeeeeeeeeee00000000
0000000000000000000677677767600000005000050000000000000011000000000000110505d0000feeeeeeeeeeeef0eeeeeeeeeeeeeeeeeeeeeeee00000000
000000000000000000077777777770000005650505605000000000000000000000000000000d0000feeeeeeeeeeeeeefeeeeeeeeeeeeeeeeeeeeeeee00000000
__label__
00000000000000000000000000000000065656665000006650665066566656665000066656650666566656665666500000000000000000000000000000000000
00000000000000000000000000000000065650650000065006500656565656500000065650650006500656565656500000000000000000000000000000000000
00000000000000000000000000000000066650650666566656500656566506650000065650650666500656665656500000000000000000000000000000000000
00000000000000000000000000000000065650650000000656500656565656500000065650650650000650065656500000000000000000000000000000000000
00000000000000000000000000000000065656665000066500665665065656665000066656665666500650065666500000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000ccccc000ccccccccc0ccccccccc000ccccccccc0ccccccccc0000000ccccccccccccc000000000000000000000000000000
00000000000000000000000000000c1111c0c1111c111cc111111111c0c111111111cc111c111c0000000c11111111111c000000000000000000000000000000
00000000000000000000000000000c11111c11111c111c11111111111c11111111111c111c111c0000000c11111111111c000000000000000000000000000000
00000000000000000000000000000c11111111111c111c11111111111c11111111111c111c111c0000000c11111111111c000000000000000000000000000000
00000000000000000000000000000c11111111111c111c111ccccccccc111ccccccccc111c111c0000000c111ccccccccc000000000000000000000000000000
00000000000000000000000000000c111c111c111c111c1111111111cc1111111111cc111c111c0000000c111111c00000000000000000000000000000000000
00000000000000000000000000000c111cc1cc111c111c11111111111c11111111111c111c111c0000000c111111c00000000000000000000000000000000000
00000000000000000000000000000c111c0c0c111c111cc1111111111cc1111111111c111c111c0000000c111111c00000000000000000000000000000000000
00000000000000000000000000000c111c000c111c111ccccccccc111ccccccccc111c111c111ccccccccc111ccccccccc000000000000000000000000000000
00000000000000000000000000000c111c000c111c111c11111111111c11111111111c111c11111111111c11111111111c000000000000000000000000000000
00000000000000000000000000000c111c000c111c111c11111111111c11111111111c111c11111111111c11111111111c000000000000000000000000000000
00000000000000000000000000000c111c000c111c111cc111111111c0c111111111cc111c11111111111c11111111111c000000000000000000000000000000
00000000000000000000000000000ccccc000ccccccccc0ccccccccc000ccccccccc0ccccccccccccccccccccccccccccc000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000ccccccc00000ccccccc00ccccc000ccccccccc000ccccc000ccccc000ccccc000cccccccccccccc0000000000000000000000000
00000000000000000000000c1111111c000c1111111c0c1111c0c1111c1111c0c1111c00c11111c00c1111c00c111c111111111c000000000000000000000000
0000000000000000000000c111111111c0c111111111cc11111c11111c11111c11111c0c1111111c0c11111c0c111c1111111111c00000000000000000000000
000000000000000000000c11111111111c11111111111c11111111111c11111111111cc111111111cc111111cc111c11111111111c0000000000000000000000
000000000000000000000c1111ccc1111c1111ccc1111c11111111111c11111111111c1111ccc1111c111c111c111c111cccc1111c0000000000000000000000
000000000000000000000c111c000ccccc111c000c111c111c111c111c111c111c111c111ccccc111c111cc111111c111c000c111c0000000000000000000000
000000000000000000000c111c0000000c111c000c111c111cc1cc111c111cc1cc111c11111111111c111c0c11111c111c000c111c0000000000000000000000
000000000000000000000c111c000ccccc111c000c111c111c0c0c111c111c0c0c111c11111111111c111c00c1111c111c000c111c0000000000000000000000
000000000000000000000c1111ccc1111c1111ccc1111c111c000c111c111c000c111c11111111111c111c000c111c111cccc1111c0000000000000000000000
000000000000000000000c11111111111c11111111111c111c000c111c111c000c111c111ccccc111c111c000c111c11111111111c0000000000000000000000
0000000000000000000000c111111111c0c111111111cc111c000c111c111c000c111c111c000c111c111c000c111c1111111111c00000000000000000000000
00000000000000000000000c1111111c000c1111111c0c111c000c111c111c000c111c111c000c111c111c000c111c111111111c000000000000000000000000
000000000000000000000000ccccccc00000ccccccc00ccccc000ccccccccc000ccccccccc000ccccccccc000cccccccccccccc0000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000088858885888508850885000088858850858500008585888585850000000000000000000000000000000000000
00000000000000000000000000000000000000085858585850085008500000085858585858500008585850085850000000000000000000000000000000000000
00000000000000000000000000000000000000088858850885088858885000088858585888500008850885088850000000000000000000000000000000000000
00000000000000000000000000000000000000085008585850000850085000085858585008500008585850000850000000000000000000000000000000000000
00000000000000000000000000000000000000085008585888588508850000085858585888500008585888588850000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d00000000000000000000000000000000000000000000000000000000000000dd00000000000000000000000000000000000000000000000000000000000000d
2d000000000000000000000000000000000000000000000000000000000000d22d000000000000000000000000000000000000000000000000000000000000d2
22d0000000000005000000000000000500000000000000050000000000000d2222d0000000000005000000000000000500000000000000050000000000000d22
222d00000000550505000000000055050500000000005505050000000000d222222d00000000550505000000000055050500000000005505050000000000d222
2222d000000056565505000000005656550500000000565655050000000d22222222d000000056565505000000005656550500000000565655050000000d2222
22222d0000056756665550000005675666555000000567566655500000d2222222222d0000056756665550000005675666555000000567566655500000d22222
222222d00005776676665000000577667666500000057766766650000d222222222222d00005776676665000000577667666500000057766766650000d222222
2222222d000677677767600000067767776760000006776777676000d22222222222222d000677677767600000067767776760000006776777676000d2222222
22222222dd077777777770dddd077777777770dddd077777777770dd2222222222222222dd077777777770dddd077777777770dddd077777777770dd22222222
2222222222dddddddddddd2222dddddddddddd2222dddddddddddd22222222222222222222dddddddddddd2222dddddddddddd2222dddddddddddd2222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222

__map__
0b0000000000000a0b0000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0c0d0c0d0c0d0e0e0c0d0c0d0c0d0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00040000016200162001630026300364005650086500c64014640246000160000000000003c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002c63022630186300f630076300e62015620196201b6271c6271c6271c6271b6271962715627116270c617106171361714617136170f6170b6170e6170f6170e6170b617076170a6070a6070860005600
000400002b0102c0102e01032010380000100031000010000000000000000000000000000000000000000000000000d0000d0000d000065000750010000077000f70017700217002770035000325000000000000
000300003001030011000000000030010300103001030011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000236202662027620276102661024610226101f6101c6101961016610196101b6101d6101d6101c6101a6101861014610106100e610106101261012610106100d610096100b6100c6100c6100a61006610
000400000102003020040200402003020010200102003020040200402003020010200200001000000000000000000000000000000000000003400037000380003500000000000000000000000000000000000000
00020000100250e6000c6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001a6200d610046100261001610016000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00040c4150c41500415004150c4050c40500405004050c4050c40500405004050c4050c40500405004050c4050c40500405004050c4050c40500405004050c4050c40500405004050c4050c4050040500405
000c0020184151a415184151a4151a415000001a41500000184001a400184001a4001a400000001a40000000184151a415184151a4151a415000001a41500000184151a415184151a4151a415000001a41500000
000c0020004000c415184000c4150c415004000a40010400004000a4000c400004001841518415114151341500400134150a4001341513415004000a4000c400004000c40016400004001641516415114150c415
00050000185201852018520000001852018520185200000018520185201852000000185201852018520000001b5201b5201b520000001a5201a5201a520000001852018520185200000016520165201652016520
0006000025714287212a7212a7212872125711247112471125714287212a7212a7212872125711247112471125714287212a7212a7212872125711247112471125714287212a7212a72128721257112471124711
010600081861524600246150c600186150e0000c6151070515705187051a7051e705257052c705347053b705357052d70526705207051b70516705127050f7050e7050b705097050670503705027050170501705
00030000065050550504505015050150503505065050a5050a5050a5050950507505075050a5050e5051250513505115050f505095050a5050c50510505155051550513505105050f50513505175051b5051c505
000500001330200300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001530200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001730200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
02 08090a47
06 4b4c4344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
06 48424344

