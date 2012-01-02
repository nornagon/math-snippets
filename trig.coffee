TAU = Math.PI*2

turnTo = (angle, targetAngle, speed) ->
  diff = targetAngle - angle
  diff -= TAU while diff > TAU/2
  diff += TAU while diff < -TAU/2
  if diff > 0
    # turn ccw
    if diff < speed
      angle = targetAngle
    else
      angle += speed
  else
    # turn cw
    if -diff < speed
      angle = targetAngle
    else
      angle -= speed
  angle
