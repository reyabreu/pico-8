pico-8 cartridge // http://www.pico-8.com
version 20
__lua__
--main
function make_state(fr,fu,fd)
	local state={
		rst=fr,
		upd=fu,
		drw=fd
	}
	return state
end

function _init()
 log:hide()
	states={
		title   =make_state(title_reset,title_update,title_draw),
		game    =make_state(game_reset,game_update,game_draw),
		gameover=make_state(gameover_reset,gameover_update,gameover_draw)
	}
	scene="title"
	states[scene].rst()
	log:log(scene)
end

function _update()
	if (sel_delay>0) sel_delay-=1
	states[scene].upd()
end

function _draw()
	states[scene].drw()
	log:drw()	
end

-->8
--title
title={
	"game title",
	"by reyabreu"
}

title_choices={}

function title_reset()
 sel_delay=10
	cls(2)
end

function title_update()
	if sel_delay<=0 and btn(4) then
		scene="game"
		states[scene].rst()
		log:log(scene)		
	end
end

function title_draw()
	print_ml(title,30,48,8,print_outline)
end
-->8
--game
function game_reset()
 sel_delay=10
	cls(1)
	circle={
		x=64,y=64,
		r=10,
		target=30,
		rmax=30,
		rmin=10,
		c=15,
		timer=3
	}
end

function game_update()
 --game logic
	if circle.rmax-circle.r<1 then
		--circle.r=circle.rmax
		circle.target=circle.rmin
		circle.timer-=1
	end
	if circle.r-circle.rmin<1 then
	 --circle.r=circle.rmin
	 circle.target=circle.rmax
		circle.timer-=1
	end
	circle.r=lerp(circle.r,circle.target,0.05)	
	
	--game over
	if circle.timer<=0 then
		scene="gameover"
		states[scene].rst()
	 log:log(scene)		
	end	
end

function game_draw()
	cls(1)
	circfill(circle.x,circle.y,circle.r,circle.c)
end
-->8
--game over
text={
	"game over!",
	"press x to try again",	
	"press z to return to title",
}
function gameover_reset()
	sel_delay=10
	cls(12)
	explosion={x=54,y=54,r=120}
end

function gameover_update()
	if sel_delay<=0 and not choice then
		if (btn(4)) choice={txt=text[3],scene="title",timer=50,c=11}
		if (btn(5))	choice={txt=text[2],scene= "game",timer=50,c=11}
 end
 
 if choice then
		choice.c=choice.timer%2==0 and 11 or 12
  choice.timer-=1
		if choice.timer<=0 then
			scene=choice.scene
			states[scene].rst()
			log:log(scene)
			log:hide(false)
			choice=nil
		end
 end
 
end

function gameover_draw()
	print_ml(text,10,48,8,print_outline)
	
	if choice then
		print(choice.txt,10,48+24,c)
	end	
	
end
-->8
--utils
function lerp(start,finish,t)
	return mid(start,start*(1-t)+finish*t,finish)
end

function print_outline(txt,x,y,col,bg)
	col=col or 7 --white
	bg=bg or 5 --light gray
 for i=-1,1 do
 	for j=-1,1 do
  	print(txt,x+j,y+i,bg)
  end
	end
	print(txt,x,y,col)
end

function print_ml(doc,x,y,lh,printer)
 local offset=0
	foreach(doc,function(txt)
		printer(txt,x,y+offset)
		offset+=lh
	end)
end
-->8
--log
log={
	x=0,y=103,
	w=127,h=24,
	msgs={},
	ml=4,
	bg=0,
	hidden=false,
	hide=function(self,v)
		if (v==nil) v=true
		hidden=v	
	end,
	log=function(self,msg)
		if #self.msgs>=self.ml then
			m=self.msgs[#self.msgs]
			del(self.msgs,m)
		end
		add(self.msgs,msg)
	end,
	drw=function(self)
	 if (hidden) return
		local lw,lh
		lw=mid(2,self.w,127)
		lh=mid(2,self.h,127)		
		rectfill(self.x,self.y,self.x+lw,self.y+lh,bg)
		for i=1,#self.msgs do
			print(i..":"..self.msgs[i],self.x+1,self.y-5+6*i,7)
		end
	end
}

__gfx__
00000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000026ddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000d2cccd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700006dccd600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000006666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000d5dd5d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000560560650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d101101d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100002b200271000730018400241001740007300271002a2000160001600016000160001600016000160001600016000000000000000000000000000000000000000000000000000000000000000000000000
