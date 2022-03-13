pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
snake={}
timer=0
fruits={}

function _init()
	-- make snake
	snake={
		col=11,  -- colour
		spd=1,  -- speed
		ssz=4,  -- segment size
		sdir=1, -- dir 0:⬅️,1:➡️,2:⬆️,3:⬇️
		body={} -- segments
	}
	-- add segments
	local segment={}
	for i=1,5 do
		s={
			x=snake.ssz*i,
			y=60
		}
		add(snake.body,s)
	end
end

function _update()
	-- animation timer
	timer+=1
	if (timer>200) timer=0

	-- add fruit
	if #fruits==0 then
		drop_fruit()		
	end

	--process btn press
	local sdir=snake.sdir
	if (btnp(⬅️)) sdir=sdir>1 and 0 or sdir
	if (btnp(➡️)) sdir=sdir>1 and 1 or sdir
	if (btnp(⬆️)) sdir=sdir<2 and 2 or sdir
	if (btnp(⬇️)) sdir=sdir<2 and 3 or sdir

	-- animate snake
	if (btn(❎)) or (sdir!=snake.sdir) then
	--if (timer%3==0) or (sdir!=snake.sdir) then
		snake.sdir=sdir
		local dx,dy=0,0
		if (sdir==0) dx=-1
		if (sdir==1) dx= 1
		if (sdir==2) dy=-1
		if (sdir==3) dy= 1

		-- move segments
		local h=snake.body[#snake.body]
		del(snake.body,snake.body[1])
		add(snake.body,{x=h.x+dx*(snake.ssz*snake.spd),y=h.y+dy*(snake.ssz*snake.spd)})

		check_hit()
	end
end

function _draw()
	-- background
	cls(5)

	-- fruit
	for f in all(fruits) do
		rectfill(f[1]-1,f[2]-1,f[1]+1,f[2]+1,8)
	end
	
	-- snake
	local msz=snake.ssz/2
	for seg in all(snake.body) do
		rectfill(seg.x-msz+1,seg.y-msz+1,seg.x+msz-1,seg.y+msz-1,snake.col)
	end
	local h=snake.body[#snake.body]
	rectfill(h.x-msz+1,h.y-msz+1,h.x+msz-1,h.y+msz-1,4)
	--pset(h.x,h.y,7)
	
	rect(2,2,125,125,12)
	
	-- stats
	print("body sz:"..#snake.body)
	print("head.x:"..snake.body[#snake.body].x)
end

function check_hit()
	local h=snake.body[#snake.body]
	local msz=snake.ssz/2
	for f in all(fruits) do
		if f[1]>=h.x-msz and f[1]<=h.x+msz and f[2]>=h.y-msz and f[2]<=h.y+msz then
			del(fruits,f)
			local dx,dy=0,0
			if (snake.sdir==0) dx=-1
			if (snake.sdir==1) dx= 1
			if (snake.sdir==2) dy=-1
			if (snake.sdir==3) dy= 1
			add(snake.body,{x=h.x+dx*(snake.ssz*snake.spd),y=h.y+dy*(snake.ssz*snake.spd)})
			sfx(0)
		end
	end
end
-->8
--fruit
function drop_fruit()
	local is_valid=false
	local msz=snake.ssz/2
	local fx,fy
	while not is_valid do
		fx=5+flr(rnd(100))
		fy=5+flr(rnd(100))
		if pget(fx,fy)!=snake.col then
			is_valid=true
			for s in all(snake.body) do
				if fx>=s.x-msz and fx<=s.x+msz and fy>=s.y-msz and fy<=s.y+msz then
					is_valid=false
					break
				end
			end
		end
	end
	add(fruits,{fx,fy})
end 
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000237502473026720280502a050300303301032000300102e7302d700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
