--[[
    SFCS Drawing Lib 
]]--


GAME.Drawing = {}
GAME.Drawing.loadedMaterials = {}
GAME.Drawing.terrain = {}

-- require
-- https://github.com/davidm/lua-matrix/blob/master/lua/matrix.lua
local matrix = require("engine/isodraw/matrix")
require("engine/isodraw/draw_materials")
require("engine/isodraw/draw_terrain")

-- Origin x,y (Screen coord)
local Ix0, Iy0 = 0, 0; -- Isometric
local Dx0, Dy0 = 0, 0; -- Descartes

-- invert y axis, move to Dx0, Dy0
local descartesToScreenMatrix = (matrix{{1, 0, Dx0}, {0, 1, Dy0}, {0, 0, 1}} * matrix{{1, 0, 0}, {0, -1, 0}, {1, 0, 1}})
-- Basis Vector I is (sqrt(3)/2, -1/2), J is (0, 1)
local descartesToIsometricMatrix = matrix{{-1, 1, 0}, {0.5, 0.5, 0}, {0, 0, 1}};
-- invert D to I
local isometricToDescartesMatrix = matrix.invert(descartesToIsometricMatrix);
-- invert y axis, move to Ix0, Iy0
local isometricToScreenMatrix = (matrix{{1, 0, Ix0}, {0, 1, Iy0}, {0, 0, 1}} * matrix{{1, 0, 0}, {0, -1, 0}, {0, 0, 1}})

-- Player is in the ISOMETRIC coord.
local screenX, screenY = 0,0;
-- transformed player position (in descartes)
local desPosX, desPosY = 0,0;
-- WorldZoom
local zoom = 0.6
local zoom_limit = {0.3, 1}

-- TestMap Load
local LoadTestMap = true

-- local ZeroDecal
local tilesSize = { hight = GAME.Drawing:GetTilesHight(), width = GAME.Drawing:GetTilesWidth()}
local ScreenCenter = {x = ((GAME.Window.width)*0.5), y = ((GAME.Window.height)*0.5)}
local ScreenCenterMove = {x = ((GAME.Window.width)*0.5)+(tilesSize.width*(zoom-1)), y = ((GAME.Window.height)*0.5)+(tilesSize.hight*(zoom))}

function GAME.Drawing:draw()
	local loadedChunk = GAME.Drawing:GetLoadedCamChunk()
	local ChunkSize = GAME.Drawing:GetChunkSize()

	if GAME.Drawing:GetDrawReady() then
		for _, chunk in ipairs(loadedChunk) do
			for _, v in ipairs(GAME.Drawing.terrain[chunk]) do
				local data = v

				for _, tile in ipairs(data.tile) do

					love.graphics.setColor(tile[3][1], tile[3][2], tile[3][3], 255);

					local posX, posY = DescartesToIsometricCoordinate(data.x*tilesSize.width, data.y*tilesSize.width)
					love.graphics.draw( GAME.Drawing:GetTexture(tile[1], tile[2]),
					(posX-screenX*zoom)+ScreenCenterMove.x,
					(posY+screenY*zoom)+ScreenCenterMove.y,
					0, 
					zoom, 
					zoom, 
					tilesSize.width, 
					tilesSize.hight )
				end
			end
		end
	end
	--(tempX-screenX*zoomVal)+width+(tilesWidth*(zoomVal-1)),
	--(tempY+screenY*zoomVal)+height+(tilesHight*(zoomVal)), 
	-- info

	local TileX, TileY = GAME.Drawing:GetCurPlayerTilePos(10)
	love.graphics.print("[Use WASD or Arrow keys to move, you're moving player in isometric]", 0, 38);
	love.graphics.print("Descartes player Position "..math.floor(desPosX).." , "..math.floor(desPosY), 0, 50);
	love.graphics.print("Player is on Tile ("..(TileX).." , "..(TileY)..")", 0, 62);
	love.graphics.print("Zoom : "..zoom, 0, 74);

	-- Cursor
	love.graphics.line(ScreenCenter.x-10, ScreenCenter.y, ScreenCenter.x+10, ScreenCenter.y);
	love.graphics.line(ScreenCenter.x, ScreenCenter.y-10, ScreenCenter.x, ScreenCenter.y+10);
end

-- matrix * vector (transform) functions
function DescartesToScreenCoordinate(x, y)
	descartesPosition = matrix{{x}, {y}, {1}};
	screenPosition = descartesToScreenMatrix * descartesPosition;

	return screenPosition[1][1], screenPosition[2][1];
end
function DescartesToIsometricCoordinate(x, y)
	descartesPosition = matrix{{x}, {y}, {1}};
	isometricPosition = descartesToIsometricMatrix * descartesPosition;

	return isometricPosition[1][1], isometricPosition[2][1];
end
function IsometricToDescartesCoordinate(x, y)
	isometricPosition = matrix{{x}, {y}, {1}};
	descartesPosition = isometricToDescartesMatrix * isometricPosition;

	return descartesPosition[1][1], descartesPosition[2][1];
end
function IsometricToScreenCoordinate(x, y)
	isometricPosition = matrix{{x}, {y}, {1}};
	screenPosition = isometricToScreenMatrix * isometricPosition;

	return screenPosition[1][1], screenPosition[2][1];
end

-- Tile ScreenPos
function GAME.Drawing:GetDescartesScreenPos()
	return desPosX, desPosY
end
function GAME.Drawing:SetDescartesScreenPos(x, y) -- Descartes cord --363 363
	desPosX, desPosY = x, y;
	screenX, screenY = DescartesToIsometricCoordinate(x, y)
end
-- Iso ScreenPos
function GAME.Drawing:GetScreenPos()
	return screenX, screenY
end
function GAME.Drawing:SetScreenPos(x, y) -- Descartes cord --363 363
	screenX, screenY = x, y;
	desPosX, desPosY = IsometricToDescartesCoordinate(screenX, screenY);
end
-- Zoom
function GAME.Drawing:GetZoom()
	return zoom 
end
function GAME.Drawing:SetZoom(int)
	if int < zoom_limit[1] then
		int = zoom_limit[1]
	elseif int > zoom_limit[2] then
		int = zoom_limit[2]
	end
	zoom = int
	GAME.Drawing:UpdateTilesWidth()
	GAME.Drawing:UpdateTilesHight()
	GAME.Drawing:UpdateSize()
	GAME.Drawing:ForceRecalculChunk()
end

-- update Screen Center And Size (update after load map) 
function GAME.Drawing:UpdateSize()
	tilesSize = { hight = GAME.Drawing:GetTilesHight(), width = GAME.Drawing:GetTilesWidth()}
	ScreenCenter = {x = ((GAME.Window.width)*0.5), y = ((GAME.Window.height)*0.5)}
	ScreenCenterMove = {x = ((GAME.Window.width)*0.5)+(tilesSize.width*(zoom-1)), y = ((GAME.Window.height)*0.5)+(tilesSize.hight*(zoom))}
end

-- Lib init Var
function GAME.Drawing:Init()
	GAME.Drawing:ClearTexture() -- texture lib
	if LoadTestMap then
		GAME.Drawing:FakeMap()
	else

	end
	love.graphics.setBackgroundColor(GAME.Drawing.terrainData.bgColor[1], GAME.Drawing.terrainData.bgColor[2], GAME.Drawing.terrainData.bgColor[3])
	GAME.Drawing:UpdateSize()
	GAME.Drawing:SetDrawReady(true) -- texture lib
	GAME.Drawing:SetDescartesScreenPos(0, 0)
end
