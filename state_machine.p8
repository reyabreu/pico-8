pico-8 cartridge // http://www.pico-8.com
version 20
__lua__
--main
context={
	scene="title",
	states={
	 title=title_state,
		game=game_state	
	},
	req=nil,	
	timer=0,
	
	init=function(s)
	 s.timer=10
	 req=nil
--		s.states[s.scene].init(s)
	end,
	
	draw=function(s)
		s.state[s.scene]:draw(s)
	end,
	
	nxt=function(s,scene)
		if s.timer<=0 then
			s.req=scene
			s.timer=20--transition delay
		end
	end
	
}

function _init()
	context:init()
end

function _update()
	local current=context.states[context.scene]
	current:update(context)
	
	context.timer-=1
	if context.timer<=0 and req~=nil then
		context.scene=req
		context:init()
	end
end

function _draw()
	context:draw()
end
-->8
--title
title_state={
	
	init=function(s,o)
		cls(1)
		print("title scene")
	end,
	
	update=function(s,o)
		if (btn(❎)) o.nxt("game")
	end,
	
	draw=function(s,o)
		
	end

}

-->8
--title
game_state={
	init=function(s,o)
		cls(16)
		print("game scene")
	end,
	update=function(s,o)
		if (btn(4)) o.nxt("title")
	end,
	draw=function(s,o)
		circfill(54,54,10)
	end
}

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
