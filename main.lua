inspect = require("inspect")

function love.load()
	cells={}
	pixels={}
	width=1024
	height=768
	cellsize=25
	cellnum = 0
	draggingEnabled = false
	LEFT=0
	RIGHT=1
	ABOVE=2
	BELOW=3
	lastCell = {["h"]=-1,["w"]=-1}
	love.window.setTitle("Eli's Conway's Game Of Life")
	love.window.setMode(width+(width/cellsize), height+(height/cellsize), {resizable=true, vsync=true, minwidth=800, minheight=600})

	for h=0,height,cellsize+1 do
		cells[h]={}
		for w=0,width,cellsize+1 do
			cells[h][w]=0
			cellnum=cellnum+1
		end
	end
end

function love.draw()
	tick()
	love.graphics.setBackgroundColor(0,0,0,0)
	for h=0,height,cellsize+1 do
		for w=0,width,cellsize+1 do
			if cells[h][w]==0 then
				love.graphics.setColor(1,0,0)
			else
				love.graphics.setColor(0,0,1)
			end
			
			love.graphics.rectangle('fill',w,h,cellsize,cellsize)
		end
	end
end

function love.mousepressed(x,y,button)
	draggingEnabled=true
end

function love.mousemoved(x,y,dx,dy,istouch)
	if draggingEnabled then
		h,w=getCell(x,y)
		if lastCell.h~=h or lastCell.w~=w then
			h,w=setCell(x,y)
			lastCell.h=h
			lastCell.w=w
		end
	end
end

function love.mousereleased( x, y, button, istouch, presses)
	setCell(x,y)
	draggingEnabled = false
end

function getCell(x,y)
	for h=0,height,cellsize+1 do
		for w=0,width,cellsize+1 do
			if y>=h and y<=h+cellsize then
				if x>=w and x<=w+cellsize then
					return h,w
				end
			end
		end
	end
end

function setCell(x,y)
	h,w=getCell(x,y)
	if cells[h][w]==0 then
		cells[h][w]=1
	else
		cells[h][w]=0
	end
	return h,w
end

function alive(h,w)
	if cells[h][w]==0 then
		return false
	elseif cells[h][w]==1 then
		return true
	end
end
function getNeighbor(direction,h,w)
	totalcellsize=cellsize+1
	if direction==LEFT then
		if w-totalcellsize>0 then
			leftcell_w=w-totalcellsize
			leftalive=alive(h,leftcell_w)
			if leftalive then
				print("left")
				print(h,leftcell_w)
			end
			return leftalive
		end
	elseif direction==RIGHT then
		print("right")
	elseif direction==ABOVE then
		print("above")
	elseif direction==BELOW then
		print("below")
	end
end
function tick()
	for h=0,height,cellsize+1 do
		for w=0,width,cellsize+1 do
			if alive(h,w) then
				leftAlive=getNeighbor(LEFT,h,w)
			end
			--rightAlive=getNeighbor(RIGHT,h,w)
			--aboveAlive=getNeighbor(ABOVE,h,w)
			--belowAlive=getNeighbor(BELOW,h,w)

		end
	end
end