-- print text utils
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

function print_multiline(doc,x,y,lh,printer)
 local offset=0
	foreach(doc,function(txt)
		printer(txt,x,y+offset)
		offset+=lh
	end)
end

-- 64 is half of the screen width (128 / 2). To calculate the x
-- coordinate, the length of the string is multiplied by half
-- of the character width (4 / 2), then subtracted from 64.
-- Similarly, the y coordinate is 60 = 64 - (8 / 2).
function print_centered(str, y, c)
	y = y or 60
	c = c or 7
	print(str, 64 - 2*#str, y, c)
end