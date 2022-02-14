pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
left,right,up,down,fire1,fire2=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
cls()
z=63 -- half screen size
s=mset
g=flr
for i=0,z*z,1 do
s(i%z,i/z,rnd(2)) -- fill memory random
end
colours={black,white,blue,red}
::_:: -- loop tag
for i=0,z*z,1 do
  ax=i%z
  ay=i/z
  pset(g(ax)*2,g(ay)*2,colours[mget(ax,ay)%4])
end
for i=0,z*z,1 do
  x = g(i%z) 
  y = g(i/z) 
  mst = mget(x,y)
  n=0 if(mst>0)n=-1
  for j=0,8,1 do
  if(pget(g(x+j%3-1)*2,g(y+j/3-1)*2)>0)n+=1end
  if(n<2or n>3)s(x,y,0)
  if(n==3)s(x,y,mst+1)end
goto _
__gfx__