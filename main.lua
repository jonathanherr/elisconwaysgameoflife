suit = require 'suit'
-- storage for text input

local speedslider={value=1,min=100,max=1,step=-1}
local cellsizeslider = {value = 0,max=100,min=5,step=5}
function love.load()
	cells={}
	bufferCells={}
	pixels={}
	width=1000
	height=800
	uiwidth=1000
	uiheight=200
	cellsize=5
	cellsizeslider.value=cellsize
	gutterSize=1
	cellnum = 0
	draggingEnabled = false
	livingcells=0
	speed=1
	ticks=0
	go = false	
	W=0
	E=1
	N=2
	S=3
	NW=4
	NE=5
	SW=6
	SE=7
	smallerFont = love.graphics.newFont(10)
	lastCell = {["h"]=-1,["w"]=-1}
	love.window.setTitle("Eli's Conway's Game Of Life")
	print(width/cellsize)
	print(width+((width/cellsize)*gutterSize))
	print(height+((height/cellsize)*gutterSize)+uiheight)
	love.window.setMode(width, height+((height/cellsize)*gutterSize)+uiheight, {resizable=true, vsync=true, minwidth=800, minheight=600})

	initcells()
end
function initcells()
	ticks=0
	cellnum=0
	for h=0,height,cellsize+gutterSize do
		cells[h]={}
		for w=0,width,cellsize+gutterSize do
			cells[h][w]=0
			cellnum=cellnum+1
		end
	end
end
function drawui()
	-- the layout will grow down and to the right from this point
	suit.layout:reset(0,height)
	rows = suit.layout:rows{pos = {0,height}, min_height = 300,
	{200, 25},
	{200, 25},    -- the first cell will measure 200 by 30 px
	{200, 25}, 
	{200, 25},
	{200, 25},
	{200, 25}
}	
	if suit.Slider(cellsizeslider,rows.cell(2)).changed then
		cellsize=cellsizeslider.value
		initcells()
	end
	if not go then
		if suit.Button("Start", rows.cell(3)).hit then
			go=true	
		end
	elseif go then
		if suit.Button("Stop", rows.cell(3)).hit then
			go=false
		end
	end
	if suit.Slider(speedslider,rows.cell(4)).changed then
		speed=speedslider.value
	end
	if suit.Button("Reset", rows.cell(5)).hit then
		initcells()
	end
	if suit.Button("Close", rows.cell(6)).hit then
		love.event.quit()
	end
	
end
function love.update()
	drawui()
end
function love.draw()
	tick()
	suit.draw()
	love.graphics.setBackgroundColor(0,0,0,0)
	for h=0,height,cellsize+gutterSize do
		for w=0,width,cellsize+gutterSize do
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
			r=setCell(x,y)
			if r ~= nil then
				h,w=r
				lastCell.h=h
				lastCell.w=w
			end
		end
	end
end

function love.mousereleased( x, y, button, istouch, presses)
	setCell(x,y)
	draggingEnabled = false
end

function getCell(x,y)
	for h=0,height,cellsize+gutterSize do
		for w=0,width,cellsize+gutterSize do
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
	if h~=nil and h<height and w<width then
		if cells[h][w]==0 then
			cells[h][w]=1
			livingcells=livingcells+1
		else
			cells[h][w]=0
			livingcells=livingcells-1
		end
		return h,w
	end
	return nil
end

function alive(h,w)
	if cells[h][w]==0 then
		return false
	elseif cells[h][w]==1 then
		return true
	end
end
function getNeighborStatus(direction,h,w)
		-- This is how our grid is setup, so we can do the math to look around a cell
		--      ww w w
		-- h 00:02652104
		-- h 26:02652104
		-- h 52:02652104
		-- cell=26,3
		-- abovecell=0,3
		-- where cellsize=25 in this example and guttersize=1
	totalcellsize=cellsize+gutterSize
	if direction==E then
		if w-totalcellsize>0 then
			leftcell_w=w-totalcellsize
			leftalive=alive(h,leftcell_w)
			return leftalive
		end
	elseif direction==W then
		if w+totalcellsize<width then
			rightcell_w=w+totalcellsize
			rightalive=alive(h,rightcell_w)
			return rightalive
		end
	elseif direction==N then
		abovecell=h-totalcellsize
		if abovecell>=0 then
			abovealive=alive(abovecell,w)
			return abovealive
		end
	elseif direction==S then
		belowcell=h+totalcellsize
		if belowcell<height then
			belowalive=alive(belowcell,w)
			return belowalive
		end
	elseif direction==NW then
		-- subtract one row and one column to get NE cell
		nwcell_h=h-totalcellsize
		nwcell_w=w-totalcellsize
		if nwcell_h>=0 and nwcell_w>=0 then
			return alive(nwcell_h,nwcell_w)
		end
	elseif direction==NE then
		-- subtract one row and add one column to get NW cell
		necell_h=h-totalcellsize
		necell_w=w+totalcellsize
		if necell_h>=0 and necell_w<width then
			return alive(necell_h,necell_w)
		end
	elseif direction==SW then
		-- add one row and subract one column to get SW cell
		swcell_h=h+totalcellsize
		swcell_w=w-totalcellsize
		if swcell_h<height and swcell_w>=0 then
			return alive(swcell_h,swcell_w)
		end
	elseif direction==SE then
		-- add one row and add one column to get SE cell
		secell_h=h+totalcellsize
		secell_w=w+totalcellsize
		if secell_h<height and secell_w<width then
			return alive(secell_h,secell_w)
		end
	end
end
function killCell(h,w)
	bufferCells[h][w]=0
end
function birthCell(h,w)
	bufferCells[h][w]=1
end
function copy(obj, seen)
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
	return res
end

function tick()
	if ticks>speed then
		if go then
			-- copy cells into buffercells so we can flip/flop buffer and cells before/after each tick
			bufferCells=copy(cells)		
			
			for h=0,height,cellsize+gutterSize do
				for w=0,width,cellsize+gutterSize do
					--w=west
					--e=east
					--n=north
					--s=south
					--nw=northwest
					--ne=northeast
					--se=southeast
					--sw=southwest
					WAlive=getNeighborStatus(W,h,w)
					EAlive=getNeighborStatus(E,h,w)
					NAlive=getNeighborStatus(N,h,w)
					SAlive=getNeighborStatus(S,h,w)
					NWAlive=getNeighborStatus(NW,h,w)
					NEAlive=getNeighborStatus(NE,h,w)
					SEAlive=getNeighborStatus(SE,h,w)
					SWAlive=getNeighborStatus(SW,h,w)

					neighborsAlive=0
					if WAlive then
						neighborsAlive=neighborsAlive+1
					end
					if EAlive then
						neighborsAlive=neighborsAlive+1
					end
					if NAlive then
						neighborsAlive=neighborsAlive+1
					end
					if SAlive then
						neighborsAlive=neighborsAlive+1
					end
					if NEAlive then
						neighborsAlive=neighborsAlive+1
					end
					if NWAlive then
						neighborsAlive=neighborsAlive+1
					end
					if SEAlive then
						neighborsAlive=neighborsAlive+1
					end
					if SWAlive then
						neighborsAlive=neighborsAlive+1
					end
					if (neighborsAlive<2 or neighborsAlive>3) and alive(h,w) then
						killCell(h,w)
					end
					if neighborsAlive==3 and not alive(h,w) then
						birthCell(h,w)
					end
				end
			end
			
			cells = copy(bufferCells)
			
		end
		ticks=0
	end
	ticks=ticks+1
end