inspect = require("inspect")

function love.load()
	cells={}
	pixels={}
	width=1024
	height=768
	cellsize=25
	cellnum = 0
	draggingEnabled = false
	lastCell = {["h"]=-1,["w"]=-1}
	love.window.setTitle("Eli's Conway's Game Of Life")
	love.window.setMode(width, height, {resizable=true, vsync=false, minwidth=800, minheight=600})

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
		print(h,w)
		print(inspect(lastCell))
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

function tick()
	
end