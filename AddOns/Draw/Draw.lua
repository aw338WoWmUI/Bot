local addOnName, AddOn = ...
Draw = Draw or {}

local function splitIntoTriangles(points)
  local triangles = {}
  local sharedPoint = points[1]
  for i = 2, #points - 1 do
    local point2 = points[i]
    local point3 = points[i + 1]
    local triangle = {
      sharedPoint,
      point2,
      point3
    }
    table.insert(triangles, triangle)
  end
  return triangles
end

local frame = CreateFrame('Frame')

local reusableTextures = {}
local usedTextures = {}

local function createTriangle(triangle, color)
  local texture = table.remove(reusableTextures) or frame:CreateTexture(nil, 'BACKGROUND')
  texture:SetColorTexture(unpack(color))
  texture:SetVertexOffset(LOWER_LEFT_VERTEX, triangle[1].x, triangle[1].y)
  texture:SetVertexOffset(UPPER_LEFT_VERTEX, triangle[2].x, triangle[2].y)
  texture:SetVertexOffset(UPPER_RIGHT_VERTEX, triangle[3].x, triangle[3].y)
  texture:SetVertexOffset(LOWER_RIGHT_VERTEX, triangle[1].x, triangle[1].y)
  texture:Show()
  table.insert(usedTextures, texture)
end

local function createPolygon(points, color)
  local triangles = splitIntoTriangles(points)

  for _, triangle in ipairs(triangles) do
    createTriangle(triangle, color)
  end
end

function Draw.drawPolygon(points, color)
  createPolygon(points, color)
end

local clearCanvas = Draw.clearCanvas
Draw.clearCanvas = function (...)
  for _, usedTexture in ipairs(usedTextures) do
    usedTexture:Hide()
  end
  Array.append(reusableTextures, usedTextures)
  usedTextures = {}
  return clearCanvas(...)
end

--createPolygon({
--  { x = 0, y = 0 },
--  { x = 0, y = 100 },
--  { x = 100, y = 0 }
--})

--createPolygon({
--  { x = 0, y = 0 },
--  { x = 0, y = 100 },
--  { x = 100, y = 100 },
--  { x = 100, y = 0 }
--})

--createPolygon({
--  { x = 0, y = 0 },
--  { x = 0, y = 100 },
--  { x = 100, y = 100 },
--  { x = 150, y = 50 },
--  { x = 100, y = 0 }
--})

--createPolygon({
--  { x = 0, y = 0 },
--  { x = 0, y = 100 },
--  { x = 100, y = 100 },
--  { x = 150, y = 50 },
--  { x = 140, y = 25 },
--  { x = 100, y = 0 }
--})
