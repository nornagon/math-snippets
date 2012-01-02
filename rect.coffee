# Simple rectangle utilities

Rect =
  union: (r1, r2) ->
    x: x = Math.min r1.x, r2.x
    y: y = Math.min r1.y, r2.y
    w: Math.max(r1.x+(r1.w ? 0), r2.x+(r2.w ? 0)) - x
    h: Math.max(r1.y+(r1.h ? 0), r2.y+(r2.h ? 0)) - y
  intersects: (r1, r2) ->
    not (
      r1.x+r1.w < r2.x or
      r1.y+r1.h < r2.y or
      r1.x > r2.x+r2.w or
      r1.y > r2.y+r2.h
    )
