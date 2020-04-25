pico-8 cartridge // http://www.pico-8.com
version 20
__lua__
--library of graphic utils
text={
	"a quick",
	"brown fox",
	"jumps over",
	"the lazy dog"
}

function _draw()
	cls(1)
	print_stereo("a quick",52,0)
	print_stereo("brown fox",52,6)
	print_stereo("jumps over",52,12)
	print_stereo("the lazy dog",52,18)
	
	print_outline("a quick",52,32)
	print_outline("brown fox",52,40)
	print_outline("jumps over",52,48)
	print_outline("the lazy dog",52,56)
	
	local function wrap(printer,col,bg)
		return function(txt,x,y)
			printer(txt,x,y,col,bg)
		end
	end
	
	print_ml(text,0,0,6,wrap(print_stereo,10,5))
	print_ml(text,0,32,8,wrap(print_outline,10,5))
	print_ml(text,0,72,6,print)
	
	spr(1,100,70)
	spr(1,100,80,1,1,true)	

	outline_spr(1,100,92)
	outline_spr(1,100,105,1,1,true)	

	spr(2,110,70)
	spr(2,110,80,1,1,false,true)	

	outline_spr(2,110,92)
	outline_spr(2,110,105,1,1,false,true)	
	
	seq={25}
	make_noise(seq,31,3,10,90)
	for i=1,#seq do
		line(52,65+i*2-1,52+seq[i],65+i*2-1,11)
	end
end

function print_stereo(txt,x,y,col,bg)
	col=col or 6 --light gray
	bg=bg or 5 --dark gray
	print(txt,x+1,y,bg)
	print(txt,x,y,col)	
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

function rndb(low,high)
  return flr(rnd(high-low+1)+low)
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
__gfx__
000000000dd00000000d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000009d6d200000d5560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000dddddd000d55d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000d6d55dd02ddd60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000dddddd0000d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000009d6d2000006d160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000dd000000d0d506000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000909009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
