pico-8 cartridge // http://www.pico-8.com
version 20
__lua__
lcw=16
sf=128-32
oxy_max=1000
ldp=20
metal=false

function _init()
 reset()
end


function reset()
 music(10)
 
 inboat=false
 ending=false
 title=true
 grab=nil
 
 oxy=oxy_max
 air=5
 
 ents={}
 depth={}
 bubs={}
 logs={}

 clb=0
 beep=0
 pry=0
 mdp=0
 cdp=0
 t=0

 
 lvl=0
 mvy=0
 print_levels() 
  
 hero=mke(64,64,64)--256
 hero.ww=16
 hero.hh=16
 hero.upd=upd_hero
 hero.bnx=bnx_hero
 hero.we=.5
 hero.ol=true
 hero.ls={ 
  5,3,12,3,12,8,12,15,5,15,5,8,
 } 
 hero.dr=dr_hero

 -- hair
 local par=hero
 for i=0,3 do
  local e=mke(0,0,0)
  e.par=par  
  e.dp=0
  e.ol=true
  e.hair=true
  e.upd=upd_hair
  e.dr=function(e,x,y)
   if not hero.ss then return end
   local cl=(e.par==hero or e.par.y+1.5>y) and 8 or 2
   circfill(x,y,4-i,cl)
      
  end  
  par=e  
 end
 
 -- boat
 boat=mke(0,48,96)
 boat.perm=true
 boat.upd=function()
  boat.vis=lvl==0
  local d=(sf-boat.y)
  if abs(d)<16 then
   boat.vy+=d/10
  end
 end
 
 boat.dr=function(e,x,y)
  map(16,16,x,y-4,4,1) 
 end
 
 --
 inboat=true
 
 -- fad
 fad=4
 local f=function(e)
  fad*=.9
  if fad<1 then
   fad=nil
   kl(e)
  end
 end
 loop(f)
 
 
end

function loop(f,t,nxt)
 local e=mke(0)
 e.perm=true
 e.upd=f
 e.life=t
 e.nxt=nxt
 return e
end

function dr_hero(e,x,y)

 if grab then
  local s=e.flp and -1 or 1
  grab.flp=e.flp
  grab.x=x+4+s*8
  grab.y=y+2
  if e.fr>64 then
   grab.x+=s*2
   grab.y-=2
  end
  if e.fr==68 then grab.y-=1 end
  if e.fr==70 then grab.y+=2 end
  if crouch then
   grab.x-=s*6
  end   
  dre(grab)
 end

end

function upd_hair(e)

 if not hero.ss then
  e.x=hero.x+8
  e.y=hero.y+8
  return
 end

 e.y+=.25  
 --e.x+=cos(t/80+e.y/40)*.25
 --e.x+=cos(e.y/20)*.25
 
 
 local px=e.par.x
 local py=e.par.y
 if e.par==hero then
  px+=8
  py+=4
  if crouch then
   py+=5
  end 
  if hero.upd==upd_climb then
   py-=4
  end
     
 end
 local dx=e.x-px
 local dy=e.y-py
 local dd=sqrt(dx*dx+dy*dy)
 if dd>3 then dd=3 end
 local an=atan2(dx,dy)
-- an+=cos(t/80+i/5)*.04
 e.x=px+cos(an)*dd
 e.y=py+sin(an)*dd   

end


function bnx_hero(e)
 
 k=sgn(e.vx)
 
 e.vx=0 
 if e.vy<0 or ground or e.dead then return end
 
 
 crawl()
	for dy=0,15 do
	 if not ecol(e,k,-dy) and ecol(e,k,1-dy) then
	  sfx(6,nil,3,1)
	  cly=e.y+7-dy
	  clx=e.x+k+1
	  clk=k	  
	  e.upd=upd_climb
	  return
	 end
	end
	uncrawl()
	
	
end

function upd_climb(e)
 
 e.vy=0
 e.x+=(clx-e.x)*.5
 e.y+=(cly-e.y)*.5
 

 
 if clk then
		 
		local cb=flr((clk+1)/2)
		 
	 if btnp(4) or btnp(3) or btn(1-cb) then
	 	hero.upd=upd_hero
	 	hero.nograv=nil
	 	uncrawl()   
	 	while ecol(e) do
	 	 e.x-=clk
	 	end
	 	return
	 end		 
			 
		if btn(cb) then
		 clb+=1
		else
		 clb=0
		end 
 
  e.fr=96
	 if clb>=8 then
	  e.fr=98
	  clx+=clk*4
	  cly-=7
	  clk=nil
	  sfx(6,nil,4,1)
	  clb=0
	  e.ccl=4
	 end 
 elseif not e.ccl then
  e.x=clx
  e.y=cly
  e.upd=upd_hero 
 end
end

function upd_drown(e)
 
 
 
 if e.cdrown then
  local c=e.cdrown/100
  e.flp=flr(c*c*100)%12<6  
  if rnd()<c/2 then
		 local b=bub(e.x,e.y)
		 b.vx*=.3
  end
  if e.cdrown < 4*10 then
   fad=4-e.cdrown/10
  end
 else
  reset()
  return
 end

 e.ss=true
 --e.flp=t%16<8
 e.we=-.1
 e.fr=102
 
 if lvl==0 then
  if e.y<sf+2 then e.y=sf+2 end
 end
 

end

function upd_hero(e)
 
 
 
 
 if title then e.ctit=16 end
 
 local sploosh=function(vy)
  if inboat then return end
  local b=bub(e.x+4+rand(8),e.y)
  b.vy+=rnd(vy)
 end
 
 -- oxygen
 if not ending and lvl+(hero.y-sf)>1 then
	 oxy-=1
	 if oxy<=0 then
	  oxy+=oxy_max
	  if air>0 then
	   air-=1
	  else
	   if not hero.ss then
	    destroy_suit()
	   end
	   gameover()	   
	  end
	 end
 end
 
 e.fr=64
 ground=ecol(e,0,1)
 moving=false
 if ground then e.vy=0 end
 
 function hrun(dx)
  local spd=crouch and .2 or .5
  e.vx+=dx*spd
  moving=true
 end
 
 if btn(0) then hrun(-1,0) end
 if btn(1) then hrun(1,0) end
 
 --
 if inboat then
  e.y=boat.y-16
  e.vy=0
  if e.x<boat.x then
   boat.x=e.x
  end
  if e.x>boat.x+16 then
   boat.x=e.x-16
  end
 end
 
 --jump
 if jumping and not btn(4) then
  jumping=false
 end
 
 if e.cjmp and (btn(4) or (e.cbnc and not btn(3) ) ) then
  
  if e.y+24>sf then
  e.vy-=e.cjmp/6 
  end 
 elseif btnp(4) and not jumping then 
  local ok = ground or inboat
  if not ok and air>0 then
   hero.cbreath=20
   hero.cdjp=8
   ok=true
   for i=0,6 do sploosh(2) end
  end
  if ok and not ending then
   if inboat then
    inboat=false
    boat.vy=3.5
    if title then music(0) end
		  title=nil 
		  
   end
   jump()
   sfx(3,nil,1)
  end
 end
 
 -- crouch
 if not crouch and ground and btn(3) then
  crawl()
 end
 if crouch and (not ground or not btn(3)) then
  uncrawl()
  if ecol(e) then
   crawl()
  end
 end 
 --launch/release
 if btnp(5) and grab then
	  sfx(2)
	  launch() 
 end
 
 -- monster cols
 for m in all(ents) do
  if m.hit then
   if hcol(m) then 
    m.hit(e)
   end
  end
 end
 
 -- frame
 if not ground and not inboat then
  e.fr=e.vy>0 and 70 or 68
 elseif moving or crouch then
  e.fr = crouch and 98 or 64
  e.fr += flr((e.x/8)%2)*2
 end
 e.flp=e.vx<0
 
 -- bub 
 if rand(16)==0 then
  sploosh(0)
 end

 -- chk warp
 if e.y<128 and lvl>0 then
  scroll(-1)
 end
 if e.y>384-64  then
  scroll(1)
 end
 
 -- max depth
 cdp=(lvl*128+hero.y)/10-8
 if cdp<0 then cdp=0 end
 if cdp > mdp then
  mdp=cdp
 end
 
 -- chk boat
 if lvl==0 and e.vy>0 and e.x>boat.x and e.x<boat.x+16then
  local by=boat.y-16
  if e.y<by and e.y+e.vy>by then
   inboat=true
   sfx(18)
   boat.vy+=4
   
   if mdp>=ldp then
    ending=true
    hero.ccong=32
    sfx(17)
    music(-1)
   end
  end 
 end
 
 
end

function gameover()
 music(-1)
 sfx(12)
 hero.dead=true
 hero.upd=upd_drown
 hero.cdrown=80
end

function hcol(e)
 for i=0,#hero.ls/2-1 do
  local x=hero.x+hero.ls[1+i*2]
  local y=hero.y+hero.ls[2+i*2]
  if ept(e,x,y) then return true end
 end
 return false
end

function ept(e,x,y)
 return x>=e.x and x<e.x+e.ww and y>=e.y and y<e.y+e.hh
end


function launch()
 
 local e=grab
 
 e.lpx=false
 e.frict=1
 e.vx=hero.flp and -5 or 5
 e.y=hero.y+4
 
 function bnc()
  impact(e.x,e.y,16,true)
  sfx(4)
  bang(e)
  local x,y =find_shell(e.x,e.y)
  if x then open_shell(x,y) end 
 end  
 
 e.upd=function(e)
  e.fr=170+(t/4)%4
  local b =bub(e.x+4,e.y+4)
  b.vx=rnd()*e.vx
  for m in all(ents) do
   if m.hit and ecole(m,e) then
    m.vx=-e.vx
    bang(m)
    bnc() 
   end
  end 
  
  if e.x<0 or e.x+e.ww>128 then
	  bnc()
  end
   
 end
 add(ents,grab)
 

 e.hit=nil
 e.dr=nil
 e.bnx=bnc
 e.bny=bnc
 grab=nil
 
 if ecol(e) then 
  e.fr=170
  bnc()
 end
 
end

function impact(x,y,r,inv)
 shk=6

 local e=mke(0,x,y)
 e.life=6
 e.dr=function(e,x,y)
  local c=e.life/6
  if inv then c=1-c end
  circfill(x,y,r*c,sget(6-e.life,6))
 end
end


function open_shell(x,y,empty)
 sfx(16)
 
 local sl=lvl+flr(y/16)
 hero["shell_"..sl] = true
 
 for dx=0,1 do for dy=0,1 do  
  mset(x+dx,y+dy-1,136+dx+dy*16)
 end end
 
 if empty then 
  return
 end
 
 local b=mke(0,x*8+8,y*8-4)
 --b.we=-.05
 b.r=7
 
 local kk=32
 b.dr=function(e,x,y)
  local ec=2
  if e.frz then
   ec=3*frz/kk
  end
  circ(x,y+sin(t/40)*ec+.5,e.r,7)
 end
 
 local fill=0
 
 b.upd=function(e)
 
 
  local dx=hero.x+8-e.x
  local dy=hero.y+8-e.y 
 
  if e.frz then
   local c=frz/kk
   e.r=c*7
   oxy+=fill
   
   e.x+=dx/kk
   e.y+=dy/kk
   
   return
  end
  

  if sqrt(dx*dx+dy*dy)<12 then
   frz=kk
   e.frz=true
   e.life=kk
   fill=flr((oxy_max-oxy)/kk)
   sfx(9)
  end 
    
 end
 
 
end


function find_shell(x,y)
 local px=flr(x/8)
 local py=flr(y/8)
 --log("find at "..px..","..py)
 for dx=-2,2 do for dy=-2,2 do
  local x=(px+dx)%16
  local y=py+dy
  local n=mget(x,y)
  if n==168 then
   return x,y
  elseif n==169 then
   return (x-1)%128,y
  end
 end end
 return nil

end



function bang(e)
 e.upd=nil
 e.we=.5
 e.vx*=-1
 e.vy=-1-rnd(2)
 e.life=32
 e.blk=true
 e.frict=.96
 e.ls=nil
 e.flx=false
 e.hit=nil
end

function wait(t,f,a,b,c)
 local e=mke()
 e.life=t
 e.nxt=function() f(a,b,c) end
end

function hit_hero(from)
 
 if metal then return end
 
 if hero.cinv then return end
 hero.cinv=32
 from.ckil=16
 frz=16
 sfx(5)
 
 if hero.ss then
  wait(1,gameover)  
 else
  hero.ctrans=2
  hero.ss=true
  hero.vy=-8

  wait(1,destroy_suit)
  
 end
 
 
end

function destroy_suit()
 sfx(8)
 for i=0,5 do
  local p=mke(138+i,hero.x,hero.y)
  p.life=40+rand(20)
  p.we=.1
  p.ol=true
  --p.frz = true
  p.blk=true
  p.frict=.96
  impulse(p,rnd(),2)
 end
end


function impulse(e,an,spd)
 e.vx=cos(an)*spd
 e.vy=sin(an)*spd
end



function jump()

 jumping=true
	hero.vy=-4
	hero.cjmp=16

end

function ecole(a,b) 
 if a.x>b.x+b.ww or
    a.x+a.ww < b.x or
    a.y > b.y+b.hh or
    a.y+a.hh < b.y
 then
  return false
 else
  return true
 end

end

function kl(e)
 del(ents,e)
end

function crawl()
 crouch=true
 hero.ls={ 
  12,8,12,15,5,15,5,8,
 } 
end
function uncrawl()
 crouch=false
 hero.ls={ 
  5,3,12,3,12,8,12,15,5,15,5,8,
 }  
end



function scroll(n)
 lvl+=n 
 for e in all(ents) do
  e.y-=n*128  
 end 
 for e in all(bubs) do
  e.y-=n*128  
 end  
 --print_levels()
  
 -- offset map
 for oy=0,16*3-1 do
  local y=n>0 and 16+oy or 47-oy
  for x=0,15 do
   mmset(x,y-n*16,mget(x,y))
  end  
 end
 
 -- gen new screen
 
 
 local dy=n>0 and 3 or 0
 local k=depth[1+lvl+dy]
 if not k then
  k=rand(9999)
  if dy+lvl==0 then k=-1 end
  add(depth,k)
 end 
 gen_screen(dy,k)
 
 
end

function bub(x,y)
 sfx(1)
 local b={
  x=x,y=y,sz=1+rand(3),
  we=-.05-rnd(.1),
  vx=rnd(3)-1,vy=0,
 }
 add(bubs,b)
 return b
end


function pmov(e,dx,dy) 
 
 if e.bnx then
  bnx = e.bnx
  bny = e.bny
 end
 
 -- ghost
 if ecol(e) and not e.noghost then
  e.x+=dx
  e.y+=dy
  return
 end
 
 -- x
 e.x+=dx
 while ecol(e) do
  e.x-=sgn(dx)
  if bnx then 
   bnx(e)
   bnx=nil 
  end
 end
 
 -- y
 e.y+=dy
 while ecol(e) do
  e.y-=sgn(dy)
  if bny then 
   bny(e)
   bny=nil 
  end  
 end

end

function ecol(e,dx,dy)
 dx=dx or 0
 dy=dy or 0
 if not e.ls then
  return false
 end
 for i=0,#e.ls/2-1 do 
  local x=dx+e.x+e.ls[i*2+1]
  local y=dy+e.y+e.ls[i*2+2]
  if pcol(x,y) then 
   return true 
  end
 end
 return false
end


function pcol(x,y)
 --if x<0 or x>=128 then return true end
 x=x%128
 return fget(mget(x/8,y/8),0)
end

function rand(n)
 return flr(rnd(n))
end

function print_levels()


 for i=0,3 do 
  local k =depth[i+lvl+1]
  if not k then
   k=rand(9999)
   if i+lvl==0 then
    k=-1
   end
   add(depth,k)
  end  
  gen_screen(i,k)
 end
 
 
end


function mmset(x,y,n)
 mset(x,y,n)
end

function gen_screen(dy,k)

 for x=0,15 do for y=0,15 do
  mmset(x,dy*16+y,0)
 end end
 
 -- log
 local clv = lvl+dy
 --log("gen clv:"..clv.." k:"..k.." dy:"..dy)
 
 
 -- empty
 if k<0 then
  return
 end
 
 -- bborders
 for i=0,1 do
  for y=0,16 do
   mmset(i*15,dy*16+y,mget(16,y))
  end
 end
 srand(k)
 local big=true
 
 local plats=3
 if clv>2 and rand(2)==0 then plats-=1 end
 for i=1,10 do
  if clv>i*5 and rand(4)==0 then 
   plats-=1 
  end
 end
 if plats<0 then plats=0 end

 local free=13-(plats+1)*4
 
 local y=dy*16+2
 
 for j=0,plats do 
  --local sx=rand(12)
  --local ex=sx+rand(min(6,15-sx))
  --local y=dy*16+i*(4+rand(2))  
  local size=1+rand(4)+rand(4)
  sx=rand(16)
 
  for i=0,2 do 
	  for dx=0,size do
	   local x=(sx+dx)%16
	   local y=y+i	   
	   local fr=21
	   
	   -- herbs
	   if mget(x,y-1)==0 then
	    fr=16+rand(5)
	   end
	   	   
	   if i==0 then
		   mmset(x,y,fr) 
		   -- wall
		   
		   --[[
			  local h=0
		   for j=1,12 do
		    if mget(x,y-j)>0 then
		     break
		    end
		    h=j
		   end	   
		   if h<8 then
		    for j=1,h do
		     local fr=9+rand(3)
		     if j==h then fr=9 end
		     mmset(x,y-j,fr)
		    end
		   end
		   --]]
		   
		   -- algae
		   if rand(2)==0 then
		    mmset(x,y-1,32+rand(4))
		   end				      
	   else
	    mmset(x,y,fr)
	   end	
	  end
	  

	  -- shells
	  if i==0  then
	   if big and rand(2)==0 then
	    local px=sx+rand(size-1)
	    if px<15 then
		    for i=0,1 do
		     mmset((px+i)%16,y-1,168+i)
		    end	  
		    if hero and hero["shell_"..clv] then
		     open_shell(px%16,y-1,true)
		    end
		    big=false
	    end
	   elseif rand(2)==0 then
	    mk_shell((sx+rand(size))*8,(y-1)*8)
	   end
	  end  
	  
	  -- size change
   if i==0 and rand(size)==0 then
    size+=2
   else
    size=flr(size/1.5+.5)
   end
   sx+=rand(3)-1
  end
  
  if rand(2)==0 then  
   mk_fish(16+rnd(96),(y+3)*8)
  end
  
  
  y+=4
  if free>0 then
	  local f=rand(free)
	 	free-=f
	 	y+=f
 	end
 end 
 
 -- walls 
 for x=0,15 do 
  local wall=0
	 for y=0,15 do 
	  local by=dy*16+15-y
	  
	  if mget(x,by)==21 then
	   for j=0,1 do
		   if not fget(mget(x-(j*2-1),by),0) and
		      not fget(mget(x,by+1),0) then
		    mset(x,by,23-j) 
		   end 
    end
	   
	  end
	  
	  if fget(mget(x,by),0) then	 
	   if wall>=1 and wall<5 then
	    for ny=1,wall do
	    	local fr=9+rand(3)
			   if ny==1 then fr=9 end
			   if mget(x,ny+by)==0 then
	      mset(x,ny+by,fr)
	     end
	    end
	   end  
	   wall=0
	  else  
	   wall+=1
	  end
	 end 
	 
	 
 end 
 

end

function mk_shell(x,y)

 local e=mke(0,x,y)
 e.flp=rand(2)==0
 e.ls={0,0,0,7,7,7,7,0}
 e.ol=true
 local walk=true

 e.upd=function()
  e.fall=not ecol(e,0,1)
  if e.fall then
   e.y+=1
   return
  end
 
  local dx=hero.x-e.x
  local dy=hero.y-e.y 
  walk=abs(dx)>32 or abs(dy)>16
  if not walk then return end
  local k=e.flp and -1 or 1
  local hdy = hero.y-e.y
  local fall = hdy>0 and hdy<128
  if (ecol(e,k*8,1) or fall) and not ecol(e,k) then
   e.x+=k/3
  else
   e.flp=not e.flp
  end  

 
 end
 
 e.dr=function(e,x,y)
  if walk then
	  sspr(88,72,8,4,x,y+4,8,4,e.flp)
	  y-=2
  end
  spr(154,x,y,1,1,e.flp)  
 end
 
 e.hit=function(h)
  
  if ground and not e.fall then
   if btnp(5) and not grab and not e.clv then
    grab=e
    sfx(6,nil,0,2)
    kl(e)
   end
  elseif h.vy>0 or e.fall then
   hit_hero(e)
  end
  
 end
 
 
 
 
end

function mk_fish(x,y)
  
 local e=mke(0,x,y)
 local s=rand(2)*2-1
 e.ww=16
 e.ol=true
 e.flp=rand(2)==0
 e.upd=function(e)
  if e.cpain then return end
  e.x+=(e.flp and -1 or 1)
  if e.x+e.ww>128 or e.x<0 then
   e.flp= not e.flp
   e.x+= (e.flp and -8 or 8)
  end   
 end
 
 e.dr=function(e,x,y)
 
  for i=0,1 do  	
  	local ki=e.flp and i or 1-i
   local fr=31
   if e.cpain then
    fr+=16
   end   
   if ki==1 then 
    fr=28+flr(t/8)%4
    if fr==31 then fr-=2 end
   end  	
   spr(fr,x+i*8,y,1,1,e.flp)
  end
 end
 
	e.hit=function(h)
  if h.vy>0 and h.y+8<e.y then
   h.cbnc=16
   jump()
   sfx(6,nil,9,2)
	  e.cpain=32
	  e.hit=nil
	  e.life=24
	  e.blk=true 
	  e.vy=8
	  e.we=-.5
  else
   hit_hero(e)
  end
 end
 
end



function mke(fr,x,y)
 local e={
  fr=fr or 0,
  x=x or 0, y=y or 0,
  vx=0,vy=0,
  ww=8, hh=8,
  we=0, frict=.8,
  flp=false, dp=1, vis=true,
  lpx=true
 }
 e.bnx=function() e.vx=0 end
 e.bny=function() e.vy=0 end
 
 add(ents,e)
 return e
end

function upe(e)

 if frz and not e.frz then return end

 if not e.nograv then
  e.vy+=e.we
 end
 e.vx*=e.frict
 e.vy*=e.frict
 
 if e.ls then
  pmov(e,e.vx,e.vy)
 else
  e.x+=e.vx
  e.y+=e.vy
 end
 --
 if e.upd then e.upd(e) end
 
 -- counters
 for v,n in pairs(e) do
  if sub(v,1,1)=="c" then
   n-=1
   if n<=0 then
    e[v]=nil
   else
    e[v]=n
   end
  end
 end  
 
 -- life
 if e.life then
  e.life-=1
  if e.life<16 and e.blk then
   e.vis=t%2==0
  end  
  if e.life<=0 then
   kl(e)
   if e.nxt then
    local f=e.nxt
    e.nxt=nil
    f()
   end
  end
 end  
 
 --boundaries
 if (e.y<e.hh or e.y>512) and not e.perm then
  kl(e)
 end
 
 --specific
 if e.cbreath then oxy-=25 end
 
 --loop
 if e.lpx then e.x=e.x%128 end
  
 
end

function dre(e,ddx,ddy)
 ddx=ddx or 0
 ddy=ddy or 0
 if dpt!=e.dp or not e.vis then return end
 local fr=e.fr
 local x=e.x+ddx  
 local y=e.y+ddy
 
 if fget(fr,1) then
  y-=1
 end
 
 if e.ss and (not e.ctrans or t%4<2) then
  fr+=8
 end 

 
 if e.ckil and t%4<2 and ddx+ddy==0then
  apal(8)
 end
  
 local function f(e,x,y)
	 if fr>0 then
	  spr(fr,x,y,e.ww/8,e.hh/8,e.flp)
	 end 
	 if e.dr then e.dr(e,x,y) end
	end	
	f(e,x,y) 
	if e.lpx then
	 if e.x<0 then
	  f(e,x+128,y)
	 end
	 if e.x+e.ww>=128 then
	  f(e,x-128,y)
	 end
 end
 apal()
  
end

function apal(n)
 
 if lockpal then return end
 if not n then 
   for i=0,15 do 

    pal(i,i) 
   end
   return
 end
 for i=0,15 do pal(i,n) end
end

function upb(e)
 e.vx*=.97
 e.vy*=.97
 e.vy+=e.we
 e.x+=e.vx 
 e.y+=e.vy 
 if lvl==0 and e.y<96 then
  e.y=96
  if not e.sf then
   e.sf=true
   e.life=16
  end
 end
 if e.life then e.life-=1 end
 
 if hero.y-e.y > 64 or e.life==-1 then
  del(bubs,e)
 end
 
 
 
end
function drb(e)
 local r=e.sz
 if bfl==7 then r+=1 end
 local y=e.y
 if bfl==1 and e.sf then
  --y+=1
  --r+=1
 end
 
 
 circfill(e.x,y,r,bfl)

end


mmvy=0

function _update()

 t=t+1
 foreach(ents,upe)
 if frz then
  frz-=1
  if frz==0 then frz=nil end
  return
 end
 
 
 foreach(bubs,upb)
 mvy+=hero.vy
 mvy*=.96
 pry+=hero.vy
 
 
 -- algae
 for y=0,7 do
	 for x=0,32 do
	  local n=sget(x,y+24)
	  local ec=2*(1-y/7)
	  local dx=flr(x/8)
	  sset(x+cos(t/32+y/8+dx/4)*ec,y+16,n)
	 end
 end
 
 -- warning
 local wc= 4*oxy/oxy_max
 if air==0 and  wc<1 and not ending then
  
  beep+=(1-wc)/4
  
  if beep>0 then
   beep-=1
   sfx(6,3,6,1)
  end
 end
 
 --ending=true
 if ending then
  
  if btnp(4) or btnp(5) and not hero.ccong then
   reset()
  end
  
  if t%16==0 then
   firework()
  end

 end
end

function firework()  
 local e=mke(137,64,64)
 e.dp=10
 e.ww=1
 e.hh=1
 impulse(e,.25-(rnd(2)-1)/10,5)
 e.we=.1
 e.frict=.96
 e.perm=true
 e.paint=4+rand(4)
 e.upd=function(e)
  if e.vy>0 and rand(4)==0 then
   exp(e)
   sfx(7)
  end
 end
  
end

function exp(b)
 kl(b)
 for i=0,32 do
  local e=mke(0,b.x,b.y)
  impulse(e,i/32,3)
  e.frict=.8+rnd(.18)
  e.life=10+rand(15)
  e.we=.01+rnd(.1)
  e.perm=true
  e.dp=10
  e.lpx=false
  local ox=b.x
  local oy=b.y
  local lm=e.life
  e.dr=function(e,x,y)
   local cl=sget(7-e.life*7/lm,b.paint)
   line(ox,oy,x,y,cl)
   ox=x
   oy=y
  end
  
 end

end


function drol(e)
 if not e.ol then return end
 dpt=e.dp
 apal(1)
 lockpal=true
 dre(e,-1,0)
 dre(e,1,0)
 dre(e,0,1)
 dre(e,0,-1)
 lockpal=false
 apal()

end


function _draw()
 cls(1)

 
 for i=0,15 do
	 local k=i
	 if fad then
	  k=sget(32+i,fad)
	 end
	 if k==5 then k=131 end
  pal(i,k,1)
 end
 
 if ending then
  mvy=-128
 end
 mmvy+= (mvy-mmvy)*.01
 

 -- parallax
 local hcy=hero.y+8-64+flr(mmvy)
 if hcy<0 then hcy=0 end

 for i=0,2 do 
  for k=0,1 do
   for l=1,2 do
    local py=-(pry/(1+l)%128)
    map(16+l,0,l*8+i*(120-2*l*8),py+k*128,1,16)
   end
  end	 
 end
 
 -- sky
 if lvl==0 then
	 clip(0,-hcy/2,127,2+sf-hcy/2)
	 if mdp<ldp then
	  sspr(24,0,8,8,0,0,127,127)
	 else
		 sspr(16,0,8,8,0,40,127,32)
		 rectfill(0,0,127,40,1)
	 end
 end
 
 
 -- cam 
 local cx=0
 if shk then
  cx=shk
  shk*=-.75
  if abs(shk) < 1 then
   shk=nil
  end
 end
 
 camera(cx,hcy)
 
 -- sky
 if lvl==0 then 
  --clip(0,0,127,sf)
  local hy=max(hcy,24)
  dpt=10
  foreach(ents,dre) 
  for i=0,2 do
   if i==1 then apal(3) end
   y=40+(hy-24)*.1*(5-i)   
   map(48-i*16,17,0,y,16,7)
   apal()
  end  
  clip() 
  rectfill(0,sf,127,sf,7) 
 end 
  
 
 -- bg
 map(0,0,0,0,16,64,2) 
 
 
 -- surface
 
 if lvl==0 then
	 for bx=-1,4 do
	  c=0
	  if hero.y>sf then
	   c=(hero.y-sf)/48
	  end  
	  local hh=24*c	  
	  for y=0,hh do
	   local py=y*16/hh 
	   local dx=cos(t/160+py/8)*flr(8*(1-y/hh))
		   --log(y.." : "..py)
		  local ok = y<8 or y%2==0
	   if ok then
	    sspr(32,64+py,32,1,bx*32+dx,sf+1+y,32,1)
	   end
	  
	   --sspr(64,96,32,16,i*32,sf+1,32,16*c)
	  end
	 end	 
 end
 
 
 
 -- bubbles
 bfl=7
 foreach(bubs,drb)
 bfl=1
 foreach(bubs,drb)

 -- outline
 foreach(ents,drol) 
 

 
 
 

 -- map  
 dpt=0
 foreach(ents,dre)  
 map(0,0,0,0,16,64,1)
 dpt=1
 foreach(ents,dre) 
 
 -- inter
 camera()
 if frz and hero.cinv and t%4<2 then
  rect(0,0,127,127,8)
 end 

 if not title then
  disp_inter()
 end
 
 if hero.ctit then
  disp_title() 
 end

 
 -- log
 cursor(0,0,7)
 for l in all(logs) do
  print(l)
 end
 
end

function disp_title()
 
 local c=mid(0,1-(t-16)/16,1)
 c=c*c 
 if c==1 then return end 
  
 local tc=1-hero.ctit/15
 
  
 local a={0,1,1,2}
 for i=0,3 do
  local x=32+i*18
  local y=16+cos(t/80+i/4)*2+.5-tc*(128)
  local dx=(x+4-64)*(1+c*8)
  sspr(32+a[1+i]*16,96,16,32,64+dx-4,y)
 end
 
 if c==0 and title then
  local str="the merciless"
  print(str,64-#str*2,8,1)
 end
 
 
end

function disp_inter()

 if ending then 
  local an=t/40
  local x=64
  if mdp>=10 then x+=4 end
  if mdp>=100 then x+=4 end
  if mdp>=1000 then x+=4 end
  local y=24
  local k=mdp
  m=true
  while true do  
   local n=k%10
   if m then
    m=false
    n=-1
   else
    k=flr(k/10)
   end
	  spr(182+n,x,y+cos(an)*2+.5)
	  an+=.2
	  x-=8   
   if k==0 then
    break
   end
  end  
 elseif mdp<cdp+10 then
  local s=flr(cdp).." m"
  print(s,64-#s*2,1,7)
 else
  sy=1
  if not ending then
   local c=(1-cdp/mdp)*64  
   rectfill(1+c,1,126-c,2,7)
   sy=4
  end
  local s=flr(mdp).." m"
  print(s,64-#s*2,sy,8+t%3)
 end
 
 
 -- oxygen
 local k=24
 local fl=oxy/oxy_max
 for x=0,k-1 do for y=0,k-1 do
  local dx=x-k/2
  local dy=y-k/2
  local an=(atan2(dx,dy)-.25)%1
  local dd=sqrt(dx*dx+dy*dy)
  if dd>7.5 and dd<12 and an<fl then
   local px=x+2
   local py=126+y-k
   local n=pget(px,py)
   local dp= (flr(an*60)%2==0) and 2 or 1
   pset(px,py,sget(n,1))
  end
 end end 
 if hero.cdjp then
  apal(8+t%3)
 elseif air==0 and fl<.25 and t%4<2 then
  apal(8)  
 end 
 spr(182+min(air,9),k/2-1,122-k/2)
 apal()
 
end


-->8
function log(n)
 add(logs,n)
 if #logs>20 then
  del(logs,logs[1])
 end
end
__gfx__
0123456789abcdef11111111cccccccc0123456789abcdef00000000000000000000000011111111111111111555555100777700007777000000000000777700
1d8b93779a7a6ef711111111cccccccc111521d62db335de000000000000000000000000111111111d5511115dd55555070000c0070000700777776007000070
d6eaab77a7777f7711111111cccccccc1111115d1535515d00000000000000000000000011111111155511115dd55555070700c07070000c700000067070000c
777777770000000011111111cccccccc1111111511511115000000000000000000000000115555111555111155555555070000c07000000c7070000c7000000c
7aaabbbb0000000022222222cccccccc111111111111111100000000000000000000000015dd55511555111155555555070000c07000000c7000000c7000000c
77fffeee0000000088888888cccccccc0000000000000000000000000000000000000000155555511551155155555551070000c07000000c6000000c7000000c
7aa998880000000099999999cccccccc0000000000000000000000000000000000000000111555111111155111555511070000c0070000c006ccccc0070000c0
77aaa99900000000aaaaaaaacccccccc000000000000000000000000000000000000000011111111111111111111111100cccc0000cccc000000000000cccc00
bbb33bbbbbb3bbbb3bbbbbbbbbb33bbbbbb3bbbb555544455555444555554445000000001555555115511111355315110c0000ccc00000cc000000cccc000000
333333333333333333333333333333333333333354444445544444455444444500000000558282155d551151315315510cc00005cc00000505000005ccc00000
553b33353333355555333355553b333533333555554444555544445555444455000000005e2e222155551555531331550ccc5ccc5cc55ccc055055ccccccc000
5b33355555555555555555555b3335555555555555555555555555555555555000000000582e2e2155551555531531550ccccccc5cc5cccc00555ccccccd7c00
533555445555445544553b3553355544555544554455444500554445445544000000000058282e2155551555533131550cccc55c5cccc55c0055c55ccccc5cc0
5554444454454455535533355554444454454455545544450055444554554400000000005528281155551551353131350cc55ddc5cc55ddc05505ddccccdd550
4454444444455544533555554454444444455544544555550000555554455000000000001122221155111111353311310c5000cccc0000cc050000ccccdd0000
5544455544454444455554455544455544454444455554450000044545500000000000001111111111111111131311310c000000c00000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000001111111111111111000000000000000000000000cc000000
000000000000000000000000000000000000000000000000000000000000000000000000000000001111111115511111000000000000000000000000ccd7d000
000000000000000000000000000000000000000000000000000000000000000000000000000000001111111115511111000000000000000000000000cc717000
000000000000000000000000000000000000000000000000000000000000000000000000000000001115511111111111000000000000000000000000ccd7dc00
000000000000000000000000000000000000000000000000000000000000000000000000000000001115511111111111000000000000000000000000cc575cc0
000000000000000000000000000000000000000000000000000000000000000000000000000000001111111111111111000000000000000000000000cccdd550
000000000000000000000000000000000000000000000000000000000000000000000000000000001111111111111111000000000000000000000000ccdd0000
00000000000000000000000000000000000000000000000000000000000000000000000000000000111111111111111100000000000000000000000000000000
0000003000000000000b000000300000000000000000000000000000000000000000000000000000111111111111111100000000000000000000000000000000
0000030000003b00000b000000300000000000000000000000000000000000000000000000000000111311131311111100000000000000000000000000000000
00000b000000030000033000003b0000000000000000000000000000000000000000000000000000111311131311111100000000000000000000000000000000
00000330000033000000b000000b0000000000000000000000000000000000000000000000000000111313131111111100000000000000000000000000000000
0b0000b0000b30000000b00000330300000000000000000000000000000000000000000000000000111113111111111100000000000000000000000000000000
0b030330000b00000003300000300b00000000000000000000000000000000000000000000000000111111111111111100000000000000000000000000000000
03030300030300000003003003300b30000000000000000000000000000000000000000000000000111111111111111100000000000000000000000000000000
03030300030300000003003003000030000000000000000000000000000000000000000000000000111111111111111100000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000055444000000000005544400000000000554aaaa000000000554440000000000008d888000000000008d888000000000008182200000000000888880000
000009554aaaa000000009554aaaa00000000955aacd9a00000009554444000000000088182280000000008818228000000000881499940000000088d8888000
00009da5aacd9a0000009da5aacd9a0000009da5acc79a0000009da54aaaa000000000881499940000000088149994000000008849ccd9000000008818228000
00009da5acc79a0000009da5acc79a0000009da5aacd9a0000009da5aacd9a000000008449ccd9000000008449ccd9000000008419ccd9000000008414999400
00009da5aacd9a0000009da5aacd9a0000009da54aaaa00000009da5acc79a000000002e19ccd9000000002e19ccd9000000002ef49994000000ff2e49ccd9e0
000009554aaaa000000009554aaaa000000009594444009900000955aacd9a0000000022e499940000000022e499940000000022eeee800000000ff219ccd9e0
0000055544440000000005554444009900000599aaaa5499004554554aaaa0000000000fcdc20000000000ffcdc200e0000000ffccc200e0000000efc4999400
00005999aaaa500000055999aaaa549900055955444454400045559544995400000000fecccf00000000ffeecccfee000000ffeecdcfee000000000eccc00000
00055555444454000045555544444440004555554444555000055559aaa4549900000fe2ef2ee00000000002ef200000000ff002ef20000000000000ef200000
00055555444454000045555544444450004555554444000000000555444455990000fe2cffd0ee000000000cefd000000000000ccddef0000000020cefd00000
000445454994490000000545499400000000054549944a000009554549940000000000efdde00000000000ffddfe0000000000fffdeff000000022efcdee0000
00044555444449000009555544444a000009555544444a000009555544444000000000ef0ee00000000eeefe00ef0000000000fe000fe00000002efe00efe000
00000555055500000009555555544a000009555555555a000009555555544400000000fe02e00000000e0000000ef00000000ee000fe000000000ee0000ef000
00000544054400000009550000055a00000955000000000000000000000444a000000ef000e00000000000000000e0000000ee0000e00000000000000000ee00
000009aa09aa000000000000000000000000000000000000000000000000aa9000000f0000ee0000000000000000ee00000ee000000000000000000000000e00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000888220000
0000000055444000000000000000000000000000000000000000000000000000000000008d888000000000000000000000000000000000000000008888ee0000
00000009554444000000000000000000000000000000000000000000000000000000000881822800000000000000000000000000000000000000f0888eef8000
0000009da54aaaa00000000000000000000000000000000000000000000000000000000881849900000000000000000000000000000000000000f088e22f8000
0000009da5aacd9a000000000000000000000000000000000000000000000000000000084449cd00000000000000000000000000000000000000ff2ee22f8000
0000009da5acc79a0000000000000000000000000000000000000000000000000000000881f9cd000000000000000000000000000000000000000ef2eee880f0
0000000955aacd9a000000005544400000000000554440000000000000000000000000008eff99000000000008d888000000000028d88800000000eeccc80ee0
00000005554aaaa000000009554444000000000955444400000000000000000000000000cfffffff000000008818228000000000881822800000000ecdcfee00
00000099aaa444990000449da54aaaa00000449da54aaaa0000000000000000000000000edde00000000000088149994000000008814999400000002ef200000
00000055444444990005449da5aacd9a0005449da5aacd9a000000000000000000000000efdd0000000000008849ccd9000000008849ccd90000000ccddef000
00000555444400000005449da5acc79a0005449da5acc79a00000000000000000000000cdc000000000000002e19ccd9000000002e19ccd9000000fffdeff000
00000545499400000054944955aacd9a0054944955aacd9a00000000000000000000000dff00000000000cc22ff4999400000cc2ffe49994000000fe000fe000
000005554455000000549449555aaaa000549449555aaaa0000000000000000000000000efe000000000ffcecffee0000000ffceffeee000000000ee00fe0000
0000005555440000005444449955400000544444445540000000000000000000000000000ff000000000fedeefdce0000000fedefcdcee000000000e00e00000
0000000544990000959444555444500009444555444555400000000000000000000000000ef000000000eef00fcce00000eee0eefccc0ee00000000ee0000000
00000009aa00000095994445559aa90009445555599559a0000000000000000000000000ef00000000eeeff00ff0ee00eeee00eeff0000ee00000000e0000000
00000000000000000000000000000000bbbbb5555555bbbbbb5555b55b55555b000aaa9999999000000000000000000000000000005544400000000000000000
000000000000000000000000000000005555b5555bbbbb555bb55bb55bbbbbbb00aa222222229900000a0000000004400049000009554aaa0000000000000000
000000000000000000000000000000005555bbbbbb55b5555bbbbb55bb5555b50aa22222222229900094a00000055440555490009da5aadd00a4440000045000
00000000000000000000000000000000555bb55b5555b5555b55bb55b55555bbaa222222222222990009440000555440055544009da5addd00a4444000444450
0000000000000000000000000000000033331113111133111311133331111113a2222422224222290000444005559440055554009da5aadd0095554000444440
0000000000000000000000000000000011111113111133311311111133111113922424222242422900000400055494000005540009554aaa0000000000444440
00000000000000000000000000000000111111133113313333311111131133339224242222424229000000000000000000000000055544440000000000055440
00000000000000000000000000000000311111133333311113333111133331139224222222224229000000000000000000000000000000000000000000000000
00000000000000000000000000000000331111331111331111113311133111119222222222222229000000000022200000000000000000000000000000000000
00000000000000000000000000000000133333311111331111133333333111114422221221222244d60000000222222000000000000000000000000000000000
0000000000000000000000000000000013311131111113311133111111333111044112122121144015d000000882878700000000000000000000000000000000
00000000000000000000000000000000331111331111113113311111113333110021111111112200dd6700008080288000000000000000000000000000000000
0000000000000000000000000000000051111115555555555551111115511555000211111111200015ddd0000022200000000000000000000000000000000000
00000000000000000000000000000000511111551111551115551111151111119499499999949949dd6676000222222000000000000000000000000000000000
00000000000000000000000000000000511115511111151115155111551111110949949999499490155dddd00882878700000000000000000000000000000000
00000000000000000000000000000000511555111111151155115555551111110042442442442400dd6667660880820800000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000004244244244240000000000d1d1d1d0667666dd000000060000000000000000
00000000000000000000000000000000000000000000000000000000000000000a9aa9aa99499490d6000000d5d5d5600dddd551000000d60000000000000000
0000000000000000000000000000000000000000000000000000000000000000a9aa9aaa9994994915d00000656d6d00006766dd000006d70000000000000000
0000000000000000000000000000000000000000000000000000000000000000a9aa9aaa99949949dd6700006d6d7000000ddd510000d7d60000000000000000
0000000000000000000000000000000000000000000000000000000000000000424424444442442415ddd0006d7d0000000076dd0007d6d60000000000000000
00000000000000000000000000000000000000000000000000000000000000009499499999949949dd6676007d60000000000d5100d6d6560000000000000000
00000000000000000000000000000000000000000000000000000000000000000949949999499490155dddd06d0000000000006d065d5d5d0000000000000000
00000000000000000000000000000000000000000000000000000000000000000042442442442400dd66676660000000000000000d1d1d1d0000000000000000
00000000000000000000000000000000000000000770007700777700000770000077770000777700007777000777777000777700077777700077770000777700
00000000000000000000000000000000000000000777077707700770007770000770077007700770007777000770000007700000000007700770077007700770
00000000000000000000000000000000000000000777777707700770000770000000077000000770077077000770000007700000000007700770077007700770
00000000000000000000000000000000000000000770707707700770000770000000077000007700077077000777770007777700000077000077770007700770
00000000000000000000000000000000000000000770007707700770000770000000770000007700770077000000077007700770000077000770077000777770
00000000000000000000000000000000000000000770007707700770000770000007700000000770777777700000077007700770000770000770077000000770
00000000000000000000000000000000000000000770007707700770000770000077000007700770000077000770077007700770000770000770077007700770
00000000000000000000000000000000000000000770007700777700007777000777777000777700000077000077770000777700000770000077770000777700
00000000000000000000000000000000111111111111000011111111111111111111111111110000000000000000000099999999999999999944444400000000
00000000000000000000000000000000177777777771110017777777777777711777777777711100000000000000000044444444444444444422222200000000
00000000000000000000000000000000177777777777711017777777777777711777777777777110000000000000000002222222222222222211111100000000
00000000000000000000000000000000177771111177771017777111111117711777711111777711000000000000000002444444444444444422222200000000
00000000000000000000000000000000177771000177771117777100000011711777710001177771000000000000000000244444444444444422222200000000
00000000000000000000000000000000177771000117777117777100000001711777710000177771000000000000000000222222222222222211111100000000
00000000000000000000000000000000177771000017777117777100000001111777710000177771000000000000000000022444444444444422222200000000
00000000000000000000000000000000177771000017777117777100000000001777710000177771000000000000000000000222222222222211111100000000
0000000000000000000000000000000017777100001777711777710000000000177771000017777100000000000000000000000bb00000000000000000000000
000000000000000000000000000000001777710000177771177771000000000017777100001777710000000000000000000bb00bbb0000000000000000000000
000000000000000000000000000000001777710000177771177771000000000017777100001777710000000000000000000bbb0bbb00bbb00000000000000000
0000000000000000000000000000000017777100001777711777710000000000177771000017777100000000000000000000bbbbbbbbbb000000000000000000
000000000000000000000000000000001777710000177771177771000111000017777100001777710000000000000000bbbbbbbbbbbbb0000000000000000000
0000000000000000000000000000000017777100001777711777710011710000177771000117777100000000000000000bbbbbbbbbbbb0000000000000000000
000000000000000000000000000000001cccc100001cccc11cccc1111cc100001cccc11111cccc11000000000000000000bbbbbbbbbbbb000000000000000000
000000000000000000000000000000001777710000177771177777777771000017777777777771100000000000000000bbbbbbbbbbbbbbbb0000000000000000
000000000000000000000000000000001cccc100001cccc11cccccccccc100001ccccccccccc1100000000000000000000000000bbbbbbbb0000000000000000
000000000000000000000000000000001cccc100001cccc11cccc1111cc100001cccc11111111000000000000000000000000000bbbbbbbb0000000000000000
000000000000000000000000000000001cccc100001cccc11cccc10011c100001cccc10000000000000000000000000000000000bbbbbbbb0000000000000000
000000000000000000000000000000001cccc100001cccc11cccc100011100001cccc10000000000000000000000000000000000bbbbbbbb0000000000000000
00000000000000000000000000000000133331000013333113333100000000001333310000000000000000000000000000000000bbbbbbbb0000000000000000
000000000000000000000000000000001cccc100001cccc11cccc100000000001cccc10000000000000000000000000000000000bbbbbbbb0000000000000000
00000000000000000000000000000000133331000013333113333100000000001333310000000000000000000000000000000000bbbbbbbb0000000000000000
00000000000000000000000000000000133331000013333113333100000000001333310000000000000000000000000000000000bbbbbbbb0000000000000000
0000000000000000000000000000000013333100001333311333310000000000133331000000000000000000000000000000000dd0000000dddddddd00000000
000000000000000000000000000000001333310000133331133331000000011113333100000000000000000000000000000000dddd000000dddddddd00000000
00000000000000000000000000000000155551000115555115555100000001511555510000000000000000000000000000000dddddd00000dddddddd00000000
0000000000000000000000000000000013333100013333111333310000001131133331000000000000000000000000000000dddddddd0000dddddddd00000000
000000000000000000000000000000001555511111555510155551111111155115555100000000000000000000000000000dddddddddd000dddddddd00000000
00000000000000000000000000000000155555555555511015555555555555511555511000000000000000000000000000dddddddddddd00dddddddd00000000
0000000000000000000000000000000015555555555111001555555555555551155555100000000000000000000000000dddddddddddddd0dddddddd00000000
000000000000000000000000000000001111111111110000111111111111111111111110000000000000000000000000dddddddddddddddddddddddd00000000
__label__
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1
cccccccccccccccccccccccccccccccccccccc111c1c1c111ccccc111c111c111cc11c111c1ccc111cc11cc11cccccccccccccccccccccccccccccccccccccc1
ccccccccccccccccccccccccccccccccccccccc1cc1c1c1ccccccc111c1ccc1c1c1cccc1cc1ccc1ccc1ccc1cccccccccccccccccccccccccccccccccccccccc1
ccccccccccccccccccccccccccccccccccccccc1cc111c11cccccc1c1c11cc11cc1cccc1cc1ccc11cc111c111cccccccccccccccccccccccccccccccccccccc1
ccccccccccccccccccccccccccccccccccccccc1cc1c1c1ccccccc1c1c1ccc1c1c1cccc1cc1ccc1ccccc1ccc1cccccccccccccccccccccccccccccccccccccc1
ccccccccccccccccccccccccccccccccccccccc1cc1c1c111ccccc1c1c111c1c1cc11c111c111c111c11cc11ccccccccccccccccccccccccccccccccccccccc1
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1111111111111111ccccccccccccccccccccccccccccccccccccccccccc1
cccccccccccccccccccccccccccccccccccccccccccccccccc1111111111111111cc1777777777777771ccccccccccccccccccccccccccccccccccccccccccc1
cccccccccccccccccccccccccccccccccccccccccccccccccc1777777777777771cc1777777777777771ccccccccccccccccccccccccccccccccccccccccccc1
cccccccccccccccccccccccccccccccccccccccccccccccccc1777777777777771cc1777711111111771cc111111111111ccccccccccccccccccccccccccccc1
cccccccccccccccccccccccccccccccc111111111111cccccc1777711111111771cc177771cccccc1171cc17777777777111ccccccccccccccccccccccccccc1
cccccccccccccccccccccccccccccccc17777777777111cccc177771cccccc1171cc177771ccccccc171cc177777777777711cccccccccccccccccccccccccc1
cccccccccccccccccccccccccccccccc177777777777711ccc177771ccccccc171cc177771ccccccc111cc1777711111777711ccccccccccccccccccccccccc1
cccccccccccccccccccccccccccccccc177771111177771ccc177771ccccccc111cc177771cccccccccccc177771ccc1177771ccccccccccccccccccccccccc1
cccccccccccccccccccccccccccccccc177771ccc1777711cc177771cccccccccccc177771cccccccccccc177771cccc177771ccccccccccccccccccccccccc1
cccccccccccccccccccccccccccccccc177771ccc1177771cc177771cccccccccccc177771cccccccccccc177771cccc177771ccccccccccccccccccccccccc1
cccccccccccccccccccccccccccccccc177771cddc177771cc177771cccccccccccc177771cccccccccccc177771cccc177771ccccccccccccccccccccccccc1
cccccccccccccccccccccccccccccccc177771dddd177771cc177771cccccccccccc177771cccccccccccc177771cccc177771ccccccccccccccccccccccccc1
cccccccccccccccccccccccccccccccc177771dddd177771cc177771cccccccccccc177771ccc111cccccc177771cccc177771ccccccccccccccccccccccccc1
cccccccccccccccccccccccccccccccc177771dddd177771cc177771ccc111cccccc177771cc1171cccccc177771cccc177771ccccccccccccccccccccccccc1
cccccccccccccccccccccccccccccccc177771dddd177771cc177771cc1171cccccc1cccc1111cc1cccccc177771cccc177771ccccccccccccccccccccccccc1
cccccccccccccccccccccccccccccccc177771dddd177771cc1cccc1111cc1cccccc177777777771cccccc177771cccc177771ccccccccccccccccccccccccc1
cccccccccccccccccccccccccccccccc177771dddd177771cc177777777771cccccc1cccccccccc1cccccc177771ccc1177771ccccccccccccccccccccccccc1
cccccccccccccccccccccccccccccccc177771dddd177771cc1cccccccccc1cccccc1cccc1111cc1cccccc1cccc11111cccc11ccccccccccccccccccccccccc1
cccccccccccccccccccccccccccccccd1cccc1dddd1cccc1dc1cccc1111cc1cccccc1cccc1cc11c1cccccc177777777777711ccddddddddddcccccccccccccc1
ccccccccccccccccccccccccccccccdd177771dddd177771dd1cccc1cc11c1cccccc1cccc1ccc111cccccc1ccccccccccc11ccddddddddddddccccccccccccc1
cccccccccccccccccccccccccccccddd1cccc1dddd1cccc1dd1cccc1ccc111cccccc133331cccccccccccc1cccc11111111ccddddddddddddddcccccccccccc1
ccccccccccccccccccccccccccccdddd1cccc1dddd1cccc1dd133331cccccccccccc1cccc1cccccccccccc1cccc1ccccccccddddddddddddddddccccccccccc1
cccccccccccccccccccccccccccddddd1cccc1dddd1cccc1dd1cccc1cccccccccccc133331cccccccccccc1cccc1cccccccddddddddddddddddddcccccccccc1
ccccccccccccccccccccccccccdddddd1cccc1dddd1cccc1dd133331cccccccccccc133331cccccccccccc133331ccccccddddddddddddddddddddccccccccc1
cccccccccccccccccccccccccddddddd133331dddd133331dd133331cccccccccccc133331cccccccccccc1cccc1cccccddddddddddddddddddddddcccccccc1
ccccccccccccccccccccccccdddddddd1cccc1dddd1cccc1dd133331cccccccccccc133331ccccccc111cc133331ccccddddddddddddddddddddddddccccccc1
cccccccddccccccccccccccddddddddd133331dddd133331dd133331dcccccc111cc1ffff1ccccccc1f1cc133331ccc3333333333dddddddddddddd33cccccc1
ccccccddddccccccccccccdddddddddd133331dddd133331dd1ffff1ddccccc1f1cc133331cccccc1131cc1333313cd33333333333ddddddddd33dd333ccccc1
cccccddddddccccccccccddddddddddd133331dddd133331dd133331dddccc1131cc1ffff11111111ff1cc13333133d33333333333dd333dddd333d333dc3331
ccccddddddddccccccccdddddddddddd133331dddd133331dd1ffff11111111ff1cc1ffffffffffffff1cc1ffff1333333333333333333dddddd3333333333c1
cccddddddddddccccccddddddddddddd1ffff1ddd11ffff1dd1ffffffffffffff1cd1ffffffffffffff1cc13333133333333333333333ddd3333333333333cc1
ccddddddddddddccccdddddddddddddd133331ddd1333311dd1ffffffffffffff1dd1111111111111111cc1ffff133333333333333333dddd333333333333dc1
cddddddddddddddccddddddddddddddd1ffff11111ffff1ddd1111111111111111dddddddddddddccccccc1ffff1133333333333333333dddd333333333333d1
dddddddddddddddddddddddddddddddd1ffffffffffff11dddddddddddddddddddddddddddddddddcccccc1fffff133333333333333333333333333333333331
3dddddddddddddddddddddd33ddddddd1ffffffffff111d3333333333dddddddddddddd33ddddddddddddd1111111333333333333333333bb333333333333331
33ddddddddddddddddd33dd333dddddd1111111111113dd33333333333ddddddddd33dd333ddddddddd33dd33333333333333333333bb33bbb33333333333331
33dd333dddddddddddd333d333dd333dddddddddddd333d33333333333dd333dddd333d333dd333dddd333d33333333333333333333bbb3bbb33bbb333333331
333333dddddddddddddd3333333333dddddddddddddd333333333333333333dddddd3333333333dddddd333333333333333333333333bbbbbbbbbb3333333331
33333ddddddddddd3333333333333ddddddddddd333333333333333333333ddd3333333333333ddd333333333333333333333333bbbbbbbbbbbbb33333333331
33333dddddddddddd333333333333dddddddddddd33333333333333333333dddd333333333333dddd333333333333333333333333bbbbbbbbbbbb33333333331
333333dddddddddddd333333333333dddddddddddd33333333333333333333dddd333333333333dddd333333333333333333333333bbbbbbbbbbbb3333333331
33333333dddddddd3333333333333333dddddddd3333333333333333333333333333333333333333333333333333333333333333bbbbbbbbbbbbbbbb33333331
3333333bb33333333333333bb333333333333333333333333333333bb311111333333333333333333333333bb33333333333333bbbbbbbbbbbbbbbbbb3333331
333bb33bbb333333333bb33bbb3333333333333333333333333bb33b11444ff13333333333333333333bb33bbb333333333bb33bbbbbbbbbbbbbbbbbbb333331
333bbb3bbb33bbb3333bbb3bbb33bbb33333333333333333333bbb31aaaa4ff91333333333333333333bbb3bbb33bbb3333bbb3bbbbbbbbbbbbbbbbbbb33bbb1
3333bbbbbbbbbb333333bbbbbbbbbb3333333333333333333333bb1a9dcaafad91333333333333333333bbbbbbbbbb333333bbbbbbbbbbbbbbbbbbbbbbbbbb31
bbbbbbbbbbbbb333bbbbbbbbbbbbb3333333333333333333bbbbbb1a97ccafad9133333333333333bbbbbbbbbbbbb333bbbbbbbbbbbbbbbbbbbbbbbbbbbbb331
3bbbbbbbbbbbb3333bbbbbbbbbbbb33333333333333333333bbbbb1a9dcaafad91333333333333333bbbbbbbbbbbb3333bbbbbbbbbbbbbbbbbbbbbbbbbbbb331
33bbbbbbbbbbbb3333bbbbbbbbbbbb33333333333333333333bbbbb1aaaa4ff9133333333333333333bbbbbbbbbbbb3333bbbbbbbbbbbbbbbbbbbbbbbbbbbb31
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333333333333bbbbbbbb14444fff1333333333333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333333333bbbbbbbb1faaaa999f13333333333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333333bb33bbbbbbb14f4444fffff133333333bb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbb3333bbb3bbbbbbb14f4444fffff13bbb3333bbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333bbbbbbbbbb1944994f4f441bbb333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333bbbbbbbb99999999999999999999999999444444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333bbbbbbb44444444444444444444444444222222bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333bbbbbbb2222222222222222222222222111111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2444444444444444444444444222222bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1
77777777777777777777777777777777777777777777777777244444444444444444444444222222777777777777777777777777777777777777777777777777
00000000000000000000000000000000000000000000000000222222222222222222222222111111000000000000000000000000000000000000000000000000
11111111111111111ff11111111111111111111111111111111224444444444444444444442222221111111111111111111111111ff111111111111111111111
11111111111ff111111111111111111111111111111111111111122222222222222222222211111111111111111111111111111111111111111ff11111111111
11111111111ff111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111ff11111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111311111111111111111111111111111111111111111111111111111111111111111111111111111111111111131111111111111111111111
11111111111111111311111111111111111111111111111111111111111111111111111111111111111111111111111111111111131111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111311131ff11111111111111111111111111111111111111111111111111111111111111111111111111111111111111ff111111113111311111111
11111111111311131ff11111111111111111111111111111111111111111111111111111111111111111111111111111111111111ff111111113111311111111
11111111111313131111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111113131311111111
11111111111113111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111131111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ffffff111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111ffffff1
fddfffff1dff11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dff1111fddfffff
fddfffff1fff11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111fff1111fddfffff
ffffffff1fff11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111fff1111ffffffff
ffffffff1fff11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111fff1111ffffffff
fffffff11ff11ff11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111ff11ff1fffffff1
11ffff1111111ff111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111ff111ffff11
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
3ff31f1111111111111111111111111111111111114244244244241111113111111111111111111111111111111111111111111111111111111111113ff31f11
31f31ff1111311131111111111131111111111111a9aa9aa99499491111311111111111111111111111111111111111111111111111111111113111331f31ff1
f31331ff1113111311111111111b111111111111a9aa9aaa99949949113b111111111111111111111111111111111111111111111111111111131113f31331ff
f31f31ff11131313111111111111331111111111a9aa9aaa9994994911b1111111111111111111111111111111111111111111111111111111131313f31f31ff
f33131ff11111311111111111b1111b11111111142442444444244241331311111111111111111111111111111111111111111111111111111111311f33131ff
3f31313f11111111111111111b1313311111111194994999999499491311b111111111111111111111111111111111111111111111111111111111113f31313f
3f33113111111111111111111313131111111111194994999949949113311b31111111111111111111111111111111111111111111111111111111113f331131
13131131111111111111111113131311111111111142442442442411131111311111111111111111111111111111111111111111111111111111111113131131
1111111111111111bbb33bbbbbb3bbbbbbb33bbb3bbbbbbbbbb33bbbbbb3bbbbbbb33bbb11111111111111111111111111111111111111111111111111111111
111111111111111133333333333333333333333333333333333333333333333333333333111111111111111111111111111111111ff111111111111111111111
1111111111111111ff3b333f33333fffff3b333fff3333ffff3b333f33333fffff3b333f111111111111111111111111111111111ff111111111111111111111
11ffff11111ff111fb333ffffffffffffb333ffffffffffffb333ffffffffffffb333fff1111111111111111111111111111111111111111111ff11111ffff11
1fddfff1111ff111f33fff44ffff44fff33fff4444ff3b3ff33fff44ffff44fff33fff441111111111111111111111111111111111111111111ff1111fddfff1
1ffffff111111111fff44444f44f44fffff44444f3ff333ffff44444f44f44fffff444441111111111111111111111111111111111111111111111111ffffff1
111fff111111111144f44444444fff4444f44444f33fffff44f44444444fff4444f44444111111111111111111111111111111111111111111111111111fff11
1111111111111111ff444fff444f4444ff444fff4ffff44fff444fff444f4444ff444fff11111111111111111111111111111111111111111111111111111111

__gff__
0000000000000000000202020000000001010101010101010002020200000000020202020000000000000000000000000202020200000000000000000000000000000200000000000000020000000000000000000000000000000000010101010000000000000000000000000101010100000000000000000000000001010101
0000000000000000020200000000000000000000000000000202000000000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
000000000000000000000000000000000b2a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000001b0a2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000090a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000002b002b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000001b2a2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000001a0a3b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000093a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000001b0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000001a2a2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000001a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000009003b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000001a3a2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000b0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000001a3a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000192a2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000cccdcdce000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fcfd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fcfefefd0000000000fcfefd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000dceddddcddfcfdfcfefefefefdfcfd00fcfefefefd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000dcdd00dd00dcdd00dceddddcdddcedededededfefefefefefefefefefefefefefefefe00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000dcdddcdd0000dcdd0000dcdddcededddededededededededededededededededfefefefefefefefefefefefefefefefe00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000ededededdddcededdddcededededededededededededededededededededededfefefefefefefefefefefefefefefefe00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400001301417012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00002b3511f311000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001f45537051000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001305300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002b471372311f4212b2112b202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001f5552b15500000130231f533370003702000000130503705113053000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00001347311644116150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01060000074541f6652b35313633076251f6120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800000307505075070750a0750c0750f065110551304516045180351b0251d0251f01522015240152701529015380050000500005010010200102002020000200001000010000000000000000000000000000
011000001d755297152170518045007052175521715007052475530715007051f04500705217552171500705227552170521705217551f7051f7051f755007051c7551c7051f7051d7551f7051f7051f75500705
011000001d755297152170518045007052175521715007052475530715007051f0450070521755217150070522755000000000024755247002e70029755000002875500000000002675500000000002475500000
011000001d77521752247652975028752287502977029732297222971200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002975529715180151800024015000052875500005297552971224015000051801500005247550000522775227221801500005180150000524755000052175522712240151d70518015000002b73500000
011000002175521712180001d755180001a7051a755180001f7551f712180051c755180051800518755180051a7550e715157051575509712217051c755157121d7551d7051c7551d7051d7551d7051f75500000
011000002175521712180001d755180001a7052175518000247551a700227551c70521755180052275518005217551a7051d7051d755217051d70521755217051f7551d705187051c7551d7051a7051875500000
010900002475329762357523573235722357123571235702000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001d755117551d7551f7551f712227552b71221755297550000029725000002971500000297150000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00000762511615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 4a420a44
00 4b420b44
00 4a420a44
00 4b420b44
00 41420e44
02 41420f44
00 41424344
00 41424344
00 41424344
00 41424344
03 0d424344

