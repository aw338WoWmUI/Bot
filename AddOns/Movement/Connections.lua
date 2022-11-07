function determineConnections(polygon1, polygon2)
  local points = Array.concat(
    Array.filter(polygon1, isPointOnLineOfPolygon(polygon2)),
    Array.filter(polygon2, isPointOnLineOfPolygon(polygon1))
  )

  local lines = determineConnectionLines(polygon1, polygon2)

  return Array.concat(points, lines)
end

function isPointOnLineOfPolygon(point, polygon)
  local lines = polygonLines(polygon)
  return Array.any(lines, isPointOnLine(point))
end

function isPointOnLine(point, line)
  return calculateSteigung(line[1], point) == calculateSteigung(line[1], line[2]) and
    length(line[1], point) <= length(line[1], line[2])
end

function determineConnectionLines(polygon1, polygon2)
  local lineCombinations = generateLineCombinations(polygon1, polygon2)
  return Array.selectTrue(forAll(lineCombinations, retrieveLineConnection))
end
