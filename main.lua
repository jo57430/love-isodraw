GAME = {}
local width, height, flags = love.window.getMode( )
GAME.Window = {width = width, height = height, flags = flags}

require("engine/isodraw/draw_main")

function love.load()
	--Variables
	debug = ""

	--Set background to deep blue
	love.graphics.setDefaultFilter("linear", "linear", 8)

	GAME.Drawing:Init()
	--Decode JSON map file
	--isomap.decodeJson("JSONMap.json")

	--Generate map from JSON file (loads assets and creates tables)
	--isomap.generatePlayField()
end


function love.draw()
	GAME.Drawing:draw()
	--isomap.drawGround(x, y, zoomL)
	--isomap.drawObjects(x, y, zoomL)
	info = love.graphics.getStats()
	love.graphics.print("FPS: "..love.timer.getFPS())
	love.graphics.print("Draw calls: "..info.drawcalls, 0, 12)
	love.graphics.print("Texture memory: "..((info.texturememory/1024)/1024).."mb", 0, 24)
	--love.graphics.print("Zoom level: "..GAME.Drawing:getZoom(), 0, 36)
	--love.graphics.print("X: "..math.floor(vector[1]).." Y: "..math.floor(vector[2]).." test :"..vector2[1].."/"..vector2[2], 0, 48)
	love.graphics.print(debug, 0, 100)
	
end

function love.init()
	-- nothing to do.
end

function love.update()

	local change = false
	local amt = 1;
	local screenX, screenY = GAME.Drawing:GetScreenPos();
	-- move player's coord (screen coord sys)

	if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
		screenX = screenX - amt;
		change = true;
	end
	if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
		screenX = screenX + amt;
		change = true;
	end
	if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
		screenY = screenY + amt;
		change = true;
	end
	if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
		screenY = screenY - amt;
		change = true;
	end

	if change then 
		GAME.Drawing:SetScreenPos(screenX, screenY)
	end
end

function love.wheelmoved(x, y)
	local zoom = GAME.Drawing:GetZoom()
	local change = false
    if y > 0 then
      zoom = zoom + 0.05
	  change = true
    elseif y < 0 then
      zoom = zoom - 0.05
	  change = true
    end

	if change then 
		GAME.Drawing:SetZoom(zoom)
	end
	
end

function lerp(a, b, rate) --EMPLOYEE OF THE MONTH
	local result = (1-rate)*a + rate*b
	return result
end

function string.explode(str, div)
    assert(type(str) == "string" and type(div) == "string", "invalid arguments")
    local o = {}
    while true do
        local pos1,pos2 = str:find(div)
        if not pos1 then
            o[#o+1] = str
            break
        end
        o[#o+1],str = str:sub(1,pos1-1),str:sub(pos2+1)
    end
    return o
end