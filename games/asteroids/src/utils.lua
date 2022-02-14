-- general utility routines
function rndb(low,high)
  return flr(rnd(high-low+1)+low)
end

function lerp(start,finish,factor)
	return mid(start,start*(1-factor)+finish*factor,finish)
end

function make_noise(seq,sz,delta,lo,hi)
  lo=lo or 0
  hi=hi or 127
	srand(seq[1])
  for i=2,sz do
    seq[i]=mid(lo,rndb(seq[i-1]-delta,seq[i-1]+delta),hi)
  end
  srand(time())
end

function outline_spr(n,x,y,w,h,flip_x,flip_y)
	w=w or 1
	h=h or 1
	flip_x=flip_x or false
	flip_y=flip_y or false	
	for i=1,15 do
		pal(i,0)
	end
	for xoffset=-1,1 do
		for yoffset=-1,1 do
			spr(n,x+xoffset,y+yoffset,w,h,flip_x,flip_y)
		end
	end
	pal()
	spr(n,x,y,w,h,flip_x,flip_y)
end