Draw = {}

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
  texture:SetVertexOffset(LOWER_LEFT_VERTEX, triangle[1][1], triangle[1][2])
  texture:SetVertexOffset(UPPER_LEFT_VERTEX, triangle[2][1], triangle[2][2])
  texture:SetVertexOffset(UPPER_RIGHT_VERTEX, triangle[3][1], triangle[3][2])
  texture:SetVertexOffset(LOWER_RIGHT_VERTEX, triangle[1][1], triangle[1][2])
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

local hasBeenConnectedWithLibDraw = false

function Draw.connectWithLibDraw(libDraw)
  if not hasBeenConnectedWithLibDraw then
    local clearCanvas = libDraw.clearCanvas
    libDraw.clearCanvas = function (...)
      for _, usedTexture in ipairs(usedTextures) do
        usedTexture:Hide()
      end
      reusableTextures = usedTextures
      usedTextures = {}
      return clearCanvas(...)
    end
    hasBeenConnectedWithLibDraw = true
  end
end

--createPolygon({
--  {0, 0},
--  {0, 100},
--  {100, 0}
--})

--createPolygon({
--  {0, 0},
--  {0, 100},
--  {100, 100},
--  {100, 0}
--})

--createPolygon({
--  {0, 0},
--  {0, 100},
--  {100, 100},
--  {150, 50},
--  {100, 0}
--})

--createPolygon({
--  {0, 0},
--  {0, 100},
--  {100, 100},
--  {150, 50},
--  {140, 25},
--  {100, 0}
--})
