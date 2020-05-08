pico-8 cartridge // http://www.pico-8.com
version 23
__lua__
players={}
zlayers={}

function make_court()
	local court={
		draw=function(self)
			rect(0,0,127,127,7)
			rect(64,0,64,127,7)
		end	
	}
	return court
end

function make_ball(x,y)
	local ball={
		x=x,
		y=y,
		r=2,
		c=10,
		vx=2,
		vy=2,
		draw=function(self)
			circfill(self.x,self.y,self.r,self.c)
		end
	}
	return ball
end

function make_paddle(x,y)
	local paddle={
		x=x,
		y=y,
		w=4,
		h=24,
		c=5,
		spd=3,
		draw=function(self)
			rectfill(self.x-self.w/2,
				self.y-self.h/2,
				self.x+self.w/2,
				self.y+self.h/2,self.c)
		end
	}
	return paddle
end

function _init()
	--init zlayers
	zlayers[-1]={}
	zlayers[ 0]={}	
	zlayers[ 1]={}
	
	--make court
	add(zlayers[-1],make_court())

	--make actors
	ball=make_ball(64,64)
	add(players,make_paddle(8,64))
	add(players,make_paddle(127-8,64))	

	--add to zlayers
	for player in all(players) do
		add(zlayers[0], player)
	end
	add(zlayers[0], ball)
end

function _update()
	
end

function _draw()
	cls()
	for z=-1,1 do
		for obj in all(zlayers[z]) do
			obj:draw()
		end
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
