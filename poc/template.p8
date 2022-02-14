pico-8 cartridge // http://www.pico-8.com
version 20
__lua__
--main
function make_state(fi,fu,fd,dv)
	local state={
		ini=fi,
		upd=fu,
		drw=fd,
		t=20,--state change ticker
		nxt=function(self,v)
			if self.t<=0 then
				scene=v
				states[scene]:ini()
				log:log(v)
				self.t=20--reset timer				
			end
		end
	}
	return state
end

function _init()
 --log:hide()
	states={
		title   =make_state(title_init,title_update,title_draw),
		game    =make_state(game_init,game_update,game_draw),
		gameover=make_state(gameover_init,gameover_update,gameover_draw)
	}
	--initial scene
	scene="title"
	states[scene]:ini()
end

function _update()
	local st=states[scene]
	st:upd()
	if (st.t>0) st.t-=1	
end

function _draw()
	states[scene]:drw()
	--log
	log:drw()	
end

-->8
--title
function title_init(st)
	cls(2)
end

function title_update(st)
	if (btn(4))	st:nxt("game")
end

function title_draw(st)
	local title={
		"game title",
		"by reyabreu"
	}
	print_ml(title,30,48,8,print_outline)
end
-->8
--game
function game_init(st)
	circle={
		x=64,y=64,
		r=10,
		target=30,
		rmax=30,
		rmin=10,
		c=15,
		timer=50
	}
end

function game_update(st)
	circle.timer-=1
 
 --game logic
	if circle.rmax-circle.r<1 then
		circle.target=circle.rmin
	end
	if circle.r-circle.rmin<1 then
	 circle.target=circle.rmax
	end
	circle.r=lerp(circle.r,circle.target,0.05)
	
	--game over
	if (circle.timer<=0)	st:nxt("gameover")
end

function game_draw(st)
	cls(1)
	circfill(circle.x,circle.y,circle.r,circle.c)
end
-->8
--game over
text={
	"press x to try again",	
	"press z to return to title",
}

function make_choice(str,x,y,sn)
	local choice={
		str=str,
		x=x,
		y=y,
		scene=sn,
		timer=50,
		cols={7,11},
		upd=function(s)
			s.timer-=1
		end,
		drw=function(s)
			print(s.str,s.x,s.y,s.cols[s.timer%2+1])
		end
	}	
	return choice
end

function gameover_init(st)
	cls(12)
end

function gameover_update(st)
	if not choice then
		if (btn(🅾️)) choice=make_choice(text[2],10,48+24,"title")
		if (btn(❎)) choice=make_choice(text[1],10,48+24,"game")
 end
 
 if choice then
 	choice:upd()
		if choice.timer<=0 then
			st:nxt(choice.scene)
			choice=nil
		end
 end 
end

function gameover_draw(st)
 print_outline("game over!",10,48,8)
 print_outline(text[1],10,48+8)
 print_outline(text[2],10,48+16)  
	if (choice)	choice:drw()
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
			print(":"..self.msgs[i],self.x+1,self.y-5+6*i,7)
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
