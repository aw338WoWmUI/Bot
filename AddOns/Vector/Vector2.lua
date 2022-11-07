function Vector:magnitude()
  return math.sqrt(
    math.pow(self.x, 2) +
      math.pow(self.y, 2) +
      math.pow(self.z, 2)
  )
end
