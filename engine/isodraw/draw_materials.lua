--[[
    SFCS Drawing Lib 
]]--

GAME.Drawing.loadedMaterials = { ["materials"] = {}, ["sprites"] = {}, ["decals"] = {},}
GAME.Drawing.MaterialsCount = 0

local defaultTexture = {{"materials", "nil", "/isodraw/error.png"},{"materials", "air", "/isodraw/air.png"},{"materials", "dev", "/isodraw/dev.png"},}
local materialsPath = "/materials"
local tilesHight = 0
local tilesWidth = 0
local drawReady = false

-- Init/Load Texture
local function AddTexture(type,name,path)
    type = type or "nil"
    name = name or "nil"
    path = path or ""
    if love.filesystem.getInfo( materialsPath..path ) and (not GAME.Drawing.loadedMaterials[type] or not GAME.Drawing.loadedMaterials[type][name]) then
        if not GAME.Drawing.loadedMaterials[type] then GAME.Drawing.loadedMaterials[type] = {} end

        GAME.Drawing.loadedMaterials[type][name] = love.graphics.newImage(materialsPath..path)
        GAME.Drawing.MaterialsCount = GAME.Drawing.MaterialsCount + 1
    end
end

function GAME.Drawing:ClearTexture()
    GAME.Drawing:SetDrawReady(false)
	GAME.Drawing.loadedMaterials = {} -- clear
    GAME.Drawing.MaterialsCount = 0

    GAME.Drawing:LoadTexture(defaultTexture)
    GAME.Drawing:UpdateTilesWidth()
    GAME.Drawing:UpdateTilesHight()
    GAME.Drawing:SetDrawReady(true)
end
function GAME.Drawing:LoadTexture(data)
	if data then 
        for k, v in pairs(data)do
            AddTexture(v[1],v[2],v[3])
        end
    end
end

function GAME.Drawing:GetTexture(type, name)
    if not type or not name or not GAME.Drawing.loadedMaterials[type][name] then
        type = "materials"
        name = "nil"
    end

    return GAME.Drawing.loadedMaterials[type][name]
end

-- TilesHight
function GAME.Drawing:UpdateTilesHight()
    tilesHight = (GAME.Drawing:GetTexture("materials", "dev"):getHeight()/2)*GAME.Drawing:GetZoom()
end
function GAME.Drawing:GetTilesHight()
    return tilesHight
end
function GAME.Drawing:UpdateTilesWidth()
    tilesWidth = (GAME.Drawing:GetTexture("materials", "dev"):getWidth()/2)*GAME.Drawing:GetZoom()
end
function GAME.Drawing:GetTilesWidth()
    return tilesWidth
end


-- DrawReady
function GAME.Drawing:SetDrawReady(bool)
    bool = bool or false
    drawReady = bool
end
function GAME.Drawing:GetDrawReady()
    return drawReady
end
