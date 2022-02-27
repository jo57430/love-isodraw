--[[
    SFCS Drawing Lib 

    {
        [0/0] = {
            {x = x, y = y, {"type", "material", {0,0,0}}, {"type", "material", {0,0,0}}, {"type", "material", {0,0,0}}} -- Plus Grand au plus petit
        }
    }
]]--


GAME.Drawing.terrain = {}
GAME.Drawing.terrainData = {bgColor = {0,0,0}, name = "nil", ver = "0.0.0", author = "fcs"}
GAME.Drawing.terrainLight = {}

local chunkSize = 9
local chunkLoad = {}
local lastChunk = ""
local defaultDrawChunkRadius = 2
local drawChunkRadius = defaultDrawChunkRadius
local AllowUpdateChunkRadius = true

function GAME.Drawing:ChunkFormat(cx, cy)
    if cx and cy then
        return tostring(cx).."/"..tostring(cy)
    end
    return "0/0"
end
function GAME.Drawing:ChunkUnFormat(str)
    local DataTable = string.explode( "/", str )
    if #DataTable > 1 then
        return tonumber(DataTable[1]), tonumber(DataTable[2])
    end
    return 0, 0
end

function GAME.Drawing:ChunkIsValid(str)
    if GAME.Drawing.terrain[str] then 
        return true 
    end
    return false
end

function GAME.Drawing:ForceRecalculChunk()
    if AllowUpdateChunkRadius then
        local frac = 1-((GAME.Drawing:GetZoom()-0.3)/0.7)
        drawChunkRadius = math.floor(defaultDrawChunkRadius+defaultDrawChunkRadius*frac+0.5)
    end
    lastChunk = ""
end
function GAME.Drawing:GetChunkDrawRadius()
    return drawChunkRadius
end

function GAME.Drawing:GetCurCamChunk()
    local x, y = GAME.Drawing:GetCurPlayerTilePos()
    local cx = math.floor(x/GAME.Drawing:GetChunkSize())
    local cy = math.floor(y/GAME.Drawing:GetChunkSize()) 
    return cx, cy, tostring(cx).."/"..tostring(cy)
end
function GAME.Drawing:GetLoadedCamChunk()
    local cx, cy, str = GAME.Drawing:GetCurCamChunk()
    local temp = ""
    if not (lastChunk == str) then
        debug = str.."|"..lastChunk.."|"
        lastChunk = str
        chunkLoad = {}
        for x=-drawChunkRadius,drawChunkRadius do
            for y=-drawChunkRadius,drawChunkRadius do
                local chStr = GAME.Drawing:ChunkFormat(cx+x, cy+y)
                if GAME.Drawing:ChunkIsValid(chStr) then
                    chunkLoad[#chunkLoad+1] = chStr
                    debug = debug..chStr.."-"
                end
            end
        end
    end
    return chunkLoad
end
function GAME.Drawing:GetChunkSize()
    return chunkSize-1
end
function GAME.Drawing:GetCurPlayerTilePos(int)
    local int = int or 1
    local desPosX, desPosY = GAME.Drawing:GetDescartesScreenPos()
    local tilesWidth = GAME.Drawing:GetTilesWidth()
    return -math.floor((desPosX/tilesWidth*GAME.Drawing:GetZoom())*int)/int, -math.floor((desPosY/tilesWidth*GAME.Drawing:GetZoom())*int)/int
end

-- Fake Map
function GAME.Drawing:FakeMap()
    GAME.Drawing.terrain = {}
    GAME.Drawing.terrainData = {bgColor = {0,0,0}, name = "test", ver = "0.0.0", author = "fcs"}
	GAME.Drawing:LoadTexture({{"materials", "grass", "/ls.png"},{"materials", "water", "/water.png"}})
	for x = 0, 64 do
		for y = 0, 64 do
			local cy = math.floor(x/GAME.Drawing:GetChunkSize())
			local cx = math.floor(y/GAME.Drawing:GetChunkSize()) 
	
			if not GAME.Drawing.terrain[tostring(cx).."/"..tostring(cy)] then GAME.Drawing.terrain[tostring(cx).."/"..tostring(cy)] = {} end
			GAME.Drawing.terrain[tostring(cx).."/"..tostring(cy)][#GAME.Drawing.terrain[tostring(cx).."/"..tostring(cy)]+1] = { x = x, y = y, tile = { {"materials", "grass", {200,200,200}}, } }
	
		end
	end
end