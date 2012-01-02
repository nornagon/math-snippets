# Things you need frequently when interfacing with OpenGL

nextPOT = (n) ->
  pot = 1
  while pot < n
    pot <<= 1
  pot

class MatrixStack
  constructor: ->
    @matrix = [1,0,0, 0,1,0, 0,0,1]
    @stack = []
  push: ->
    @stack.push @matrix
  pop: ->
    return unless @stack.length > 0
    @matrix = @stack.pop()
  mult: (b) ->
    a = @matrix
    @matrix = new Array(9)
    for r in [0...3]
      for c in [0...3]
        @matrix[3*r+c] = b[3*r+0]*a[0+c] +
                         b[3*r+1]*a[3+c] +
                         b[3*r+2]*a[6+c]
    return
  translate: (x, y) ->
    @mult [
      1,0,0
      0,1,0
      x,y,1
    ]
  rotate: (phi) ->
    c = Math.cos phi
    s = Math.sin phi
    @mult [
      c,s,0
     -s,c,0
      0,0,1
    ]
  scale: (sx, sy) ->
    @mult [
      sx,0,0
      0,sy,0
      0,0,1
    ]
  transformPoint: (x, y) ->
    tx = @matrix[0]*x + @matrix[3]*y + @matrix[6]
    ty = @matrix[1]*x + @matrix[4]*y + @matrix[7]
    tz = @matrix[2]*x + @matrix[5]*y + @matrix[8]
    return {x:tx/tz, y:ty/tz}
  transformAABB: (bb) ->
    r = @transformPoint bb.x, bb.y
    r = Rect.union r, @transformPoint bb.x+bb.w, bb.y
    r = Rect.union r, @transformPoint bb.x+bb.w, bb.y+bb.h
    r = Rect.union r, @transformPoint bb.x, bb.y+bb.h
    r
