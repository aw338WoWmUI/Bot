-- This version is based on https://gist.github.com/benphelps/7f88f181978267edf899.
-- Most code seems to be copyrighted by its author(s).

-- LubDraw orginally by docbrown on fh-wow.com

local addOnName, AddOn = ...
Draw = Draw or {}

local sin, cos, atan, atan2, sqrt, rad = math.sin, math.cos, math.atan, math.atan2, math.sqrt, math.rad
local tinsert, tremove = tinsert, tremove

local function WorldToScreen(x, y, z)
  local screenX, screenY = select(2, HWT.WorldToScreen(x, y, z))
  return screenX * WorldFrame:GetWidth(), -(WorldFrame:GetTop() - screenY * WorldFrame:GetHeight())
end

Draw.line = Draw.line or { r = 0, g = 1, b = 0, a = 1, w = 1 }
Draw.level = "BACKGROUND"
Draw.callbacks = { }

if not Draw.canvas then
	Draw.canvas = CreateFrame("Frame", WorldFrame)
	Draw.canvas:SetAllPoints(WorldFrame)
  Draw.lines = { }
  Draw.lines_used = { }
	Draw.textures = { }
	Draw.textures_used = { }
	Draw.fontstrings = { }
	Draw.fontstrings_used = { }
end

function Draw.SetColor(r, g, b, a)
	Draw.line.r = r * 0.00390625
	Draw.line.g = g * 0.00390625
	Draw.line.b = b * 0.00390625
	if a then
		Draw.line.a = a * 0.01
	else
		Draw.line.a = 1
	end
end

function Draw.SetColorRaw(r, g, b, a)
	Draw.line.r = r
	Draw.line.g = g
	Draw.line.b = b
	Draw.line.a = a
end

function Draw.SetWidth(w)
	Draw.line.w = w
end

function Draw.Line(sx, sy, sz, ex, ey, ez)
	local sx, sy = WorldToScreen(sx, sy, sz)
	local ex, ey = WorldToScreen(ex, ey, ez)

	Draw.Draw2DLine(sx, sy, ex, ey)
end

function Draw.rotateX(cx, cy, cz, px, py, pz, r)
	if r == nil then return px, py, pz end
	local s = sin(r)
	local c = cos(r)
	-- center of rotation
	px, py, pz = px - cx,  py - cy, pz - cz
	local x = px + cx
	local y = ((py * c - pz * s) + cy)
	local z = ((py * s + pz * c) + cz)
	return x, y, z
end

function Draw.rotateY(cx, cy, cz, px, py, pz, r)
	if r == nil then return px, py, pz end
	local s = sin(r)
	local c = cos(r)
	-- center of rotation
	px, py, pz = px - cx,  py - cy, pz - cz
	local x = ((pz * s + px * c) + cx)
	local y = py + cy
	local z = ((pz * c - px * s) + cz)
	return x, y, z
end

function Draw.rotateZ(cx, cy, cz, px, py, pz, r)
	if r == nil then return px, py, pz end
	local s = sin(r)
	local c = cos(r)
	-- center of rotation
	px, py, pz = px - cx,  py - cy, pz - cz
	local x = ((px * c - py * s) + cx)
	local y = ((px * s + py * c) + cy)
	local z = pz + cz
	return x, y, z
end

function Draw.Array(vectors, x, y, z, rotationX, rotationY, rotationZ)
	for _, vector in ipairs(vectors) do
		local sx, sy, sz = x+vector[1], y+vector[2], z+vector[3]
		local ex, ey, ez = x+vector[4], y+vector[5], z+vector[6]

		if rotationX then
			sx, sy, sz = Draw.rotateX(x, y, z, sx, sy, sz, rotationX)
			ex, ey, ez = Draw.rotateX(x, y, z, ex, ey, ez, rotationX)
		end
		if rotationY then
			sx, sy, sz = Draw.rotateY(x, y, z, sx, sy, sz, rotationY)
			ex, ey, ez = Draw.rotateY(x, y, z, ex, ey, ez, rotationY)
		end
		if rotationZ then
			sx, sy, sz = Draw.rotateZ(x, y, z, sx, sy, sz, rotationZ)
			ex, ey, ez = Draw.rotateZ(x, y, z, ex, ey, ez, rotationZ)
		end

		local sx, sy = WorldToScreen(sx, sy, sz)
		local ex, ey = WorldToScreen(ex, ey, ez)
		Draw.Draw2DLine(sx, sy, ex, ey)
	end
end

function Draw.Draw2DLine(sx, sy, ex, ey)
	if not sx or not sy or not ex or not ey then return end

	local L = tremove(Draw.lines) or false
	if L == false then
		L = CreateFrame("Frame", Draw.canvas)
    L.line = L:CreateLine()
		L.line:SetDrawLayer(Draw.level)
	end
	tinsert(Draw.lines_used, L)

  L:ClearAllPoints()

  if sx > ex and sy > ey or  sx < ex and sy < ey  then
    L:SetPoint("TOPRIGHT", Draw.canvas, "TOPLEFT", sx, sy)
    L:SetPoint("BOTTOMLEFT", Draw.canvas, "TOPLEFT", ex, ey)
    L.line:SetStartPoint('TOPRIGHT')
    L.line:SetEndPoint('BOTTOMLEFT')
  elseif sx < ex and sy > ey then
    L:SetPoint("TOPLEFT", Draw.canvas, "TOPLEFT", sx, sy)
    L:SetPoint("BOTTOMRIGHT", Draw.canvas, "TOPLEFT", ex, ey)
    L.line:SetStartPoint('TOPLEFT')
    L.line:SetEndPoint('BOTTOMRIGHT')
  elseif sx > ex and sy < ey then
    L:SetPoint("TOPRIGHT", Draw.canvas, "TOPLEFT", sx, sy)
    L:SetPoint("BOTTOMLEFT", Draw.canvas, "TOPLEFT", ex, ey)
    L.line:SetStartPoint('TOPLEFT')
    L.line:SetEndPoint('BOTTOMRIGHT')
  else
    -- wat, I don't like this, not one bit
    L:SetPoint("TOPLEFT", Draw.canvas, "TOPLEFT", sx, sy)
    L:SetPoint("BOTTOMLEFT", Draw.canvas, "TOPLEFT", sx, ey)
    L.line:SetStartPoint('TOPLEFT')
    L.line:SetEndPoint('BOTTOMLEFT')
  end

  L.line:SetThickness(Draw.line.w)
	L.line:SetColorTexture(Draw.line.r, Draw.line.g, Draw.line.b, Draw.line.a)

	L:Show()
end

local full_circle = rad(360)
local small_circle_step = rad(360 / 20)

function Draw.Circle(x, y, z, size)
	local lx, ly, nx, ny, fx, fy = false, false, false, false, false, false
	for v=0, full_circle, small_circle_step do
		nx, ny = WorldToScreen( (x+cos(v)*size), (y+sin(v)*size), z )
		Draw.Draw2DLine(lx, ly, nx, ny)
		lx, ly = nx, ny
	end
end

local flags = bit.bor(0x100)

function Draw.GroundCircle(x, y, z, size)
	local lx, ly, nx, ny, fx, fy, fz = false, false, false, false, false, false, false
	for v=0, full_circle, small_circle_step do
		fx, fy, fz = HWT.TraceLine(  (x+cos(v)*size), (y+sin(v)*size), z+100, (x+cos(v)*size), (y+sin(v)*size), z-100, flags )
		if fx == nil then
			fx, fy, fz = (x+cos(v)*size), (y+sin(v)*size), z
		end
		nx, ny = WorldToScreen( (fx+cos(v)*size), (fy+sin(v)*size), fz )
		Draw.Draw2DLine(lx, ly, nx, ny)
		lx, ly = nx, ny
	end
end

function Draw.Arc(x, y, z, size, arc, rotation)
	local lx, ly, nx, ny, fx, fy = false, false, false, false, false, false
	local half_arc = arc * 0.5
	local ss = (arc/half_arc)
	local as, ae = -half_arc, half_arc
	for v = as, ae, ss do
		nx, ny = WorldToScreen( (x+cos(rotation+rad(v))*size), (y+sin(rotation+rad(v))*size), z )
		if lx and ly then
			Draw.Draw2DLine(lx, ly, nx, ny)
		else
			fx, fy = nx, ny
		end
		lx, ly = nx, ny
	end
	local px, py = WorldToScreen(x, y, z)
	Draw.Draw2DLine(px, py, lx, ly)
	Draw.Draw2DLine(px, py, fx, fy)
end

function Draw.Texture(config, x, y, z, alphaA)

	local texture, width, height = config.texture, config.width, config.height
	local left, right, top, bottom, scale =  config.left, config.right, config.top, config.bottom, config.scale
	local alpha = config.alpha or alphaA

	if not texture or not width or not height or not x or not y or not z then return end
	if not left or not right or not top or not bottom then
		left = 0
		right = 1
		top = 0
		bottom = 1
	end
	if not scale then
		local cx, cy, cz = GetCameraPosition()
		scale = width / Draw.Distance(x, y, z, cx, cy, cz)
	end

	local sx, sy = WorldToScreen(x, y, z)
	if not sx or not sy then return end
	local w = width * scale
	local h = height * scale
	sx = sx - w*0.5
	sy = sy + h*0.5
	local ex, ey = sx + w, sy - h

	local T = tremove(Draw.textures) or false
	if T == false then
		T = Draw.canvas:CreateTexture(nil, "BACKGROUND")
		T:SetDrawLayer(Draw.level)
		T:SetTexture(Draw.texture)
	end
	tinsert(Draw.textures_used, T)
	T:ClearAllPoints()
	T:SetTexCoord(left, right, top, bottom)
	T:SetTexture(texture)
	T:SetWidth(width)
	T:SetHeight(height)
	T:SetPoint("TOPLEFT", Draw.canvas, "TOPLEFT", sx, sy)
	T:SetPoint("BOTTOMRIGHT", Draw.canvas, "TOPLEFT", ex, ey)
	T:SetVertexColor(1, 1, 1, 1)
	if alpha then T:SetAlpha(alpha) else T:SetAlpha(1) end
	T:Show()

end

function Draw.Text(text, font, x, y, z)

	local sx, sy = WorldToScreen(x, y, z)

	if sx and sy then

		local F = tremove(Draw.fontstrings) or Draw.canvas:CreateFontString(nil, "BACKGROUND")

		F:SetFontObject(font)
		F:SetText(text)
		F:SetTextColor(Draw.line.r, Draw.line.g, Draw.line.b, Draw.line.a)

		if p then
			local width = F:GetStringWidth() - 4
			local offsetX = width*0.5
			local offsetY = F:GetStringHeight() + 3.5
			local pwidth = width*p*0.01
			FHAugment.drawLine(sx-offsetX, sy-offsetY, (sx+offsetX), sy-offsetY, 4, r, g, b, 0.25)
			FHAugment.drawLine(sx-offsetX, sy-offsetY, (sx+offsetX)-(width-pwidth), sy-offsetY, 4, r, g, b, 1)
		end

		F:SetPoint("TOPLEFT", UIParent, "TOPLEFT", sx-(F:GetStringWidth()*0.5), sy)
		F:Show()

		tinsert(Draw.fontstrings_used, F)

	end

end

local rad90 = math.rad(-90)

function Draw.Box(x, y, z, width, height, rotation, offset_x, offset_y)

	if not offset_x then offset_x = 0 end
	if not offset_y then offset_y = 0 end

	if rotation then rotation = rotation + rad90 end

	local half_width = width * 0.5
	local half_height = height * 0.5

	local p1x, p1y = Draw.rotateZ(x, y, z, x - half_width + offset_x, y - half_width + offset_y, z, rotation)
	local p2x, p2y = Draw.rotateZ(x, y, z, x + half_width + offset_x, y - half_width + offset_y, z, rotation)
	local p3x, p3y = Draw.rotateZ(x, y, z, x - half_width + offset_x, y + half_width + offset_y, z, rotation)
	local p4x, p4y = Draw.rotateZ(x, y, z, x - half_width + offset_x, y - half_width + offset_y, z, rotation)
	local p5x, p5y = Draw.rotateZ(x, y, z, x + half_width + offset_x, y + half_width + offset_y, z, rotation)
	local p6x, p6y = Draw.rotateZ(x, y, z, x + half_width + offset_x, y - half_width + offset_y, z, rotation)
	local p7x, p7y = Draw.rotateZ(x, y, z, x - half_width + offset_x, y + half_width + offset_y, z, rotation)
	local p8x, p8y = Draw.rotateZ(x, y, z, x + half_width + offset_x, y + half_width + offset_y, z, rotation)

	Draw.Line(p1x, p1y, z, p2x, p2y, z)
	Draw.Line(p3x, p3y, z, p4x, p4y, z)
	Draw.Line(p5x, p5y, z, p6x, p6y, z)
	Draw.Line(p7x, p7y, z, p8x, p8y, z)

end

local deg45 = math.rad(45)
local arrowX = {
	{ 0  , 0, 0, 1.5,  0,    0   },
	{ 1.5, 0, 0, 1.2,  0.2, -0.2 },
	{ 1.5, 0, 0, 1.2, -0.2,  0.2 }
}
local arrowY = {
	{ 0, 0  , 0,  0  , 1.5,  0   },
	{ 0, 1.5, 0,  0.2, 1.2, -0.2 },
	{ 0, 1.5, 0, -0.2, 1.2,  0.2 }
}
local arrowZ = {
	{ 0, 0, 0  ,  0,    0,   1.5 },
	{ 0, 0, 1.5,  0.2, -0.2, 1.2 },
	{ 0, 0, 1.5, -0.2,  0.2, 1.2 }
}

function Draw.DrawHelper()
	local playerX, playerY, playerZ = HWT.ObjectPosition("player")
	local old_red, old_green, old_blue, old_alpha, old_width = Draw.line.r, Draw.line.g, Draw.line.b, Draw.line.a, Draw.line.w

	-- X
	Draw.SetColor(255, 0, 0, 100)
	Draw.SetWidth(1)
	Draw.Array(arrowX, playerX, playerY, playerZ, deg45, false, false)
	Draw.Text('X', "GameFontNormal", playerX + 1.75, playerY, playerZ)
  --Draw.Line(playerX, playerY, playerZ, playerX + 1.75, playerY, playerZ)

	-- Y
	Draw.SetColor(0, 255, 0, 100)
	Draw.SetWidth(1)
	Draw.Array(arrowY, playerX, playerY, playerZ, false, -deg45, false)
	Draw.Text('Y', "GameFontNormal", playerX, playerY + 1.75, playerZ)
  --Draw.Line(playerX, playerY, playerZ, playerX, playerY + 1.75, playerZ)
	-- Z
	Draw.SetColor(0, 0, 255, 100)
	Draw.SetWidth(1)
	Draw.Array(arrowZ, playerX, playerY, playerZ, false, false, false)
	Draw.Text('Z', "GameFontNormal", playerX, playerY, playerZ + 1.75)
  --Draw.Line(playerX, playerY, playerZ, playerX, playerY, playerZ + 1.75)

	Draw.line.r, Draw.line.g, Draw.line.b, Draw.line.a, Draw.line.w = old_red, old_green, old_blue, old_alpha, old_width
end

function Draw.Distance(ax, ay, az, bx, by, bz)
	return math.sqrt(((bx-ax)*(bx-ax)) + ((by-ay)*(by-ay)) + ((bz-az)*(bz-az)))
end

function Draw.Camera()
	local fX, fY, fZ = HWT.ObjectPosition("player")
	local sX, sY, sZ = HWT.GetCameraPosition()
	return sX, sY, sZ, atan2(sY - fY, sX - fX), atan((sZ - fZ) / sqrt(((fX - sX) ^ 2) + ((fY - sY) ^ 2)))
end

function Draw.Sync(callback)
	tinsert(Draw.callbacks, callback)
end

function Draw.clearCanvas()
	for i = 1, #Draw.textures_used do
		Draw.textures_used[i]:Hide()
	end
  Array.append(Draw.textures, Draw.textures_used)
  Draw.textures_used = {}

	for i = 1, #Draw.fontstrings_used do
		Draw.fontstrings_used[i]:Hide()
	end
  Array.append(Draw.fontstrings, Draw.fontstrings_used)
  Draw.fontstrings_used = {}

  for i = 1, #Draw.lines_used do
		Draw.lines_used[i]:Hide()
	end
  Array.append(Draw.lines, Draw.lines_used)
  Draw.lines_used = {}
end

local function OnUpdate()
	Draw.clearCanvas()
	for _, callback in ipairs(Draw.callbacks) do
		callback()
		if Draw.helper then
			Draw.DrawHelper()
		end
		Draw.helper = false
	end
end

local isEnabled = false

Draw.toggle = function ()
  if isEnabled then
    Draw.disable()
  else
    Draw.enable()
  end
end

Draw.enable = function ()
  if not isEnabled then
    isEnabled = true
    Draw.canvas:SetScript("OnUpdate", OnUpdate)
  end
end

Draw.disable = function ()
  if isEnabled then
    isEnabled = false
    Draw.canvas:SetScript('OnUpdate', nil)
    Draw.clearCanvas()
  end
end

Draw.enable()
