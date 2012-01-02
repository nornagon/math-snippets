# Decompose a concave polygon into convex parts.
# Uses the ear clipping algorithm, which is correct but suboptimal and O(n^2).
#
# Cribbed from http://www.ewjordan.com/earClip/

convexicatePolygon = (poly) ->
  throw 'bad poly' unless poly.length % 2 == 0 and poly.length >= 6
  if isConvex poly
    return [poly]
  return polygonizeTriangles triangulatePolygon poly

triangulatePolygon = (vs) ->
  return if vs.length < 6
  triangles = []
  vs = vs.slice()
  while vs.length > 6
    # find an ear
    earIndex = -1
    for i in [0...vs.length/2]
      if isEar i, vs
        earIndex = i
        break

    # no ear means bail out
    return if earIndex < 0

    underIdx = if earIndex == 0 then vs.length/2-1 else earIndex-1
    overIdx = if earIndex == vs.length/2-1 then 0 else earIndex+1

    triangle = [
      vs[earIndex*2], vs[earIndex*2+1]
      vs[overIdx*2], vs[overIdx*2+1]
      vs[underIdx*2], vs[underIdx*2+1]
    ]
    triangles.push triangle

    # clip off the ear
    ear = vs.splice(earIndex*2, 2)
  # add the last triangle
  triangles.push [
    vs[2], vs[3]
    vs[4], vs[5]
    vs[0], vs[1]
  ]
  triangles

addToPoly = (poly, tri) ->
  t_0 = t_1 = t_2 = null
  for i in [0...poly.length/2]
    if poly[i*2] == tri[0] and poly[i*2+1] == tri[1]
      t_0 = i
    else if poly[i*2] == tri[2] and poly[i*2+1] == tri[3]
      t_1 = i
    else if poly[i*2] == tri[4] and poly[i*2+1] == tri[5]
      t_2 = i

  return unless (t_0? and t_1?) or (t_1? and t_2?) or (t_0? and t_2?)
  first = second = -1
  first_t = second_t = -1
  tip_t = -1
  if t_0?
    first = t_0
    first_t = 0
    if t_1?
      second = t_1
      second_t = 1
      tip_t = 2
    else
      second = t_2
      second_t = 2
      tip_t = 1
  else
    first = t_1
    first_t = 1
    second = t_2
    second_t = 2
    tip_t = 0

  if first - second == 1
    insert = first
  else if first - second == -1
    insert = second
  else if first == poly.length/2-1 or second == poly.length/2-1
    insert = poly.length/2
  else
    throw 'but sir, we have but two measly dimensions!'
  poly = poly.slice()
  poly.splice(insert*2, 0, tri[tip_t*2], tri[tip_t*2+1])
  poly

isConvex = (poly) ->
  isPositive = false
  for i in [0...poly.length/2]
    lower = if i == 0 then poly.length/2-1 else i-1
    middle = i
    upper = if i == poly.length/2-1 then 0 else i+1
    dx0 = poly[middle*2]-poly[lower*2]
    dy0 = poly[middle*2+1]-poly[lower*2+1]
    dx1 = poly[upper*2]-poly[middle*2]
    dy1 = poly[upper*2+1]-poly[middle*2+1]
    cross = dx0*dy1-dx1*dy0
    newIsP = cross > 0
    if i == 0
      isPositive = newIsP
    else if isPositive != newIsP
      return false
  return true

polygonizeTriangles = (triangles) ->
  return unless triangles?
  polys = []
  covered = (false for i in [0...triangles.length])
  while true
    currTri = -1
    for i in [0...triangles.length]
      continue if covered[i]
      currTri = i
      break
    if currTri < 0
      break
    poly = triangles[currTri]
    covered[currTri] = true
    for i in [0...triangles.length]
      continue if covered[i]
      newPoly = addToPoly poly, triangles[i]
      if newPoly? and isConvex newPoly
        poly = newPoly
        covered[i] = true
    polys.push poly
  polys

isEar = (i, vs) ->
  upper = i+1
  lower = i-1
  if i == 0
    lower = vs.length/2-1
  else if i == vs.length/2-1
    upper = 0

  dx0 = vs[i*2] - vs[lower*2]
  dy0 = vs[i*2+1] - vs[lower*2+1]
  dx1 = vs[upper*2] - vs[i*2]
  dy1 = vs[upper*2+1] - vs[i*2+1]

  cross = dx0*dy1 - dx1*dy0
  return false if cross > 0

  triangle = [
    vs[i*2], vs[i*2+1]
    vs[upper*2], vs[upper*2+1]
    vs[lower*2], vs[lower*2+1]
  ]
  for j in [0...vs.length/2]
    continue if i == j or j == lower or j == upper
    if triContainsPoint triangle, vs[j*2], vs[j*2+1]
      return false
  return true

triContainsPoint = (tri, x, y) ->
  vx2 = x - tri[0]
  vy2 = y - tri[1]
  vx1 = tri[2] - tri[0]
  vy1 = tri[3] - tri[1]
  vx0 = tri[4] - tri[0]
  vy0 = tri[5] - tri[1]

  dot00 = vx0*vx0+vy0*vy0
  dot01 = vx0*vx1+vy0*vy1
  dot02 = vx0*vx2+vy0*vy2
  dot11 = vx1*vx1+vy1*vy1
  dot12 = vx1*vx2+vy1*vy2
  invDenom = 1 / (dot00*dot11 - dot01*dot01)
  u = (dot11*dot02 - dot01*dot12) * invDenom
  v = (dot00*dot12 - dot01*dot02) * invDenom
  return u > 0 and v > 0 and u+v < 1
