pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
snake={}
fruits={}

function _init()
	delta=10
	timer=delta

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
			x=snake.ssz*i-1,
			y=60
		}
		add(snake.body,s)
	end
	game_over=false
end

function _update60()
	-- animation timer
	timer-=1

	if game_over then
		if (btnp(❎)) _init()
		return
	end

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
	--if (btn(❎)) or (sdir!=snake.sdir) then
	if (timer<=0) or (sdir!=snake.sdir) then
		timer=delta
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
	cls()
	rectfill(0,1,126,127,5)

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
	--rectfill(h.x-msz+1,h.y-msz+1,h.x+msz-1,h.y+msz-1,4)
	pset(h.x,h.y,7)
	
	rect(0,1,126,127,12)

	if game_over then
		local str="game over! press ❎ to retry"
		print(str, 64 - 2*#str, 60, 7)
	end
	
	-- stats
	--print("body sz:"..#snake.body)
	--print("head.x:"..snake.body[#snake.body].x)
end

function check_hit()
	local h=snake.body[#snake.body]
	local msz=snake.ssz/2

	local s
	if h.x-msz<=0 or h.x+msz>=126 or h.y-msz<=1 or h.y+msz>=127 then
		game_over=true
		sfx(1)
	end
	if not game_over then
		for i=1,#snake.body-1 do
			s=snake.body[i]
			if h.x>=s.x-msz and h.x<=s.x+msz and h.y>=s.y-msz and h.y<=s.y+msz then
				game_over=true
				sfx(1)
				break
			end
		end
	end

	for f in all(fruits) do
		if f[1]>=h.x-msz and f[1]<=h.x+msz and f[2]>=h.y-msz and f[2]<=h.y+msz then
			del(fruits,f)
			local dx,dy=0,0
			if (snake.sdir==0) dx=-1
			if (snake.sdir==1) dx= 1
			if (snake.sdir==2) dy=-1
			if (snake.sdir==3) dy= 1
			add(snake.body,{x=h.x+dx*(snake.ssz*snake.spd),y=h.y+dy*(snake.ssz*snake.spd)})
			delta-=1
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
		fx=2+flr(rnd(120))
		fy=1+flr(rnd(120))
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
0010000000000285402144027540154401a530084300b520000000155001550015400151001500015000150000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000270402e0502903016720187401375022050270202d0402905016750197201574018050260302c020000001a2000000000000000001230000000000000000000000000000000000000000000000000000
000500000f3500f3500f3500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
02 02034344

