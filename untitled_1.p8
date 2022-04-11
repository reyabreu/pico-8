pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
explosions={}

function _update()
		for explosion in all(explosions) do
			explosion.timer-=1
			if explosion.timer>10 then
				explosion.radius-=1
			elseif explosion.timer>5 then
				explosion.radius-=1
				explosion.col=9
			elseif explosion.timer>2 then
				explosion.radius-=1
				explosion.col=8
			else
				del(explosions,explosion)
			end
		end
		
		if btnp(❎) then
			local r=20
			for i=1,3 do
				local explosion={
					x=64,y=64,
					timer=20,
					radius=r-4*i,
					col=10
				}
				add(explosions, explosion)
			end
			sfx(0)
		end
end

function _draw()
	cls()
	for explosion in all(explosions) do
		circ(explosion.x,explosion.y,explosion.radius,explosion.col)
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000200001a630146400f6400c6500d6503065033650376503a6503c6503f6502d65028650226501c65018640146400f6400b640076400b6400964006640046400b6400964005640016400a640086400564001640
