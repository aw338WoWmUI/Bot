-- Source: https://rosettacode.org/wiki/Vector_products#Lua
-- License: https://creativecommons.org/licenses/by-sa/4.0/
-- The code has been modified.

Vector = Vector or {}

Vector.Vector = {}

function Vector.Vector:new(x, y, z)
  local vector = { x = x, y = y, z = z }
  setmetatable(vector, { __index = Vector.Vector })
  return vector
end

function Vector.Vector:cross(B)
  return Vector.Vector:new(
    self.y * B.z - self.z * B.y,
    self.z * B.x - self.x * B.z,
    self.x * B.y - self.y * B.x
  )
end
