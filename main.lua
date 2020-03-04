inspect = require("inspect")

function love.load()
	cells={}
	pixels={}
	width=1024
	height=768
	cellsize=25
	cellnum = 0
	draggingEnabled = false
	livingcells=0
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
		livingcells=livingcells+1
	else
		cells[h][w]=0
		livingcells=livingcells-1
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
function getNeighborStatus(direction,h,w)
	totalcellsize=cellsize+1
	if direction==LEFT then
		if w-totalcellsize>0 then
			leftcell_w=w-totalcellsize
			leftalive=alive(h,leftcell_w)
			return leftalive
		end
	elseif direction==RIGHT then
		if w+totalcellsize<width then
			rightcell_w=w+totalcellsize
			rightalive=alive(h,rightcell_w)
			return rightalive
		end
	elseif direction==ABOVE then
		-- This is how our grid is setup, so we can do the math to look around a cell
		--    wwwwwwww
		-- 00:01234567
		-- 26:01234567
		-- 52:01234567
		-- cell=26,3
		-- abovcell=0,3
		
		abovecell=h-totalcellsize
		print(abovecell)
		if abovecell>=0 then
			abovealive=alive(abovecell,w)
			return abovealive
		end
	elseif direction==BELOW then
		belowcell=h+totalcellsize
		if belowcell<height+cellsize then
			belowalive=alive(belowcell,w)
			return belowalive
		end
	end
end
function killCell(h,w)
	cells[h][w]=0
end
function birthCell(h,w)
	cells[h][w]=1
end
function tick()
	if livingcells>10 then
		for h=0,height,cellsize+1 do
			for w=0,width,cellsize+1 do
				if alive(h,w) then
					leftAlive=getNeighborStatus(LEFT,h,w)
					rightAlive=getNeighborStatus(RIGHT,h,w)
					aboveAlive=getNeighborStatus(ABOVE,h,w)
					belowAlive=getNeighborStatus(BELOW,h,w)
					neighborsAlive=0
					if leftAlive then
						neighborsAlive=neighborsAlive+1
					end
					if rightAlive then
						neighborsAlive=neighborsAlive+1
					end
					if aboveAlive then
						neighborsAlive=neighborsAlive+1
					end
					if belowAlive then
						neighborsAlive=neighborsAlive+1
					end
					if neighborsAlive<=2 then
						killCell(h,w)
					elseif neighborsAlive>=3 then
						birthCell(h,w)
					end
				end
			end
		end
	end
end