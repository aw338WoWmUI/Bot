Caching = {}

function Caching.cached(fn)
  local hasResultBeenCached = false
  local cachedResult = nil
  return function(...)
    if not hasResultBeenCached then
      cachedResult = { fn(...) }
      hasResultBeenCached = true
    end
    return unpack(cachedResult)
  end
end
